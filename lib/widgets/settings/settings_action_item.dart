import 'package:flutter/material.dart';
import '../../gradients.dart';
import 'tappable_settings_card.dart';

/// 設定画面で使用するアクション実行ボタンウィジェット
///
/// 機能:
/// - アイコン、タイトル、説明文、右矢印を表示
/// - タップでアクションを実行（同期、バックアップ、削除など）
/// - ローディング状態の表示
/// - 有効/無効状態の制御
/// - 危険なアクション用の色分け対応
class SettingsActionItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;
  final bool enabled;
  final bool isLoading;
  final bool isDangerous;

  const SettingsActionItem({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    required this.onTap,
    this.enabled = true,
    this.isLoading = false,
    this.isDangerous = false,
  });

  @override
  Widget build(BuildContext context) {
    return TappableSettingsCard(
      onTap: enabled && !isLoading ? onTap : null,
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
          style: TextStyle(
            color:
                isDangerous
                    ? Colors.red[400]
                    : (enabled ? Colors.white : Colors.grey[500]),
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle:
            subtitle != null
                ? Text(
                  subtitle!,
                  style: TextStyle(
                    color: enabled ? Colors.grey[400] : Colors.grey[600],
                    fontSize: 14,
                  ),
                )
                : null,
        trailing:
            isLoading
                ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Color(0xFFE85A3B),
                    ),
                  ),
                )
                : Icon(
                  Icons.arrow_forward_ios,
                  color: enabled ? Colors.grey[500] : Colors.grey[700],
                  size: 16,
                ),
        enableFeedback: false,
      ),
    );
  }
}
