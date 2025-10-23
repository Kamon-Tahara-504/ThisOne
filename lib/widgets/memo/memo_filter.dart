import 'package:flutter/material.dart';
import '../../gradients.dart';
import '../../utils/color_utils.dart';

class MemoFilterWidget extends StatelessWidget {
  final String? selectedColorFilter;
  final VoidCallback onShowColorFilterBottomSheet;
  final VoidCallback onClearColorFilter;

  const MemoFilterWidget({
    super.key,
    required this.selectedColorFilter,
    required this.onShowColorFilterBottomSheet,
    required this.onClearColorFilter,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // メインの円形ボタン
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            gradient: createOrangeYellowGradient(),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            shape: const CircleBorder(),
            child: InkWell(
              onTap: onShowColorFilterBottomSheet,
              customBorder: const CircleBorder(),
              child: const Center(
                child: Icon(Icons.palette, color: Color(0xFF2B2B2B), size: 24),
              ),
            ),
          ),
        ),
        // フィルタ中バッジ
        if (selectedColorFilter != null)
          Positioned(
            top: -2,
            right: -2,
            child: GestureDetector(
              onTap: onClearColorFilter,
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  gradient:
                      ColorUtils.isGradientColor(selectedColorFilter!)
                          ? ColorUtils.getGradientFromHex(selectedColorFilter!)
                          : null,
                  color:
                      ColorUtils.isGradientColor(selectedColorFilter!)
                          ? null
                          : ColorUtils.getColorFromHex(selectedColorFilter!),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF2B2B2B), width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.close,
                  size: 14,
                  color:
                      (selectedColorFilter == '#FFEB3B')
                          ? Colors.black
                          : Colors.white,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
