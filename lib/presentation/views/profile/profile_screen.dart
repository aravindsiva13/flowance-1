// lib/presentation/views/profile/profile_screen.dart - COMPLETE CORRECTED VERSION
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/user_viewmodel.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../../routes/app_routes.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/validation_utils.dart';
import '../../../core/utils/app_utils.dart';
import '../../../core/enums/user_role.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUserData();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _loadUserData() {
    final authViewModel = context.read<AuthViewModel>();
    final user = authViewModel.currentUser;
    if (user != null) {
      _nameController.text = user.name;
      _emailController.text = user.email;
    }
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;

    final authViewModel = context.read<AuthViewModel>();
    final success = await authViewModel.updateProfile(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
    );

    if (success) {
      setState(() {
        _isEditing = false;
      });
      if (mounted) {
        AppUtils.showSuccessSnackBar(context, 'Profile updated successfully');
      }
    } else if (mounted) {
      AppUtils.showErrorSnackBar(
        context,
        authViewModel.errorMessage ?? 'Failed to update profile',
      );
    }
  }

  Future<void> _logout() async {
    final confirmed = await AppUtils.showConfirmDialog(
      context,
      title: 'Logout',
      content: 'Are you sure you want to logout?',
      confirmText: 'Logout',
    );

    if (confirmed) {
      final authViewModel = context.read<AuthViewModel>();
      await authViewModel.logout();
      
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.login,
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: Colors.white,
        actions: [
          if (!_isEditing)
            IconButton(
              onPressed: () {
                setState(() {
                  _isEditing = true;
                });
              },
              icon: const Icon(Icons.edit_rounded),
            ),
        ],
      ),
      body: Consumer<AuthViewModel>(
        builder: (context, authViewModel, child) {
          final user = authViewModel.currentUser;
          
          if (user == null) {
            return const LoadingWidget(message: 'Loading profile...');
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  // Profile Picture
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primaryBlue.withOpacity(0.1),
                      border: Border.all(
                        color: AppColors.primaryBlue.withOpacity(0.2),
                        width: 2,
                      ),
                    ),
                    child: user.avatarUrl != null
                        ? ClipOval(
                            child: Image.network(
                              user.avatarUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  _buildDefaultAvatar(user.name),
                            ),
                          )
                        : _buildDefaultAvatar(user.name),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Role Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.primaryBlue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppColors.primaryBlue.withOpacity(0.3),
                      ),
                    ),
                    child: Text(
                      user.role.displayName,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryBlue,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Name Field
                  CustomTextField(
                    label: 'Full Name',
                    controller: _nameController,
                    validator: ValidationUtils.validateName,
                    prefixIcon: Icons.person_rounded,
                    enabled: _isEditing,
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Email Field
                  CustomTextField(
                    label: 'Email',
                    controller: _emailController,
                    validator: ValidationUtils.validateEmail,
                    prefixIcon: Icons.email_rounded,
                    keyboardType: TextInputType.emailAddress,
                    enabled: _isEditing,
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Action Buttons
                  if (_isEditing) ...[
                    Row(
                      children: [
                        Expanded(
                          child: CustomButton(
                            text: 'Cancel',
                            onPressed: () {
                              setState(() {
                                _isEditing = false;
                              });
                              _loadUserData(); // Reset form
                            },
                            isOutlined: true,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: CustomButton(
                            text: 'Save Changes',
                            onPressed: _updateProfile,
                            isLoading: authViewModel.isLoading,
                            icon: Icons.save_rounded,
                          ),
                        ),
                      ],
                    ),
                  ] else ...[
                    // Profile Stats
                    const SizedBox(height: 16),
                    _buildProfileStats(user),
                    const SizedBox(height: 32),
                    
                    // Account Actions
                    _buildAccountActions(),
                  ],
                  
                  // Error Message
                  if (authViewModel.errorMessage != null) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
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
                              authViewModel.errorMessage!,
                              style: const TextStyle(color: AppColors.error),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDefaultAvatar(String name) {
    return Icon(
      Icons.person_rounded,
      size: 60,
      color: AppColors.primaryBlue.withOpacity(0.7),
    );
  }

  Widget _buildProfileStats(user) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Account Information',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            
            _buildInfoRow(
              'Member Since',
              '${user.createdAt.day}/${user.createdAt.month}/${user.createdAt.year}',
              Icons.calendar_today_rounded,
            ),
            
            if (user.lastLoginAt != null)
              _buildInfoRow(
                'Last Login',
                '${user.lastLoginAt!.day}/${user.lastLoginAt!.month}/${user.lastLoginAt!.year}',
                Icons.login_rounded,
              ),
            
            _buildInfoRow(
              'Role',
              user.role.displayName,
              Icons.badge_rounded,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: AppColors.textSecondary,
          ),
          const SizedBox(width: 8),
          Text(
            '$label:',
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountActions() {
    return Column(
      children: [
        // Permissions Card (for reference)
        Consumer<AuthViewModel>(
          builder: (context, authViewModel, child) {
            if (authViewModel.currentUser?.role == UserRole.teamMember) {
              return const SizedBox.shrink();
            }
            
            return Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Permissions',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    Builder(
                      builder: (context) {
                        final permissions = <String>[];
                        
                        if (authViewModel.hasPermission(Permission.createProject)) {
                          permissions.add('Create Projects');
                        }
                        if (authViewModel.hasPermission(Permission.deleteProject)) {
                          permissions.add('Delete Projects');
                        }
                        if (authViewModel.hasPermission(Permission.manageUsers)) {
                          permissions.add('Manage Users');
                        }
                        if (authViewModel.hasPermission(Permission.assignTasks)) {
                          permissions.add('Assign Tasks');
                        }
                        if (authViewModel.hasPermission(Permission.viewAllProjects)) {
                          permissions.add('View All Projects');
                        }
                        if (authViewModel.hasPermission(Permission.exportData)) {
                          permissions.add('Export Data');
                        }
                        
                        return Wrap(
                          spacing: 8,
                          runSpacing: 4,
                          children: permissions.map((permission) => Chip(
                            label: Text(
                              permission,
                              style: const TextStyle(fontSize: 12),
                            ),
                            backgroundColor: AppColors.success.withOpacity(0.1),
                            side: BorderSide(
                              color: AppColors.success.withOpacity(0.3),
                            ),
                          )).toList(),
                        );
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        
        const SizedBox(height: 16),
        
        // Logout Button
        CustomButton(
          text: 'Logout',
          onPressed: _logout,
          backgroundColor: AppColors.error,
          icon: Icons.logout_rounded,
          width: double.infinity,
        ),
      ],
    );
  }
}