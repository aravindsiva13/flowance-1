// // lib/routes/route_generator.dart - Updated with new routes

// import 'package:flutter/material.dart';
// import '../presentation/views/common/splash_screen.dart';
// import '../presentation/views/auth/login_screen.dart';
// import '../presentation/views/auth/register_screen.dart';
// import '../presentation/views/common/main_navigation_screen.dart';
// import '../presentation/views/dashboard/dashboard_screen.dart';
// import '../presentation/views/projects/projects_list_screen.dart';
// import '../presentation/views/projects/project_detail_screen.dart';
// import '../presentation/views/projects/create_project_screen.dart';
// import '../presentation/views/tasks/tasks_list_screen.dart';
// import '../presentation/views/tasks/task_detail_screen.dart';
// import '../presentation/views/tasks/create_task_screen.dart';
// import '../presentation/views/tasks/edit_task_screen.dart'; // NEW
// import '../presentation/views/tasks/kanban_board_screen.dart';
// import '../presentation/views/profile/profile_screen.dart';
// import '../presentation/views/common/search_screen.dart'; // NEW
// import 'app_routes.dart';

// class RouteGenerator {
//   static Route<dynamic> generateRoute(RouteSettings settings) {
//     final args = settings.arguments;

//     switch (settings.name) {
//       case AppRoutes.splash:
//         return MaterialPageRoute(builder: (_) => const SplashScreen());
      
//       case AppRoutes.login:
//         return MaterialPageRoute(builder: (_) => const LoginScreen());
      
//       case AppRoutes.register:
//         return MaterialPageRoute(builder: (_) => const RegisterScreen());
      
//       case AppRoutes.main:
//         return MaterialPageRoute(builder: (_) => const MainNavigationScreen());
      
//       case AppRoutes.dashboard:
//         return MaterialPageRoute(builder: (_) => const DashboardScreen());
      
//       case AppRoutes.projects:
//         return MaterialPageRoute(builder: (_) => const ProjectsListScreen());
      
//       case AppRoutes.createProject:
//         return MaterialPageRoute(builder: (_) => const CreateProjectScreen());
      
//       case AppRoutes.projectDetail:
//         if (args is String) {
//           return MaterialPageRoute(
//             builder: (_) => ProjectDetailScreen(projectId: args),
//           );
//         }
//         return _errorRoute('Project ID is required');
      
//       case AppRoutes.tasks:
//         final projectId = args as String?;
//         return MaterialPageRoute(
//           builder: (_) => TasksListScreen(projectId: projectId),
//         );
      
//       case AppRoutes.createTask:
//         final projectId = args as String?;
//         return MaterialPageRoute(
//           builder: (_) => CreateTaskScreen(projectId: projectId),
//         );
      
//       case AppRoutes.taskDetail:
//         if (args is String) {
//           return MaterialPageRoute(
//             builder: (_) => TaskDetailScreen(taskId: args),
//           );
//         }
//         return _errorRoute('Task ID is required');
      
//       case AppRoutes.editTask: // NEW
//         if (args is String) {
//           return MaterialPageRoute(
//             builder: (_) => EditTaskScreen(taskId: args),
//           );
//         }
//         return _errorRoute('Task ID is required');
      
//       case AppRoutes.kanbanBoard:
//         final projectId = args as String?;
//         return MaterialPageRoute(
//           builder: (_) => KanbanBoardScreen(projectId: projectId),
//         );
      
//       case AppRoutes.profile:
//         return MaterialPageRoute(builder: (_) => const ProfileScreen());
      
//       case AppRoutes.search: // NEW
//         return MaterialPageRoute(builder: (_) => const SearchScreen());
      
//       default:
//         return _errorRoute('Route not found: ${settings.name}');
//     }
//   }

//   static Route<dynamic> _errorRoute(String message) {
//     return MaterialPageRoute(
//       builder: (_) => Scaffold(
//         appBar: AppBar(title: const Text('Error')),
//         body: Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               const Icon(Icons.error, size: 64, color: Colors.red),
//               const SizedBox(height: 16),
//               Text(
//                 message,
//                 style: const TextStyle(fontSize: 18),
//                 textAlign: TextAlign.center,
//               ),
//               const SizedBox(height: 16),
//               ElevatedButton(
//                 onPressed: () => Navigator.of(_).pop(),
//                 child: const Text('Go Back'),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

//2



