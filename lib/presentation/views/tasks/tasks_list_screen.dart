
// =================================================================

// lib/presentation/views/tasks/tasks_list_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/task_viewmodel.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../widgets/common/custom_app_bar.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/error_widget.dart';
import '../../widgets/task/task_card.dart';
import '../../../routes/app_routes.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/enums/task_status.dart';
import '../../../core/enums/task_priority.dart';
import '../../../core/utils/app_utils.dart';

class TasksListScreen extends StatefulWidget {
  final String? projectId;

  const TasksListScreen({Key? key, this.projectId}) : super(key: key);

  @override
  State<TasksListScreen> createState() => _TasksListScreenState();
}

class _TasksListScreenState extends State<TasksListScreen> {
  String _searchQuery = '';
  TaskStatus? _filterStatus;
  TaskPriority? _filterPriority;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadTasks();
    });
  }

  Future<void> _loadTasks() async {
    final taskViewModel = context.read<TaskViewModel>();
    await Future.wait([
      taskViewModel.loadTasks(projectId: widget.projectId),
      taskViewModel.loadProjects(),
      taskViewModel.loadUsers(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: widget.projectId != null ? 'Project Tasks' : 'All Tasks',
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pushNamed(
                context,
                AppRoutes.kanbanBoard,
                arguments: widget.projectId,
              );
            },
            icon: const Icon(Icons.view_kanban_rounded),
          ),
          IconButton(
            onPressed: _showFilterDialog,
            icon: const Icon(Icons.filter_list_rounded),
          ),
          IconButton(
            onPressed: _loadTasks,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search tasks...',
                prefixIcon: const Icon(Icons.search_rounded),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),

          // Filter Chips
          if (_filterStatus != null || _filterPriority != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              height: 40,
              child: Row(
                children: [
                  if (_filterStatus != null)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Chip(
                        label: Text(_filterStatus!.displayName),
                        deleteIcon: const Icon(Icons.close, size: 18),
                        onDeleted: () {
                          setState(() {
                            _filterStatus = null;
                          });
                        },
                      ),
                    ),
                  if (_filterPriority != null)
                    Chip(
                      label: Text(_filterPriority!.displayName),
                      deleteIcon: const Icon(Icons.close, size: 18),
                      onDeleted: () {
                        setState(() {
                          _filterPriority = null;
                        });
                      },
                    ),
                ],
              ),
            ),

          // Tasks List
          Expanded(
            child: Consumer<TaskViewModel>(
              builder: (context, taskViewModel, child) {
                if (taskViewModel.isLoading) {
                  return const LoadingWidget(message: 'Loading tasks...');
                }

                if (taskViewModel.errorMessage != null) {
                  return CustomErrorWidget(
                    message: taskViewModel.errorMessage!,
                    onRetry: _loadTasks,
                  );
                }

                var tasks = taskViewModel.tasks;

                // Apply project filter if specified
                if (widget.projectId != null) {
                  tasks = tasks.where((t) => t.projectId == widget.projectId).toList();
                }

                // Apply search filter
                if (_searchQuery.isNotEmpty) {
                  tasks = taskViewModel.searchTasks(_searchQuery);
                }

                // Apply status filter
                if (_filterStatus != null) {
                  tasks = tasks.where((t) => t.status == _filterStatus).toList();
                }

                // Apply priority filter
                if (_filterPriority != null) {
                  tasks = tasks.where((t) => t.priority == _filterPriority).toList();
                }

                if (tasks.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.task_alt_rounded,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _searchQuery.isNotEmpty || _filterStatus != null || _filterPriority != null
                              ? 'No tasks found'
                              : 'No tasks yet',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                          ),
                        ),
                        if (_searchQuery.isEmpty && _filterStatus == null && _filterPriority == null) ...[
                          const SizedBox(height: 8),
                          Text(
                            'Create your first task to get started',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: _loadTasks,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: tasks.length,
                    itemBuilder: (context, index) {
                      final task = tasks[index];
                      return TaskCard(
                        task: task,
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            AppRoutes.taskDetail,
                            arguments: task.id,
                          );
                        },
                        showProject: widget.projectId == null,
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(
            context,
            AppRoutes.createTask,
            arguments: widget.projectId,
          );
        },
        backgroundColor: AppColors.primaryBlue,
        child: const Icon(Icons.add_task, color: Colors.white),
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Tasks'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Filter by status:'),
              const SizedBox(height: 8),
              ...TaskStatus.values.map((status) {
                return RadioListTile<TaskStatus?>(
                  title: Text(status.displayName),
                  value: status,
                  groupValue: _filterStatus,
                  onChanged: (value) {
                    setState(() {
                      _filterStatus = value;
                    });
                  },
                );
              }),
              RadioListTile<TaskStatus?>(
                title: const Text('Any Status'),
                value: null,
                groupValue: _filterStatus,
                onChanged: (value) {
                  setState(() {
                    _filterStatus = null;
                  });
                },
              ),
              const SizedBox(height: 16),
              const Text('Filter by priority:'),
              const SizedBox(height: 8),
              ...TaskPriority.values.map((priority) {
                return RadioListTile<TaskPriority?>(
                  title: Text(priority.displayName),
                  value: priority,
                  groupValue: _filterPriority,
                  onChanged: (value) {
                    setState(() {
                      _filterPriority = value;
                    });
                  },
                );
              }),
              RadioListTile<TaskPriority?>(
                title: const Text('Any Priority'),
                value: null,
                groupValue: _filterPriority,
                onChanged: (value) {
                  setState(() {
                    _filterPriority = null;
                  });
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }
}
