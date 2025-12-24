import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_service.dart';
import '../models/task.dart';
import '../models/memo.dart';
import '../models/schedule.dart';
import 'local_memo_service.dart';
import 'local_task_service.dart';
import 'local_schedule_service.dart';

/// メイン画面のデータ管理を担当するクラス
///
/// ローカルストレージ（SQLite）を使用してデータを管理します。
/// Supabaseは認証のみに使用します。
class MainDataService extends ChangeNotifier {
  final SupabaseService _supabaseService = SupabaseService();
  final LocalMemoService _localMemoService = LocalMemoService();
  final LocalTaskService _localTaskService = LocalTaskService();
  final LocalScheduleService _localScheduleService = LocalScheduleService();

  // データ
  final List<Task> _tasks = [];
  final List<Memo> _memos = [];
  final List<Schedule> _schedules = [];

  // 状態
  bool _isLoading = true;
  bool _isLoadingMemos = true;
  bool _isLoadingSchedules = true;
  String? _newlyCreatedMemoId;
  String? _newlyCreatedTaskId;
  String? _newlyCreatedScheduleId;
  bool _isDisposed = false;

  // ゲッター
  List<Task> get tasks => List.unmodifiable(_tasks);
  List<Memo> get memos => List.unmodifiable(_memos);
  List<Schedule> get schedules => List.unmodifiable(_schedules);
  bool get isLoading => _isLoading;
  bool get isLoadingMemos => _isLoadingMemos;
  bool get isLoadingSchedules => _isLoadingSchedules;
  String? get newlyCreatedMemoId => _newlyCreatedMemoId;
  String? get newlyCreatedTaskId => _newlyCreatedTaskId;
  String? get newlyCreatedScheduleId => _newlyCreatedScheduleId;

  /// 現在のユーザーIDを取得
  ///
  /// ログインしている場合はユーザーID、未ログインの場合は'local'を返す
  String get _userId {
    final user = _supabaseService.getCurrentUser();
    return user?.id ?? 'local';
  }

  /// タスクを読み込み
  Future<void> loadTasks() async {
    if (_isDisposed) return;

    try {
      final tasks = await _localTaskService.getTasks(_userId);
      if (!_isDisposed) {
        _tasks.clear();
        _tasks.addAll(tasks);
        _isLoading = false;
        notifyListeners();
      }
    } catch (e) {
      if (!_isDisposed) {
        _isLoading = false;
        notifyListeners();
        rethrow;
      }
    }
  }

  /// メモを読み込み
  Future<void> loadMemos() async {
    if (_isDisposed) return;

    try {
      final memos = await _localMemoService.getMemos(_userId);
      if (!_isDisposed) {
        _memos.clear();
        _memos.addAll(memos);
        _isLoadingMemos = false;
        notifyListeners();
      }
    } catch (e) {
      if (!_isDisposed) {
        _isLoadingMemos = false;
        notifyListeners();
        rethrow;
      }
    }
  }

  /// スケジュールを読み込み
  Future<void> loadSchedules() async {
    if (_isDisposed) return;

    try {
      final schedules = await _localScheduleService.getSchedules(_userId);
      if (!_isDisposed) {
        _schedules.clear();
        _schedules.addAll(schedules);
        _isLoadingSchedules = false;
        notifyListeners();
      }
    } catch (e) {
      if (!_isDisposed) {
        _isLoadingSchedules = false;
        notifyListeners();
        rethrow;
      }
    }
  }

  /// タスクを詳細情報付きで追加
  Future<void> addTaskWithDetails(Map<String, dynamic> taskData) async {
    if (_isDisposed || taskData['title'].toString().trim().isEmpty) return;

    try {
      final newTask = await _localTaskService.addTask(
        userId: _userId,
        title: taskData['title'].toString().trim(),
        description: taskData['description'],
        priority: taskData['priority'] ?? TaskPriority.low,
        dueDate: taskData['dueDate'],
      );

      if (!_isDisposed) {
        // 新しく作成されたタスクのIDを設定（アニメーション用）
        _newlyCreatedTaskId = newTask.id;
        _tasks.add(newTask);
        notifyListeners();
      }
    } catch (e) {
      rethrow;
    }
  }

  /// タスクの完了状態を切り替え
  Future<void> toggleTaskCompletion({
    required String taskId,
    required bool isCompleted,
  }) async {
    if (_isDisposed) return;

    try {
      await _localTaskService.toggleComplete(taskId, isCompleted);

      if (_isDisposed) return;

      final index = _tasks.indexWhere((task) => task.id == taskId);
      if (index != -1) {
        final now = DateTime.now();
        _tasks[index] = _tasks[index].copyWith(
          isCompleted: isCompleted,
          completedAt: isCompleted ? now : null,
          updatedAt: now,
        );
        notifyListeners();
      }
    } catch (e) {
      rethrow;
    }
  }

  /// タスクを更新
  Future<void> updateTask(Task updatedTask) async {
    if (_isDisposed) return;

    try {
      await _localTaskService.updateTask(updatedTask);

      if (_isDisposed) return;

      final index = _tasks.indexWhere((task) => task.id == updatedTask.id);
      if (index != -1) {
        _tasks[index] = updatedTask.copyWith(updatedAt: DateTime.now());
        notifyListeners();
      }
    } catch (e) {
      rethrow;
    }
  }

