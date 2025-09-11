

// lib/presentation/views/common/main_navigation_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../dashboard/dashboard_screen.dart';
import '../projects/projects_list_screen.dart';
import '../tasks/tasks_list_screen.dart';
import '../profile/profile_screen.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/dashboard_viewmodel.dart';
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
      const ProfileScreen(),
    ];
    
    // Load initial data after the widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DashboardViewModel>().loadDashboard();
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final authViewModel = context.watch<AuthViewModel>();

    return Scaffold(
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
          BottomNavigationBarItem(
            icon: Icon(Icons.person_rounded),
            label: 'Profile',
          ),
        ],
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget? _buildFloatingActionButton() {
    final authViewModel = context.watch<AuthViewModel>();
    
    // Show FAB based on current tab and user permissions
    switch (_selectedIndex) {
      case 1: // Projects tab
        if (authViewModel.hasPermission(Permission.createProject)) {
          return FloatingActionButton(
            heroTag: "create_project_fab", // Unique hero tag
            onPressed: () {
              Navigator.pushNamed(context, '/create-project');
            },
            backgroundColor: AppColors.primaryBlue,
            child: const Icon(Icons.add, color: Colors.white),
          );
        }
        break;
      case 2: // Tasks tab
        return FloatingActionButton(
          heroTag: "create_task_fab", // Unique hero tag
          onPressed: () {
            Navigator.pushNamed(context, '/create-task');
          },
          backgroundColor: AppColors.primaryBlue,
          child: const Icon(Icons.add_task, color: Colors.white),
        );
    }
    
    return null;
  }
}