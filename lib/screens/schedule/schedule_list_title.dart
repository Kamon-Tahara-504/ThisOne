import 'package:flutter/material.dart';
import 'package:holiday_jp/holiday_jp.dart';

import '../../gradients.dart';

class ScheduleListTitle extends StatelessWidget {
  final DateTime selectedDate;

  const ScheduleListTitle({super.key, required this.selectedDate});

  @override
  Widget build(BuildContext context) {
    final holiday = getHoliday(selectedDate);

    return SizedBox(
      height: 20, // 固定の高さを設定（fontSize 16 + 少し余裕）
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            '${selectedDate.year}年 ${selectedDate.month}月${selectedDate.day}日 | スケジュール',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
              height: 1.0, // 行の高さを固定して位置を安定させる
            ),
          ),
          if (holiday != null)
            Padding(
              padding: const EdgeInsets.only(left: 6),
              child: _HolidayBadge(name: holiday.name),
            ),
        ],
      ),
    );
  }
}

/// 祝日表示用のグラデーションバッジ
class _HolidayBadge extends StatelessWidget {
  final String name;

  const _HolidayBadge({required this.name});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      decoration: BoxDecoration(
        gradient: createColorGradient(
          '赤',
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.red.withValues(alpha: 0.45),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.2,
              height: 1.2, // 行の高さを調整
            ),
          ),
          const SizedBox(width: 5),
          Icon(
            Icons.celebration_rounded,
            size: 14,
            color: Colors.white.withValues(alpha: 0.95),
          ),
        ],
      ),
    );
  }
}
