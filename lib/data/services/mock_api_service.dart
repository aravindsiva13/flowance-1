// lib/data/services/mock_api_service.dart

import 'dart:math';
import '../models/user_model.dart';
import '../models/project_model.dart';
import '../models/task_model.dart';
import '../models/comment_model.dart';
import '../models/notification_model.dart';
import '../../core/enums/user_role.dart';
import '../../core/enums/project_status.dart';
import '../../core/enums/task_status.dart';
import '../../core/enums/task_priority.dart';

class MockApiService {
  static final MockApiService _instance = MockApiService._internal();
  factory MockApiService() => _instance;
  MockApiService._internal();

  // In-memory data storage
  final List<UserModel> _users = [];
  final List<ProjectModel> _projects = [];
  final List<TaskModel> _tasks = [];
  final List<CommentModel> _comments = [];
  final List<NotificationModel> _notifications = [];
  
  String? _currentUserId;
  final Random _random = Random();

  // Initialize with sample data
  void _initializeData() {
    if (_users.isEmpty) {
      _createSampleUsers();
      _createSampleProjects();
      _createSampleTasks();
      _createSampleComments();
      _createSampleNotifications();
    }
  }

  void _createSampleUsers() {
    final now = DateTime.now();
    _users.addAll([
      UserModel(
        id: '1',
        name: 'John Admin',
        email: 'admin@example.com',
        role: UserRole.admin,
        createdAt: now.subtract(const Duration(days: 30)),
        lastLoginAt: now.subtract(const Duration(hours: 1)),
      ),
      UserModel(
        id: '2',
        name: 'Jane Manager',
        email: 'manager@example.com',
        role: UserRole.projectManager,
        createdAt: now.subtract(const Duration(days: 25)),
        lastLoginAt: now.subtract(const Duration(hours: 2)),
      ),
      UserModel(
        id: '3',
        name: 'Bob Developer',
        email: 'developer@example.com',
        role: UserRole.teamMember,
        createdAt: now.subtract(const Duration(days: 20)),
        lastLoginAt: now.subtract(const Duration(hours: 3)),
      ),
      UserModel(
        id: '4',
        name: 'Alice Designer',
        email: 'designer@example.com',
        role: UserRole.teamMember,
        createdAt: now.subtract(const Duration(days: 15)),
        lastLoginAt: now.subtract(const Duration(hours: 4)),
      ),
    ]);
  }

  void _createSampleProjects() {
    final now = DateTime.now();
    _projects.addAll([
      ProjectModel(
        id: '1',
        name: 'Mobile App Development',
        description: 'Developing a cross-platform mobile application',
        status: ProjectStatus.active,
        ownerId: '2',
        memberIds: ['2', '3', '4'],
        startDate: now.subtract(const Duration(days: 30)),
        dueDate: now.add(const Duration(days: 60)),
        createdAt: now.subtract(const Duration(days: 30)),
        updatedAt: now.subtract(const Duration(days: 1)),
        progress: 0.45,
      ),
      ProjectModel(
        id: '2',
        name: 'Website Redesign',
        description: 'Complete overhaul of company website',
        status: ProjectStatus.active,
        ownerId: '2',
        memberIds: ['2', '4'],
        startDate: now.subtract(const Duration(days: 15)),
        dueDate: now.add(const Duration(days: 45)),
        createdAt: now.subtract(const Duration(days: 15)),
        updatedAt: now.subtract(const Duration(hours: 5)),
        progress: 0.25,
      ),
      ProjectModel(
        id: '3',
        name: 'API Integration',
        description: 'Integrate third-party APIs',
        status: ProjectStatus.planning,
        ownerId: '2',
        memberIds: ['2', '3'],
        startDate: now.add(const Duration(days: 7)),
        dueDate: now.add(const Duration(days: 90)),
        createdAt: now.subtract(const Duration(days: 5)),
        updatedAt: now.subtract(const Duration(days: 2)),
        progress: 0.0,
      ),
    ]);
  }

