import 'package:flutter/material.dart';
import '../../utils/color_utils.dart';
import '../../utils/text_selection_menu_builder.dart';
import 'color_picker_bottom_sheet.dart';

class ScheduleBasicSettings extends StatelessWidget {
  final TextEditingController titleController;
  final TextEditingController descriptionController;
  final TextEditingController locationController;
  final String selectedColorHex;
  final ValueChanged<String> onColorChanged;

  const ScheduleBasicSettings({
    super.key,
    required this.titleController,
    required this.descriptionController,
    required this.locationController,
    required this.selectedColorHex,
    required this.onColorChanged,
  });

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
                contextMenuBuilder: nativeTextSelectionMenuBuilder,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // 場所入力
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '場所',
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
                controller: locationController,
                style: const TextStyle(color: Colors.white, fontSize: 16),
                decoration: const InputDecoration(
                  hintText: '場所を入力...',
                  hintStyle: TextStyle(color: Colors.grey),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(16),
                ),
                contextMenuBuilder: nativeTextSelectionMenuBuilder,
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
            GestureDetector(
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  backgroundColor: Colors.transparent,
                  builder:
                      (context) => ColorPickerBottomSheet(
                        selectedColorHex: selectedColorHex,
                        onColorSelected: onColorChanged,
                      ),
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF3A3A3A),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[600]!),
                ),
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    // 選択中の色のプレビュー
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        gradient:
                            ColorUtils.isGradientColor(selectedColorHex)
                                ? ColorUtils.getGradientFromHex(
                                  selectedColorHex,
                                )
                                : null,
                        color:
                            ColorUtils.isGradientColor(selectedColorHex)
                                ? null
                                : ColorUtils.getColorFromHex(selectedColorHex),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.3),
                          width: 2,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // ラベルテキスト
                    const Expanded(
                      child: Text(
                        '色ラベルを選択',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                    const Icon(Icons.chevron_right, color: Colors.grey),
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
