// // lib/data/services/mock_api_service.dart

// import 'dart:math';
// import '../models/user_model.dart';
// import '../models/project_model.dart';
// import '../models/task_model.dart';
// import '../models/comment_model.dart';
// import '../models/notification_model.dart';
// import '../../core/enums/user_role.dart';
// import '../../core/enums/project_status.dart';
// import '../../core/enums/task_status.dart';
// import '../../core/enums/task_priority.dart';

// class MockApiService {
//   static final MockApiService _instance = MockApiService._internal();
//   factory MockApiService() => _instance;
//   MockApiService._internal();

//   // In-memory data storage
//   final List<UserModel> _users = [];
//   final List<ProjectModel> _projects = [];
//   final List<TaskModel> _tasks = [];
//   final List<CommentModel> _comments = [];
//   final List<NotificationModel> _notifications = [];
  
//   String? _currentUserId;
//   final Random _random = Random();

//   // Initialize with sample data
//   void _initializeData() {
//     if (_users.isEmpty) {
//       _createSampleUsers();
//       _createSampleProjects();
//       _createSampleTasks();
//       _createSampleComments();
//       _createSampleNotifications();
//     }
//   }

//   void _createSampleUsers() {
//     final now = DateTime.now();
//     _users.addAll([
//       UserModel(
//         id: '1',
//         name: 'John Admin',
//         email: 'admin@example.com',
//         role: UserRole.admin,
//         createdAt: now.subtract(const Duration(days: 30)),
//         lastLoginAt: now.subtract(const Duration(hours: 1)),
//       ),
//       UserModel(
//         id: '2',
//         name: 'Jane Manager',
//         email: 'manager@example.com',
//         role: UserRole.projectManager,
//         createdAt: now.subtract(const Duration(days: 25)),
//         lastLoginAt: now.subtract(const Duration(hours: 2)),
//       ),
//       UserModel(
//         id: '3',
//         name: 'Bob Developer',
//         email: 'developer@example.com',
//         role: UserRole.teamMember,
//         createdAt: now.subtract(const Duration(days: 20)),
//         lastLoginAt: now.subtract(const Duration(hours: 3)),
//       ),
//       UserModel(
//         id: '4',
//         name: 'Alice Designer',
//         email: 'designer@example.com',
//         role: UserRole.teamMember,
//         createdAt: now.subtract(const Duration(days: 15)),
//         lastLoginAt: now.subtract(const Duration(hours: 4)),
//       ),
//     ]);
//   }

//   void _createSampleProjects() {
//     final now = DateTime.now();
//     _projects.addAll([
//       ProjectModel(
//         id: '1',
//         name: 'Mobile App Development',
//         description: 'Developing a cross-platform mobile application',
//         status: ProjectStatus.active,
//         ownerId: '2',
//         memberIds: ['2', '3', '4'],
//         startDate: now.subtract(const Duration(days: 30)),
//         dueDate: now.add(const Duration(days: 60)),
//         createdAt: now.subtract(const Duration(days: 30)),
//         updatedAt: now.subtract(const Duration(days: 1)),
//         progress: 0.45,
//       ),
//       ProjectModel(
//         id: '2',
//         name: 'Website Redesign',
//         description: 'Complete overhaul of company website',
//         status: ProjectStatus.active,
//         ownerId: '2',
//         memberIds: ['2', '4'],
//         startDate: now.subtract(const Duration(days: 15)),
//         dueDate: now.add(const Duration(days: 45)),
//         createdAt: now.subtract(const Duration(days: 15)),
//         updatedAt: now.subtract(const Duration(hours: 5)),
//         progress: 0.25,
//       ),
//       ProjectModel(
//         id: '3',
//         name: 'API Integration',
//         description: 'Integrate third-party APIs',
//         status: ProjectStatus.planning,
//         ownerId: '2',
//         memberIds: ['2', '3'],
//         startDate: now.add(const Duration(days: 7)),
//         dueDate: now.add(const Duration(days: 90)),
//         createdAt: now.subtract(const Duration(days: 5)),
//         updatedAt: now.subtract(const Duration(days: 2)),
//         progress: 0.0,
//       ),
//     ]);
//   }

//   void _createSampleTasks() {
//     final now = DateTime.now();
//     _tasks.addAll([
//       // Mobile App Development tasks
//       TaskModel(
//         id: '1',
//         title: 'Setup Flutter Project',
//         description: 'Initialize Flutter project with proper structure',
//         status: TaskStatus.done,
//         priority: TaskPriority.high,
//         projectId: '1',
//         assigneeId: '3',
//         creatorId: '2',
//         dueDate: now.add(const Duration(days: 3)),
//         createdAt: now.subtract(const Duration(days: 28)),
//         updatedAt: now.subtract(const Duration(days: 25)),
//         progress: 1.0,
//       ),
//       TaskModel(
//         id: '2',
//         title: 'Design User Interface',
//         description: 'Create mockups and wireframes for the app',
//         status: TaskStatus.inProgress,
//         priority: TaskPriority.medium,
//         projectId: '1',
//         assigneeId: '4',
//         creatorId: '2',
//         dueDate: now.add(const Duration(days: 7)),
//         createdAt: now.subtract(const Duration(days: 20)),
//         updatedAt: now.subtract(const Duration(hours: 6)),
//         progress: 0.6,
//       ),
//       TaskModel(
//         id: '3',
//         title: 'Implement Authentication',
//         description: 'Add login/logout functionality with JWT',
//         status: TaskStatus.inProgress,
//         priority: TaskPriority.high,
//         projectId: '1',
//         assigneeId: '3',
//         creatorId: '2',
//         dueDate: now.add(const Duration(days: 5)),
//         createdAt: now.subtract(const Duration(days: 15)),
//         updatedAt: now.subtract(const Duration(hours: 2)),
//         progress: 0.3,
//       ),
//       // Website Redesign tasks
//       TaskModel(
//         id: '4',
//         title: 'Homepage Design',
//         description: 'Design new homepage layout',
//         status: TaskStatus.toDo,
//         priority: TaskPriority.medium,
//         projectId: '2',
//         assigneeId: '4',
//         creatorId: '2',
//         dueDate: now.add(const Duration(days: 10)),
//         createdAt: now.subtract(const Duration(days: 12)),
//         updatedAt: now.subtract(const Duration(days: 10)),
//         progress: 0.0,
//       ),
//       TaskModel(
//         id: '5',
//         title: 'Content Migration',
//         description: 'Move existing content to new structure',
//         status: TaskStatus.toDo,
//         priority: TaskPriority.low,
//         projectId: '2',
//         assigneeId: '2',
//         creatorId: '2',
//         dueDate: now.add(const Duration(days: 20)),
//         createdAt: now.subtract(const Duration(days: 8)),
//         updatedAt: now.subtract(const Duration(days: 8)),
//         progress: 0.0,
//       ),
//     ]);
//   }

//   void _createSampleComments() {
//     final now = DateTime.now();
//     _comments.addAll([
//       CommentModel(
//         id: '1',
//         taskId: '2',
//         authorId: '4',
//         content: 'Initial wireframes are ready for review',
//         createdAt: now.subtract(const Duration(hours: 8)),
//       ),
//       CommentModel(
//         id: '2',
//         taskId: '3',
//         authorId: '3',
//         content: 'Having some issues with JWT implementation. @Jane Manager need help',
//         createdAt: now.subtract(const Duration(hours: 4)),
//         mentions: ['2'],
//       ),
//       CommentModel(
//         id: '3',
//         taskId: '3',
//         authorId: '2',
//         content: 'I can help you with that. Let\'s have a call tomorrow.',
//         createdAt: now.subtract(const Duration(hours: 2)),
//       ),
//     ]);
//   }

//   void _createSampleNotifications() {
//     final now = DateTime.now();
//     _notifications.addAll([
//       NotificationModel(
//         id: '1',
//         userId: '3',
//         type: NotificationType.taskAssigned,
//         title: 'New Task Assigned',
//         message: 'You have been assigned to "Implement Authentication"',
//         createdAt: now.subtract(const Duration(hours: 6)),
//         metadata: {'taskId': '3'},
//       ),
//       NotificationModel(
//         id: '2',
//         userId: '2',
//         type: NotificationType.mention,
//         title: 'You were mentioned',
//         message: 'Bob mentioned you in a comment',
//         createdAt: now.subtract(const Duration(hours: 4)),
//         metadata: {'taskId': '3', 'commentId': '2'},
//       ),
//       NotificationModel(
//         id: '3',
//         userId: '4',
//         type: NotificationType.deadlineReminder,
//         title: 'Deadline Approaching',
//         message: 'Task "Design User Interface" is due in 7 days',
//         createdAt: now.subtract(const Duration(hours: 1)),
//         metadata: {'taskId': '2'},
//       ),
//     ]);
//   }

