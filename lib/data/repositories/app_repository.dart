// // lib/data/repositories/app_repository.dart

// import '../models/user_model.dart';
// import '../models/project_model.dart';
// import '../models/task_model.dart';
// import '../models/comment_model.dart';
// import '../models/notification_model.dart';
// import '../services/mock_api_service.dart';

// class AppRepository {
//   static final AppRepository _instance = AppRepository._internal();
//   factory AppRepository() => _instance;
//   AppRepository._internal();

//   final MockApiService _apiService = MockApiService();

//   // Auth Methods
//   Future<Map<String, dynamic>> login(String email, String password) async {
//     try {
//       return await _apiService.login(email, password);
//     } catch (e) {
//       throw Exception('Login failed: ${e.toString()}');
//     }
//   }

//   Future<Map<String, dynamic>> register(String name, String email, String password) async {
//     try {
//       return await _apiService.register(name, email, password);
//     } catch (e) {
//       throw Exception('Registration failed: ${e.toString()}');
//     }
//   }

//   Future<void> logout() async {
//     try {
//       await _apiService.logout();
//     } catch (e) {
//       throw Exception('Logout failed: ${e.toString()}');
//     }
//   }

//   // User Methods
//   Future<UserModel> getCurrentUser() async {
//     try {
//       return await _apiService.getCurrentUser();
//     } catch (e) {
//       throw Exception('Failed to get current user: ${e.toString()}');
//     }
//   }

//   Future<List<UserModel>> getUsers() async {
//     try {
//       return await _apiService.getUsers();
//     } catch (e) {
//       throw Exception('Failed to get users: ${e.toString()}');
//     }
//   }

//   Future<UserModel> getUserById(String id) async {
//     try {
//       return await _apiService.getUserById(id);
//     } catch (e) {
//       throw Exception('Failed to get user: ${e.toString()}');
//     }
//   }

//   Future<UserModel> updateUser(String id, Map<String, dynamic> data) async {
//     try {
//       return await _apiService.updateUser(id, data);
//     } catch (e) {
//       throw Exception('Failed to update user: ${e.toString()}');
//     }
//   }

//   // Project Methods
//   Future<List<ProjectModel>> getProjects() async {
//     try {
//       return await _apiService.getProjects();
//     } catch (e) {
//       throw Exception('Failed to get projects: ${e.toString()}');
//     }
//   }

//   Future<ProjectModel> getProjectById(String id) async {
//     try {
//       return await _apiService.getProjectById(id);
//     } catch (e) {
//       throw Exception('Failed to get project: ${e.toString()}');
//     }
//   }

//   Future<ProjectModel> createProject(Map<String, dynamic> data) async {
//     try {
//       return await _apiService.createProject(data);
//     } catch (e) {
//       throw Exception('Failed to create project: ${e.toString()}');
//     }
//   }

//   Future<ProjectModel> updateProject(String id, Map<String, dynamic> data) async {
//     try {
//       return await _apiService.updateProject(id, data);
//     } catch (e) {
//       throw Exception('Failed to update project: ${e.toString()}');
//     }
//   }

//   Future<void> deleteProject(String id) async {
//     try {
//       await _apiService.deleteProject(id);
//     } catch (e) {
//       throw Exception('Failed to delete project: ${e.toString()}');
//     }
//   }

//   // Task Methods
//   Future<List<TaskModel>> getTasks({String? projectId, String? assigneeId}) async {
//     try {
//       return await _apiService.getTasks(projectId: projectId, assigneeId: assigneeId);
//     } catch (e) {
//       throw Exception('Failed to get tasks: ${e.toString()}');
//     }
//   }

//   Future<TaskModel> getTaskById(String id) async {
//     try {
//       return await _apiService.getTaskById(id);
//     } catch (e) {
//       throw Exception('Failed to get task: ${e.toString()}');
//     }
//   }

//   Future<TaskModel> createTask(Map<String, dynamic> data) async {
//     try {
//       return await _apiService.createTask(data);
//     } catch (e) {
//       throw Exception('Failed to create task: ${e.toString()}');
//     }
//   }

//   Future<TaskModel> updateTask(String id, Map<String, dynamic> data) async {
//     try {
//       return await _apiService.updateTask(id, data);
//     } catch (e) {
//       throw Exception('Failed to update task: ${e.toString()}');
//     }
//   }

//   Future<void> deleteTask(String id) async {
//     try {
//       await _apiService.deleteTask(id);
//     } catch (e) {
//       throw Exception('Failed to delete task: ${e.toString()}');
//     }
//   }

//   // Comment Methods
//   Future<List<CommentModel>> getComments(String taskId) async {
//     try {
//       return await _apiService.getComments(taskId);
//     } catch (e) {
//       throw Exception('Failed to get comments: ${e.toString()}');
//     }
//   }

