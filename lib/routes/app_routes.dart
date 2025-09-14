// // lib/routes/app_routes.dart - Updated with new routes

// class AppRoutes {
//   // Private constructor to prevent instantiation
//   AppRoutes._();

//   // Main navigation routes
//   static const String splash = '/';
//   static const String login = '/login';
//   static const String register = '/register';
//   static const String main = '/main';
//   static const String dashboard = '/dashboard';

//   // Project related routes
//   static const String projects = '/projects';
//   static const String createProject = '/create-project';
//   static const String projectDetail = '/project-detail';
//   static const String editProject = '/edit-project';

//   // Task related routes
//   static const String tasks = '/tasks';
//   static const String createTask = '/create-task';
//   static const String taskDetail = '/task-detail';
//   static const String editTask = '/edit-task'; // NEW

//   // Board and organization routes
//   static const String kanbanBoard = '/kanban-board';
//   static const String calendar = '/calendar';

//   // User and profile routes
//   static const String profile = '/profile';
//   static const String settings = '/settings';
//   static const String editProfile = '/edit-profile';

//   // Team and collaboration routes
//   static const String team = '/team';
//   static const String addTeamMember = '/add-team-member';
//   static const String teamMemberDetail = '/team-member-detail';

//   // Notification and activity routes
//   static const String notifications = '/notifications';
//   static const String activity = '/activity';

//   // Search and filter routes
//   static const String search = '/search'; // NEW
//   static const String filters = '/filters';

//   // Help and support routes
//   static const String help = '/help';
//   static const String about = '/about';
//   static const String feedback = '/feedback';

//   // Error and utility routes
//   static const String error = '/error';
//   static const String noInternet = '/no-internet';

//   // Get all routes as a list (useful for debugging or navigation logic)
//   static List<String> get allRoutes => [
//         splash,
//         login,
//         register,
//         main,
//         dashboard,
//         projects,
//         createProject,
//         projectDetail,
//         editProject,
//         tasks,
//         createTask,
//         taskDetail,
//         editTask, // NEW
//         kanbanBoard,
//         calendar,
//         profile,
//         settings,
//         editProfile,
//         team,
//         addTeamMember,
//         teamMemberDetail,
//         notifications,
//         activity,
//         search, // NEW
//         filters,
//         help,
//         about,
//         feedback,
//         error,
//         noInternet,
//       ];

//   // Route validation - check if a route exists
//   static bool isValidRoute(String route) {
//     return allRoutes.contains(route);
//   }

//   // Get route display name (useful for breadcrumbs or navigation titles)
//   static String getRouteDisplayName(String route) {
//     switch (route) {
//       case splash:
//         return 'Splash';
//       case login:
//         return 'Login';
//       case register:
//         return 'Register';
//       case main:
//         return 'Home';
//       case dashboard:
//         return 'Dashboard';
//       case projects:
//         return 'Projects';
//       case createProject:
//         return 'Create Project';
//       case projectDetail:
//         return 'Project Details';
//       case editProject:
//         return 'Edit Project';
//       case tasks:
//         return 'Tasks';
//       case createTask:
//         return 'Create Task';
//       case taskDetail:
//         return 'Task Details';
//       case editTask:
//         return 'Edit Task'; // NEW
//       case kanbanBoard:
//         return 'Kanban Board';
//       case calendar:
//         return 'Calendar';
//       case profile:
//         return 'Profile';
//       case settings:
//         return 'Settings';
//       case editProfile:
//         return 'Edit Profile';
//       case team:
//         return 'Team';
//       case addTeamMember:
//         return 'Add Team Member';
//       case teamMemberDetail:
//         return 'Team Member';
//       case notifications:
//         return 'Notifications';
//       case activity:
//         return 'Activity';
//       case search:
//         return 'Search'; // NEW
//       case filters:
//         return 'Filters';
//       case help:
//         return 'Help';
//       case about:
//         return 'About';
//       case feedback:
//         return 'Feedback';
//       case error:
//         return 'Error';
//       case noInternet:
//         return 'No Internet';
//       default:
//         return 'Unknown';
//     }
//   }

