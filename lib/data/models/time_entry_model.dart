// lib/data/models/time_entry_model.dart

enum TimeEntryType {
  tracked,
  manual;

  String get displayName {
    switch (this) {
      case TimeEntryType.tracked:
        return 'Tracked';
      case TimeEntryType.manual:
        return 'Manual';
    }
  }
}

class TimeEntryModel {
  final String id;
  final String userId;
  final String taskId;
  final String projectId;
  final String description;
  final DateTime startTime;
  final DateTime? endTime;
  final int durationSeconds; // Total duration in seconds
  final TimeEntryType type;
  final bool isActive; // Whether timer is currently running
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, dynamic>? metadata;

  TimeEntryModel({
    required this.id,
    required this.userId,
    required this.taskId,
    required this.projectId,
    required this.description,
    required this.startTime,
    this.endTime,
    required this.durationSeconds,
    this.type = TimeEntryType.tracked,
    this.isActive = false,
    required this.createdAt,
    required this.updatedAt,
    this.metadata,
  });

  // Calculate duration from start and end times
  int get calculatedDurationSeconds {
    if (endTime != null) {
      return endTime!.difference(startTime).inSeconds;
    } else if (isActive) {
      return DateTime.now().difference(startTime).inSeconds;
    }
    return durationSeconds;
  }

  // Get formatted duration string
  String get formattedDuration {
    final duration = Duration(seconds: calculatedDurationSeconds);
    final hours = duration.inHours;
    final minutes = (duration.inMinutes % 60);
    final seconds = (duration.inSeconds % 60);
    
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    } else {
      return '${seconds}s';
    }
  }

  // Get decimal hours for calculations
  double get durationHours {
    return calculatedDurationSeconds / 3600.0;
  }

  // Check if entry overlaps with another entry
  bool overlapsWithEntry(TimeEntryModel other) {
    if (other.id == id) return false;
    
    final thisStart = startTime;
    final thisEnd = endTime ?? DateTime.now();
    final otherStart = other.startTime;
    final otherEnd = other.endTime ?? DateTime.now();
    
    return thisStart.isBefore(otherEnd) && thisEnd.isAfter(otherStart);
  }

  // Check if entry is from today
  bool get isToday {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final entryDate = DateTime(startTime.year, startTime.month, startTime.day);
    return entryDate.isAtSameMomentAs(today);
  }

  // Check if entry is from this week
  bool get isThisWeek {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weekStartDate = DateTime(weekStart.year, weekStart.month, weekStart.day);
    final entryDate = DateTime(startTime.year, startTime.month, startTime.day);
    return entryDate.isAfter(weekStartDate.subtract(const Duration(days: 1)));
  }

  factory TimeEntryModel.fromJson(Map<String, dynamic> json) {
    return TimeEntryModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      taskId: json['taskId'] as String,
      projectId: json['projectId'] as String,
      description: json['description'] as String,
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: json['endTime'] != null ? DateTime.parse(json['endTime'] as String) : null,
      durationSeconds: (json['durationSeconds'] as num).toInt(),
      type: TimeEntryType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => TimeEntryType.tracked,
      ),
      isActive: json['isActive'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'taskId': taskId,
      'projectId': projectId,
      'description': description,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'durationSeconds': durationSeconds,
      'type': type.name,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'metadata': metadata,
    };
  }

  TimeEntryModel copyWith({
    String? description,
    DateTime? startTime,
    DateTime? endTime,
    int? durationSeconds,
    TimeEntryType? type,
    bool? isActive,
    Map<String, dynamic>? metadata,
  }) {
    return TimeEntryModel(
      id: id,
      userId: userId,
      taskId: taskId,
      projectId: projectId,
      description: description ?? this.description,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      type: type ?? this.type,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      metadata: metadata ?? this.metadata,
    );
  }

  // Create a new time entry for manual entry
  static TimeEntryModel createManual({
    required String id,
    required String userId,
    required String taskId,
    required String projectId,
    required String description,
    required DateTime startTime,
    required DateTime endTime,
  }) {
    final duration = endTime.difference(startTime).inSeconds;
    return TimeEntryModel(
      id: id,
      userId: userId,
      taskId: taskId,
      projectId: projectId,
      description: description,
      startTime: startTime,
      endTime: endTime,
      durationSeconds: duration,
      type: TimeEntryType.manual,
      isActive: false,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  // Create a new time entry for timer
  static TimeEntryModel createTimer({
    required String id,
    required String userId,
    required String taskId,
    required String projectId,
    required String description,
  }) {
    return TimeEntryModel(
      id: id,
      userId: userId,
      taskId: taskId,
      projectId: projectId,
      description: description,
      startTime: DateTime.now(),
      endTime: null,
      durationSeconds: 0,
      type: TimeEntryType.tracked,
      isActive: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }
}