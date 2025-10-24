import 'package:flutter/material.dart';
import '../../models/task.dart';
import '../../utils/color_utils.dart';

/// 展開可能なタスクカードウィジェット
class TaskCard extends StatefulWidget {
  final Task task;
  final VoidCallback onToggleComplete;
  final VoidCallback onDelete;

  const TaskCard({
    super.key,
    required this.task,
    required this.onToggleComplete,
    required this.onDelete,
  });

  @override
  State<TaskCard> createState() => _TaskCardState();
}

class _TaskCardState extends State<TaskCard>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late AnimationController _animationController;
  late Animation<double> _expandAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  Color _getDueDateColor() {
    if (widget.task.dueDate == null) return Colors.grey[600]!;
    if (widget.task.isOverdue) return const Color(0xFFF44336); // Red
    if (widget.task.isDueToday) return const Color(0xFFFF9800); // Orange
    if (widget.task.isDueTomorrow) return const Color(0xFFFFC107); // Amber
    return Colors.grey[500]!;
  }

  Color _getPriorityColor() {
    return ColorUtils.getColorFromHex(widget.task.priorityColorHex);
  }

  @override
  Widget build(BuildContext context) {
    final bool hasDescription =
        widget.task.description != null &&
        widget.task.description!.trim().isNotEmpty;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF3A3A3A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color:
              widget.task.isCompleted
                  ? const Color(0xFFE85A3B).withValues(alpha: 0.3)
                  : Colors.grey[700]!,
        ),
      ),
      child: Column(
        children: [
          // メインカード部分
          InkWell(
            onTap: hasDescription ? _toggleExpanded : null,
            borderRadius: BorderRadius.circular(12),
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
                    onTap: widget.onToggleComplete,
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color:
                              widget.task.isCompleted
                                  ? const Color(0xFFE85A3B)
                                  : Colors.grey[500]!,
                          width: 2,
                        ),
                        color:
                            widget.task.isCompleted
                                ? const Color(0xFFE85A3B)
                                : Colors.transparent,
                      ),
                      child:
                          widget.task.isCompleted
                              ? const Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 16,
                              )
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
                          widget.task.title,
                          style: TextStyle(
                            color:
                                widget.task.isCompleted
                                    ? Colors.grey[500]
                                    : Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            decoration:
                                widget.task.isCompleted
                                    ? TextDecoration.lineThrough
                                    : null,
                          ),
                        ),
                        if (widget.task.dueDate != null) ...[
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
                                widget.task.dueDateDisplayString,
                                style: TextStyle(
                                  color: _getDueDateColor(),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              if (widget.task.isOverdue) ...[
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

                  // 展開アイコン（メモがある場合のみ）
                  if (hasDescription)
                    RotationTransition(
                      turns: Tween(
                        begin: 0.0,
                        end: 0.5,
                      ).animate(_expandAnimation),
                      child: Icon(
                        Icons.keyboard_arrow_down,
                        color: Colors.grey[500],
                      ),
                    ),
                ],
              ),
            ),
          ),

          // 展開部分（メモと削除ボタン）
          SizeTransition(
            sizeFactor: _expandAnimation,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.only(left: 28, right: 16, bottom: 12),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: Colors.grey[700]!, width: 1),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),
                  // メモセクション
                  if (hasDescription) ...[
                    Row(
                      children: [
                        Icon(Icons.notes, size: 16, color: Colors.grey[500]),
                        const SizedBox(width: 6),
                        Text(
                          'メモ',
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2B2B2B),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        widget.task.description!,
                        style: TextStyle(
                          color: Colors.grey[300],
                          fontSize: 14,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),

                  // 削除ボタン
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: widget.onDelete,
                      icon: const Icon(Icons.delete_outline, size: 18),
                      label: const Text('削除'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red[400],
                        side: BorderSide(color: Colors.red[400]!),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
