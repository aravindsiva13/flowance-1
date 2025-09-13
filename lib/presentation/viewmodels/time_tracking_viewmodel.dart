// lib/presentation/viewmodels/time_tracking_viewmodel.dart

import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../data/models/time_entry_model.dart';
import '../../data/models/task_model.dart';
import '../../data/models/project_model.dart';
import '../../data/repositories/app_repository.dart';
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
      
      // Find active timer
      _activeTimeEntry = _timeEntries.firstWhere(
        (entry) => entry.isActive,
        orElse: () => null as TimeEntryModel?,
      );
      
      // Start timer if there's an active entry
      if (_activeTimeEntry != null && _activeTimeEntry!.isActive) {
        _startTimer();
      }
    } catch (e) {
      _setError(_getErrorMessage(e));
    }
    
    _setLoading(false);
  }
  
  // Load supporting data
  Future<void> loadSupportingData() async {
    try {
      final results = await Future.wait([
        _repository.getTasks(),
        _repository.getProjects(),
      ]);
      
      _tasks = results[0] as List<TaskModel>;
      _projects = results[1] as List<ProjectModel>;
      notifyListeners();
    } catch (e) {
      _setError(_getErrorMessage(e));
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
      // Stop any existing active timer
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
      if (startTime != null && endTime != null) {
        final validationError = _validateTimeEntry(startTime, endTime);
        if (validationError != null) {
          _setError(validationError);
          _setUpdating(false);
          return false;
        }
        
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
      
      final index = _timeEntries.indexWhere((e) => e.id == entryId);
      if (index != -1) {
        _timeEntries[index] = updatedEntry;
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
    _filterTaskId = null; // Clear task filter when project changes
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
      
      final exportData = <Map<String, dynamic>>[];
      for (final entry in entries) {
        exportData.add({
          'Date': entry['startTime']?.substring(0, 10) ?? '',
          'Start Time': entry['startTime']?.substring(11, 16) ?? '',
          'End Time': entry['endTime']?.substring(11, 16) ?? '',
          'Duration': entry['formattedDuration'] ?? '',
          'Project': entry['projectName'] ?? '',
          'Task': entry['taskTitle'] ?? '',
          'Description': entry['description'] ?? '',
          'Type': entry['type'] ?? '',
          'User': entry['userName'] ?? '',
        });
      }
      
      return exportData;
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
}