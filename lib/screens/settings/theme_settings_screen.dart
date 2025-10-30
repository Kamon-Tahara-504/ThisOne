import 'package:flutter/material.dart';
import '../../gradients.dart';
import '../../services/settings_service.dart';
import '../../widgets/app_bars/static_header_guideline.dart';

/// テーマ設定画面
///
/// 機能:
/// - 表示モード選択（ダーク/ライト/システム設定に従う）
///
/// 画面構成:
/// - 表示モードセクション（ラジオボタン選択）
class ThemeSettingsScreen extends StatefulWidget {
  const ThemeSettingsScreen({super.key});

  @override
  State<ThemeSettingsScreen> createState() => _ThemeSettingsScreenState();
}

class _ThemeSettingsScreenState extends State<ThemeSettingsScreen> {
  final SettingsService _settingsService = SettingsService();

  String _themeMode = 'dark';

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  /// 設定画面の初期化時に設定値を読み込む
  Future<void> _loadSettings() async {
    await _settingsService.initialize();

    final themeMode = await _settingsService.getThemeMode();

    setState(() {
      _themeMode = themeMode;
      _isLoading = false;
    });
  }

  /// テーマモードを更新
  Future<void> _updateThemeMode(String mode) async {
    setState(() {
      _themeMode = mode;
    });

    try {
      await _settingsService.setThemeMode(mode);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('テーマモードを変更しました'),
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

  /// 設定をリセット
  Future<void> _resetSettings() async {
    final confirmed = await _showConfirmDialog();
    if (!confirmed) return;

    try {
      await _settingsService.resetThemeSettings();
      await _loadSettings();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('テーマ設定をリセットしました'),
            backgroundColor: Color(0xFFE85A3B),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('リセットに失敗しました: $e'),
            backgroundColor: Colors.red[700],
          ),
        );
      }
    }
  }

  /// 確認ダイアログを表示
  Future<bool> _showConfirmDialog() async {
    final result = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: const Color(0xFF3A3A3A),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text(
              'テーマ設定をリセット',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: Text(
              'テーマ設定をデフォルトに戻します。\nよろしいですか？',
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
                  'リセット',
                  style: TextStyle(
                    color: Color(0xFFE85A3B),
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
                    'テーマ',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: _resetSettings,
                    child: const Text(
                      'リセット',
                      style: TextStyle(color: Color(0xFFE85A3B), fontSize: 16),
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
                            // 表示モードセクション
                            _buildSectionHeader('表示モード'),
                            const SizedBox(height: 12),

                            _buildThemeModeOption(
                              mode: 'dark',
                              icon: Icons.dark_mode,
                              title: 'ダークモード',
                              subtitle: '目に優しい暗いテーマ',
                            ),

                            _buildThemeModeOption(
                              mode: 'light',
                              icon: Icons.light_mode,
                              title: 'ライトモード',
                              subtitle: '明るく見やすいテーマ',
                            ),

                            _buildThemeModeOption(
                              mode: 'system',
                              icon: Icons.brightness_auto,
                              title: 'システム設定に従う',
                              subtitle: '端末の設定に合わせて自動切替',
                            ),

                            const SizedBox(height: 16),

                            // 注意事項
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.blue.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.blue.withOpacity(0.3),
                                ),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(
                                    Icons.info_outline,
                                    color: Colors.blue[300],
                                    size: 20,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      'テーマ変更は次回アプリ起動時に反映されます',
                                      style: TextStyle(
                                        color: Colors.blue[200],
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
          child: const Icon(Icons.palette, color: Colors.white, size: 20),
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

  /// テーマモード選択項目を構築
  ///
  /// [mode] テーマモードの値
  /// [icon] アイコン
  /// [title] タイトル
  /// [subtitle] 説明文
  Widget _buildThemeModeOption({
    required String mode,
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    final isSelected = _themeMode == mode;
    final bool isEnabled = mode == 'dark'; // ライト/システムは未実装のため無効化

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF3A3A3A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? const Color(0xFFE85A3B) : Colors.grey[700]!,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            gradient:
                isSelected
                    ? createOrangeYellowGradient()
                    : LinearGradient(
                      colors: [Colors.grey[700]!, Colors.grey[600]!],
                    ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
        title: Text(
          isEnabled ? title : '$title（未実装）',
          style: TextStyle(
            color:
                isEnabled
                    ? (isSelected ? Colors.white : Colors.grey[300])
                    : Colors.grey[500],
            fontSize: 16,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        subtitle: Text(
          isEnabled ? subtitle : '未実装です（今後対応予定）',
          style: TextStyle(color: Colors.grey[500], fontSize: 14),
        ),
        trailing: Radio<String>(
          value: mode,
          groupValue: _themeMode,
          onChanged:
              isEnabled
                  ? (value) {
                    if (value != null) {
                      _updateThemeMode(value);
                    }
                  }
                  : null,
          activeColor: const Color(0xFFE85A3B),
        ),
        onTap: isEnabled ? () => _updateThemeMode(mode) : null,
      ),
    );
  }
}