//   // Check if route requires authentication
//   static bool requiresAuth(String route) {
//     const unauthenticatedRoutes = [
//       splash,
//       login,
//       register,
//       error,
//       noInternet,
//     ];
//     return !unauthenticatedRoutes.contains(route);
//   }

//   // Get route category (useful for analytics or navigation grouping)
//   static String getRouteCategory(String route) {
//     if ([splash, login, register].contains(route)) {
//       return 'auth';
//     } else if ([dashboard, main].contains(route)) {
//       return 'main';
//     } else if ([projects, createProject, projectDetail, editProject].contains(route)) {
//       return 'projects';
//     } else if ([tasks, createTask, taskDetail, editTask, kanbanBoard].contains(route)) {
//       return 'tasks';
//     } else if ([profile, settings, editProfile].contains(route)) {
//       return 'profile';
//     } else if ([team, addTeamMember, teamMemberDetail].contains(route)) {
//       return 'team';
//     } else if ([notifications, activity].contains(route)) {
//       return 'notifications';
//     } else if ([search, filters].contains(route)) {
//       return 'search';
//     } else if ([help, about, feedback].contains(route)) {
//       return 'support';
//     } else if ([error, noInternet, calendar].contains(route)) {
//       return 'utility';
//     }
//     return 'unknown';
//   }

//   // Generate route with parameters (helper method)
//   static String generateRouteWithParams(String baseRoute, Map<String, String>? params) {
//     if (params == null || params.isEmpty) {
//       return baseRoute;
//     }
    
//     final queryString = params.entries
//         .map((entry) => '${entry.key}=${Uri.encodeComponent(entry.value)}')
//         .join('&');
    
//     return '$baseRoute?$queryString';
//   }

//   // Common route parameter keys
//   static const String paramProjectId = 'projectId';
//   static const String paramTaskId = 'taskId';
//   static const String paramUserId = 'userId';
//   static const String paramTeamId = 'teamId';
//   static const String paramFilter = 'filter';
//   static const String paramSearch = 'search';
//   static const String paramDate = 'date';
//   static const String paramStatus = 'status';
//   static const String paramPriority = 'priority';

//   // Helper methods for common parametrized routes
//   static String projectDetailRoute(String projectId) =>
//       generateRouteWithParams(projectDetail, {paramProjectId: projectId});

//   static String taskDetailRoute(String taskId) =>
//       generateRouteWithParams(taskDetail, {paramTaskId: taskId});

//   static String editProjectRoute(String projectId) =>
//       generateRouteWithParams(editProject, {paramProjectId: projectId});

//   static String editTaskRoute(String taskId) =>
//       generateRouteWithParams(editTask, {paramTaskId: taskId});

//   static String teamMemberDetailRoute(String userId) =>
//       generateRouteWithParams(teamMemberDetail, {paramUserId: userId});

//   static String kanbanBoardRoute({String? projectId, String? filter}) {
//     Map<String, String> params = {};
//     if (projectId != null) params[paramProjectId] = projectId;
//     if (filter != null) params[paramFilter] = filter;
//     return generateRouteWithParams(kanbanBoard, params.isEmpty ? null : params);
//   }

//   static String searchRoute({String? query, String? filter}) {
//     Map<String, String> params = {};
//     if (query != null) params[paramSearch] = query;
//     if (filter != null) params[paramFilter] = filter;
//     return generateRouteWithParams(search, params.isEmpty ? null : params);
//   }

//   static String tasksRoute({String? projectId, String? status, String? priority}) {
//     Map<String, String> params = {};
//     if (projectId != null) params[paramProjectId] = projectId;
//     if (status != null) params[paramStatus] = status;
//     if (priority != null) params[paramPriority] = priority;
//     return generateRouteWithParams(tasks, params.isEmpty ? null : params);
//   }
// }

//2


// lib/routes/app_routes.dart - Updated with Time Tracking Routes

