
// // lib/presentation/viewmodels/task_viewmodel.dart

// import 'package:flowence/core/enums/user_role.dart';
// import 'package:flutter/foundation.dart';
// import '../../data/models/task_model.dart';
// import '../../data/models/project_model.dart';
// import '../../data/models/user_model.dart';
// import '../../data/models/comment_model.dart' hide CommentModel;
// import '../../data/repositories/app_repository.dart';
// import '../../core/enums/task_status.dart';
// import '../../core/enums/task_priority.dart';
// import '../../core/exceptions/app_exception.dart';

// class TaskViewModel extends ChangeNotifier {
//   final AppRepository _repository = AppRepository();
  
//   List<TaskModel> _tasks = [];
//   List<ProjectModel> _projects = [];
//   List<UserModel> _users = [];
//   List<CommentModel> _comments = [];
//   bool _isLoading = false;
//   bool _isCreating = false;
//   bool _isUpdating = false;
//   bool _isDeleting = false;
//   bool _isLoadingComments = false;
//   String? _errorMessage;
//   String? _selectedProjectId;
  
//   // Getters
//   List<TaskModel> get tasks => _tasks;
//   List<ProjectModel> get projects => _projects;
//   List<UserModel> get users => _users;
//   List<CommentModel> get comments => _comments;
//   bool get isLoading => _isLoading;
//   bool get isCreating => _isCreating;
//   bool get isUpdating => _isUpdating;
//   bool get isDeleting => _isDeleting;
//   bool get isLoadingComments => _isLoadingComments;
//   String? get errorMessage => _errorMessage;
//   String? get selectedProjectId => _selectedProjectId;
  
//   // Load tasks
//   Future<void> loadTasks({String? projectId, String? assigneeId}) async {
//     _setLoading(true);
//     _clearError();
    
//     try {
//       _tasks = await _repository.getTasks(projectId: projectId, assigneeId: assigneeId);
//       _selectedProjectId = projectId;
//     } catch (e) {
//       _setError(_getErrorMessage(e));
//     }
    
//     _setLoading(false);
//   }
  
//   // Load projects for task creation
//   Future<void> loadProjects() async {
//     try {
//       _projects = await _repository.getProjects();
//       notifyListeners();
//     } catch (e) {
//       _setError(_getErrorMessage(e));
//     }
//   }
  
//   // Load users for task assignment
//   Future<void> loadUsers() async {
//     try {
//       _users = await _repository.getUsers();
//       notifyListeners();
//     } catch (e) {
//       _setError(_getErrorMessage(e));
//     }
//   }
  
//   // Get task by id
//   Future<TaskModel?> getTask(String id) async {
//     try {
//       return await _repository.getTaskById(id);
//     } catch (e) {
//       _setError(_getErrorMessage(e));
//       return null;
//     }
//   }
  
//   // Create task
//   Future<bool> createTask({
//     required String title,
//     required String description,
//     required String projectId,
//     TaskStatus status = TaskStatus.toDo,
//     TaskPriority priority = TaskPriority.medium,
//     String? assigneeId,
//     DateTime? dueDate,
//     List<String> tags = const [],
//   }) async {
//     _setCreating(true);
//     _clearError();
    
//     try {
//       final taskData = {
//         'title': title,
//         'description': description,
//         'projectId': projectId,
//         'status': status.name,
//         'priority': priority.name,
//         'assigneeId': assigneeId,
//         'dueDate': dueDate?.toIso8601String(),
//         'tags': tags,
//       };
      
//       final newTask = await _repository.createTask(taskData);
      
//       // Add to local list if it matches current filter
//       if (_selectedProjectId == null || _selectedProjectId == projectId) {
//         _tasks.insert(0, newTask);
//       }
      
//       _setCreating(false);
//       return true;
//     } catch (e) {
//       _setError(_getErrorMessage(e));
//       _setCreating(false);
//       return false;
//     }
//   }
  
//   // Update task
//   Future<bool> updateTask(
//     String id, {
//     String? title,
//     String? description,
//     TaskStatus? status,
//     TaskPriority? priority,
//     String? assigneeId,
//     DateTime? dueDate,
//     List<String>? tags,
//     double? progress,
//   }) async {
//     _setUpdating(true);
//     _clearError();
    
