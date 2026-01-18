import 'package:flutter/material.dart';
import '../../gradients.dart';
import '../../services/settings_service.dart';
import '../../services/data_export_service.dart';
import '../../services/data_import_service.dart';
import '../../services/local_task_service.dart';
import '../../services/local_memo_service.dart';
import '../../services/local_schedule_service.dart';
import '../../services/supabase_service.dart';
import '../../utils/error_handler.dart';
import '../../widgets/settings/settings_action_item.dart';
import '../../widgets/app_bars/static_header_guideline.dart';

/// データ管理画面
///
/// 機能:
/// - データバックアップ（エクスポート/インポート）
/// - データ一括削除（タスク、メモ、スケジュール）
///
/// 画面構成:
/// - データ管理セクション（データ統計、エクスポート、インポート）
/// - データ削除セクション（タスク、メモ、スケジュールの一括削除）
class DataManagementScreen extends StatefulWidget {
  const DataManagementScreen({super.key});

  @override
  State<DataManagementScreen> createState() => _DataManagementScreenState();
}

class _DataManagementScreenState extends State<DataManagementScreen> {
  final SettingsService _settingsService = SettingsService();
  final DataExportService _exportService = DataExportService();
  final DataImportService _importService = DataImportService();
  final LocalTaskService _taskService = LocalTaskService();
  final LocalMemoService _memoService = LocalMemoService();
  final LocalScheduleService _scheduleService = LocalScheduleService();
  final SupabaseService _supabaseService = SupabaseService();

  Map<String, int> _dataCounts = {};

  bool _isLoading = true;
  bool _isExporting = false;
  bool _isImporting = false;
  bool _isDeletingTasks = false;
  bool _isDeletingMemos = false;
  bool _isDeletingSchedules = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  /// 設定画面の初期化時に設定値を読み込む
  Future<void> _loadSettings() async {
    await _settingsService.initialize();

    final dataCounts = await _exportService.getDataCounts();

    setState(() {
      _dataCounts = dataCounts;
      _isLoading = false;
    });
  }

  /// 現在のユーザーIDを取得
  String _getUserId() {
    final user = _supabaseService.getCurrentUser();
    return user?.id ?? 'local';
  }

  /// すべてのタスクを削除
  Future<void> _deleteAllTasks() async {
    final taskCount = _dataCounts['tasks'] ?? 0;
    if (taskCount == 0) {
      if (mounted) {
        AppErrorHandler.showInfo(context, '削除するタスクがありません');
      }
      return;
    }

    final confirmed = await _showConfirmDialog(
      title: 'すべてのタスクを削除',
      message: 'すべてのタスク（$taskCount件）を削除します。\nこの操作は元に戻せません。',
      confirmText: '削除する',
      isDangerous: true,
    );

    if (!mounted || !confirmed) return;

    setState(() {
      _isDeletingTasks = true;
    });

    try {
      final userId = _getUserId();
      await _taskService.deleteAllTasks(userId);

      // データ統計を更新
      final newDataCounts = await _exportService.getDataCounts();
      if (!mounted) return;

      setState(() {
        _dataCounts = newDataCounts;
      });

      if (mounted) {
        AppErrorHandler.showSuccess(context, 'すべてのタスクを削除しました');
      }
    } catch (e) {
      if (mounted) {
        AppErrorHandler.handleError(context, e, operation: 'タスクの削除');
      }
    } finally {
      setState(() {
        _isDeletingTasks = false;
      });
    }
  }

  /// すべてのメモを削除
  Future<void> _deleteAllMemos() async {
    final memoCount = _dataCounts['memos'] ?? 0;
    if (memoCount == 0) {
      if (mounted) {
        AppErrorHandler.showInfo(context, '削除するメモがありません');
      }
      return;
    }

    final confirmed = await _showConfirmDialog(
      title: 'すべてのメモを削除',
      message: 'すべてのメモ（$memoCount件）を削除します。\nこの操作は元に戻せません。',
      confirmText: '削除する',
      isDangerous: true,
    );

    if (!mounted || !confirmed) return;

    setState(() {
      _isDeletingMemos = true;
    });

    try {
      final userId = _getUserId();
      await _memoService.deleteAllMemos(userId);

      // データ統計を更新
      final newDataCounts = await _exportService.getDataCounts();
      if (!mounted) return;

      setState(() {
        _dataCounts = newDataCounts;
      });

      if (mounted) {
        AppErrorHandler.showSuccess(context, 'すべてのメモを削除しました');
      }
    } catch (e) {
      if (mounted) {
        AppErrorHandler.handleError(context, e, operation: 'メモの削除');
      }
    } finally {
      setState(() {
        _isDeletingMemos = false;
      });
    }
  }

