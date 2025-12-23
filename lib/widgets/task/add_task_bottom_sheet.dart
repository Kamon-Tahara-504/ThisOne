import 'package:flutter/material.dart';
import '../../gradients.dart';
import '../../models/task.dart';
import '../../utils/error_handler.dart';
import 'due_date_picker_bottom_sheet.dart';

class AddTaskBottomSheet extends StatefulWidget {
  final Function(Map<String, dynamic>) onAdd;

  const AddTaskBottomSheet({super.key, required this.onAdd});

  @override
  State<AddTaskBottomSheet> createState() => _AddTaskBottomSheetState();
}

class _AddTaskBottomSheetState extends State<AddTaskBottomSheet> {
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

  void _selectDueDate() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder:
          (context) => DueDatePickerBottomSheet(
            initialDate: _selectedDueDate,
            onDateChanged: (newDate) {
              setState(() {
                _selectedDueDate = newDate;
              });
            },
          ),
    );
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

  Widget _buildPriorityOption(TaskPriority priority) {
    final isSelected = _selectedPriority == priority;

    return GestureDetector(
      onTap: () => setState(() => _selectedPriority = priority),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? const Color(0xFFE85A3B).withValues(alpha: 0.2)
                  : const Color(0xFF2B2B2B),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? const Color(0xFFE85A3B) : Colors.grey[700]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color:
                    priority == TaskPriority.high
                        ? const Color(0xFFF44336)
                        : priority == TaskPriority.medium
                        ? const Color(0xFFFF9800)
                        : const Color(0xFF4CAF50),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              priority.displayName,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey[400],
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDueDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final selectedDay = DateTime(date.year, date.month, date.day);

    final dateString =
        selectedDay == today
            ? '今日'
            : selectedDay == tomorrow
            ? '明日'
            : '${date.year}/${date.month}/${date.day}';

    // 時間を追加
    final timeString =
        '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';

    return '$dateString $timeString';
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
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    ShaderMask(
                      shaderCallback:
                          (bounds) =>
                              createOrangeYellowGradient().createShader(bounds),
                      child: const Icon(
                        Icons.task_alt,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'タスク作成',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close, color: Colors.white),
                    ),
                  ],
                ),
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
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'タイトル',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFF3A3A3A),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey[600]!),
                              ),
                              child: TextField(
                                controller: _titleController,
                                focusNode: _titleFocusNode,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                                decoration: const InputDecoration(
                                  hintText: 'タスクのタイトルを入力...',
                                  hintStyle: TextStyle(color: Colors.grey),
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.all(16),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // 期限選択
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '期限',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            InkWell(
                              onTap: _selectDueDate,
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF3A3A3A),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.grey[600]!),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.calendar_today,
                                      color:
                                          _selectedDueDate != null
                                              ? const Color(0xFFE85A3B)
                                              : Colors.grey[500],
                                      size: 20,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        _selectedDueDate != null
                                            ? _formatDueDate(_selectedDueDate!)
                                            : '期限を設定（任意）',
                                        style: TextStyle(
                                          color:
                                              _selectedDueDate != null
                                                  ? Colors.white
                                                  : Colors.grey[500],
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                    if (_selectedDueDate != null)
                                      GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            _selectedDueDate = null;
                                          });
                                        },
                                        child: Icon(
                                          Icons.close,
                                          color: Colors.grey[500],
                                          size: 20,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // 優先度選択
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '優先度',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildPriorityOption(TaskPriority.low),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: _buildPriorityOption(
                                    TaskPriority.medium,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: _buildPriorityOption(
                                    TaskPriority.high,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // 作成ボタン
                        Container(
                          width: double.infinity,
                          height: 56,
                          decoration: BoxDecoration(
                            gradient: createHorizontalOrangeYellowGradient(),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ElevatedButton(
                            onPressed: _addTask,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'タスクを作成',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
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
    );
  }
}