//   // Auth Methods
//   Future<Map<String, dynamic>> login(String email, String password) async {
//     await Future.delayed(const Duration(milliseconds: 500));
//     _initializeData();
    
//     final user = _users.firstWhere(
//       (user) => user.email == email,
//       orElse: () => throw Exception('Invalid credentials'),
//     );

//     _currentUserId = user.id;
    
//     return {
//       'token': 'mock_jwt_token_${user.id}',
//       'user': user.toJson(),
//       'expiresAt': DateTime.now().add(const Duration(days: 7)).toIso8601String(),
//     };
//   }

//   Future<Map<String, dynamic>> register(String name, String email, String password) async {
//     await Future.delayed(const Duration(milliseconds: 500));
//     _initializeData();
    
//     if (_users.any((user) => user.email == email)) {
//       throw Exception('Email already exists');
//     }

//     final newUser = UserModel(
//       id: (_users.length + 1).toString(),
//       name: name,
//       email: email,
//       role: UserRole.teamMember,
//       createdAt: DateTime.now(),
//     );

//     _users.add(newUser);
//     _currentUserId = newUser.id;

//     return {
//       'token': 'mock_jwt_token_${newUser.id}',
//       'user': newUser.toJson(),
//       'expiresAt': DateTime.now().add(const Duration(days: 7)).toIso8601String(),
//     };
//   }

//   Future<void> logout() async {
//     await Future.delayed(const Duration(milliseconds: 200));
//     _currentUserId = null;
//   }

//   // User Methods
//   Future<UserModel> getCurrentUser() async {
//     await Future.delayed(const Duration(milliseconds: 300));
//     _initializeData();
    
//     if (_currentUserId == null) throw Exception('Not authenticated');
    
//     return _users.firstWhere(
//       (user) => user.id == _currentUserId,
//       orElse: () => throw Exception('User not found'),
//     );
//   }

//   Future<List<UserModel>> getUsers() async {
//     await Future.delayed(const Duration(milliseconds: 400));
//     _initializeData();
//     return List.from(_users);
//   }

//   Future<UserModel> getUserById(String id) async {
//     await Future.delayed(const Duration(milliseconds: 300));
//     _initializeData();
    
//     return _users.firstWhere(
//       (user) => user.id == id,
//       orElse: () => throw Exception('User not found'),
//     );
//   }

//   Future<UserModel> updateUser(String id, Map<String, dynamic> data) async {
//     await Future.delayed(const Duration(milliseconds: 400));
//     _initializeData();
    
//     final index = _users.indexWhere((user) => user.id == id);
//     if (index == -1) throw Exception('User not found');
    
//     final user = _users[index];
//     final updatedUser = user.copyWith(
//       name: data['name'],
//       email: data['email'],
//       role: data['role'] != null ? UserRole.values.firstWhere((e) => e.name == data['role']) : null,
//     );
    
//     _users[index] = updatedUser;
//     return updatedUser;
//   }

//   // Project Methods
//   Future<List<ProjectModel>> getProjects() async {
//     await Future.delayed(const Duration(milliseconds: 500));
//     _initializeData();
    
//     final currentUser = await getCurrentUser();
    
//     if (currentUser.role.canViewAllProjects) {
//       return List.from(_projects);
//     } else {
//       // Return only projects where user is owner or member
//       return _projects.where((project) =>
//         project.ownerId == currentUser.id ||
//         project.memberIds.contains(currentUser.id)
//       ).toList();
//     }
//   }

//   Future<ProjectModel> getProjectById(String id) async {
//     await Future.delayed(const Duration(milliseconds: 300));
//     _initializeData();
    
//     return _projects.firstWhere(
//       (project) => project.id == id,
//       orElse: () => throw Exception('Project not found'),
//     );
//   }

//   Future<ProjectModel> createProject(Map<String, dynamic> data) async {
//     await Future.delayed(const Duration(milliseconds: 600));
//     _initializeData();
    
//     final currentUser = await getCurrentUser();
//     if (!currentUser.role.canCreateProjects) {
//       throw Exception('Permission denied');
//     }
    
//     final newProject = ProjectModel(
//       id: (_projects.length + 1).toString(),
//       name: data['name'],
//       description: data['description'],
//       status: ProjectStatus.values.firstWhere(
//         (e) => e.name == (data['status'] ?? 'planning'),
//         orElse: () => ProjectStatus.planning,
//       ),
//       ownerId: currentUser.id,
//       memberIds: List<String>.from(data['memberIds'] ?? [currentUser.id]),
//       startDate: data['startDate'] != null ? DateTime.parse(data['startDate']) : DateTime.now(),
//       dueDate: data['dueDate'] != null ? DateTime.parse(data['dueDate']) : null,
//       createdAt: DateTime.now(),
//       updatedAt: DateTime.now(),
//     );
    
//     _projects.add(newProject);
//     return newProject;
//   }

//   Future<ProjectModel> updateProject(String id, Map<String, dynamic> data) async {
//     await Future.delayed(const Duration(milliseconds: 500));
//     _initializeData();
    
//     final index = _projects.indexWhere((project) => project.id == id);
//     if (index == -1) throw Exception('Project not found');
    
//     final project = _projects[index];
//     final updatedProject = project.copyWith(
//       name: data['name'],
//       description: data['description'],
//       status: data['status'] != null ? ProjectStatus.values.firstWhere((e) => e.name == data['status']) : null,
//       memberIds: data['memberIds'] != null ? List<String>.from(data['memberIds']) : null,
//       dueDate: data['dueDate'] != null ? DateTime.parse(data['dueDate']) : project.dueDate,
//       progress: data['progress']?.toDouble(),
//     );
    
//     _projects[index] = updatedProject;
//     return updatedProject;
//   }

//   Future<void> deleteProject(String id) async {
//     await Future.delayed(const Duration(milliseconds: 400));
//     _initializeData();
    
//     final currentUser = await getCurrentUser();
//     final project = _projects.firstWhere(
//       (project) => project.id == id,
//       orElse: () => throw Exception('Project not found'),
//     );
    
//     if (!currentUser.role.canDeleteProjects && project.ownerId != currentUser.id) {
//       throw Exception('Permission denied');
//     }
    
//     _projects.removeWhere((project) => project.id == id);
//     _tasks.removeWhere((task) => task.projectId == id);
//     _comments.removeWhere((comment) => 
//       _tasks.any((task) => task.id == comment.taskId && task.projectId == id));
//   }

//   // Task Methods
//   Future<List<TaskModel>> getTasks({String? projectId, String? assigneeId}) async {
//     await Future.delayed(const Duration(milliseconds: 400));
//     _initializeData();
    
//     var tasks = List<TaskModel>.from(_tasks);
    
//     if (projectId != null) {
//       tasks = tasks.where((task) => task.projectId == projectId).toList();
//     }
    
//     if (assigneeId != null) {
//       tasks = tasks.where((task) => task.assigneeId == assigneeId).toList();
//     }
    
//     return tasks;
//   }

//   Future<TaskModel> getTaskById(String id) async {
//     await Future.delayed(const Duration(milliseconds: 300));
//     _initializeData();
    
//     return _tasks.firstWhere(
//       (task) => task.id == id,
//       orElse: () => throw Exception('Task not found'),
//     );
//   }

//   Future<TaskModel> createTask(Map<String, dynamic> data) async {
//     await Future.delayed(const Duration(milliseconds: 500));
//     _initializeData();
    
//     final currentUser = await getCurrentUser();
    
//     final newTask = TaskModel(
//       id: (_tasks.length + 1).toString(),
//       title: data['title'],
//       description: data['description'],
//       status: TaskStatus.values.firstWhere(
//         (e) => e.name == (data['status'] ?? 'toDo'),
//         orElse: () => TaskStatus.toDo,
//       ),
//       priority: TaskPriority.values.firstWhere(
//         (e) => e.name == (data['priority'] ?? 'medium'),
//         orElse: () => TaskPriority.medium,
//       ),
//       projectId: data['projectId'],
//       assigneeId: data['assigneeId'],
//       creatorId: currentUser.id,
//       dueDate: data['dueDate'] != null ? DateTime.parse(data['dueDate']) : null,
//       createdAt: DateTime.now(),
//       updatedAt: DateTime.now(),
//       tags: List<String>.from(data['tags'] ?? []),
//     );
    
