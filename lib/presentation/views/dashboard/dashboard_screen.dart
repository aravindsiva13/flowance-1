// lib/presentation/views/dashboard/dashboard_screen.dart - COMPLETE FIXED VERSION

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/dashboard_viewmodel.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/dashboard/stats_card.dart';
import '../../widgets/task/task_card.dart';
import '../../widgets/project/project_card.dart';
import '../../../routes/app_routes.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/date_utils.dart';
import '../../../data/models/notification_model.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    final dashboardViewModel = context.read<DashboardViewModel>();
    await Future.wait([
      dashboardViewModel.loadDashboard(),
      dashboardViewModel.loadNotifications(),
    ]);
  }

  Future<void> _refreshData() async {
    final dashboardViewModel = context.read<DashboardViewModel>();
    await dashboardViewModel.refreshAll();
  }

  @override
  Widget build(BuildContext context) {
    final authViewModel = context.watch<AuthViewModel>();
    final currentUser = authViewModel.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Dashboard'),
            if (currentUser != null)
              Text(
                'Welcome back, ${currentUser.name.split(' ').first}',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
              ),
          ],
        ),
        actions: [
          // Notifications
          Consumer<DashboardViewModel>(
            builder: (context, dashboardViewModel, child) {
              final unreadCount = dashboardViewModel.unreadNotificationsCount;
              return Stack(
                children: [
                  IconButton(
                    onPressed: () => _showNotifications(context),
                    icon: const Icon(Icons.notifications_rounded),
                  ),
                  if (unreadCount > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: AppColors.error,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          unreadCount > 9 ? '9+' : unreadCount.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          
          // Refresh
          IconButton(
            onPressed: _refreshData,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: Consumer<DashboardViewModel>(
        builder: (context, dashboardViewModel, child) {
          if (dashboardViewModel.isLoading) {
            return const LoadingWidget();
          }

          if (dashboardViewModel.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, size: 64, color: AppColors.error),
                  const SizedBox(height: 16),
                  Text(
                    dashboardViewModel.errorMessage!,
                    style: const TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _refreshData,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _refreshData,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Overview Stats
                  _buildOverviewStats(dashboardViewModel),
                  const SizedBox(height: 24),
                  
                  // Simple Analytics Section (without complex charts)
                  _buildSimpleAnalytics(dashboardViewModel),
                  const SizedBox(height: 24),
                  
                  // Recent Tasks
                  _buildRecentTasks(dashboardViewModel),
                  const SizedBox(height: 24),
                  
                  // Active Projects
                  _buildActiveProjects(dashboardViewModel),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildOverviewStats(DashboardViewModel dashboardViewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Overview',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: StatsCard(
                title: 'Total Tasks',
                value: _safeGetInt(dashboardViewModel.totalTasks).toString(),
                icon: Icons.task_alt_rounded,
                color: AppColors.primaryBlue,
                subtitle: '${_safeGetInt(dashboardViewModel.completedTasks)} completed',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StatsCard(
                title: 'Active Projects',
                value: _safeGetInt(dashboardViewModel.activeProjectsCount).toString(),
                icon: Icons.folder_rounded,
                color: AppColors.success,
                subtitle: '${_safeGetInt(dashboardViewModel.totalProjects)} total',
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: StatsCard(
                title: 'Overdue Tasks',
                value: _safeGetInt(dashboardViewModel.overdueTasks).toString(),
                icon: Icons.warning_rounded,
                color: AppColors.error,
                subtitle: 'Need attention',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StatsCard(
                title: 'Completed This Week',
                value: _safeGetInt(dashboardViewModel.completedThisWeek).toString(),
                icon: Icons.trending_up_rounded,
                color: AppColors.info,
                subtitle: 'Great progress!',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSimpleAnalytics(DashboardViewModel dashboardViewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Analytics',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            // Task Status Distribution (Simple Version)
            Expanded(
              child: _buildTaskStatusCard(dashboardViewModel),
            ),
            const SizedBox(width: 12),
            
            // Productivity Score (Simple Version)
            Expanded(
              child: _buildProductivityCard(dashboardViewModel),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTaskStatusCard(DashboardViewModel dashboardViewModel) {
    final todoTasks = _safeGetInt(dashboardViewModel.todoTasks);
    final inProgressTasks = _safeGetInt(dashboardViewModel.inProgressTasks);
    final completedTasks = _safeGetInt(dashboardViewModel.completedTasks);
    final totalTasks = _safeGetInt(dashboardViewModel.totalTasks);
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Task Distribution',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            
            // Simple progress bars instead of pie chart
            _buildTaskStatusRow('To Do', todoTasks, totalTasks, AppColors.statusToDo),
            const SizedBox(height: 8),
            _buildTaskStatusRow('In Progress', inProgressTasks, totalTasks, AppColors.statusInProgress),
            const SizedBox(height: 8),
            _buildTaskStatusRow('Completed', completedTasks, totalTasks, AppColors.statusDone),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskStatusRow(String label, int count, int total, Color color) {
    final percentage = total > 0 ? (count / total) : 0.0;
    
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            ),
            Text(
              '$count',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color),
            ),
          ],
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: percentage,
          backgroundColor: AppColors.borderLight,
          valueColor: AlwaysStoppedAnimation(color),
          minHeight: 4,
        ),
      ],
    );
  }

  Widget _buildProductivityCard(DashboardViewModel dashboardViewModel) {
    final score = _safeGetInt(dashboardViewModel.productivityScore);
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Productivity Score',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _getScoreColor(score).withOpacity(0.1),
                      border: Border.all(color: _getScoreColor(score), width: 4),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            score.toString(),
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: _getScoreColor(score),
                            ),
                          ),
                          Text(
                            _getScoreLabel(score),
                            style: TextStyle(
                              fontSize: 10,
                              color: _getScoreColor(score),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _getScoreDescription(score),
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentTasks(DashboardViewModel dashboardViewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Recent Tasks',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, AppRoutes.tasks);
              },
              child: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        
        dashboardViewModel.recentTasks.isEmpty
            ? Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.task_alt_rounded,
                          size: 48,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'No recent tasks',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            : Column(
                children: dashboardViewModel.recentTasks
                    .map((task) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: TaskCard(
                            task: task,
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                AppRoutes.taskDetail,
                                arguments: task.id,
                              );
                            },
                            showProject: true,
                          ),
                        ))
                    .toList(),
              ),
      ],
    );
  }

  Widget _buildActiveProjects(DashboardViewModel dashboardViewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Active Projects',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, AppRoutes.projects);
              },
              child: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        
        dashboardViewModel.activeProjects.isEmpty
            ? Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.folder_rounded,
                          size: 48,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'No active projects',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            : Column(
                children: dashboardViewModel.activeProjects
                    .map((project) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: ProjectCard(
                            project: project,
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                AppRoutes.projectDetail,
                                arguments: project.id,
                              );
                            },
                          ),
                        ))
                    .toList(),
              ),
      ],
    );
  }

  // Helper methods
  int _safeGetInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.round();
    if (value is num) return value.toInt();
    return 0;
  }

  Color _getScoreColor(int score) {
    if (score >= 80) return AppColors.success;
    if (score >= 60) return AppColors.warning;
    if (score >= 40) return AppColors.error;
    return Colors.red;
  }

  String _getScoreLabel(int score) {
    if (score >= 80) return 'Excellent';
    if (score >= 60) return 'Good';
    if (score >= 40) return 'Fair';
    return 'Poor';
  }

  String _getScoreDescription(int score) {
    if (score >= 80) return 'Keep up the great work!';
    if (score >= 60) return 'Good progress made';
    if (score >= 40) return 'Room for improvement';
    return 'Let\'s focus more';
  }

  void _showNotifications(BuildContext context) {
    final dashboardViewModel = context.read<DashboardViewModel>();
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Notifications',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (dashboardViewModel.unreadNotificationsCount > 0)
                  TextButton(
                    onPressed: () async {
                      await dashboardViewModel.markAllNotificationsAsRead();
                    },
                    child: const Text('Mark All Read'),
                  ),
              ],
            ),
            const Divider(),
            Expanded(
              child: dashboardViewModel.notifications.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.notifications_none, size: 64, color: Colors.grey),
                          SizedBox(height: 16),
                          Text('No notifications yet'),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: dashboardViewModel.notifications.length,
                      itemBuilder: (context, index) {
                        final notification = dashboardViewModel.notifications[index];
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: notification.isRead 
                                ? Colors.grey[300] 
                                : AppColors.primaryBlue,
                            child: Icon(
                              _getNotificationIcon(notification.type),
                              color: notification.isRead ? Colors.grey : Colors.white,
                            ),
                          ),
                          title: Text(
                            notification.title,
                            style: TextStyle(
                              fontWeight: notification.isRead 
                                  ? FontWeight.normal 
                                  : FontWeight.bold,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(notification.message),
                              const SizedBox(height: 4),
                              Text(
                                AppDateUtils.formatRelativeTime(notification.createdAt),
                                style: const TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                          onTap: () async {
                            if (!notification.isRead) {
                              await dashboardViewModel.markNotificationAsRead(notification.id);
                            }
                            Navigator.pop(context);
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getNotificationIcon(NotificationType type) {
    switch (type) {
      case NotificationType.taskAssigned:
        return Icons.task_alt_rounded;
      case NotificationType.taskUpdated:
        return Icons.edit_rounded;
      case NotificationType.taskCompleted:
        return Icons.check_circle_rounded;
      case NotificationType.projectInvite:
        return Icons.group_add_rounded;
      case NotificationType.mention:
        return Icons.alternate_email_rounded;
      case NotificationType.deadlineReminder:
        return Icons.alarm_rounded;
    }
  }
}