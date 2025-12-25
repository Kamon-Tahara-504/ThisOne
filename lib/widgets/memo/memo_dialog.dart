import 'package:flutter/material.dart';
import '../../gradients.dart';
import '../../utils/color_utils.dart';

class MemoDialog extends StatefulWidget {
  final Function(String, String, String) onMemoCreated;

  const MemoDialog({super.key, required this.onMemoCreated});

  @override
  State<MemoDialog> createState() => _MemoDialogState();
}

class _MemoDialogState extends State<MemoDialog> {
  late TextEditingController _titleController;
  String _selectedMode = 'memo';
  String _selectedColorHex = ColorUtils.defaultColorHex;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  // 色選択オプション（強化版）
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

  void _createMemo() async {
    final title =
        _titleController.text.trim().isNotEmpty
            ? _titleController.text.trim()
            : '無題';
    // Navigator.popはonMemoCreatedコールバック内で呼ばれるため、ここでは呼ばない
    await widget.onMemoCreated(title, _selectedMode, _selectedColorHex);
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final maxWidth = screenSize.width * 0.9;
    final maxHeight = screenSize.height * 0.85;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.zero,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth, maxHeight: maxHeight),
        child: SizedBox(
          width: maxWidth,
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF2B2B2B),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ヘッダー
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      ShaderMask(
                        shaderCallback:
                            (bounds) => createOrangeYellowGradient()
                                .createShader(bounds),
                        child: const Icon(
                          Icons.edit_note,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'メモを作成',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close, color: Colors.white),
                      ),
                    ],
                  ),
                ),

                // メインコンテンツ
                Flexible(
                  child: GestureDetector(
                    onTap: () {
                      // 入力欄以外をタップした時にキーボードを格納
                      FocusScope.of(context).unfocus();
                    },
                    behavior: HitTestBehavior.opaque,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                      child: Column(
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
                                  border: Border.all(
                                    color: Colors.grey[600]!,
                                    width: 1,
                                  ),
                                ),
                                child: TextField(
                                  controller: _titleController,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
                                  decoration: const InputDecoration(
                                    hintText: 'メモのタイトルを入力...',
                                    hintStyle: TextStyle(color: Colors.grey),
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.all(16),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 32),

                          // モード選択
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'メモの種類',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: GestureDetector(
                                      onTap:
                                          () => setState(
                                            () => _selectedMode = 'memo',
                                          ),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 12,
                                        ),
                                        decoration: BoxDecoration(
                                          gradient:
                                              _selectedMode == 'memo'
                                                  ? createHorizontalOrangeYellowGradient()
                                                  : null,
                                          color:
                                              _selectedMode == 'memo'
                                                  ? null
                                                  : const Color(0xFF3A3A3A),
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          border: Border.all(
                                            color:
                                                _selectedMode == 'memo'
                                                    ? Colors.transparent
                                                    : Colors.grey[600]!,
                                            width: 1,
                                          ),
                                        ),
                                        child: const Column(
                                          children: [
                                            Icon(
                                              Icons.edit_note,
                                              color: Colors.white,
                                              size: 24,
                                            ),
                                            SizedBox(height: 4),
                                            Text(
                                              'メモ',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: GestureDetector(
                                      onTap:
                                          () => setState(
                                            () => _selectedMode = 'calculator',
                                          ),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 12,
                                        ),
                                        decoration: BoxDecoration(
                                          gradient:
                                              _selectedMode == 'calculator'
                                                  ? createHorizontalOrangeYellowGradient()
                                                  : null,
                                          color:
                                              _selectedMode == 'calculator'
                                                  ? null
                                                  : const Color(0xFF3A3A3A),
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          border: Border.all(
                                            color:
                                                _selectedMode == 'calculator'
                                                    ? Colors.transparent
                                                    : Colors.grey[600]!,
                                            width: 1,
                                          ),
                                        ),
                                        child: const Column(
                                          children: [
                                            Icon(
                                              Icons.calculate,
                                              color: Colors.white,
                                              size: 24,
                                            ),
                                            SizedBox(height: 4),
                                            Text(
                                              '計算機',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 32),

                          // 色選択
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
                              const SizedBox(height: 16),
                              // カラーパレット（2行5列のグリッド）
                              Column(
                                children: [
                                  for (int row = 0; row < 2; row++)
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 8,
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          for (int col = 0; col < 5; col++)
                                            if (row * 5 + col <
                                                ColorUtils
                                                    .colorLabelPalette
                                                    .length)
                                              _buildEnhancedColorOption(
                                                ColorUtils
                                                    .colorLabelPalette[row * 5 +
                                                    col],
                                                _selectedColorHex,
                                                (colorHex) => setState(
                                                  () =>
                                                      _selectedColorHex =
                                                          colorHex,
                                                ),
                                              ),
                                        ],
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),

                          // 作成ボタン
                          Container(
                            width: double.infinity,
                            height: 56,
                            decoration: BoxDecoration(
                              gradient: createHorizontalOrangeYellowGradient(),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: ElevatedButton(
                              onPressed: _createMemo,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: const Text(
                                'メモを作成',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