//     _tasks.add(newTask);
    
//     // Create notification if task is assigned to someone
//     if (newTask.assigneeId != null && newTask.assigneeId != currentUser.id) {
//       _createNotification(
//         newTask.assigneeId!,
//         NotificationType.taskAssigned,
//         'New Task Assigned',
//         'You have been assigned to "${newTask.title}"',
//         {'taskId': newTask.id},
//       );
//     }
    
//     return newTask;
//   }

//   Future<TaskModel> updateTask(String id, Map<String, dynamic> data) async {
//     await Future.delayed(const Duration(milliseconds: 400));
//     _initializeData();
    
//     final index = _tasks.indexWhere((task) => task.id == id);
//     if (index == -1) throw Exception('Task not found');
    
//     final task = _tasks[index];
//     final oldStatus = task.status;
    
//     final updatedTask = task.copyWith(
//       title: data['title'],
//       description: data['description'],
//       status: data['status'] != null ? TaskStatus.values.firstWhere((e) => e.name == data['status']) : null,
//       priority: data['priority'] != null ? TaskPriority.values.firstWhere((e) => e.name == data['priority']) : null,
//       assigneeId: data['assigneeId'],
//       dueDate: data['dueDate'] != null ? DateTime.parse(data['dueDate']) : task.dueDate,
//       tags: data['tags'] != null ? List<String>.from(data['tags']) : null,
//       progress: data['progress']?.toDouble(),
//     );
    
//     _tasks[index] = updatedTask;
    
//     // Create notification if status changed to done
//     if (oldStatus != TaskStatus.done && updatedTask.status == TaskStatus.done) {
//       final project = _projects.firstWhere((p) => p.id == updatedTask.projectId);
//       _createNotification(
//         project.ownerId,
//         NotificationType.taskCompleted,
//         'Task Completed',
//         '"${updatedTask.title}" has been completed',
//         {'taskId': updatedTask.id},
//       );
//     }
    
//     // Update project progress
//     _updateProjectProgress(updatedTask.projectId);
    
//     return updatedTask;
//   }

//   Future<void> deleteTask(String id) async {
//     await Future.delayed(const Duration(milliseconds: 300));
//     _initializeData();
    
//     final task = _tasks.firstWhere(
//       (task) => task.id == id,
//       orElse: () => throw Exception('Task not found'),
//     );
    
//     _tasks.removeWhere((task) => task.id == id);
//     _comments.removeWhere((comment) => comment.taskId == id);
    
//     _updateProjectProgress(task.projectId);
//   }

//   // Comment Methods
//   Future<List<CommentModel>> getComments(String taskId) async {
//     await Future.delayed(const Duration(milliseconds: 300));
//     _initializeData();
    
//     return _comments.where((comment) => comment.taskId == taskId).toList()
//       ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
//   }

//   Future<CommentModel> createComment(Map<String, dynamic> data) async {
//     await Future.delayed(const Duration(milliseconds: 400));
//     _initializeData();
    
//     final currentUser = await getCurrentUser();
    
//     final newComment = CommentModel(
//       id: (_comments.length + 1).toString(),
//       taskId: data['taskId'],
//       authorId: currentUser.id,
//       content: data['content'],
//       createdAt: DateTime.now(),
//       mentions: List<String>.from(data['mentions'] ?? []),
//     );
    
//     _comments.add(newComment);
    
//     // Create notifications for mentions
//     for (final mentionId in newComment.mentions) {
//       if (mentionId != currentUser.id) {
//         _createNotification(
//           mentionId,
//           NotificationType.mention,
//           'You were mentioned',
//           '${currentUser.name} mentioned you in a comment',
//           {'taskId': newComment.taskId, 'commentId': newComment.id},
//         );
//       }
//     }
    
//     return newComment;
//   }

//   // Notification Methods
//   Future<List<NotificationModel>> getNotifications() async {
//     await Future.delayed(const Duration(milliseconds: 300));
//     _initializeData();
    
//     final currentUser = await getCurrentUser();
    
//     return _notifications.where((notification) => 
//       notification.userId == currentUser.id).toList()
//       ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
//   }

//   Future<NotificationModel> markNotificationAsRead(String id) async {
//     await Future.delayed(const Duration(milliseconds: 200));
//     _initializeData();
    
//     final index = _notifications.indexWhere((notification) => notification.id == id);
//     if (index == -1) throw Exception('Notification not found');
    
//     final updatedNotification = _notifications[index].copyWith(isRead: true);
//     _notifications[index] = updatedNotification;
    
//     return updatedNotification;
//   }

//   Future<void> markAllNotificationsAsRead() async {
//     await Future.delayed(const Duration(milliseconds: 300));
//     _initializeData();
    
//     final currentUser = await getCurrentUser();
    
//     for (int i = 0; i < _notifications.length; i++) {
//       if (_notifications[i].userId == currentUser.id && !_notifications[i].isRead) {
//         _notifications[i] = _notifications[i].copyWith(isRead: true);
//       }
//     }
//   }

//   // Dashboard/Analytics Methods
//   Future<Map<String, dynamic>> getDashboardStats() async {
//     await Future.delayed(const Duration(milliseconds: 500));
//     _initializeData();
    
//     final currentUser = await getCurrentUser();
//     final userProjects = await getProjects();
//     final allTasks = <TaskModel>[];
    
//     for (final project in userProjects) {
//       final projectTasks = await getTasks(projectId: project.id);
//       allTasks.addAll(projectTasks);
//     }
    
//     final myTasks = allTasks.where((task) => task.assigneeId == currentUser.id).toList();
    
//     final taskStats = {
//       'total': myTasks.length,
//       'toDo': myTasks.where((task) => task.status == TaskStatus.toDo).length,
//       'inProgress': myTasks.where((task) => task.status == TaskStatus.inProgress).length,
//       'inReview': myTasks.where((task) => task.status == TaskStatus.inReview).length,
//       'done': myTasks.where((task) => task.status == TaskStatus.done).length,
//     };
    
//     final projectStats = {
//       'total': userProjects.length,
//       'active': userProjects.where((project) => project.status == ProjectStatus.active).length,
//       'planning': userProjects.where((project) => project.status == ProjectStatus.planning).length,
//       'completed': userProjects.where((project) => project.status == ProjectStatus.completed).length,
//       'onHold': userProjects.where((project) => project.status == ProjectStatus.onHold).length,
//     };
    
//     final overdueTasks = myTasks.where((task) =>
//       task.dueDate != null &&
//       task.dueDate!.isBefore(DateTime.now()) &&
//       task.status != TaskStatus.done
//     ).length;
    
//     return {
//       'taskStats': taskStats,
//       'projectStats': projectStats,
//       'overdueTasks': overdueTasks,
//       'completedThisWeek': myTasks.where((task) =>
//         task.status == TaskStatus.done &&
//         task.updatedAt.isAfter(DateTime.now().subtract(const Duration(days: 7)))
//       ).length,
//       'avgProjectProgress': userProjects.isEmpty ? 0.0 : 
//         userProjects.map((p) => p.progress).reduce((a, b) => a + b) / userProjects.length,
//     };
//   }

//   Future<List<Map<String, dynamic>>> getTasksForExport({String? projectId}) async {
//     await Future.delayed(const Duration(milliseconds: 400));
//     _initializeData();
    
//     final tasks = await getTasks(projectId: projectId);
//     final result = <Map<String, dynamic>>[];
    
//     for (final task in tasks) {
//       final assignee = task.assigneeId != null ? 
//         await getUserById(task.assigneeId!) : null;
//       final project = await getProjectById(task.projectId);
      
//       result.add({
//         'Task ID': task.id,
//         'Title': task.title,
//         'Description': task.description,
//         'Status': task.status.displayName,
//         'Priority': task.priority.displayName,
//         'Project': project.name,
//         'Assignee': assignee?.name ?? 'Unassigned',
//         'Due Date': task.dueDate?.toIso8601String()?.substring(0, 10) ?? '',
//         'Progress': '${(task.progress * 100).toInt()}%',
//         'Created': task.createdAt.toIso8601String().substring(0, 10),
//         'Updated': task.updatedAt.toIso8601String().substring(0, 10),
//         'Tags': task.tags.join(', '),
//       });
//     }
    
