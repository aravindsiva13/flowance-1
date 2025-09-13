// lib/presentation/views/tasks/edit_task_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/task_viewmodel.dart';
import '../../widgets/common/custom_app_bar.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/loading_widget.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/enums/task_status.dart';
import '../../../core/enums/task_priority.dart';
import '../../../core/utils/validation_utils.dart';
import '../../../core/utils/app_utils.dart';
import '../../../data/models/task_model.dart';

class EditTaskScreen extends StatefulWidget {
  final String taskId;

  const EditTaskScreen({Key? key, required this.taskId}) : super(key: key);

  @override
  State<EditTaskScreen> createState() => _EditTaskScreenState();
}

class _EditTaskScreenState extends State<EditTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _dueDateController = TextEditingController();
  final _tagsController = TextEditingController();

  TaskStatus _selectedStatus = TaskStatus.toDo;
  TaskPriority _selectedPriority = TaskPriority.medium;
  String? _selectedAssigneeId;
  DateTime? _selectedDueDate;
  double _progress = 0.0;
  
  TaskModel? _task;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadTask();
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _dueDateController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  Future<void> _loadTask() async {
    final taskViewModel = context.read<TaskViewModel>();
    
    // Load task data and users
    await Future.wait([
      taskViewModel.loadUsers(),
    ]);

    final task = await taskViewModel.getTask(widget.taskId);
    if (task != null) {
      setState(() {
        _task = task;
        _titleController.text = task.title;
        _descriptionController.text = task.description;
        _selectedStatus = task.status;
        _selectedPriority = task.priority;
        _selectedAssigneeId = task.assigneeId;
        _selectedDueDate = task.dueDate;
        _progress = task.progress;
        _tagsController.text = task.tags.join(', ');
        
        if (task.dueDate != null) {
          _dueDateController.text = '${task.dueDate!.day}/${task.dueDate!.month}/${task.dueDate!.year}';
        }
        
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _selectDueDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDueDate ?? DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (date != null) {
      setState(() {
        _selectedDueDate = date;
        _dueDateController.text = '${date.day}/${date.month}/${date.year}';
      });
    }
  }

  Future<void> _updateTask() async {
    if (!_formKey.currentState!.validate()) return;

    final taskViewModel = context.read<TaskViewModel>();
    final tags = _tagsController.text
        .split(',')
        .map((tag) => tag.trim())
        .where((tag) => tag.isNotEmpty)
        .toList();

    final success = await taskViewModel.updateTask(
      widget.taskId,
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      status: _selectedStatus,
      priority: _selectedPriority,
      assigneeId: _selectedAssigneeId,
      dueDate: _selectedDueDate,
      tags: tags,
      progress: _progress,
    );

    if (success && mounted) {
      AppUtils.showSuccessSnackBar(context, 'Task updated successfully');
      Navigator.pop(context);
    } else if (mounted) {
      AppUtils.showErrorSnackBar(
        context,
        taskViewModel.errorMessage ?? 'Failed to update task',
      );
    }
  }

  Future<void> _deleteTask() async {
    final confirmed = await AppUtils.showConfirmDialog(
      context,
      title: 'Delete Task',
      content: 'Are you sure you want to delete this task? This action cannot be undone.',
      confirmText: 'Delete',
    );

    if (confirmed) {
      final taskViewModel = context.read<TaskViewModel>();
      final success = await taskViewModel.deleteTask(widget.taskId);

      if (success && mounted) {
        AppUtils.showSuccessSnackBar(context, 'Task deleted successfully');
        Navigator.pop(context);
        Navigator.pop(context); // Go back to task list
      } else if (mounted) {
        AppUtils.showErrorSnackBar(
          context,
          taskViewModel.errorMessage ?? 'Failed to delete task',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: LoadingWidget(message: 'Loading task...'),
      );
    }

    if (_task == null) {
      return Scaffold(
        appBar: const CustomAppBar(title: 'Edit Task'),
        body: const Center(
          child: Text('Task not found'),
        ),
      );
    }

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Edit Task',
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'delete') {
                _deleteTask();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete_outlined, color: AppColors.error),
                    SizedBox(width: 8),
                    Text('Delete Task', style: TextStyle(color: AppColors.error)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Task Title
              CustomTextField(
                label: 'Task Title',
                controller: _titleController,
                validator: ValidationUtils.validateTaskTitle,
                prefixIcon: Icons.task_alt_outlined,
              ),
              const SizedBox(height: 16),

              // Description
              CustomTextField(
                label: 'Description',
                controller: _descriptionController,
                validator: (value) => ValidationUtils.validateDescription(value, required: true),
                prefixIcon: Icons.description_outlined,
                maxLines: 3,
              ),
              const SizedBox(height: 16),

              // Status and Priority Row
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<TaskStatus>(
                      value: _selectedStatus,
                      decoration: const InputDecoration(
                        labelText: 'Status',
                        prefixIcon: Icon(Icons.flag_outlined),
                      ),
                      items: TaskStatus.values.map((status) {
                        return DropdownMenuItem(
                          value: status,
                          child: Text(status.displayName),
                        );
                      }).toList(),
                      onChanged: (status) {
                        if (status != null) {
                          setState(() {
                            _selectedStatus = status;
                          });
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DropdownButtonFormField<TaskPriority>(
                      value: _selectedPriority,
                      decoration: const InputDecoration(
                        labelText: 'Priority',
                        prefixIcon: Icon(Icons.priority_high_outlined),
                      ),
                      items: TaskPriority.values.map((priority) {
                        return DropdownMenuItem(
                          value: priority,
                          child: Text(priority.displayName),
                        );
                      }).toList(),
                      onChanged: (priority) {
                        if (priority != null) {
                          setState(() {
                            _selectedPriority = priority;
                          });
                        }
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Assignee
              Consumer<TaskViewModel>(
                builder: (context, taskViewModel, child) {
                  return DropdownButtonFormField<String>(
                    value: _selectedAssigneeId,
                    decoration: const InputDecoration(
                      labelText: 'Assignee',
                      prefixIcon: Icon(Icons.person_outlined),
                    ),
                    items: [
                      const DropdownMenuItem(
                        value: null,
                        child: Text('Unassigned'),
                      ),
                      ...taskViewModel.users.map((user) {
                        return DropdownMenuItem(
                          value: user.id,
                          child: Text('${user.name} (${user.role.displayName})'),
                        );
                      }),
                    ],
                    onChanged: (userId) {
                      setState(() {
                        _selectedAssigneeId = userId;
                      });
                    },
                  );
                },
              ),
              const SizedBox(height: 16),

              // Due Date
              CustomTextField(
                label: 'Due Date',
                controller: _dueDateController,
                prefixIcon: Icons.calendar_today_outlined,
                readOnly: true,
                onTap: _selectDueDate,
                suffixIcon: _selectedDueDate != null
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _selectedDueDate = null;
                            _dueDateController.clear();
                          });
                        },
                      )
                    : null,
              ),
              const SizedBox(height: 16),

              // Progress Slider (only for in-progress tasks)
              if (_selectedStatus == TaskStatus.inProgress) ...[
                const Text(
                  'Progress',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('0%'),
                            Text(
                              '${(_progress * 100).toInt()}%',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryBlue,
                              ),
                            ),
                            const Text('100%'),
                          ],
                        ),
                        Slider(
                          value: _progress,
                          onChanged: (value) {
                            setState(() {
                              _progress = value;
                            });
                          },
                          divisions: 10,
                          activeColor: AppColors.primaryBlue,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Tags
              CustomTextField(
                label: 'Tags (comma-separated)',
                controller: _tagsController,
                prefixIcon: Icons.label_outlined,
                hint: 'e.g. frontend, urgent, bug',
              ),
              const SizedBox(height: 24),

              // Project Info (Read-only)
              Consumer<TaskViewModel>(
                builder: (context, taskViewModel, child) {
                  final projectName = taskViewModel.getProjectName(_task!.projectId);
                  return CustomTextField(
                    label: 'Project',
                    controller: TextEditingController(text: projectName),
                    prefixIcon: Icons.folder_outlined,
                    enabled: false,
                  );
                },
              ),
              const SizedBox(height: 24),

              // Action Buttons
              Consumer<TaskViewModel>(
                builder: (context, taskViewModel, child) {
                  return Row(
                    children: [
                      Expanded(
                        child: CustomButton(
                          text: 'Cancel',
                          onPressed: () => Navigator.pop(context),
                          isOutlined: true,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: CustomButton(
                          text: 'Update Task',
                          onPressed: _updateTask,
                          isLoading: taskViewModel.isUpdating,
                          icon: Icons.save_outlined,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}