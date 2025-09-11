// lib/data/models/task_model.dart

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
  });

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
    );
  }
}