//   Future<CommentModel> createComment(Map<String, dynamic> data) async {
//     try {
//       return await _apiService.createComment(data);
//     } catch (e) {
//       throw Exception('Failed to create comment: ${e.toString()}');
//     }
//   }

//   // Notification Methods
//   Future<List<NotificationModel>> getNotifications() async {
//     try {
//       return await _apiService.getNotifications();
//     } catch (e) {
//       throw Exception('Failed to get notifications: ${e.toString()}');
//     }
//   }

//   Future<NotificationModel> markNotificationAsRead(String id) async {
//     try {
//       return await _apiService.markNotificationAsRead(id);
//     } catch (e) {
//       throw Exception('Failed to mark notification as read: ${e.toString()}');
//     }
//   }

//   Future<void> markAllNotificationsAsRead() async {
//     try {
//       await _apiService.markAllNotificationsAsRead();
//     } catch (e) {
//       throw Exception('Failed to mark all notifications as read: ${e.toString()}');
//     }
//   }

//   // Dashboard Methods
//   Future<Map<String, dynamic>> getDashboardStats() async {
//     try {
//       return await _apiService.getDashboardStats();
//     } catch (e) {
//       throw Exception('Failed to get dashboard stats: ${e.toString()}');
//     }
//   }

//   // Export Methods
//   Future<List<Map<String, dynamic>>> getTasksForExport({String? projectId}) async {
//     try {
//       return await _apiService.getTasksForExport(projectId: projectId);
//     } catch (e) {
//       throw Exception('Failed to get tasks for export: ${e.toString()}');
//     }
//   }

//   // Search Methods
//   Future<List<TaskModel>> searchTasks(String query) async {
//     try {
//       return await _apiService.searchTasks(query);
//     } catch (e) {
//       throw Exception('Failed to search tasks: ${e.toString()}');
//     }
//   }

//   Future<List<ProjectModel>> searchProjects(String query) async {
//     try {
//       return await _apiService.searchProjects(query);
//     } catch (e) {
//       throw Exception('Failed to search projects: ${e.toString()}');
//     }
//   }
// }


//2




// lib/data/repositories/app_repository.dart

import '../models/user_model.dart';
import '../models/project_model.dart';
import '../models/task_model.dart';
import '../models/comment_model.dart';
import '../models/notification_model.dart';
import '../models/time_entry_model.dart';
import '../services/mock_api_service.dart';
import '../../core/enums/project_status.dart';
import '../../core/enums/task_status.dart';
import '../../core/enums/task_priority.dart';

class AppRepository {
  static final AppRepository _instance = AppRepository._internal();
  factory AppRepository() => _instance;
  AppRepository._internal();

  final MockApiService _apiService = MockApiService();

