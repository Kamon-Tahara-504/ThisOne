import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../gradients.dart';

class ScheduleCalendarHeader extends StatelessWidget {
  final DateTime focusedDate;
  final CalendarFormat calendarFormat;
  final ValueChanged<DateTime> onPreviousMonth;
  final ValueChanged<DateTime> onNextMonth;
  final VoidCallback onToggleFormat;

  const ScheduleCalendarHeader({
    super.key,
    required this.focusedDate,
    required this.calendarFormat,
    required this.onPreviousMonth,
    required this.onNextMonth,
    required this.onToggleFormat,
  });

  String _getCalendarFormatText() {
    switch (calendarFormat) {
      case CalendarFormat.month:
        return 'Month';
      case CalendarFormat.twoWeeks:
        return '2 Weeks';
      case CalendarFormat.week:
        return 'Week';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          // 左矢印
          IconButton(
            onPressed: () {
              DateTime newDate;
              if (calendarFormat == CalendarFormat.week) {
                newDate = focusedDate.subtract(const Duration(days: 7));
              } else {
                newDate = DateTime(focusedDate.year, focusedDate.month - 1);
              }
              onPreviousMonth(newDate);
            },
            icon: const Icon(Icons.chevron_left, color: Colors.white),
            iconSize: 24,
            splashRadius: 20,
          ),

          // 中央に配置するためのSpacer
          const Spacer(),

          // 年月表示
          Text(
            '${focusedDate.year}年${focusedDate.month}月',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(width: 12),

          // 表示形式切り替えボタン
          GestureDetector(
            onTap: onToggleFormat,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                gradient: createHorizontalOrangeYellowGradient(),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 3,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Text(
                _getCalendarFormatText(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),

          // 中央に配置するためのSpacer
          const Spacer(),

          // 右矢印
          IconButton(
            onPressed: () {
              DateTime newDate;
              if (calendarFormat == CalendarFormat.week) {
                newDate = focusedDate.add(const Duration(days: 7));
              } else {
                newDate = DateTime(focusedDate.year, focusedDate.month + 1);
              }
              onNextMonth(newDate);
            },
            icon: const Icon(Icons.chevron_right, color: Colors.white),
            iconSize: 24,
            splashRadius: 20,
          ),
        ],
      ),
    );
  }
}
