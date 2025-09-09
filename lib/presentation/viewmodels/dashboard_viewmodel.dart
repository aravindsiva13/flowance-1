// lib/presentation/viewmodels/dashboard_viewmodel.dart

import 'package:flutter/foundation.dart';
import '../../data/models/task_model.dart';
import '../../data/models/project_model.dart';
import '../../data/models/notification_model.dart';
import '../../data/repositories/app_repository.dart';
import '../../core/enums/task_status.dart';
import '../../core/enums/project_status.dart';
import '../../core/exceptions/app_exception.dart';

class DashboardViewModel extends ChangeNotifier {
  final AppRepository _repository = AppRepository();
  
  Map<String, dynamic> _dashboardStats = {};
  List<TaskModel> _recentTasks = [];
  List<ProjectModel> _activeProjects = [];
  List<NotificationModel> _notifications = [];
  bool _isLoading = false;
  bool _isLoadingNotifications = false;
  String? _errorMessage;
  
  // Getters
  Map<String, dynamic> get dashboardStats => _dashboardStats;
  List<TaskModel> get recentTasks => _recentTasks;
  List<ProjectModel> get activeProjects => _activeProjects;
  List<NotificationModel> get notifications => _notifications;
  bool get isLoading => _isLoading;
  bool get isLoadingNotifications => _isLoadingNotifications;
  String? get errorMessage => _errorMessage;
  
  // Computed getters
  int get totalTasks => _getStatValue('taskStats', 'total');
  int get todoTasks => _getStatValue('taskStats', 'toDo');
  int get inProgressTasks => _getStatValue('taskStats', 'inProgress');
  int get completedTasks => _getStatValue('taskStats', 'done');
  int get overdueTasks => _getStatValue('overdueTasks');
  
  int get totalProjects => _getStatValue('projectStats', 'total');
  int get activeProjectsCount => _getStatValue('projectStats', 'active');
  int get completedProjectsCount => _getStatValue('projectStats', 'completed');
  
  double get avgProjectProgress => (_getStatValue('avgProjectProgress') as num?)?.toDouble() ?? 0.0;
  int get completedThisWeek => _getStatValue('completedThisWeek');
  
  List<NotificationModel> get unreadNotifications => 
    _notifications.where((n) => !n.isRead).toList();
  
  int get unreadNotificationsCount => unreadNotifications.length;
  
  // Load dashboard data
  Future<void> loadDashboard() async {
    _setLoading(true);
    _clearError();
    
    try {
      // Load stats
      _dashboardStats = await _repository.getDashboardStats();
      
      // Load recent tasks (assigned to current user)
      final allTasks = await _repository.getTasks();
      _recentTasks = allTasks
          .where((task) => task.status != TaskStatus.done)
          .toList()
        ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      
      // Take only first 5 recent tasks
      if (_recentTasks.length > 5) {
        _recentTasks = _recentTasks.sublist(0, 5);
      }
      
      // Load active projects
      final allProjects = await _repository.getProjects();
      _activeProjects = allProjects
          .where((project) => project.status.isActive)
          .toList()
        ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      
      // Take only first 5 active projects
      if (_activeProjects.length > 5) {
        _activeProjects = _activeProjects.sublist(0, 5);
      }
      
    } catch (e) {
      _setError(_getErrorMessage(e));
    }
    
    _setLoading(false);
  }
  
  // Load notifications
  Future<void> loadNotifications() async {
    _setLoadingNotifications(true);
    
    try {
      _notifications = await _repository.getNotifications();
    } catch (e) {
      _setError(_getErrorMessage(e));
    }
    
    _setLoadingNotifications(false);
  }
  
