import 'package:flutter/material.dart';
import '../../gradients.dart';
import '../../services/settings_service.dart';
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

  bool _autoSync = true;
  bool _syncOnWifiOnly = false;
  String _lastSyncTime = '';

  bool _isLoading = true;
  bool _isSyncing = false;
  bool _isClearingCache = false;
  bool _isBackingUp = false;

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

    setState(() {
      _autoSync = autoSync;
      _syncOnWifiOnly = syncOnWifiOnly;
      _lastSyncTime = lastSyncTime;
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

    if (!confirmed) return;

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

  /// データをバックアップ
  Future<void> _backupData() async {
    final confirmed = await _showConfirmDialog(
      title: 'データをバックアップ',
      message: '現在のデータをSupabaseにバックアップします。',
      confirmText: 'バックアップ',
      isDangerous: false,
    );

    if (!confirmed) return;

    setState(() {
      _isBackingUp = true;
    });

    try {
      // TODO: 実際のバックアップ処理を実装
      await Future.delayed(const Duration(seconds: 2));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('バックアップが完了しました'),
            backgroundColor: Color(0xFFE85A3B),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('バックアップに失敗しました: $e'),
            backgroundColor: Colors.red[700],
          ),
        );
      }
    } finally {
      setState(() {
        _isBackingUp = false;
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
                            // 同期設定セクション
                            _buildSectionHeader('同期設定'),
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

                            const SizedBox(height: 24),

                            // 同期状態セクション
                            _buildSectionHeader('同期状態'),
                            const SizedBox(height: 12),

                            // 最終同期日時表示
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

                            SettingsActionItem(
                              icon: Icons.backup,
                              title: 'データをバックアップ',
                              subtitle: 'Supabaseにバックアップを作成',
                              isLoading: _isBackingUp,
                              onTap: _backupData,
                            ),

                            SettingsActionItem(
                              icon: Icons.delete_sweep,
                              title: 'キャッシュをクリア',
                              subtitle: 'ローカルのキャッシュデータを削除',
                              isLoading: _isClearingCache,
                              isDangerous: true,
                              onTap: _clearCache,
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
}
