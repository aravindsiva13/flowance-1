
// lib/presentation/widgets/task/priority_indicator.dart

import 'package:flutter/material.dart';
import '../../../core/enums/task_priority.dart';
import '../../../core/constants/app_colors.dart';

class PriorityIndicator extends StatelessWidget {
  final TaskPriority priority;
  final bool showLabel;
  
  const PriorityIndicator({
    Key? key,
    required this.priority,
    this.showLabel = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: showLabel ? 8 : 4,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: _getPriorityColor(priority).withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getPriorityIcon(priority),
            size: 12,
            color: _getPriorityColor(priority),
          ),
          if (showLabel) ...[
            const SizedBox(width: 4),
            Text(
              priority.displayName,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: _getPriorityColor(priority),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Color _getPriorityColor(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.low:
        return AppColors.priorityLow;
      case TaskPriority.medium:
        return AppColors.priorityMedium;
      case TaskPriority.high:
        return AppColors.priorityHigh;
      case TaskPriority.urgent:
        return AppColors.priorityUrgent;
    }
  }

  IconData _getPriorityIcon(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.low:
        return Icons.keyboard_arrow_down_rounded;
      case TaskPriority.medium:
        return Icons.remove_rounded;
      case TaskPriority.high:
        return Icons.keyboard_arrow_up_rounded;
      case TaskPriority.urgent:
        return Icons.keyboard_double_arrow_up_rounded;
    }
  }
}
