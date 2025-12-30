import 'package:flutter/material.dart';
import '../../services/main_data_service.dart';
import '../../gradients.dart';
import '../../widgets/memo/memo_item_card.dart';
import '../../widgets/memo/memo_filter.dart';
import '../../widgets/memo/empty_memo_state.dart';
import '../../widgets/memo/color_filter_bottom_sheet.dart';
import '../../widgets/memo/memo_edit_dialog.dart';
import '../../utils/error_handler.dart';
import '../../models/memo.dart';
import '../../widgets/overlays/memo_sort_overlay.dart';
import '../../widgets/common/count_badge.dart';
import 'memo_detail_screen.dart';

class MemoScreen extends StatefulWidget {
  final List<Memo> memos; // 型安全なMemoモデルに変更
  final Function(List<Memo>) onMemosChanged; // 型安全なコールバックに変更
  final MainDataService dataService;
  final String? newlyCreatedMemoId; // 新しく作成されたメモのID
  final VoidCallback? onPopAnimationComplete; // ポップアニメーション完了時のコールバック
  final ScrollController? scrollController;

  const MemoScreen({
    super.key,
    required this.memos,
    required this.onMemosChanged,
    required this.dataService,
    this.newlyCreatedMemoId,
    this.onPopAnimationComplete,
    this.scrollController,
  });

  @override
  State<MemoScreen> createState() => _MemoScreenState();
}

class _MemoScreenState extends State<MemoScreen> with TickerProviderStateMixin {
  late AnimationController _popAnimationController;
  late Animation<double> _popAnimation;
  String? _animatingMemoId; // アニメーション中のメモID
  MemoSortOverlay? _sortOverlay;

  // 型安全なフィルター管理
  MemoFilter _currentFilter = const MemoFilter(
    sortOrder: MemoSortOrder.pinnedFirst,
  );