//     try {
//       final updateData = <String, dynamic>{};
//       if (title != null) updateData['title'] = title;
//       if (description != null) updateData['description'] = description;
//       if (status != null) updateData['status'] = status.name;
//       if (priority != null) updateData['priority'] = priority.name;
//       if (assigneeId != null) updateData['assigneeId'] = assigneeId;
//       if (dueDate != null) updateData['dueDate'] = dueDate.toIso8601String();
//       if (tags != null) updateData['tags'] = tags;
//       if (progress != null) updateData['progress'] = progress;
      
//       final updatedTask = await _repository.updateTask(id, updateData);
      
//       final index = _tasks.indexWhere((task) => task.id == id);
//       if (index != -1) {
//         _tasks[index] = updatedTask;
//       }
      
//       _setUpdating(false);
//       return true;
//     } catch (e) {
//       _setError(_getErrorMessage(e));
//       _setUpdating(false);
//       return false;
//     }
//   }
  
//   // Delete task
//   Future<bool> deleteTask(String id) async {
//     _setDeleting(true);
//     _clearError();
    
//     try {
//       await _repository.deleteTask(id);
//       _tasks.removeWhere((task) => task.id == id);
      
//       _setDeleting(false);
//       return true;
//     } catch (e) {
//       _setError(_getErrorMessage(e));
//       _setDeleting(false);
//       return false;
//     }
//   }
  
//   // Update task status (for Kanban board)
//   Future<bool> updateTaskStatus(String id, TaskStatus newStatus) async {
//     return await updateTask(id, status: newStatus);
//   }
  
//   // Get tasks by status
//   List<TaskModel> getTasksByStatus(TaskStatus status) {
//     return _tasks.where((task) => task.status == status).toList();
//   }
  
//   // Get tasks by priority
//   List<TaskModel> getTasksByPriority(TaskPriority priority) {
//     return _tasks.where((task) => task.priority == priority).toList();
//   }
  
//   // Get my tasks (assigned to current user)
//   List<TaskModel> getMyTasks(String userId) {
//     return _tasks.where((task) => task.assigneeId == userId).toList();
//   }
  
//   // Get overdue tasks
//   List<TaskModel> get overdueTasks {
//     final now = DateTime.now();
//     return _tasks.where((task) =>
//       task.dueDate != null &&
//       task.dueDate!.isBefore(now) &&
//       task.status != TaskStatus.done
//     ).toList();
//   }
  
//   // Get tasks due today
//   List<TaskModel> get tasksDueToday {
//     final now = DateTime.now();
//     final today = DateTime(now.year, now.month, now.day);
    
//     return _tasks.where((task) {
//       if (task.dueDate == null) return false;
//       final dueDate = DateTime(task.dueDate!.year, task.dueDate!.month, task.dueDate!.day);
//       return dueDate.isAtSameMomentAs(today) && task.status != TaskStatus.done;
//     }).toList();
//   }
  
//   // Get task statistics
//   Map<String, int> get taskStats {
//     final stats = <String, int>{};
    
//     for (final status in TaskStatus.values) {
//       stats[status.name] = _tasks.where((t) => t.status == status).length;
//     }
    
//     return stats;
//   }
  
//   // Search tasks
//   List<TaskModel> searchTasks(String query) {
//     if (query.trim().isEmpty) return _tasks;
    
//     final lowercaseQuery = query.toLowerCase();
//     return _tasks.where((task) =>
//       task.title.toLowerCase().contains(lowercaseQuery) ||
//       task.description.toLowerCase().contains(lowercaseQuery) ||
//       task.tags.any((tag) => tag.toLowerCase().contains(lowercaseQuery))
//     ).toList();
//   }
  
//   // Comment-related methods
//   Future<void> loadComments(String taskId) async {
//     _setLoadingComments(true);
//     _clearError();
    
//     try {
//       _comments = await _repository.getComments(taskId);
//     } catch (e) {
//       _setError(_getErrorMessage(e));
//     }
    
