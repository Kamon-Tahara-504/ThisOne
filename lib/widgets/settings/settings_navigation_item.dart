import 'package:flutter/material.dart';
import '../../gradients.dart';

/// 設定画面で使用するナビゲーション付き設定項目ウィジェット
///
/// 機能:
/// - アイコン、タイトル、説明文、右矢印を表示
/// - タップで他の画面に遷移
/// - 有効/無効状態の制御
/// - グラデーションアイコンの表示
class SettingsNavigationItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;
  final bool enabled;

  const SettingsNavigationItem({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    required this.onTap,
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
        trailing: Icon(
          Icons.chevron_right,
          color: enabled ? Colors.grey[500] : Colors.grey[700],
        ),
        onTap: enabled ? onTap : null,
      ),
    );
  }
}
