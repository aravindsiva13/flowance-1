// lib/presentation/widgets/time/start_timer_dialog.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/time_tracking_viewmodel.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/validation_utils.dart';
import '../../../core/utils/app_utils.dart';

class StartTimerDialog extends StatefulWidget {
  const StartTimerDialog({Key? key}) : super(key: key);

  @override
  State<StartTimerDialog> createState() => _StartTimerDialogState();
}

class _StartTimerDialogState extends State<StartTimerDialog> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  
  String? _selectedProjectId;
  String? _selectedTaskId;

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TimeTrackingViewModel>(
      builder: (context, timeTrackingVM, child) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.play_arrow_rounded, color: AppColors.success),
              SizedBox(width: 8),
              Text('Start Timer'),
            ],
          ),
          content: SizedBox(
            width: MediaQuery.of(context).size.width * 0.9,
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                    onChanged: (projectId) {
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
                    onChanged: (taskId) {
                      setState(() {
                        _selectedTaskId = taskId;
                      });
                    },
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Description
                  const Text(
                    'Description (Optional)',
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
                      hintText: 'What are you working on?',
                    ),
                    maxLines: 2,
                    validator: (value) {
                      if (value != null && value.length > 200) {
                        return 'Description must be less than 200 characters';
                      }
                      return null;
                    },
                  ),
                  
                  // Warning if there's already an active timer
                  if (timeTrackingVM.hasActiveTimer) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.warning.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppColors.warning.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.warning_rounded, color: AppColors.warning, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Starting a new timer will stop the current active timer.',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.warning.withOpacity(0.8),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton.icon(
              onPressed: timeTrackingVM.isUpdating ? null : _startTimer,
              icon: timeTrackingVM.isUpdating
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.play_arrow_rounded),
              label: Text(timeTrackingVM.isUpdating ? 'Starting...' : 'Start Timer'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.success,
                foregroundColor: Colors.white,
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

  Future<void> _startTimer() async {
    if (!_formKey.currentState!.validate()) return;

    final timeTrackingVM = context.read<TimeTrackingViewModel>();
    final success = await timeTrackingVM.startTimer(
      taskId: _selectedTaskId!,
      description: _descriptionController.text.trim(),
    );

    if (success && mounted) {
      Navigator.pop(context);
      AppUtils.showSuccessSnackBar(context, 'Timer started successfully');
    } else if (mounted) {
      AppUtils.showErrorSnackBar(
        context,
        timeTrackingVM.errorMessage ?? 'Failed to start timer',
      );
    }
  }
}