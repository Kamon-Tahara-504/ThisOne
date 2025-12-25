import 'package:flutter/material.dart';
import '../../models/memo.dart';
import '../../services/main_data_service.dart';
import '../../utils/error_handler.dart';
import 'memo_edit_form_header.dart';
import 'memo_mode_selector.dart';
import 'memo_color_selector.dart';
import 'memo_edit_submit_button.dart';

class MemoEditDialog extends StatefulWidget {
  final Memo memo;
  final VoidCallback onMemoUpdated;
  final MainDataService dataService;

  const MemoEditDialog({
    super.key,
    required this.memo,
    required this.onMemoUpdated,
    required this.dataService,
  });

  @override
  State<MemoEditDialog> createState() => _MemoEditDialogState();
}

class _MemoEditDialogState extends State<MemoEditDialog> {
  late MemoMode _selectedMode;
  late String _selectedColorHex;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _selectedMode = widget.memo.mode;
    _selectedColorHex = widget.memo.colorTag;
  }

  Future<void> _saveMemoSettings() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final updatedMemo = widget.memo.copyWith(
        mode: _selectedMode,
        colorTag: _selectedColorHex,
      );

      await widget.dataService.updateMemo(updatedMemo);

      if (mounted) {
        Navigator.pop(context);
        widget.onMemoUpdated();
        AppErrorHandler.showSuccess(context, 'メモ設定を更新しました');
      }
    } catch (e) {
      if (mounted) {
        AppErrorHandler.handleError(context, e, operation: '設定の更新');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
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
                MemoEditFormHeader(onClose: () => Navigator.pop(context)),

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
                          // モード選択
                          MemoModeSelector(
                            selectedMode: _selectedMode,
                            onModeChanged: (mode) {
                              setState(() {
                                _selectedMode = mode;
                              });
                            },
                          ),
                          const SizedBox(height: 32),

                          // 色選択
                          MemoColorSelector(
                            selectedColorHex: _selectedColorHex,
                            onColorSelected: (colorHex) {
                              setState(() {
                                _selectedColorHex = colorHex;
                              });
                            },
                          ),
                          const SizedBox(height: 24),

                          // 保存ボタン
                          MemoEditSubmitButton(
                            onPressed: _saveMemoSettings,
                            isLoading: _isLoading,
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