//     _setLoadingComments(false);
//   }
  
//   // Add comment
//   Future<bool> addComment({
//     required String taskId,
//     required String content,
//     List<String> mentions = const [],
//   }) async {
//     _clearError();
    
//     try {
//       final commentData = {
//         'taskId': taskId,
//         'content': content,
//         'mentions': mentions,
//       };
      
//       final newComment = await _repository.createComment(commentData);
//       _comments.add(newComment);
      
//       notifyListeners();
//       return true;
//     } catch (e) {
//       _setError(_getErrorMessage(e));
//       return false;
//     }
//   }
  
//   // Get assignee name
//   String getAssigneeName(String? assigneeId) {
//     if (assigneeId == null) return 'Unassigned';
    
//     final user = _users.firstWhere(
//       (user) => user.id == assigneeId,
//       orElse: () => UserModel(
//         id: assigneeId,
//         name: 'Unknown User',
//         email: '',
//         role: UserRole.teamMember,
//         createdAt: DateTime.now(),
//       ),
//     );
    
//     return user.name;
//   }
  
//   // Get project name
//   String getProjectName(String projectId) {
//     final project = _projects.firstWhere(
//       (project) => project.id == projectId,
//       orElse: () => ProjectModel(
//         id: projectId,
//         name: 'Unknown Project',
//         description: '',
//         status: ProjectStatus.active,
//         ownerId: '',
//         memberIds: [],
//         startDate: DateTime.now(),
//         createdAt: DateTime.now(),
//         updatedAt: DateTime.now(),
//       ),
//     );
    
//     return project.name;
//   }
  
//   // Export tasks for CSV
//   Future<List<Map<String, dynamic>>> getTasksForExport() async {
//     try {
//       return await _repository.getTasksForExport(projectId: _selectedProjectId);
//     } catch (e) {
//       _setError(_getErrorMessage(e));
//       return [];
//     }
//   }
  
//   // Private methods
//   void _setLoading(bool loading) {
//     _isLoading = loading;
//     notifyListeners();
//   }
  
//   void _setCreating(bool creating) {
//     _isCreating = creating;
//     notifyListeners();
//   }
  
//   void _setUpdating(bool updating) {
//     _isUpdating = updating;
//     notifyListeners();
//   }
  
//   void _setDeleting(bool deleting) {
//     _isDeleting = deleting;
//     notifyListeners();
//   }
  
//   void _setLoadingComments(bool loading) {
//     _isLoadingComments = loading;
//     notifyListeners();
//   }
  
//   void _setError(String error) {
//     _errorMessage = error;
//     notifyListeners();
//   }
  
//   void _clearError() {
//     _errorMessage = null;
//   }
  
//   String _getErrorMessage(dynamic error) {
//     if (error is AppException) {
//       return error.message;
//     }
//     return error.toString().replaceFirst('Exception: ', '');
//   }
  
//   void clearError() {
//     _clearError();
//     notifyListeners();
//   }
// }


//2


// lib/presentation/viewmodels/task_viewmodel.dart

import 'package:flutter/foundation.dart';
import '../../data/models/task_model.dart';
import '../../data/models/project_model.dart';
import '../../data/models/user_model.dart';
import '../../data/models/comment_model.dart';
import '../../data/repositories/app_repository.dart';
import '../../core/enums/task_status.dart';
import '../../core/enums/task_priority.dart';
import '../../core/enums/project_status.dart';
import '../../core/enums/user_role.dart';
import '../../core/exceptions/app_exception.dart';

class TaskViewModel extends ChangeNotifier {
  final AppRepository _repository = AppRepository();
  
  List<TaskModel> _tasks = [];
  List<ProjectModel> _projects = [];
  List<UserModel> _users = [];
  List<CommentModel> _comments = [];
  bool _isLoading = false;
  bool _isCreating = false;
  bool _isUpdating = false;
  bool _isDeleting = false;
  bool _isLoadingComments = false;
  String? _errorMessage;
  String? _selectedProjectId;
  
