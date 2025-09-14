
// lib/presentation/widgets/task/task_card.dart

import 'package:flutter/material.dart';
import '../../../data/models/task_model.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/date_utils.dart';
import 'task_status_chip.dart';
import 'priority_indicator.dart';

class TaskCard extends StatelessWidget {
  final TaskModel task;
  final VoidCallback? onTap;
  final bool showProject;
  final bool showAssignee;
  
  const TaskCard({
    Key? key,
    required this.task,
    this.onTap,
    this.showProject = false,
    this.showAssignee = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      task.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  PriorityIndicator(priority: task.priority),
                ],
              ),
              
              if (task.description.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  task.description,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              
              const SizedBox(height: 12),
              
              Row(
                children: [
                  TaskStatusChip(status: task.status),
                  const Spacer(),
                  
                  if (task.dueDate != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppDateUtils.isOverdue(task.dueDate!) 
                            ? AppColors.error.withOpacity(0.1)
                            : AppColors.warning.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.schedule_rounded,
                            size: 12,
                            color: AppDateUtils.isOverdue(task.dueDate!) 
                                ? AppColors.error 
                                : AppColors.warning,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            AppDateUtils.formatDueDate(task.dueDate!),
                            style: TextStyle(
                              fontSize: 12,
                              color: AppDateUtils.isOverdue(task.dueDate!) 
                                  ? AppColors.error 
                                  : AppColors.warning,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              
              if (task.progress > 0) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: LinearProgressIndicator(
                        value: task.progress,
                        backgroundColor: AppColors.borderLight,
                        valueColor: const AlwaysStoppedAnimation(AppColors.success),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${(task.progress * 100).toInt()}%',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
