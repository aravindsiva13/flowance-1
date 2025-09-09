
// lib/routes/route_generator.dart

import 'package:flutter/material.dart';
import '../presentation/views/common/splash_screen.dart';
import '../presentation/views/auth/login_screen.dart';
import '../presentation/views/auth/register_screen.dart';
import '../presentation/views/common/main_navigation_screen.dart';
import '../presentation/views/dashboard/dashboard_screen.dart';
import '../presentation/views/projects/projects_list_screen.dart';
import '../presentation/views/projects/project_detail_screen.dart';
import '../presentation/views/projects/create_project_screen.dart';
import '../presentation/views/tasks/tasks_list_screen.dart';
import '../presentation/views/tasks/task_detail_screen.dart';
import '../presentation/views/tasks/create_task_screen.dart';
import '../presentation/views/tasks/kanban_board_screen.dart';
import '../presentation/views/profile/profile_screen.dart';
import 'app_routes.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    final args = settings.arguments;

    switch (settings.name) {
      case AppRoutes.splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      
      case AppRoutes.login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      
      case AppRoutes.register:
        return MaterialPageRoute(builder: (_) => const RegisterScreen());
      
      case AppRoutes.main:
        return MaterialPageRoute(builder: (_) => const MainNavigationScreen());
      
      case AppRoutes.dashboard:
        return MaterialPageRoute(builder: (_) => const DashboardScreen());
      
      case AppRoutes.projects:
        return MaterialPageRoute(builder: (_) => const ProjectsListScreen());
      
      case AppRoutes.createProject:
        return MaterialPageRoute(builder: (_) => const CreateProjectScreen());
      
      case AppRoutes.projectDetail:
        if (args is String) {
          return MaterialPageRoute(
            builder: (_) => ProjectDetailScreen(projectId: args),
          );
        }
        return _errorRoute('Project ID is required');
      
      case AppRoutes.tasks:
        final projectId = args as String?;
        return MaterialPageRoute(
          builder: (_) => TasksListScreen(projectId: projectId),
        );
      
      case AppRoutes.createTask:
        final projectId = args as String?;
        return MaterialPageRoute(
          builder: (_) => CreateTaskScreen(projectId: projectId),
        );
      
      case AppRoutes.taskDetail:
        if (args is String) {
          return MaterialPageRoute(
            builder: (_) => TaskDetailScreen(taskId: args),
          );
        }
        return _errorRoute('Task ID is required');
      
      case AppRoutes.kanbanBoard:
        final projectId = args as String?;
        return MaterialPageRoute(
          builder: (_) => KanbanBoardScreen(projectId: projectId),
        );
      
      case AppRoutes.profile:
        return MaterialPageRoute(builder: (_) => const ProfileScreen());
      
      default:
        return _errorRoute('Route not found: ${settings.name}');
    }
  }

  static Route<dynamic> _errorRoute(String message) {
    return MaterialPageRoute(
      builder: (_) => Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                message,
                style: const TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.of(_).pop(),
                child: const Text('Go Back'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}