  // AUTH METHODS
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      return await _apiService.login(email, password);
    } catch (e) {
      throw Exception('Login failed: ${e.toString()}');
    }
  }

  Future<Map<String, dynamic>> register(String name, String email, String password) async {
    try {
      return await _apiService.register(name, email, password);
    } catch (e) {
      throw Exception('Registration failed: ${e.toString()}');
    }
  }

  Future<void> logout() async {
    try {
      await _apiService.logout();
    } catch (e) {
      throw Exception('Logout failed: ${e.toString()}');
    }
  }

  // USER METHODS
  Future<UserModel> getCurrentUser() async {
    try {
      return await _apiService.getCurrentUser();
    } catch (e) {
      throw Exception('Failed to get current user: ${e.toString()}');
    }
  }

  Future<List<UserModel>> getUsers() async {
    try {
      return await _apiService.getUsers();
    } catch (e) {
      throw Exception('Failed to get users: ${e.toString()}');
    }
  }

  Future<UserModel> getUserById(String id) async {
    try {
      return await _apiService.getUserById(id);
    } catch (e) {
      throw Exception('Failed to get user: ${e.toString()}');
    }
  }

  // PROJECT METHODS
  Future<List<ProjectModel>> getProjects({
    ProjectStatus? status,
    String? ownerId,
  }) async {
    try {
      return await _apiService.getProjects(status: status, ownerId: ownerId);
    } catch (e) {
      throw Exception('Failed to get projects: ${e.toString()}');
    }
  }

  Future<ProjectModel> getProjectById(String id) async {
    try {
      return await _apiService.getProjectById(id);
    } catch (e) {
      throw Exception('Failed to get project: ${e.toString()}');
    }
  }

  Future<ProjectModel> createProject(Map<String, dynamic> data) async {
    try {
      final project = ProjectModel(
        id: '', 
        name: data['name'] as String,
        description: data['description'] as String? ?? '',
        status: data['status'] as ProjectStatus? ?? ProjectStatus.active,
        ownerId: data['ownerId'] as String,
        memberIds: List<String>.from(data['memberIds'] ?? []),
        startDate: data['startDate'] as DateTime? ?? DateTime.now(),
        dueDate: data['dueDate'] as DateTime?,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        progress: data['progress'] as double? ?? 0.0,
      );
      return await _apiService.createProject(project);
    } catch (e) {
      throw Exception('Failed to create project: ${e.toString()}');
    }
  }

  Future<ProjectModel> updateProject(String id, Map<String, dynamic> data) async {
    try {
      final currentProject = await _apiService.getProjectById(id);
      final updatedProject = currentProject.copyWith(
        name: data['name'],
        description: data['description'],
        status: data['status'],
        dueDate: data['dueDate'],
        progress: data['progress'],
      );
      return await _apiService.updateProject(id, updatedProject);
    } catch (e) {
      throw Exception('Failed to update project: ${e.toString()}');
    }
  }

  Future<void> deleteProject(String id) async {
    try {
      await _apiService.deleteProject(id);
    } catch (e) {
      throw Exception('Failed to delete project: ${e.toString()}');
    }
  }

  // TASK METHODS
  Future<List<TaskModel>> getTasks({
    String? projectId,
    TaskStatus? status,
    TaskPriority? priority,
    String? assigneeId,
  }) async {
    try {
      return await _apiService.getTasks(
        projectId: projectId,
        status: status,
        priority: priority,
        assigneeId: assigneeId,
      );
    } catch (e) {
      throw Exception('Failed to get tasks: ${e.toString()}');
    }
  }

  Future<TaskModel> getTaskById(String id) async {
    try {
      return await _apiService.getTaskById(id);
    } catch (e) {
      throw Exception('Failed to get task: ${e.toString()}');
    }
  }

  Future<TaskModel> createTask(Map<String, dynamic> data) async {
    try {
      final task = TaskModel(
        id: '',
        title: data['title'] as String,
        description: data['description'] as String? ?? '',
        status: data['status'] as TaskStatus? ?? TaskStatus.toDo,
        priority: data['priority'] as TaskPriority? ?? TaskPriority.medium,
        projectId: data['projectId'] as String,
        creatorId: data['creatorId'] as String,
        assigneeId: data['assigneeId'] as String?,
        dueDate: data['dueDate'] as DateTime?,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      return await _apiService.createTask(task);
    } catch (e) {
      throw Exception('Failed to create task: ${e.toString()}');
    }
  }

  Future<TaskModel> updateTask(String id, Map<String, dynamic> data) async {
    try {
      final currentTask = await _apiService.getTaskById(id);
      final updatedTask = currentTask.copyWith(
        title: data['title'],
        description: data['description'],
        status: data['status'],
        priority: data['priority'],
        assigneeId: data['assigneeId'],
        dueDate: data['dueDate'],
      );
      return await _apiService.updateTask(id, updatedTask);
    } catch (e) {
      throw Exception('Failed to update task: ${e.toString()}');
    }
  }

  Future<void> deleteTask(String id) async {
    try {
      await _apiService.deleteTask(id);
    } catch (e) {
      throw Exception('Failed to delete task: ${e.toString()}');
    }
  }

  Future<List<Map<String, dynamic>>> getTasksForExport({String? projectId}) async {
    try {
      final tasks = await _apiService.getTasks(projectId: projectId);
      return tasks.map((task) => {
        'ID': task.id,
        'Title': task.title,
        'Description': task.description,
        'Status': task.status.displayName,
        'Priority': task.priority.displayName,
        'Project ID': task.projectId,
        'Assignee ID': task.assigneeId ?? '',
        'Due Date': task.dueDate?.toIso8601String() ?? '',
        'Created At': task.createdAt.toIso8601String(),
        'Updated At': task.updatedAt.toIso8601String(),
      }).toList();
    } catch (e) {
      throw Exception('Failed to get tasks for export: ${e.toString()}');
    }
  }

  // COMMENT METHODS
  Future<List<CommentModel>> getComments(String taskId) async {
    try {
      return await _apiService.getComments(taskId);
    } catch (e) {
      throw Exception('Failed to get comments: ${e.toString()}');
    }
  }

  Future<CommentModel> createComment(Map<String, dynamic> data) async {
    try {
      final comment = CommentModel(
        id: '',
        taskId: data['taskId'] as String,
        authorId: data['authorId'] as String,
        content: data['content'] as String,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        mentions: data['mentions'] != null ? List<String>.from(data['mentions']) : [],
      );
      return await _apiService.createComment(comment);
    } catch (e) {
      throw Exception('Failed to create comment: ${e.toString()}');
    }
  }

  // NOTIFICATION METHODS
  Future<List<NotificationModel>> getNotifications() async {
    try {
      return await _apiService.getNotifications();
    } catch (e) {
      throw Exception('Failed to get notifications: ${e.toString()}');
    }
  }

  Future<NotificationModel> markNotificationAsRead(String id) async {
    try {
      return await _apiService.markNotificationAsRead(id);
    } catch (e) {
      throw Exception('Failed to mark notification as read: ${e.toString()}');
    }
  }

  Future<void> markAllNotificationsAsRead() async {
    try {
      await _apiService.markAllNotificationsAsRead();
    } catch (e) {
      throw Exception('Failed to mark all notifications as read: ${e.toString()}');
    }
  }

  // TIME TRACKING METHODS
  Future<List<TimeEntryModel>> getTimeEntries({
    DateTime? startDate,
    DateTime? endDate,
    String? projectId,
    String? taskId,
  }) async {
    try {
      return await _apiService.getTimeEntries(
        startDate: startDate,
        endDate: endDate,
        projectId: projectId,
        taskId: taskId,
      );
    } catch (e) {
      throw Exception('Failed to get time entries: ${e.toString()}');
    }
  }

  Future<TimeEntryModel> startTimeEntry({
    required String taskId,
    required String projectId,
    required String description,
  }) async {
    try {
      return await _apiService.startTimeEntry(
        taskId: taskId,
        projectId: projectId,
        description: description,
      );
    } catch (e) {
      throw Exception('Failed to start time entry: ${e.toString()}');
    }
  }

  Future<TimeEntryModel> stopTimeEntry(String entryId) async {
    try {
      return await _apiService.stopTimeEntry(entryId);
    } catch (e) {
      throw Exception('Failed to stop time entry: ${e.toString()}');
    }
  }
Future<void> deleteNotification(String id) async {
  try {
    await _apiService.deleteNotification(id);
  } catch (e) {
    throw Exception('Failed to delete notification: ${e.toString()}');
  }
}
  Future<TimeEntryModel> createManualTimeEntry({
    required String taskId,
    required String projectId,
    required String description,
    required DateTime startTime,
    required DateTime endTime,
  }) async {
    try {
      return await _apiService.createManualTimeEntry(
        taskId: taskId,
        projectId: projectId,
        description: description,
        startTime: startTime,
        endTime: endTime,
      );
    } catch (e) {
      throw Exception('Failed to create manual time entry: ${e.toString()}');
    }
  }
Future<UserModel> updateUser(String id, Map<String, dynamic> data) async {
    try {
      final currentUser = await _apiService.getUserById(id);
      final updatedUser = currentUser.copyWith(
        name: data['name'],
        email: data['email'],
      );
      return updatedUser;
    } catch (e) {
      throw Exception('Failed to update user: ${e.toString()}');
    }
  }
  Future<TimeEntryModel> updateTimeEntry(
    String entryId, {
    String? description,
    DateTime? startTime,
    DateTime? endTime,
  }) async {
    try {
      return await _apiService.updateTimeEntry(
        entryId,
        description: description,
        startTime: startTime,
        endTime: endTime,
      );
    } catch (e) {
      throw Exception('Failed to update time entry: ${e.toString()}');
    }
  }

  Future<void> deleteTimeEntry(String entryId) async {
    try {
      await _apiService.deleteTimeEntry(entryId);
    } catch (e) {
      throw Exception('Failed to delete time entry: ${e.toString()}');
    }
  }

  Future<TimeEntryModel?> getActiveTimeEntry() async {
    try {
      return await _apiService.getActiveTimeEntry();
    } catch (e) {
      throw Exception('Failed to get active time entry: ${e.toString()}');
    }
  }

  Future<Map<String, dynamic>> getTimeTrackingStats({
    DateTime? startDate,
    DateTime? endDate,
    String? projectId,
  }) async {
    try {
      return await _apiService.getTimeTrackingStats(
        startDate: startDate,
        endDate: endDate,
        projectId: projectId,
      );
    } catch (e) {
      throw Exception('Failed to get time tracking stats: ${e.toString()}');
    }
  }

  Future<List<Map<String, dynamic>>> getTimeEntriesForExport({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      return await _apiService.getTimeEntriesForExport(
        startDate: startDate,
        endDate: endDate,
      );
    } catch (e) {
      throw Exception('Failed to get time entries for export: ${e.toString()}');
    }
  }

  // DASHBOARD METHODS
  Future<Map<String, dynamic>> getDashboardStats() async {
    try {
      return await _apiService.getDashboardStats();
    } catch (e) {
      throw Exception('Failed to get dashboard stats: ${e.toString()}');
    }
  }

  Future<Map<String, dynamic>> getProjectAnalytics({String? projectId}) async {
    try {
      return await _apiService.getProjectAnalytics(projectId: projectId);
    } catch (e) {
      throw Exception('Failed to get project analytics: ${e.toString()}');
    }
  }
}