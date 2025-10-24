import 'package:flutter/material.dart';
import '../../models/task.dart';

/// シンプルなタスクカードウィジェット
class TaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback onToggleComplete;
  final VoidCallback onDelete;

  const TaskCard({
    super.key,
    required this.task,
    required this.onToggleComplete,
    required this.onDelete,
  });

  Color _getDueDateColor() {
    if (task.dueDate == null) return Colors.grey[600]!;
    if (task.isOverdue) return const Color(0xFFF44336); // Red
    if (task.isDueToday) return const Color(0xFFFF9800); // Orange
    if (task.isDueTomorrow) return const Color(0xFFFFC107); // Amber
    return Colors.grey[500]!;
  }

  Color _getPriorityColor() {
    switch (task.priority) {
      case TaskPriority.low:
        return const Color(0xFF4CAF50); // Green
      case TaskPriority.medium:
        return const Color(0xFFFF9800); // Orange
      case TaskPriority.high:
        return const Color(0xFFF44336); // Red
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF3A3A3A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color:
              task.isCompleted
                  ? const Color(0xFFE85A3B).withValues(alpha: 0.3)
                  : Colors.grey[700]!,
        ),
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

            // チェックボックス
            GestureDetector(
              onTap: onToggleComplete,
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color:
                        task.isCompleted
                            ? const Color(0xFFE85A3B)
                            : Colors.grey[500]!,
                    width: 2,
                  ),
                  color:
                      task.isCompleted
                          ? const Color(0xFFE85A3B)
                          : Colors.transparent,
                ),
                child:
                    task.isCompleted
                        ? const Icon(Icons.check, color: Colors.white, size: 16)
                        : null,
              ),
            ),
            const SizedBox(width: 12),

            // タイトルと期限
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.title,
                    style: TextStyle(
                      color: task.isCompleted ? Colors.grey[500] : Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      decoration:
                          task.isCompleted ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  if (task.dueDate != null) ...[
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
                          Icons.schedule,
                          size: 14,
                          color: _getDueDateColor(),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          task.dueDateDisplayString,
                          style: TextStyle(
                            color: _getDueDateColor(),
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (task.isOverdue) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(
                                0xFFF44336,
                              ).withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              '期限切れ',
                              style: TextStyle(
                                color: Color(0xFFF44336),
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ],
              ),
            ),

            // 削除ボタン
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
      ),
    );
  }
}
