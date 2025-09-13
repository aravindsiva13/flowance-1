// lib/core/enums/user_role.dart

enum UserRole {
  admin,
  projectManager,
  teamMember;

  String get displayName {
    switch (this) {
      case UserRole.admin:
        return 'Admin';
      case UserRole.projectManager:
        return 'Project Manager';
      case UserRole.teamMember:
        return 'Team Member';
    }
  }

  bool get canCreateProjects {
    switch (this) {
      case UserRole.admin:
      case UserRole.projectManager:
        return true;
      case UserRole.teamMember:
        return false;
    }
  }

  bool get canDeleteProjects {
    return this == UserRole.admin;
  }

  bool get canManageUsers {
    return this == UserRole.admin;
  }

  bool get canAssignTasks {
    switch (this) {
      case UserRole.admin:
      case UserRole.projectManager:
        return true;
      case UserRole.teamMember:
        return false;
    }
  }

  bool get canViewAllProjects {
    switch (this) {
      case UserRole.admin:
        return true;
      case UserRole.projectManager:
      case UserRole.teamMember:
        return false;
    }
  }

  bool get canExportData {
    switch (this) {
      case UserRole.admin:
      case UserRole.projectManager:
        return true;
      case UserRole.teamMember:
        return false;
    }
  }
}