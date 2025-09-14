// lib/presentation/views/common/search_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/project_viewmodel.dart';
import '../../viewmodels/task_viewmodel.dart';
import '../../viewmodels/user_viewmodel.dart';
import '../../widgets/project/project_card.dart';
import '../../widgets/task/task_card.dart';
import '../../widgets/user/user_card.dart';
import '../../widgets/common/loading_widget.dart';
import '../../../data/models/project_model.dart';
import '../../../data/models/task_model.dart';
import '../../../data/models/user_model.dart';
import '../../../core/constants/app_colors.dart';
import '../../../routes/app_routes.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen>
    with SingleTickerProviderStateMixin {
  final _searchController = TextEditingController();
  late TabController _tabController;
  
  List<ProjectModel> _filteredProjects = [];
  List<TaskModel> _filteredTasks = [];
  List<UserModel> _filteredUsers = [];
  
  bool _isSearching = false;
  String _currentQuery = '';
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.trim();
    if (query != _currentQuery) {
      _currentQuery = query;
      _performSearch(query);
    }
  }

  Future<void> _performSearch(String query) async {
    if (query.isEmpty) {
      setState(() {
        _filteredProjects.clear();
        _filteredTasks.clear();
        _filteredUsers.clear();
        _isSearching = false;
      });
      return;
    }

    setState(() {
      _isSearching = true;
    });

    try {
      final projectVM = context.read<ProjectViewModel>();
      final taskVM = context.read<TaskViewModel>();
      final userVM = context.read<UserViewModel>();

      // Load data if not already loaded
      await Future.wait([
        projectVM.loadProjects(),
        taskVM.loadTasks(),
        userVM.loadUsers(),
      ]);

      // Filter results
      final lowerQuery = query.toLowerCase();
      
      final filteredProjects = projectVM.projects.where((project) {
        return project.name.toLowerCase().contains(lowerQuery) ||
               project.description.toLowerCase().contains(lowerQuery);
      }).toList();

      final filteredTasks = taskVM.tasks.where((task) {
        return task.title.toLowerCase().contains(lowerQuery) ||
               task.description.toLowerCase().contains(lowerQuery) ||
               task.tags.any((tag) => tag.toLowerCase().contains(lowerQuery));
      }).toList();

      final filteredUsers = userVM.users.where((user) {
        return user.name.toLowerCase().contains(lowerQuery) ||
               user.email.toLowerCase().contains(lowerQuery);
      }).toList();

      setState(() {
        _filteredProjects = filteredProjects;
        _filteredTasks = filteredTasks;
        _filteredUsers = filteredUsers;
        _isSearching = false;
      });
    } catch (e) {
      setState(() {
        _isSearching = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Search projects, tasks, users...',
            hintStyle: TextStyle(color: Colors.white70),
            border: InputBorder.none,
            suffixIcon: Icon(Icons.search, color: Colors.white70),
          ),
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
        backgroundColor: AppColors.primaryBlue,
        iconTheme: const IconThemeData(color: Colors.white),
        bottom: _currentQuery.isNotEmpty
            ? TabBar(
                controller: _tabController,
                indicatorColor: Colors.white,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white70,
                tabs: [
                  Tab(
                    text: 'Projects (${_filteredProjects.length})',
                  ),
                  Tab(
                    text: 'Tasks (${_filteredTasks.length})',
                  ),
                  Tab(
                    text: 'People (${_filteredUsers.length})',
                  ),
                ],
              )
            : null,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_currentQuery.isEmpty) {
      return _buildEmptySearch();
    }

    if (_isSearching) {
      return const LoadingWidget(message: 'Searching...');
    }

    final totalResults = _filteredProjects.length + 
                        _filteredTasks.length + 
                        _filteredUsers.length;

    if (totalResults == 0) {
      return _buildNoResults();
    }

    return TabBarView(
      controller: _tabController,
      children: [
        _buildProjectsTab(),
        _buildTasksTab(),
        _buildUsersTab(),
      ],
    );
  }

  Widget _buildEmptySearch() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search,
            size: 80,
            color: Colors.grey,
          ),
          SizedBox(height: 16),
          Text(
            'Search Everything',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Find projects, tasks, and team members',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoResults() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.search_off,
            size: 80,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          const Text(
            'No Results Found',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'No results for "$_currentQuery"',
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Try different keywords or check spelling',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProjectsTab() {
    if (_filteredProjects.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.folder_outlined, size: 48, color: Colors.grey),
            SizedBox(height: 8),
            Text('No projects found', style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _filteredProjects.length,
      itemBuilder: (context, index) {
        final project = _filteredProjects[index];
        return ProjectCard(
          project: project,
          onTap: () {
            Navigator.pushNamed(
              context,
              AppRoutes.projectDetail,
              arguments: project.id,
            );
          },
        );
      },
    );
  }

  Widget _buildTasksTab() {
    if (_filteredTasks.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.task_outlined, size: 48, color: Colors.grey),
            SizedBox(height: 8),
            Text('No tasks found', style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _filteredTasks.length,
      itemBuilder: (context, index) {
        final task = _filteredTasks[index];
        return TaskCard(
          task: task,
          showProject: true,
          onTap: () {
            Navigator.pushNamed(
              context,
              AppRoutes.taskDetail,
              arguments: task.id,
            );
          },
        );
      },
    );
  }

  Widget _buildUsersTab() {
    if (_filteredUsers.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person_outlined, size: 48, color: Colors.grey),
            SizedBox(height: 8),
            Text('No people found', style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _filteredUsers.length,
      itemBuilder: (context, index) {
        final user = _filteredUsers[index];
        return UserCard(
          user: user,
          onTap: () {
            // Navigate to user profile or show user details
            _showUserDetails(user);
          },
        );
      },
    );
  }

  void _showUserDetails(UserModel user) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: AppColors.primaryBlue,
              child: Text(
                user.name.substring(0, 1).toUpperCase(),
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              user.name,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              user.email,
              style: const TextStyle(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Chip(
              label: Text(user.role.displayName),
              backgroundColor: AppColors.primaryBlue.withOpacity(0.1),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.message),
                  label: const Text('Message'),
                ),
                TextButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.person),
                  label: const Text('Profile'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// lib/presentation/widgets/user/user_card.dart

class UserCard extends StatelessWidget {
  final UserModel user;
  final VoidCallback? onTap;
  final bool showRole;

  const UserCard({
    Key? key,
    required this.user,
    this.onTap,
    this.showRole = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.primaryBlue,
          child: Text(
            user.name.substring(0, 1).toUpperCase(),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          user.name,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(user.email),
            if (showRole) ...[
              const SizedBox(height: 4),
              Chip(
                label: Text(
                  user.role.displayName,
                  style: const TextStyle(fontSize: 12),
                ),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                backgroundColor: AppColors.primaryBlue.withOpacity(0.1),
                padding: EdgeInsets.zero,
              ),
            ],
          ],
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}