import 'package:flutter/material.dart';
import '../../gradients.dart';
import '../../services/settings_service.dart';
import '../../services/data_export_service.dart';
import '../../services/data_import_service.dart';
import '../../widgets/settings/settings_toggle_item.dart';
import '../../widgets/settings/settings_action_item.dart';
import '../../widgets/app_bars/static_header_guideline.dart';

/// データ管理画面
///
/// 機能:
/// - 自動同期の有効/無効設定
/// - Wi-Fi接続時のみ同期する設定
/// - 最終同期日時の表示
/// - 手動同期ボタン
/// - キャッシュクリア機能
/// - データバックアップ（手動実行）
///
/// 画面構成:
/// - 同期設定セクション（自動同期、Wi-Fi限定）
/// - 同期状態セクション（最終同期日時、手動同期ボタン）
/// - データ管理セクション（キャッシュクリア、バックアップ）
class DataManagementScreen extends StatefulWidget {
  const DataManagementScreen({super.key});

  @override
  State<DataManagementScreen> createState() => _DataManagementScreenState();
}

class _DataManagementScreenState extends State<DataManagementScreen> {
  final SettingsService _settingsService = SettingsService();
  final DataExportService _exportService = DataExportService();
  final DataImportService _importService = DataImportService();

  bool _autoSync = true;
  bool _syncOnWifiOnly = false;
  String _lastSyncTime = '';
  Map<String, int> _dataCounts = {};

  bool _isLoading = true;
  bool _isSyncing = false;
  bool _isClearingCache = false;
  bool _isExporting = false;
  bool _isImporting = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  /// 設定画面の初期化時に設定値を読み込む
  Future<void> _loadSettings() async {
    await _settingsService.initialize();

    final autoSync = await _settingsService.getAutoSync();
    final syncOnWifiOnly = await _settingsService.getSyncOnWifiOnly();
    final lastSyncTime = await _settingsService.getLastSyncTime();
    final dataCounts = await _exportService.getDataCounts();

    setState(() {
      _autoSync = autoSync;
      _syncOnWifiOnly = syncOnWifiOnly;
      _lastSyncTime = lastSyncTime;
      _dataCounts = dataCounts;
      _isLoading = false;
    });
  }