  // Getters
  List<TaskModel> get tasks => _tasks;
  List<ProjectModel> get projects => _projects;
  List<UserModel> get users => _users;
  List<CommentModel> get comments => _comments;
  bool get isLoading => _isLoading;
  bool get isCreating => _isCreating;
  bool get isUpdating => _isUpdating;
  bool get isDeleting => _isDeleting;
  bool get isLoadingComments => _isLoadingComments;
  String? get errorMessage => _errorMessage;
  String? get selectedProjectId => _selectedProjectId;
  
  // Load tasks
  Future<void> loadTasks({String? projectId, String? assigneeId}) async {
    _setLoading(true);
    _clearError();
    
    try {
      _tasks = await _repository.getTasks(projectId: projectId, assigneeId: assigneeId);
      _selectedProjectId = projectId;
    } catch (e) {
      _setError(_getErrorMessage(e));
    }
    
    _setLoading(false);
  }
  
  // Load projects for task creation
  Future<void> loadProjects() async {
    try {
      _projects = await _repository.getProjects();
      notifyListeners();
    } catch (e) {
      _setError(_getErrorMessage(e));
    }
  }
  
  // Load users for task assignment
  Future<void> loadUsers() async {
    try {
      _users = await _repository.getUsers();
      notifyListeners();
    } catch (e) {
      _setError(_getErrorMessage(e));
    }
  }
  
  // Get task by id
  Future<TaskModel?> getTask(String id) async {
    try {
      return await _repository.getTaskById(id);
    } catch (e) {
      _setError(_getErrorMessage(e));
      return null;
    }
  }
  
  // Create task
  Future<bool> createTask({
    required String title,
    required String description,
    required String projectId,
    TaskStatus status = TaskStatus.toDo,
    TaskPriority priority = TaskPriority.medium,
    String? assigneeId,
    DateTime? dueDate,
    List<String> tags = const [],
  }) async {
    _setCreating(true);
    _clearError();
    
    try {
      final taskData = {
        'title': title,
        'description': description,
        'projectId': projectId,
        'status': status.name,
        'priority': priority.name,
        'assigneeId': assigneeId,
        'dueDate': dueDate?.toIso8601String(),
        'tags': tags,
      };
      
      final newTask = await _repository.createTask(taskData);
      
      // Add to local list if it matches current filter
      if (_selectedProjectId == null || _selectedProjectId == projectId) {
        _tasks.insert(0, newTask);
      }
      
      _setCreating(false);
      return true;
    } catch (e) {
      _setError(_getErrorMessage(e));
      _setCreating(false);
      return false;
    }
  }
  
  // Update task
  Future<bool> updateTask(
    String id, {
    String? title,
    String? description,
    TaskStatus? status,
    TaskPriority? priority,
    String? assigneeId,
    DateTime? dueDate,
    List<String>? tags,
    double? progress,
  }) async {
    _setUpdating(true);
    _clearError();
    
    try {
      final updateData = <String, dynamic>{};
      if (title != null) updateData['title'] = title;
      if (description != null) updateData['description'] = description;
      if (status != null) updateData['status'] = status.name;
      if (priority != null) updateData['priority'] = priority.name;
      if (assigneeId != null) updateData['assigneeId'] = assigneeId;
      if (dueDate != null) updateData['dueDate'] = dueDate.toIso8601String();
      if (tags != null) updateData['tags'] = tags;
      if (progress != null) updateData['progress'] = progress;
      
      final updatedTask = await _repository.updateTask(id, updateData);
      
      final index = _tasks.indexWhere((task) => task.id == id);
      if (index != -1) {
        _tasks[index] = updatedTask;
      }
      
      _setUpdating(false);
      return true;
    } catch (e) {
      _setError(_getErrorMessage(e));
      _setUpdating(false);
      return false;
    }
  }
  
  // Delete task
  Future<bool> deleteTask(String id) async {
    _setDeleting(true);
    _clearError();
    
    try {
      await _repository.deleteTask(id);
      _tasks.removeWhere((task) => task.id == id);
      
      _setDeleting(false);
      return true;
    } catch (e) {
      _setError(_getErrorMessage(e));
      _setDeleting(false);
      return false;
    }
  }
  
