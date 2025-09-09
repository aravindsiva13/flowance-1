// lib/data/repositories/app_repository.dart

import '../models/user_model.dart';
import '../models/project_model.dart';
import '../models/task_model.dart';
import '../models/comment_model.dart';
import '../models/notification_model.dart';
import '../services/mock_api_service.dart';

class AppRepository {
  static final AppRepository _instance = AppRepository._internal();
  factory AppRepository() => _instance;
  AppRepository._internal();

  final MockApiService _apiService = MockApiService();

  // Auth Methods
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

  // User Methods
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

  Future<UserModel> updateUser(String id, Map<String, dynamic> data) async {
    try {
      return await _apiService.updateUser(id, data);
    } catch (e) {
      throw Exception('Failed to update user: ${e.toString()}');
    }
  }

  // Project Methods
  Future<List<ProjectModel>> getProjects() async {
    try {
      return await _apiService.getProjects();
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
      return await _apiService.createProject(data);
    } catch (e) {
      throw Exception('Failed to create project: ${e.toString()}');
    }
  }

  Future<ProjectModel> updateProject(String id, Map<String, dynamic> data) async {
    try {
      return await _apiService.updateProject(id, data);
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

  // Task Methods
  Future<List<TaskModel>> getTasks({String? projectId, String? assigneeId}) async {
    try {
      return await _apiService.getTasks(projectId: projectId, assigneeId: assigneeId);
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
      return await _apiService.createTask(data);
    } catch (e) {
      throw Exception('Failed to create task: ${e.toString()}');
    }
  }

  Future<TaskModel> updateTask(String id, Map<String, dynamic> data) async {
    try {
      return await _apiService.updateTask(id, data);
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

  // Comment Methods
  Future<List<CommentModel>> getComments(String taskId) async {
    try {
      return await _apiService.getComments(taskId);
    } catch (e) {
      throw Exception('Failed to get comments: ${e.toString()}');
    }
  }

  Future<CommentModel> createComment(Map<String, dynamic> data) async {
    try {
      return await _apiService.createComment(data);
    } catch (e) {
      throw Exception('Failed to create comment: ${e.toString()}');
    }
  }

  // Notification Methods
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

  // Dashboard Methods
  Future<Map<String, dynamic>> getDashboardStats() async {
    try {
      return await _apiService.getDashboardStats();
    } catch (e) {
      throw Exception('Failed to get dashboard stats: ${e.toString()}');
    }
  }

  // Export Methods
  Future<List<Map<String, dynamic>>> getTasksForExport({String? projectId}) async {
    try {
      return await _apiService.getTasksForExport(projectId: projectId);
    } catch (e) {
      throw Exception('Failed to get tasks for export: ${e.toString()}');
    }
  }

  // Search Methods
  Future<List<TaskModel>> searchTasks(String query) async {
    try {
      return await _apiService.searchTasks(query);
    } catch (e) {
      throw Exception('Failed to search tasks: ${e.toString()}');
    }
  }

  Future<List<ProjectModel>> searchProjects(String query) async {
    try {
      return await _apiService.searchProjects(query);
    } catch (e) {
      throw Exception('Failed to search projects: ${e.toString()}');
    }
  }
}