  /// 設定値を更新し、SharedPreferencesに保存する
  ///
  /// [key] 設定のキー
  /// [value] 新しい値
  /// [updateState] UIの状態を更新するコールバック
  Future<void> _updateSetting<T>(
    String key,
    T value,
    VoidCallback updateState,
  ) async {
    updateState();

    try {
      switch (key) {
        case 'autoSync':
          await _settingsService.setAutoSync(value as bool);
          break;
        case 'syncOnWifiOnly':
          await _settingsService.setSyncOnWifiOnly(value as bool);
          break;
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('設定の保存に失敗しました: $e'),
            backgroundColor: Colors.red[700],
          ),
        );
      }
    }
  }

  /// 手動同期を実行
  Future<void> _performSync() async {
    setState(() {
      _isSyncing = true;
    });

    try {
      // TODO: 実際の同期処理を実装
      // 現在はデモとして2秒待機
      await Future.delayed(const Duration(seconds: 2));

      final now = DateTime.now().toIso8601String();
      await _settingsService.setLastSyncTime(now);

      setState(() {
        _lastSyncTime = now;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('同期が完了しました'),
            backgroundColor: Color(0xFFE85A3B),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('同期に失敗しました: $e'),
            backgroundColor: Colors.red[700],
          ),
        );
      }
    } finally {
      setState(() {
        _isSyncing = false;
      });
    }
  }

  /// キャッシュをクリア
  Future<void> _clearCache() async {
    final confirmed = await _showConfirmDialog(
      title: 'キャッシュをクリア',
      message: 'ローカルのキャッシュデータを削除します。\nこの操作は元に戻せません。',
      confirmText: 'クリア',
      isDangerous: true,
    );

    if (!mounted || !confirmed) return;

    setState(() {
      _isClearingCache = true;
    });

    try {
      // TODO: 実際のキャッシュクリア処理を実装
      await Future.delayed(const Duration(seconds: 1));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('キャッシュをクリアしました'),
            backgroundColor: Color(0xFFE85A3B),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('キャッシュのクリアに失敗しました: $e'),
            backgroundColor: Colors.red[700],
          ),
        );
      }
    } finally {
      setState(() {
        _isClearingCache = false;
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

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.message),
          backgroundColor:
              result.success ? const Color(0xFFE85A3B) : Colors.red[700],
          duration: Duration(seconds: result.success ? 3 : 5),
          action:
              result.success && result.counts != null
                  ? SnackBarAction(
                    label: '詳細',
                    textColor: Colors.white,
                    onPressed: () => _showExportDetails(result.counts!),
                  )
                  : null,
        ),
      );

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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('エクスポート中に予期しないエラーが発生しました'),
            backgroundColor: Colors.red[700],
            duration: const Duration(seconds: 5),
          ),
        );
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

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.message),
          backgroundColor:
              result.success ? const Color(0xFFE85A3B) : Colors.red[700],
        ),
      );

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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('インポートに失敗しました: $e'),
            backgroundColor: Colors.red[700],
          ),
        );
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

  /// 最終同期日時をフォーマットして表示
  String _formatLastSyncTime() {
    if (_lastSyncTime.isEmpty) {
      return '未同期';
    }

    try {
      final dateTime = DateTime.parse(_lastSyncTime);
      final now = DateTime.now();
      final difference = now.difference(dateTime);

      if (difference.inMinutes < 1) {
        return 'たった今';
      } else if (difference.inMinutes < 60) {
        return '${difference.inMinutes}分前';
      } else if (difference.inHours < 24) {
        return '${difference.inHours}時間前';
      } else if (difference.inDays < 7) {
        return '${difference.inDays}日前';
      } else {
        return '${dateTime.month}/${dateTime.day} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
      }
    } catch (e) {
      return '不明';
    }
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
                            // 同期（設定 + 状態 統合セクション）
                            _buildSectionHeader('同期'),
                            const SizedBox(height: 12),

                            SettingsToggleItem(
                              icon: Icons.sync,
                              title: '自動同期',
                              subtitle: 'データを自動的に同期する',
                              value: _autoSync,
                              onChanged:
                                  (value) =>
                                      _updateSetting('autoSync', value, () {
                                        setState(() {
                                          _autoSync = value;
                                        });
                                      }),
                            ),

                            SettingsToggleItem(
                              icon: Icons.wifi,
                              title: 'Wi-Fi接続時のみ同期',
                              subtitle: 'モバイルデータ通信を節約',
                              value: _syncOnWifiOnly,
                              enabled: _autoSync,
                              onChanged:
                                  (value) => _updateSetting(
                                    'syncOnWifiOnly',
                                    value,
                                    () {
                                      setState(() {
                                        _syncOnWifiOnly = value;
                                      });
                                    },
                                  ),
                            ),

                            const SizedBox(height: 12),

                            // 最終同期日時表示（同期セクション内に統合）
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
                                      Icons.access_time,
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
                                          '最終同期',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          _formatLastSyncTime(),
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
                              icon: Icons.sync,
                              title: '今すぐ同期',
                              subtitle: '手動でデータを同期する',
                              isLoading: _isSyncing,
                              onTap: _performSync,
                            ),

                            const SizedBox(height: 24),

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

                            SettingsActionItem(
                              icon: Icons.delete_sweep,
                              title: 'キャッシュをクリア',
                              subtitle: 'ローカルのキャッシュデータを削除',
                              isLoading: _isClearingCache,
                              isDangerous: true,
                              onTap: _clearCache,
                            ),

                            const SizedBox(height: 24),

                            // ヘルプセクション
                            _buildSectionHeader('ヘルプ'),
                            const SizedBox(height: 12),

                            SettingsActionItem(
                              icon: Icons.help_outline,
                              title: 'バックアップについて',
                              subtitle: '使い方とよくある質問',
                              onTap: _showBackupHelp,
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

  /// バックアップヘルプを表示（アイコンを使わない簡潔な表現）
  void _showBackupHelp() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: const Color(0xFF3A3A3A),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text(
              'バックアップについて',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHelpSection(
                    'エクスポート',
                    '現在のデータをJSONファイルとして保存し、他のアプリや端末と共有できます。',
                  ),
                  const SizedBox(height: 16),
                  _buildHelpSection(
                    'インポート',
                    'バックアップファイルからデータを復元します。重複するデータは自動的にスキップされます。',
                  ),
                  const SizedBox(height: 16),
                  _buildHelpSection(
                    'プライバシー',
                    'すべてのデータは端末内に保存され、外部サーバーには送信されません。',
                  ),
                  const SizedBox(height: 16),
                  _buildHelpSection(
                    'ヒント',
                    '• 定期的にバックアップを作成することをお勧めします\n'
                        '• バックアップファイルは安全な場所に保管してください\n'
                        '• 機種変更時にはエクスポート→インポートでデータ移行できます',
                  ),
                ],
              ),
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

  /// ヘルプセクションを構築
  Widget _buildHelpSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Color(0xFFE85A3B),
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          content,
          style: TextStyle(color: Colors.grey[300], fontSize: 14, height: 1.4),
        ),
      ],
    );
  }
}
