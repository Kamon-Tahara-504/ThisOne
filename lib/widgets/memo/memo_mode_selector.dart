import 'package:flutter/material.dart';
import '../../gradients.dart';
import '../../models/memo.dart';

class MemoModeSelector extends StatelessWidget {
  final MemoMode selectedMode;
  final ValueChanged<MemoMode> onModeChanged;

  const MemoModeSelector({
    super.key,
    required this.selectedMode,
    required this.onModeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
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
                onTap: () => onModeChanged(MemoMode.memo),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    gradient:
                        selectedMode == MemoMode.memo
                            ? createHorizontalOrangeYellowGradient()
                            : null,
                    color:
                        selectedMode == MemoMode.memo
                            ? null
                            : const Color(0xFF3A3A3A),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color:
                          selectedMode == MemoMode.memo
                              ? Colors.transparent
                              : Colors.grey[600]!,
                      width: 1,
                    ),
                  ),
                  child: const Column(
                    children: [
                      Icon(Icons.edit_note, color: Colors.white, size: 24),
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
                onTap: () => onModeChanged(MemoMode.calculator),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    gradient:
                        selectedMode == MemoMode.calculator
                            ? createHorizontalOrangeYellowGradient()
                            : null,
                    color:
                        selectedMode == MemoMode.calculator
                            ? null
                            : const Color(0xFF3A3A3A),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color:
                          selectedMode == MemoMode.calculator
                              ? Colors.transparent
                              : Colors.grey[600]!,
                      width: 1,
                    ),
                  ),
                  child: const Column(
                    children: [
                      Icon(Icons.calculate, color: Colors.white, size: 24),
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
    );
  }
}
