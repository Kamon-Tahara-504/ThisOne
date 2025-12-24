import 'package:flutter/material.dart';
import '../../utils/color_utils.dart';

class ScheduleBasicSettings extends StatelessWidget {
  final TextEditingController titleController;
  final TextEditingController descriptionController;
  final String selectedColorHex;
  final ValueChanged<String> onColorChanged;

  const ScheduleBasicSettings({
    super.key,
    required this.titleController,
    required this.descriptionController,
    required this.selectedColorHex,
    required this.onColorChanged,
  });

  Widget _buildColorOption(Map<String, dynamic> colorOption) {
    final isSelected = selectedColorHex == colorOption['hex'];
    final colorHex = colorOption['hex'] as String;
    final isGradient = colorOption['isGradient'] as bool;

    return GestureDetector(
      onTap: () => onColorChanged(colorHex),
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          gradient: isGradient ? ColorUtils.getGradientFromHex(colorHex) : null,
          color: isGradient ? null : ColorUtils.getColorFromHex(colorHex),
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? Colors.white : Colors.transparent,
            width: 3,
          ),
          boxShadow: null,
        ),
        child:
            isSelected
                ? const Icon(Icons.check, color: Colors.white, size: 14)
                : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // タイトル入力
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'タイトル',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF3A3A3A),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[600]!),
              ),
              child: TextField(
                controller: titleController,
                style: const TextStyle(color: Colors.white, fontSize: 16),
                decoration: const InputDecoration(
                  hintText: 'スケジュールのタイトルを入力...',
                  hintStyle: TextStyle(color: Colors.grey),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(16),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // 説明入力
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '説明',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF3A3A3A),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[600]!),
              ),
              child: TextField(
                controller: descriptionController,
                style: const TextStyle(color: Colors.white, fontSize: 16),
                maxLines: 2,
                decoration: const InputDecoration(
                  hintText: '詳細な説明を入力...',
                  hintStyle: TextStyle(color: Colors.grey),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(12),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // 色設定
        Column(
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
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF3A3A3A),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[600]!),
              ),
              child: Container(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // カラーパレット（横スクロール一列）
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          const SizedBox(width: 8), // 左端の余白
                          for (
                            int i = 0;
                            i < ColorUtils.colorLabelPalette.length;
                            i++
                          ) ...[
                            _buildColorOption(ColorUtils.colorLabelPalette[i]),
                            if (i < ColorUtils.colorLabelPalette.length - 1)
                              const SizedBox(width: 12), // アイテム間の間隔
                          ],
                          const SizedBox(width: 8), // 右端の余白
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
