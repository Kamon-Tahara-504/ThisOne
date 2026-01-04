import 'package:flutter/material.dart';
import '../../gradients.dart';
import 'tappable_settings_card.dart';

/// 設定画面で使用する選択肢付き設定項目ウィジェット
///
/// 機能:
/// - アイコン、タイトル、現在の選択値を表示
/// - タップで選択ダイアログを表示
/// - 有効/無効状態の制御
/// - グラデーションアイコンの表示
/// - 右矢印で選択可能であることを示す
class SettingsSelectionItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final String currentValue;
  final VoidCallback onTap;
  final bool enabled;

  const SettingsSelectionItem({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    required this.currentValue,
    required this.onTap,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return TappableSettingsCard(
      onTap: enabled ? onTap : null,
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
            color: enabled ? Colors.white : Colors.grey[500],
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
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              currentValue,
              style: TextStyle(
                color: enabled ? Colors.grey[300] : Colors.grey[600],
                fontSize: 14,
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.chevron_right,
              color: enabled ? Colors.grey[500] : Colors.grey[700],
            ),
          ],
        ),
        enableFeedback: false,
      ),
    );
  }
}
