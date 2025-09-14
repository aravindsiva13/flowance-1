// // lib/data/models/task_model.dart

// import '../../core/enums/task_status.dart';
// import '../../core/enums/task_priority.dart';

// class TaskModel {
//   final String id;
//   final String title;
//   final String description;
//   final TaskStatus status;
//   final TaskPriority priority;
//   final String projectId;
//   final String? assigneeId;
//   final String creatorId;
//   final DateTime? dueDate;
//   final DateTime createdAt;
//   final DateTime updatedAt;
//   final List<String> tags;
//   final double progress;

//   TaskModel({
//     required this.id,
//     required this.title,
//     required this.description,
//     required this.status,
//     required this.priority,
//     required this.projectId,
//     this.assigneeId,
//     required this.creatorId,
//     this.dueDate,
//     required this.createdAt,
//     required this.updatedAt,
//     this.tags = const [],
//     this.progress = 0.0,
//   });

//   factory TaskModel.fromJson(Map<String, dynamic> json) {
//     return TaskModel(
//       id: json['id'],
//       title: json['title'],
//       description: json['description'],
//       status: TaskStatus.values.firstWhere(
//         (e) => e.name == json['status'],
//         orElse: () => TaskStatus.toDo,
//       ),
//       priority: TaskPriority.values.firstWhere(
//         (e) => e.name == json['priority'],
//         orElse: () => TaskPriority.medium,
//       ),
//       projectId: json['projectId'],
//       assigneeId: json['assigneeId'],
//       creatorId: json['creatorId'],
//       dueDate: json['dueDate'] != null ? DateTime.parse(json['dueDate']) : null,
//       createdAt: DateTime.parse(json['createdAt']),
//       updatedAt: DateTime.parse(json['updatedAt']),
//       tags: List<String>.from(json['tags'] ?? []),
//       progress: (json['progress'] ?? 0.0).toDouble(),
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'id': id,
//       'title': title,
//       'description': description,
//       'status': status.name,
//       'priority': priority.name,
//       'projectId': projectId,
//       'assigneeId': assigneeId,
//       'creatorId': creatorId,
//       'dueDate': dueDate?.toIso8601String(),
//       'createdAt': createdAt.toIso8601String(),
//       'updatedAt': updatedAt.toIso8601String(),
//       'tags': tags,
//       'progress': progress,
//     };
//   }

//   TaskModel copyWith({
//     String? title,
//     String? description,
//     TaskStatus? status,
//     TaskPriority? priority,
//     String? assigneeId,
//     DateTime? dueDate,
//     List<String>? tags,
//     double? progress,
//   }) {
//     return TaskModel(
//       id: id,
//       title: title ?? this.title,
//       description: description ?? this.description,
//       status: status ?? this.status,
//       priority: priority ?? this.priority,
//       projectId: projectId,
//       assigneeId: assigneeId ?? this.assigneeId,
//       creatorId: creatorId,
//       dueDate: dueDate ?? this.dueDate,
//       createdAt: createdAt,
//       updatedAt: DateTime.now(),
//       tags: tags ?? this.tags,
//       progress: progress ?? this.progress,
//     );
//   }
// }


//2


// lib/data/models/task_model.dart - Updated with time estimates

import '../../core/enums/task_status.dart';
import '../../core/enums/task_priority.dart';

class TaskModel {
  final String id;
  final String title;
  final String description;
  final TaskStatus status;
  final TaskPriority priority;
  final String projectId;
  final String? assigneeId;
  final String creatorId;
  final DateTime? dueDate;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<String> tags;
  final double progress;
  
  // Time tracking fields
  final int? estimatedHours; // Estimated time in hours
  final int? estimatedMinutes; // Additional minutes for estimates
  final bool isTimeTrackingEnabled; // Whether time tracking is enabled for this task

  TaskModel({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.priority,
    required this.projectId,
    this.assigneeId,
    required this.creatorId,
    this.dueDate,
    required this.createdAt,
    required this.updatedAt,
    this.tags = const [],
    this.progress = 0.0,
    this.estimatedHours,
    this.estimatedMinutes,
    this.isTimeTrackingEnabled = true,
  });

  // Get total estimated time in seconds
  int? get totalEstimatedSeconds {
    if (estimatedHours == null && estimatedMinutes == null) return null;
    final hours = estimatedHours ?? 0;
    final minutes = estimatedMinutes ?? 0;
    return (hours * 3600) + (minutes * 60);
  }

  // Get formatted estimated time
  String get formattedEstimatedTime {
    if (totalEstimatedSeconds == null) return 'No estimate';
    final duration = Duration(seconds: totalEstimatedSeconds!);
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else {
      return '${minutes}m';
    }
  }

  // Get estimated time in decimal hours
  double? get estimatedTimeHours {
    if (totalEstimatedSeconds == null) return null;
    return totalEstimatedSeconds! / 3600.0;
  }

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      status: TaskStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => TaskStatus.toDo,
      ),
      priority: TaskPriority.values.firstWhere(
        (e) => e.name == json['priority'],
        orElse: () => TaskPriority.medium,
      ),
      projectId: json['projectId'],
      assigneeId: json['assigneeId'],
      creatorId: json['creatorId'],
      dueDate: json['dueDate'] != null ? DateTime.parse(json['dueDate']) : null,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      tags: List<String>.from(json['tags'] ?? []),
      progress: (json['progress'] ?? 0.0).toDouble(),
      estimatedHours: json['estimatedHours'] as int?,
      estimatedMinutes: json['estimatedMinutes'] as int?,
      isTimeTrackingEnabled: json['isTimeTrackingEnabled'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'status': status.name,
      'priority': priority.name,
      'projectId': projectId,
      'assigneeId': assigneeId,
      'creatorId': creatorId,
      'dueDate': dueDate?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'tags': tags,
      'progress': progress,
      'estimatedHours': estimatedHours,
      'estimatedMinutes': estimatedMinutes,
      'isTimeTrackingEnabled': isTimeTrackingEnabled,
    };
  }

  TaskModel copyWith({
    String? title,
    String? description,
    TaskStatus? status,
    TaskPriority? priority,
    String? assigneeId,
    DateTime? dueDate,
    List<String>? tags,
    double? progress,
    int? estimatedHours,
    int? estimatedMinutes,
    bool? isTimeTrackingEnabled,
  }) {
    return TaskModel(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      projectId: projectId,
      assigneeId: assigneeId ?? this.assigneeId,
      creatorId: creatorId,
      dueDate: dueDate ?? this.dueDate,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      tags: tags ?? this.tags,
      progress: progress ?? this.progress,
      estimatedHours: estimatedHours ?? this.estimatedHours,
      estimatedMinutes: estimatedMinutes ?? this.estimatedMinutes,
      isTimeTrackingEnabled: isTimeTrackingEnabled ?? this.isTimeTrackingEnabled,
    );
  }
}