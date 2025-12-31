import 'package:uuid/uuid.dart';
import '../models/task_template.dart';
import '../models/task.dart';
import 'local_database_service.dart';

/// ローカルタスクテンプレートサービス
///
/// SQLiteを使用してタスクテンプレートデータのCRUD操作を実行
class LocalTaskTemplateService {
  final LocalDatabaseService _dbService = LocalDatabaseService();

  /// テンプレートを追加
  ///
  /// [userId] ユーザーID
  /// [title] タイトル
  /// [description] 説明
  /// [priority] 優先度
  /// [dueDate] 期限日
  ///
  /// 戻り値: 作成されたTaskTemplateオブジェクト
  Future<TaskTemplate> addTemplate({
    required String userId,
    required String title,
    String? description,
    required TaskPriority priority,
    DateTime? dueDate,
  }) async {
    final db = await _dbService.database;
    final id = const Uuid().v4();
    final now = DateTime.now().toIso8601String();

    final template = TaskTemplate(
      id: id,
      userId: userId,
      title: title,
      description: description,
      priority: priority,
      dueDate: dueDate,
      createdAt: DateTime.parse(now),
      updatedAt: DateTime.parse(now),
    );

    await db.insert('task_templates', {
      'id': template.id,
      'user_id': template.userId,
      'title': template.title,
      'description': template.description,
      'priority': template.priority.value,
      'due_date': template.dueDate?.toIso8601String(),
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
  Future<List<TaskTemplate>> getTemplates(String userId) async {
    final db = await _dbService.database;
    final maps = await db.query(
      'task_templates',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'created_at DESC',
    );

    return maps.map((map) => TaskTemplate.fromMap(map)).toList();
  }

  /// IDでテンプレートを取得
  ///
  /// [templateId] テンプレートID
  ///
  /// 戻り値: テンプレート（存在しない場合はnull）
  Future<TaskTemplate?> getTemplateById(String templateId) async {
    final db = await _dbService.database;
    final maps = await db.query(
      'task_templates',
      where: 'id = ?',
      whereArgs: [templateId],
      limit: 1,
    );

    if (maps.isEmpty) return null;
    return TaskTemplate.fromMap(maps.first);
  }

  /// テンプレートを更新
  ///
  /// [template] 更新するTaskTemplateオブジェクト
  Future<void> updateTemplate(TaskTemplate template) async {
    final db = await _dbService.database;
    await db.update(
      'task_templates',
      {
        'title': template.title,
        'description': template.description,
        'priority': template.priority.value,
        'due_date': template.dueDate?.toIso8601String(),
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
      'task_templates',
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
      'task_templates',
      where: 'user_id = ?',
      whereArgs: [userId],
    );
  }
}