//     return result;
//   }

//   // Helper Methods
//   void _createNotification(
//     String userId,
//     NotificationType type,
//     String title,
//     String message,
//     Map<String, dynamic>? metadata,
//   ) {
//     _notifications.add(
//       NotificationModel(
//         id: (_notifications.length + 1).toString(),
//         userId: userId,
//         type: type,
//         title: title,
//         message: message,
//         createdAt: DateTime.now(),
//         metadata: metadata,
//       ),
//     );
//   }

//   void _updateProjectProgress(String projectId) {
//     final projectTasks = _tasks.where((task) => task.projectId == projectId).toList();
    
//     if (projectTasks.isEmpty) return;
    
//     final completedTasks = projectTasks.where((task) => task.status == TaskStatus.done).length;
//     final progress = completedTasks / projectTasks.length;
    
//     final projectIndex = _projects.indexWhere((project) => project.id == projectId);
//     if (projectIndex != -1) {
//       _projects[projectIndex] = _projects[projectIndex].copyWith(progress: progress);
//     }
//   }

//   // Search Methods
//   Future<List<TaskModel>> searchTasks(String query) async {
//     await Future.delayed(const Duration(milliseconds: 300));
//     _initializeData();
    
//     final lowercaseQuery = query.toLowerCase();
//     return _tasks.where((task) =>
//       task.title.toLowerCase().contains(lowercaseQuery) ||
//       task.description.toLowerCase().contains(lowercaseQuery) ||
//       task.tags.any((tag) => tag.toLowerCase().contains(lowercaseQuery))
//     ).toList();
//   }

//   Future<List<ProjectModel>> searchProjects(String query) async {
//     await Future.delayed(const Duration(milliseconds: 300));
//     _initializeData();
    
//     final lowercaseQuery = query.toLowerCase();
//     return _projects.where((project) =>
//       project.name.toLowerCase().contains(lowercaseQuery) ||
//       project.description.toLowerCase().contains(lowercaseQuery)
//     ).toList();
//   }

//     Future<Map<String, dynamic>> getEnhancedDashboardStats() async {
//     await Future.delayed(const Duration(milliseconds: 500));
//     _initializeData();
    
//     final currentUser = await getCurrentUser();
//     final userProjects = await getProjects();
//     final allTasks = <TaskModel>[];
    
//     for (final project in userProjects) {
//       final projectTasks = await getTasks(projectId: project.id);
//       allTasks.addAll(projectTasks);
//     }
    
//     final myTasks = allTasks.where((task) => task.assigneeId == currentUser.id).toList();
    
//     final taskStats = {
//       'total': myTasks.length,
//       'toDo': myTasks.where((task) => task.status == TaskStatus.toDo).length,
//       'inProgress': myTasks.where((task) => task.status == TaskStatus.inProgress).length,
//       'inReview': myTasks.where((task) => task.status == TaskStatus.inReview).length,
//       'done': myTasks.where((task) => task.status == TaskStatus.done).length,
//     };
    
//     final projectStats = {
//       'total': userProjects.length,
//       'active': userProjects.where((project) => project.status == ProjectStatus.active).length,
//       'planning': userProjects.where((project) => project.status == ProjectStatus.planning).length,
//       'completed': userProjects.where((project) => project.status == ProjectStatus.completed).length,
//       'onHold': userProjects.where((project) => project.status == ProjectStatus.onHold).length,
//     };
    
//     final overdueTasks = myTasks.where((task) =>
//       task.dueDate != null &&
//       task.dueDate!.isBefore(DateTime.now()) &&
//       task.status != TaskStatus.done
//     ).length;

//     // Weekly completion data (mock 7 days)
//     final weeklyCompletions = [
//       myTasks.where((task) => 
//         task.status == TaskStatus.done && 
//         _isTaskCompletedOnDay(task, DateTime.now().subtract(const Duration(days: 6)))
//       ).length,
//       myTasks.where((task) => 
//         task.status == TaskStatus.done && 
//         _isTaskCompletedOnDay(task, DateTime.now().subtract(const Duration(days: 5)))
//       ).length,
//       myTasks.where((task) => 
//         task.status == TaskStatus.done && 
//         _isTaskCompletedOnDay(task, DateTime.now().subtract(const Duration(days: 4)))
//       ).length,
//       myTasks.where((task) => 
//         task.status == TaskStatus.done && 
//         _isTaskCompletedOnDay(task, DateTime.now().subtract(const Duration(days: 3)))
//       ).length,
//       myTasks.where((task) => 
//         task.status == TaskStatus.done && 
//         _isTaskCompletedOnDay(task, DateTime.now().subtract(const Duration(days: 2)))
//       ).length,
//       myTasks.where((task) => 
//         task.status == TaskStatus.done && 
//         _isTaskCompletedOnDay(task, DateTime.now().subtract(const Duration(days: 1)))
//       ).length,
//       myTasks.where((task) => 
//         task.status == TaskStatus.done && 
//         _isTaskCompletedOnDay(task, DateTime.now())
//       ).length,
//     ];
    
//     return {
//       'taskStats': taskStats,
//       'projectStats': projectStats,
//       'overdueTasks': overdueTasks,
//       'completedThisWeek': myTasks.where((task) =>
//         task.status == TaskStatus.done &&
//         task.updatedAt.isAfter(DateTime.now().subtract(const Duration(days: 7)))
//       ).length,
//       'avgProjectProgress': userProjects.isEmpty ? 0.0 : 
//         userProjects.map((p) => p.progress).reduce((a, b) => a + b) / userProjects.length,
//       'weeklyCompletions': weeklyCompletions,
//       'topProjects': userProjects.take(5).map((p) => {
//         'name': p.name,
//         'progress': p.progress,
//         'id': p.id,
//       }).toList(),
//     };
//   }

//   bool _isTaskCompletedOnDay(TaskModel task, DateTime day) {
//     if (task.status != TaskStatus.done) return false;
//     final taskDay = DateTime(task.updatedAt.year, task.updatedAt.month, task.updatedAt.day);
//     final checkDay = DateTime(day.year, day.month, day.day);
//     return taskDay.isAtSameMomentAs(checkDay);
//   }

//   // Enhanced Search Methods
//   Future<Map<String, dynamic>> globalSearch(String query) async {
//     await Future.delayed(const Duration(milliseconds: 300));
//     _initializeData();
    
//     final lowercaseQuery = query.toLowerCase();
    
//     // Search projects
//     final projectResults = _projects.where((project) =>
//       project.name.toLowerCase().contains(lowercaseQuery) ||
//       project.description.toLowerCase().contains(lowercaseQuery)
//     ).toList();
    
//     // Search tasks
//     final taskResults = _tasks.where((task) =>
//       task.title.toLowerCase().contains(lowercaseQuery) ||
//       task.description.toLowerCase().contains(lowercaseQuery) ||
//       task.tags.any((tag) => tag.toLowerCase().contains(lowercaseQuery))
//     ).toList();
    
//     // Search users
//     final userResults = _users.where((user) =>
//       user.name.toLowerCase().contains(lowercaseQuery) ||
//       user.email.toLowerCase().contains(lowercaseQuery)
//     ).toList();
    
//     return {
//       'projects': projectResults.map((p) => p.toJson()).toList(),
//       'tasks': taskResults.map((t) => t.toJson()).toList(),
//       'users': userResults.map((u) => u.toJson()).toList(),
//       'totalResults': projectResults.length + taskResults.length + userResults.length,
//     };
//   }

//   // Search with filters
//   Future<List<TaskModel>> searchTasksWithFilters({
//     String? query,
//     TaskStatus? status,
//     TaskPriority? priority,
//     String? assigneeId,
//     String? projectId,
//     bool? isOverdue,
//   }) async {
//     await Future.delayed(const Duration(milliseconds: 200));
//     _initializeData();
    
//     var results = List<TaskModel>.from(_tasks);
    
//     // Apply text search
//     if (query != null && query.trim().isNotEmpty) {
//       final lowercaseQuery = query.toLowerCase();
//       results = results.where((task) =>
//         task.title.toLowerCase().contains(lowercaseQuery) ||
//         task.description.toLowerCase().contains(lowercaseQuery) ||
//         task.tags.any((tag) => tag.toLowerCase().contains(lowercaseQuery))
//       ).toList();
//     }
    
