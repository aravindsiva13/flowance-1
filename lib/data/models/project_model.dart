
// lib/data/models/project_model.dart

import 'package:flowence/core/enums/task_status.dart';

import '../../core/enums/project_status.dart';

class ProjectModel {
  final String id;
  final String name;
  final String description;
  final ProjectStatus status;
  final String ownerId;
  final List<String> memberIds;
  final DateTime startDate;
  final DateTime? endDate;
  final DateTime? dueDate;
  final DateTime createdAt;
  final DateTime updatedAt;
  final double progress;

  ProjectModel({
    required this.id,
    required this.name,
    required this.description,
    required this.status,
    required this.ownerId,
    required this.memberIds,
    required this.startDate,
    this.endDate,
    this.dueDate,
    required this.createdAt,
    required this.updatedAt,
    this.progress = 0.0, String? color,
  });

  factory ProjectModel.fromJson(Map<String, dynamic> json) {
    return ProjectModel(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      status: ProjectStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => ProjectStatus.planning,
      ),
      ownerId: json['ownerId'],
      memberIds: List<String>.from(json['memberIds']),
      startDate: DateTime.parse(json['startDate']),
      endDate: json['endDate'] != null ? DateTime.parse(json['endDate']) : null,
      dueDate: json['dueDate'] != null ? DateTime.parse(json['dueDate']) : null,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      progress: (json['progress'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'status': status.name,
      'ownerId': ownerId,
      'memberIds': memberIds,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'dueDate': dueDate?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'progress': progress,
    };
  }

  ProjectModel copyWith({
    String? name,
    String? description,
    ProjectStatus? status,
    List<String>? memberIds,
    DateTime? endDate,
    DateTime? dueDate,
    double? progress,
  }) {
    return ProjectModel(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      status: status ?? this.status,
      ownerId: ownerId,
      memberIds: memberIds ?? this.memberIds,
      startDate: startDate,
      endDate: endDate ?? this.endDate,
      dueDate: dueDate ?? this.dueDate,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      progress: progress ?? this.progress,
    );
  }
}
