// lib/presentation/views/projects/projects_list_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/project_viewmodel.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../widgets/common/custom_app_bar.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/error_widget.dart';
import '../../widgets/project/project_card.dart';
import '../../../routes/app_routes.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/enums/project_status.dart';
import '../../../core/utils/app_utils.dart';

class ProjectsListScreen extends StatefulWidget {
  const ProjectsListScreen({Key? key}) : super(key: key);

  @override
  State<ProjectsListScreen> createState() => _ProjectsListScreenState();
}

class _ProjectsListScreenState extends State<ProjectsListScreen> {
  String _searchQuery = '';
  ProjectStatus? _filterStatus;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadProjects();
    });
  }

  Future<void> _loadProjects() async {
    final projectViewModel = context.read<ProjectViewModel>();
    await projectViewModel.loadProjects();
  }

  @override
  Widget build(BuildContext context) {
    final authViewModel = context.watch<AuthViewModel>();

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Projects',
        actions: [
          IconButton(
            onPressed: _showFilterDialog,
            icon: const Icon(Icons.filter_list_rounded),
          ),
          IconButton(
            onPressed: _loadProjects,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search projects...',
                prefixIcon: const Icon(Icons.search_rounded),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),

          // Filter Chips
          if (_filterStatus != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              height: 40,
              child: Row(
                children: [
                  Chip(
                    label: Text(_filterStatus!.displayName),
                    deleteIcon: const Icon(Icons.close, size: 18),
                    onDeleted: () {
                      setState(() {
                        _filterStatus = null;
                      });
                    },
                  ),
                ],
              ),
            ),

          // Projects List
          Expanded(
            child: Consumer<ProjectViewModel>(
              builder: (context, projectViewModel, child) {
                if (projectViewModel.isLoading) {
                  return const LoadingWidget(message: 'Loading projects...');
                }

                if (projectViewModel.errorMessage != null) {
                  return CustomErrorWidget(
                    message: projectViewModel.errorMessage!,
                    onRetry: _loadProjects,
                  );
                }

                var projects = projectViewModel.projects;

                // Apply search filter
                if (_searchQuery.isNotEmpty) {
                  projects = projectViewModel.searchProjects(_searchQuery);
                }

                // Apply status filter
                if (_filterStatus != null) {
                  projects = projects.where((p) => p.status == _filterStatus).toList();
                }

                if (projects.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.folder_outlined,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _searchQuery.isNotEmpty || _filterStatus != null
                              ? 'No projects found'
                              : 'No projects yet',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                          ),
                        ),
                        if (_searchQuery.isEmpty && _filterStatus == null) ...[
                          const SizedBox(height: 8),
                          Text(
                            'Create your first project to get started',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: _loadProjects,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: projects.length,
                    itemBuilder: (context, index) {
                      final project = projects[index];
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
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: authViewModel.hasPermission(Permission.createProject)
          ? FloatingActionButton(
              onPressed: () {
                Navigator.pushNamed(context, AppRoutes.createProject);
              },
              backgroundColor: AppColors.primaryBlue,
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Projects'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Filter by status:'),
            const SizedBox(height: 16),
            ...ProjectStatus.values.map((status) {
              return RadioListTile<ProjectStatus?>(
                title: Text(status.displayName),
                value: status,
                groupValue: _filterStatus,
                onChanged: (value) {
                  setState(() {
                    _filterStatus = value;
                  });
                  Navigator.pop(context);
                },
              );
            }),
            RadioListTile<ProjectStatus?>(
              title: const Text('All Projects'),
              value: null,
              groupValue: _filterStatus,
              onChanged: (value) {
                setState(() {
                  _filterStatus = null;
                });
                Navigator.pop(context);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }
}
