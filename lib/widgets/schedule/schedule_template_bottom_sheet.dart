import 'package:flutter/material.dart';
import '../../models/schedule_template.dart';
import '../../services/main_data_service.dart';
import '../common/bottom_sheet_header.dart';
import '../template/empty_template_state.dart';
import '../template/template_create_button.dart';

class ScheduleTemplateBottomSheet extends StatelessWidget {
  final MainDataService dataService;
  final Function(ScheduleTemplate)? onTemplateSelected;
  final Function(ScheduleTemplate)? onTemplateEdit;
  final Function(ScheduleTemplate)? onTemplateDelete;
  final VoidCallback? onTemplateCreate;

  const ScheduleTemplateBottomSheet({
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
        final templates = dataService.templates;
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
                  icon: Icons.description,
                  title: 'テンプレートから選択',
                  onClose: () => Navigator.pop(context),
                ),
                const SizedBox(height: 16),

                // テンプレートリスト
                if (templates.isEmpty)
                  EmptyTemplateState(
                    icon: Icons.description_outlined,
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
                            return _TemplateCard(
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
                                        ); // スケジュール作成ダイアログも閉じる
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

class _TemplateCard extends StatelessWidget {
  final ScheduleTemplate template;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool isLast;

  const _TemplateCard({
    required this.template,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.isLast = false,
  });

  Color _getTemplateColor(String colorHex) {
    try {
      return Color(int.parse(colorHex.substring(1), radix: 16) + 0xFF000000);
    } catch (e) {
      return const Color(0xFFE85A3B);
    }
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
      child: IntrinsicHeight(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 色インジケーター
              Container(
                width: 4,
                height: double.infinity,
                decoration: BoxDecoration(
                  color: _getTemplateColor(template.colorHex),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),

              // メインコンテンツ
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

                      // 時間表示
                      Row(
                        children: [
                          Icon(
                            Icons.schedule,
                            size: 14,
                            color: Colors.grey[500],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            template.timeDisplayString,
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),

                      // 場所（あれば）
                      if (template.location != null &&
                          template.location!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.location_on,
                              size: 12,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                template.location!,
                                style: TextStyle(
                                  color: Colors.grey[400],
                                  fontSize: 12,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],

                      // 説明（あれば）
                      if (template.description != null &&
                          template.description!.isNotEmpty) ...[
                        const SizedBox(height: 4),
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

              // 編集・削除ボタン
              if (onEdit != null || onDelete != null)
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
      ),
    );
  }
}
