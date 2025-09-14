// // lib/presentation/views/common/main_navigation_screen.dart - FIXED VERSION

// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../dashboard/dashboard_screen.dart';
// import '../projects/projects_list_screen.dart';
// import '../tasks/tasks_list_screen.dart';
// import '../profile/profile_screen.dart';
// import '../../viewmodels/auth_viewmodel.dart';
// import '../../viewmodels/dashboard_viewmodel.dart';
// import '../../../routes/app_routes.dart';
// import '../../../core/constants/app_colors.dart';

// class MainNavigationScreen extends StatefulWidget {
//   const MainNavigationScreen({Key? key}) : super(key: key);

//   @override
//   State<MainNavigationScreen> createState() => _MainNavigationScreenState();
// }

// class _MainNavigationScreenState extends State<MainNavigationScreen> {
//   int _selectedIndex = 0;
  
//   late final List<Widget> _screens;
  
//   @override
//   void initState() {
//     super.initState();
//     _screens = [
//       const DashboardScreen(),
//       const ProjectsListScreen(),
//       const TasksListScreen(),
//       const ProfileScreen(),
//     ];
    
//     // Load initial data after the widget is built
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       context.read<DashboardViewModel>().loadDashboard();
//     });
//   }

//   void _onItemTapped(int index) {
//     setState(() {
//       _selectedIndex = index;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: _buildAppBar(),
//       body: IndexedStack(
//         index: _selectedIndex,
//         children: _screens,
//       ),
//       bottomNavigationBar: BottomNavigationBar(
//         currentIndex: _selectedIndex,
//         onTap: _onItemTapped,
//         type: BottomNavigationBarType.fixed,
//         selectedItemColor: AppColors.primaryBlue,
//         unselectedItemColor: AppColors.textSecondary,
//         items: const [
//           BottomNavigationBarItem(
//             icon: Icon(Icons.dashboard_rounded),
//             label: 'Dashboard',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.folder_rounded),
//             label: 'Projects',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.task_alt_rounded),
//             label: 'Tasks',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.person_rounded),
//             label: 'Profile',
//           ),
//         ],
//       ),
//       floatingActionButton: _buildFloatingActionButton(),
//     );
//   }

//   PreferredSizeWidget? _buildAppBar() {
//     // Only show app bar on screens that need it (not Dashboard)
//     if (_selectedIndex == 0) return null; // Dashboard has its own app bar
    
//     String title = '';
//     switch (_selectedIndex) {
//       case 1:
//         title = 'Projects';
//         break;
//       case 2:
//         title = 'Tasks';
//         break;
//       case 3:
//         title = 'Profile';
//         break;
//     }

//     return AppBar(
//       title: Text(title),
//       backgroundColor: AppColors.primaryBlue,
//       foregroundColor: Colors.white,
//       actions: [
//         // Search action for projects and tasks tabs
//         if (_selectedIndex == 1 || _selectedIndex == 2)
//           IconButton(
//             onPressed: () {
//               Navigator.pushNamed(context, AppRoutes.search);
//             },
//             icon: const Icon(Icons.search_rounded),
//             tooltip: 'Search',
//           ),
//       ],
//     );
//   }

//   Widget? _buildFloatingActionButton() {
//     final authViewModel = context.watch<AuthViewModel>();
    
//     // Show FAB based on current tab and user permissions
//     switch (_selectedIndex) {
//       case 1: // Projects tab
//         if (authViewModel.hasPermission(Permission.createProject)) {
//           return FloatingActionButton(
//             heroTag: "main_nav_create_project_fab", // FIXED: Unique hero tag
//             onPressed: () {
//               Navigator.pushNamed(context, AppRoutes.createProject);
//             },
//             backgroundColor: AppColors.primaryBlue,
//             child: const Icon(Icons.add, color: Colors.white),
//           );
//         }
//         break;
//       case 2: // Tasks tab
//         return FloatingActionButton(
//           heroTag: "main_nav_create_task_fab", // FIXED: Unique hero tag
//           onPressed: () {
//             Navigator.pushNamed(context, AppRoutes.createTask);
//           },
//           backgroundColor: AppColors.primaryBlue,
//           child: const Icon(Icons.add_task, color: Colors.white),
//         );
//     }
    
//     return null;
//   }
// }


//2


