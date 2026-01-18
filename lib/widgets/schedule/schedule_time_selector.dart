import 'package:flutter/material.dart';

class ScheduleTimeSelector extends StatelessWidget {
  final bool isAllDay;
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final ValueChanged<bool> onAllDayChanged;
  final VoidCallback onStartTimeSelected;
  final VoidCallback onEndTimeSelected;

  const ScheduleTimeSelector({
    super.key,
    required this.isAllDay,
    required this.startTime,
    required this.endTime,
    required this.onAllDayChanged,
    required this.onStartTimeSelected,
    required this.onEndTimeSelected,
  });

  String _formatTime(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  Widget _buildTimePickerButton({
    required String label,
    required TimeOfDay time,
    required VoidCallback onTap,
    required bool isEnabled,
  }) {
    return GestureDetector(
      onTap: isEnabled ? onTap : null,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF3A3A3A),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isEnabled ? Colors.grey[600]! : Colors.grey[800]!,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                color: isEnabled ? Colors.grey[400] : Colors.grey[600],
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _formatTime(time),
              style: TextStyle(
                color: isEnabled ? Colors.white : Colors.grey[600],
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 終日チェックボックス
        Row(
          children: [
            Checkbox(
              value: isAllDay,
              onChanged: (value) => onAllDayChanged(value ?? false),
              activeColor: const Color(0xFFE85A3B),
            ),
            const Text(
              '終日',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // 時間設定セクション（開始/終了を横並び）
        Row(
          children: [
            Expanded(
              child: _buildTimePickerButton(
                label: '開始時間',
                time: startTime,
                onTap: onStartTimeSelected,
                isEnabled: !isAllDay,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildTimePickerButton(
                label: '終了時間',
                time: endTime,
                onTap: onEndTimeSelected,
                isEnabled: !isAllDay,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
