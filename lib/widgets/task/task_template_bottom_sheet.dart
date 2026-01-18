import 'package:flutter/material.dart';
import '../../models/task_template.dart';
import '../../models/task.dart';
import '../../services/main_data_service.dart';
import '../common/bottom_sheet_header.dart';
import '../template/empty_template_state.dart';
import '../template/template_create_button.dart';

class TaskTemplateBottomSheet extends StatelessWidget {
  final MainDataService dataService;
  final Function(TaskTemplate)? onTemplateSelected;
  final Function(TaskTemplate)? onTemplateEdit;
  final Function(TaskTemplate)? onTemplateDelete;
  final VoidCallback? onTemplateCreate;

  const TaskTemplateBottomSheet({
    super.key,
    required this.dataService,
    this.onTemplateSelected,
    this.onTemplateEdit,
    this.onTemplateDelete,
    this.onTemplateCreate,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: dataService,
      builder: (context, child) {
        final templates = dataService.taskTemplates;
        final double maxSheetHeight = MediaQuery.of(context).size.height * 0.52;

        return ConstrainedBox(
          constraints: BoxConstraints(maxHeight: maxSheetHeight),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: Color(0xFF2B2B2B),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                BottomSheetHeader(
                  icon: Icons.checklist,
                  title: 'テンプレートから選択',
                  onClose: () => Navigator.pop(context),
                ),
                const SizedBox(height: 16),

                // テンプレートリスト
                if (templates.isEmpty)
                  EmptyTemplateState(
                    icon: Icons.checklist_outlined,
                    title: 'テンプレートがありません',
                    description: 'メニューバーの作成ボタンを長押ししてテンプレートを作成できます',
                  )
                else
                  Builder(
                    builder: (context) {
                      final double maxHeight = maxSheetHeight;
                      // ヘッダー、パディング、ボタン、マージンなどの固定要素の高さを推定
                      const double fixedElementsHeight =
                          24 * 2 +
                          60 +
                          16 +
                          4 +
                          56; // padding + header + spacing + button spacing
                      final double availableHeightForList =
                          maxHeight - fixedElementsHeight;

                      return ConstrainedBox(
                        constraints: BoxConstraints(
                          maxHeight: availableHeightForList,
                        ),
                        child: ListView.builder(
                          shrinkWrap: true,
                          padding: const EdgeInsets.only(top: 2, bottom: 12),
                          physics: const ClampingScrollPhysics(),
                          itemCount: templates.length,
                          itemBuilder: (context, index) {
                            final template = templates[index];
                            final isLast = index == templates.length - 1;
                            return _TaskTemplateCard(
                              template: template,
                              isLast: isLast,
                              onTap:
                                  onTemplateSelected != null
                                      ? () {
                                        Navigator.pop(context);
                                        onTemplateSelected!(template);
                                      }
                                      : null,
                              onEdit:
                                  onTemplateEdit != null
                                      ? () {
                                        Navigator.pop(context); // ボトムシートを閉じる
                                        Navigator.pop(
                                          context,
                                        ); // タスク作成ダイアログも閉じる
                                        onTemplateEdit!(
                                          template,
                                        ); // テンプレート編集ダイアログを表示
                                      }
                                      : null,
                              onDelete:
                                  onTemplateDelete != null
                                      ? () => onTemplateDelete!(template)
                                      : null,
                            );
                          },
                        ),
                      );
                    },
                  ),
                if (onTemplateCreate != null) ...[
                  const SizedBox(height: 4),
                  TemplateCreateButton(
                    label: '新しいテンプレートを作成',
                    onPressed: onTemplateCreate!,
                    closeBottomSheet: true,
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

class _TaskTemplateCard extends StatelessWidget {
  final TaskTemplate template;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool isLast;

  const _TaskTemplateCard({
    required this.template,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.isLast = false,
  });

  Color _getPriorityColor() {
    switch (template.priority) {
      case TaskPriority.low:
        return const Color(0xFF4CAF50); // Green
      case TaskPriority.medium:
        return const Color(0xFFFF9800); // Orange
      case TaskPriority.high:
        return const Color(0xFFF44336); // Red
    }
  }

  Color _getDueDateColor() {
    if (template.dueDate == null) return Colors.grey[600]!;
    // テンプレートの期限日は常にグレーで表示
    return Colors.grey[500]!;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: isLast ? 0 : 12),
      decoration: BoxDecoration(
        color: const Color(0xFF3A3A3A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[700]!),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 優先度インジケーター
            Container(
              width: 4,
              height: 48,
              decoration: BoxDecoration(
                color: _getPriorityColor(),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 12),

            // メインコンテンツ（チェックボックスは除外）
            Expanded(
              child: GestureDetector(
                onTap: onTap,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // タイトル
                    Text(
                      template.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 6),

                    // 期限日表示
                    Row(
                      children: [
                        Icon(
                          Icons.schedule,
                          size: 14,
                          color: _getDueDateColor(),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          template.dueDate != null
                              ? template.dueDateDisplayString
                              : '期限なし',
                          style: TextStyle(
                            color: _getDueDateColor(),
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),

                    // 説明（あれば）
                    if (template.description != null &&
                        template.description!.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        template.description!,
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 12,
                          height: 1.4,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // 編集ボタンと削除ボタン
            Row(
              children: [
                // 編集ボタン
                if (onEdit != null)
                  GestureDetector(
                    onTap: onEdit,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.blue[400]!.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.edit_outlined,
                        color: Colors.blue[400],
                        size: 20,
                      ),
                    ),
                  ),
                if (onEdit != null && onDelete != null)
                  const SizedBox(width: 8),
                // 削除ボタン
                if (onDelete != null)
                  GestureDetector(
                    onTap: onDelete,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.red[400]!.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.delete_outline,
                        color: Colors.red[400],
                        size: 20,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