  // Update task status (for Kanban board)
  Future<bool> updateTaskStatus(String id, TaskStatus newStatus) async {
    return await updateTask(id, status: newStatus);
  }
  
  // Get tasks by status
  List<TaskModel> getTasksByStatus(TaskStatus status) {
    return _tasks.where((task) => task.status == status).toList();
  }
  
  // Get tasks by priority
  List<TaskModel> getTasksByPriority(TaskPriority priority) {
    return _tasks.where((task) => task.priority == priority).toList();
  }
  
  // Get my tasks (assigned to current user)
  List<TaskModel> getMyTasks(String userId) {
    return _tasks.where((task) => task.assigneeId == userId).toList();
  }
  
  // Get overdue tasks
  List<TaskModel> get overdueTasks {
    final now = DateTime.now();
    return _tasks.where((task) =>
      task.dueDate != null &&
      task.dueDate!.isBefore(now) &&
      task.status != TaskStatus.done
    ).toList();
  }
  
  // Get tasks due today
  List<TaskModel> get tasksDueToday {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    return _tasks.where((task) {
      if (task.dueDate == null) return false;
      final dueDate = DateTime(task.dueDate!.year, task.dueDate!.month, task.dueDate!.day);
      return dueDate.isAtSameMomentAs(today) && task.status != TaskStatus.done;
    }).toList();
  }
  
  // Get task statistics
  Map<String, int> get taskStats {
    final stats = <String, int>{};
    
    for (final status in TaskStatus.values) {
      stats[status.name] = _tasks.where((t) => t.status == status).length;
    }
    
    return stats;
  }
  
  // Search tasks
  List<TaskModel> searchTasks(String query) {
    if (query.trim().isEmpty) return _tasks;
    
    final lowercaseQuery = query.toLowerCase();
    return _tasks.where((task) =>
      task.title.toLowerCase().contains(lowercaseQuery) ||
      task.description.toLowerCase().contains(lowercaseQuery) ||
      task.tags.any((tag) => tag.toLowerCase().contains(lowercaseQuery))
    ).toList();
  }
  
  // Comment-related methods
  Future<void> loadComments(String taskId) async {
    _setLoadingComments(true);
    _clearError();
    
    try {
      _comments = await _repository.getComments(taskId);
    } catch (e) {
      _setError(_getErrorMessage(e));
    }
    
    _setLoadingComments(false);
  }
  
  // Add comment
  Future<bool> addComment({
    required String taskId,
    required String content,
    List<String> mentions = const [],
  }) async {
    _clearError();
    
    try {
      final commentData = {
        'taskId': taskId,
        'content': content,
        'mentions': mentions,
      };
      
      final newComment = await _repository.createComment(commentData);
      _comments.add(newComment);
      
      notifyListeners();
      return true;
    } catch (e) {
      _setError(_getErrorMessage(e));
      return false;
    }
  }
  
  // Get assignee name
  String getAssigneeName(String? assigneeId) {
    if (assigneeId == null) return 'Unassigned';
    
    final user = _users.firstWhere(
      (user) => user.id == assigneeId,
      orElse: () => UserModel(
        id: assigneeId,
        name: 'Unknown User',
        email: '',
        role: UserRole.teamMember,
        createdAt: DateTime.now(),
      ),
    );
    
    return user.name;
  }
  
  // Get project name
  String getProjectName(String projectId) {
    final project = _projects.firstWhere(
      (project) => project.id == projectId,
      orElse: () => ProjectModel(
        id: projectId,
        name: 'Unknown Project',
        description: '',
        status: ProjectStatus.active,
        ownerId: '',
        memberIds: [],
        startDate: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );
    
    return project.name;
  }
  
  // Export tasks for CSV
  Future<List<Map<String, dynamic>>> getTasksForExport() async {
    try {
      return await _repository.getTasksForExport(projectId: _selectedProjectId);
    } catch (e) {
      _setError(_getErrorMessage(e));
      return [];
    }
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
  
  void _setLoadingComments(bool loading) {
    _isLoadingComments = loading;
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