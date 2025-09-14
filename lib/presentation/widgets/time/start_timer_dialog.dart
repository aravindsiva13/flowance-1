// // lib/presentation/widgets/time/start_timer_dialog.dart

// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../../viewmodels/time_tracking_viewmodel.dart';
// import '../../../data/models/task_model.dart';
// import '../../../core/constants/app_colors.dart';
// import '../../../core/utils/validation_utils.dart';

// class StartTimerDialog extends StatefulWidget {
//   final String? preSelectedTaskId;
//   final String? preSelectedProjectId;
  
//   const StartTimerDialog({
//     Key? key,
//     this.preSelectedTaskId,
//     this.preSelectedProjectId,
//   }) : super(key: key);

//   @override
//   State<StartTimerDialog> createState() => _StartTimerDialogState();
// }

// class _StartTimerDialogState extends State<StartTimerDialog> {
//   final _formKey = GlobalKey<FormState>();
//   final _descriptionController = TextEditingController();
  
//   String? _selectedProjectId;
//   String? _selectedTaskId;
  
//   @override
//   void initState() {
//     super.initState();
//     _selectedProjectId = widget.preSelectedProjectId;
//     _selectedTaskId = widget.preSelectedTaskId;
    
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       final timeTrackingVM = context.read<TimeTrackingViewModel>();
//       if (timeTrackingVM.projects.isEmpty || timeTrackingVM.tasks.isEmpty) {
//         timeTrackingVM.loadSupportingData();
//       }
//     });
//   }

//   @override
//   void dispose() {
//     _descriptionController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Consumer<TimeTrackingViewModel>(
//       builder: (context, timeTrackingVM, child) {
//         return AlertDialog(
//           title: const Row(
//             children: [
//               Icon(Icons.play_circle_rounded, color: AppColors.primaryBlue),
//               SizedBox(width: 8),
//               Text('Start Timer'),
//             ],
//           ),
//           content: Form(
//             key: _formKey,
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 // Project Selection
//                 const Text(
//                   'Project',
//                   style: TextStyle(fontWeight: FontWeight.w500),
//                 ),
//                 const SizedBox(height: 8),
//                 DropdownButtonFormField<String>(
//                   value: _selectedProjectId,
//                   decoration: const InputDecoration(
//                     border: OutlineInputBorder(),
//                     hintText: 'Select project',
//                   ),
//                   validator: (value) {
//                     if (value == null || value.isEmpty) {
//                       return 'Please select a project';
//                     }
//                     return null;
//                   },
//                   items: timeTrackingVM.projects.map((project) {
//                     return DropdownMenuItem<String>(
//                       value: project.id,
//                       child: Text(project.name),
//                     );
//                   }).toList(),
//                   onChanged: (value) {
//                     setState(() {
//                       _selectedProjectId = value;
//                       _selectedTaskId = null; // Reset task selection
//                     });
//                   },
//                 ),
//                 const SizedBox(height: 16),
                
//                 // Task Selection
//                 const Text(
//                   'Task',
//                   style: TextStyle(fontWeight: FontWeight.w500),
//                 ),
//                 const SizedBox(height: 8),
//                 DropdownButtonFormField<String>(
//                   value: _selectedTaskId,
//                   decoration: const InputDecoration(
//                     border: OutlineInputBorder(),
//                     hintText: 'Select task',
//                   ),
//                   validator: (value) {
//                     if (value == null || value.isEmpty) {
//                       return 'Please select a task';
//                     }
//                     return null;
//                   },
//                   items: _getTasksForProject().map<DropdownMenuItem<String>>((task) {
//                     return DropdownMenuItem<String>(
//                       value: task.id,
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         mainAxisSize: MainAxisSize.min,
//                         children: [
//                           Text(
//                             task.title,
//                             style: const TextStyle(fontWeight: FontWeight.w500),
//                           ),
//                           if (task.estimatedTimeHours != null)
//                             Text(
//                               'Est: ${task.estimatedTimeHours!.toStringAsFixed(1)}h',
//                               style: const TextStyle(
//                                 fontSize: 12,
//                                 color: Colors.grey,
//                               ),
//                             ),
//                         ],
//                       ),
//                     );
//                   }).toList(),
//                   onChanged: (value) {
//                     setState(() {
//                       _selectedTaskId = value;
//                     });
//                   },
//                 ),
//                 const SizedBox(height: 16),
                
//                 // Description
//                 const Text(
//                   'Description',
//                   style: TextStyle(fontWeight: FontWeight.w500),
//                 ),
//                 const SizedBox(height: 8),
//                 TextFormField(
//                   controller: _descriptionController,
//                   decoration: const InputDecoration(
//                     border: OutlineInputBorder(),
//                     hintText: 'What are you working on?',
//                   ),
//                   validator: ValidationUtils.validateRequired,
//                   maxLines: 3,
//                   textCapitalization: TextCapitalization.sentences,
//                 ),
                