  // Mark notification as read
  Future<bool> markNotificationAsRead(String notificationId) async {
    try {
      await _repository.markNotificationAsRead(notificationId);
      
      // Update local state
      final index = _notifications.indexWhere((n) => n.id == notificationId);
      if (index != -1) {
        _notifications[index] = _notifications[index].copyWith(isRead: true);
        notifyListeners();
      }
      
      return true;
    } catch (e) {
      _setError(_getErrorMessage(e));
      return false;
    }
  }
  
  // Mark all notifications as read
  Future<bool> markAllNotificationsAsRead() async {
    try {
      await _repository.markAllNotificationsAsRead();
      
      // Update local state
      for (int i = 0; i < _notifications.length; i++) {
        if (!_notifications[i].isRead) {
          _notifications[i] = _notifications[i].copyWith(isRead: true);
        }
      }
      
      notifyListeners();
      return true;
    } catch (e) {
      _setError(_getErrorMessage(e));
      return false;
    }
  }
  
  // Get task completion rate
  double get taskCompletionRate {
    if (totalTasks == 0) return 0.0;
    return completedTasks / totalTasks;
  }
  
  // Get project completion rate
  double get projectCompletionRate {
    if (totalProjects == 0) return 0.0;
    return completedProjectsCount / totalProjects;
  }
  
  // Get productivity score (0-100)
  int get productivityScore {
    double score = 0.0;
    
    // Task completion contributes 40%
    score += (taskCompletionRate * 40);
    
    // Project progress contributes 30%
    score += (avgProjectProgress * 30);
    
    // Overdue tasks penalty (up to -20%)
    if (totalTasks > 0) {
      final overdueRate = overdueTasks / totalTasks;
      score -= (overdueRate * 20);
    }
    
    // Completed this week bonus (up to +10%)
    if (completedThisWeek > 0) {
      score += (completedThisWeek.clamp(0, 10).toDouble());
    }
    
    return score.clamp(0, 100).round();
  }
  
  // Get chart data for task status
  List<Map<String, dynamic>> get taskStatusChartData {
    return [
      {
        'status': 'To Do',
        'count': todoTasks,
        'color': '#9E9E9E',
      },
      {
        'status': 'In Progress',
        'count': inProgressTasks,
        'color': '#2196F3',
      },
      {
        'status': 'Completed',
        'count': completedTasks,
        'color': '#4CAF50',
      },
    ];
  }
  
  // Get chart data for project status
  List<Map<String, dynamic>> get projectStatusChartData {
    final stats = _getNestedStat('projectStats');
    return [
      {
        'status': 'Active',
        'count': stats['active'] ?? 0,
        'color': '#2196F3',
      },
      {
        'status': 'Planning',
        'count': stats['planning'] ?? 0,
        'color': '#FF9800',
      },
      {
        'status': 'Completed',
        'count': stats['completed'] ?? 0,
        'color': '#4CAF50',
      },
      {
        'status': 'On Hold',
        'count': stats['onHold'] ?? 0,
        'color': '#9E9E9E',
      },
    ];
  }
  
  // Refresh dashboard
  Future<void> refresh() async {
    await Future.wait([
      loadDashboard(),
      loadNotifications(),
    ]);
  }
  
  // Private helper methods
  int _getStatValue(String key, [String? subKey]) {
    if (subKey != null) {
      final nested = _dashboardStats[key] as Map<String, dynamic>?;
      return nested?[subKey] ?? 0;
    }
    return _dashboardStats[key] ?? 0;
  }
  
  Map<String, dynamic> _getNestedStat(String key) {
    return _dashboardStats[key] as Map<String, dynamic>? ?? {};
  }
  
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
  
  void _setLoadingNotifications(bool loading) {
    _isLoadingNotifications = loading;
    notifyListeners();
  }
  
  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }
  
  void _clearError() {
    _errorMessage = null;
  }
  
  String _getErrorMessage(dynamic error) {
    if (error is AppException) {
      return error.message;
    }
    return error.toString().replaceFirst('Exception: ', '');
  }
  
  void clearError() {
    _clearError();
    notifyListeners();
  }
}
