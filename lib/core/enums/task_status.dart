// lib/core/enums/task_status.dart

enum TaskStatus {
  toDo,
  inProgress,
  inReview,
  done;

  String get displayName {
    switch (this) {
      case TaskStatus.toDo:
        return 'To Do';
      case TaskStatus.inProgress:
        return 'In Progress';
      case TaskStatus.inReview:
        return 'In Review';
      case TaskStatus.done:
        return 'Done';
    }
  }

  String get shortName {
    switch (this) {
      case TaskStatus.toDo:
        return 'TODO';
      case TaskStatus.inProgress:
        return 'PROGRESS';
      case TaskStatus.inReview:
        return 'REVIEW';
      case TaskStatus.done:
        return 'DONE';
    }
  }
}

// lib/core/enums/task_priority.dart

enum TaskPriority {
  low,
  medium,
  high,
  urgent;

  String get displayName {
    switch (this) {
      case TaskPriority.low:
        return 'Low';
      case TaskPriority.medium:
        return 'Medium';
      case TaskPriority.high:
        return 'High';
      case TaskPriority.urgent:
        return 'Urgent';
    }
  }

  int get value {
    switch (this) {
      case TaskPriority.low:
        return 1;
      case TaskPriority.medium:
        return 2;
      case TaskPriority.high:
        return 3;
      case TaskPriority.urgent:
        return 4;
    }
  }
}

// lib/core/enums/project_status.dart

enum ProjectStatus {
  planning,
  active,
  onHold,
  completed,
  cancelled;

  String get displayName {
    switch (this) {
      case ProjectStatus.planning:
        return 'Planning';
      case ProjectStatus.active:
        return 'Active';
      case ProjectStatus.onHold:
        return 'On Hold';
      case ProjectStatus.completed:
        return 'Completed';
      case ProjectStatus.cancelled:
        return 'Cancelled';
    }
  }

  bool get isActive {
    return this == ProjectStatus.active || this == ProjectStatus.planning;
  }
}