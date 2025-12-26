import 'package:flutter/material.dart';
import '../../models/task.dart';
import '../../utils/error_handler.dart';
import 'task_form_header.dart';
import 'task_title_input.dart';
import 'task_due_date_selector.dart';
import 'task_priority_selector.dart';
import 'task_form_submit_button.dart';

class TaskDialog extends StatefulWidget {
  final Function(Map<String, dynamic>)? onAdd;
  final Task? task;
  final Function(Map<String, dynamic>)? onUpdate;

  const TaskDialog({super.key, this.onAdd, this.task, this.onUpdate});

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
    // 編集モードの場合、既存タスクの値を初期値として設定
    if (widget.task != null) {
      final task = widget.task!;
      _titleController.text = task.title;
      _selectedPriority = task.priority;
      _selectedDueDate = task.dueDate;
    }
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

  void _saveTask() {
    if (_titleController.text.trim().isNotEmpty) {
      final taskData = {
        'title': _titleController.text.trim(),
        'priority': _selectedPriority,
        'dueDate': _selectedDueDate,
      };

      if (widget.task == null) {
        // 作成モード
        widget.onAdd?.call(taskData);
        // Navigator.popはonAddコールバック内で呼ばれるため、ここでは呼ばない
      } else {
        // 編集モード
        widget.onUpdate?.call(taskData);
        // Navigator.popはonUpdateコールバック内で呼ばれるため、ここでは呼ばない
      }
    } else {
      AppErrorHandler.handleError(
        context,
        'タイトルを入力してください',
        operation: widget.task == null ? 'タスク追加' : 'タスク更新',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final maxWidth = screenSize.width * 0.9;
    final maxHeight = screenSize.height * 0.85;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.zero,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth, maxHeight: maxHeight),
        child: SizedBox(
          width: maxWidth,
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF2B2B2B),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ヘッダー
                TaskFormHeader(
                  onClose: () => Navigator.pop(context),
                  isEditMode: widget.task != null,
                ),

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

                          // 作成/更新ボタン
                          TaskFormSubmitButton(
                            onPressed: _saveTask,
                            label: widget.task != null ? 'タスクを更新' : 'タスクを作成',
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
