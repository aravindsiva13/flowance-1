// lib/presentation/viewmodels/time_tracking_viewmodel.dart

import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../data/models/time_entry_model.dart';
import '../../data/models/task_model.dart';
import '../../data/models/project_model.dart';
import '../../data/repositories/app_repository.dart';
import '../../core/enums/task_status.dart';
import '../../core/enums/task_priority.dart';
import '../../core/enums/project_status.dart';
import '../../core/exceptions/app_exception.dart';

class TimeTrackingViewModel extends ChangeNotifier {
  final AppRepository _repository = AppRepository();
  
  List<TimeEntryModel> _timeEntries = [];
  TimeEntryModel? _activeTimeEntry;
  List<TaskModel> _tasks = [];
  List<ProjectModel> _projects = [];
  Timer? _timer;
  
  bool _isLoading = false;
  bool _isCreating = false;
  bool _isUpdating = false;
  bool _isDeleting = false;
  String? _errorMessage;
  
  // Filter states
  DateTime? _filterStartDate;
  DateTime? _filterEndDate;
  String? _filterProjectId;
  String? _filterTaskId;
  
  // Getters
  List<TimeEntryModel> get timeEntries => _timeEntries;
  TimeEntryModel? get activeTimeEntry => _activeTimeEntry;
  List<TaskModel> get tasks => _tasks;
  List<ProjectModel> get projects => _projects;
  bool get isLoading => _isLoading;
  bool get isCreating => _isCreating;
  bool get isUpdating => _isUpdating;
  bool get isDeleting => _isDeleting;
  String? get errorMessage => _errorMessage;
  bool get hasActiveTimer => _activeTimeEntry != null && _activeTimeEntry!.isActive;
  
  // Filter getters
  DateTime? get filterStartDate => _filterStartDate;
  DateTime? get filterEndDate => _filterEndDate;
  String? get filterProjectId => _filterProjectId;
  String? get filterTaskId => _filterTaskId;
  
  // Current timer duration
  Duration get currentTimerDuration {
    if (_activeTimeEntry == null || !_activeTimeEntry!.isActive) {
      return Duration.zero;
    }
    return DateTime.now().difference(_activeTimeEntry!.startTime);
  }
  
  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
  
  // Load time entries with optional filters
  Future<void> loadTimeEntries({
    DateTime? startDate,
    DateTime? endDate,
    String? projectId,
    String? taskId,
  }) async {
    _setLoading(true);
    _clearError();
    
    try {
      _timeEntries = await _repository.getTimeEntries(
        startDate: startDate,
        endDate: endDate,
        projectId: projectId,
        taskId: taskId,
      );
      
      // Load active time entry
      _activeTimeEntry = await _repository.getActiveTimeEntry();
      if (_activeTimeEntry != null) {
        _startTimer();
      }
    } catch (e) {
      _setError(_getErrorMessage(e));
    }
    
    _setLoading(false);
  }
  
  // Load supporting data (tasks and projects)
  Future<void> loadSupportingData() async {
    try {
      final futures = await Future.wait([
        _repository.getTasks(),
        _repository.getProjects(),
      ]);
      
      _tasks = futures[0] as List<TaskModel>;
      _projects = futures[1] as List<ProjectModel>;
      notifyListeners();
    } catch (e) {
      _setError(_getErrorMessage(e));
    }
  }
  
  // Get active time entry
  Future<TimeEntryModel?> getActiveEntry() async {
    try {
      final activeEntry = _timeEntries.firstWhere(
        (entry) => entry.isActive,
        orElse: () => throw StateError('No active entry found'),
      );
      return activeEntry;
    } catch (e) {
      return null;
    }
  }
  
