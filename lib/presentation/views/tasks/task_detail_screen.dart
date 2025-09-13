
// // =================================================================

// // lib/presentation/views/tasks/task_detail_screen.dart
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../../viewmodels/task_viewmodel.dart';
// import '../../viewmodels/auth_viewmodel.dart';
// import '../../widgets/common/custom_app_bar.dart';
// import '../../widgets/common/loading_widget.dart';
// import '../../widgets/task/task_status_chip.dart';
// import '../../widgets/task/priority_indicator.dart';
// import '../../../core/constants/app_colors.dart';
// import '../../../core/utils/date_utils.dart';
// import '../../../core/utils/app_utils.dart';
// import '../../../core/enums/task_status.dart';
// import '../../../data/models/task_model.dart';

// class TaskDetailScreen extends StatefulWidget {
//   final String taskId;

//   const TaskDetailScreen({Key? key, required this.taskId}) : super(key: key);

//   @override
//   State<TaskDetailScreen> createState() => _TaskDetailScreenState();
// }

// class _TaskDetailScreenState extends State<TaskDetailScreen>
//     with SingleTickerProviderStateMixin {
//   late TabController _tabController;
//   TaskModel? _task;
//   final _commentController = TextEditingController();

//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: 2, vsync: this);
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       _loadData();
//     });
//   }

//   @override
//   void dispose() {
//     _tabController.dispose();
//     _commentController.dispose();
//     super.dispose();
//   }

//   Future<void> _loadData() async {
//     final taskViewModel = context.read<TaskViewModel>();
    
//     final task = await taskViewModel.getTask(widget.taskId);
//     if (task != null) {
//       setState(() {
//         _task = task;
//       });
//     }

//     await Future.wait([
//       taskViewModel.loadComments(widget.taskId),
//       taskViewModel.loadUsers(),
//     ]);
//   }

//   Future<void> _updateTaskStatus(TaskStatus newStatus) async {
//     final taskViewModel = context.read<TaskViewModel>();
//     final success = await taskViewModel.updateTaskStatus(widget.taskId, newStatus);

//     if (success) {
//       setState(() {
//         _task = _task?.copyWith(status: newStatus);
//       });
//       if (mounted) {
//         AppUtils.showSuccessSnackBar(context, 'Task status updated');
//       }
//     } else if (mounted) {
//       AppUtils.showErrorSnackBar(
//         context,
//         taskViewModel.errorMessage ?? 'Failed to update task',
//       );
//     }
//   }

//   Future<void> _addComment() async {
//     if (_commentController.text.trim().isEmpty) return;

//     final taskViewModel = context.read<TaskViewModel>();
//     final success = await taskViewModel.addComment(
//       taskId: widget.taskId,
//       content: _commentController.text.trim(),
//     );

//     if (success) {
//       _commentController.clear();
//       if (mounted) {
//         AppUtils.showSuccessSnackBar(context, 'Comment added');
//       }
//     } else if (mounted) {
//       AppUtils.showErrorSnackBar(
//         context,
//         taskViewModel.errorMessage ?? 'Failed to add comment',
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final authViewModel = context.watch<AuthViewModel>();
    
//     return Scaffold(
//       appBar: CustomAppBar(
//         title: _task?.title ?? 'Task Details',
//         actions: [
//           if (_task != null)
//             PopupMenuButton<String>(
//               onSelected: (value) {
//                 switch (value) {
//                   case 'edit':
//                     // Navigate to edit task
//                     break;
//                   case 'delete':
//                     _deleteTask();
//                     break;
//                 }
//               },
//               itemBuilder: (context) => [
//                 const PopupMenuItem(
//                   value: 'edit',
//                   child: Row(
//                     children: [
//                       Icon(Icons.edit_outlined),
//                       SizedBox(width: 8),
//                       Text('Edit Task'),
//                     ],
//                   ),
//                 ),
//                 const PopupMenuItem(
//                   value: 'delete',
//                   child: Row(
//                     children: [
//                       Icon(Icons.delete_outlined, color: AppColors.error),
//                       SizedBox(width: 8),
//                       Text('Delete Task', style: TextStyle(color: AppColors.error)),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//         ],
//       ),
//       body: _task == null
//           ? const LoadingWidget(message: 'Loading task...')
//           : Column(
//               children: [
//                 // Task Header
//                 _buildTaskHeader(),
                
//                 // Tabs
//                 TabBar(
//                   controller: _tabController,
//                   labelColor: AppColors.primaryBlue,
//                   unselectedLabelColor: AppColors.textSecondary,
//                   indicatorColor: AppColors.primaryBlue,
//                   tabs: const [
//                     Tab(text: 'Details'),
//                     Tab(text: 'Comments'),
//                   ],
//                 ),