  /// すべてのスケジュールを削除
  Future<void> _deleteAllSchedules() async {
    final scheduleCount = _dataCounts['schedules'] ?? 0;
    if (scheduleCount == 0) {
      if (mounted) {
        AppErrorHandler.showInfo(context, '削除するスケジュールがありません');
      }
      return;
    }

    final confirmed = await _showConfirmDialog(
      title: 'すべてのスケジュールを削除',
      message: 'すべてのスケジュール（$scheduleCount件）を削除します。\nこの操作は元に戻せません。',
      confirmText: '削除する',
      isDangerous: true,
    );

    if (!mounted || !confirmed) return;

    setState(() {
      _isDeletingSchedules = true;
    });

    try {
      final userId = _getUserId();
      await _scheduleService.deleteAllSchedules(userId);

      // データ統計を更新
      final newDataCounts = await _exportService.getDataCounts();
      if (!mounted) return;

      setState(() {
        _dataCounts = newDataCounts;
      });

      if (mounted) {
        AppErrorHandler.showSuccess(context, 'すべてのスケジュールを削除しました');
      }
    } catch (e) {
      if (mounted) {
        AppErrorHandler.handleError(context, e, operation: 'スケジュールの削除');
      }
    } finally {
      setState(() {
        _isDeletingSchedules = false;
      });
    }
  }

  /// データをエクスポート
  Future<void> _exportData() async {
    final totalItems = _dataCounts.values.fold(0, (sum, count) => sum + count);

    final confirmed = await _showConfirmDialog(
      title: 'データをエクスポート',
      message:
          '現在のデータ（$totalItems件）をファイルとしてエクスポートします。\n'
          'メモ: ${_dataCounts['memos'] ?? 0}件\n'
          'タスク: ${_dataCounts['tasks'] ?? 0}件\n'
          'スケジュール: ${_dataCounts['schedules'] ?? 0}件',
      confirmText: 'エクスポート',
      isDangerous: false,
    );

    if (!confirmed) return;

    setState(() {
      _isExporting = true;
    });

    try {
      final result = await _exportService.exportAllData();

      if (!mounted) return;

      if (result.success) {
        AppErrorHandler.showSuccess(context, result.message);
        // 詳細情報がある場合は表示
        if (result.counts != null) {
          Future.delayed(const Duration(seconds: 1), () {
            if (mounted) {
              _showExportDetails(result.counts!);
            }
          });
        }
      } else {
        AppErrorHandler.handleError(
          context,
          result.message,
          operation: 'エクスポート',
        );
      }

      // 成功した場合はデータ統計を更新
      if (result.success) {
        final newDataCounts = await _exportService.getDataCounts();
        if (!mounted) return;
        setState(() {
          _dataCounts = newDataCounts;
        });
      }
    } catch (e) {
      if (mounted) {
        AppErrorHandler.handleError(context, e, operation: 'エクスポート');
      }
    } finally {
      setState(() {
        _isExporting = false;
      });
    }
  }

