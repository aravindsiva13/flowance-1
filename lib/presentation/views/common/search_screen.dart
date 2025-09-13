// lib/presentation/views/common/search_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/project_viewmodel.dart';
import '../../viewmodels/task_viewmodel.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/project/project_card.dart';
import '../../widgets/task/task_card.dart';
import '../../../routes/app_routes.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/project_model.dart';
import '../../../data/models/task_model.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isSearching = false;
  List<ProjectModel> _projectResults = [];
  List<TaskModel> _taskResults = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final projectViewModel = context.read<ProjectViewModel>();
    final taskViewModel = context.read<TaskViewModel>();
    
    await Future.wait([
      projectViewModel.loadProjects(),
      taskViewModel.loadTasks(),
    ]);
  }

  void _performSearch(String query) {
    if (query.trim().isEmpty) {
      setState(() {
        _searchQuery = '';
        _projectResults = [];
        _taskResults = [];
        _isSearching = false;
      });
      return;
    }

    setState(() {
      _searchQuery = query;
      _isSearching = true;
    });

    final projectViewModel = context.read<ProjectViewModel>();
    final taskViewModel = context.read<TaskViewModel>();

    // Simulate search delay for better UX
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted && _searchQuery == query) {
        setState(() {
          _projectResults = projectViewModel.searchProjects(query);
          _taskResults = taskViewModel.searchTasks(query);
          _isSearching = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Search projects and tasks...',
            border: InputBorder.none,
            hintStyle: TextStyle(color: Colors.white70),
          ),
          style: const TextStyle(color: Colors.white, fontSize: 18),
          onChanged: _performSearch,
        ),
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: Colors.white,
        actions: [
          if (_searchController.text.isNotEmpty)
            IconButton(
              onPressed: () {
                _searchController.clear();
                _performSearch('');
              },
              icon: const Icon(Icons.clear),
            ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_searchQuery.isEmpty) {
      return _buildEmptyState();
    }

    if (_isSearching) {
      return const LoadingWidget(message: 'Searching...');
    }

    if (_projectResults.isEmpty && _taskResults.isEmpty) {
      return _buildNoResults();
    }

    return _buildResults();
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_rounded,
            size: 64,
            color: Colors.grey,
          ),
          SizedBox(height: 16),
          Text(
            'Search for projects and tasks',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Type in the search bar above to get started',
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
            Icons.search_off_rounded,
            size: 64,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          Text(
            'No results for "$_searchQuery"',
            style: const TextStyle(
              fontSize: 18,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Try a different search term',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResults() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search Summary
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primaryBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.search_rounded,
                  color: AppColors.primaryBlue,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Found ${_projectResults.length} projects and ${_taskResults.length} tasks',
                    style: const TextStyle(
                      color: AppColors.primaryBlue,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Projects Section
          if (_projectResults.isNotEmpty) ...[
            Row(
              children: [
                const Icon(
                  Icons.folder_rounded,
                  color: AppColors.textPrimary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Projects (${_projectResults.length})',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ..._projectResults.map((project) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: ProjectCard(
                project: project,
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    AppRoutes.projectDetail,
                    arguments: project.id,
                  );
                },
              ),
            )),
            const SizedBox(height: 24),
          ],

          // Tasks Section
          if (_taskResults.isNotEmpty) ...[
            Row(
              children: [
                const Icon(
                  Icons.task_alt_rounded,
                  color: AppColors.textPrimary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Tasks (${_taskResults.length})',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ..._taskResults.map((task) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: TaskCard(
                task: task,
                showProject: true,
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    AppRoutes.taskDetail,
                    arguments: task.id,
                  );
                },
              ),
            )),
          ],
        ],
      ),
    );
  }
}