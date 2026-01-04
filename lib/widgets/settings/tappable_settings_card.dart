import 'package:flutter/material.dart';

/// 設定画面で使用するタッパブルなコンテナコンポーネント
///
/// 機能:
/// - 統一されたスタイリング（背景色、ボーダー、マージン）
/// - ボックス全体を囲うInkWellアニメーション
/// - タップ可能/不可能の状態管理
///
/// 使用例:
/// ```dart
/// TappableSettingsCard(
///   onTap: () => Navigator.push(...),
///   child: ListTile(...),
/// )
/// ```
class TappableSettingsCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsets? margin;
  final double? borderRadius;

  /// 設定画面用のタッパブルコンテナ
  ///
  /// [child] 表示する子ウィジェット（通常はListTile）
  /// [onTap] タップ時のコールバック（nullの場合はタップ無効）
  /// [margin] マージン（デフォルト: EdgeInsets.only(bottom: 12)）
  /// [borderRadius] 角丸の半径（デフォルト: 12.0）
  const TappableSettingsCard({
    super.key,
    required this.child,
    this.onTap,
    this.margin,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveMargin = margin ?? const EdgeInsets.only(bottom: 12);
    final effectiveBorderRadius = borderRadius ?? 12.0;

    return Container(
      margin: effectiveMargin,
      decoration: BoxDecoration(
        color: const Color(0xFF3A3A3A),
        borderRadius: BorderRadius.circular(effectiveBorderRadius),
        border: Border.all(color: Colors.grey[700]!),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(effectiveBorderRadius),
          onTap: onTap,
          child: child,
        ),
      ),
    );
  }
}
