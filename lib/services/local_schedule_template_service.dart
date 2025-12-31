import 'package:uuid/uuid.dart';
import 'package:flutter/material.dart';
import '../models/schedule_template.dart';
import 'local_database_service.dart';

/// ローカルスケジュールテンプレートサービス
///
/// SQLiteを使用してスケジュールテンプレートデータのCRUD操作を実行
class LocalScheduleTemplateService {
  final LocalDatabaseService _dbService = LocalDatabaseService();

  /// テンプレートを追加
  ///
  /// [userId] ユーザーID
  /// [title] タイトル
  /// [description] 説明
  /// [startTime] 開始時刻
  /// [endTime] 終了時刻
  /// [isAllDay] 終日フラグ
  /// [location] 場所
  /// [reminderMinutes] リマインダー（分）
  /// [colorHex] カラーコード
  ///
  /// 戻り値: 作成されたScheduleTemplateオブジェクト
  Future<ScheduleTemplate> addTemplate({
    required String userId,
    required String title,
    String? description,
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

    final template = ScheduleTemplate(
      id: id,
      userId: userId,
      title: title,
      description: description,
      startTime: startTime,
      endTime: endTime,
      isAllDay: isAllDay,
      location: location,
      reminderMinutes: reminderMinutes,
      colorHex: colorHex,
      createdAt: DateTime.parse(now),
      updatedAt: DateTime.parse(now),
    );

    await db.insert('schedule_templates', {
      'id': template.id,
      'user_id': template.userId,
      'title': template.title,
      'description': template.description,
      'start_time':
          '${template.startTime.hour.toString().padLeft(2, '0')}:${template.startTime.minute.toString().padLeft(2, '0')}:00',
      'end_time':
          template.endTime != null
              ? '${template.endTime!.hour.toString().padLeft(2, '0')}:${template.endTime!.minute.toString().padLeft(2, '0')}:00'
              : null,
      'is_all_day': template.isAllDay ? 1 : 0,
      'location': template.location,
      'reminder_minutes': template.reminderMinutes,
      'color_hex': template.colorHex,
      'created_at': now,
      'updated_at': now,
    });

    return template;
  }

  /// ユーザーのテンプレートを全取得
  ///
  /// [userId] ユーザーID
  ///
  /// 戻り値: テンプレートリスト（作成日時の降順）
  Future<List<ScheduleTemplate>> getTemplates(String userId) async {
    final db = await _dbService.database;
    final maps = await db.query(
      'schedule_templates',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'created_at DESC',
    );

    return maps.map((map) => ScheduleTemplate.fromMap(map)).toList();
  }

  /// IDでテンプレートを取得
  ///
  /// [templateId] テンプレートID
  ///
  /// 戻り値: テンプレート（存在しない場合はnull）
  Future<ScheduleTemplate?> getTemplateById(String templateId) async {
    final db = await _dbService.database;
    final maps = await db.query(
      'schedule_templates',
      where: 'id = ?',
      whereArgs: [templateId],
      limit: 1,
    );

    if (maps.isEmpty) return null;
    return ScheduleTemplate.fromMap(maps.first);
  }

  /// テンプレートを更新
  ///
  /// [template] 更新するScheduleTemplateオブジェクト
  Future<void> updateTemplate(ScheduleTemplate template) async {
    final db = await _dbService.database;
    await db.update(
      'schedule_templates',
      {
        'title': template.title,
        'description': template.description,
        'start_time':
            '${template.startTime.hour.toString().padLeft(2, '0')}:${template.startTime.minute.toString().padLeft(2, '0')}:00',
        'end_time':
            template.endTime != null
                ? '${template.endTime!.hour.toString().padLeft(2, '0')}:${template.endTime!.minute.toString().padLeft(2, '0')}:00'
                : null,
        'is_all_day': template.isAllDay ? 1 : 0,
        'location': template.location,
        'reminder_minutes': template.reminderMinutes,
        'color_hex': template.colorHex,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [template.id],
    );
  }

  /// テンプレートを削除
  ///
  /// [templateId] 削除するテンプレートID
  Future<void> deleteTemplate(String templateId) async {
    final db = await _dbService.database;
    await db.delete(
      'schedule_templates',
      where: 'id = ?',
      whereArgs: [templateId],
    );
  }

  /// ユーザーのすべてのテンプレートを削除
  ///
  /// [userId] ユーザーID
  Future<void> deleteAllTemplates(String userId) async {
    final db = await _dbService.database;
    await db.delete(
      'schedule_templates',
      where: 'user_id = ?',
      whereArgs: [userId],
    );
  }
}
