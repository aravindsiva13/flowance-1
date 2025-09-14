// lib/presentation/widgets/time/add_time_entry_dialog.dart - FIXED VERSION

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/time_tracking_viewmodel.dart';
import '../../../data/models/time_entry_model.dart';
import '../../../data/models/task_model.dart';
import '../../../core/constants/app_colors.dart';

class AddTimeEntryDialog extends StatefulWidget {
  final TimeEntryModel? entryToEdit;
  
  const AddTimeEntryDialog({Key? key, this.entryToEdit}) : super(key: key);

  @override
  State<AddTimeEntryDialog> createState() => _AddTimeEntryDialogState();
}

class _AddTimeEntryDialogState extends State<AddTimeEntryDialog> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  
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
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        constraints: const BoxConstraints(maxWidth: 500),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHeader(),
              const SizedBox(height: 16),
              _buildForm(),
              const SizedBox(height: 16),
              _buildButtons(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Icon(
          _isEditing ? Icons.edit_rounded : Icons.add_rounded,
          color: AppColors.primaryBlue,
        ),
        const SizedBox(width: 8),
        Text(
          _isEditing ? 'Edit Time Entry' : 'Add Time Entry',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildForm() {
    return Consumer<TimeTrackingViewModel>(
      builder: (context, timeTrackingVM, child) {
        return Form(
          key: _formKey,
          child: Column(
            children: [
              // Project Dropdown
              DropdownButtonFormField<String>(
                value: _selectedProjectId,
                decoration: const InputDecoration(
                  labelText: 'Project',
                  border: OutlineInputBorder(),
                ),
                items: timeTrackingVM.projects.map((project) {
                  return DropdownMenuItem(
                    value: project.id,
                    child: Text(project.name),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedProjectId = value;
                    _selectedTaskId = null; // Reset task selection
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a project';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Task Dropdown
              DropdownButtonFormField<String>(
                value: _selectedTaskId,
                decoration: const InputDecoration(
                  labelText: 'Task',
                  border: OutlineInputBorder(),
                ),
                items: _selectedProjectId != null
                    ? timeTrackingVM.getTasksForProject(_selectedProjectId!).map((task) {
                        return DropdownMenuItem(
                          value: task.id,
                          child: Text(task.title),
                        );
                      }).toList()
                    : [],
                onChanged: _selectedProjectId != null
                    ? (value) {
                        setState(() {
                          _selectedTaskId = value;
                        });
                      }
                    : null,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a task';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Description
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Date and Time Row
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => _selectDate(context),
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Date',
                          border: OutlineInputBorder(),
                        ),
                        child: Text(
                          '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: InkWell(
                      onTap: () => _selectStartTime(context),
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Start Time',
                          border: OutlineInputBorder(),
                        ),
                        child: Text(
                          _startTime?.format(context) ?? 'Select time',
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: InkWell(
                      onTap: () => _selectEndTime(context),
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'End Time',
                          border: OutlineInputBorder(),
                        ),
                        child: Text(
                          _endTime?.format(context) ?? 'Select time',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildButtons(BuildContext context) {
    return Consumer<TimeTrackingViewModel>(
      builder: (context, timeTrackingVM, child) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              onPressed: timeTrackingVM.isCreating || timeTrackingVM.isUpdating
                  ? null
                  : () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: timeTrackingVM.isCreating || timeTrackingVM.isUpdating
                  ? null
                  : () => _saveTimeEntry(context, timeTrackingVM),
              child: timeTrackingVM.isCreating || timeTrackingVM.isUpdating
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(_isEditing ? 'Update' : 'Save'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectStartTime(BuildContext context) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _startTime ?? TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        _startTime = picked;
      });
    }
  }

  Future<void> _selectEndTime(BuildContext context) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _endTime ?? TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        _endTime = picked;
      });
    }
  }

  Future<void> _saveTimeEntry(BuildContext context, TimeTrackingViewModel timeTrackingVM) async {
    if (!_formKey.currentState!.validate()) return;
    if (_startTime == null || _endTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select start and end times')),
      );
      return;
    }

    final startDateTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _startTime!.hour,
      _startTime!.minute,
    );

    final endDateTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _endTime!.hour,
      _endTime!.minute,
    );

    bool success = false;
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
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(timeTrackingVM.errorMessage ?? 'An error occurred')),
      );
    }
  }
}

// Helper function to show the dialog
Future<void> showAddTimeEntryDialog(BuildContext context, {TimeEntryModel? entryToEdit}) {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AddTimeEntryDialog(entryToEdit: entryToEdit);
    },
  );
}