import 'package:flutter/material.dart';
import '../../gradients.dart';

/// 静的ヘッダー用のグラデーションガイドライン
///
/// 設定画面のヘッダー直下に表示される水平グラデーションライン
/// アカウント設定と通知設定画面と同じデザインを適用
class StaticHeaderGuideline extends StatelessWidget {
  const StaticHeaderGuideline({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 2,
      decoration: BoxDecoration(
        gradient: createHorizontalOrangeYellowGradient(),
      ),
    );
  }
}
