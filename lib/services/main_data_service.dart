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
  bool _isDisposed = false;

  // ゲッター
  List<Task> get tasks => List.unmodifiable(_tasks);
  List<Memo> get memos => List.unmodifiable(_memos);
  List<Schedule> get schedules => List.unmodifiable(_schedules);
  bool get isLoading => _isLoading;
  bool get isLoadingMemos => _isLoadingMemos;
  bool get isLoadingSchedules => _isLoadingSchedules;
  String? get newlyCreatedMemoId => _newlyCreatedMemoId;

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

  /// タスクを追加
  Future<void> addTask(String title) async {
    if (_isDisposed || title.trim().isEmpty) return;

    try {
      final newTask = await _localTaskService.addTask(
        userId: _userId,
        title: title.trim(),
        priority: TaskPriority.low,
      );

      if (!_isDisposed) {
        _tasks.add(newTask);
        notifyListeners();
      }
    } catch (e) {
      rethrow;
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
        _tasks.add(newTask);
        notifyListeners();
      }
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