  void _createSampleTasks() {
    final now = DateTime.now();
    _tasks.addAll([
      // Mobile App Development tasks
      TaskModel(
        id: '1',
        title: 'Setup Flutter Project',
        description: 'Initialize Flutter project with proper structure',
        status: TaskStatus.done,
        priority: TaskPriority.high,
        projectId: '1',
        assigneeId: '3',
        creatorId: '2',
        dueDate: now.add(const Duration(days: 3)),
        createdAt: now.subtract(const Duration(days: 28)),
        updatedAt: now.subtract(const Duration(days: 25)),
        progress: 1.0,
      ),
      TaskModel(
        id: '2',
        title: 'Design User Interface',
        description: 'Create mockups and wireframes for the app',
        status: TaskStatus.inProgress,
        priority: TaskPriority.medium,
        projectId: '1',
        assigneeId: '4',
        creatorId: '2',
        dueDate: now.add(const Duration(days: 7)),
        createdAt: now.subtract(const Duration(days: 20)),
        updatedAt: now.subtract(const Duration(hours: 6)),
        progress: 0.6,
      ),
      TaskModel(
        id: '3',
        title: 'Implement Authentication',
        description: 'Add login/logout functionality with JWT',
        status: TaskStatus.inProgress,
        priority: TaskPriority.high,
        projectId: '1',
        assigneeId: '3',
        creatorId: '2',
        dueDate: now.add(const Duration(days: 5)),
        createdAt: now.subtract(const Duration(days: 15)),
        updatedAt: now.subtract(const Duration(hours: 2)),
        progress: 0.3,
      ),
      // Website Redesign tasks
      TaskModel(
        id: '4',
        title: 'Homepage Design',
        description: 'Design new homepage layout',
        status: TaskStatus.toDo,
        priority: TaskPriority.medium,
        projectId: '2',
        assigneeId: '4',
        creatorId: '2',
        dueDate: now.add(const Duration(days: 10)),
        createdAt: now.subtract(const Duration(days: 12)),
        updatedAt: now.subtract(const Duration(days: 10)),
        progress: 0.0,
      ),
      TaskModel(
        id: '5',
        title: 'Content Migration',
        description: 'Move existing content to new structure',
        status: TaskStatus.toDo,
        priority: TaskPriority.low,
        projectId: '2',
        assigneeId: '2',
        creatorId: '2',
        dueDate: now.add(const Duration(days: 20)),
        createdAt: now.subtract(const Duration(days: 8)),
        updatedAt: now.subtract(const Duration(days: 8)),
        progress: 0.0,
      ),
    ]);
  }

  void _createSampleComments() {
    final now = DateTime.now();
    _comments.addAll([
      CommentModel(
        id: '1',
        taskId: '2',
        authorId: '4',
        content: 'Initial wireframes are ready for review',
        createdAt: now.subtract(const Duration(hours: 8)),
      ),
      CommentModel(
        id: '2',
        taskId: '3',
        authorId: '3',
        content: 'Having some issues with JWT implementation. @Jane Manager need help',
        createdAt: now.subtract(const Duration(hours: 4)),
        mentions: ['2'],
      ),
      CommentModel(
        id: '3',
        taskId: '3',
        authorId: '2',
        content: 'I can help you with that. Let\'s have a call tomorrow.',
        createdAt: now.subtract(const Duration(hours: 2)),
      ),
    ]);
  }

  void _createSampleNotifications() {
    final now = DateTime.now();
    _notifications.addAll([
      NotificationModel(
        id: '1',
        userId: '3',
        type: NotificationType.taskAssigned,
        title: 'New Task Assigned',
        message: 'You have been assigned to "Implement Authentication"',
        createdAt: now.subtract(const Duration(hours: 6)),
        metadata: {'taskId': '3'},
      ),
      NotificationModel(
        id: '2',
        userId: '2',
        type: NotificationType.mention,
        title: 'You were mentioned',
        message: 'Bob mentioned you in a comment',
        createdAt: now.subtract(const Duration(hours: 4)),
        metadata: {'taskId': '3', 'commentId': '2'},
      ),
      NotificationModel(
        id: '3',
        userId: '4',
        type: NotificationType.deadlineReminder,
        title: 'Deadline Approaching',
        message: 'Task "Design User Interface" is due in 7 days',
        createdAt: now.subtract(const Duration(hours: 1)),
        metadata: {'taskId': '2'},
      ),
    ]);
  }

