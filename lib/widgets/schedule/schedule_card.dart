import 'package:flutter/material.dart';
import '../../models/schedule.dart';

/// シンプルなスケジュールカードウィジェット
class ScheduleCard extends StatelessWidget {
  final Schedule schedule;
  final VoidCallback onDelete;
  final VoidCallback? onEdit;
  final bool isAnimating;
  final Animation<double>? popAnimation;

  const ScheduleCard({
    super.key,
    required this.schedule,
    required this.onDelete,
    this.onEdit,
    this.isAnimating = false,
    this.popAnimation,
  });

  Color _getScheduleColor() {
    final colorHex = schedule.colorHex;
    return Color(int.parse(colorHex.substring(1), radix: 16) + 0xFF000000);
  }

  @override
  Widget build(BuildContext context) {
    Widget scheduleCard = Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF3A3A3A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[700]!),
        // アニメーション中は特別な装飾を追加
        boxShadow:
            isAnimating
                ? [
                  BoxShadow(
                    color: Colors.white.withValues(alpha: 0.6),
                    blurRadius: 20,
                    offset: const Offset(0, 5),
                  ),
                ]
                : null,
      ),
      child: IntrinsicHeight(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 色インジケーター（カードの高さに合わせて動的調整）
              Container(
                width: 4,
                height: double.infinity,
                decoration: BoxDecoration(
                  color: _getScheduleColor(),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),

              // メインコンテンツ
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // タイトル
                    Text(
                      schedule.title,
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
                        Icon(Icons.schedule, size: 14, color: Colors.grey[500]),
                        const SizedBox(width: 4),
                        Text(
                          schedule.timeDisplayString,
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),

                    // 場所（あれば）
                    if (schedule.location != null &&
                        schedule.location!.isNotEmpty) ...[
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
                              schedule.location!,
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

                    // 説明文（あれば）
                    if (schedule.description != null &&
                        schedule.description!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        schedule.description!,
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

              // 編集ボタンと削除ボタン
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
                  if (onEdit != null) const SizedBox(width: 8),
                  // 削除ボタン（タスクカードと同じスタイル）
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

    // アニメーション中の場合は、スケールとバウンス効果を適用
    if (isAnimating && popAnimation != null) {
      return Material(
        color: Colors.transparent,
        child: AnimatedBuilder(
          animation: popAnimation!,
          builder: (context, child) {
            return Transform.scale(
              scale: 0.8 + (popAnimation!.value * 0.2),
              child: Transform.translate(
                offset: Offset(0, -10 * (1 - popAnimation!.value)),
                child: child,
              ),
            );
          },
          child: scheduleCard,
        ),
      );
    }

    // 通常状態
    return Material(color: Colors.transparent, child: scheduleCard);
  }
}
