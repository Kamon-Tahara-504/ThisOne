import 'package:uuid/uuid.dart';
import '../models/task.dart';
import 'local_database_service.dart';

/// ローカルタスクサービス
///
/// SQLiteを使用してタスクデータのCRUD操作を実行
class LocalTaskService {
  final LocalDatabaseService _dbService = LocalDatabaseService();

  /// タスクを追加
  ///
  /// [userId] ユーザーID
  /// [title] タイトル
  /// [description] 説明
  /// [priority] 優先度
  /// [dueDate] 期限
  ///
  /// 戻り値: 作成されたTaskオブジェクト
  Future<Task> addTask({
    required String userId,
    required String title,
    String? description,
    required TaskPriority priority,
    DateTime? dueDate,
  }) async {
    final db = await _dbService.database;
    final id = const Uuid().v4();
    final now = DateTime.now().toIso8601String();

    final task = Task(
      id: id,
      userId: userId,
      title: title,
      description: description,
      isCompleted: false,
      priority: priority,
      dueDate: dueDate,
      createdAt: DateTime.parse(now),
      updatedAt: DateTime.parse(now),
      completedAt: null,
    );

    await db.insert('tasks', {
      'id': task.id,
      'user_id': task.userId,
      'title': task.title,
      'description': task.description,
      'is_completed': task.isCompleted ? 1 : 0,
      'priority': task.priority.value,
      'due_date': task.dueDate?.toIso8601String(),
      'created_at': now,
      'updated_at': now,
      'completed_at': task.completedAt?.toIso8601String(),
    });

    return task;
  }

  /// ユーザーのタスクを全取得
  ///
  /// [userId] ユーザーID
  ///
  /// 戻り値: タスクリスト（更新日時の降順）
  Future<List<Task>> getTasks(String userId) async {
    final db = await _dbService.database;
    final maps = await db.query(
      'tasks',
      where: 'user_id = ? AND is_deleted = 0',
      whereArgs: [userId],
      orderBy: 'updated_at DESC',
    );

    return maps.map((map) => Task.fromMap(map)).toList();
  }

  /// IDでタスクを取得
  ///
  /// [taskId] タスクID
  ///
  /// 戻り値: タスク（存在しない場合はnull）
  Future<Task?> getTaskById(String taskId) async {
    final db = await _dbService.database;
    final maps = await db.query(
      'tasks',
      where: 'id = ? AND is_deleted = 0',
      whereArgs: [taskId],
      limit: 1,
    );

    if (maps.isEmpty) return null;
    return Task.fromMap(maps.first);
  }

  /// タスクを更新
  ///
  /// [task] 更新するTaskオブジェクト
  Future<void> updateTask(Task task) async {
    final db = await _dbService.database;
    await db.update(
      'tasks',
      {
        'title': task.title,
        'description': task.description,
        'is_completed': task.isCompleted ? 1 : 0,
        'priority': task.priority.value,
        'due_date': task.dueDate?.toIso8601String(),
        'completed_at': task.completedAt?.toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }

  /// タスクの完了状態を切り替え
  ///
  /// [taskId] タスクID
  /// [isCompleted] 完了状態
  Future<void> toggleComplete(String taskId, bool isCompleted) async {
    final db = await _dbService.database;
    await db.update(
      'tasks',
      {
        'is_completed': isCompleted ? 1 : 0,
        'completed_at': isCompleted ? DateTime.now().toIso8601String() : null,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [taskId],
    );
  }

  /// タスクを削除（論理削除）
  ///
  /// [taskId] 削除するタスクID
  Future<void> deleteTask(String taskId) async {
    final db = await _dbService.database;
    await db.update(
      'tasks',
      {'is_deleted': 1, 'updated_at': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [taskId],
    );
  }

  /// 完全削除（論理削除されたタスクを物理削除）
  ///
  /// [taskId] タスクID
  Future<void> permanentlyDeleteTask(String taskId) async {
    final db = await _dbService.database;
    await db.delete('tasks', where: 'id = ?', whereArgs: [taskId]);
  }

  /// ユーザーのすべてのタスクを削除
  ///
  /// [userId] ユーザーID
  Future<void> deleteAllTasks(String userId) async {
    final db = await _dbService.database;
    await db.update(
      'tasks',
      {'is_deleted': 1, 'updated_at': DateTime.now().toIso8601String()},
      where: 'user_id = ?',
      whereArgs: [userId],
    );
  }

  /// ユーザーのすべてのタスクを物理削除
  ///
  /// [userId] ユーザーID
  Future<void> permanentlyDeleteAllTasks(String userId) async {
    final db = await _dbService.database;
    await db.delete('tasks', where: 'user_id = ?', whereArgs: [userId]);
  }
}