class AppRoutes {
  // Private constructor to prevent instantiation
  AppRoutes._();

  // Main navigation routes
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String main = '/main';
  static const String dashboard = '/dashboard';

  // Project related routes
  static const String projects = '/projects';
  static const String createProject = '/create-project';
  static const String projectDetail = '/project-detail';
  static const String editProject = '/edit-project';

  // Task related routes
  static const String tasks = '/tasks';
  static const String createTask = '/create-task';
  static const String taskDetail = '/task-detail';
  static const String editTask = '/edit-task';

  // Board and organization routes
  static const String kanbanBoard = '/kanban-board';
  static const String calendar = '/calendar';

  // Time tracking routes
  static const String timesheet = '/timesheet';
  static const String timeReports = '/time-reports';
  static const String timeEntry = '/time-entry';

  // User and profile routes
  static const String profile = '/profile';
  static const String settings = '/settings';
  static const String editProfile = '/edit-profile';

  // Team and collaboration routes
  static const String team = '/team';
  static const String addTeamMember = '/add-team-member';
  static const String teamMemberDetail = '/team-member-detail';

  // Notification and activity routes
  static const String notifications = '/notifications';
  static const String activity = '/activity';

  // Search and filter routes
  static const String search = '/search';
  static const String filters = '/filters';

  // Help and support routes
  static const String help = '/help';
  static const String about = '/about';
  static const String feedback = '/feedback';

  // Error and utility routes
  static const String error = '/error';
  static const String noInternet = '/no-internet';

  // Get all routes as a list (useful for debugging or navigation logic)
  static List<String> get allRoutes => [
        splash,
        login,
        register,
        main,
        dashboard,
        projects,
        createProject,
        projectDetail,
        editProject,
        tasks,
        createTask,
        taskDetail,
        editTask,
        kanbanBoard,
        calendar,
        timesheet,
        timeReports,
        timeEntry,
        profile,
        settings,
        editProfile,
        team,
        addTeamMember,
        teamMemberDetail,
        notifications,
        activity,
        search,
        filters,
        help,
        about,
        feedback,
        error,
        noInternet,
      ];

  // Route validation - check if a route exists
  static bool isValidRoute(String route) {
    return allRoutes.contains(route);
  }

  // Get route display name (useful for breadcrumbs or navigation titles)
  static String getRouteDisplayName(String route) {
    switch (route) {
      case splash:
        return 'Splash';
      case login:
        return 'Login';
      case register:
        return 'Register';
      case main:
        return 'Home';
      case dashboard:
        return 'Dashboard';
      case projects:
        return 'Projects';
      case createProject:
        return 'Create Project';
      case projectDetail:
        return 'Project Details';
      case editProject:
        return 'Edit Project';
      case tasks:
        return 'Tasks';
      case createTask:
        return 'Create Task';
      case taskDetail:
        return 'Task Details';
      case editTask:
        return 'Edit Task';
      case kanbanBoard:
        return 'Kanban Board';
      case calendar:
        return 'Calendar';
      case timesheet:
        return 'Timesheet';
      case timeReports:
        return 'Time Reports';
      case timeEntry:
        return 'Time Entry';
      case profile:
        return 'Profile';
      case settings:
        return 'Settings';
      case editProfile:
        return 'Edit Profile';
      case team:
        return 'Team';
      case addTeamMember:
        return 'Add Team Member';
      case teamMemberDetail:
        return 'Team Member';
      case notifications:
        return 'Notifications';
      case activity:
        return 'Activity';
      case search:
        return 'Search';
      case filters:
        return 'Filters';
      case help:
        return 'Help';
      case about:
        return 'About';
      case feedback:
        return 'Feedback';
      case error:
        return 'Error';
      case noInternet:
        return 'No Internet';
      default:
        return 'Unknown';
    }
  }

  // Check if route requires authentication
  static bool requiresAuth(String route) {
    const unauthenticatedRoutes = [
      splash,
      login,
      register,
      error,
      noInternet,
    ];
    return !unauthenticatedRoutes.contains(route);
  }