  // Start timer for a task
  Future<bool> startTimer({
    required String taskId,
    required String description,
  }) async {
    _setUpdating(true);
    _clearError();
    
    try {
      // Stop existing timer if active
      if (_activeTimeEntry != null && _activeTimeEntry!.isActive) {
        await stopTimer();
      }
      
      // Get task details
      final task = _tasks.firstWhere((t) => t.id == taskId);
      
      final newEntry = await _repository.startTimeEntry(
        taskId: taskId,
        projectId: task.projectId,
        description: description,
      );
      
      _activeTimeEntry = newEntry;
      _timeEntries.insert(0, newEntry);
      _startTimer();
      
      _setUpdating(false);
      return true;
    } catch (e) {
      _setError(_getErrorMessage(e));
      _setUpdating(false);
      return false;
    }
  }
  
  // Stop active timer
  Future<bool> stopTimer() async {
    if (_activeTimeEntry == null || !_activeTimeEntry!.isActive) {
      return false;
    }
    
    _setUpdating(true);
    _clearError();
    
    try {
      final stoppedEntry = await _repository.stopTimeEntry(_activeTimeEntry!.id);
      
      // Update the entry in the list
      final index = _timeEntries.indexWhere((e) => e.id == _activeTimeEntry!.id);
      if (index != -1) {
        _timeEntries[index] = stoppedEntry;
      }
      
      _activeTimeEntry = null;
      _timer?.cancel();
      
      _setUpdating(false);
      return true;
    } catch (e) {
      _setError(_getErrorMessage(e));
      _setUpdating(false);
      return false;
    }
  }
  
  // Create manual time entry
  Future<bool> createManualEntry({
    required String taskId,
    required String description,
    required DateTime startTime,
    required DateTime endTime,
  }) async {
    _setCreating(true);
    _clearError();
    
    try {
      // Validate time entry
      final validationError = _validateTimeEntry(startTime, endTime);
      if (validationError != null) {
        _setError(validationError);
        _setCreating(false);
        return false;
      }
      
      // Check for overlaps
      final overlaps = await _checkForOverlaps(startTime, endTime);
      if (overlaps.isNotEmpty) {
        _setError('Time entry overlaps with existing entries');
        _setCreating(false);
        return false;
      }
      
      // Get task details
      final task = _tasks.firstWhere((t) => t.id == taskId);
      
      final newEntry = await _repository.createManualTimeEntry(
        taskId: taskId,
        projectId: task.projectId,
        description: description,
        startTime: startTime,
        endTime: endTime,
      );
      
      _timeEntries.insert(0, newEntry);
      
      _setCreating(false);
      return true;
    } catch (e) {
      _setError(_getErrorMessage(e));
      _setCreating(false);
      return false;
    }
  }
  
  // Update time entry
  Future<bool> updateTimeEntry(
    String entryId, {
    String? description,
    DateTime? startTime,
    DateTime? endTime,
  }) async {
    _setUpdating(true);
    _clearError();
    
    try {
      // Validate if times are provided
      if (startTime != null && endTime != null) {
        final validationError = _validateTimeEntry(startTime, endTime);
        if (validationError != null) {
          _setError(validationError);
          _setUpdating(false);
          return false;
        }
        
        // Check for overlaps (excluding current entry)
        final overlaps = await _checkForOverlaps(startTime, endTime, excludeId: entryId);
        if (overlaps.isNotEmpty) {
          _setError('Time entry overlaps with existing entries');
          _setUpdating(false);
          return false;
        }
      }
      
      final updatedEntry = await _repository.updateTimeEntry(
        entryId,
        description: description,
        startTime: startTime,
        endTime: endTime,
      );
      
      // Update entry in list
      final index = _timeEntries.indexWhere((e) => e.id == entryId);
      if (index != -1) {
        _timeEntries[index] = updatedEntry;
        
        // Update active entry if it's the same
        if (_activeTimeEntry?.id == entryId) {
          _activeTimeEntry = updatedEntry;
        }
      }
      
      _setUpdating(false);
      return true;
    } catch (e) {
      _setError(_getErrorMessage(e));
      _setUpdating(false);
      return false;
    }
  }
  
