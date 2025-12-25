import 'package:flutter/material.dart';
import '../../gradients.dart';

class ScheduleFormHeader extends StatelessWidget {
  final DateTime selectedDate;
  final VoidCallback onClose;
  final bool isEditMode;

  const ScheduleFormHeader({
    super.key,
    required this.selectedDate,
    required this.onClose,
    this.isEditMode = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          ShaderMask(
            shaderCallback:
                (bounds) => createOrangeYellowGradient().createShader(bounds),
            child: const Icon(Icons.event_note, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isEditMode ? 'スケジュール編集' : 'スケジュール作成',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${selectedDate.year}年${selectedDate.month}月${selectedDate.day}日',
                  style: TextStyle(color: Colors.grey[400], fontSize: 14),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onClose,
            icon: const Icon(Icons.close, color: Colors.white),
          ),
        ],
      ),
    );
  }
}
