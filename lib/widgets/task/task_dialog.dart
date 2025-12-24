import 'package:flutter/material.dart';
import '../../models/task.dart';
import '../../utils/error_handler.dart';
import 'task_form_header.dart';
import 'task_title_input.dart';
import 'task_due_date_selector.dart';
import 'task_priority_selector.dart';
import 'task_form_submit_button.dart';

class TaskDialog extends StatefulWidget {
  final Function(Map<String, dynamic>) onAdd;

  const TaskDialog({super.key, required this.onAdd});

  @override
  State<TaskDialog> createState() => _TaskDialogState();
}

class _TaskDialogState extends State<TaskDialog> {
  final _titleController = TextEditingController();
  final _titleFocusNode = FocusNode();
  TaskPriority _selectedPriority = TaskPriority.low;
  DateTime? _selectedDueDate;

  @override
  void initState() {
    super.initState();
    // フォーカスリスナーを追加（UI更新のため）
    _titleFocusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    // フォーカス変更時にUIを更新
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _titleFocusNode.removeListener(_onFocusChange);
    _titleFocusNode.dispose();
    super.dispose();
  }

  void _addTask() {
    if (_titleController.text.trim().isNotEmpty) {
      widget.onAdd({
        'title': _titleController.text.trim(),
        'priority': _selectedPriority,
        'dueDate': _selectedDueDate,
      });
      // Navigator.popはonAddコールバック内で呼ばれるため、ここでは呼ばない
    } else {
      AppErrorHandler.handleError(context, 'タイトルを入力してください', operation: 'タスク追加');
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final maxWidth = screenSize.width * 0.9;
    final maxHeight = screenSize.height * 0.85;

    return Dialog(
      backgroundColor: Colors.transparent,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth, maxHeight: maxHeight),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF2B2B2B),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ヘッダー
              TaskFormHeader(onClose: () => Navigator.pop(context)),

              // メインコンテンツ
              Flexible(
                child: GestureDetector(
                  onTap: () {
                    // 入力欄以外をタップした時にキーボードを格納
                    FocusScope.of(context).unfocus();
                  },
                  behavior: HitTestBehavior.opaque,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // タイトル入力
                        TaskTitleInput(
                          titleController: _titleController,
                          titleFocusNode: _titleFocusNode,
                        ),
                        const SizedBox(height: 16),

                        // 期限選択
                        TaskDueDateSelector(
                          selectedDueDate: _selectedDueDate,
                          onDateChanged: (newDate) {
                            setState(() {
                              _selectedDueDate = newDate;
                            });
                          },
                          onDateCleared: () {
                            setState(() {
                              _selectedDueDate = null;
                            });
                          },
                        ),
                        const SizedBox(height: 16),

                        // 優先度選択
                        TaskPrioritySelector(
                          selectedPriority: _selectedPriority,
                          onPriorityChanged: (priority) {
                            setState(() {
                              _selectedPriority = priority;
                            });
                          },
                        ),
                        const SizedBox(height: 24),

                        // 作成ボタン
                        TaskFormSubmitButton(onPressed: _addTask),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