  // Delete time entry
  Future<bool> deleteTimeEntry(String entryId) async {
    _setDeleting(true);
    _clearError();
    
    try {
      await _repository.deleteTimeEntry(entryId);
      
      _timeEntries.removeWhere((e) => e.id == entryId);
      
      // Clear active entry if it was deleted
      if (_activeTimeEntry?.id == entryId) {
        _activeTimeEntry = null;
        _timer?.cancel();
      }
      
      _setDeleting(false);
      return true;
    } catch (e) {
      _setError(_getErrorMessage(e));
      _setDeleting(false);
      return false;
    }
  }
  
  // Filter methods
  void setDateFilter(DateTime? startDate, DateTime? endDate) {
    _filterStartDate = startDate;
    _filterEndDate = endDate;
    notifyListeners();
  }
  
  void setProjectFilter(String? projectId) {
    _filterProjectId = projectId;
    notifyListeners();
  }
  
  void setTaskFilter(String? taskId) {
    _filterTaskId = taskId;
    notifyListeners();
  }
  
  void clearFilters() {
    _filterStartDate = null;
    _filterEndDate = null;
    _filterProjectId = null;
    _filterTaskId = null;
    notifyListeners();
  }
  
  // Get filtered time entries
  List<TimeEntryModel> get filteredTimeEntries {
    var filtered = List<TimeEntryModel>.from(_timeEntries);
    
    if (_filterStartDate != null) {
      filtered = filtered.where((entry) => 
        entry.startTime.isAfter(_filterStartDate!) ||
        entry.startTime.isAtSameMomentAs(_filterStartDate!)
      ).toList();
    }
    
    if (_filterEndDate != null) {
      final endOfDay = DateTime(_filterEndDate!.year, _filterEndDate!.month, _filterEndDate!.day, 23, 59, 59);
      filtered = filtered.where((entry) => 
        entry.startTime.isBefore(endOfDay) ||
        entry.startTime.isAtSameMomentAs(endOfDay)
      ).toList();
    }
    
    if (_filterProjectId != null) {
      filtered = filtered.where((entry) => entry.projectId == _filterProjectId).toList();
    }
    
    if (_filterTaskId != null) {
      filtered = filtered.where((entry) => entry.taskId == _filterTaskId).toList();
    }
    
    return filtered;
  }
  
