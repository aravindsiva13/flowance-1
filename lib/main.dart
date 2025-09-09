// lib/main.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'presentation/viewmodels/auth_viewmodel.dart';
import 'presentation/viewmodels/dashboard_viewmodel.dart';
import 'presentation/viewmodels/project_viewmodel.dart';
import 'presentation/viewmodels/task_viewmodel.dart';
import 'presentation/viewmodels/user_viewmodel.dart';
import 'routes/app_routes.dart';
import 'routes/route_generator.dart';
import 'core/constants/app_colors.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
        ChangeNotifierProvider(create: (_) => DashboardViewModel()),
        ChangeNotifierProvider(create: (_) => ProjectViewModel()),
        ChangeNotifierProvider(create: (_) => TaskViewModel()),
        ChangeNotifierProvider(create: (_) => UserViewModel()),
      ],
      child: MaterialApp(
        title: 'Project Manager',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          primaryColor: AppColors.primaryBlue,
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppColors.primaryBlue,
            brightness: Brightness.light,
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: AppColors.primaryBlue,
            foregroundColor: Colors.white,
            elevation: 2,
          ),
          cardTheme: CardTheme(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
          useMaterial3: true,
        ),
        initialRoute: AppRoutes.splash,
        onGenerateRoute: RouteGenerator.generateRoute,
      ),
    );
  }
}

// lib/routes/app_routes.dart

class AppRoutes {
  // Auth routes
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  
  // Main navigation
  static const String main = '/main';
  static const String dashboard = '/dashboard';
  
  // Project routes
  static const String projects = '/projects';
  static const String projectDetail = '/project-detail';
  static const String createProject = '/create-project';
  
  // Task routes
  static const String tasks = '/tasks';
  static const String taskDetail = '/task-detail';
  static const String createTask = '/create-task';
  static const String kanbanBoard = '/kanban-board';
  
  // User routes
  static const String profile = '/profile';
  
  // Utility routes
  static const String settings = '/settings';
  static const String notifications = '/notifications';
}
