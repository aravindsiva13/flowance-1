// lib/presentation/views/notifications/notifications_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/dashboard_viewmodel.dart';
import '../../widgets/common/custom_app_bar.dart';
import '../../widgets/common/loading_widget.dart';
import './notification_card.dart';
import '../../../data/models/notification_model.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/app_utils.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadNotifications();
    });
  }

  Future<void> _loadNotifications() async {
    final dashboardVM = context.read<DashboardViewModel>();
    await dashboardVM.loadNotifications();
  }

  Future<void> _markAllAsRead() async {
    final dashboardVM = context.read<DashboardViewModel>();
    final success = await dashboardVM.markAllNotificationsAsRead();
    
    if (success && mounted) {
      AppUtils.showSuccessSnackBar(context, 'All notifications marked as read');
    } else if (mounted) {
      AppUtils.showErrorSnackBar(context, 'Failed to mark notifications as read');
    }
  }

  Future<void> _deleteNotification(String id) async {
    final dashboardVM = context.read<DashboardViewModel>();
    final success = await dashboardVM.deleteNotification(id);
    
    if (success && mounted) {
      AppUtils.showSuccessSnackBar(context, 'Notification deleted');
    } else if (mounted) {
      AppUtils.showErrorSnackBar(context, 'Failed to delete notification');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Notifications',
        actions: [
          Consumer<DashboardViewModel>(
            builder: (context, dashboardVM, child) {
              final unreadCount = dashboardVM.unreadNotificationsCount;
              
              if (unreadCount > 0) {
                return TextButton(
                  onPressed: _markAllAsRead,
                  child: const Text(
                    'Mark All Read',
                    style: TextStyle(color: Colors.white),
                  ),
                );
              }
              
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: Consumer<DashboardViewModel>(
        builder: (context, dashboardVM, child) {
          if (dashboardVM.isLoading) {
            return const LoadingWidget(message: 'Loading notifications...');
          }

          final notifications = dashboardVM.notifications;

          if (notifications.isEmpty) {
            return _buildEmptyState();
          }

          return RefreshIndicator(
            onRefresh: _loadNotifications,
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: notifications.length,
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final notification = notifications[index];
                return NotificationCard(
                  notification: notification,
                  onTap: () => _handleNotificationTap(notification),
                  onMarkRead: () => _markAsRead(notification),
                  onDelete: () => _deleteNotification(notification.id),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_none_rounded,
            size: 80,
            color: Colors.grey,
          ),
          SizedBox(height: 16),
          Text(
            'No Notifications',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'You\'re all caught up!',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  void _handleNotificationTap(NotificationModel notification) {
    // Mark as read if not already read
    if (!notification.isRead) {
      _markAsRead(notification);
    }

    // Navigate based on notification type and metadata
    if (notification.metadata != null) {
      final metadata = notification.metadata!;
      
      switch (notification.type) {
        case NotificationType.taskAssigned:
        case NotificationType.taskUpdated:
        case NotificationType.taskCompleted:
        case NotificationType.mention:
        case NotificationType.deadlineReminder:
          final taskId = metadata['taskId'];
          if (taskId != null) {
            Navigator.pushNamed(
              context,
              '/task-detail',
              arguments: taskId,
            );
          }
          break;
          
        case NotificationType.projectInvite:
          final projectId = metadata['projectId'];
          if (projectId != null) {
            Navigator.pushNamed(
              context,
              '/project-detail',
              arguments: projectId,
            );
          }
          break;
      }
    }
  }

  Future<void> _markAsRead(NotificationModel notification) async {
    if (notification.isRead) return;
    
    final dashboardVM = context.read<DashboardViewModel>();
    await dashboardVM.markNotificationAsRead(notification.id);
  }
}

// lib/presentation/widgets/notifications/notification_card.dart

class NotificationCard extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback? onTap;
  final VoidCallback? onMarkRead;
  final VoidCallback? onDelete;

  const NotificationCard({
    Key? key,
    required this.notification,
    this.onTap,
    this.onMarkRead,
    this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: notification.isRead ? 1 : 3,
      color: notification.isRead ? null : AppColors.primaryBlue.withOpacity(0.05),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildIcon(),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: TextStyle(
                              fontWeight: notification.isRead
                                  ? FontWeight.normal
                                  : FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        if (!notification.isRead)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: AppColors.primaryBlue,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notification.message,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          _formatTime(notification.createdAt),
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                        const Spacer(),
                        if (!notification.isRead && onMarkRead != null)
                          TextButton(
                            onPressed: onMarkRead,
                            child: const Text(
                              'Mark Read',
                              style: TextStyle(fontSize: 12),
                            ),
                          ),
                        if (onDelete != null)
                          IconButton(
                            onPressed: onDelete,
                            icon: const Icon(
                              Icons.delete_outline,
                              size: 18,
                              color: AppColors.textSecondary,
                            ),
                            constraints: const BoxConstraints(),
                            padding: EdgeInsets.zero,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIcon() {
    IconData iconData;
    Color iconColor;

    switch (notification.type) {
      case NotificationType.taskAssigned:
        iconData = Icons.task_alt_rounded;
        iconColor = AppColors.primaryBlue;
        break;
      case NotificationType.taskUpdated:
        iconData = Icons.edit_rounded;
        iconColor = AppColors.warning;
        break;
      case NotificationType.taskCompleted:
        iconData = Icons.check_circle_rounded;
        iconColor = AppColors.success;
        break;
      case NotificationType.projectInvite:
        iconData = Icons.group_add_rounded;
        iconColor = AppColors.info;
        break;
      case NotificationType.mention:
        iconData = Icons.alternate_email_rounded;
        iconColor = AppColors.secondary;
        break;
      case NotificationType.deadlineReminder:
        iconData = Icons.alarm_rounded;
        iconColor = AppColors.error;
        break;
    }

    return CircleAvatar(
      radius: 18,
      backgroundColor: iconColor.withOpacity(0.1),
      child: Icon(
        iconData,
        size: 18,
        color: iconColor,
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }
}