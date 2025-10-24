import 'package:flutter/material.dart';
import '../../gradients.dart';
import '../../services/supabase_service.dart';
import '../../utils/error_handler.dart';
import '../../models/task.dart';
import '../../widgets/task/task_card.dart';
import '../../widgets/overlays/sort_overlay.dart';

class TaskScreen extends StatefulWidget {
  final List<Task>? tasks; // 型安全なTaskモデルに変更
  final Function(List<Task>)? onTasksChanged; // 型安全なコールバックに変更
  final ScrollController? scrollController;

  const TaskScreen({
    super.key,
    this.tasks,
    this.onTasksChanged,
    this.scrollController,
  });

  @override
  State<TaskScreen> createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
  late List<Task> _tasks; // 型安全なTaskモデルに変更
  final SupabaseService _supabaseService = SupabaseService();
  TaskSortOrder _currentSortOrder = TaskSortOrder.createdAt;
  SortOverlay? _sortOverlay;

  @override
  void initState() {
    super.initState();
    _tasks = widget.tasks != null ? List.from(widget.tasks!) : [];
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
  }

  @override
  void dispose() {
    _sortOverlay?.dispose();
    super.dispose();
  }

  void _applySorting() {
    _tasks = _tasks.applySort(_currentSortOrder);
  }

  Future<void> _toggleTask(int index) async {
    final task = _tasks[index];
    final newCompletionStatus = !task.isCompleted;

    try {
      // データベースを更新
      await _supabaseService.updateTaskCompletionTyped(
        taskId: task.id,
        isCompleted: newCompletionStatus,
      );

      // ローカルの状態を更新
      setState(() {
        _tasks[index] = task.copyWith(
          isCompleted: newCompletionStatus,
          completedAt: newCompletionStatus ? DateTime.now() : null,
        );
      });

      _notifyTasksChanged();
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
      // データベースから削除
      await _supabaseService.deleteTaskTyped(task.id);

      setState(() {
        _tasks.removeAt(index);
      });
      _notifyTasksChanged();
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

  void _notifyTasksChanged() {
    if (widget.onTasksChanged != null) {
      widget.onTasksChanged!(_tasks);
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
                        return TaskCard(
                          task: task,
                          onToggleComplete: () => _toggleTask(originalIndex),
                          onDelete: () => _deleteTask(originalIndex),
                        );
                      },
                    ),
          ),
        ],
      ),
      floatingActionButton:
          sortedTasks.isNotEmpty
              ? Container(
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
                      child: Icon(
                        Icons.sort,
                        color: Color(0xFF2B2B2B),
                        size: 24,
                      ),
                    ),
                  ),
                ),
              )
              : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