// lib/routes/route_generator.dart - COMPLETE INTEGRATION

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
import '../presentation/views/time/timesheet_screen.dart';
import '../presentation/views/time/time_reports_screen.dart';
import '../presentation/views/notifications/notifications_screen.dart';
import '../presentation/views/common/search_screen.dart';
import '../presentation/views/profile/profile_screen.dart';
import 'app_routes.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    final args = settings.arguments;

    switch (settings.name) {
      // Auth and main navigation
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

      // Project routes
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

      // Task routes
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

      // Time tracking routes
      case AppRoutes.timesheet:
        return MaterialPageRoute(builder: (_) => const TimesheetScreen());
      
      case AppRoutes.timeReports:
        return MaterialPageRoute(builder: (_) => const TimeReportsScreen());

      // Notification routes  
      case AppRoutes.notifications:
        return MaterialPageRoute(builder: (_) => const NotificationsScreen());

      // Search and utility routes
      case AppRoutes.search:
        return MaterialPageRoute(builder: (_) => const SearchScreen());

      // Profile routes
      case AppRoutes.profile:
        return MaterialPageRoute(builder: (_) => const ProfileScreen());

      // Calendar route (if implemented)
      case AppRoutes.calendar:
        return MaterialPageRoute(
          builder: (_) => _buildPlaceholderScreen('Calendar', 'Calendar view coming soon'),
        );

      // Settings routes (if needed)
      case AppRoutes.settings:
        return MaterialPageRoute(
          builder: (_) => _buildPlaceholderScreen('Settings', 'Settings coming soon'),
        );

      // Team routes (if needed)
      case AppRoutes.team:
        return MaterialPageRoute(
          builder: (_) => _buildPlaceholderScreen('Team', 'Team management coming soon'),
        );

      // Activity routes (if needed)
      case AppRoutes.activity:
        return MaterialPageRoute(
          builder: (_) => _buildPlaceholderScreen('Activity', 'Activity feed coming soon'),
        );

      // Help routes (if needed)
      case AppRoutes.help:
        return MaterialPageRoute(
          builder: (_) => _buildPlaceholderScreen('Help', 'Help center coming soon'),
        );

      case AppRoutes.about:
        return MaterialPageRoute(
          builder: (_) => _buildAboutScreen(),
        );

      // Error handling
      default:
        return _errorRoute('Route not found: ${settings.name}');
    }
  }

  static Route<dynamic> _errorRoute(String message) {
    return MaterialPageRoute(
      builder: (_) => Scaffold(
        appBar: AppBar(
          title: const Text('Error'),
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 80,
                  color: Colors.red,
                ),
                const SizedBox(height: 24),
                Text(
                  'Oops! Something went wrong',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  message,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                ElevatedButton.icon(
                  onPressed: () => Navigator.of(_).pop(),
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Go Back'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static Widget _buildPlaceholderScreen(String title, String message) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: const Color(0xFF2196F3),
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.construction,
                size: 80,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 24),
              Text(
                title,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                message,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              Builder(
  builder: (context) => ElevatedButton(
    onPressed: () => Navigator.pop(context),
    child: const Text('Go Back'),
  ),
),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _buildAboutScreen() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About'),
        backgroundColor: const Color(0xFF2196F3),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 32),
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: const Color(0xFF2196F3),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.speed,
                size: 60,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Flowence',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2196F3),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Project Management Made Simple',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'Version 1.0.0',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 32),
            const Expanded(
              child: Column(
                children: [
                  ListTile(
                    leading: Icon(Icons.check_circle, color: Colors.green),
                    title: Text('Project Management'),
                    subtitle: Text('Create and manage projects efficiently'),
                  ),
                  ListTile(
                    leading: Icon(Icons.task_alt, color: Colors.blue),
                    title: Text('Task Tracking'),
                    subtitle: Text('Track tasks with Kanban boards'),
                  ),
                  ListTile(
                    leading: Icon(Icons.access_time, color: Colors.orange),
                    title: Text('Time Tracking'),
                    subtitle: Text('Monitor time spent on tasks'),
                  ),
                  ListTile(
                    leading: Icon(Icons.group, color: Colors.purple),
                    title: Text('Team Collaboration'),
                    subtitle: Text('Work together seamlessly'),
                  ),
                ],
              ),
            ),
            Text(
              '© 2024 Flowence. All rights reserved.',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }
}