import 'package:flutter/material.dart';
import '../../widgets/color_palette.dart';

class ColorFilterBottomSheet extends StatelessWidget {
  final String? selectedColorFilter;
  final Function(String?) onColorSelected;

  const ColorFilterBottomSheet({
    super.key,
    required this.selectedColorFilter,
    required this.onColorSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Color(0xFF2B2B2B),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.palette, color: Colors.white, size: 24),
              const SizedBox(width: 12),
              const Text(
                '色でメモを検索',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              if (selectedColorFilter != null)
                TextButton(
                  onPressed: () {
                    onColorSelected(null);
                    Navigator.pop(context);
                  },
                  child: const Text(
                    'すべて表示',
                    style: TextStyle(color: Color(0xFFE85A3B), fontSize: 14),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            '表示したいメモの色を選択してください',
            style: TextStyle(color: Colors.grey[400], fontSize: 14),
          ),
          const SizedBox(height: 24),
          // 色パレット
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF3A3A3A),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[600]!),
            ),
            padding: const EdgeInsets.all(16),
            child: ColorPalette(
              selectedColorHex: selectedColorFilter,
              onColorSelected: (colorHex) {
                onColorSelected(colorHex);
                Navigator.pop(context);
              },
              showCheckIcon: true,
              itemSize: 56.0,
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
