
// lib/presentation/viewmodels/user_viewmodel.dart

import 'package:flutter/foundation.dart';
import '../../data/models/user_model.dart';
import '../../data/repositories/app_repository.dart';
import '../../core/enums/user_role.dart';
import '../../core/exceptions/app_exception.dart';

class UserViewModel extends ChangeNotifier {
  final AppRepository _repository = AppRepository();
  
  List<UserModel> _users = [];
  UserModel? _currentUser;
  bool _isLoading = false;
  bool _isUpdating = false;
  String? _errorMessage;
  
  // Getters
  List<UserModel> get users => _users;
  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isUpdating => _isUpdating;
  String? get errorMessage => _errorMessage;
  
  // Load users
  Future<void> loadUsers() async {
    _setLoading(true);
    _clearError();
    
    try {
      _users = await _repository.getUsers();
    } catch (e) {
      _setError(_getErrorMessage(e));
    }
    
    _setLoading(false);
  }
  
  // Load current user
  Future<void> loadCurrentUser() async {
    _setLoading(true);
    _clearError();
    
    try {
      _currentUser = await _repository.getCurrentUser();
    } catch (e) {
      _setError(_getErrorMessage(e));
    }
    
    _setLoading(false);
  }
  
  // Get user by id
  Future<UserModel?> getUser(String id) async {
    try {
      return await _repository.getUserById(id);
    } catch (e) {
      _setError(_getErrorMessage(e));
      return null;
    }
  }
  
  // Update user profile
  Future<bool> updateUserProfile({
    String? name,
    String? email,
  }) async {
    if (_currentUser == null) return false;
    
    _setUpdating(true);
    _clearError();
    
    try {
      final updateData = <String, dynamic>{};
      if (name != null) updateData['name'] = name;
      if (email != null) updateData['email'] = email;
      
      final updatedUser = await _repository.updateUser(_currentUser!.id, updateData);
      _currentUser = updatedUser;
      
      // Update in users list if exists
      final index = _users.indexWhere((user) => user.id == updatedUser.id);
      if (index != -1) {
        _users[index] = updatedUser;
      }
      
      _setUpdating(false);
      return true;
    } catch (e) {
      _setError(_getErrorMessage(e));
      _setUpdating(false);
      return false;
    }
  }
  
  // Update user role (admin only)
  Future<bool> updateUserRole(String userId, UserRole newRole) async {
    _setUpdating(true);
    _clearError();
    
    try {
      final updateData = {'role': newRole.name};
      final updatedUser = await _repository.updateUser(userId, updateData);
      
      // Update in local list
      final index = _users.indexWhere((user) => user.id == userId);
      if (index != -1) {
        _users[index] = updatedUser;
      }
      
      _setUpdating(false);
      return true;
    } catch (e) {
      _setError(_getErrorMessage(e));
      _setUpdating(false);
      return false;
    }
  }
  
  // Get users by role
  List<UserModel> getUsersByRole(UserRole role) {
    return _users.where((user) => user.role == role).toList();
  }
  
  // Get team members (non-admin users)
  List<UserModel> get teamMembers {
    return _users.where((user) => user.role != UserRole.admin).toList();
  }
  
  // Get admins
  List<UserModel> get admins {
    return _users.where((user) => user.role == UserRole.admin).toList();
  }
  
  // Get project managers
  List<UserModel> get projectManagers {
    return _users.where((user) => user.role == UserRole.projectManager).toList();
  }
  
  // Search users
  List<UserModel> searchUsers(String query) {
    if (query.trim().isEmpty) return _users;
    
    final lowercaseQuery = query.toLowerCase();
    return _users.where((user) =>
      user.name.toLowerCase().contains(lowercaseQuery) ||
      user.email.toLowerCase().contains(lowercaseQuery)
    ).toList();
  }
  
  // Get user statistics
  Map<String, int> get userStats {
    final stats = <String, int>{};
    
    for (final role in UserRole.values) {
      stats[role.name] = _users.where((u) => u.role == role).length;
    }
    
    return stats;
  }
  
  // Get user by email
  UserModel? getUserByEmail(String email) {
    try {
      return _users.firstWhere((user) => user.email == email);
    } catch (e) {
      return null;
    }
  }
  
  // Get users for assignment (can be assigned tasks)
  List<UserModel> get assignableUsers {
    return _users; // All users can be assigned tasks
  }
  
  // Check if current user can manage other users
  bool get canManageUsers {
    return _currentUser?.role.canManageUsers ?? false;
  }
  
  // Check if current user can assign tasks
  bool get canAssignTasks {
    return _currentUser?.role.canAssignTasks ?? false;
  }
  
  // Private methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
  
  void _setUpdating(bool updating) {
    _isUpdating = updating;
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