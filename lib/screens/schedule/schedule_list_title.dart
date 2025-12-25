import 'package:flutter/material.dart';

class ScheduleListTitle extends StatelessWidget {
  final DateTime selectedDate;

  const ScheduleListTitle({super.key, required this.selectedDate});

  @override
  Widget build(BuildContext context) {
    return Text(
      '${selectedDate.year}年${selectedDate.month}月${selectedDate.day}日のスケジュール',
      style: const TextStyle(
        color: Colors.white,
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