  // Auth Methods
  Future<Map<String, dynamic>> login(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _initializeData();
    
    final user = _users.firstWhere(
      (user) => user.email == email,
      orElse: () => throw Exception('Invalid credentials'),
    );

    _currentUserId = user.id;
    
    return {
      'token': 'mock_jwt_token_${user.id}',
      'user': user.toJson(),
      'expiresAt': DateTime.now().add(const Duration(days: 7)).toIso8601String(),
    };
  }

  Future<Map<String, dynamic>> register(String name, String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _initializeData();
    
    if (_users.any((user) => user.email == email)) {
      throw Exception('Email already exists');
    }

    final newUser = UserModel(
      id: (_users.length + 1).toString(),
      name: name,
      email: email,
      role: UserRole.teamMember,
      createdAt: DateTime.now(),
    );

    _users.add(newUser);
    _currentUserId = newUser.id;

    return {
      'token': 'mock_jwt_token_${newUser.id}',
      'user': newUser.toJson(),
      'expiresAt': DateTime.now().add(const Duration(days: 7)).toIso8601String(),
    };
  }

  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 200));
    _currentUserId = null;
  }

  // User Methods
  Future<UserModel> getCurrentUser() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _initializeData();
    
    if (_currentUserId == null) throw Exception('Not authenticated');
    
    return _users.firstWhere(
      (user) => user.id == _currentUserId,
      orElse: () => throw Exception('User not found'),
    );
  }

  Future<List<UserModel>> getUsers() async {
    await Future.delayed(const Duration(milliseconds: 400));
    _initializeData();
    return List.from(_users);
  }

  Future<UserModel> getUserById(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _initializeData();
    
    return _users.firstWhere(
      (user) => user.id == id,
      orElse: () => throw Exception('User not found'),
    );
  }

  Future<UserModel> updateUser(String id, Map<String, dynamic> data) async {
    await Future.delayed(const Duration(milliseconds: 400));
    _initializeData();
    
    final index = _users.indexWhere((user) => user.id == id);
    if (index == -1) throw Exception('User not found');
    
    final user = _users[index];
    final updatedUser = user.copyWith(
      name: data['name'],
      email: data['email'],
      role: data['role'] != null ? UserRole.values.firstWhere((e) => e.name == data['role']) : null,
    );
    
    _users[index] = updatedUser;
    return updatedUser;
  }

  // Project Methods
  Future<List<ProjectModel>> getProjects() async {
    await Future.delayed(const Duration(milliseconds: 500));
    _initializeData();
    
    final currentUser = await getCurrentUser();
    
    if (currentUser.role.canViewAllProjects) {
      return List.from(_projects);
    } else {
      // Return only projects where user is owner or member
      return _projects.where((project) =>
        project.ownerId == currentUser.id ||
        project.memberIds.contains(currentUser.id)
      ).toList();
    }
  }

  Future<ProjectModel> getProjectById(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _initializeData();
    
    return _projects.firstWhere(
      (project) => project.id == id,
      orElse: () => throw Exception('Project not found'),
    );
  }

  Future<ProjectModel> createProject(Map<String, dynamic> data) async {
    await Future.delayed(const Duration(milliseconds: 600));
    _initializeData();
    
    final currentUser = await getCurrentUser();
    if (!currentUser.role.canCreateProjects) {
      throw Exception('Permission denied');
    }
    
    final newProject = ProjectModel(
      id: (_projects.length + 1).toString(),
      name: data['name'],
      description: data['description'],
      status: ProjectStatus.values.firstWhere(
        (e) => e.name == (data['status'] ?? 'planning'),
        orElse: () => ProjectStatus.planning,
      ),
      ownerId: currentUser.id,
      memberIds: List<String>.from(data['memberIds'] ?? [currentUser.id]),
      startDate: data['startDate'] != null ? DateTime.parse(data['startDate']) : DateTime.now(),
      dueDate: data['dueDate'] != null ? DateTime.parse(data['dueDate']) : null,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    
    _projects.add(newProject);
    return newProject;
  }

  Future<ProjectModel> updateProject(String id, Map<String, dynamic> data) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _initializeData();
    
    final index = _projects.indexWhere((project) => project.id == id);
    if (index == -1) throw Exception('Project not found');
    
    final project = _projects[index];
    final updatedProject = project.copyWith(
      name: data['name'],
      description: data['description'],
      status: data['status'] != null ? ProjectStatus.values.firstWhere((e) => e.name == data['status']) : null,
      memberIds: data['memberIds'] != null ? List<String>.from(data['memberIds']) : null,
      dueDate: data['dueDate'] != null ? DateTime.parse(data['dueDate']) : project.dueDate,
      progress: data['progress']?.toDouble(),
    );
    
    _projects[index] = updatedProject;
    return updatedProject;
  }

  Future<void> deleteProject(String id) async {
    await Future.delayed(const Duration(milliseconds: 400));
    _initializeData();
    
    final currentUser = await getCurrentUser();
    final project = _projects.firstWhere(
      (project) => project.id == id,
      orElse: () => throw Exception('Project not found'),
    );
    
    if (!currentUser.role.canDeleteProjects && project.ownerId != currentUser.id) {
      throw Exception('Permission denied');
    }
    
    _projects.removeWhere((project) => project.id == id);
    _tasks.removeWhere((task) => task.projectId == id);
    _comments.removeWhere((comment) => 
      _tasks.any((task) => task.id == comment.taskId && task.projectId == id));
  }

  // Task Methods
  Future<List<TaskModel>> getTasks({String? projectId, String? assigneeId}) async {
    await Future.delayed(const Duration(milliseconds: 400));
    _initializeData();
    
    var tasks = List<TaskModel>.from(_tasks);
    
    if (projectId != null) {
      tasks = tasks.where((task) => task.projectId == projectId).toList();
    }
    
    if (assigneeId != null) {
      tasks = tasks.where((task) => task.assigneeId == assigneeId).toList();
    }
    
    return tasks;
  }

  Future<TaskModel> getTaskById(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _initializeData();
    
    return _tasks.firstWhere(
      (task) => task.id == id,
      orElse: () => throw Exception('Task not found'),
    );
  }

  Future<TaskModel> createTask(Map<String, dynamic> data) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _initializeData();
    
    final currentUser = await getCurrentUser();
    
    final newTask = TaskModel(
      id: (_tasks.length + 1).toString(),
      title: data['title'],
      description: data['description'],
      status: TaskStatus.values.firstWhere(
        (e) => e.name == (data['status'] ?? 'toDo'),
        orElse: () => TaskStatus.toDo,
      ),
      priority: TaskPriority.values.firstWhere(
        (e) => e.name == (data['priority'] ?? 'medium'),
        orElse: () => TaskPriority.medium,
      ),
      projectId: data['projectId'],
      assigneeId: data['assigneeId'],
      creatorId: currentUser.id,
      dueDate: data['dueDate'] != null ? DateTime.parse(data['dueDate']) : null,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      tags: List<String>.from(data['tags'] ?? []),
    );
    
    _tasks.add(newTask);
    
    // Create notification if task is assigned to someone
    if (newTask.assigneeId != null && newTask.assigneeId != currentUser.id) {
      _createNotification(
        newTask.assigneeId!,
        NotificationType.taskAssigned,
        'New Task Assigned',
        'You have been assigned to "${newTask.title}"',
        {'taskId': newTask.id},
      );
    }
    
    return newTask;
  }

  Future<TaskModel> updateTask(String id, Map<String, dynamic> data) async {
    await Future.delayed(const Duration(milliseconds: 400));
    _initializeData();
    
    final index = _tasks.indexWhere((task) => task.id == id);
    if (index == -1) throw Exception('Task not found');
    
    final task = _tasks[index];
    final oldStatus = task.status;
    
    final updatedTask = task.copyWith(
      title: data['title'],
      description: data['description'],
      status: data['status'] != null ? TaskStatus.values.firstWhere((e) => e.name == data['status']) : null,
      priority: data['priority'] != null ? TaskPriority.values.firstWhere((e) => e.name == data['priority']) : null,
      assigneeId: data['assigneeId'],
      dueDate: data['dueDate'] != null ? DateTime.parse(data['dueDate']) : task.dueDate,
      tags: data['tags'] != null ? List<String>.from(data['tags']) : null,
      progress: data['progress']?.toDouble(),
    );
    
    _tasks[index] = updatedTask;
    
    // Create notification if status changed to done
    if (oldStatus != TaskStatus.done && updatedTask.status == TaskStatus.done) {
      final project = _projects.firstWhere((p) => p.id == updatedTask.projectId);
      _createNotification(
        project.ownerId,
        NotificationType.taskCompleted,
        'Task Completed',
        '"${updatedTask.title}" has been completed',
        {'taskId': updatedTask.id},
      );
    }
    
    // Update project progress
    _updateProjectProgress(updatedTask.projectId);
    
    return updatedTask;
  }

  Future<void> deleteTask(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _initializeData();
    
    final task = _tasks.firstWhere(
      (task) => task.id == id,
      orElse: () => throw Exception('Task not found'),
    );
    
    _tasks.removeWhere((task) => task.id == id);
    _comments.removeWhere((comment) => comment.taskId == id);
    
    _updateProjectProgress(task.projectId);
  }

  // Comment Methods
  Future<List<CommentModel>> getComments(String taskId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _initializeData();
    
    return _comments.where((comment) => comment.taskId == taskId).toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
  }

  Future<CommentModel> createComment(Map<String, dynamic> data) async {
    await Future.delayed(const Duration(milliseconds: 400));
    _initializeData();
    
    final currentUser = await getCurrentUser();
    
    final newComment = CommentModel(
      id: (_comments.length + 1).toString(),
      taskId: data['taskId'],
      authorId: currentUser.id,
      content: data['content'],
      createdAt: DateTime.now(),
      mentions: List<String>.from(data['mentions'] ?? []),
    );
    
    _comments.add(newComment);
    
    // Create notifications for mentions
    for (final mentionId in newComment.mentions) {
      if (mentionId != currentUser.id) {
        _createNotification(
          mentionId,
          NotificationType.mention,
          'You were mentioned',
          '${currentUser.name} mentioned you in a comment',
          {'taskId': newComment.taskId, 'commentId': newComment.id},
        );
      }
    }
    
    return newComment;
  }

  // Notification Methods
  Future<List<NotificationModel>> getNotifications() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _initializeData();
    
    final currentUser = await getCurrentUser();
    
    return _notifications.where((notification) => 
      notification.userId == currentUser.id).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  Future<NotificationModel> markNotificationAsRead(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _initializeData();
    
    final index = _notifications.indexWhere((notification) => notification.id == id);
    if (index == -1) throw Exception('Notification not found');
    
    final updatedNotification = _notifications[index].copyWith(isRead: true);
    _notifications[index] = updatedNotification;
    
    return updatedNotification;
  }

  Future<void> markAllNotificationsAsRead() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _initializeData();
    
    final currentUser = await getCurrentUser();
    
    for (int i = 0; i < _notifications.length; i++) {
      if (_notifications[i].userId == currentUser.id && !_notifications[i].isRead) {
        _notifications[i] = _notifications[i].copyWith(isRead: true);
      }
    }
  }

  // Dashboard/Analytics Methods
  Future<Map<String, dynamic>> getDashboardStats() async {
    await Future.delayed(const Duration(milliseconds: 500));
    _initializeData();
    
    final currentUser = await getCurrentUser();
    final userProjects = await getProjects();
    final allTasks = <TaskModel>[];
    
    for (final project in userProjects) {
      final projectTasks = await getTasks(projectId: project.id);
      allTasks.addAll(projectTasks);
    }
    
    final myTasks = allTasks.where((task) => task.assigneeId == currentUser.id).toList();
    
    final taskStats = {
      'total': myTasks.length,
      'toDo': myTasks.where((task) => task.status == TaskStatus.toDo).length,
      'inProgress': myTasks.where((task) => task.status == TaskStatus.inProgress).length,
      'inReview': myTasks.where((task) => task.status == TaskStatus.inReview).length,
      'done': myTasks.where((task) => task.status == TaskStatus.done).length,
    };
    
    final projectStats = {
      'total': userProjects.length,
      'active': userProjects.where((project) => project.status == ProjectStatus.active).length,
      'planning': userProjects.where((project) => project.status == ProjectStatus.planning).length,
      'completed': userProjects.where((project) => project.status == ProjectStatus.completed).length,
      'onHold': userProjects.where((project) => project.status == ProjectStatus.onHold).length,
    };
    
    final overdueTasks = myTasks.where((task) =>
      task.dueDate != null &&
      task.dueDate!.isBefore(DateTime.now()) &&
      task.status != TaskStatus.done
    ).length;
    
    return {
      'taskStats': taskStats,
      'projectStats': projectStats,
      'overdueTasks': overdueTasks,
      'completedThisWeek': myTasks.where((task) =>
        task.status == TaskStatus.done &&
        task.updatedAt.isAfter(DateTime.now().subtract(const Duration(days: 7)))
      ).length,
      'avgProjectProgress': userProjects.isEmpty ? 0.0 : 
        userProjects.map((p) => p.progress).reduce((a, b) => a + b) / userProjects.length,
    };
  }

  Future<List<Map<String, dynamic>>> getTasksForExport({String? projectId}) async {
    await Future.delayed(const Duration(milliseconds: 400));
    _initializeData();
    
    final tasks = await getTasks(projectId: projectId);
    final result = <Map<String, dynamic>>[];
    
    for (final task in tasks) {
      final assignee = task.assigneeId != null ? 
        await getUserById(task.assigneeId!) : null;
      final project = await getProjectById(task.projectId);
      
      result.add({
        'Task ID': task.id,
        'Title': task.title,
        'Description': task.description,
        'Status': task.status.displayName,
        'Priority': task.priority.displayName,
        'Project': project.name,
        'Assignee': assignee?.name ?? 'Unassigned',
        'Due Date': task.dueDate?.toIso8601String()?.substring(0, 10) ?? '',
        'Progress': '${(task.progress * 100).toInt()}%',
        'Created': task.createdAt.toIso8601String().substring(0, 10),
        'Updated': task.updatedAt.toIso8601String().substring(0, 10),
        'Tags': task.tags.join(', '),
      });
    }
    
    return result;
  }

  // Helper Methods
  void _createNotification(
    String userId,
    NotificationType type,
    String title,
    String message,
    Map<String, dynamic>? metadata,
  ) {
    _notifications.add(
      NotificationModel(
        id: (_notifications.length + 1).toString(),
        userId: userId,
        type: type,
        title: title,
        message: message,
        createdAt: DateTime.now(),
        metadata: metadata,
      ),
    );
  }

  void _updateProjectProgress(String projectId) {
    final projectTasks = _tasks.where((task) => task.projectId == projectId).toList();
    
    if (projectTasks.isEmpty) return;
    
    final completedTasks = projectTasks.where((task) => task.status == TaskStatus.done).length;
    final progress = completedTasks / projectTasks.length;
    
    final projectIndex = _projects.indexWhere((project) => project.id == projectId);
    if (projectIndex != -1) {
      _projects[projectIndex] = _projects[projectIndex].copyWith(progress: progress);
    }
  }

  // Search Methods
  Future<List<TaskModel>> searchTasks(String query) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _initializeData();
    
    final lowercaseQuery = query.toLowerCase();
    return _tasks.where((task) =>
      task.title.toLowerCase().contains(lowercaseQuery) ||
      task.description.toLowerCase().contains(lowercaseQuery) ||
      task.tags.any((tag) => tag.toLowerCase().contains(lowercaseQuery))
    ).toList();
  }

  Future<List<ProjectModel>> searchProjects(String query) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _initializeData();
    
    final lowercaseQuery = query.toLowerCase();
    return _projects.where((project) =>
      project.name.toLowerCase().contains(lowercaseQuery) ||
      project.description.toLowerCase().contains(lowercaseQuery)
    ).toList();
  }
}