  // Analytics methods
  Map<String, double> getDailyHours({DateTime? date}) {
    final targetDate = date ?? DateTime.now();
    final startOfDay = DateTime(targetDate.year, targetDate.month, targetDate.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    
    final dailyEntries = _timeEntries.where((entry) => 
      entry.startTime.isAfter(startOfDay) || entry.startTime.isAtSameMomentAs(startOfDay)
    ).where((entry) =>
      entry.startTime.isBefore(endOfDay)
    ).toList();
    
    final hoursMap = <String, double>{};
    for (final entry in dailyEntries) {
      final projectName = getProjectName(entry.projectId);
      hoursMap[projectName] = (hoursMap[projectName] ?? 0.0) + entry.durationHours;
    }
    
    return hoursMap;
  }
  
  double getTotalHoursForPeriod({DateTime? startDate, DateTime? endDate}) {
    final start = startDate ?? DateTime.now().subtract(const Duration(days: 7));
    final end = endDate ?? DateTime.now();
    
    final periodEntries = _timeEntries.where((entry) => 
      (entry.startTime.isAfter(start) || entry.startTime.isAtSameMomentAs(start)) &&
      entry.startTime.isBefore(end.add(const Duration(days: 1)))
    ).toList();
    
    return periodEntries.fold(0.0, (sum, entry) => sum + entry.durationHours);
  }
  
  Map<String, double> getProjectHours({DateTime? startDate, DateTime? endDate}) {
    final start = startDate ?? DateTime.now().subtract(const Duration(days: 7));
    final end = endDate ?? DateTime.now();
    
    final periodEntries = _timeEntries.where((entry) => 
      (entry.startTime.isAfter(start) || entry.startTime.isAtSameMomentAs(start)) &&
      entry.startTime.isBefore(end.add(const Duration(days: 1)))
    ).toList();
    
    final projectHours = <String, double>{};
    for (final entry in periodEntries) {
      final projectName = getProjectName(entry.projectId);
      projectHours[projectName] = (projectHours[projectName] ?? 0.0) + entry.durationHours;
    }
    
    return projectHours;
  }
  
  // Export methods
  Future<List<Map<String, dynamic>>> getTimeEntriesForExport({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final entries = await _repository.getTimeEntriesForExport(
        startDate: startDate,
        endDate: endDate,
      );
      
      return entries;
    } catch (e) {
      _setError(_getErrorMessage(e));
      return [];
    }
  }
  
  // Helper methods
  String getTaskName(String taskId) {
    final task = _tasks.firstWhere(
      (task) => task.id == taskId,
      orElse: () => TaskModel(
        id: taskId,
        title: 'Unknown Task',
        description: '',
        status: TaskStatus.toDo,
        priority: TaskPriority.medium,
        projectId: '',
        creatorId: '',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );
    return task.title;
  }
  
  String getProjectName(String projectId) {
    final project = _projects.firstWhere(
      (project) => project.id == projectId,
      orElse: () => ProjectModel(
        id: projectId,
        name: 'Unknown Project',
        description: '',
        status: ProjectStatus.active,
        ownerId: '',
        memberIds: [],
        startDate: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );
    return project.name;
  }
  
  List<TaskModel> getTasksForProject(String? projectId) {
    if (projectId == null) return _tasks;
    return _tasks.where((task) => task.projectId == projectId).toList();
  }
  
  // Private methods
  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      notifyListeners(); // Update UI every second
    });
  }
  
  String? _validateTimeEntry(DateTime startTime, DateTime endTime) {
    if (endTime.isBefore(startTime) || endTime.isAtSameMomentAs(startTime)) {
      return 'End time must be after start time';
    }
    
    final duration = endTime.difference(startTime);
    if (duration.inHours > 24) {
      return 'Time entry cannot be longer than 24 hours';
    }
    
    if (startTime.isAfter(DateTime.now())) {
      return 'Start time cannot be in the future';
    }
    
    return null;
  }
  
  Future<List<TimeEntryModel>> _checkForOverlaps(
    DateTime startTime, 
    DateTime endTime, 
    {String? excludeId}
  ) async {
    return _timeEntries.where((entry) {
      if (excludeId != null && entry.id == excludeId) return false;
      
      final entryStart = entry.startTime;
      final entryEnd = entry.endTime ?? DateTime.now();
      
      return startTime.isBefore(entryEnd) && endTime.isAfter(entryStart);
    }).toList();
  }
  
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
  
  void _setCreating(bool creating) {
    _isCreating = creating;
    notifyListeners();
  }
  
  void _setUpdating(bool updating) {
    _isUpdating = updating;
    notifyListeners();
  }
  
  void _setDeleting(bool deleting) {
    _isDeleting = deleting;
    notifyListeners();
  }
  
  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }
  
  void _clearError() {
    _errorMessage = null;
  }
  
  String _getErrorMessage(dynamic error) {
    if (error is AppException) {
      return error.message;
    }
    return error.toString().replaceFirst('Exception: ', '');
  }
  
  void clearError() {
    _clearError();
    notifyListeners();
  }


  // Add these methods to your existing TimeTrackingViewModel class:


// Get time entries for a specific project
List<TimeEntryModel> getProjectTimeEntries(String projectId) {
  return _timeEntries.where((entry) => entry.projectId == projectId).toList()
    ..sort((a, b) => b.startTime.compareTo(a.startTime));
}

