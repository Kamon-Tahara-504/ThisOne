import 'package:flutter/material.dart';
import '../../gradients.dart';

/// 設定画面で使用するトグルスイッチ付き設定項目ウィジェット
///
/// 機能:
/// - アイコン、タイトル、説明文、トグルスイッチを表示
/// - 有効/無効状態の制御
/// - グラデーションアイコンの表示
/// - タップでトグルスイッチの状態を変更
class SettingsToggleItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool enabled;

  const SettingsToggleItem({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    required this.value,
    required this.onChanged,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
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
        trailing: Switch(
          value: value,
          onChanged: enabled ? onChanged : null,
          thumbColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return const Color(0xFFE85A3B);
            }
            return Colors.grey[400];
          }),
          trackColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return const Color(0xFFE85A3B).withValues(alpha: 0.3);
            }
            return Colors.grey[700];
          }),
        ),
        enableFeedback: false,
      ),
    );
  }
}
