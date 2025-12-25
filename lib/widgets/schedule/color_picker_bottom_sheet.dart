import 'package:flutter/material.dart';
import '../../utils/color_utils.dart';

class ColorPickerBottomSheet extends StatelessWidget {
  final String selectedColorHex;
  final ValueChanged<String> onColorSelected;

  const ColorPickerBottomSheet({
    super.key,
    required this.selectedColorHex,
    required this.onColorSelected,
  });

  // 色選択オプション（強化版）
  Widget _buildEnhancedColorOption(
    BuildContext context,
    Map<String, dynamic> colorItem,
    String selectedColorHex,
    Function(String) onColorSelected,
  ) {
    final colorHex = colorItem['hex'] as String;
    final isGradient = colorItem['isGradient'] as bool;
    final color = colorItem['color'] as Color?;
    final isSelected = selectedColorHex == colorHex;

    return GestureDetector(
      onTap: () {
        onColorSelected(colorHex);
        Navigator.pop(context);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          gradient: isGradient ? ColorUtils.getGradientFromHex(colorHex) : null,
          color: isGradient ? null : color,
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? Colors.white : Colors.transparent,
            width: 3,
          ),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: Colors.white.withValues(alpha: 0.5),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
          ],
        ),
        child:
            isSelected
                ? const Icon(Icons.check, color: Colors.white, size: 24)
                : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF2B2B2B),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ヘッダー
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '色ラベルを選択',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: Colors.white),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // カラーパレット（2行5列のグリッド）
            Column(
              children: [
                for (int row = 0; row < 2; row++)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        for (int col = 0; col < 5; col++)
                          if (row * 5 + col <
                              ColorUtils.colorLabelPalette.length)
                            _buildEnhancedColorOption(
                              context,
                              ColorUtils.colorLabelPalette[row * 5 + col],
                              selectedColorHex,
                              onColorSelected,
                            ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