//     // Apply status filter
//     if (status != null) {
//       results = results.where((task) => task.status == status).toList();
//     }
    
//     // Apply priority filter
//     if (priority != null) {
//       results = results.where((task) => task.priority == priority).toList();
//     }
    
//     // Apply assignee filter
//     if (assigneeId != null) {
//       results = results.where((task) => task.assigneeId == assigneeId).toList();
//     }
    
//     // Apply project filter
//     if (projectId != null) {
//       results = results.where((task) => task.projectId == projectId).toList();
//     }
    
//     // Apply overdue filter
//     if (isOverdue == true) {
//       final now = DateTime.now();
//       results = results.where((task) =>
//         task.dueDate != null &&
//         task.dueDate!.isBefore(now) &&
//         task.status != TaskStatus.done
//       ).toList();
//     }
    
//     return results;
//   }

//   Future<List<ProjectModel>> searchProjectsWithFilters({
//     String? query,
//     ProjectStatus? status,
//     String? ownerId,
//   }) async {
//     await Future.delayed(const Duration(milliseconds: 200));
//     _initializeData();
    
//     var results = List<ProjectModel>.from(_projects);
    
//     // Apply text search
//     if (query != null && query.trim().isNotEmpty) {
//       final lowercaseQuery = query.toLowerCase();
//       results = results.where((project) =>
//         project.name.toLowerCase().contains(lowercaseQuery) ||
//         project.description.toLowerCase().contains(lowercaseQuery)
//       ).toList();
//     }
    
//     // Apply status filter
//     if (status != null) {
//       results = results.where((project) => project.status == status).toList();
//     }
    
//     // Apply owner filter
//     if (ownerId != null) {
//       results = results.where((project) => project.ownerId == ownerId).toList();
//     }
    
//     return results;
//   }

//   // Recent activity feed
//   Future<List<Map<String, dynamic>>> getRecentActivity({int limit = 20}) async {
//     await Future.delayed(const Duration(milliseconds: 400));
//     _initializeData();
    
//     final activities = <Map<String, dynamic>>[];
    
//     // Add task activities
//     for (final task in _tasks.take(10)) {
//       activities.add({
//         'id': 'task_${task.id}_${task.updatedAt.millisecondsSinceEpoch}',
//         'type': 'task_updated',
//         'title': 'Task Updated',
//         'message': '${task.title} was updated',
//         'timestamp': task.updatedAt,
//         'metadata': {
//           'taskId': task.id,
//           'taskTitle': task.title,
//           'status': task.status.displayName,
//         },
//       });
//     }
    
//     // Add project activities
//     for (final project in _projects.take(5)) {
//       activities.add({
//         'id': 'project_${project.id}_${project.updatedAt.millisecondsSinceEpoch}',
//         'type': 'project_updated',
//         'title': 'Project Updated',
//         'message': '${project.name} progress updated to ${(project.progress * 100).toInt()}%',
//         'timestamp': project.updatedAt,
//         'metadata': {
//           'projectId': project.id,
//           'projectName': project.name,
//           'progress': project.progress,
//         },
//       });
//     }
    
//     // Sort by timestamp and limit
//     activities.sort((a, b) => (b['timestamp'] as DateTime).compareTo(a['timestamp'] as DateTime));
    
//     return activities.take(limit).toList();
//   }

//   // Task analytics
//   Future<Map<String, dynamic>> getTaskAnalytics({String? projectId}) async {
//     await Future.delayed(const Duration(milliseconds: 400));
//     _initializeData();
    
//     var tasks = _tasks;
//     if (projectId != null) {
//       tasks = tasks.where((task) => task.projectId == projectId).toList();
//     }
    
//     final completionRate = tasks.isEmpty ? 0.0 : 
//       tasks.where((task) => task.status == TaskStatus.done).length / tasks.length;
    
//     final avgCompletionTime = _calculateAvgCompletionTime(tasks);
    
//     final priorityDistribution = {
//       'low': tasks.where((task) => task.priority == TaskPriority.low).length,
//       'medium': tasks.where((task) => task.priority == TaskPriority.medium).length,
//       'high': tasks.where((task) => task.priority == TaskPriority.high).length,
//       'urgent': tasks.where((task) => task.priority == TaskPriority.urgent).length,
//     };
    
//     return {
//       'totalTasks': tasks.length,
//       'completionRate': completionRate,
//       'avgCompletionDays': avgCompletionTime,
//       'priorityDistribution': priorityDistribution,
//       'overdueCount': tasks.where((task) =>
//         task.dueDate != null &&
//         task.dueDate!.isBefore(DateTime.now()) &&
//         task.status != TaskStatus.done
//       ).length,
//     };
//   }

//   double _calculateAvgCompletionTime(List<TaskModel> tasks) {
//     final completedTasks = tasks.where((task) => task.status == TaskStatus.done).toList();
//     if (completedTasks.isEmpty) return 0.0;
    
//     final totalDays = completedTasks.map((task) => 
//       task.updatedAt.difference(task.createdAt).inDays
//     ).reduce((a, b) => a + b);
    
//     return totalDays / completedTasks.length;
//   }

// }


//2



// lib/data/services/mock_api_service.dart - Part 1 (Complete with Time Tracking - FIXED)

