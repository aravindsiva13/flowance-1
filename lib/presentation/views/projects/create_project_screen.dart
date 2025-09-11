
// lib/presentation/views/projects/create_project_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/project_viewmodel.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_text_field.dart';
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
      context.read<ProjectViewModel>().loadUsers();
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
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDueDate ?? DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (selectedDate != null) {
      setState(() {
        _selectedDueDate = selectedDate;
        _dueDateController.text = selectedDate.toString().substring(0, 10);
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

    if (success && mounted) {
      Navigator.pop(context);
      AppUtils.showSuccessSnackBar(context, 'Project created successfully!');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Project'),
      ),
      body: Consumer<ProjectViewModel>(
        builder: (context, projectViewModel, child) {
          return SingleChildScrollView(
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
                    prefixIcon: Icons.work_rounded,
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Description
                  CustomTextField(
                    label: 'Description',
                    hint: 'Describe your project...',
                    controller: _descriptionController,
                    validator: (value) => ValidationUtils.validateDescription(value, required: true),
                    prefixIcon: Icons.description_rounded,
                    maxLines: 3,
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Status Dropdown
                  const Text(
                    'Status',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<ProjectStatus>(
                    value: _selectedStatus,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      prefixIcon: const Icon(Icons.flag_rounded),
                    ),
                    items: ProjectStatus.values.map((status) {
                      return DropdownMenuItem(
                        value: status,
                        child: Text(status.displayName),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _selectedStatus = value;
                        });
                      }
                    },
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Due Date
                  CustomTextField(
                    label: 'Due Date (Optional)',
                    controller: _dueDateController,
                    prefixIcon: Icons.calendar_today_rounded,
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
                  
                  Container(
                    height: 200,
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.borderLight),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: projectViewModel.users.isEmpty
                        ? const Center(child: CircularProgressIndicator())
                        : ListView.builder(
                            itemCount: projectViewModel.users.length,
                            itemBuilder: (context, index) {
                              final user = projectViewModel.users[index];
                              final isSelected = _selectedMemberIds.contains(user.id);
                              
                              return CheckboxListTile(
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
                                title: Text(user.name),
                                subtitle: Text(user.email),
                                secondary: CircleAvatar(
                                  backgroundColor: AppColors.primaryBlue.withOpacity(0.1),
                                  child: Text(
                                    user.name.substring(0, 1).toUpperCase(),
                                    style: const TextStyle(
                                      color: AppColors.primaryBlue,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Error Message
                  if (projectViewModel.errorMessage != null)
                    Container(
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: AppColors.error.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppColors.error.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error, color: AppColors.error),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              projectViewModel.errorMessage!,
                              style: const TextStyle(color: AppColors.error),
                            ),
                          ),
                        ],
                      ),
                    ),
                  
                  // Create Button
                  CustomButton(
                    text: 'Create Project',
                    onPressed: _createProject,
                    isLoading: projectViewModel.isCreating,
                    icon: Icons.create_rounded,
                    width: double.infinity,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}