import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../gradients.dart';
import '../../services/settings_service.dart';
import '../../widgets/settings/settings_action_item.dart';
import '../../widgets/app_bars/static_header_guideline.dart';

/// プライバシー設定画面
///
/// 機能:
/// - 完了済みタスクを自動削除（30日後/90日後/なし）
/// - 古いメモを自動アーカイブ（有効/無効）
/// - 全データを削除
/// - アカウントを完全に削除
/// - プライバシーポリシーへのリンク
/// - 利用規約へのリンク
///
/// 画面構成:
/// - 自動削除設定セクション
/// - リンクセクション
/// - 危険な操作セクション（削除系）
class PrivacySettingsScreen extends StatefulWidget {
  const PrivacySettingsScreen({super.key});

  @override
  State<PrivacySettingsScreen> createState() => _PrivacySettingsScreenState();
}

class _PrivacySettingsScreenState extends State<PrivacySettingsScreen> {
  final SettingsService _settingsService = SettingsService();

  String _autoDeleteCompletedTasks = 'none';
  bool _autoArchiveOldMemos = false;

  bool _isLoading = true;
  bool _isDeletingData = false;
  bool _isDeletingAccount = false;

  // 自動削除オプション
  final List<Map<String, String>> _deleteOptions = [
    {'value': 'none', 'label': '削除しない'},
    {'value': '30days', 'label': '30日後'},
    {'value': '90days', 'label': '90日後'},
  ];

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  /// 設定画面の初期化時に設定値を読み込む
  Future<void> _loadSettings() async {
    await _settingsService.initialize();

    final autoDeleteCompletedTasks =
        await _settingsService.getAutoDeleteCompletedTasks();
    final autoArchiveOldMemos = await _settingsService.getAutoArchiveOldMemos();

    setState(() {
      _autoDeleteCompletedTasks = autoDeleteCompletedTasks;
      _autoArchiveOldMemos = autoArchiveOldMemos;
      _isLoading = false;
    });
  }

  /// 自動削除設定を更新
  Future<void> _updateAutoDeleteSetting(String value) async {
    setState(() {
      _autoDeleteCompletedTasks = value;
    });

    try {
      await _settingsService.setAutoDeleteCompletedTasks(value);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('設定を変更しました'),
            backgroundColor: Color(0xFFE85A3B),
            duration: Duration(seconds: 1),
          ),
        );
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

  /// 自動アーカイブ設定を更新
  Future<void> _updateAutoArchiveSetting(bool value) async {
    setState(() {
      _autoArchiveOldMemos = value;
    });

    try {
      await _settingsService.setAutoArchiveOldMemos(value);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('設定を変更しました'),
            backgroundColor: Color(0xFFE85A3B),
            duration: Duration(seconds: 1),
          ),
        );
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

