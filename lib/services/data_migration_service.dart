import 'supabase_service.dart';
import 'local_memo_service.dart';
import 'local_task_service.dart';
import 'local_schedule_service.dart';

/// データ移行サービス
///
/// Supabaseからローカルストレージへのデータ移行を行います
class DataMigrationService {
  final SupabaseService _supabaseService = SupabaseService();
  final LocalMemoService _localMemoService = LocalMemoService();
  final LocalTaskService _localTaskService = LocalTaskService();
  final LocalScheduleService _localScheduleService = LocalScheduleService();

  /// 移行が必要かどうかをチェック
  ///
  /// [userId] ユーザーID
  ///
  /// 戻り値: true = 移行が必要, false = 移行不要
  Future<bool> needsMigration(String userId) async {
    try {
      // ローカルDBにメモが存在するかチェック
      final localMemos = await _localMemoService.getMemos(userId);

      // メモが1つもなければ移行が必要
      if (localMemos.isEmpty) {
        return true;
      }

      return false;
    } catch (e) {
      // エラーが発生した場合も移行を試みる
      return true;
    }
  }

  /// Supabaseからローカルストレージへデータを移行
  ///
  /// [userId] ユーザーID
  /// [progressCallback] 進捗コールバック（オプション）
  ///
  /// 戻り値: 移行したデータ数（メモ、タスク、スケジュール）
  Future<Map<String, int>> migrateFromSupabase(
    String userId, {
    Function(double progress)? progressCallback,
  }) async {
    int memoCount = 0;
    int taskCount = 0;
    int scheduleCount = 0;

    try {
      // メモの移行
      final memos = await _supabaseService.getUserMemosTyped();
      for (final memo in memos) {
        // 既存のメモをチェック
        final existingMemo = await _localMemoService.getMemoById(memo.id);
        if (existingMemo == null) {
          // 新規メモとして追加
          await _localMemoService.addMemo(
            userId: userId,
            title: memo.title,
            content: memo.content,
            mode: memo.mode,
            richContent: memo.richContent,
            tags: memo.tags,
            isPinned: memo.isPinned,
            colorTag: memo.colorTag,
          );
          memoCount++;
        }

        // 進捗を報告
        if (progressCallback != null) {
          final progress = 0.33 * (memos.indexOf(memo) + 1) / memos.length;
          progressCallback(progress);
        }
      }

      // タスクの移行
      final tasks = await _supabaseService.getUserTasksTyped();
      for (final task in tasks) {
        // 既存のタスクをチェック
        final existingTask = await _localTaskService.getTaskById(task.id);
        if (existingTask == null) {
          // 新規タスクとして追加
          await _localTaskService.addTask(
            userId: userId,
            title: task.title,
            description: task.description,
            priority: task.priority,
            dueDate: task.dueDate,
          );

          // 完了状態を更新
          if (task.isCompleted) {
            await _localTaskService.toggleComplete(task.id, true);
          }

          taskCount++;
        }

        // 進捗を報告
        if (progressCallback != null) {
          final progress =
              0.33 + 0.33 * (tasks.indexOf(task) + 1) / tasks.length;
          progressCallback(progress);
        }
      }

      // スケジュールの移行
      final schedules = await _supabaseService.getUserSchedulesTyped();
      for (final schedule in schedules) {
        // 既存のスケジュールをチェック
        final existingSchedule = await _localScheduleService.getScheduleById(
          schedule.id,
        );
        if (existingSchedule == null) {
          // 新規スケジュールとして追加
          await _localScheduleService.addSchedule(
            userId: userId,
            title: schedule.title,
            description: schedule.description,
            scheduleDate: schedule.scheduleDate,
            startTime: schedule.startTime,
            endTime: schedule.endTime,
            isAllDay: schedule.isAllDay,
            location: schedule.location,
            reminderMinutes: schedule.reminderMinutes,
            colorHex: schedule.colorHex,
          );
          scheduleCount++;
        }

        // 進捗を報告
        if (progressCallback != null) {
          final progress =
              0.66 +
              0.34 * (schedules.indexOf(schedule) + 1) / schedules.length;
          progressCallback(progress);
        }
      }
    } catch (e) {
      // エラーが発生しても移行済みのデータは保持
      print('データ移行エラー: $e');
    }

    return {'memos': memoCount, 'tasks': taskCount, 'schedules': scheduleCount};
  }

  /// ローカルストレージの全データを削除
  ///
  /// [userId] ユーザーID
  ///
  /// ⚠️ 注意: この操作は取り消せません
  Future<void> clearAllLocalData(String userId) async {
    await _localMemoService.deleteAllMemos(userId);
    await _localTaskService.deleteAllTasks(userId);
    await _localScheduleService.deleteAllSchedules(userId);
  }
}
