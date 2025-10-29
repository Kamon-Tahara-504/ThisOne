import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'local_memo_service.dart';
import 'local_task_service.dart';
import 'local_schedule_service.dart';
import 'supabase_service.dart';
import '../models/memo.dart';
import '../models/task.dart';
import '../models/schedule.dart';

/// データエクスポートサービス
///
/// ローカルに保存されたデータをJSON形式でエクスポートし、
/// ファイル共有機能を提供します
class DataExportService {
  final LocalMemoService _localMemoService = LocalMemoService();
  final LocalTaskService _localTaskService = LocalTaskService();
  final LocalScheduleService _localScheduleService = LocalScheduleService();
  final SupabaseService _supabaseService = SupabaseService();

  /// 全データをエクスポート
  ///
  /// 戻り値: エクスポートが成功した場合はtrue
  Future<bool> exportAllData() async {
    try {
      // 現在のユーザーIDを取得
      final userId = _getUserId();

      // 全データを取得
      final memos = await _localMemoService.getMemos(userId);
      final tasks = await _localTaskService.getTasks(userId);
      final schedules = await _localScheduleService.getSchedules(userId);

      // エクスポートデータを作成
      final exportData = {
        'version': '1.0.0',
        'exportedAt': DateTime.now().toIso8601String(),
        'userId': userId,
        'data': {
          'memos': memos.map((memo) => _memoToMap(memo)).toList(),
          'tasks': tasks.map((task) => _taskToMap(task)).toList(),
          'schedules':
              schedules.map((schedule) => _scheduleToMap(schedule)).toList(),
        },
        'counts': {
          'memos': memos.length,
          'tasks': tasks.length,
          'schedules': schedules.length,
        },
      };

      // JSONファイルとして保存
      final jsonString = const JsonEncoder.withIndent('  ').convert(exportData);
      final file = await _createExportFile(jsonString);

      // ファイルを共有
      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'ThisOneアプリのバックアップデータ',
        subject:
            'ThisOne バックアップ - ${DateTime.now().toString().substring(0, 16)}',
      );

      return true;
    } catch (e) {
      debugPrint('エクスポートエラー: $e');
      return false;
    }
  }

  /// 特定のデータタイプのみをエクスポート
  ///
  /// [dataTypes] エクスポートするデータタイプのリスト
  /// 戻り値: エクスポートが成功した場合はtrue
  Future<bool> exportSelectedData(List<String> dataTypes) async {
    try {
      final userId = _getUserId();
      final exportData = {
        'version': '1.0.0',
        'exportedAt': DateTime.now().toIso8601String(),
        'userId': userId,
        'data': <String, dynamic>{},
        'counts': <String, int>{},
      };

      // 選択されたデータタイプのみを取得
      if (dataTypes.contains('memos')) {
        final memos = await _localMemoService.getMemos(userId);
        (exportData['data'] as Map<String, dynamic>)['memos'] =
            memos.map((memo) => _memoToMap(memo)).toList();
        (exportData['counts'] as Map<String, int>)['memos'] = memos.length;
      }

      if (dataTypes.contains('tasks')) {
        final tasks = await _localTaskService.getTasks(userId);
        (exportData['data'] as Map<String, dynamic>)['tasks'] =
            tasks.map((task) => _taskToMap(task)).toList();
        (exportData['counts'] as Map<String, int>)['tasks'] = tasks.length;
      }

      if (dataTypes.contains('schedules')) {
        final schedules = await _localScheduleService.getSchedules(userId);
        (exportData['data'] as Map<String, dynamic>)['schedules'] =
            schedules.map((schedule) => _scheduleToMap(schedule)).toList();
        (exportData['counts'] as Map<String, int>)['schedules'] =
            schedules.length;
      }

      // JSONファイルとして保存
      final jsonString = const JsonEncoder.withIndent('  ').convert(exportData);
      final file = await _createExportFile(jsonString);

      // ファイルを共有
      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'ThisOneアプリのバックアップデータ（選択項目）',
        subject:
            'ThisOne バックアップ - ${DateTime.now().toString().substring(0, 16)}',
      );

      return true;
    } catch (e) {
      debugPrint('選択エクスポートエラー: $e');
      return false;
    }
  }

  /// エクスポートファイルを作成
  ///
  /// [jsonString] JSON形式のデータ文字列
  /// 戻り値: 作成されたファイル
  Future<File> _createExportFile(String jsonString) async {
    final directory = await getTemporaryDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final fileName = 'thisone_backup_$timestamp.json';
    final file = File('${directory.path}/$fileName');

    return await file.writeAsString(jsonString);
  }

  /// 現在のユーザーIDを取得
  ///
  /// 戻り値: ユーザーID（ログインしていない場合は'local'）
  String _getUserId() {
    final user = _supabaseService.getCurrentUser();
    return user?.id ?? 'local';
  }

  /// エクスポート可能なデータの統計を取得
  ///
  /// 戻り値: データ統計情報
  Future<Map<String, int>> getDataCounts() async {
    try {
      final userId = _getUserId();

      final memos = await _localMemoService.getMemos(userId);
      final tasks = await _localTaskService.getTasks(userId);
      final schedules = await _localScheduleService.getSchedules(userId);

      return {
        'memos': memos.length,
        'tasks': tasks.length,
        'schedules': schedules.length,
      };
    } catch (e) {
      debugPrint('データ統計取得エラー: $e');
      return {'memos': 0, 'tasks': 0, 'schedules': 0};
    }
  }

  /// MemoをMapに変換
  Map<String, dynamic> _memoToMap(Memo memo) {
    return {
      'id': memo.id,
      'userId': memo.userId,
      'title': memo.title,
      'content': memo.content,
      'mode': memo.mode.value,
      'richContent': memo.richContent,
      'tags': memo.tags,
      'isPinned': memo.isPinned,
      'colorTag': memo.colorTag,
      'createdAt': memo.createdAt.toIso8601String(),
      'updatedAt': memo.updatedAt.toIso8601String(),
    };
  }

  /// TaskをMapに変換
  Map<String, dynamic> _taskToMap(Task task) {
    return {
      'id': task.id,
      'userId': task.userId,
      'title': task.title,
      'description': task.description,
      'isCompleted': task.isCompleted,
      'priority': task.priority.value,
      'dueDate': task.dueDate?.toIso8601String(),
      'createdAt': task.createdAt.toIso8601String(),
      'updatedAt': task.updatedAt.toIso8601String(),
      'completedAt': task.completedAt?.toIso8601String(),
    };
  }

  /// ScheduleをMapに変換
  Map<String, dynamic> _scheduleToMap(Schedule schedule) {
    return {
      'id': schedule.id,
      'userId': schedule.userId,
      'title': schedule.title,
      'description': schedule.description,
      'scheduleDate': schedule.scheduleDate.toIso8601String(),
      'startTime': '${schedule.startTime.hour}:${schedule.startTime.minute}',
      'endTime':
          schedule.endTime != null
              ? '${schedule.endTime!.hour}:${schedule.endTime!.minute}'
              : null,
      'isAllDay': schedule.isAllDay,
      'location': schedule.location,
      'reminderMinutes': schedule.reminderMinutes,
      'colorHex': schedule.colorHex,
      'createdAt': schedule.createdAt.toIso8601String(),
      'updatedAt': schedule.updatedAt.toIso8601String(),
    };
  }
}