  @override
  void initState() {
    super.initState();

    // ポップアニメーションコントローラー
    _popAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _popAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _popAnimationController,
        curve: Curves.elasticOut,
      ),
    );

    // アニメーション完了時のリスナー
    _popAnimationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _animatingMemoId = null;
        });
        widget.onPopAnimationComplete?.call();
      }
    });
  }

  @override
  void dispose() {
    _sortOverlay?.dispose();
    _popAnimationController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(MemoScreen oldWidget) {
    super.didUpdateWidget(oldWidget);

    // 新しいメモが作成された場合にアニメーションを開始
    if (widget.newlyCreatedMemoId != null &&
        widget.newlyCreatedMemoId != oldWidget.newlyCreatedMemoId) {
      _startPopAnimation(widget.newlyCreatedMemoId!);
    }
  }

  void _startPopAnimation(String memoId) {
    setState(() {
      _animatingMemoId = memoId;
    });
    _popAnimationController.forward(from: 0.0);
  }

  // フィルタリングされたメモを取得（型安全版）
  List<Memo> get _filteredMemos {
    final filtered = widget.memos.where(_currentFilter.matches).toList();
    return filtered.applySort(_currentFilter.sortOrder);
  }

  // 色フィルタリングを設定
  void _setColorFilter(String? colorHex) {
    setState(() {
      _currentFilter = MemoFilter(
        colorTag: colorHex,
        sortOrder: _currentFilter.sortOrder,
      );
    });
  }

  // 色フィルタリングをクリア
  void _clearColorFilter() {
    setState(() {
      _currentFilter = const MemoFilter(sortOrder: MemoSortOrder.pinnedFirst);
    });
  }

  // 色フィルタリングBottomSheetを表示
  void _showColorFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder:
          (context) => ColorFilterBottomSheet(
            selectedColorFilter: _currentFilter.colorTag,
            onColorSelected: _setColorFilter,
          ),
    );
  }

  // 並び替えオーバーレイを表示
  void _showSortOverlay() {
    _sortOverlay?.dispose();
    _sortOverlay = MemoSortOverlay(
      context: context,
      currentSortOrder: _currentFilter.sortOrder,
      onSortChanged: (sortOrder) {
        setState(() {
          _currentFilter = MemoFilter(
            mode: _currentFilter.mode,
            colorTag: _currentFilter.colorTag,
            isPinned: _currentFilter.isPinned,
            searchQuery: _currentFilter.searchQuery,
            sortOrder: sortOrder,
          );
        });
      },
    );
    _sortOverlay!.toggle();
  }

  // メモを再読み込み（ローカルデータベース）
  Future<void> _loadMemos() async {
    try {
      await widget.dataService.loadMemos();
      widget.onMemosChanged(widget.dataService.memos);
    } catch (e) {
      if (mounted) {
        AppErrorHandler.handleError(
          context,
          e,
          operation: 'メモの読み込み',
          onRetry: _loadMemos,
        );
      }
    }
  }

  void _openMemoDetail(Memo memo) async {
    final result = await Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder:
            (context, animation, secondaryAnimation) => MemoDetailScreen(
              memo: memo, // 型安全なMemoオブジェクトを渡す
              dataService: widget.dataService,
            ),
        transitionDuration: const Duration(milliseconds: 300),
        reverseTransitionDuration: const Duration(milliseconds: 300),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          // より現代的なスケール＆フェードアニメーション
          return FadeTransition(
            opacity: animation.drive(
              Tween<double>(
                begin: 0.0,
                end: 1.0,
              ).chain(CurveTween(curve: Curves.easeOutCubic)),
            ),
            child: ScaleTransition(
              scale: animation.drive(
                Tween<double>(
                  begin: 0.8,
                  end: 1.0,
                ).chain(CurveTween(curve: Curves.easeOutBack)),
              ),
              child: child,
            ),
          );
        },
      ),
    );

    // 詳細画面から戻った時にメモリストを再読み込み
    if (result == true) {
      _loadMemos();
    }
  }

  void _deleteMemo(Memo memo) async {
    // 削除確認ダイアログ
    final shouldDelete =
        await showDialog<bool>(
          context: context,
          builder:
              (context) => AlertDialog(
                backgroundColor: const Color(0xFF2B2B2B),
                title: const Text(
                  'メモを削除',
                  style: TextStyle(color: Colors.white),
                ),
                content: Text(
                  '「${memo.title}」を削除しますか？\nこの操作は取り消せません。',
                  style: TextStyle(color: Colors.grey[300]),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: Text(
                      'キャンセル',
                      style: TextStyle(color: Colors.grey[400]),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.red[400]!, Colors.red[600]!],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text(
                        '削除',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
        ) ??
        false;

    if (shouldDelete) {
      try {
        await widget.dataService.deleteMemo(memo.id);
        await _loadMemos(); // リストを再読み込み
      } catch (e) {
        if (mounted) {
          AppErrorHandler.handleError(
            context,
            e,
            operation: 'メモの削除',
            onRetry: () => _deleteMemo(memo),
          );
        }
      }
    }
  }

  // ピン留め状態を切り替え（型安全版）
  void _togglePin(Memo memo) async {
    final newPinStatus = !memo.isPinned;

    try {
      await widget.dataService.toggleMemoPin(
        memoId: memo.id,
        isPinned: newPinStatus,
      );

      // 成功した場合はリストを再読み込み
      await _loadMemos();
    } catch (e) {
      if (mounted) {
        AppErrorHandler.handleError(
          context,
          e,
          operation: 'ピン留めの更新',
          onRetry: () => _togglePin(memo),
        );
      }
    }
  }

  // メモ編集ダイアログを表示
  void _editMemo(Memo memo) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.7),
      builder:
          (context) => MemoEditDialog(
            memo: memo,
            onMemoUpdated: _loadMemos,
            dataService: widget.dataService,
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredMemos = _filteredMemos;

    return Scaffold(
      backgroundColor: const Color(0xFF2B2B2B),
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          // メモリスト（全体に表示）
          filteredMemos.isEmpty
              ? EmptyMemoState(hasColorFilter: _currentFilter.hasFilter)
              : RefreshIndicator(
                color: const Color(0xFFE85A3B),
                backgroundColor: const Color(0xFF2B2B2B),
                onRefresh: _loadMemos,
                child: ListView.builder(
                  controller: widget.scrollController,
                  padding: const EdgeInsets.only(
                    top: 12,
                    left: 16,
                    right: 16,
                    bottom: 16,
                  ),
                  itemCount: filteredMemos.length,
                  itemBuilder: (context, index) {
                    final memo = filteredMemos[index];
                    return MemoItemCard(
                      memo: memo,
                      isAnimating: _animatingMemoId == memo.id,
                      popAnimation: _popAnimation,
                      onTap: () => _openMemoDetail(memo),
                      onTogglePin: () => _togglePin(memo),
                      onDelete: () => _deleteMemo(memo),
                      onEditMemo: () => _editMemo(memo),
                    );
                  },
                ),
              ),
          // メモ数表示（左下）
          CountBadge(count: filteredMemos.length, icon: Icons.description),
          // 色フィルタリングボタン（sortボタンの上）
          Positioned(
            bottom: 80, // sortボタン（56px）+ 間隔（16px）+ マージン（8px）
            right: 16,
            child: MemoFilterWidget(
              selectedColorFilter: _currentFilter.colorTag,
              onShowColorFilterBottomSheet: _showColorFilterBottomSheet,
              onClearColorFilter: _clearColorFilter,
            ),
          ),
          // sortボタン（右下）
          Positioned(
            bottom: 16,
            right: 16,
            child: Container(
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
                  onTap: _showSortOverlay,
                  customBorder: const CircleBorder(),
                  child: const Center(
                    child: Icon(Icons.sort, color: Color(0xFF2B2B2B), size: 24),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
