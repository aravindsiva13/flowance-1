// // lib/presentation/viewmodels/dashboard_viewmodel.dart

// import 'package:flutter/foundation.dart';
// import '../../data/models/task_model.dart';
// import '../../data/models/project_model.dart';
// import '../../data/models/notification_model.dart';
// import '../../data/repositories/app_repository.dart';
// import '../../core/enums/task_status.dart';
// import '../../core/enums/project_status.dart';
// import '../../core/exceptions/app_exception.dart';

// class DashboardViewModel extends ChangeNotifier {
//   final AppRepository _repository = AppRepository();
  
//   Map<String, dynamic> _dashboardStats = {};
//   List<TaskModel> _recentTasks = [];
//   List<ProjectModel> _activeProjects = [];
//   List<NotificationModel> _notifications = [];
//   bool _isLoading = false;
//   bool _isLoadingNotifications = false;
//   String? _errorMessage;
  
//   // Getters
//   Map<String, dynamic> get dashboardStats => _dashboardStats;
//   List<TaskModel> get recentTasks => _recentTasks;
//   List<ProjectModel> get activeProjects => _activeProjects;
//   List<NotificationModel> get notifications => _notifications;
//   bool get isLoading => _isLoading;
//   bool get isLoadingNotifications => _isLoadingNotifications;
//   String? get errorMessage => _errorMessage;
  
//   // Computed getters
//   int get totalTasks => _getStatValue('taskStats', 'total');
//   int get todoTasks => _getStatValue('taskStats', 'toDo');
//   int get inProgressTasks => _getStatValue('taskStats', 'inProgress');
//   int get completedTasks => _getStatValue('taskStats', 'done');
//   int get overdueTasks => _getStatValue('overdueTasks');
  
//   int get totalProjects => _getStatValue('projectStats', 'total');
//   int get activeProjectsCount => _getStatValue('projectStats', 'active');
//   int get completedProjectsCount => _getStatValue('projectStats', 'completed');
  
//   double get avgProjectProgress => (_getStatValue('avgProjectProgress') as num?)?.toDouble() ?? 0.0;
//   int get completedThisWeek => _getStatValue('completedThisWeek');
  
//   List<NotificationModel> get unreadNotifications => 
//     _notifications.where((n) => !n.isRead).toList();
  
//   int get unreadNotificationsCount => unreadNotifications.length;
  
//   // Load dashboard data
//   Future<void> loadDashboard() async {
//     _setLoading(true);
//     _clearError();
    
//     try {
//       // Load stats
//       _dashboardStats = await _repository.getDashboardStats();
      
//       // Load recent tasks (assigned to current user)
//       final allTasks = await _repository.getTasks();
//       _recentTasks = allTasks
//           .where((task) => task.status != TaskStatus.done)
//           .toList()
//         ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      
//       // Take only first 5 recent tasks
//       if (_recentTasks.length > 5) {
//         _recentTasks = _recentTasks.sublist(0, 5);
//       }
      
//       // Load active projects
//       final allProjects = await _repository.getProjects();
//       _activeProjects = allProjects
//           .where((project) => project.status.isActive)
//           .toList()
//         ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      
//       // Take only first 5 active projects
//       if (_activeProjects.length > 5) {
//         _activeProjects = _activeProjects.sublist(0, 5);
//       }
      
//     } catch (e) {
//       _setError(_getErrorMessage(e));
//     }
    
//     _setLoading(false);
//   }
  
//   // Load notifications
//   Future<void> loadNotifications() async {
//     _setLoadingNotifications(true);
    
//     try {
//       _notifications = await _repository.getNotifications();
//     } catch (e) {
//       _setError(_getErrorMessage(e));
//     }
    
//     _setLoadingNotifications(false);
//   }
  
//   // Mark notification as read
//   Future<bool> markNotificationAsRead(String notificationId) async {
//     try {
//       await _repository.markNotificationAsRead(notificationId);
      
//       // Update local state
//       final index = _notifications.indexWhere((n) => n.id == notificationId);
//       if (index != -1) {
//         _notifications[index] = _notifications[index].copyWith(isRead: true);
//         notifyListeners();
//       }
      
//       return true;
//     } catch (e) {
//       _setError(_getErrorMessage(e));
//       return false;
//     }
//   }
  
//   // Mark all notifications as read
//   Future<bool> markAllNotificationsAsRead() async {
//     try {
//       await _repository.markAllNotificationsAsRead();
      
//       // Update local state
//       for (int i = 0; i < _notifications.length; i++) {
//         if (!_notifications[i].isRead) {
//           _notifications[i] = _notifications[i].copyWith(isRead: true);
//         }
//       }
      
