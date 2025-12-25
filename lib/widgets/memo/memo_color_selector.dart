import 'package:flutter/material.dart';
import '../../utils/color_utils.dart';

class MemoColorSelector extends StatelessWidget {
  final String selectedColorHex;
  final ValueChanged<String> onColorSelected;

  const MemoColorSelector({
    super.key,
    required this.selectedColorHex,
    required this.onColorSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '色ラベル',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF3A3A3A),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[600]!),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              for (int row = 0; row < 2; row++)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      for (int col = 0; col < 5; col++)
                        if (row * 5 + col < ColorUtils.colorLabelPalette.length)
                          _buildEnhancedColorOption(
                            ColorUtils.colorLabelPalette[row * 5 + col],
                            selectedColorHex,
                            onColorSelected,
                          ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEnhancedColorOption(
    Map<String, dynamic> colorItem,
    String selectedColorHex,
    Function(String) onColorSelected,
  ) {
    final colorHex = colorItem['hex'] as String;
    final isGradient = colorItem['isGradient'] as bool;
    final color = colorItem['color'] as Color?;
    final isSelected = selectedColorHex == colorHex;

    return GestureDetector(
      onTap: () => onColorSelected(colorHex),
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
}
