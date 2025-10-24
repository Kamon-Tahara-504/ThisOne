import 'package:flutter/material.dart';
import '../../gradients.dart';
import '../../models/task.dart';

class SortOverlay {
  OverlayEntry? _overlayEntry;
  final BuildContext context;
  final TaskSortOrder currentSortOrder;
  final Function(TaskSortOrder) onSortChanged;

  SortOverlay({
    required this.context,
    required this.currentSortOrder,
    required this.onSortChanged,
  });

  void dispose() {
    _closeOverlay();
  }

  void _closeOverlay() {
    if (_overlayEntry != null) {
      _overlayEntry!.remove();
      _overlayEntry = null;
    }
  }

  void toggle() {
    if (_overlayEntry != null) {
      // 既に表示されている場合は閉じる
      _closeOverlay();
    } else {
      // まだ表示されていない場合は開く
      _showSortOverlay();
    }
  }

  void _showSortOverlay() {
    // 既存のオーバーレイがあれば先に閉じる
    _closeOverlay();

    final overlay = Overlay.of(context);

    _overlayEntry = OverlayEntry(
      builder:
          (context) => GestureDetector(
            onTap: () => _closeOverlay(), // タップで閉じる
            behavior: HitTestBehavior.translucent,
            child: Stack(
              children: [
                // ポップアップ本体
                Positioned(
                  bottom: 120, // ナビゲーションバーより上に表示
                  right: 16,
                  child: GestureDetector(
                    onTap: () {}, // ポップアップ内のタップは伝播を止める
                    child: Material(
                      color: Colors.transparent,
                      child: Container(
                        width: 180,
                        decoration: BoxDecoration(
                          color: const Color(0xFF3A3A3A),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: _buildSortOptions(),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
    );

    overlay.insert(_overlayEntry!);
  }

  Widget _buildSortOptions() {
    return Container(
      width: 180,
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // ヘッダー
          Row(
            children: [
              Icon(Icons.sort, color: const Color(0xFFE85A3B), size: 16),
              const SizedBox(width: 6),
              ShaderMask(
                shaderCallback:
                    (bounds) => createHorizontalOrangeYellowGradient()
                        .createShader(bounds),
                child: const Text(
                  '並び替え',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // ソートオプション
          _buildSortOption(TaskSortOrder.createdAt, '作成順', Icons.access_time),
          const SizedBox(height: 8),
          _buildSortOption(TaskSortOrder.dueDate, '期限順', Icons.calendar_today),
          const SizedBox(height: 8),
          _buildSortOption(TaskSortOrder.priority, '優先度順', Icons.flag),
        ],
      ),
    );
  }

  Widget _buildSortOption(
    TaskSortOrder sortOrder,
    String label,
    IconData icon,
  ) {
    final isSelected = currentSortOrder == sortOrder;

    return GestureDetector(
      onTap: () {
        onSortChanged(sortOrder);
        _closeOverlay();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? const Color(0xFFE85A3B).withValues(alpha: 0.15)
                  : const Color(0xFF2B2B2B),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color:
                isSelected
                    ? const Color(0xFFE85A3B).withValues(alpha: 0.5)
                    : Colors.grey[700]!,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? const Color(0xFFE85A3B) : Colors.grey[400],
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.grey[300],
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
            if (isSelected)
              Icon(Icons.check, size: 16, color: const Color(0xFFE85A3B)),
          ],
        ),
      ),
    );
  }
}