// Get time breakdown by team member for a project
Map<String, double> getProjectMemberHours(String projectId) {
  final projectEntries = getProjectTimeEntries(projectId);
  final memberHours = <String, double>{};
  
  for (final entry in projectEntries) {
    memberHours[entry.userId] = (memberHours[entry.userId] ?? 0.0) + entry.durationHours;
  }
  
  return memberHours;
}

// Get time breakdown by task for a project
Map<String, double> getProjectTaskHours(String projectId) {
  final projectEntries = getProjectTimeEntries(projectId);
  final taskHours = <String, double>{};
  
  for (final entry in projectEntries) {
    final taskName = getTaskName(entry.taskId);
    taskHours[taskName] = (taskHours[taskName] ?? 0.0) + entry.durationHours;
  }
  
  return taskHours;
}

// Get daily hours for a project (for charts)
Map<DateTime, double> getProjectDailyHours(String projectId, {
  DateTime? startDate,
  DateTime? endDate,
}) {
  final projectEntries = getProjectTimeEntries(projectId);
  final dailyHours = <DateTime, double>{};
  
  for (final entry in projectEntries) {
    // Check date range
    if (startDate != null && entry.startTime.isBefore(startDate)) continue;
    if (endDate != null && entry.startTime.isAfter(endDate)) continue;
    
    final date = DateTime(
      entry.startTime.year,
      entry.startTime.month,
      entry.startTime.day,
    );
    dailyHours[date] = (dailyHours[date] ?? 0.0) + entry.durationHours;
  }
  
  return Map.fromEntries(
    dailyHours.entries.toList()..sort((a, b) => a.key.compareTo(b.key))
  );
}

// Get weekly hours for a project
Map<DateTime, double> getProjectWeeklyHours(String projectId) {
  final projectEntries = getProjectTimeEntries(projectId);
  final weeklyHours = <DateTime, double>{};
  
  for (final entry in projectEntries) {
    // Get start of week (Monday)
    final weekStart = entry.startTime.subtract(Duration(days: entry.startTime.weekday - 1));
    final weekKey = DateTime(weekStart.year, weekStart.month, weekStart.day);
    
    weeklyHours[weekKey] = (weeklyHours[weekKey] ?? 0.0) + entry.durationHours;
  }
  
  return Map.fromEntries(
    weeklyHours.entries.toList()..sort((a, b) => a.key.compareTo(b.key))
  );
}

// Get project time statistics
Map<String, dynamic> getProjectTimeStats(String projectId) {
  final projectEntries = getProjectTimeEntries(projectId);
  
  if (projectEntries.isEmpty) {
    return {
      'totalHours': 0.0,
      'totalEntries': 0,
      'averageSessionHours': 0.0,
      'longestSessionHours': 0.0,
      'shortestSessionHours': 0.0,
      'activeDays': 0,
      'memberCount': 0,
      'taskCount': 0,
    };
  }
  
  final totalHours = projectEntries.fold(0.0, (sum, entry) => sum + entry.durationHours);
  final sessionHours = projectEntries.map((e) => e.durationHours).toList();
  final uniqueDays = projectEntries.map((e) => DateTime(e.startTime.year, e.startTime.month, e.startTime.day)).toSet();
  final uniqueMembers = projectEntries.map((e) => e.userId).toSet();
  final uniqueTasks = projectEntries.map((e) => e.taskId).toSet();
  
  return {
    'totalHours': totalHours,
    'totalEntries': projectEntries.length,
    'averageSessionHours': totalHours / projectEntries.length,
    'longestSessionHours': sessionHours.reduce((a, b) => a > b ? a : b),
    'shortestSessionHours': sessionHours.reduce((a, b) => a < b ? a : b),
    'activeDays': uniqueDays.length,
    'memberCount': uniqueMembers.length,
    'taskCount': uniqueTasks.length,
  };
}