//       notifyListeners();
//       return true;
//     } catch (e) {
//       _setError(_getErrorMessage(e));
//       return false;
//     }
//   }
  
//   // Get task completion rate
//   double get taskCompletionRate {
//     if (totalTasks == 0) return 0.0;
//     return completedTasks / totalTasks;
//   }
  
//   // Get project completion rate
//   double get projectCompletionRate {
//     if (totalProjects == 0) return 0.0;
//     return completedProjectsCount / totalProjects;
//   }
  
//   // Get productivity score (0-100)
//   int get productivityScore {
//     double score = 0.0;
    
//     // Task completion contributes 40%
//     score += (taskCompletionRate * 40);
    
//     // Project progress contributes 30%
//     score += (avgProjectProgress * 30);
    
//     // Overdue tasks penalty (up to -20%)
//     if (totalTasks > 0) {
//       final overdueRate = overdueTasks / totalTasks;
//       score -= (overdueRate * 20);
//     }
    
//     // Completed this week bonus (up to +10%)
//     if (completedThisWeek > 0) {
//       score += (completedThisWeek.clamp(0, 10).toDouble());
//     }
    
//     return score.clamp(0, 100).round();
//   }
  
//   // Get chart data for task status
//   List<Map<String, dynamic>> get taskStatusChartData {
//     return [
//       {
//         'status': 'To Do',
//         'count': todoTasks,
//         'color': '#9E9E9E',
//       },
//       {
//         'status': 'In Progress',
//         'count': inProgressTasks,
//         'color': '#2196F3',
//       },
//       {
//         'status': 'Completed',
//         'count': completedTasks,
//         'color': '#4CAF50',
//       },
//     ];
//   }
  
//   // Get chart data for project status
//   List<Map<String, dynamic>> get projectStatusChartData {
//     final stats = _getNestedStat('projectStats');
//     return [
//       {
//         'status': 'Active',
//         'count': stats['active'] ?? 0,
//         'color': '#2196F3',
//       },
//       {
//         'status': 'Planning',
//         'count': stats['planning'] ?? 0,
//         'color': '#FF9800',
//       },
//       {
//         'status': 'Completed',
//         'count': stats['completed'] ?? 0,
//         'color': '#4CAF50',
//       },
//       {
//         'status': 'On Hold',
//         'count': stats['onHold'] ?? 0,
//         'color': '#9E9E9E',
//       },
//     ];
//   }
  
//   // Refresh dashboard
//   Future<void> refresh() async {
//     await Future.wait([
//       loadDashboard(),
//       loadNotifications(),
//     ]);
//   }
  
//   // Private helper methods
//   int _getStatValue(String key, [String? subKey]) {
//     if (subKey != null) {
//       final nested = _dashboardStats[key] as Map<String, dynamic>?;
//       return nested?[subKey] ?? 0;
//     }
//     return _dashboardStats[key] ?? 0;
//   }
  
//   Map<String, dynamic> _getNestedStat(String key) {
//     return _dashboardStats[key] as Map<String, dynamic>? ?? {};
//   }
  
//   void _setLoading(bool loading) {
//     _isLoading = loading;
//     notifyListeners();
//   }
  
//   void _setLoadingNotifications(bool loading) {
//     _isLoadingNotifications = loading;
//     notifyListeners();
//   }
  
//   void _setError(String error) {
//     _errorMessage = error;
//     notifyListeners();
//   }
  
//   void _clearError() {
//     _errorMessage = null;
//   }
  
//   String _getErrorMessage(dynamic error) {
//     if (error is AppException) {
//       return error.message;
//     }
//     return error.toString().replaceFirst('Exception: ', '');
//   }
  
//   void clearError() {
//     _clearError();
//     notifyListeners();
//   }
// }


//2

// lib/presentation/viewmodels/dashboard_viewmodel.dart - COMPLETE INTEGRATION

import 'package:flutter/foundation.dart';
import '../../data/models/project_model.dart';
import '../../data/models/task_model.dart';
import '../../data/models/user_model.dart';
import '../../data/models/notification_model.dart';
import '../../data/models/time_entry_model.dart';
import '../../data/repositories/app_repository.dart';
import '../../core/enums/task_status.dart';
import '../../core/enums/task_priority.dart';
import '../../core/enums/project_status.dart';
import '../../core/exceptions/app_exception.dart';

class DashboardViewModel extends ChangeNotifier {
  final AppRepository _repository = AppRepository();
  
  // Dashboard data
  List<ProjectModel> _recentProjects = [];
  List<TaskModel> _recentTasks = [];
  List<TaskModel> _myTasks = [];
  List<NotificationModel> _notifications = [];
  List<TimeEntryModel> _recentTimeEntries = [];
  UserModel? _currentUser;
  