//                 // Tab Views
//                 Expanded(
//                   child: TabBarView(
//                     controller: _tabController,
//                     children: [
//                       _buildDetailsTab(),
//                       _buildCommentsTab(),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//     );
//   }

//   Widget _buildTaskHeader() {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       color: AppColors.surface,
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Expanded(
//                 child: Text(
//                   _task!.title,
//                   style: const TextStyle(
//                     fontSize: 20,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ),
//               PriorityIndicator(priority: _task!.priority, showLabel: true),
//             ],
//           ),
//           const SizedBox(height: 8),
//           Text(
//             _task!.description,
//             style: const TextStyle(
//               fontSize: 16,
//               color: AppColors.textSecondary,
//             ),
//           ),
//           const SizedBox(height: 16),
//           Row(
//             children: [
//               TaskStatusChip(
//                 status: _task!.status,
//                 onTap: () => _showStatusChangeDialog(),
//               ),
//               const SizedBox(width: 12),
//               if (_task!.dueDate != null) ...[
//                 Container(
//                   padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                   decoration: BoxDecoration(
//                     color: AppDateUtils.isOverdue(_task!.dueDate!)
//                         ? AppColors.error.withOpacity(0.1)
//                         : AppColors.info.withOpacity(0.1),
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   child: Row(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       Icon(
//                         Icons.schedule_rounded,
//                         size: 12,
//                         color: AppDateUtils.isOverdue(_task!.dueDate!)
//                             ? AppColors.error
//                             : AppColors.info,
//                       ),
//                       const SizedBox(width: 4),
//                       Text(
//                         AppDateUtils.formatDueDate(_task!.dueDate!),
//                         style: TextStyle(
//                           fontSize: 12,
//                           color: AppDateUtils.isOverdue(_task!.dueDate!)
//                               ? AppColors.error
//                               : AppColors.info,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildDetailsTab() {
//     return SingleChildScrollView(
//       padding: const EdgeInsets.all(16),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Task Info
//           _buildInfoSection('Task Information', [
//             _buildInfoRow('Project', _getProjectName()),
//             _buildInfoRow('Assignee', _getAssigneeName()),
//             _buildInfoRow('Created', AppDateUtils.formatDateTime(_task!.createdAt)),
//             _buildInfoRow('Last Updated', AppDateUtils.formatDateTime(_task!.updatedAt)),
//             if (_task!.progress > 0)
//               _buildInfoRow('Progress', '${(_task!.progress * 100).toInt()}%'),
//           ]),
          
//           const SizedBox(height: 24),

//           // Tags
//           if (_task!.tags.isNotEmpty) ...[
//             _buildInfoSection('Tags', [
//               Wrap(
//                 spacing: 8,
//                 runSpacing: 4,
//                 children: _task!.tags.map((tag) {
//                   return Chip(
//                     label: Text(tag),
//                     backgroundColor: AppColors.primaryBlue.withOpacity(0.1),
//                     labelStyle: const TextStyle(
//                       fontSize: 12,
//                       color: AppColors.primaryBlue,
//                     ),
//                   );
//                 }).toList(),
//               ),
//             ]),
//             const SizedBox(height: 24),
//           ],

//           // Progress Slider
//           if (_task!.status == TaskStatus.inProgress) ...[
//             _buildInfoSection('Progress', [
//               Slider(
//                 value: _task!.progress,
//                 onChanged: (value) => _updateProgress(value),
//                 divisions: 10,
//                 label: '${(_task!.progress * 100).toInt()}%',
//               ),
//             ]),
//           ],
//         ],
//       ),
//     );
//   }

//   Widget _buildCommentsTab() {
//     return Column(
//       children: [
//         // Comments List
//         Expanded(
//           child: Consumer<TaskViewModel>(
//             builder: (context, taskViewModel, child) {
//               if (taskViewModel.isLoadingComments) {
//                 return const LoadingWidget(message: 'Loading comments...');
//               }

//               final comments = taskViewModel.comments;
//               if (comments.isEmpty) {
//                 return const Center(
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Icon(Icons.comment_outlined, size: 64, color: Colors.grey),
//                       SizedBox(height: 16),
//                       Text(
//                         'No comments yet',
//                         style: TextStyle(fontSize: 16, color: Colors.grey),
//                       ),
//                       Text(
//                         'Be the first to comment!',
//                         style: TextStyle(fontSize: 14, color: Colors.grey),
//                       ),
//                     ],
//                   ),
//                 );
//               }

//               return ListView.builder(
//                 padding: const EdgeInsets.all(16),
//                 itemCount: comments.length,
//                 itemBuilder: (context, index) {
//                   final comment = comments[index];
//                   final author = taskViewModel.users
//                       .firstWhere(
//                         (u) => u.id == comment.authorId,
//                         orElse: () => null,
//                       );

//                   return Card(
//                     margin: const EdgeInsets.only(bottom: 12),
//                     child: Padding(
//                       padding: const EdgeInsets.all(12),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Row(
//                             children: [
//                               CircleAvatar(
//                                 radius: 16,
//                                 backgroundColor: AppColors.primaryBlue.withOpacity(0.1),
//                                 child: Text(
//                                   author?.name.substring(0, 1).toUpperCase() ?? '?',
//                                   style: const TextStyle(
//                                     fontWeight: FontWeight.bold,
//                                     color: AppColors.primaryBlue,
//                                   ),
//                                 ),
//                               ),
//                               const SizedBox(width: 8),
//                               Expanded(
//                                 child: Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     Text(
//                                       author?.name ?? 'Unknown User',
//                                       style: const TextStyle(fontWeight: FontWeight.bold),
//                                     ),
//                                     Text(
//                                       AppDateUtils.formatRelativeTime(comment.createdAt),
//                                       style: const TextStyle(
//                                         fontSize: 12,
//                                         color: AppColors.textSecondary,
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             ],
//                           ),
//                           const SizedBox(height: 8),
//                           Text(comment.content),
//                         ],
//                       ),
//                     ),
//                   );
//                 },
//               );
//             },
//           ),
//         ),

//         // Comment Input
//         Container(
//           padding: const EdgeInsets.all(16),
//           decoration: const BoxDecoration(
//             border: Border(top: BorderSide(color: AppColors.borderLight)),
//           ),
//           child: Row(
//             children: [
//               Expanded(
//                 child: TextField(
//                   controller: _commentController,
//                   decoration: const InputDecoration(
//                     hintText: 'Add a comment...',
//                     border: OutlineInputBorder(),
//                     contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//                   ),
//                   maxLines: null,
//                 ),
//               ),
//               const SizedBox(width: 8),
//               IconButton(
//                 onPressed: _addComment,
//                 icon: const Icon(Icons.send_rounded),
//                 color: AppColors.primaryBlue,
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildInfoSection(String title, List<Widget> children) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           title,
//           style: const TextStyle(
//             fontSize: 18,
//             fontWeight: FontWeight.bold,
//             color: AppColors.textPrimary,
//           ),
//         ),
//         const SizedBox(height: 12),
//         Card(
//           child: Padding(
//             padding: const EdgeInsets.all(16),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: children,
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildInfoRow(String label, String value) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 4),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           SizedBox(
//             width: 100,
//             child: Text(
//               '$label:',
//               style: const TextStyle(
//                 fontWeight: FontWeight.w600,
//                 color: AppColors.textSecondary,
//               ),
//             ),
//           ),
//           Expanded(
//             child: Text(
//               value,
//               style: const TextStyle(color: AppColors.textPrimary),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   String _getProjectName() {
//     final taskViewModel = context.read<TaskViewModel>();
//     return taskViewModel.getProjectName(_task!.projectId);
//   }

//   String _getAssigneeName() {
//     final taskViewModel = context.read<TaskViewModel>();
//     return taskViewModel.getAssigneeName(_task!.assigneeId);
//   }

//   void _showStatusChangeDialog() {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Change Status'),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: TaskStatus.values.map((status) {
//             return ListTile(
//               title: Text(status.displayName),
//               leading: Radio<TaskStatus>(
//                 value: status,
//                 groupValue: _task!.status,
//                 onChanged: (newStatus) {
//                   if (newStatus != null) {
//                     Navigator.pop(context);
//                     _updateTaskStatus(newStatus);
//                   }
//                 },
//               ),
//             );
//           }).toList(),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('Cancel'),
//           ),
//         ],
//       ),
//     );
//   }

//   Future<void> _updateProgress(double progress) async {
//     final taskViewModel = context.read<TaskViewModel>();
//     final success = await taskViewModel.updateTask(widget.taskId, progress: progress);

//     if (success) {
//       setState(() {
//         _task = _task?.copyWith(progress: progress);
//       });
//     }
//   }

//   Future<void> _deleteTask() async {
//     final confirmed = await AppUtils.showConfirmDialog(
//       context,
//       title: 'Delete Task',
//       content: 'Are you sure you want to delete this task? This action cannot be undone.',
//       confirmText: 'Delete',
//     );

//     if (confirmed) {
//       final taskViewModel = context.read<TaskViewModel>();
//       final success = await taskViewModel.deleteTask(widget.taskId);

//       if (success && mounted) {
//         AppUtils.showSuccessSnackBar(context, 'Task deleted successfully');
//         Navigator.pop(context);
//       } else if (mounted) {
//         AppUtils.showErrorSnackBar(
//           context,
//           taskViewModel.errorMessage ?? 'Failed to delete task',
//         );
//       }
//     }
//   }
// }



//2


// lib/presentation/views/tasks/task_detail_screen.dart
import 'package:flowence/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/task_viewmodel.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../widgets/common/custom_app_bar.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/task/task_status_chip.dart';
import '../../widgets/task/priority_indicator.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/date_utils.dart';
import '../../../core/utils/app_utils.dart';
import '../../../core/enums/task_status.dart';
import '../../../data/models/task_model.dart';
import '../../../data/models/user_model.dart';
import '../../../core/enums/user_role.dart';

class TaskDetailScreen extends StatefulWidget {
  final String taskId;

  const TaskDetailScreen({Key? key, required this.taskId}) : super(key: key);

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  TaskModel? _task;
  final _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final taskViewModel = context.read<TaskViewModel>();
    
    final task = await taskViewModel.getTask(widget.taskId);
    if (task != null) {
      setState(() {
        _task = task;
      });
    }

    await Future.wait([
      taskViewModel.loadComments(widget.taskId),
      taskViewModel.loadUsers(),
    ]);
  }

  Future<void> _updateTaskStatus(TaskStatus newStatus) async {
    final taskViewModel = context.read<TaskViewModel>();
    final success = await taskViewModel.updateTaskStatus(widget.taskId, newStatus);

    if (success) {
      setState(() {
        _task = _task?.copyWith(status: newStatus);
      });
      if (mounted) {
        AppUtils.showSuccessSnackBar(context, 'Task status updated');
      }
    } else if (mounted) {
      AppUtils.showErrorSnackBar(
        context,
        taskViewModel.errorMessage ?? 'Failed to update task',
      );
    }
  }

  Future<void> _addComment() async {
    if (_commentController.text.trim().isEmpty) return;

    final taskViewModel = context.read<TaskViewModel>();
    final success = await taskViewModel.addComment(
      taskId: widget.taskId,
      content: _commentController.text.trim(),
    );

    if (success) {
      _commentController.clear();
      if (mounted) {
        AppUtils.showSuccessSnackBar(context, 'Comment added');
      }
    } else if (mounted) {
      AppUtils.showErrorSnackBar(
        context,
        taskViewModel.errorMessage ?? 'Failed to add comment',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authViewModel = context.watch<AuthViewModel>();
    
    return Scaffold(
      appBar: CustomAppBar(
        title: _task?.title ?? 'Task Details',
        actions: [
          if (_task != null)
             PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'edit':
                  Navigator.pushNamed(
                    context,
                    AppRoutes.editTask,
                    arguments: widget.taskId,
                  );
                  break;
                case 'delete':
                  _deleteTask();
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit_outlined),
                    SizedBox(width: 8),
                    Text('Edit Task'),
                  ],
                ),
              ),
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
      body: _task == null
          ? const LoadingWidget(message: 'Loading task...')
          : Column(
              children: [
                // Task Header
                _buildTaskHeader(),
                
                // Tabs
                TabBar(
                  controller: _tabController,
                  labelColor: AppColors.primaryBlue,
                  unselectedLabelColor: AppColors.textSecondary,
                  indicatorColor: AppColors.primaryBlue,
                  tabs: const [
                    Tab(text: 'Details'),
                    Tab(text: 'Comments'),
                  ],
                ),

                // Tab Views
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildDetailsTab(),
                      _buildCommentsTab(),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildTaskHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: AppColors.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  _task!.title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              PriorityIndicator(priority: _task!.priority, showLabel: true),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _task!.description,
            style: const TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              TaskStatusChip(
                status: _task!.status,
                onTap: () => _showStatusChangeDialog(),
              ),
              const SizedBox(width: 12),
              if (_task!.dueDate != null) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppDateUtils.isOverdue(_task!.dueDate!)
                        ? AppColors.error.withOpacity(0.1)
                        : AppColors.info.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.schedule_rounded,
                        size: 12,
                        color: AppDateUtils.isOverdue(_task!.dueDate!)
                            ? AppColors.error
                            : AppColors.info,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        AppDateUtils.formatDueDate(_task!.dueDate!),
                        style: TextStyle(
                          fontSize: 12,
                          color: AppDateUtils.isOverdue(_task!.dueDate!)
                              ? AppColors.error
                              : AppColors.info,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Task Info
          _buildInfoSection('Task Information', [
            _buildInfoRow('Project', _getProjectName()),
            _buildInfoRow('Assignee', _getAssigneeName()),
            _buildInfoRow('Created', AppDateUtils.formatDateTime(_task!.createdAt)),
            _buildInfoRow('Last Updated', AppDateUtils.formatDateTime(_task!.updatedAt)),
            if (_task!.progress > 0)
              _buildInfoRow('Progress', '${(_task!.progress * 100).toInt()}%'),
          ]),
          
          const SizedBox(height: 24),

          // Tags
          if (_task!.tags.isNotEmpty) ...[
            _buildInfoSection('Tags', [
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: _task!.tags.map((tag) {
                  return Chip(
                    label: Text(tag),
                    backgroundColor: AppColors.primaryBlue.withOpacity(0.1),
                    labelStyle: const TextStyle(
                      fontSize: 12,
                      color: AppColors.primaryBlue,
                    ),
                  );
                }).toList(),
              ),
            ]),
            const SizedBox(height: 24),
          ],

          // Progress Slider
          if (_task!.status == TaskStatus.inProgress) ...[
            _buildInfoSection('Progress', [
              Slider(
                value: _task!.progress,
                onChanged: (value) => _updateProgress(value),
                divisions: 10,
                label: '${(_task!.progress * 100).toInt()}%',
              ),
            ]),
          ],
        ],
      ),
    );
  }

  Widget _buildCommentsTab() {
    return Column(
      children: [
        // Comments List
        Expanded(
          child: Consumer<TaskViewModel>(
            builder: (context, taskViewModel, child) {
              if (taskViewModel.isLoadingComments) {
                return const LoadingWidget(message: 'Loading comments...');
              }

              final comments = taskViewModel.comments;
              if (comments.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.comment_outlined, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'No comments yet',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                      Text(
                        'Be the first to comment!',
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: comments.length,
                itemBuilder: (context, index) {
                  final comment = comments[index];
                  final author = taskViewModel.users.firstWhere(
                    (u) => u.id == comment.authorId,
                    orElse: () => UserModel(
                      id: comment.authorId,
                      name: 'Unknown User',
                      email: '',
                      role: UserRole.teamMember,
                      createdAt: DateTime.now(),
                    ),
                  );

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 16,
                                backgroundColor: AppColors.primaryBlue.withOpacity(0.1),
                                child: Text(
                                  author.name.substring(0, 1).toUpperCase(),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primaryBlue,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      author.name,
                                      style: const TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      AppDateUtils.formatRelativeTime(comment.createdAt),
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(comment.content),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),

        // Comment Input
        Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            border: Border(top: BorderSide(color: AppColors.borderLight)),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _commentController,
                  decoration: const InputDecoration(
                    hintText: 'Add a comment...',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  maxLines: null,
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: _addComment,
                icon: const Icon(Icons.send_rounded),
                color: AppColors.primaryBlue,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: AppColors.textPrimary),
            ),
          ),
        ],
      ),
    );
  }

  String _getProjectName() {
    final taskViewModel = context.read<TaskViewModel>();
    return taskViewModel.getProjectName(_task!.projectId);
  }

  String _getAssigneeName() {
    final taskViewModel = context.read<TaskViewModel>();
    return taskViewModel.getAssigneeName(_task!.assigneeId);
  }

  void _showStatusChangeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Status'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: TaskStatus.values.map((status) {
            return ListTile(
              title: Text(status.displayName),
              leading: Radio<TaskStatus>(
                value: status,
                groupValue: _task!.status,
                onChanged: (newStatus) {
                  if (newStatus != null) {
                    Navigator.pop(context);
                    _updateTaskStatus(newStatus);
                  }
                },
              ),
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Future<void> _updateProgress(double progress) async {
    final taskViewModel = context.read<TaskViewModel>();
    final success = await taskViewModel.updateTask(widget.taskId, progress: progress);

    if (success) {
      setState(() {
        _task = _task?.copyWith(progress: progress);
      });
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
      } else if (mounted) {
        AppUtils.showErrorSnackBar(
          context,
          taskViewModel.errorMessage ?? 'Failed to delete task',
        );
      }
    }
  }
}