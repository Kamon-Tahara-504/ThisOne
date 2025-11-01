import 'package:flutter/material.dart';

/// 開発中で無効化された認証ボタン用のコンポーネント
///
/// ボタンを半透明にし、中央に「開発中」のバッジを表示します
class DisabledAuthButton extends StatelessWidget {
  /// 無効化するボタンウィジェット
  final Widget button;

  /// バッジに表示するテキスト（デフォルト: "開発中（今後対応予定）"）
  final String? badgeText;

  /// ボタンの透明度（デフォルト: 0.5）
  final double opacity;

  /// オーバーレイの透明度（デフォルト: 0.3）
  final double overlayOpacity;

  const DisabledAuthButton({
    super.key,
    required this.button,
    this.badgeText,
    this.opacity = 0.5,
    this.overlayOpacity = 0.3,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 半透明のボタン
        Opacity(opacity: opacity, child: button),
        // オーバーレイレイヤー
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: overlayOpacity),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(child: _buildBadge()),
          ),
        ),
      ],
    );
  }

  /// 開発中バッジを構築
  Widget _buildBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.orange[800]?.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.orange[300]!, width: 1),
      ),
      child: Text(
        badgeText ?? '開発中（今後対応予定）',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
