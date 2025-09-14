
// lib/presentation/views/projects/project_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/project_viewmodel.dart';
import '../../viewmodels/task_viewmodel.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../widgets/common/custom_app_bar.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/error_widget.dart';
import '../../widgets/project/project_progress_widget.dart';
import '../../widgets/task/task_card.dart';
import '../../../routes/app_routes.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/enums/project_status.dart';
import '../../../core/utils/date_utils.dart';
import '../../../core/utils/app_utils.dart';
import '../../../data/models/project_model.dart';

class ProjectDetailScreen extends StatefulWidget {
  final String projectId;

  const ProjectDetailScreen({Key? key, required this.projectId}) : super(key: key);

  @override
  State<ProjectDetailScreen> createState() => _ProjectDetailScreenState();
}

class _ProjectDetailScreenState extends State<ProjectDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  ProjectModel? _project;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final projectViewModel = context.read<ProjectViewModel>();
    final taskViewModel = context.read<TaskViewModel>();

    final project = await projectViewModel.getProject(widget.projectId);
    if (project != null) {
      setState(() {
        _project = project;
      });
    }

    await Future.wait([
      taskViewModel.loadTasks(projectId: widget.projectId),
      taskViewModel.loadUsers(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final authViewModel = context.watch<AuthViewModel>();
    final canEdit = _project != null && 
        authViewModel.canAccessProject(
          widget.projectId, 
          _project!.ownerId, 
          _project!.memberIds,
        );

    return Scaffold(
      appBar: CustomAppBar(
        title: _project?.name ?? 'Project Details',
        actions: [
          if (canEdit)
            PopupMenuButton<String>(
              onSelected: (value) {
                switch (value) {
                  case 'edit':
                    // Navigate to edit project
                    break;
                  case 'delete':
                    _deleteProject();
                    break;
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit_outlined),
                      SizedBox(width: 8),
                      Text('Edit Project'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete_outlined, color: AppColors.error),
                      SizedBox(width: 8),
                      Text('Delete Project', style: TextStyle(color: AppColors.error)),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
      body: _project == null
          ? const LoadingWidget(message: 'Loading project...')
          : Column(
              children: [
                // Project Header
                _buildProjectHeader(),
                
                // Tabs
                TabBar(
                  controller: _tabController,
                  labelColor: AppColors.primaryBlue,
                  unselectedLabelColor: AppColors.textSecondary,
                  indicatorColor: AppColors.primaryBlue,
                  tabs: const [
                    Tab(text: 'Overview'),
                    Tab(text: 'Tasks'),
                    Tab(text: 'Team'),
                  ],
                ),

                // Tab Views
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildOverviewTab(),
                      _buildTasksTab(),
                      _buildTeamTab(),
                    ],
                  ),
                ),
              ],
            ),
      floatingActionButton: canEdit
          ? FloatingActionButton(
              heroTag: "project_detail_fab", // Add unique hero tag
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  AppRoutes.createTask,
                  arguments: widget.projectId,
                );
              },
              backgroundColor: AppColors.primaryBlue,
              child: const Icon(Icons.add_task, color: Colors.white),
            )
          : null,
    );
  }

  Widget _buildProjectHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: AppColors.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  _project!.name,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _getStatusColor(_project!.status).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _getStatusColor(_project!.status).withOpacity(0.3),
                  ),
                ),
                child: Text(
                  _project!.status.displayName,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _getStatusColor(_project!.status),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _project!.description,
            style: const TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          ProjectProgressWidget(
            progress: _project!.progress,
            showLabel: true,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.group_outlined, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 4),
              Text(
                '${_project!.memberIds.length} members',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
              const SizedBox(width: 16),
              if (_project!.dueDate != null) ...[
                Icon(Icons.schedule_outlined, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  'Due ${AppDateUtils.formatDate(_project!.dueDate!)}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Project Info Cards
          Row(
            children: [
              Expanded(
                child: _buildInfoCard(
                  'Start Date',
                  AppDateUtils.formatDate(_project!.startDate),
                  Icons.play_arrow_rounded,
                  AppColors.info,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildInfoCard(
                  'Progress',
                  '${(_project!.progress * 100).toInt()}%',
                  Icons.trending_up_rounded,
                  AppColors.success,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Recent Activity
          const Text(
            'Recent Activity',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Consumer<TaskViewModel>(
            builder: (context, taskViewModel, child) {
              final recentTasks = taskViewModel.tasks
                  .where((task) => task.projectId == widget.projectId)
                  .take(3)
                  .toList();

              if (recentTasks.isEmpty) {
                return const Card(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Center(
                      child: Text('No recent activity'),
                    ),
                  ),
                );
              }

              return Column(
                children: recentTasks
                    .map((task) => TaskCard(
                          task: task,
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              AppRoutes.taskDetail,
                              arguments: task.id,
                            );
                          },
                        ))
                    .toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTasksTab() {
    return Consumer<TaskViewModel>(
      builder: (context, taskViewModel, child) {
        if (taskViewModel.isLoading) {
          return const LoadingWidget(message: 'Loading tasks...');
        }

        final tasks = taskViewModel.tasks
            .where((task) => task.projectId == widget.projectId)
            .toList();

        if (tasks.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.task_alt_rounded, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'No tasks yet',
                  style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                ),
                const SizedBox(height: 8),
                Text(
                  'Create your first task to get started',
                  style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
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
              showProject: false,
            );
          },
        );
      },
    );
  }

  Widget _buildTeamTab() {
    return Consumer<TaskViewModel>(
      builder: (context, taskViewModel, child) {
        final users = taskViewModel.users
            .where((user) => _project!.memberIds.contains(user.id))
            .toList();

        if (users.isEmpty) {
          return const Center(
            child: Text('No team members assigned'),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: users.length,
          itemBuilder: (context, index) {
            final user = users[index];
            final isOwner = user.id == _project!.ownerId;
            
            return Card(
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppColors.primaryBlue.withOpacity(0.1),
                  child: Text(
                    user.name.substring(0, 1).toUpperCase(),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryBlue,
                    ),
                  ),
                ),
                title: Text(user.name),
                subtitle: Text(user.role.displayName),
                trailing: isOwner
                    ? Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.warning.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'Owner',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: AppColors.warning,
                          ),
                        ),
                      )
                    : null,
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildInfoCard(String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(ProjectStatus status) {
    switch (status) {
      case ProjectStatus.planning:
        return AppColors.warning;
      case ProjectStatus.active:
        return AppColors.primaryBlue;
      case ProjectStatus.onHold:
        return AppColors.statusToDo;
      case ProjectStatus.completed:
        return AppColors.success;
      case ProjectStatus.cancelled:
        return AppColors.error;
    }
  }

  Future<void> _deleteProject() async {
    final confirmed = await AppUtils.showConfirmDialog(
      context,
      title: 'Delete Project',
      content: 'Are you sure you want to delete this project? This action cannot be undone.',
      confirmText: 'Delete',
    );

    if (confirmed) {
      final projectViewModel = context.read<ProjectViewModel>();
      final success = await projectViewModel.deleteProject(widget.projectId);

      if (success && mounted) {
        AppUtils.showSuccessSnackBar(context, 'Project deleted successfully');
        Navigator.pop(context);
      } else if (mounted) {
        AppUtils.showErrorSnackBar(
          context,
          projectViewModel.errorMessage ?? 'Failed to delete project',
        );
      }
    }
  }
}