  // Add these getters for dashboard stats
int get totalTasks => _safeGetStat('totalTasks');
int get completedTasks => _safeGetStat('completedTasks');
int get activeProjectsCount => _safeGetStat('activeProjectsCount') ?? _recentProjects.length;
int get totalProjects => _safeGetStat('totalProjects') ?? _recentProjects.length;
int get completedThisWeek => _safeGetStat('completedThisWeek');
int get todoTasks => _safeGetStat('todoTasks');
int get inProgressTasks => _safeGetStat('inProgressTasks');
int get productivityScore => _safeGetStat('productivityScore');
List<ProjectModel> get activeProjects => _recentProjects;

// Helper method
int _safeGetStat(String key) {
  final value = _dashboardStats[key];
  if (value is int) return value;
  if (value is double) return value.toInt();
  return 0;
}
  // Dashboard statistics
  Map<String, dynamic> _dashboardStats = {};
  
  // Loading states
  bool _isLoading = false;
  bool _isLoadingStats = false;
  bool _isLoadingNotifications = false;
  String? _errorMessage;

  // Getters
  List<ProjectModel> get recentProjects => _recentProjects;
  List<TaskModel> get recentTasks => _recentTasks;
  List<TaskModel> get myTasks => _myTasks;
  List<NotificationModel> get notifications => _notifications;
  List<TimeEntryModel> get recentTimeEntries => _recentTimeEntries;
  UserModel? get currentUser => _currentUser;
  Map<String, dynamic> get dashboardStats => _dashboardStats;
  
  bool get isLoading => _isLoading;
  bool get isLoadingStats => _isLoadingStats;
  bool get isLoadingNotifications => _isLoadingNotifications;
  String? get errorMessage => _errorMessage;

  // Computed getters
  int get unreadNotificationsCount => 
      _notifications.where((n) => !n.isRead).length;

  List<TaskModel> get overdueTasks {
    final now = DateTime.now();
    return _myTasks.where((task) => 
      task.dueDate != null && 
      task.dueDate!.isBefore(now) &&
      task.status != TaskStatus.done
    ).toList();
  }

  List<TaskModel> get upcomingTasks {
    final now = DateTime.now();
    final next7Days = now.add(const Duration(days: 7));
    return _myTasks.where((task) => 
      task.dueDate != null && 
      task.dueDate!.isAfter(now) &&
      task.dueDate!.isBefore(next7Days) &&
      task.status != TaskStatus.done
    ).toList();
  }

  double get todayHoursLogged {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    
    return _recentTimeEntries
        .where((entry) => 
            entry.startTime.isAfter(startOfDay) &&
            entry.startTime.isBefore(endOfDay))
        .fold(0.0, (sum, entry) => sum + entry.durationHours);
  }

  double get weekHoursLogged {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final startOfWeekDay = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
    
    return _recentTimeEntries
        .where((entry) => entry.startTime.isAfter(startOfWeekDay))
        .fold(0.0, (sum, entry) => sum + entry.durationHours);
  }
Future<void> refresh() async {
  await loadDashboard();
}
  // Main dashboard loading method
  Future<void> loadDashboard() async {
    _setLoading(true);
    _clearError();

    try {
      // Load all dashboard data in parallel
      await Future.wait([
        _loadCurrentUser(),
        _loadRecentProjects(),
        _loadMyTasks(),
        _loadRecentTimeEntries(),
        loadNotifications(),
        _loadDashboardStats(),
      ]);
    } catch (e) {
      _setError(_getErrorMessage(e));
    } finally {
      _setLoading(false);
    }
  }

  // Load current user
  Future<void> _loadCurrentUser() async {
    try {
      _currentUser = await _repository.getCurrentUser();
    } catch (e) {
      throw Exception('Failed to load user data: ${e.toString()}');
    }
  }

  // Load recent projects
  Future<void> _loadRecentProjects() async {
    try {
      final projects = await _repository.getProjects();
      _recentProjects = projects.take(3).toList();
    } catch (e) {
      throw Exception('Failed to load recent projects: ${e.toString()}');
    }
  }