import 'dart:math';
import '../models/user_model.dart';
import '../models/project_model.dart';
import '../models/task_model.dart';
import '../models/comment_model.dart';
import '../models/notification_model.dart';
import '../models/time_entry_model.dart';
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
  final List<TimeEntryModel> _timeEntries = [];
  
  String? _currentUserId;
  bool _isDataInitialized = false;

  // Initialize sample data
  void _initializeData() {
    if (_isDataInitialized) return;
    
    _users.clear();
    _projects.clear();
    _tasks.clear();
    _comments.clear();
    _notifications.clear();
    _timeEntries.clear();
    
    _createSampleUsers();
    _createSampleProjects();
    _createSampleTasks();
    _createSampleComments();
    _createSampleNotifications();
    _createSampleTimeEntries();
    
    _isDataInitialized = true;
  }

  void _createSampleUsers() {
    final now = DateTime.now();
    _users.addAll([
      UserModel(
        id: '1',
        name: 'Admin User',
        email: 'admin@example.com',
        role: UserRole.admin,
        createdAt: now.subtract(const Duration(days: 100)),
      ),
      UserModel(
        id: '2',
        name: 'Jane Manager',
        email: 'jane@example.com',
        role: UserRole.projectManager,
        createdAt: now.subtract(const Duration(days: 90)),
      ),
      UserModel(
        id: '3',
        name: 'Bob Developer',
        email: 'bob@example.com',
        role: UserRole.teamMember,
        createdAt: now.subtract(const Duration(days: 80)),
      ),
      UserModel(
        id: '4',
        name: 'Alice Designer',
        email: 'alice@example.com',
        role: UserRole.teamMember,
        createdAt: now.subtract(const Duration(days: 70)),
      ),
    ]);

    _currentUserId ??= '3'; // Default to Bob Developer
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
      TaskModel(
        id: '1',
        title: 'Setup Flutter Project',
        description: 'Initialize Flutter project with proper structure',
        status: TaskStatus.inProgress,
        priority: TaskPriority.high,
        projectId: '1',
        creatorId: '2',
        assigneeId: '3',
        dueDate: now.add(const Duration(days: 2)),
        createdAt: now.subtract(const Duration(days: 5)),
        updatedAt: now.subtract(const Duration(hours: 2)),
      ),
      TaskModel(
        id: '2',
        title: 'Design User Interface',
        description: 'Create mockups and wireframes for main screens',
        status: TaskStatus.inProgress,
        priority: TaskPriority.medium,
        projectId: '1',
        creatorId: '2',
        assigneeId: '4',
        dueDate: now.add(const Duration(days: 7)),
        createdAt: now.subtract(const Duration(days: 4)),
        updatedAt: now.subtract(const Duration(hours: 1)),
      ),
      TaskModel(
        id: '3',
        title: 'Implement Authentication',
        description: 'Set up user authentication with JWT',
        status: TaskStatus.toDo,
        priority: TaskPriority.high,
        projectId: '1',
        creatorId: '2',
        assigneeId: '3',
        dueDate: now.add(const Duration(days: 10)),
        createdAt: now.subtract(const Duration(days: 3)),
        updatedAt: now.subtract(const Duration(days: 1)),
      ),
      TaskModel(
        id: '4',
        title: 'Database Schema Design',
        description: 'Design and implement database schema',
        status: TaskStatus.done,
        priority: TaskPriority.medium,
        projectId: '1',
        creatorId: '2',
        assigneeId: '3',
        dueDate: now.subtract(const Duration(days: 2)),
        createdAt: now.subtract(const Duration(days: 10)),
        updatedAt: now.subtract(const Duration(days: 3)),
      ),
      TaskModel(
        id: '5',
        title: 'Content Migration',
        description: 'Migrate content from old website to new design',
        status: TaskStatus.toDo,
        priority: TaskPriority.low,
        projectId: '2',
        creatorId: '2',
        assigneeId: '4',
        dueDate: now.add(const Duration(days: 14)),
        createdAt: now.subtract(const Duration(days: 2)),
        updatedAt: now.subtract(const Duration(days: 1)),
      ),
    ]);
  }

  void _createSampleComments() {
    final now = DateTime.now();
    _comments.addAll([
      CommentModel(
        id: '1',
        taskId: '1',
        authorId: '3',
        content: 'Started working on the project structure. Will have initial setup done by tomorrow.',
        createdAt: now.subtract(const Duration(hours: 6)),
      ),
      CommentModel(
        id: '2',
        taskId: '3',
        authorId: '3',
        content: '@Jane Manager need help',
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


  // lib/data/services/mock_api_service.dart - Part 2 (FIXED - Time Entries and Auth Methods)

  void _createSampleTimeEntries() {
    final now = DateTime.now();
    _timeEntries.addAll([
      // Time entries for today
      TimeEntryModel(
        id: '1',
        userId: '3',
        taskId: '1',
        projectId: '1',
        description: 'Setting up initial project structure',
        startTime: now.subtract(const Duration(hours: 3, minutes: 30)),
        endTime: now.subtract(const Duration(hours: 1, minutes: 45)),
        durationSeconds: 6300, // 1h 45m
        type: TimeEntryType.tracked,
        isActive: false,
        createdAt: now.subtract(const Duration(hours: 3, minutes: 30)),
        updatedAt: now.subtract(const Duration(hours: 1, minutes: 45)),
      ),
      
      TimeEntryModel(
        id: '2',
        userId: '4',
        taskId: '2',
        projectId: '1',
        description: 'Working on wireframe designs',
        startTime: now.subtract(const Duration(minutes: 45)),
        endTime: null, // Active timer
        durationSeconds: 0,
        type: TimeEntryType.tracked,
        isActive: true,
        createdAt: now.subtract(const Duration(minutes: 45)),
        updatedAt: now.subtract(const Duration(minutes: 45)),
      ),
      
      // Yesterday's entries
      TimeEntryModel(
        id: '3',
        userId: '3',
        taskId: '3',
        projectId: '1',
        description: 'JWT authentication research',
        startTime: now.subtract(const Duration(days: 1, hours: 4)),
        endTime: now.subtract(const Duration(days: 1, hours: 2)),
        durationSeconds: 7200, // 2h
        type: TimeEntryType.manual,
        isActive: false,
        createdAt: now.subtract(const Duration(days: 1, hours: 4)),
        updatedAt: now.subtract(const Duration(days: 1, hours: 2)),
      ),
      
      TimeEntryModel(
        id: '4',
        userId: '4',
        taskId: '2',
        projectId: '1',
        description: 'UI mockup creation',
        startTime: now.subtract(const Duration(days: 1, hours: 6)),
        endTime: now.subtract(const Duration(days: 1, hours: 3, minutes: 30)),
        durationSeconds: 9000, // 2h 30m
        type: TimeEntryType.tracked,
        isActive: false,
        createdAt: now.subtract(const Duration(days: 1, hours: 6)),
        updatedAt: now.subtract(const Duration(days: 1, hours: 3, minutes: 30)),
      ),
      
      // This week's entries
      TimeEntryModel(
        id: '5',
        userId: '3',
        taskId: '1',
        projectId: '1',
        description: 'Flutter configuration',
        startTime: now.subtract(const Duration(days: 2, hours: 3)),
        endTime: now.subtract(const Duration(days: 2, hours: 1)),
        durationSeconds: 7200, // 2h
        type: TimeEntryType.tracked,
        isActive: false,
        createdAt: now.subtract(const Duration(days: 2, hours: 3)),
        updatedAt: now.subtract(const Duration(days: 2, hours: 1)),
      ),
      
      TimeEntryModel(
        id: '6',
        userId: '2',
        taskId: '5',
        projectId: '2',
        description: 'Planning content migration',
        startTime: now.subtract(const Duration(days: 3, hours: 2)),
        endTime: now.subtract(const Duration(days: 3, hours: 1)),
        durationSeconds: 3600, // 1h
        type: TimeEntryType.manual,
        isActive: false,
        createdAt: now.subtract(const Duration(days: 3, hours: 2)),
        updatedAt: now.subtract(const Duration(days: 3, hours: 1)),
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

  Future<UserModel> getCurrentUser() async {
    await Future.delayed(const Duration(milliseconds: 100));
    _initializeData();
    
    if (_currentUserId == null) {
      throw Exception('User not authenticated');
    }

    return _users.firstWhere(
      (user) => user.id == _currentUserId,
      orElse: () => throw Exception('User not found'),
    );
  }

  // User Methods
  Future<List<UserModel>> getUsers() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _initializeData();
    return List.from(_users);
  }

  Future<UserModel> getUserById(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _initializeData();
    
    return _users.firstWhere(
      (user) => user.id == id,
      orElse: () => throw Exception('User not found'),
    );
  }

  // Project Methods
  Future<List<ProjectModel>> getProjects({
    ProjectStatus? status,
    String? ownerId,
  }) async {
    await Future.delayed(const Duration(milliseconds: 400));
    _initializeData();
    
    final currentUser = await getCurrentUser();
    
    var projects = _projects.where((project) => 
      project.memberIds.contains(currentUser.id) || 
      project.ownerId == currentUser.id
    ).toList();

    if (status != null) {
      projects = projects.where((project) => project.status == status).toList();
    }

    if (ownerId != null) {
      projects = projects.where((project) => project.ownerId == ownerId).toList();
    }

    return projects..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  }

  Future<ProjectModel> getProjectById(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _initializeData();
    
    return _projects.firstWhere(
      (project) => project.id == id,
      orElse: () => throw Exception('Project not found'),
    );
  }

  Future<ProjectModel> createProject(ProjectModel project) async {
    await Future.delayed(const Duration(milliseconds: 600));
    _initializeData();
    
    final newProject = ProjectModel(
      id: (_projects.length + 1).toString(),
      name: project.name,
      description: project.description,
      status: project.status,
      ownerId: project.ownerId,
      memberIds: project.memberIds,
      startDate: project.startDate,
      dueDate: project.dueDate,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      progress: project.progress,
    );

    _projects.add(newProject);
    return newProject;
  }

  Future<ProjectModel> updateProject(String id, ProjectModel updates) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _initializeData();
    
    final index = _projects.indexWhere((project) => project.id == id);
    if (index == -1) throw Exception('Project not found');

    final updatedProject = _projects[index].copyWith(
      name: updates.name,
      description: updates.description,
      status: updates.status,
      dueDate: updates.dueDate,
    );

    _projects[index] = updatedProject;
    return updatedProject;
  }

  Future<void> deleteProject(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _initializeData();
    
    final index = _projects.indexWhere((project) => project.id == id);
    if (index == -1) throw Exception('Project not found');

    _projects.removeAt(index);
    
    // Also delete associated tasks
    _tasks.removeWhere((task) => task.projectId == id);
    
    // Delete associated time entries
    _timeEntries.removeWhere((entry) => entry.projectId == id);
  }



  // lib/data/services/mock_api_service.dart - Part 3 (FIXED - Task and Comment Methods)

  // Task Methods
  Future<List<TaskModel>> getTasks({
    String? projectId,
    TaskStatus? status,
    TaskPriority? priority,
    String? assigneeId,
  }) async {
    await Future.delayed(const Duration(milliseconds: 400));
    _initializeData();
    
    var tasks = List<TaskModel>.from(_tasks);

    if (projectId != null) {
      tasks = tasks.where((task) => task.projectId == projectId).toList();
    }

    if (status != null) {
      tasks = tasks.where((task) => task.status == status).toList();
    }

    if (priority != null) {
      tasks = tasks.where((task) => task.priority == priority).toList();
    }

    if (assigneeId != null) {
      tasks = tasks.where((task) => task.assigneeId == assigneeId).toList();
    }

    return tasks..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  }

  Future<TaskModel> getTaskById(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _initializeData();
    
    return _tasks.firstWhere(
      (task) => task.id == id,
      orElse: () => throw Exception('Task not found'),
    );
  }

  Future<TaskModel> createTask(TaskModel task) async {
    await Future.delayed(const Duration(milliseconds: 600));
    _initializeData();
    
    final newTask = TaskModel(
      id: (_tasks.length + 1).toString(),
      title: task.title,
      description: task.description,
      status: task.status,
      priority: task.priority,
      projectId: task.projectId,
      creatorId: task.creatorId,
      assigneeId: task.assigneeId,
      dueDate: task.dueDate,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    _tasks.add(newTask);
    
    // Create notification for assignee
    if (newTask.assigneeId != null) {
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

  Future<TaskModel> updateTask(String id, TaskModel updates) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _initializeData();
    
    final index = _tasks.indexWhere((task) => task.id == id);
    if (index == -1) throw Exception('Task not found');

    final originalTask = _tasks[index];
    final updatedTask = originalTask.copyWith(
      title: updates.title,
      description: updates.description,
      status: updates.status,
      priority: updates.priority,
      assigneeId: updates.assigneeId,
      dueDate: updates.dueDate,
    );

    _tasks[index] = updatedTask;
    
    // Create notification for new assignee
    if (updates.assigneeId != null && updates.assigneeId != originalTask.assigneeId) {
      _createNotification(
        updates.assigneeId!,
        NotificationType.taskAssigned,
        'Task Assigned',
        'You have been assigned to "${updatedTask.title}"',
        {'taskId': updatedTask.id},
      );
    }

    return updatedTask;
  }

  Future<void> deleteTask(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _initializeData();
    
    final index = _tasks.indexWhere((task) => task.id == id);
    if (index == -1) throw Exception('Task not found');

    _tasks.removeAt(index);
    
    // Also delete associated comments and time entries
    _comments.removeWhere((comment) => comment.taskId == id);
    _timeEntries.removeWhere((entry) => entry.taskId == id);
  }

  // Comment Methods
  Future<List<CommentModel>> getComments(String taskId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _initializeData();
    
    return _comments.where((comment) => comment.taskId == taskId).toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
  }

  Future<CommentModel> createComment(CommentModel comment) async {
    await Future.delayed(const Duration(milliseconds: 400));
    _initializeData();
    
    final currentUser = await getCurrentUser();
    
    final newComment = CommentModel(
      id: (_comments.length + 1).toString(),
      taskId: comment.taskId,
      authorId: currentUser.id,
      content: comment.content,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      mentions: comment.mentions ?? [],
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

  // TIME TRACKING METHODS

  // Get time entries with optional filters
  Future<List<TimeEntryModel>> getTimeEntries({
    DateTime? startDate,
    DateTime? endDate,
    String? projectId,
    String? taskId,
  }) async {
    await Future.delayed(const Duration(milliseconds: 400));
    _initializeData();
    
    final currentUser = await getCurrentUser();
    var entries = _timeEntries.where((entry) => entry.userId == currentUser.id).toList();
    
    if (startDate != null) {
      entries = entries.where((entry) => 
        entry.startTime.isAfter(startDate.subtract(const Duration(days: 1)))
      ).toList();
    }
    
    if (endDate != null) {
      final endOfDay = DateTime(endDate.year, endDate.month, endDate.day, 23, 59, 59);
      entries = entries.where((entry) => 
        entry.startTime.isBefore(endOfDay.add(const Duration(days: 1)))
      ).toList();
    }
    
    if (projectId != null) {
      entries = entries.where((entry) => entry.projectId == projectId).toList();
    }
    
    if (taskId != null) {
      entries = entries.where((entry) => entry.taskId == taskId).toList();
    }
    
    return entries..sort((a, b) => b.startTime.compareTo(a.startTime));
  }

  // Start a new time entry
  Future<TimeEntryModel> startTimeEntry({
    required String taskId,
    required String projectId,
    required String description,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _initializeData();
    
    final currentUser = await getCurrentUser();
    
    // Stop any existing active timer for this user
    for (int i = 0; i < _timeEntries.length; i++) {
      if (_timeEntries[i].userId == currentUser.id && _timeEntries[i].isActive) {
        final duration = DateTime.now().difference(_timeEntries[i].startTime).inSeconds;
        _timeEntries[i] = _timeEntries[i].copyWith(
          isActive: false,
          endTime: DateTime.now(),
          durationSeconds: duration,
        );
      }
    }
    
    final newEntry = TimeEntryModel.createTimer(
      id: (_timeEntries.length + 1).toString(),
      userId: currentUser.id,
      taskId: taskId,
      projectId: projectId,
      description: description,
    );
    
    _timeEntries.add(newEntry);
    return newEntry;
  }

  // Stop an active time entry
  Future<TimeEntryModel> stopTimeEntry(String entryId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _initializeData();
    
    // lib/data/services/mock_api_service.dart - Part 4 (FIXED - Final Part)

    final index = _timeEntries.indexWhere((entry) => entry.id == entryId);
    if (index == -1) throw Exception('Time entry not found');
    
    final entry = _timeEntries[index];
    if (!entry.isActive) throw Exception('Time entry is not active');
    
    final endTime = DateTime.now();
    final duration = endTime.difference(entry.startTime).inSeconds;
    
    final stoppedEntry = entry.copyWith(
      isActive: false,
      endTime: endTime,
      durationSeconds: duration,
    );
    
    _timeEntries[index] = stoppedEntry;
    return stoppedEntry;
  }

  // Create a manual time entry
  Future<TimeEntryModel> createManualTimeEntry({
    required String taskId,
    required String projectId,
    required String description,
    required DateTime startTime,
    required DateTime endTime,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _initializeData();
    
    final currentUser = await getCurrentUser();
    
    final newEntry = TimeEntryModel.createManual(
      id: (_timeEntries.length + 1).toString(),
      userId: currentUser.id,
      taskId: taskId,
      projectId: projectId,
      description: description,
      startTime: startTime,
      endTime: endTime,
    );
    
    _timeEntries.add(newEntry);
    return newEntry;
  }

  // Update an existing time entry
  Future<TimeEntryModel> updateTimeEntry(
    String entryId, {
    String? description,
    DateTime? startTime,
    DateTime? endTime,
  }) async {
    await Future.delayed(const Duration(milliseconds: 400));
    _initializeData();
    
    final index = _timeEntries.indexWhere((entry) => entry.id == entryId);
    if (index == -1) throw Exception('Time entry not found');
    
    final entry = _timeEntries[index];
    
    final updatedEntry = entry.copyWith(
      description: description,
      startTime: startTime,
      endTime: endTime,
      durationSeconds: endTime != null && (startTime ?? entry.startTime) != null
          ? endTime.difference(startTime ?? entry.startTime).inSeconds
          : entry.durationSeconds,
    );
    
    _timeEntries[index] = updatedEntry;
    return updatedEntry;
  }

  // Delete a time entry
  Future<void> deleteTimeEntry(String entryId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _initializeData();
    
    final index = _timeEntries.indexWhere((entry) => entry.id == entryId);
    if (index == -1) throw Exception('Time entry not found');
    
    _timeEntries.removeAt(index);
  }

  // Get active time entry for current user
  Future<TimeEntryModel?> getActiveTimeEntry() async {
    await Future.delayed(const Duration(milliseconds: 200));
    _initializeData();
    
    final currentUser = await getCurrentUser();
    
    try {
      return _timeEntries.firstWhere((entry) => 
        entry.userId == currentUser.id && entry.isActive);
    } catch (e) {
      return null;
    }
  }

  // Get time tracking statistics
  Future<Map<String, dynamic>> getTimeTrackingStats({
    DateTime? startDate,
    DateTime? endDate,
    String? projectId,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _initializeData();
    
    final currentUser = await getCurrentUser();
    var entries = _timeEntries.where((entry) => entry.userId == currentUser.id).toList();
    
    // Apply filters
    if (startDate != null) {
      entries = entries.where((entry) => 
        entry.startTime.isAfter(startDate.subtract(const Duration(days: 1)))
      ).toList();
    }
    
    if (endDate != null) {
      final endOfDay = DateTime(endDate.year, endDate.month, endDate.day, 23, 59, 59);
      entries = entries.where((entry) => 
        entry.startTime.isBefore(endOfDay.add(const Duration(days: 1)))
      ).toList();
    }
    
    if (projectId != null) {
      entries = entries.where((entry) => entry.projectId == projectId).toList();
    }
    
    // Calculate statistics
    final totalSeconds = entries.fold<int>(0, (sum, entry) => sum + entry.durationSeconds);
    final totalHours = totalSeconds / 3600.0;
    
    final projectHours = <String, double>{};
    final taskHours = <String, double>{};
    final dailyHours = <String, double>{};
    
    for (final entry in entries) {
      final project = _projects.firstWhere((p) => p.id == entry.projectId);
      final task = _tasks.firstWhere((t) => t.id == entry.taskId);
      final dayKey = '${entry.startTime.year}-${entry.startTime.month.toString().padLeft(2, '0')}-${entry.startTime.day.toString().padLeft(2, '0')}';
      
      projectHours[project.name] = (projectHours[project.name] ?? 0.0) + entry.durationHours;
      taskHours[task.title] = (taskHours[task.title] ?? 0.0) + entry.durationHours;
      dailyHours[dayKey] = (dailyHours[dayKey] ?? 0.0) + entry.durationHours;
    }
    
    return {
      'totalHours': totalHours,
      'totalEntries': entries.length,
      'averageHoursPerDay': dailyHours.isEmpty ? 0.0 : totalHours / dailyHours.length,
      'projectHours': projectHours,
      'taskHours': taskHours,
      'dailyHours': dailyHours,
      'workingDays': dailyHours.length,
    };
  }

  // Export time entries for reporting
  Future<List<Map<String, dynamic>>> getTimeEntriesForExport({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    await Future.delayed(const Duration(milliseconds: 400));
    _initializeData();
    
    final currentUser = await getCurrentUser();
    var entries = _timeEntries.where((entry) => entry.userId == currentUser.id).toList();
    
    if (startDate != null) {
      entries = entries.where((entry) => 
        entry.startTime.isAfter(startDate.subtract(const Duration(days: 1)))
      ).toList();
    }
    
    if (endDate != null) {
      final endOfDay = DateTime(endDate.year, endDate.month, endDate.day, 23, 59, 59);
      entries = entries.where((entry) => 
        entry.startTime.isBefore(endOfDay.add(const Duration(days: 1)))
      ).toList();
    }
    
    final result = <Map<String, dynamic>>[];
    
    for (final entry in entries) {
      final task = _tasks.firstWhere((t) => t.id == entry.taskId);
      final project = _projects.firstWhere((p) => p.id == entry.projectId);
      
      result.add({
        'Date': entry.startTime.toIso8601String().substring(0, 10),
        'Start Time': entry.startTime.toIso8601String().substring(11, 16),
        'End Time': entry.endTime?.toIso8601String().substring(11, 16) ?? '',
        'Duration': entry.formattedDuration,
        'Project': project.name,
        'Task': task.title,
        'Description': entry.description,
        'Type': entry.type.displayName,
        'User': currentUser.name,
        'Hours': entry.durationHours.toStringAsFixed(2),
      });
    }
    
    return result..sort((a, b) => 
      DateTime.parse('${a['Date']}T${a['Start Time']}:00').compareTo(
        DateTime.parse('${b['Date']}T${b['Start Time']}:00')
      )
    );
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
      'done': myTasks.where((task) => task.status == TaskStatus.done).length,
    };
    
    final projectStats = {
      'total': userProjects.length,
      'active': userProjects.where((project) => project.status == ProjectStatus.active).length,
      'planning': userProjects.where((project) => project.status == ProjectStatus.planning).length,
      'completed': userProjects.where((project) => project.status == ProjectStatus.completed).length,
    };
    
    final overdueTasks = myTasks.where((task) =>
      task.dueDate != null &&
      task.dueDate!.isBefore(DateTime.now()) &&
      task.status != TaskStatus.done
    ).length;

    // Time tracking stats for dashboard
    final timeStats = await getTimeTrackingStats(
      startDate: DateTime.now().subtract(const Duration(days: 7)),
      endDate: DateTime.now(),
    );
    
    return {
      'taskStats': taskStats,
      'projectStats': projectStats,
      'overdueTasks': overdueTasks,
      'completedThisWeek': myTasks.where((task) =>
        task.status == TaskStatus.done &&
        task.updatedAt.isAfter(DateTime.now().subtract(const Duration(days: 7)))
      ).length,
      'avgProjectProgress': userProjects.isEmpty ? 
        0.0 : userProjects.map((p) => p.progress).reduce((a, b) => a + b) / userProjects.length,
      'timeStats': timeStats,
    };
  }

  Future<Map<String, dynamic>> getProjectAnalytics({String? projectId}) async {
    await Future.delayed(const Duration(milliseconds: 400));
    _initializeData();
    
    var tasks = _tasks;
    if (projectId != null) {
      tasks = tasks.where((task) => task.projectId == projectId).toList();
    }
    
    final completionRate = tasks.isEmpty ? 0.0 : 
      tasks.where((task) => task.status == TaskStatus.done).length / tasks.length;
    
    final avgCompletionTime = _calculateAvgCompletionTime(tasks);
    
    final priorityDistribution = {
      'low': tasks.where((task) => task.priority == TaskPriority.low).length,
      'medium': tasks.where((task) => task.priority == TaskPriority.medium).length,
      'high': tasks.where((task) => task.priority == TaskPriority.high).length,
      'urgent': tasks.where((task) => task.priority == TaskPriority.urgent).length,
    };
    
    // Time tracking analytics for the project
    final timeEntries = projectId != null 
        ? _timeEntries.where((entry) => entry.projectId == projectId).toList()
        : _timeEntries;
    
    final totalTrackedHours = timeEntries.fold<double>(
      0.0, (sum, entry) => sum + entry.durationHours);
    
    final estimatedHours = 0.0; // Since we removed estimatedTimeHours from TaskModel
    
    return {
      'totalTasks': tasks.length,
      'completionRate': completionRate,
      'avgCompletionDays': avgCompletionTime,
      'priorityDistribution': priorityDistribution,
      'overdueCount': tasks.where((task) =>
        task.dueDate != null &&
        task.dueDate!.isBefore(DateTime.now()) &&
        task.status != TaskStatus.done
      ).length,
      'totalTrackedHours': totalTrackedHours,
      'estimatedHours': estimatedHours,
      'timeVariance': totalTrackedHours - estimatedHours,
    };
  }


Future<void> deleteNotification(String id) async {
  await Future.delayed(const Duration(milliseconds: 200));
  _initializeData();
  
  _notifications.removeWhere((notification) => notification.id == id);
}
  // Helper Methods
  double _calculateAvgCompletionTime(List<TaskModel> tasks) {
    final completedTasks = tasks.where((task) => task.status == TaskStatus.done).toList();
    if (completedTasks.isEmpty) return 0.0;
    
    final totalDays = completedTasks.map((task) => 
      task.updatedAt.difference(task.createdAt).inDays
    ).reduce((a, b) => a + b);
    
    return totalDays / completedTasks.length;
  }

  bool _isTaskCompletedOnDay(TaskModel task, DateTime day) {
    if (task.status != TaskStatus.done) return false;
    
    final taskCompletionDate = DateTime(
      task.updatedAt.year,
      task.updatedAt.month,
      task.updatedAt.day,
    );
    
    final targetDate = DateTime(day.year, day.month, day.day);
    
    return taskCompletionDate.isAtSameMomentAs(targetDate);
  }

  void _createNotification(
    String userId,
    NotificationType type,
    String title,
    String message,
    Map<String, dynamic> metadata,
  ) {
    final notification = NotificationModel(
      id: (_notifications.length + 1).toString(),
      userId: userId,
      type: type,
      title: title,
      message: message,
      metadata: metadata,
      createdAt: DateTime.now(),
    );
    
    _notifications.add(notification);
  }

  // Reset data for testing
  void resetData() {
    _isDataInitialized = false;
    _currentUserId = null;
    _users.clear();
    _projects.clear();
    _tasks.clear();
    _comments.clear();
    _notifications.clear();
    _timeEntries.clear();
  }
}