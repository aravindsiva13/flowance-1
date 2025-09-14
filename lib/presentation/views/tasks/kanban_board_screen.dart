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
