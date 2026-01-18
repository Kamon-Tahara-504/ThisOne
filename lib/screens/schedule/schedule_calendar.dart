import 'package:flutter/material.dart';
import 'package:holiday_jp/holiday_jp.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../gradients.dart';
import '../../models/schedule.dart';

class ScheduleCalendar extends StatelessWidget {
  final DateTime focusedDate;
  final DateTime selectedDate;
  final CalendarFormat calendarFormat;
  final List<Schedule> Function(DateTime) getSchedulesForDate;
  final void Function(DateTime selectedDay, DateTime focusedDay) onDaySelected;
  final ValueChanged<CalendarFormat> onFormatChanged;
  final ValueChanged<DateTime> onPageChanged;

  const ScheduleCalendar({
    super.key,
    required this.focusedDate,
    required this.selectedDate,
    required this.calendarFormat,
    required this.getSchedulesForDate,
    required this.onDaySelected,
    required this.onFormatChanged,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TableCalendar<Map<String, dynamic>>(
      firstDay: DateTime.utc(2020, 1, 1),
      lastDay: DateTime.utc(2030, 12, 31),
      focusedDay: focusedDate,
      selectedDayPredicate: (day) => isSameDay(selectedDate, day),
      calendarFormat: calendarFormat,
      availableCalendarFormats: const {
        CalendarFormat.month: 'Month',
        CalendarFormat.week: 'Week',
      },
      eventLoader:
          (date) => getSchedulesForDate(date).map((s) => s.toMap()).toList(),
      startingDayOfWeek: StartingDayOfWeek.monday,
      headerVisible: false,
      calendarStyle: CalendarStyle(
        outsideDaysVisible: true,
        weekendTextStyle: const TextStyle(color: Colors.white),
        defaultTextStyle: const TextStyle(color: Colors.white),
        // 前月・次月の日付スタイル（薄いグレー）
        outsideTextStyle: TextStyle(color: Colors.grey[600], fontSize: 16),
        // 過去の日付も白色で表示（期限切れでも色を変えない）
        todayTextStyle: const TextStyle(color: Colors.white),
        selectedTextStyle: const TextStyle(color: Colors.white),
        selectedDecoration: const BoxDecoration(
          color: Colors.transparent,
          shape: BoxShape.circle,
        ),
        todayDecoration: BoxDecoration(
          gradient: createOrangeYellowGradient(),
          shape: BoxShape.circle,
        ),
        markerDecoration: const BoxDecoration(color: Colors.transparent),
        markersMaxCount: 1,
        markerSize: 0,
      ),
      calendarBuilders: CalendarBuilders(
        // 曜日ビルダー（日〜土）
        dowBuilder: (context, day) {
          final weekdays = ['月', '火', '水', '木', '金', '土', '日'];
          // 土曜日は青色、日曜日は赤色
          Color textColor;
          if (day.weekday == 6) {
            textColor = Colors.blue; // 土曜日
          } else if (day.weekday == 7) {
            textColor = Colors.red; // 日曜日
          } else {
            textColor = Colors.white; // 平日
          }
          return Center(
            child: Text(
              weekdays[day.weekday - 1],
              style: TextStyle(color: textColor, fontWeight: FontWeight.w500),
            ),
          );
        },

        // 通常の日付ビルダー（祝日＝赤、土曜＝青、日曜＝赤、平日＝白）
        defaultBuilder: (context, day, focusedDay) {
          Color textColor;
          if (isHoliday(day)) {
            textColor = Colors.red; // 日本の祝日
          } else if (day.weekday == 6) {
            textColor = Colors.blue; // 土曜日
          } else if (day.weekday == 7) {
            textColor = Colors.red; // 日曜日
          } else {
            textColor = Colors.white; // 平日
          }
          return Center(
            child: Text(day.day.toString(), style: TextStyle(color: textColor)),
          );
        },

        // 今日の日付ビルダー（祝日なら文字を赤に）
        todayBuilder: (context, day, focusedDay) {
          return Container(
            margin: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              gradient: createOrangeYellowGradient(),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                day.day.toString(),
                style: TextStyle(
                  color: isHoliday(day) ? Colors.red : Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          );
        },

        // 前月・次月の日付ビルダー（祝日＝赤・薄、土/日/平日も薄く）
        outsideBuilder: (context, day, focusedDay) {
          Color textColor;
          if (isHoliday(day)) {
            textColor = Colors.red.withValues(alpha: 0.6); // 祝日
          } else if (day.weekday == 6) {
            textColor = Colors.blue.withValues(alpha: 0.4); // 土曜日
          } else if (day.weekday == 7) {
            textColor = Colors.red.withValues(alpha: 0.4); // 日曜日
          } else {
            textColor = Colors.grey[600]!; // 平日
          }
          return Center(
            child: Text(day.day.toString(), style: TextStyle(color: textColor)),
          );
        },

        selectedBuilder: (context, day, focusedDay) {
          final isToday = isSameDay(day, DateTime.now());
          final holidayColor = isHoliday(day) ? Colors.red : Colors.white;

          return Container(
            margin: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              gradient: createOrangeYellowGradient(),
              shape: BoxShape.circle,
            ),
            child: Container(
              margin: const EdgeInsets.all(2),
              decoration: const BoxDecoration(
                color: Color(0xFF3A3A3A), // 背景色に合わせる
                shape: BoxShape.circle,
              ),
              child:
                  isToday
                      ? Container(
                        margin: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          gradient: createOrangeYellowGradient(),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            day.day.toString(),
                            style: TextStyle(
                              color: holidayColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      )
                      : Center(
                        child: Text(
                          day.day.toString(),
                          style: TextStyle(
                            color: holidayColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
            ),
          );
        },
        markerBuilder: (context, day, events) {
          final eventCount = events.length;
          if (eventCount > 0) {
            return Positioned(
              right: 1,
              bottom: 1,
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                ),
                width: 18,
                height: 18,
                child: Center(
                  child: Text(
                    eventCount > 99 ? '99+' : eventCount.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            );
          }
          return null;
        },
      ),
      onDaySelected: onDaySelected,
      onFormatChanged: onFormatChanged,
      onPageChanged: onPageChanged,
    );
  }
}
