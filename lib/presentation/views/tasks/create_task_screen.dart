
// =================================================================

// lib/presentation/views/tasks/create_task_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/task_viewmodel.dart';
import '../../viewmodels/project_viewmodel.dart';
import '../../widgets/common/custom_app_bar.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../widgets/common/custom_button.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/enums/task_status.dart';
import '../../../core/enums/task_priority.dart';
import '../../../core/utils/validation_utils.dart';
import '../../../core/utils/app_utils.dart';

class CreateTaskScreen extends StatefulWidget {
  final String? projectId;

  const CreateTaskScreen({Key? key, this.projectId}) : super(key: key);

  @override
  State<CreateTaskScreen> createState() => _CreateTaskScreenState();
}

class _CreateTaskScreenState extends State<CreateTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _dueDateController = TextEditingController();
  final _tagsController = TextEditingController();

  TaskStatus _selectedStatus = TaskStatus.toDo;
  TaskPriority _selectedPriority = TaskPriority.medium;
  String? _selectedProjectId;
  String? _selectedAssigneeId;
  DateTime? _selectedDueDate;

  @override
  void initState() {
    super.initState();
    _selectedProjectId = widget.projectId;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final taskViewModel = context.read<TaskViewModel>();
      Future.wait([
        taskViewModel.loadProjects(),
        taskViewModel.loadUsers(),
      ]);
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

  Future<void> _selectDueDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 7)),
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

  Future<void> _createTask() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedProjectId == null) {
      AppUtils.showErrorSnackBar(context, 'Please select a project');
      return;
    }

    final taskViewModel = context.read<TaskViewModel>();
    final tags = _tagsController.text
        .split(',')
        .map((tag) => tag.trim())
        .where((tag) => tag.isNotEmpty)
        .toList();

    final success = await taskViewModel.createTask(
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      projectId: _selectedProjectId!,
      status: _selectedStatus,
      priority: _selectedPriority,
      assigneeId: _selectedAssigneeId,
      dueDate: _selectedDueDate,
      tags: tags,
    );

    if (success && mounted) {
      AppUtils.showSuccessSnackBar(context, 'Task created successfully');
      Navigator.pop(context);
    } else if (mounted) {
      AppUtils.showErrorSnackBar(
        context,
        taskViewModel.errorMessage ?? 'Failed to create task',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Create Task'),
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

              // Project Selection
              Consumer<TaskViewModel>(
                builder: (context, taskViewModel, child) {
                  return DropdownButtonFormField<String>(
                    value: _selectedProjectId,
                    decoration: const InputDecoration(
                      labelText: 'Project',
                      prefixIcon: Icon(Icons.folder_outlined),
                    ),
                    validator: (value) => value == null ? 'Please select a project' : null,
                    items: taskViewModel.projects.map((project) {
                      return DropdownMenuItem(
                        value: project.id,
                        child: Text(project.name),
                      );
                    }).toList(),
                    onChanged: widget.projectId == null
                        ? (projectId) {
                            setState(() {
                              _selectedProjectId = projectId;
                            });
                          }
                        : null,
                  );
                },
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
                      labelText: 'Assignee (Optional)',
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
                label: 'Due Date (Optional)',
                controller: _dueDateController,
                prefixIcon: Icons.calendar_today_outlined,
                readOnly: true,
                onTap: _selectDueDate,
              ),
              const SizedBox(height: 16),

              // Tags
              CustomTextField(
                label: 'Tags (comma-separated)',
                controller: _tagsController,
                prefixIcon: Icons.label_outlined,
                hint: 'e.g. frontend, urgent, bug',
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
                          text: 'Create Task',
                          onPressed: _createTask,
                          isLoading: taskViewModel.isCreating,
                          icon: Icons.add_task,
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
