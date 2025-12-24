import 'package:flutter/material.dart';
import '../common/due_date_picker_bottom_sheet.dart';

class TaskDueDateSelector extends StatelessWidget {
  final DateTime? selectedDueDate;
  final ValueChanged<DateTime> onDateChanged;
  final VoidCallback onDateCleared;

  const TaskDueDateSelector({
    super.key,
    required this.selectedDueDate,
    required this.onDateChanged,
    required this.onDateCleared,
  });

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

  void _selectDueDate(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder:
          (context) => DueDatePickerBottomSheet(
            initialDate: selectedDueDate,
            onDateChanged: onDateChanged,
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
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
          onTap: () => _selectDueDate(context),
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
                      selectedDueDate != null
                          ? const Color(0xFFE85A3B)
                          : Colors.grey[500],
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    selectedDueDate != null
                        ? _formatDueDate(selectedDueDate!)
                        : '期限を設定（任意）',
                    style: TextStyle(
                      color:
                          selectedDueDate != null
                              ? Colors.white
                              : Colors.grey[500],
                      fontSize: 16,
                    ),
                  ),
                ),
                if (selectedDueDate != null)
                  GestureDetector(
                    onTap: onDateCleared,
                    child: Icon(Icons.close, color: Colors.grey[500], size: 20),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
