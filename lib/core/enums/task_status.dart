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