// Helper method to get user name by ID
String getUserName(String userId) {
  // You might want to integrate this with UserViewModel
  // For now, return a placeholder
  return 'User $userId';
}

// Get time efficiency metrics for a project
Map<String, dynamic> getProjectEfficiencyMetrics(String projectId) {
  final projectEntries = getProjectTimeEntries(projectId);
  final now = DateTime.now();
  
  // Calculate various efficiency metrics
  final last7DaysEntries = projectEntries.where((entry) => 
    now.difference(entry.startTime).inDays <= 7
  ).toList();
  
  final last30DaysEntries = projectEntries.where((entry) => 
    now.difference(entry.startTime).inDays <= 30
  ).toList();
  
  final last7DaysHours = last7DaysEntries.fold(0.0, (sum, entry) => sum + entry.durationHours);
  final last30DaysHours = last30DaysEntries.fold(0.0, (sum, entry) => sum + entry.durationHours);
  
  return {
    'last7DaysHours': last7DaysHours,
    'last30DaysHours': last30DaysHours,
    'dailyAverage7Days': last7DaysHours / 7,
    'dailyAverage30Days': last30DaysHours / 30,
    'weeklyAverage': last30DaysHours / 4,
    'entriesLast7Days': last7DaysEntries.length,
    'entriesLast30Days': last30DaysEntries.length,
  };
}

// Get project time trends (for analytics)
List<Map<String, dynamic>> getProjectTimeTrends(String projectId, {int days = 30}) {
  final endDate = DateTime.now();
  final startDate = endDate.subtract(Duration(days: days));
  final dailyHours = getProjectDailyHours(projectId, startDate: startDate, endDate: endDate);
  
  final trends = <Map<String, dynamic>>[];
  
  for (int i = 0; i < days; i++) {
    final date = startDate.add(Duration(days: i));
    final dayKey = DateTime(date.year, date.month, date.day);
    final hours = dailyHours[dayKey] ?? 0.0;
    
    trends.add({
      'date': dayKey,
      'hours': hours,
      'dayName': _getDayName(dayKey.weekday),
      'isWeekend': dayKey.weekday > 5,
    });
  }
  
  return trends;
}

String _getDayName(int weekday) {
  switch (weekday) {
    case 1: return 'Mon';
    case 2: return 'Tue';
    case 3: return 'Wed';
    case 4: return 'Thu';
    case 5: return 'Fri';
    case 6: return 'Sat';
    case 7: return 'Sun';
    default: return '';
  }
}


// // Get time budget vs actual for project (if budget is set)
// Map<String, dynamic> getProjectBudgetAnalysis(String projectId, {double? budgetHours}) {
//   if (budgetHours == null) {
//     return {
//       'hasBudget': false,
//       'message': 'No budget set for this project',
//     };
//   }
  
//   final actualHours = getProjectHours(projectIds: [projectId]);
//   final budgetUsed = actualHours / budgetHours;
//   final isOverBudget = budgetUsed > 1.0;
//   final remainingHours = budgetHours - actualHours;
  
//   return {
//     'hasBudget': true,
//     'budgetHours': budgetHours,
//     'actualHours': actualHours,
//     'budgetUsedPercentage': budgetUsed * 100,
//     'isOverBudget': isOverBudget,
//     'remainingHours': remainingHours,
//     'overageHours': isOverBudget ? actualHours - budgetHours : 0.0,
//     'status': isOverBudget 
//         ? 'over_budget' 
//         : budgetUsed > 0.8 
//             ? 'near_budget' 
//             : 'under_budget',
//   };
// }


Future<void> _loadProjects() async {
  try {
    _projects = await _repository.getProjects();
  } catch (e) {
    debugPrint('Failed to load projects for time tracking: ${e.toString()}');
  }
}

Future<void> _loadTasks() async {
  try {
    _tasks = await _repository.getTasks();
  } catch (e) {
    debugPrint('Failed to load tasks for time tracking: ${e.toString()}');
  }
}
}