  /// データをインポート
  Future<void> _importData() async {
    final confirmed = await _showConfirmDialog(
      title: 'データをインポート',
      message:
          'バックアップファイルからデータをインポートします。\n'
          '重複するデータはスキップされます。',
      confirmText: 'インポート',
      isDangerous: false,
    );

    if (!mounted || !confirmed) return;

    setState(() {
      _isImporting = true;
    });

    // 進行状況ダイアログを表示
    String progressMessage = 'インポート準備中...';
    double progressValue = 0.0;

    late StateSetter dialogSetState;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => StatefulBuilder(
            builder: (context, setDialogState) {
              dialogSetState = setDialogState;
              return AlertDialog(
                backgroundColor: const Color(0xFF3A3A3A),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                title: const Text(
                  'データインポート中',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    LinearProgressIndicator(
                      value: progressValue,
                      backgroundColor: Colors.grey[600],
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Color(0xFFE85A3B),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      progressMessage,
                      style: TextStyle(color: Colors.grey[300], fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${(progressValue * 100).toInt()}%',
                      style: const TextStyle(
                        color: Color(0xFFE85A3B),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
    );

    try {
      final result = await _importService.importFromFile(
        progressCallback: (progress, message) {
          dialogSetState(() {
            progressValue = progress;
            progressMessage = message;
          });
        },
      );

      if (!mounted) return;

      // 進行状況ダイアログを閉じる
      Navigator.pop(context);

      if (result.success) {
        AppErrorHandler.showSuccess(context, result.message);
      } else {
        AppErrorHandler.handleError(
          context,
          result.message,
          operation: 'インポート',
        );
      }

      // 成功した場合はデータ統計を更新
      if (result.success) {
        final newDataCounts = await _exportService.getDataCounts();
        if (!mounted) return;
        setState(() {
          _dataCounts = newDataCounts;
        });
      }
    } catch (e) {
      // 進行状況ダイアログを閉じる
      if (mounted) Navigator.pop(context);

      if (mounted) {
        AppErrorHandler.handleError(context, e, operation: 'インポート');
      }
    } finally {
      setState(() {
        _isImporting = false;
      });
    }
  }

  /// 確認ダイアログを表示
  ///
  /// [title] ダイアログのタイトル
  /// [message] ダイアログのメッセージ
  /// [confirmText] 確認ボタンのテキスト
  /// [isDangerous] 危険な操作かどうか（赤色表示）
  Future<bool> _showConfirmDialog({
    required String title,
    required String message,
    required String confirmText,
    required bool isDangerous,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: const Color(0xFF3A3A3A),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: Text(
              message,
              style: TextStyle(color: Colors.grey[300], fontSize: 16),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(
                  'キャンセル',
                  style: TextStyle(color: Colors.grey[400], fontSize: 16),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(
                  confirmText,
                  style: TextStyle(
                    color:
                        isDangerous ? Colors.red[400] : const Color(0xFFE85A3B),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
    );

    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2B2B2B),
      body: SafeArea(
        child: Column(
          children: [
            // ヘッダー
            Container(
              height: 52,
              margin: const EdgeInsets.only(top: 4.0),
              padding: const EdgeInsets.symmetric(
                horizontal: 14.0,
                vertical: 1.0,
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    padding: const EdgeInsets.all(4),
                    constraints: const BoxConstraints(
                      minWidth: 32,
                      minHeight: 32,
                    ),
                    icon: const Icon(
                      Icons.arrow_back_ios,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'データ管理',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),

            // グラデーションガイドライン
            const StaticHeaderGuideline(),

            // メインコンテンツ
            Expanded(
              child:
                  _isLoading
                      ? const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFFE85A3B),
                        ),
                      )
                      : SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // データ管理セクション
                            _buildSectionHeader('データ管理'),
                            const SizedBox(height: 12),

                            // データ統計表示
                            Container(
                              padding: const EdgeInsets.all(16),
                              margin: const EdgeInsets.only(bottom: 12),
                              decoration: BoxDecoration(
                                color: const Color(0xFF3A3A3A),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      gradient: createOrangeYellowGradient(),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(
                                      Icons.storage,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'ローカルデータ',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'メモ: ${_dataCounts['memos'] ?? 0}件 | '
                                          'タスク: ${_dataCounts['tasks'] ?? 0}件 | '
                                          'スケジュール: ${_dataCounts['schedules'] ?? 0}件',
                                          style: TextStyle(
                                            color: Colors.grey[400],
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            SettingsActionItem(
                              icon: Icons.file_upload,
                              title: 'データをエクスポート',
                              subtitle: 'バックアップファイルを作成・共有',
                              isLoading: _isExporting,
                              onTap: _exportData,
                            ),

                            SettingsActionItem(
                              icon: Icons.file_download,
                              title: 'データをインポート',
                              subtitle: 'バックアップファイルから復元',
                              isLoading: _isImporting,
                              onTap: _importData,
                            ),

                            const SizedBox(height: 24),

                            // データ削除セクション
                            _buildSectionHeader('データ削除'),
                            const SizedBox(height: 12),

                            SettingsActionItem(
                              icon: Icons.task_alt,
                              title: 'すべてのタスクを削除',
                              subtitle: 'タスク: ${_dataCounts['tasks'] ?? 0}件',
                              isLoading: _isDeletingTasks,
                              isDangerous: true,
                              onTap: _deleteAllTasks,
                            ),

                            SettingsActionItem(
                              icon: Icons.note,
                              title: 'すべてのメモを削除',
                              subtitle: 'メモ: ${_dataCounts['memos'] ?? 0}件',
                              isLoading: _isDeletingMemos,
                              isDangerous: true,
                              onTap: _deleteAllMemos,
                            ),

                            SettingsActionItem(
                              icon: Icons.calendar_today,
                              title: 'すべてのスケジュールを削除',
                              subtitle:
                                  'スケジュール: ${_dataCounts['schedules'] ?? 0}件',
                              isLoading: _isDeletingSchedules,
                              isDangerous: true,
                              onTap: _deleteAllSchedules,
                            ),
                          ],
                        ),
                      ),
            ),
          ],
        ),
      ),
    );
  }

  /// セクションヘッダーを構築する
  ///
  /// [title] セクションのタイトル
  Widget _buildSectionHeader(String title) {
    return Row(
      children: [
        ShaderMask(
          shaderCallback:
              (bounds) => createOrangeYellowGradient().createShader(bounds),
          child: const Icon(Icons.settings, color: Colors.white, size: 20),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  /// エクスポート詳細を表示
  ///
  /// [counts] エクスポートされたデータの件数
  void _showExportDetails(Map<String, int> counts) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: const Color(0xFF3A3A3A),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text(
              'エクスポート詳細',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailRow('メモ', counts['memos'] ?? 0),
                const SizedBox(height: 8),
                _buildDetailRow('タスク', counts['tasks'] ?? 0),
                const SizedBox(height: 8),
                _buildDetailRow('スケジュール', counts['schedules'] ?? 0),
                const Divider(color: Colors.grey),
                _buildDetailRow(
                  '合計',
                  counts.values.fold(0, (sum, count) => sum + count),
                  isTotal: true,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  '閉じる',
                  style: TextStyle(color: Color(0xFFE85A3B), fontSize: 16),
                ),
              ),
            ],
          ),
    );
  }

  /// 詳細行を構築
  Widget _buildDetailRow(String label, int count, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: isTotal ? Colors.white : Colors.grey[300],
            fontSize: isTotal ? 16 : 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          '$count件',
          style: TextStyle(
            color: isTotal ? const Color(0xFFE85A3B) : Colors.grey[300],
            fontSize: isTotal ? 16 : 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}
