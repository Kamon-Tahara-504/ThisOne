import 'package:flutter/material.dart';

/// ボトムシートのヘッダーコンポーネント
/// アイコン、タイトル、閉じるボタンを表示
class BottomSheetHeader extends StatelessWidget {
  final IconData? icon;
  final String title;
  final VoidCallback? onClose;

  const BottomSheetHeader({
    super.key,
    this.icon,
    required this.title,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (icon != null) ...[
          Icon(
            icon,
            color: Colors.white,
            size: 24,
          ),
          const SizedBox(width: 12),
        ],
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        const Spacer(),
        IconButton(
          onPressed: onClose ?? () => Navigator.pop(context),
          icon: const Icon(Icons.close, color: Colors.white),
        ),
      ],
    );
  }
}
