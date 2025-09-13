// lib/presentation/widgets/time/add_time_entry_dialog.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/time_tracking_viewmodel.dart';
import '../../../data/models/time_entry_model.dart';
import '../../../data/models/task_model.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/validation_utils.dart';
import '../../../core/utils/app_utils.dart';
import '../../../core/utils/date_utils.dart';

class AddTimeEntryDialog extends StatefulWidget {
  final TimeEntryModel? entryToEdit;
  
  const AddTimeEntryDialog({Key? key, this.entryToEdit}) : super(key: key);

  @override
  State<AddTimeEntryDialog> createState() => _AddTimeEntryDialogState();
}

class _AddTimeEntryDialogState extends State<AddTimeEntryDialog> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _startTimeController = TextEditingController();
  final _endTimeController = TextEditingController();
  final _dateController = TextEditingController();
  
  String? _selectedProjectId;
  String? _selectedTaskId;
  DateTime _selectedDate = DateTime.now();
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  
  bool get _isEditing => widget.entryToEdit != null;

  @override
  void initState() {
    super.initState();
    _initializeFields();
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _startTimeController.dispose();
    _endTimeController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  void _initializeFields() {
    if (_isEditing) {
      final entry = widget.entryToEdit!;
      _descriptionController.text = entry.description;
      _selectedDate = DateTime(
        entry.startTime.year,
        entry.startTime.month,
        entry.startTime.day,
      );
      _startTime = TimeOfDay.fromDateTime(entry.startTime);
      if (entry.endTime != null) {
        _endTime = TimeOfDay.fromDateTime(entry.endTime!);
      }
      _selectedProjectId = entry.projectId;
      _selectedTaskId = entry.taskId;
    }
    
    _updateControllers();
  }

  void _updateControllers() {
    _dateController.text = AppDateUtils.formatDate(_selectedDate);
    _startTimeController.text = _startTime?.format(context) ?? '';
    _endTimeController.text = _endTime?.format(context) ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TimeTrackingViewModel>(
      builder: (context, timeTrackingVM, child) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(
                _isEditing ? Icons.edit_rounded : Icons.add_rounded,
                color: AppColors.primaryBlue,
              ),
              const SizedBox(width: 8),
              Text(_isEditing ? 'Edit Time Entry' : 'Add Time Entry'),
            ],
          ),
          content: SizedBox(
            width: MediaQuery.of(context).size.width * 0.9,
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Date selection
                    const Text(
                      'Date *',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _dateController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        prefixIcon: Icon(Icons.calendar_today_outlined),
                      ),
                      readOnly: true,
                      onTap: _selectDate,
                      validator: (value) => value?.isEmpty == true ? 'Please select a date' : null,
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Time range
                    Row(
                      children: [
                        // Start time
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Start Time *',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _startTimeController,
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  prefixIcon: Icon(Icons.access_time_rounded),
                                ),
                                readOnly: true,
                                onTap: () => _selectTime(true),
                                validator: (value) => value?.isEmpty == true ? 'Required' : null,
                              ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(width: 16),
                        
                        // End time
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'End Time *',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _endTimeController,
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  prefixIcon: Icon(Icons.access_time_rounded),
                                ),
                                readOnly: true,
                                onTap: () => _selectTime(false),
                                validator: (value) => value?.isEmpty == true ? 'Required' : null,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    
                    // Duration display
                    if (_startTime != null && _endTime != null) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.info.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.timer_rounded, size: 16, color: AppColors.info),
                            const SizedBox(width: 4),
                            Text(
                              'Duration: ${_calculateDuration()}',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: AppColors.info,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    
                    const SizedBox(height: 16),
                    
                    // Project selection
                    const Text(
                      'Project *',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _selectedProjectId,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        prefixIcon: Icon(Icons.folder_outlined),
                      ),
                      hint: const Text('Select project'),
                      validator: (value) => value == null ? 'Please select a project' : null,
                      items: timeTrackingVM.projects.map((project) {
                        return DropdownMenuItem(
                          value: project.id,
                          child: Text(
                            project.name,
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      }).toList(),
                      onChanged: _isEditing ? null : (projectId) {
                        setState(() {
                          _selectedProjectId = projectId;
                          _selectedTaskId = null; // Reset task when project changes
                        });
                      },
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Task selection
                    const Text(
                      'Task *',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _selectedTaskId,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        prefixIcon: Icon(Icons.task_alt_outlined),
                      ),
                      hint: const Text('Select task'),
                      validator: (value) => value == null ? 'Please select a task' : null,
                      items: _getTasksForProject().map((task) {
                        return DropdownMenuItem(
                          value: task.id,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                task.title,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontWeight: FontWeight.w500),
                              ),
                              if (task.estimatedTimeHours != null)
                                Text(
                                  'Est: ${task.formattedEstimatedTime}',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey[600],
                                  ),
                                ),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: _isEditing ? null : (taskId) {
                        setState(() {
                          _selectedTaskId = taskId;
                        });
                      },
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Description
                    const Text(
                      'Description',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        prefixIcon: Icon(Icons.description_outlined),
                        hintText: 'What did you work on?',
                      ),
                      maxLines: 3,
                      validator: (value) {
                        if (value != null && value.length > 500) {
                          return 'Description must be less than 500 characters';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton.icon(
              onPressed: timeTrackingVM.isCreating || timeTrackingVM.isUpdating 
                  ? null 
                  : _saveTimeEntry,
              icon: timeTrackingVM.isCreating || timeTrackingVM.isUpdating
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Icon(_isEditing ? Icons.save_rounded : Icons.add_rounded),
              label: Text(
                timeTrackingVM.isCreating || timeTrackingVM.isUpdating
                    ? (_isEditing ? 'Updating...' : 'Adding...')
                    : (_isEditing ? 'Update' : 'Add Entry'),
              ),
            ),
          ],
        );
      },
    );
  }

  List<TaskModel> _getTasksForProject() {
    if (_selectedProjectId == null) return [];
    
    final timeTrackingVM = context.read<TimeTrackingViewModel>();
    return timeTrackingVM.tasks
        .where((task) => 
          task.projectId == _selectedProjectId && 
          task.isTimeTrackingEnabled)
        .toList();
  }

  Future<void> _selectDate() async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
    );

    if (selectedDate != null) {
      setState(() {
        _selectedDate = selectedDate;
        _updateControllers();
      });
    }
  }

  Future<void> _selectTime(bool isStartTime) async {
    final initialTime = isStartTime 
        ? _startTime ?? TimeOfDay.now()
        : _endTime ?? (_startTime?.replacing(hour: _startTime!.hour + 1) ?? TimeOfDay.now());

    final selectedTime = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );

    if (selectedTime != null) {
      setState(() {
        if (isStartTime) {
          _startTime = selectedTime;
          // If end time is before start time, adjust it
          if (_endTime != null && _timeToMinutes(_endTime!) <= _timeToMinutes(selectedTime)) {
            _endTime = TimeOfDay(
              hour: (selectedTime.hour + 1) % 24,
              minute: selectedTime.minute,
            );
          }
        } else {
          _endTime = selectedTime;
        }
        _updateControllers();
      });
    }
  }

  int _timeToMinutes(TimeOfDay time) {
    return time.hour * 60 + time.minute;
  }

  String _calculateDuration() {
    if (_startTime == null || _endTime == null) return '';
    
    final startMinutes = _timeToMinutes(_startTime!);
    final endMinutes = _timeToMinutes(_endTime!);
    
    int durationMinutes = endMinutes - startMinutes;
    if (durationMinutes < 0) {
      durationMinutes += 24 * 60; // Handle next day
    }
    
    final hours = durationMinutes ~/ 60;
    final minutes = durationMinutes % 60;
    
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else {
      return '${minutes}m';
    }
  }

  Future<void> _saveTimeEntry() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_startTime == null || _endTime == null) {
      AppUtils.showErrorSnackBar(context, 'Please select start and end times');
      return;
    }

    final startDateTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _startTime!.hour,
      _startTime!.minute,
    );

    var endDateTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _endTime!.hour,
      _endTime!.minute,
    );

    // Handle case where end time is next day
    if (endDateTime.isBefore(startDateTime)) {
      endDateTime = endDateTime.add(const Duration(days: 1));
    }

    final timeTrackingVM = context.read<TimeTrackingViewModel>();
    bool success;

    if (_isEditing) {
      success = await timeTrackingVM.updateTimeEntry(
        widget.entryToEdit!.id,
        description: _descriptionController.text.trim(),
        startTime: startDateTime,
        endTime: endDateTime,
      );
    } else {
      success = await timeTrackingVM.createManualEntry(
        taskId: _selectedTaskId!,
        description: _descriptionController.text.trim(),
        startTime: startDateTime,
        endTime: endDateTime,
      );
    }

    if (success && mounted) {
      Navigator.pop(context);
      AppUtils.showSuccessSnackBar(
        context, 
        _isEditing ? 'Time entry updated successfully' : 'Time entry added successfully',
      );
    } else if (mounted) {
      AppUtils.showErrorSnackBar(
        context,
        timeTrackingVM.errorMessage ?? 
        (_isEditing ? 'Failed to update time entry' : 'Failed to add time entry'),
      );
    }
  }
}