//                 if (timeTrackingVM.hasActiveTimer) ...[
//                   const SizedBox(height: 16),
//                   Container(
//                     padding: const EdgeInsets.all(12),
//                     decoration: BoxDecoration(
//                       color: AppColors.warning.withOpacity(0.1),
//                       borderRadius: BorderRadius.circular(8),
//                       border: Border.all(color: AppColors.warning.withOpacity(0.3)),
//                     ),
//                     child: const Row(
//                       children: [
//                         Icon(Icons.warning_rounded, 
//                              color: AppColors.warning, size: 20),
//                         SizedBox(width: 8),
//                         Expanded(
//                           child: Text(
//                             'Starting a new timer will stop your current timer.',
//                             style: TextStyle(fontSize: 12),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ],
//             ),
//           ),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.of(context).pop(),
//               child: const Text('Cancel'),
//             ),
//             ElevatedButton(
//               onPressed: timeTrackingVM.isUpdating ? null : _startTimer,
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: AppColors.primaryBlue,
//                 foregroundColor: Colors.white,
//               ),
//               child: timeTrackingVM.isUpdating
//                   ? const SizedBox(
//                       width: 16,
//                       height: 16,
//                       child: CircularProgressIndicator(
//                         strokeWidth: 2,
//                         valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
//                       ),
//                     )
//                   : const Text('Start Timer'),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   List<TaskModel> _getTasksForProject() {
//     final timeTrackingVM = context.read<TimeTrackingViewModel>();
//     if (_selectedProjectId == null) return [];
    
//     return timeTrackingVM.tasks
//         .where((task) => task.projectId == _selectedProjectId)
//         .toList();
//   }

//   Future<void> _startTimer() async {
//     if (!_formKey.currentState!.validate()) return;
    
//     final timeTrackingVM = context.read<TimeTrackingViewModel>();
    
//     final success = await timeTrackingVM.startTimer(
//       taskId: _selectedTaskId!,
//       description: _descriptionController.text.trim(),
//     );
    
//     if (success && mounted) {
//       Navigator.of(context).pop(true);
//     } else if (mounted) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(timeTrackingVM.errorMessage ?? 'Failed to start timer'),
//           backgroundColor: AppColors.error,
//         ),
//       );
//     }
//   }
// }


//2


// lib/presentation/widgets/time/start_timer_dialog.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/time_tracking_viewmodel.dart';
import '../../../data/models/task_model.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/validation_utils.dart';

class StartTimerDialog extends StatefulWidget {
  final String? preSelectedTaskId;
  final String? preSelectedProjectId;
  
  const StartTimerDialog({
    Key? key,
    this.preSelectedTaskId,
    this.preSelectedProjectId,
  }) : super(key: key);

  @override
  State<StartTimerDialog> createState() => _StartTimerDialogState();
}

class _StartTimerDialogState extends State<StartTimerDialog> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  
  String? _selectedProjectId;
  String? _selectedTaskId;
  
  @override
  void initState() {
    super.initState();
    _selectedProjectId = widget.preSelectedProjectId;
    _selectedTaskId = widget.preSelectedTaskId;
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final timeTrackingVM = context.read<TimeTrackingViewModel>();
      if (timeTrackingVM.projects.isEmpty || timeTrackingVM.tasks.isEmpty) {
        timeTrackingVM.loadSupportingData();
      }
    });
  }

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
              Icon(Icons.play_circle_rounded, color: AppColors.primaryBlue),
              SizedBox(width: 8),
              Text('Start Timer'),
            ],
          ),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Project Selection
                const Text(
                  'Project',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _selectedProjectId,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Select project',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select a project';
                    }
                    return null;
                  },
                  items: timeTrackingVM.projects.map((project) {
                    return DropdownMenuItem<String>(
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
                ),
                const SizedBox(height: 16),
                
                // Task Selection
                const Text(
                  'Task',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _selectedTaskId,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Select task',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select a task';
                    }
                    return null;
                  },
                  items: _getTasksForProject().map<DropdownMenuItem<String>>((task) {
                    return DropdownMenuItem<String>(
                      value: task.id,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            task.title,
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                          if (task.estimatedTimeHours != null)
                            Text(
                              'Est: ${task.formattedEstimatedTime}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedTaskId = value;
                    });
                  },
                ),
                const SizedBox(height: 16),
                
                // Description
                const Text(
                  'Description',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'What are you working on?',
                  ),
                  validator: ValidationUtils.validateRequired,
                  maxLines: 3,
                  textCapitalization: TextCapitalization.sentences,
                ),
                
                if (timeTrackingVM.hasActiveTimer) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.warning.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.warning.withOpacity(0.3)),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.warning_rounded, 
                             color: AppColors.warning, size: 20),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Starting a new timer will stop your current timer.',
                            style: TextStyle(fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: timeTrackingVM.isUpdating ? null : _startTimer,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                foregroundColor: Colors.white,
              ),
              child: timeTrackingVM.isUpdating
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text('Start Timer'),
            ),
          ],
        );
      },
    );
  }

  List<TaskModel> _getTasksForProject() {
    final timeTrackingVM = context.read<TimeTrackingViewModel>();
    if (_selectedProjectId == null) return [];
    
    return timeTrackingVM.tasks
        .where((task) => task.projectId == _selectedProjectId)
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
      Navigator.of(context).pop(true);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(timeTrackingVM.errorMessage ?? 'Failed to start timer'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }
}