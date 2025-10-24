import 'package:flutter/material.dart';
import '../../gradients.dart';
import '../../services/supabase_service.dart';
import '../../utils/error_handler.dart';
import '../../models/task.dart';
import '../../widgets/task/task_card.dart';

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
    }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2B2B2B),
      body: Column(
        children: [
          // タスクリスト
          Expanded(
            child:
                _tasks.isEmpty
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
                      itemCount: _tasks.length,
                      itemBuilder: (context, index) {
                        final task = _tasks[index];
                        return TaskCard(
                          task: task,
                          onToggleComplete: () => _toggleTask(index),
                          onDelete: () => _deleteTask(index),
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }
}
