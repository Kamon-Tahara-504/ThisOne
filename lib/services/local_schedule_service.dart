import 'package:uuid/uuid.dart';
import 'package:flutter/material.dart';
import '../models/schedule.dart';
import 'local_database_service.dart';

/// ローカルスケジュールサービス
///
/// SQLiteを使用してスケジュールデータのCRUD操作を実行
class LocalScheduleService {
  final LocalDatabaseService _dbService = LocalDatabaseService();

  /// スケジュールを追加
  ///
  /// [userId] ユーザーID
  /// [title] タイトル
  /// [description] 説明
  /// [scheduleDate] 日付
  /// [startTime] 開始時刻
  /// [endTime] 終了時刻
  /// [isAllDay] 終日フラグ
  /// [location] 場所
  /// [reminderMinutes] リマインダー（分）
  /// [colorHex] カラーコード
  ///
  /// 戻り値: 作成されたScheduleオブジェクト
  Future<Schedule> addSchedule({
    required String userId,
    required String title,
    String? description,
    required DateTime scheduleDate,
    required TimeOfDay startTime,
    TimeOfDay? endTime,
    required bool isAllDay,
    String? location,
    int reminderMinutes = 0,
    String colorHex = '#E85A3B',
  }) async {
    final db = await _dbService.database;
    final id = const Uuid().v4();
    final now = DateTime.now().toIso8601String();

    final schedule = Schedule(
      id: id,
      userId: userId,
      title: title,
      description: description,
      scheduleDate: scheduleDate,
      startTime: startTime,
      endTime: endTime,
      isAllDay: isAllDay,
      location: location,
      reminderMinutes: reminderMinutes,
      colorHex: colorHex,
      createdAt: DateTime.parse(now),
      updatedAt: DateTime.parse(now),
    );

    await db.insert('schedules', {
      'id': schedule.id,
      'user_id': schedule.userId,
      'title': schedule.title,
      'description': schedule.description,
      'schedule_date':
          '${schedule.scheduleDate.year}-${schedule.scheduleDate.month.toString().padLeft(2, '0')}-${schedule.scheduleDate.day.toString().padLeft(2, '0')}',
      'start_time':
          '${schedule.startTime.hour.toString().padLeft(2, '0')}:${schedule.startTime.minute.toString().padLeft(2, '0')}:00',
      'end_time':
          schedule.endTime != null
              ? '${schedule.endTime!.hour.toString().padLeft(2, '0')}:${schedule.endTime!.minute.toString().padLeft(2, '0')}:00'
              : null,
      'is_all_day': schedule.isAllDay ? 1 : 0,
      'location': schedule.location,
      'reminder_minutes': schedule.reminderMinutes,
      'color_hex': schedule.colorHex,
      'created_at': now,
      'updated_at': now,
    });

    return schedule;
  }

  /// ユーザーのスケジュールを全取得
  ///
  /// [userId] ユーザーID
  ///
  /// 戻り値: スケジュールリスト（日付の昇順）
  Future<List<Schedule>> getSchedules(String userId) async {
    final db = await _dbService.database;
    final maps = await db.query(
      'schedules',
      where: 'user_id = ? AND is_deleted = 0',
      whereArgs: [userId],
      orderBy: 'schedule_date ASC, start_time ASC',
    );

    return maps.map((map) => Schedule.fromMap(map)).toList();
  }

  /// 特定日付のスケジュールを取得
  ///
  /// [userId] ユーザーID
  /// [date] 日付
  ///
  /// 戻り値: 指定日付のスケジュールリスト
  Future<List<Schedule>> getSchedulesByDate(
    String userId,
    DateTime date,
  ) async {
    final db = await _dbService.database;
    final dateString =
        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    final maps = await db.query(
      'schedules',
      where: 'user_id = ? AND schedule_date = ? AND is_deleted = 0',
      whereArgs: [userId, dateString],
      orderBy: 'start_time ASC',
    );

    return maps.map((map) => Schedule.fromMap(map)).toList();
  }

  /// IDでスケジュールを取得
  ///
  /// [scheduleId] スケジュールID
  ///
  /// 戻り値: スケジュール（存在しない場合はnull）
  Future<Schedule?> getScheduleById(String scheduleId) async {
    final db = await _dbService.database;
    final maps = await db.query(
      'schedules',
      where: 'id = ? AND is_deleted = 0',
      whereArgs: [scheduleId],
      limit: 1,
    );

    if (maps.isEmpty) return null;
    return Schedule.fromMap(maps.first);
  }

  /// スケジュールを更新
  ///
  /// [schedule] 更新するScheduleオブジェクト
  Future<void> updateSchedule(Schedule schedule) async {
    final db = await _dbService.database;
    await db.update(
      'schedules',
      {
        'title': schedule.title,
        'description': schedule.description,
        'schedule_date':
            '${schedule.scheduleDate.year}-${schedule.scheduleDate.month.toString().padLeft(2, '0')}-${schedule.scheduleDate.day.toString().padLeft(2, '0')}',
        'start_time':
            '${schedule.startTime.hour.toString().padLeft(2, '0')}:${schedule.startTime.minute.toString().padLeft(2, '0')}:00',
        'end_time':
            schedule.endTime != null
                ? '${schedule.endTime!.hour.toString().padLeft(2, '0')}:${schedule.endTime!.minute.toString().padLeft(2, '0')}:00'
                : null,
        'is_all_day': schedule.isAllDay ? 1 : 0,
        'location': schedule.location,
        'reminder_minutes': schedule.reminderMinutes,
        'color_hex': schedule.colorHex,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [schedule.id],
    );
  }

  /// スケジュールを削除（論理削除）
  ///
  /// [scheduleId] 削除するスケジュールID
  Future<void> deleteSchedule(String scheduleId) async {
    final db = await _dbService.database;
    await db.update(
      'schedules',
      {'is_deleted': 1, 'updated_at': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [scheduleId],
    );
  }

  /// 完全削除（論理削除されたスケジュールを物理削除）
  ///
  /// [scheduleId] スケジュールID
  Future<void> permanentlyDeleteSchedule(String scheduleId) async {
    final db = await _dbService.database;
    await db.delete('schedules', where: 'id = ?', whereArgs: [scheduleId]);
  }

  /// ユーザーのすべてのスケジュールを削除
  ///
  /// [userId] ユーザーID
  Future<void> deleteAllSchedules(String userId) async {
    final db = await _dbService.database;
    await db.update(
      'schedules',
      {'is_deleted': 1, 'updated_at': DateTime.now().toIso8601String()},
      where: 'user_id = ?',
      whereArgs: [userId],
    );
  }

  /// ユーザーのすべてのスケジュールを物理削除
  ///
  /// [userId] ユーザーID
  Future<void> permanentlyDeleteAllSchedules(String userId) async {
    final db = await _dbService.database;
    await db.delete('schedules', where: 'user_id = ?', whereArgs: [userId]);
  }
}
