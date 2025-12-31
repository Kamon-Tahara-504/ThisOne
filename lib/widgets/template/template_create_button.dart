import 'package:flutter/material.dart';
import '../../gradients.dart';

/// テンプレート作成用のグラデーションボタンコンポーネント
class TemplateCreateButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final bool closeBottomSheet;

  const TemplateCreateButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.closeBottomSheet = false,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: GestureDetector(
        onTap: () {
          if (closeBottomSheet) {
            Navigator.pop(context); // ボトムシートを閉じる
            Navigator.pop(context); // 親のダイアログも閉じる
          }
          onPressed(); // テンプレート作成コールバック
        },
        child: Container(
          width: double.infinity,
          height: 56,
          decoration: BoxDecoration(
            gradient: createHorizontalOrangeYellowGradient(),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
