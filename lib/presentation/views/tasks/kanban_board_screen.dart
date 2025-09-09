// lib/presentation/views/tasks/kanban_board_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/task_viewmodel.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/error_widget.dart';
import '../../widgets/task/kanban_column.dart';
import '../../../routes/app_routes.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/enums/task_status.dart';
import '../../../core/utils/app_utils.dart';

class KanbanBoardScreen extends StatefulWidget {
  final String? projectId;

  const KanbanBoardScreen({Key? key, this.projectId}) : super(key: key);

  @override
  State<KanbanBoardScreen> createState() => _KanbanBoardScreenState();
}

class _KanbanBoardScreenState extends State<KanbanBoardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    final taskViewModel = context.read<TaskViewModel>();
    await Future.wait([
      taskViewModel.loadTasks(projectId: widget.projectId),
      taskViewModel.loadUsers(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.projectId != null ? 'Project Kanban' : 'All Tasks Kanban'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pushNamed(
                context,
                AppRoutes.tasks,
                arguments: widget.projectId,
              );
            },
            icon: const Icon(Icons.list_rounded),
          ),
          IconButton(
            onPressed: _loadData,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: Consumer<TaskViewModel>(
        builder: (context, taskViewModel, child) {
          if (taskViewModel.isLoading) {
            return const LoadingWidget(message: 'Loading kanban board...');
          }

          if (taskViewModel.errorMessage != null) {
            return CustomErrorWidget(
              message: taskViewModel.errorMessage!,
              onRetry: _loadData,
            );
          }

          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: TaskStatus.values.map((status) {
                final tasks = taskViewModel.getTasksByStatus(status);
                return Container(
                  width: 300,
                  margin: const EdgeInsets.only(right: 16),
                  child: KanbanColumn(
                    title: status.displayName,
                    status: status,
                    tasks: tasks,
                    onTaskTap: (task) {
                      Navigator.pushNamed(
                        context,
                        AppRoutes.taskDetail,
                        arguments: task.id,
                      );
                    },
                    onTaskMoved: (task, newStatus) async {
                      final success = await taskViewModel.updateTaskStatus(task.id, newStatus);
                      if (success) {
                        AppUtils.showSuccessSnackBar(
                          context,
                          'Task moved to ${newStatus.displayName}',
                        );
                      } else {
                        AppUtils.showErrorSnackBar(
                          context,
                          taskViewModel.errorMessage ?? 'Failed to move task',
                        );
                      }
                    },
                    onAddTask: widget.projectId != null ? () {
                      Navigator.pushNamed(
                        context,
                        AppRoutes.createTask,
                        arguments: widget.projectId,
                      );
                    } : null,
                  ),
                );
              }).toList(),
            ),
          );
        },
      ),
    );
  }
}

// lib/presentation/widgets/task/kanban_column.dart

import 'package:flutter/material.dart';
import '../../../data/models/task_model.dart';
import '../../../core/enums/task_status.dart';
import '../../../core/constants/app_colors.dart';
import '../task/task_card.dart';

class KanbanColumn extends StatelessWidget {
  final String title;
  final TaskStatus status;
  final List<TaskModel> tasks;
  final Function(TaskModel) onTaskTap;
  final Function(TaskModel, TaskStatus) onTaskMoved;
  final VoidCallback? onAddTask;

  const KanbanColumn({
    Key? key,
    required this.title,
    required this.status,
    required this.tasks,
    required this.onTaskTap,
    required this.onTaskMoved,
    this.onAddTask,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _getStatusColor(status).withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _getStatusColor(status).withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Column Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _getStatusColor(status).withOpacity(0.1),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: _getStatusColor(status),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: _getStatusColor(status),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(status).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    tasks.length.toString(),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: _getStatusColor(status),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Tasks List
          Expanded(
            child: DragTarget<TaskModel>(
              onAccept: (task) {
                if (task.status != status) {
                  onTaskMoved(task, status);
                }
              },
              builder: (context, candidateData, rejectedData) {
                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: candidateData.isNotEmpty
                        ? _getStatusColor(status).withOpacity(0.1)
                        : Colors.transparent,
                    borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
                  ),
                  child: tasks.isEmpty
                      ? _buildEmptyState()
                      : Column(
                          children: [
                            ...tasks.map((task) => _buildDraggableTask(task)),
                            if (onAddTask != null) ...[
                              const SizedBox(height: 8),
                              _buildAddTaskButton(),
                            ],
                          ],
                        ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDraggableTask(TaskModel task) {
    return Draggable<TaskModel>(
      data: task,
      feedback: Material(
        elevation: 8,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 280,
          child: TaskCard(
            task: task,
            showProject: true,
          ),
        ),
      ),
      childWhenDragging: Opacity(
        opacity: 0.5,
        child: TaskCard(
          task: task,
          onTap: () => onTaskTap(task),
          showProject: true,
        ),
      ),
      child: TaskCard(
        task: task,
        onTap: () => onTaskTap(task),
        showProject: true,
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      height: 120,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _getStatusIcon(status),
            size: 32,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 8),
          Text(
            'No ${title.toLowerCase()} tasks',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
          if (onAddTask != null && status == TaskStatus.toDo) ...[
            const SizedBox(height: 8),
            _buildAddTaskButton(),
          ],
        ],
      ),
    );
  }

  Widget _buildAddTaskButton() {
    return OutlinedButton.icon(
      onPressed: onAddTask,
      icon: const Icon(Icons.add, size: 16),
      label: const Text(
        'Add Task',
        style: TextStyle(fontSize: 12),
      ),
      style: OutlinedButton.styleFrom(
        foregroundColor: _getStatusColor(status),
        side: BorderSide(color: _getStatusColor(status).withOpacity(0.5)),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        minimumSize: const Size(0, 0),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }

  Color _getStatusColor(TaskStatus status) {
    switch (status) {
      case TaskStatus.toDo:
        return AppColors.statusToDo;
      case TaskStatus.inProgress:
        return AppColors.statusInProgress;
      case TaskStatus.inReview:
        return AppColors.statusInReview;
      case TaskStatus.done:
        return AppColors.statusDone;
    }
  }

  IconData _getStatusIcon(TaskStatus status) {
    switch (status) {
      case TaskStatus.toDo:
        return Icons.radio_button_unchecked_rounded;
      case TaskStatus.inProgress:
        return Icons.play_circle_outline_rounded;
      case TaskStatus.inReview:
        return Icons.rate_review_rounded;
      case TaskStatus.done:
        return Icons.check_circle_outline_rounded;
    }
  }
}