// lib/presentation/views/common/main_navigation_screen.dart - COMPLETE INTEGRATION

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../dashboard/dashboard_screen.dart';
import '../projects/projects_list_screen.dart';
import '../tasks/tasks_list_screen.dart';
import '../time/timesheet_screen.dart';
import '../profile/profile_screen.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/dashboard_viewmodel.dart';
import '../../viewmodels/time_tracking_viewmodel.dart';
import '../../../routes/app_routes.dart';
import '../../../core/constants/app_colors.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({Key? key}) : super(key: key);

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;
  
  late final List<Widget> _screens;
  
  @override
  void initState() {
    super.initState();
    _screens = [
      const DashboardScreen(),
      const ProjectsListScreen(),
      const TasksListScreen(),
      const TimesheetScreen(), // ADDED: Time tracking integration
      const ProfileScreen(),
    ];
    
    // Load initial data after the widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final dashboardVM = context.read<DashboardViewModel>();
      final timeTrackingVM = context.read<TimeTrackingViewModel>();
      
      dashboardVM.loadDashboard();
      timeTrackingVM.loadTimeEntries(); // ADDED: Load time tracking data
      timeTrackingVM.loadSupportingData();
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    
    // Load specific data when switching to time tracking tab
    if (index == 3) {
      final timeTrackingVM = context.read<TimeTrackingViewModel>();
      timeTrackingVM.loadTimeEntries();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primaryBlue,
        unselectedItemColor: AppColors.textSecondary,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_rounded),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.folder_rounded),
            label: 'Projects',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.task_alt_rounded),
            label: 'Tasks',
          ),
          BottomNavigationBarItem( // ADDED: Time tracking tab
            icon: Icon(Icons.access_time_rounded),
            label: 'Time',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_rounded),
            label: 'Profile',
          ),
        ],
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  PreferredSizeWidget? _buildAppBar() {
    // Only show app bar on screens that need it (not Dashboard)
    if (_selectedIndex == 0) return null; // Dashboard has its own app bar
    
    String title = '';
    List<Widget> actions = [];
    
    switch (_selectedIndex) {
      case 1:
        title = 'Projects';
        actions = [_buildSearchButton()];
        break;
      case 2:
        title = 'Tasks';
        actions = [_buildSearchButton()];
        break;
      case 3: // ADDED: Time tracking app bar
        title = 'Time Tracking';
        actions = [
          IconButton(
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.timeReports);
            },
            icon: const Icon(Icons.analytics_rounded),
            tooltip: 'Reports',
          ),
        ];
        break;
      case 4:
        title = 'Profile';
        actions = [_buildNotificationButton()];
        break;
    }

    return AppBar(
      title: Text(title),
      backgroundColor: AppColors.primaryBlue,
      foregroundColor: Colors.white,
      actions: actions,
    );
  }

  Widget _buildSearchButton() {
    return IconButton(
      onPressed: () {
        Navigator.pushNamed(context, AppRoutes.search);
      },
      icon: const Icon(Icons.search_rounded),
      tooltip: 'Search',
    );
  }

  Widget _buildNotificationButton() {
    return Consumer<DashboardViewModel>(
      builder: (context, dashboardVM, child) {
        final unreadCount = dashboardVM.unreadNotificationsCount;
        
        return Stack(
          children: [
            IconButton(
              onPressed: () {
                Navigator.pushNamed(context, AppRoutes.notifications);
              },
              icon: const Icon(Icons.notifications_rounded),
              tooltip: 'Notifications',
            ),
            if (unreadCount > 0)
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: AppColors.error,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 16,
                    minHeight: 16,
                  ),
                  child: Text(
                    unreadCount > 99 ? '99+' : unreadCount.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget? _buildFloatingActionButton() {
    final authViewModel = context.watch<AuthViewModel>();
    
    // Show FAB based on current tab and user permissions
    switch (_selectedIndex) {
      case 1: // Projects tab
        if (authViewModel.hasPermission(Permission.createProject)) {
          return FloatingActionButton(
            heroTag: "main_nav_create_project_fab",
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.createProject);
            },
            backgroundColor: AppColors.primaryBlue,
            child: const Icon(Icons.add, color: Colors.white),
          );
        }
        break;
        
      case 2: // Tasks tab
        return FloatingActionButton(
          heroTag: "main_nav_create_task_fab",
          onPressed: () {
            Navigator.pushNamed(context, AppRoutes.createTask);
          },
          backgroundColor: AppColors.primaryBlue,
          child: const Icon(Icons.add_task, color: Colors.white),
        );
        
      case 3: // Time tracking tab - ADDED
        return Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Consumer<TimeTrackingViewModel>(
              builder: (context, timeTrackingVM, child) {
                final hasActiveTimer = timeTrackingVM.hasActiveTimer;
                
                return FloatingActionButton(
                  heroTag: "main_nav_timer_fab",
                  onPressed: hasActiveTimer
                      ? () => timeTrackingVM.stopTimer()
                      : () => _showStartTimerDialog(),
                  backgroundColor: hasActiveTimer 
                      ? AppColors.error 
                      : AppColors.success,
                  child: Icon(
                    hasActiveTimer 
                        ? Icons.stop_rounded 
                        : Icons.play_arrow_rounded,
                    color: Colors.white,
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            FloatingActionButton(
              heroTag: "main_nav_add_manual_entry_fab",
              onPressed: () => _showManualEntryDialog(),
              backgroundColor: AppColors.primaryBlue,
              child: const Icon(Icons.add, color: Colors.white),
            ),
          ],
        );
    }
    
    return null;
  }

  void _showStartTimerDialog() {
    // Implementation for starting timer dialog
    // This would show a dialog to select task and start timer
  }

  void _showManualEntryDialog() {
    // Implementation for manual entry dialog
    // This would show a dialog to add manual time entry
  }
}