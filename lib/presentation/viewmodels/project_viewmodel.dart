// lib/presentation/viewmodels/project_viewmodel.dart

import 'package:flutter/foundation.dart';
import '../../data/models/project_model.dart';
import '../../data/models/user_model.dart';
import '../../data/repositories/app_repository.dart';
import '../../core/enums/project_status.dart';
import '../../core/exceptions/app_exception.dart';

class ProjectViewModel extends ChangeNotifier {
  final AppRepository _repository = AppRepository();
  
  List<ProjectModel> _projects = [];
  List<UserModel> _users = [];
  bool _isLoading = false;
  bool _isCreating = false;
  bool _isUpdating = false;
  bool _isDeleting = false;
  String? _errorMessage;
  
  // Getters
  List<ProjectModel> get projects => _projects;
  List<UserModel> get users => _users;
  bool get isLoading => _isLoading;
  bool get isCreating => _isCreating;
  bool get isUpdating => _isUpdating;
  bool get isDeleting => _isDeleting;
  String? get errorMessage => _errorMessage;
  
  // Load projects
  Future<void> loadProjects() async {
    _setLoading(true);
    _clearError();
    
    try {
      _projects = await _repository.getProjects();
    } catch (e) {
      _setError(_getErrorMessage(e));
    }
    
    _setLoading(false);
  }
  
  // Load users for project assignment
  Future<void> loadUsers() async {
    try {
      _users = await _repository.getUsers();
      notifyListeners();
    } catch (e) {
      _setError(_getErrorMessage(e));
    }
  }
  
  // Get project by id
  Future<ProjectModel?> getProject(String id) async {
    try {
      return await _repository.getProjectById(id);
    } catch (e) {
      _setError(_getErrorMessage(e));
      return null;
    }
  }
  
  // Create project
  Future<bool> createProject({
    required String name,
    required String description,
    ProjectStatus status = ProjectStatus.planning,
    List<String> memberIds = const [],
    DateTime? dueDate,
  }) async {
    _setCreating(true);
    _clearError();
    
    try {
      final projectData = {
        'name': name,
        'description': description,
        'status': status.name,
        'memberIds': memberIds,
        'dueDate': dueDate?.toIso8601String(),
      };
      
      final newProject = await _repository.createProject(projectData);
      _projects.insert(0, newProject);
      
      _setCreating(false);
      return true;
    } catch (e) {
      _setError(_getErrorMessage(e));
      _setCreating(false);
      return false;
    }
  }
  
  // Update project
  Future<bool> updateProject(
    String id, {
    String? name,
    String? description,
    ProjectStatus? status,
    List<String>? memberIds,
    DateTime? dueDate,
  }) async {
    _setUpdating(true);
    _clearError();
    
    try {
      final updateData = <String, dynamic>{};
      if (name != null) updateData['name'] = name;
      if (description != null) updateData['description'] = description;
      if (status != null) updateData['status'] = status.name;
      if (memberIds != null) updateData['memberIds'] = memberIds;
      if (dueDate != null) updateData['dueDate'] = dueDate.toIso8601String();
      
      final updatedProject = await _repository.updateProject(id, updateData);
      
      final index = _projects.indexWhere((project) => project.id == id);
      if (index != -1) {
        _projects[index] = updatedProject;
      }
      
      _setUpdating(false);
      return true;
    } catch (e) {
      _setError(_getErrorMessage(e));
      _setUpdating(false);
      return false;
    }
  }
  
  // Delete project
  Future<bool> deleteProject(String id) async {
    _setDeleting(true);
    _clearError();
    
    try {
      await _repository.deleteProject(id);
      _projects.removeWhere((project) => project.id == id);
      
      _setDeleting(false);
      return true;
    } catch (e) {
      _setError(_getErrorMessage(e));
      _setDeleting(false);
      return false;
    }
  }
  
  // Get projects by status
  List<ProjectModel> getProjectsByStatus(ProjectStatus status) {
    return _projects.where((project) => project.status == status).toList();
  }
  
  // Get active projects
  List<ProjectModel> get activeProjects {
    return _projects.where((project) => project.status.isActive).toList();
  }
  
  // Get project statistics
  Map<String, int> get projectStats {
    final stats = <String, int>{};
    
    for (final status in ProjectStatus.values) {
      stats[status.name] = _projects.where((p) => p.status == status).length;
    }
    
    return stats;
  }
  
  // Search projects
  List<ProjectModel> searchProjects(String query) {
    if (query.trim().isEmpty) return _projects;
    
    final lowercaseQuery = query.toLowerCase();
    return _projects.where((project) =>
      project.name.toLowerCase().contains(lowercaseQuery) ||
      project.description.toLowerCase().contains(lowercaseQuery)
    ).toList();
  }
  
  // Private methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
  
  void _setCreating(bool creating) {
    _isCreating = creating;
    notifyListeners();
  }
  
  void _setUpdating(bool updating) {
    _isUpdating = updating;
    notifyListeners();
  }
  
  void _setDeleting(bool deleting) {
    _isDeleting = deleting;
    notifyListeners();
  }
  
  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }
  
  void _clearError() {
    _errorMessage = null;
  }
  
  String _getErrorMessage(dynamic error) {
    if (error is AppException) {
      return error.message;
    }
    return error.toString().replaceFirst('Exception: ', '');
  }
  
  void clearError() {
    _clearError();
    notifyListeners();
  }
}
