// lib/core/constants/app_constants.dart

class AppConstants {
  // App Info
  static const String appName = 'Project Manager';
  static const String appVersion = '1.0.0';
  
  // Storage Keys
  static const String tokenKey = 'auth_token';
  static const String userKey = 'current_user';
  static const String themeKey = 'app_theme';
  
  // Timeouts
  static const int apiTimeout = 30000; // 30 seconds
  static const int refreshInterval = 300000; // 5 minutes
  
  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;
  
  // Validation
  static const int minPasswordLength = 6;
  static const int maxFileSize = 10485760; // 10MB
  
  // Date Formats
  static const String dateFormat = 'yyyy-MM-dd';
  static const String dateTimeFormat = 'yyyy-MM-dd HH:mm';
  static const String displayDateFormat = 'MMM dd, yyyy';
  static const String displayDateTimeFormat = 'MMM dd, yyyy HH:mm';
}

// lib/core/constants/api_endpoints.dart

class ApiEndpoints {
  static const String baseUrl = 'https://api.projectmanager.com';
  static const String apiVersion = '/v1';
  
  // Auth
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String logout = '/auth/logout';
  static const String refreshToken = '/auth/refresh';
  
  // Users
  static const String users = '/users';
  static const String currentUser = '/users/me';
  
  // Projects
  static const String projects = '/projects';
  
  // Tasks
  static const String tasks = '/tasks';
  
  // Comments
  static const String comments = '/comments';
  
  // Notifications
  static const String notifications = '/notifications';
  
  // Dashboard
  static const String dashboard = '/dashboard';
  
  // Export
  static const String exportTasks = '/export/tasks';
}