  /// タスクを削除
  Future<void> deleteTask(String taskId) async {
    if (_isDisposed) return;

    try {
      await _localTaskService.deleteTask(taskId);

      if (_isDisposed) return;

      _tasks.removeWhere((task) => task.id == taskId);
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  /// メモを作成
  Future<void> createMemo(String title, String mode, String colorHex) async {
    if (_isDisposed) return;

    try {
      // modeをMemoModeに変換
      final memoMode = MemoMode.fromString(mode);
      final newMemo = await _localMemoService.addMemo(
        userId: _userId,
        title: title,
        content: '',
        mode: memoMode,
        colorTag: colorHex,
      );

      if (!_isDisposed) {
        // 新しく作成されたメモのIDを設定
        _newlyCreatedMemoId = newMemo.id;
        notifyListeners();

        // メモリストを再読み込み
        await loadMemos();
      }
    } catch (e) {
      rethrow;
    }
  }

  /// メモを削除
  Future<void> deleteMemo(String memoId) async {
    if (_isDisposed) return;

    try {
      await _localMemoService.deleteMemo(memoId);

      if (_isDisposed) return;

      _memos.removeWhere((memo) => memo.id == memoId);
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  /// メモのピン留め状態を更新
  Future<void> toggleMemoPin({
    required String memoId,
    required bool isPinned,
  }) async {
    if (_isDisposed) return;

    try {
      await _localMemoService.togglePin(memoId, isPinned);

      if (_isDisposed) return;

      final index = _memos.indexWhere((memo) => memo.id == memoId);
      if (index != -1) {
        _memos[index] = _memos[index].copyWith(
          isPinned: isPinned,
          updatedAt: DateTime.now(),
        );
        notifyListeners();
      }
    } catch (e) {
      rethrow;
    }
  }

  /// メモを更新
  Future<void> updateMemo(Memo memo) async {
    if (_isDisposed) return;

    try {
      await _localMemoService.updateMemo(memo);

      if (_isDisposed) return;

      final index = _memos.indexWhere((item) => item.id == memo.id);
      if (index != -1) {
        _memos[index] = memo.copyWith(updatedAt: DateTime.now());
        notifyListeners();
      }
    } catch (e) {
      rethrow;
    }
  }

  /// スケジュールを追加
  Future<void> addSchedule({
    required String title,
    String? description,
    required DateTime scheduleDate,
    required TimeOfDay startTime,
    TimeOfDay? endTime,
    bool isAllDay = false,
    String? location,
    required int reminderMinutes,
    String colorHex = '#E85A3B',
  }) async {
    if (_isDisposed) return;

    try {
      final newSchedule = await _localScheduleService.addSchedule(
        userId: _userId,
        title: title,
        description: description,
        scheduleDate: scheduleDate,
        startTime: startTime,
        endTime: endTime,
        isAllDay: isAllDay,
        location: location,
        reminderMinutes: reminderMinutes,
        colorHex: colorHex,
      );

      if (!_isDisposed) {
        // 新しく作成されたスケジュールのIDを設定
        _newlyCreatedScheduleId = newSchedule.id;
        _schedules.add(newSchedule);
        notifyListeners();
      }
    } catch (e) {
      rethrow;
    }
  }

  /// 新しく作成されたメモIDをクリア
  void clearNewlyCreatedMemoId() {
    if (_newlyCreatedMemoId != null) {
      _newlyCreatedMemoId = null;
      notifyListeners();
    }
  }

  /// 新しく作成されたタスクIDをクリア
  void clearNewlyCreatedTaskId() {
    if (_newlyCreatedTaskId != null) {
      _newlyCreatedTaskId = null;
      notifyListeners();
    }
  }

  /// 新しく作成されたスケジュールIDをクリア
  void clearNewlyCreatedScheduleId() {
    if (_newlyCreatedScheduleId != null) {
      _newlyCreatedScheduleId = null;
      notifyListeners();
    }
  }

  /// スケジュールを削除
  Future<void> deleteSchedule(String scheduleId) async {
    if (_isDisposed) return;

    try {
      await _localScheduleService.deleteSchedule(scheduleId);

      if (!_isDisposed) {
        _schedules.removeWhere((schedule) => schedule.id == scheduleId);
        notifyListeners();
      }
    } catch (e) {
      rethrow;
    }
  }

  /// スケジュールを更新
  Future<void> updateSchedule(Schedule schedule) async {
    if (_isDisposed) return;

    try {
      await _localScheduleService.updateSchedule(schedule);

      if (_isDisposed) return;

      final index = _schedules.indexWhere((item) => item.id == schedule.id);
      if (index != -1) {
        _schedules[index] = schedule.copyWith(updatedAt: DateTime.now());
        notifyListeners();
      }
    } catch (e) {
      rethrow;
    }
  }

  /// タスクを更新
  void updateTasks(List<Task> updatedTasks) {
    if (_isDisposed) return;
    _tasks.clear();
    _tasks.addAll(updatedTasks);
    notifyListeners();
  }

  /// メモを更新
  void updateMemos(List<Memo> updatedMemos) {
    if (_isDisposed) return;
    _memos.clear();
    _memos.addAll(updatedMemos);
    notifyListeners();
  }

  /// スケジュールを更新
  void updateSchedules(List<Schedule> updatedSchedules) {
    if (_isDisposed) return;
    _schedules.clear();
    _schedules.addAll(updatedSchedules);
    notifyListeners();
  }

  /// 認証状態の変更を監視
  void startAuthStateListener() {
    _supabaseService.authStateChanges.listen((AuthState data) {
      if (!_isDisposed) {
        loadTasks();
        loadMemos();
        loadSchedules();
      }
    });
  }

  /// リソースを解放
  @override
  void dispose() {
    if (_isDisposed) return;
    _isDisposed = true;
    super.dispose();
  }
}
