
// =================================================================

// lib/presentation/views/projects/create_project_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/project_viewmodel.dart';
import '../../viewmodels/user_viewmodel.dart';
import '../../widgets/common/custom_app_bar.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../widgets/common/custom_button.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/enums/project_status.dart';
import '../../../core/utils/validation_utils.dart';
import '../../../core/utils/app_utils.dart';

class CreateProjectScreen extends StatefulWidget {
  const CreateProjectScreen({Key? key}) : super(key: key);

  @override
  State<CreateProjectScreen> createState() => _CreateProjectScreenState();
}

class _CreateProjectScreenState extends State<CreateProjectScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _dueDateController = TextEditingController();
  
  ProjectStatus _selectedStatus = ProjectStatus.planning;
  DateTime? _selectedDueDate;
  List<String> _selectedMemberIds = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UserViewModel>().loadUsers();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _dueDateController.dispose();
    super.dispose();
  }

  Future<void> _selectDueDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );

    if (date != null) {
      setState(() {
        _selectedDueDate = date;
        _dueDateController.text = '${date.day}/${date.month}/${date.year}';
      });
    }
  }

  Future<void> _createProject() async {
    if (!_formKey.currentState!.validate()) return;

    final projectViewModel = context.read<ProjectViewModel>();
    final success = await projectViewModel.createProject(
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
      status: _selectedStatus,
      memberIds: _selectedMemberIds,
      dueDate: _selectedDueDate,
    );

    if (success) {
      if (mounted) {
        AppUtils.showSuccessSnackBar(context, 'Project created successfully');
        Navigator.pop(context);
      }
    } else if (mounted) {
      AppUtils.showErrorSnackBar(
        context,
        projectViewModel.errorMessage ?? 'Failed to create project',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Create Project'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Project Name
              CustomTextField(
                label: 'Project Name',
                controller: _nameController,
                validator: ValidationUtils.validateProjectName,
                prefixIcon: Icons.folder_outlined,
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

              // Status
              DropdownButtonFormField<ProjectStatus>(
                value: _selectedStatus,
                decoration: const InputDecoration(
                  labelText: 'Status',
                  prefixIcon: Icon(Icons.flag_outlined),
                ),
                items: ProjectStatus.values.map((status) {
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

              // Team Members
              const Text(
                'Team Members',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Consumer<UserViewModel>(
                builder: (context, userViewModel, child) {
                  if (userViewModel.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final users = userViewModel.teamMembers;
                  return Card(
                    child: Container(
                      constraints: const BoxConstraints(maxHeight: 200),
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: users.length,
                        itemBuilder: (context, index) {
                          final user = users[index];
                          final isSelected = _selectedMemberIds.contains(user.id);
                          
                          return CheckboxListTile(
                            title: Text(user.name),
                            subtitle: Text(user.role.displayName),
                            value: isSelected,
                            onChanged: (selected) {
                              setState(() {
                                if (selected == true) {
                                  _selectedMemberIds.add(user.id);
                                } else {
                                  _selectedMemberIds.remove(user.id);
                                }
                              });
                            },
                          );
                        },
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),

              // Action Buttons
              Consumer<ProjectViewModel>(
                builder: (context, projectViewModel, child) {
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
                          text: 'Create Project',
                          onPressed: _createProject,
                          isLoading: projectViewModel.isCreating,
                          icon: Icons.add,
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

