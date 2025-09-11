// lib/presentation/viewmodels/auth_viewmodel.dart

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/models/user_model.dart';
import '../../data/repositories/app_repository.dart';
import '../../core/constants/app_constants.dart';
import '../../core/exceptions/app_exception.dart';

class AuthViewModel extends ChangeNotifier {
  final AppRepository _repository = AppRepository();
  
  UserModel? _currentUser;
  bool _isLoading = false;
  bool _isAuthenticated = false;
  String? _errorMessage;
  
  // Getters
  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _isAuthenticated;
  String? get errorMessage => _errorMessage;
  
  // Initialize auth state
  Future<void> initialize() async {
    _setLoading(true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(AppConstants.tokenKey);
      
      if (token != null) {
        // Try to get current user to validate token
        final user = await _repository.getCurrentUser();
        _currentUser = user;
        _isAuthenticated = true;
      }
    } catch (e) {
      // Token expired or invalid, clear storage
      await _clearAuthData();
    }
    _setLoading(false);
  }
  
  // Login
  Future<bool> login(String email, String password) async {
    _setLoading(true);
    _clearError();
    
    try {
      final result = await _repository.login(email, password);
      
      // Store auth data
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(AppConstants.tokenKey, result['token']);
      
      _currentUser = UserModel.fromJson(result['user']);
      _isAuthenticated = true;
      
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(_getErrorMessage(e));
      _setLoading(false);
      return false;
    }
  }
  
  // Register
  Future<bool> register(String name, String email, String password) async {
    _setLoading(true);
    _clearError();
    
    try {
      final result = await _repository.register(name, email, password);
      
      // Store auth data
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(AppConstants.tokenKey, result['token']);
      
      _currentUser = UserModel.fromJson(result['user']);
      _isAuthenticated = true;
      
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(_getErrorMessage(e));
      _setLoading(false);
      return false;
    }
  }
  
  // Logout
  Future<void> logout() async {
    _setLoading(true);
    
    try {
      await _repository.logout();
    } catch (e) {
      // Continue with logout even if API call fails
      debugPrint('Logout API error: $e');
    }
    
    await _clearAuthData();
    _setLoading(false);
  }
  
  // Update user profile
  Future<bool> updateProfile({
    String? name,
    String? email,
  }) async {
    if (_currentUser == null) return false;
    
    _setLoading(true);
    _clearError();
    
    try {
      final updateData = <String, dynamic>{};
      if (name != null) updateData['name'] = name;
      if (email != null) updateData['email'] = email;
      
      final updatedUser = await _repository.updateUser(_currentUser!.id, updateData);
      _currentUser = updatedUser;
      
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(_getErrorMessage(e));
      _setLoading(false);
      return false;
    }
  }
  
  // Check if user has specific permission
  bool hasPermission(Permission permission) {
    if (_currentUser == null) return false;
    
    switch (permission) {
      case Permission.createProject:
        return _currentUser!.role.canCreateProjects;
      case Permission.deleteProject:
        return _currentUser!.role.canDeleteProjects;
      case Permission.manageUsers:
        return _currentUser!.role.canManageUsers;
      case Permission.assignTasks:
        return _currentUser!.role.canAssignTasks;
      case Permission.viewAllProjects:
        return _currentUser!.role.canViewAllProjects;
      case Permission.exportData:
        return _currentUser!.role.canExportData;
    }
  }
  
  // Check if user can access project
  bool canAccessProject(String projectId, String ownerId, List<String> memberIds) {
    if (_currentUser == null) return false;
    
    // Admin can access all projects
    if (_currentUser!.role.canViewAllProjects) return true;
    
    // Owner and members can access
    return _currentUser!.id == ownerId || memberIds.contains(_currentUser!.id);
  }
  
  // Check if user can edit task
  bool canEditTask(String taskCreatorId, String? taskAssigneeId, String projectOwnerId) {
    if (_currentUser == null) return false;
    
    // Admin can edit all tasks
    if (_currentUser!.role.canViewAllProjects) return true;
    
    // Task creator, assignee, or project owner can edit
    return _currentUser!.id == taskCreatorId ||
           _currentUser!.id == taskAssigneeId ||
           _currentUser!.id == projectOwnerId;
  }
  
  // Private methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
  
  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }
  
  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }
  
  Future<void> _clearAuthData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.tokenKey);
    
    _currentUser = null;
    _isAuthenticated = false;
    notifyListeners();
  }
  
  String _getErrorMessage(dynamic error) {
    if (error is AppException) {
      return error.message;
    }
    return error.toString().replaceFirst('Exception: ', '');
  }
  
  // Clear error manually
  void clearError() {
    _clearError();
  }
}

// Permission enum for role-based access control
enum Permission {
  createProject,
  deleteProject,
  manageUsers,
  assignTasks,
  viewAllProjects,
  exportData,
}