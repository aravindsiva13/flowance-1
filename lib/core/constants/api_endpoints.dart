// lib/core/constants/api_endpoints.dart
class ApiEndpoints {
  static const String baseUrl = 'https://api.projectmanager.com';
  static const String apiVersion = '/v1';
  
  // Auth endpoints
  static const String login = '$baseUrl$apiVersion/auth/login';
  static const String register = '$baseUrl$apiVersion/auth/register';
  static const String logout = '$baseUrl$apiVersion/auth/logout';
  static const String refreshToken = '$baseUrl$apiVersion/auth/refresh';
  
  // User endpoints
  static const String users = '$baseUrl$apiVersion/users';
  static const String currentUser = '$baseUrl$apiVersion/users/me';
  
  // Project endpoints
  static const String projects = '$baseUrl$apiVersion/projects';
  static String projectById(String id) => '$projects/$id';
  
  // Task endpoints
  static const String tasks = '$baseUrl$apiVersion/tasks';
  static String taskById(String id) => '$tasks/$id';
  static String tasksByProject(String projectId) => '$tasks?projectId=$projectId';
  
  // Comment endpoints
  static const String comments = '$baseUrl$apiVersion/comments';
  static String commentsByTask(String taskId) => '$comments?taskId=$taskId';
  
  // Notification endpoints
  static const String notifications = '$baseUrl$apiVersion/notifications';
  static String markNotificationRead(String id) => '$notifications/$id/read';
  static const String markAllNotificationsRead = '$notifications/mark-all-read';
  
  // Dashboard endpoints
  static const String dashboardStats = '$baseUrl$apiVersion/dashboard/stats';
  
  // Export endpoints
  static const String exportTasks = '$baseUrl$apiVersion/export/tasks';
  static String exportProjectTasks(String projectId) => '$exportTasks?projectId=$projectId';
}