  // Get route category (useful for analytics or navigation grouping)
  static String getRouteCategory(String route) {
    if ([splash, login, register].contains(route)) {
      return 'auth';
    } else if ([dashboard, main].contains(route)) {
      return 'main';
    } else if ([projects, createProject, projectDetail, editProject].contains(route)) {
      return 'projects';
    } else if ([tasks, createTask, taskDetail, editTask, kanbanBoard].contains(route)) {
      return 'tasks';
    } else if ([timesheet, timeReports, timeEntry].contains(route)) {
      return 'time';
    } else if ([profile, settings, editProfile].contains(route)) {
      return 'profile';
    } else if ([team, addTeamMember, teamMemberDetail].contains(route)) {
      return 'team';
    } else if ([notifications, activity].contains(route)) {
      return 'notifications';
    } else if ([search, filters].contains(route)) {
      return 'search';
    } else if ([help, about, feedback].contains(route)) {
      return 'support';
    } else if ([error, noInternet, calendar].contains(route)) {
      return 'utility';
    }
    return 'unknown';
  }

  // Generate route with parameters (helper method)
  static String generateRouteWithParams(String baseRoute, Map<String, String>? params) {
    if (params == null || params.isEmpty) {
      return baseRoute;
    }
    
    final queryString = params.entries
        .map((entry) => '${entry.key}=${Uri.encodeComponent(entry.value)}')
        .join('&');
    
    return '$baseRoute?$queryString';
  }

  // Common route parameter keys
  static const String paramProjectId = 'projectId';
  static const String paramTaskId = 'taskId';
  static const String paramUserId = 'userId';
  static const String paramTeamId = 'teamId';
  static const String paramFilter = 'filter';
  static const String paramSearch = 'search';
  static const String paramDate = 'date';
  static const String paramStatus = 'status';
  static const String paramPriority = 'priority';
  static const String paramStartDate = 'startDate';
  static const String paramEndDate = 'endDate';

  // Helper methods for common parametrized routes
  static String projectDetailRoute(String projectId) =>
      generateRouteWithParams(projectDetail, {paramProjectId: projectId});

  static String taskDetailRoute(String taskId) =>
      generateRouteWithParams(taskDetail, {paramTaskId: taskId});

  static String editProjectRoute(String projectId) =>
      generateRouteWithParams(editProject, {paramProjectId: projectId});

  static String editTaskRoute(String taskId) =>
      generateRouteWithParams(editTask, {paramTaskId: taskId});

  static String teamMemberDetailRoute(String userId) =>
      generateRouteWithParams(teamMemberDetail, {paramUserId: userId});

  static String kanbanBoardRoute({String? projectId, String? filter}) {
    Map<String, String> params = {};
    if (projectId != null) params[paramProjectId] = projectId;
    if (filter != null) params[paramFilter] = filter;
    return generateRouteWithParams(kanbanBoard, params.isEmpty ? null : params);
  }

  static String searchRoute({String? query, String? filter}) {
    Map<String, String> params = {};
    if (query != null) params[paramSearch] = query;
    if (filter != null) params[paramFilter] = filter;
    return generateRouteWithParams(search, params.isEmpty ? null : params);
  }

  static String tasksRoute({String? projectId, String? status, String? priority}) {
    Map<String, String> params = {};
    if (projectId != null) params[paramProjectId] = projectId;
    if (status != null) params[paramStatus] = status;
    if (priority != null) params[paramPriority] = priority;
    return generateRouteWithParams(tasks, params.isEmpty ? null : params);
  }

  static String timeReportsRoute({String? startDate, String? endDate, String? projectId}) {
    Map<String, String> params = {};
    if (startDate != null) params[paramStartDate] = startDate;
    if (endDate != null) params[paramEndDate] = endDate;
    if (projectId != null) params[paramProjectId] = projectId;
    return generateRouteWithParams(timeReports, params.isEmpty ? null : params);
  }
}