  // Load user's tasks
  Future<void> _loadMyTasks() async {
    try {
      if (_currentUser == null) return;
      
      final allTasks = await _repository.getTasks();
      _myTasks = allTasks.where((task) => 
        task.assigneeId == _currentUser!.id
      ).toList();
      
      // Sort by priority and due date
      _myTasks.sort((a, b) {
        // First sort by status (in-progress first)
        if (a.status == TaskStatus.inProgress && b.status != TaskStatus.inProgress) {
          return -1;
        }
        if (b.status == TaskStatus.inProgress && a.status != TaskStatus.inProgress) {
          return 1;
        }
        
        // Then by priority
        final priorityComparison = b.priority.index.compareTo(a.priority.index);
        if (priorityComparison != 0) return priorityComparison;
        
        // Finally by due date
        if (a.dueDate == null && b.dueDate == null) return 0;
        if (a.dueDate == null) return 1;
        if (b.dueDate == null) return -1;
        return a.dueDate!.compareTo(b.dueDate!);
      });
      
      _recentTasks = _myTasks.take(5).toList();
    } catch (e) {
      throw Exception('Failed to load tasks: ${e.toString()}');
    }
  }

  // Load recent time entries
  Future<void> _loadRecentTimeEntries() async {
    try {
      if (_currentUser == null) return;
      
      final entries = await _repository.getTimeEntries(
        // userId: _currentUser!.id,
        startDate: DateTime.now().subtract(const Duration(days: 7)),
      );
      _recentTimeEntries = entries.take(10).toList();
    } catch (e) {
      // Time entries are optional, don't fail the entire dashboard
      debugPrint('Failed to load time entries: ${e.toString()}');
    }
  }

  // Load dashboard statistics
  Future<void> _loadDashboardStats() async {
    _setLoadingStats(true);
    
    try {
      _dashboardStats = await _repository.getDashboardStats();
    } catch (e) {
      debugPrint('Failed to load dashboard stats: ${e.toString()}');
      // Provide fallback stats
      _dashboardStats = {
        'totalProjects': _recentProjects.length,
        'totalTasks': _myTasks.length,
        'completedTasks': _myTasks.where((t) => t.status == TaskStatus.done).length,
        'overdueTasksCount': overdueTasks.length,
        'upcomingTasksCount': upcomingTasks.length,
        'todayHours': todayHoursLogged,
        'weekHours': weekHoursLogged,
      };
    } finally {
      _setLoadingStats(false);
    }
  }

  // NOTIFICATION METHODS
  Future<void> loadNotifications() async {
    _setLoadingNotifications(true);
    _clearError();

    try {
      _notifications = await _repository.getNotifications();
      _notifications.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } catch (e) {
      _setError(_getErrorMessage(e));
    } finally {
      _setLoadingNotifications(false);
    }
  }

  Future<bool> markNotificationAsRead(String id) async {
    try {
      await _repository.markNotificationAsRead(id);
      
      // Update local state
      final index = _notifications.indexWhere((n) => n.id == id);
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

  Future<bool> deleteNotification(String id) async {
    try {
      await _repository.deleteNotification(id);
      
      // Update local state
      _notifications.removeWhere((n) => n.id == id);
      notifyListeners();
      
      return true;
    } catch (e) {
      _setError(_getErrorMessage(e));
      return false;
    }
  }

  // TASK QUICK ACTIONS
  Future<bool> updateTaskStatus(String taskId, TaskStatus newStatus) async {
    try {
      await _repository.updateTask(taskId, {'status': newStatus.name});
      
      // Update local state
      final index = _myTasks.indexWhere((t) => t.id == taskId);
      if (index != -1) {
        _myTasks[index] = _myTasks[index].copyWith(status: newStatus);
        
        // Also update in recent tasks
        final recentIndex = _recentTasks.indexWhere((t) => t.id == taskId);
        if (recentIndex != -1) {
          _recentTasks[recentIndex] = _recentTasks[recentIndex].copyWith(status: newStatus);
        }
        
        notifyListeners();
      }
      
      return true;
    } catch (e) {
      _setError(_getErrorMessage(e));
      return false;
    }
  }

  // REFRESH METHODS
  Future<void> refreshProjects() async {
    await _loadRecentProjects();
    notifyListeners();
  }

  Future<void> refreshTasks() async {
    await _loadMyTasks();
    notifyListeners();
  }

  Future<void> refreshTimeEntries() async {
    await _loadRecentTimeEntries();
    notifyListeners();
  }

  Future<void> refreshAll() async {
    await loadDashboard();
  }

  // UTILITY METHODS
  String getProjectName(String projectId) {
    try {
      return _recentProjects.firstWhere((p) => p.id == projectId).name;
    } catch (e) {
      return 'Unknown Project';
    }
  }

  TaskModel? getTask(String taskId) {
    try {
      return _myTasks.firstWhere((t) => t.id == taskId);
    } catch (e) {
      return null;
    }
  }

  // PRIVATE HELPER METHODS
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setLoadingStats(bool loading) {
    _isLoadingStats = loading;
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

  @override
  void dispose() {
    // Clean up any streams or subscriptions if needed
    super.dispose();
  }
}