import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'local_memo_service.dart';
import 'local_task_service.dart';
import 'local_schedule_service.dart';
import 'supabase_service.dart';
import '../models/memo.dart';
import '../models/task.dart';

/// インポート結果
class ImportResult {
  final bool success;
  final String message;
  final Map<String, int> importedCounts;
  final Map<String, int> skippedCounts;

  ImportResult({
    required this.success,
    required this.message,
    this.importedCounts = const {},
    this.skippedCounts = const {},
  });
}

/// データインポートサービス
///
/// JSONファイルからデータをインポートし、
/// 既存データとの重複処理を行います
class DataImportService {
  final LocalMemoService _localMemoService = LocalMemoService();
  final LocalTaskService _localTaskService = LocalTaskService();
  final LocalScheduleService _localScheduleService = LocalScheduleService();
  final SupabaseService _supabaseService = SupabaseService();

  /// ファイル選択からデータをインポート
  ///
  /// [progressCallback] インポート進行状況のコールバック
  /// 戻り値: インポート結果
  Future<ImportResult> importFromFile({
    Function(double progress, String message)? progressCallback,
  }) async {
    try {
      progressCallback?.call(0.1, 'ファイルを選択中...');

      // ファイル選択
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
        allowMultiple: false,
      );

      if (result == null || result.files.isEmpty) {
        return ImportResult(success: false, message: 'ファイルが選択されませんでした');
      }

      final file = File(result.files.first.path!);
      return await importFromJsonFile(file, progressCallback: progressCallback);
    } catch (e) {
      debugPrint('ファイル選択エラー: $e');
      return ImportResult(success: false, message: 'ファイル選択中にエラーが発生しました: $e');
    }
  }

  /// JSONファイルからデータをインポート
  ///
  /// [file] インポートするJSONファイル
  /// [progressCallback] インポート進行状況のコールバック
  /// 戻り値: インポート結果
  Future<ImportResult> importFromJsonFile(
    File file, {
    Function(double progress, String message)? progressCallback,
  }) async {
    try {
      progressCallback?.call(0.2, 'ファイルを読み込み中...');

      // ファイル内容を読み込み
      final jsonString = await file.readAsString();
      final jsonData = jsonDecode(jsonString) as Map<String, dynamic>;

      // データ形式を検証
      final validationResult = _validateImportData(jsonData);
      if (!validationResult.success) {
        return validationResult;
      }

      progressCallback?.call(0.3, 'データを検証中...');

      // 現在のユーザーIDを取得
      final currentUserId = _getUserId();

      progressCallback?.call(0.4, 'データをインポート中...');

      // データをインポート
      final importedCounts = <String, int>{};
      final skippedCounts = <String, int>{};
      final data = jsonData['data'] as Map<String, dynamic>;

      // メモのインポート
      if (data.containsKey('memos')) {
        progressCallback?.call(0.5, 'メモをインポート中...');
        final result = await _importMemos(
          data['memos'] as List<dynamic>,
          currentUserId,
        );
        importedCounts['memos'] = result['imported']!;
        skippedCounts['memos'] = result['skipped']!;
      }

      // タスクのインポート
      if (data.containsKey('tasks')) {
        progressCallback?.call(0.7, 'タスクをインポート中...');
        final result = await _importTasks(
          data['tasks'] as List<dynamic>,
          currentUserId,
        );
        importedCounts['tasks'] = result['imported']!;
        skippedCounts['tasks'] = result['skipped']!;
      }

      // スケジュールのインポート
      if (data.containsKey('schedules')) {
        progressCallback?.call(0.9, 'スケジュールをインポート中...');
        final result = await _importSchedules(
          data['schedules'] as List<dynamic>,
          currentUserId,
        );
        importedCounts['schedules'] = result['imported']!;
        skippedCounts['schedules'] = result['skipped']!;
      }

      progressCallback?.call(1.0, 'インポート完了');

      final totalImported = importedCounts.values.fold(
        0,
        (sum, count) => sum + count,
      );
      final totalSkipped = skippedCounts.values.fold(
        0,
        (sum, count) => sum + count,
      );

      return ImportResult(
        success: true,
        message:
            'インポートが完了しました。\n'
            '追加: $totalImported件、スキップ: $totalSkipped件',
        importedCounts: importedCounts,
        skippedCounts: skippedCounts,
      );
    } catch (e) {
      debugPrint('インポートエラー: $e');
      return ImportResult(success: false, message: 'インポート中にエラーが発生しました: $e');
    }
  }

  /// インポートデータの形式を検証
  ///
  /// [jsonData] 検証するJSONデータ
  /// 戻り値: 検証結果
  ImportResult _validateImportData(Map<String, dynamic> jsonData) {
    // 必須フィールドの確認
    if (!jsonData.containsKey('version')) {
      return ImportResult(
        success: false,
        message: 'バックアップファイルの形式が正しくありません（version情報なし）',
      );
    }

    if (!jsonData.containsKey('data')) {
      return ImportResult(
        success: false,
        message: 'バックアップファイルの形式が正しくありません（data情報なし）',
      );
    }

    // バージョン互換性の確認
    final version = jsonData['version'] as String;
    if (!_isVersionCompatible(version)) {
      return ImportResult(
        success: false,
        message: 'バックアップファイルのバージョン（$version）は対応していません',
      );
    }

    return ImportResult(success: true, message: '検証成功');
  }

  /// バージョン互換性をチェック
  ///
  /// [version] チェックするバージョン
  /// 戻り値: 互換性がある場合はtrue
  bool _isVersionCompatible(String version) {
    // 現在は1.0.0のみサポート
    return version == '1.0.0';
  }

  /// メモをインポート
  ///
  /// [memosData] メモデータのリスト
  /// [userId] インポート先のユーザーID
  /// 戻り値: インポート結果（imported, skipped）
  Future<Map<String, int>> _importMemos(
    List<dynamic> memosData,
    String userId,
  ) async {
    int imported = 0;
    int skipped = 0;

    for (final memoData in memosData) {
      try {
        final memo = _mapToMemo(memoData as Map<String, dynamic>, userId);

        // 既存のメモをチェック（タイトルと作成日時で判定）
        final existingMemos = await _localMemoService.getMemos(userId);
        final isDuplicate = existingMemos.any(
          (existing) =>
              existing.title == memo.title &&
              existing.createdAt.difference(memo.createdAt).abs().inMinutes < 1,
        );

        if (!isDuplicate) {
          // LocalMemoServiceのaddMemoメソッドを使用
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
          imported++;
        } else {
          skipped++;
        }
      } catch (e) {
        debugPrint('メモインポートエラー: $e');
        skipped++;
      }
    }

    return {'imported': imported, 'skipped': skipped};
  }

  /// タスクをインポート
  ///
  /// [tasksData] タスクデータのリスト
  /// [userId] インポート先のユーザーID
  /// 戻り値: インポート結果（imported, skipped）
  Future<Map<String, int>> _importTasks(
    List<dynamic> tasksData,
    String userId,
  ) async {
    int imported = 0;
    int skipped = 0;

    for (final taskData in tasksData) {
      try {
        final task = _mapToTask(taskData as Map<String, dynamic>, userId);

        // 既存のタスクをチェック（タイトルと作成日時で判定）
        final existingTasks = await _localTaskService.getTasks(userId);
        final isDuplicate = existingTasks.any(
          (existing) =>
              existing.title == task.title &&
              existing.createdAt.difference(task.createdAt).abs().inMinutes < 1,
        );

        if (!isDuplicate) {
          // LocalTaskServiceのaddTaskメソッドを使用
          await _localTaskService.addTask(
            userId: userId,
            title: task.title,
            description: task.description,
            priority: task.priority,
            dueDate: task.dueDate,
          );
          imported++;
        } else {
          skipped++;
        }
      } catch (e) {
        debugPrint('タスクインポートエラー: $e');
        skipped++;
      }
    }

    return {'imported': imported, 'skipped': skipped};
  }

  /// スケジュールをインポート
  ///
  /// [schedulesData] スケジュールデータのリスト
  /// [userId] インポート先のユーザーID
  /// 戻り値: インポート結果（imported, skipped）
  Future<Map<String, int>> _importSchedules(
    List<dynamic> schedulesData,
    String userId,
  ) async {
    int imported = 0;
    int skipped = 0;

    for (final scheduleData in schedulesData) {
      try {
        final schedule = _mapToSchedule(
          scheduleData as Map<String, dynamic>,
          userId,
        );

        // 既存のスケジュールをチェック（タイトルと日時で判定）
        final existingSchedules = await _localScheduleService.getSchedules(
          userId,
        );
        final isDuplicate = existingSchedules.any(
          (existing) =>
              existing.title == schedule.title &&
              existing.scheduleDate == schedule.scheduleDate &&
              existing.startTime == schedule.startTime,
        );

        if (!isDuplicate) {
          // LocalScheduleServiceのaddScheduleメソッドを使用
          await _localScheduleService.addSchedule(
            userId: userId,
            title: schedule.title,
            description: schedule.description,
            scheduleDate: schedule.scheduleDate,
            startTime:
                schedule.startTime ?? const TimeOfDay(hour: 0, minute: 0),
            endTime: schedule.endTime,
            isAllDay: schedule.isAllDay,
            location: schedule.location,
            reminderMinutes: schedule.reminderMinutes ?? 0,
            colorHex: schedule.colorHex,
          );
          imported++;
        } else {
          skipped++;
        }
      } catch (e) {
        debugPrint('スケジュールインポートエラー: $e');
        skipped++;
      }
    }

    return {'imported': imported, 'skipped': skipped};
  }

  /// 現在のユーザーIDを取得
  ///
  /// 戻り値: ユーザーID（ログインしていない場合は'local'）
  String _getUserId() {
    final user = _supabaseService.getCurrentUser();
    return user?.id ?? 'local';
  }

  /// MapからMemoオブジェクトを作成（一時的な構造体として使用）
  ({
    String title,
    String content,
    MemoMode mode,
    String? richContent,
    List<String> tags,
    bool isPinned,
    String colorTag,
    DateTime createdAt,
    DateTime updatedAt,
  })
  _mapToMemo(Map<String, dynamic> data, String userId) {
    return (
      title: data['title'] as String,
      content: data['content'] as String,
      mode: MemoMode.fromString(data['mode'] as String),
      richContent: data['richContent'] as String?,
      tags: List<String>.from(data['tags'] as List),
      isPinned: data['isPinned'] as bool,
      colorTag: data['colorTag'] as String,
      createdAt: DateTime.parse(data['createdAt'] as String),
      updatedAt: DateTime.parse(data['updatedAt'] as String),
    );
  }

  /// MapからTaskオブジェクトを作成（一時的な構造体として使用）
  ({
    String title,
    String? description,
    bool isCompleted,
    TaskPriority priority,
    DateTime? dueDate,
    DateTime createdAt,
    DateTime updatedAt,
    DateTime? completedAt,
  })
  _mapToTask(Map<String, dynamic> data, String userId) {
    return (
      title: data['title'] as String,
      description: data['description'] as String?,
      isCompleted: data['isCompleted'] as bool,
      priority: TaskPriority.values.firstWhere(
        (p) => p.value == data['priority'] as int,
        orElse: () => TaskPriority.medium,
      ),
      dueDate:
          data['dueDate'] != null
              ? DateTime.parse(data['dueDate'] as String)
              : null,
      createdAt: DateTime.parse(data['createdAt'] as String),
      updatedAt: DateTime.parse(data['updatedAt'] as String),
      completedAt:
          data['completedAt'] != null
              ? DateTime.parse(data['completedAt'] as String)
              : null,
    );
  }

  /// MapからScheduleオブジェクトを作成（一時的な構造体として使用）
  ({
    String title,
    String? description,
    DateTime scheduleDate,
    TimeOfDay? startTime,
    TimeOfDay? endTime,
    bool isAllDay,
    String? location,
    int? reminderMinutes,
    String colorHex,
    DateTime createdAt,
    DateTime updatedAt,
  })
  _mapToSchedule(Map<String, dynamic> data, String userId) {
    TimeOfDay? parseTimeOfDay(String? timeString) {
      if (timeString == null) return null;
      final parts = timeString.split(':');
      return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
    }

    return (
      title: data['title'] as String,
      description: data['description'] as String?,
      scheduleDate: DateTime.parse(data['scheduleDate'] as String),
      startTime: parseTimeOfDay(data['startTime'] as String?),
      endTime: parseTimeOfDay(data['endTime'] as String?),
      isAllDay: data['isAllDay'] as bool,
      location: data['location'] as String?,
      reminderMinutes: data['reminderMinutes'] as int?,
      colorHex: data['colorHex'] as String,
      createdAt: DateTime.parse(data['createdAt'] as String),
      updatedAt: DateTime.parse(data['updatedAt'] as String),
    );
  }
}
