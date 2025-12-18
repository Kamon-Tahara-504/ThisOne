import 'package:flutter/material.dart';
import '../../gradients.dart';
import '../../services/main_data_service.dart';
import '../../utils/error_handler.dart';
import '../../models/task.dart';
import '../../widgets/task/task_card.dart';
import '../../widgets/overlays/sort_overlay.dart';

class TaskScreen extends StatefulWidget {
  final List<Task>? tasks; // 型安全なTaskモデルに変更
  final MainDataService dataService;
  final ScrollController? scrollController;
  final String? newlyCreatedTaskId;
  final VoidCallback? onPopAnimationComplete;

  const TaskScreen({
    super.key,
    this.tasks,
    required this.dataService,
    this.scrollController,
    this.newlyCreatedTaskId,
    this.onPopAnimationComplete,
  });

  @override
  State<TaskScreen> createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> with TickerProviderStateMixin {
  late List<Task> _tasks; // 型安全なTaskモデルに変更
  TaskSortOrder _currentSortOrder = TaskSortOrder.createdAt;
  SortOverlay? _sortOverlay;
  late AnimationController _popAnimationController;
  late Animation<double> _popAnimation;
  String? _animatingTaskId;

  @override
  void initState() {
    super.initState();
    _tasks = widget.tasks != null ? List.from(widget.tasks!) : [];

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
          _animatingTaskId = null;
        });
        widget.onPopAnimationComplete?.call();
      }
    });
  }

  @override
  void didUpdateWidget(TaskScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.tasks != null) {
      _tasks = List.from(widget.tasks!);
      setState(() {
        // ソート順を適用
        _applySorting();
      });
    }

    // 新しいタスクが作成された場合にアニメーションを開始
    if (widget.newlyCreatedTaskId != null &&
        widget.newlyCreatedTaskId != oldWidget.newlyCreatedTaskId) {
      _startPopAnimation(widget.newlyCreatedTaskId!);
    }
  }

  @override
  void dispose() {
    _sortOverlay?.dispose();
    _popAnimationController.dispose();
    super.dispose();
  }

  void _startPopAnimation(String taskId) {
    setState(() {
      _animatingTaskId = taskId;
    });
    _popAnimationController.forward(from: 0.0);
  }

  void _applySorting() {
    _tasks = _tasks.applySort(_currentSortOrder);
  }

  Future<void> _toggleTask(int index) async {
    final task = _tasks[index];
    final newCompletionStatus = !task.isCompleted;

    try {
      // データベース（ローカル）を更新
      await widget.dataService.toggleTaskCompletion(
        taskId: task.id,
        isCompleted: newCompletionStatus,
      );

      // 最新状態を同期
      if (mounted) {
        setState(() {
          _tasks = List<Task>.from(widget.dataService.tasks);
          _applySorting();
        });
      }
    } catch (e) {
      if (mounted) {
        AppErrorHandler.handleError(
          context,
          e,
          operation: 'タスクの完了状態更新',
          onRetry: () => _toggleTask(index),
        );
      }
    }
  }

  Future<void> _deleteTask(int index) async {
    final task = _tasks[index];

    try {
      // データベース（ローカル）から削除
      await widget.dataService.deleteTask(task.id);

      if (mounted) {
        setState(() {
          _tasks = List<Task>.from(widget.dataService.tasks);
          _applySorting();
        });
      }
    } catch (e) {
      if (mounted) {
        AppErrorHandler.handleError(
          context,
          e,
          operation: 'タスクの削除',
          onRetry: () => _deleteTask(index),
        );
      }
    }
  }

  void _showSortOverlay() {
    _sortOverlay?.dispose();
    _sortOverlay = SortOverlay(
      context: context,
      currentSortOrder: _currentSortOrder,
      onSortChanged: (sortOrder) {
        setState(() {
          _currentSortOrder = sortOrder;
          _applySorting();
        });
      },
    );
    _sortOverlay!.toggle();
  }

  @override
  Widget build(BuildContext context) {
    // ソート済みのタスクリストを取得
    final sortedTasks = _tasks.applySort(_currentSortOrder);

    return Scaffold(
      backgroundColor: const Color(0xFF2B2B2B),
      resizeToAvoidBottomInset: false,
      body: Column(
        children: [
          // タスクリスト
          Expanded(
            child:
                sortedTasks.isEmpty
                    ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ShaderMask(
                            shaderCallback:
                                (bounds) => createOrangeYellowGradient()
                                    .createShader(bounds),
                            child: const Icon(
                              Icons.task_alt,
                              size: 64,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'タスクがありません',
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '下部の + ボタンから新しいタスクを追加してください',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    )
                    : ListView.builder(
                      controller: widget.scrollController,
                      padding: const EdgeInsets.all(16),
                      itemCount: sortedTasks.length,
                      itemBuilder: (context, index) {
                        final task = sortedTasks[index];
                        final originalIndex = _tasks.indexOf(task);
                        final isAnimating = _animatingTaskId == task.id;
                        return TaskCard(
                          task: task,
                          onToggleComplete: () => _toggleTask(originalIndex),
                          onDelete: () => _deleteTask(originalIndex),
                          isAnimating: isAnimating,
                          popAnimation: isAnimating ? _popAnimation : null,
                        );
                      },
                    ),
          ),
        ],
      ),
      floatingActionButton: Container(
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
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
