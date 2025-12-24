import 'package:flutter/material.dart';
import '../../models/task.dart';

class TaskPrioritySelector extends StatelessWidget {
  final TaskPriority selectedPriority;
  final ValueChanged<TaskPriority> onPriorityChanged;

  const TaskPrioritySelector({
    super.key,
    required this.selectedPriority,
    required this.onPriorityChanged,
  });

  Widget _buildPriorityOption(TaskPriority priority) {
    final isSelected = selectedPriority == priority;

    return GestureDetector(
      onTap: () => onPriorityChanged(priority),
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

  @override
  Widget build(BuildContext context) {
    return Column(
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
            Expanded(child: _buildPriorityOption(TaskPriority.low)),
            const SizedBox(width: 8),
            Expanded(child: _buildPriorityOption(TaskPriority.medium)),
            const SizedBox(width: 8),
            Expanded(child: _buildPriorityOption(TaskPriority.high)),
          ],
        ),
      ],
    );
  }
}
