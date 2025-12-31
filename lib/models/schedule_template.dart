import 'package:flutter/material.dart';
import 'dart:convert';

/// 型安全なスケジュールテンプレートモデルクラス
class ScheduleTemplate {
  final String id;
  final String userId;
  final String title;
  final String? description;
  final TimeOfDay startTime;
  final TimeOfDay? endTime;
  final bool isAllDay;
  final String? location;
  final int reminderMinutes;
  final String colorHex;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ScheduleTemplate({
    required this.id,
    required this.userId,
    required this.title,
    this.description,
    required this.startTime,
    this.endTime,
    required this.isAllDay,
    this.location,
    required this.reminderMinutes,
    required this.colorHex,
    required this.createdAt,
    required this.updatedAt,
  });

  /// MapからScheduleTemplateオブジェクトを作成
  factory ScheduleTemplate.fromMap(Map<String, dynamic> map) {
    // is_all_dayの処理: Supabaseからはbool、SQLiteからはint
    bool parseAllDay(dynamic allDayData) {
      if (allDayData == null) return false;
      if (allDayData is bool) return allDayData;
      if (allDayData is int) return allDayData == 1;
      return false;
    }

    return ScheduleTemplate(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      title: map['title'] as String,
      description: map['description'] as String?,
      startTime: _parseTimeOfDay(map['start_time'] as String?),
      endTime:
          map['end_time'] != null
              ? _parseTimeOfDay(map['end_time'] as String)
              : null,
      isAllDay: parseAllDay(map['is_all_day']),
      location: map['location'] as String?,
      reminderMinutes: map['reminder_minutes'] as int? ?? 0,
      colorHex: map['color_hex'] as String? ?? '#E85A3B',
      createdAt: DateTime.parse(map['created_at'] as String).toLocal(),
      updatedAt: DateTime.parse(map['updated_at'] as String).toLocal(),
    );
  }

  /// ScheduleTemplateオブジェクトをMapに変換
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'description': description,
      'start_time':
          '${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}:00',
      'end_time':
          endTime != null
              ? '${endTime!.hour.toString().padLeft(2, '0')}:${endTime!.minute.toString().padLeft(2, '0')}:00'
              : null,
      'is_all_day': isAllDay,
      'location': location,
      'reminder_minutes': reminderMinutes,
      'color_hex': colorHex,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// JSON文字列からScheduleTemplateオブジェクトを作成
  factory ScheduleTemplate.fromJson(String source) {
    return ScheduleTemplate.fromMap(jsonDecode(source) as Map<String, dynamic>);
  }

  /// ScheduleTemplateオブジェクトをJSON文字列に変換
  String toJson() {
    return jsonEncode(toMap());
  }

  /// 文字列の時刻をTimeOfDayに変換
  static TimeOfDay _parseTimeOfDay(String? timeString) {
    if (timeString == null || timeString.isEmpty) {
      return const TimeOfDay(hour: 0, minute: 0);
    }

    final parts = timeString.split(':');
    if (parts.length >= 2) {
      final hour = int.tryParse(parts[0]) ?? 0;
      final minute = int.tryParse(parts[1]) ?? 0;
      return TimeOfDay(hour: hour, minute: minute);
    }

    return const TimeOfDay(hour: 0, minute: 0);
  }

  /// テンプレートのコピーを作成（指定されたフィールドを更新）
  ScheduleTemplate copyWith({
    String? id,
    String? userId,
    String? title,
    String? description,
    TimeOfDay? startTime,
    TimeOfDay? endTime,
    bool? isAllDay,
    String? location,
    int? reminderMinutes,
    String? colorHex,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ScheduleTemplate(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      isAllDay: isAllDay ?? this.isAllDay,
      location: location ?? this.location,
      reminderMinutes: reminderMinutes ?? this.reminderMinutes,
      colorHex: colorHex ?? this.colorHex,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// 時刻の表示文字列を取得
  String get timeDisplayString {
    if (isAllDay) return '終日';

    final startTimeStr =
        '${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}';

    if (endTime != null) {
      final endTimeStr =
          '${endTime!.hour.toString().padLeft(2, '0')}:${endTime!.minute.toString().padLeft(2, '0')}';
      return '$startTimeStr - $endTimeStr';
    }

    return startTimeStr;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ScheduleTemplate &&
        other.id == id &&
        other.userId == userId &&
        other.title == title &&
        other.description == description &&
        other.startTime == startTime &&
        other.endTime == endTime &&
        other.isAllDay == isAllDay &&
        other.location == location &&
        other.reminderMinutes == reminderMinutes &&
        other.colorHex == colorHex;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      userId,
      title,
      description,
      startTime,
      endTime,
      isAllDay,
      location,
      reminderMinutes,
      colorHex,
    );
  }

  @override
  String toString() {
    return 'ScheduleTemplate(id: $id, title: $title, time: $timeDisplayString, color: $colorHex)';
  }
}