  /// 全データを削除
  Future<void> _deleteAllData() async {
    final confirmed = await _showConfirmDialog(
      title: '全データを削除',
      message: 'すべてのメモ、スケジュール、タスクが完全に削除されます。\n\nこの操作は取り消せません。本当に削除しますか？',
      confirmText: '削除する',
      requireDoubleConfirm: true,
    );

    if (!confirmed) return;

    setState(() {
      _isDeletingData = true;
    });

    try {
      // TODO: 実際のデータ削除処理を実装
      await Future.delayed(const Duration(seconds: 2));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('全データを削除しました'),
            backgroundColor: Color(0xFFE85A3B),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('削除に失敗しました: $e'),
            backgroundColor: Colors.red[700],
          ),
        );
      }
    } finally {
      setState(() {
        _isDeletingData = false;
      });
    }
  }

  /// アカウントを完全に削除
  Future<void> _deleteAccount() async {
    final confirmed = await _showConfirmDialog(
      title: 'アカウントを削除',
      message: 'アカウントとすべてのデータが完全に削除されます。\n\nこの操作は取り消せません。本当に削除しますか？',
      confirmText: 'アカウントを削除',
      requireDoubleConfirm: true,
    );

    if (!confirmed) return;

    setState(() {
      _isDeletingAccount = true;
    });

    try {
      // TODO: 実際のアカウント削除処理を実装
      await Future.delayed(const Duration(seconds: 2));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('アカウントを削除しました'),
            backgroundColor: Color(0xFFE85A3B),
          ),
        );
        // アカウント削除後はログイン画面に遷移
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('削除に失敗しました: $e'),
            backgroundColor: Colors.red[700],
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isDeletingAccount = false;
        });
      }
    }
  }

  /// 確認ダイアログを表示
  ///
  /// [title] ダイアログのタイトル
  /// [message] ダイアログのメッセージ
  /// [confirmText] 確認ボタンのテキスト
  /// [requireDoubleConfirm] 2段階確認が必要かどうか
  Future<bool> _showConfirmDialog({
    required String title,
    required String message,
    required String confirmText,
    bool requireDoubleConfirm = false,
  }) async {
    final firstConfirm = await showDialog<bool>(
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
                  style: const TextStyle(
                    color: Colors.red,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
    );

    if (firstConfirm != true || !requireDoubleConfirm) {
      return firstConfirm ?? false;
    }

    // 2段階目の確認
    final secondConfirm = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: const Color(0xFF3A3A3A),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text(
              '最終確認',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: Text(
              '本当によろしいですか？\nこの操作は取り消せません。',
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
                child: const Text(
                  '実行する',
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
    );

    return secondConfirm ?? false;
  }

  /// URLを開く
  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('リンクを開けませんでした'),
            backgroundColor: Colors.red,
          ),
        );
      }
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
                    'プライバシー',
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
                            // 自動削除設定セクション
                            _buildSectionHeader('自動削除設定'),
                            const SizedBox(height: 12),

                            // 完了済みタスクの自動削除
                            Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              decoration: BoxDecoration(
                                color: const Color(0xFF3A3A3A),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey[700]!),
                              ),
                              child: Column(
                                children: [
                                  ListTile(
                                    leading: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        gradient: createOrangeYellowGradient(),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Icon(
                                        Icons.auto_delete,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                    ),
                                    title: const Text(
                                      '完了済みタスクの自動削除',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    subtitle: Text(
                                      '完了したタスクを自動的に削除',
                                      style: TextStyle(
                                        color: Colors.grey[400],
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 8,
                                    ),
                                    child: Column(
                                      children:
                                          _deleteOptions
                                              .map(
                                                (
                                                  option,
                                                ) => RadioListTile<String>(
                                                  value: option['value']!,
                                                  groupValue:
                                                      _autoDeleteCompletedTasks,
                                                  onChanged: (value) {
                                                    if (value != null) {
                                                      _updateAutoDeleteSetting(
                                                        value,
                                                      );
                                                    }
                                                  },
                                                  title: Text(
                                                    option['label']!,
                                                    style: TextStyle(
                                                      color: Colors.grey[300],
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                  activeColor: const Color(
                                                    0xFFE85A3B,
                                                  ),
                                                ),
                                              )
                                              .toList(),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // 古いメモの自動アーカイブ
                            Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              decoration: BoxDecoration(
                                color: const Color(0xFF3A3A3A),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey[700]!),
                              ),
                              child: SwitchListTile(
                                secondary: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    gradient: createOrangeYellowGradient(),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(
                                    Icons.archive,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                                title: const Text(
                                  '古いメモを自動アーカイブ',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                subtitle: Text(
                                  '90日以上更新されていないメモをアーカイブ',
                                  style: TextStyle(
                                    color: Colors.grey[400],
                                    fontSize: 14,
                                  ),
                                ),
                                value: _autoArchiveOldMemos,
                                onChanged: _updateAutoArchiveSetting,
                                activeColor: const Color(0xFFE85A3B),
                              ),
                            ),

                            const SizedBox(height: 24),

                            // リンクセクション
                            _buildSectionHeader('法的情報'),
                            const SizedBox(height: 12),

                            _buildLinkCard(
                              icon: Icons.privacy_tip,
                              title: 'プライバシーポリシー',
                              subtitle: '個人情報の取り扱いについて',
                              onTap:
                                  () =>
                                      _launchUrl('https://example.com/privacy'),
                            ),

                            _buildLinkCard(
                              icon: Icons.article,
                              title: '利用規約',
                              subtitle: 'サービス利用規約',
                              onTap:
                                  () => _launchUrl('https://example.com/terms'),
                            ),

                            const SizedBox(height: 24),

                            // 危険な操作セクション
                            _buildSectionHeader('危険な操作'),
                            const SizedBox(height: 12),

                            SettingsActionItem(
                              icon: Icons.delete_forever,
                              title: '全データを削除',
                              subtitle: 'すべてのメモ、スケジュール、タスクを削除',
                              isLoading: _isDeletingData,
                              isDangerous: true,
                              onTap: _deleteAllData,
                            ),

                            SettingsActionItem(
                              icon: Icons.person_remove,
                              title: 'アカウントを削除',
                              subtitle: 'アカウントとすべてのデータを完全に削除',
                              isLoading: _isDeletingAccount,
                              isDangerous: true,
                              onTap: _deleteAccount,
                            ),

                            const SizedBox(height: 16),

                            // 警告メッセージ
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.red.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.red.withOpacity(0.3),
                                ),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(
                                    Icons.warning_amber_rounded,
                                    color: Colors.red[300],
                                    size: 20,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      '削除操作は取り消すことができません。実行前に必ずバックアップを取ってください。',
                                      style: TextStyle(
                                        color: Colors.red[200],
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
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
          child: const Icon(Icons.security, color: Colors.white, size: 20),
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

  /// リンクカードを構築
  ///
  /// [icon] アイコン
  /// [title] タイトル
  /// [subtitle] 説明文
  /// [onTap] タップ時の処理
  Widget _buildLinkCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF3A3A3A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[700]!),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            gradient: createOrangeYellowGradient(),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(color: Colors.grey[400], fontSize: 14),
        ),
        trailing: Icon(Icons.open_in_new, color: Colors.grey[500], size: 16),
        onTap: onTap,
      ),
    );
  }
}
