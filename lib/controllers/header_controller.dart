import 'package:flutter/material.dart';

/// ヘッダーの表示制御を管理するクラス
class HeaderController extends ChangeNotifier {
  double _headerOffset = 0.0; // 0.0=完全表示, 1.0=完全非表示
  double _lastScrollPosition = 0.0;
  bool _isScrollingDown = false;

  // 定数
  static const double _headerHeight = 54.0;
  static const Duration _headerAnimationDuration = Duration(milliseconds: 200);

  /// ヘッダーのオフセット（0.0=完全表示, 1.0=完全非表示）
  double get headerOffset => _headerOffset;

  /// ヘッダーの表示状態（互換性のため残す）
  bool get isHeaderVisible => _headerOffset < 0.5;

  /// ヘッダーの高さ
  static double get headerHeight => _headerHeight;

  /// ヘッダーアニメーション時間
  static Duration get headerAnimationDuration => _headerAnimationDuration;

  /// スクロール位置を更新してヘッダーの表示状態を制御
  void updateScrollPosition({
    required double currentPosition,
    required int currentPageIndex,
    required int targetPageIndex,
  }) {
    // 現在のページのみ監視
    if (currentPageIndex != targetPageIndex) return;

    // スクロール量を計算
    final delta = currentPosition - _lastScrollPosition;

    // スクロール量が微小な場合は無視
    if (delta.abs() < 0.5) {
      return;
    }

    // スクロール方向の検出
    final isNowScrollingDown = delta > 0;

    // スクロール方向が変わったらリセット
    if (isNowScrollingDown != _isScrollingDown) {
      _isScrollingDown = isNowScrollingDown;
    }

    // スクロール量に応じてoffsetを計算
    // deltaを_headerHeightで割ることで、ヘッダーの高さ分スクロールしたら完全に隠れる/表示される
    final offsetDelta = delta / _headerHeight;

    if (_isScrollingDown) {
      // 下スクロール: 上部付近（50px以下）以外でヘッダーを隠す
      if (currentPosition > 50.0) {
        _headerOffset = (_headerOffset + offsetDelta).clamp(0.0, 1.0);
      }
      // 上部付近（50px以下）では何もしない（ヘッダーは表示されたまま）
    } else {
      // 上スクロール: 上部付近（50px以下）の場合のみヘッダーを表示
      if (currentPosition <= 50.0) {
        _headerOffset = (_headerOffset + offsetDelta).clamp(0.0, 1.0);
      }
      // 上部付近以外では何もしない（ヘッダーは隠れたまま）
    }

    _lastScrollPosition = currentPosition;
    notifyListeners();
  }

  /// 動的トップパディングを計算
  double calculateDynamicTopPadding(BuildContext context) {
    final statusBarHeight = MediaQuery.of(context).padding.top;
    const baseOffset = 4.0;
    final baseTop = statusBarHeight + baseOffset;

    // offsetに応じて連続的にパディングを計算
    // offset=0.0(完全表示): baseTop + _headerHeight
    // offset=1.0(完全非表示): statusBarHeight
    return baseTop + (_headerHeight * (1.0 - _headerOffset));
  }

  /// ヘッダーの位置を計算
  double calculateHeaderTop(BuildContext context) {
    final statusBarHeight = MediaQuery.of(context).padding.top;
    const baseOffset = 4.0;
    final baseTop = statusBarHeight + baseOffset;

    // offsetに応じて連続的に位置を計算
    // offset=0.0(完全表示): baseTop
    // offset=1.0(完全非表示): baseTop - _headerHeight
    return baseTop - (_headerHeight * _headerOffset);
  }

  /// ヘッダーの表示状態を手動で設定
  void setHeaderVisible(bool visible) {
    final targetOffset = visible ? 0.0 : 1.0;
    if (_headerOffset != targetOffset) {
      _headerOffset = targetOffset;
      notifyListeners();
    }
  }

  /// ヘッダーの表示状態をリセット
  void reset() {
    _headerOffset = 0.0;
    _lastScrollPosition = 0.0;
    _isScrollingDown = false;
    notifyListeners();
  }

  @override
  void dispose() {
    super.dispose();
  }
}
