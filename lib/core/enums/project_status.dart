
// =================================================================

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

  String get shortName {
    switch (this) {
      case ProjectStatus.planning:
        return 'PLAN';
      case ProjectStatus.active:
        return 'ACTIVE';
      case ProjectStatus.onHold:
        return 'HOLD';
      case ProjectStatus.completed:
        return 'DONE';
      case ProjectStatus.cancelled:
        return 'CANCELLED';
    }
  }
}
