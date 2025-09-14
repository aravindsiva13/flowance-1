
// lib/presentation/widgets/task/task_status_chip.dart

import 'package:flutter/material.dart';
import '../../../core/enums/task_status.dart';
import '../../../core/constants/app_colors.dart';

class TaskStatusChip extends StatelessWidget {
  final TaskStatus status;
  final VoidCallback? onTap;
  
  const TaskStatusChip({
    Key? key,
    required this.status,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: _getStatusColor(status).withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _getStatusColor(status).withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: _getStatusColor(status),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              status.displayName,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: _getStatusColor(status),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(TaskStatus status) {
    switch (status) {
      case TaskStatus.toDo:
        return AppColors.statusToDo;
      case TaskStatus.inProgress:
        return AppColors.statusInProgress;
      case TaskStatus.inReview:
        return AppColors.statusInReview;
      case TaskStatus.done:
        return AppColors.statusDone;
    }
  }
}
