// lib/presentation/widgets/time/time_entry_card.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/models/time_entry_model.dart';
import '../../viewmodels/time_tracking_viewmodel.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/date_utils.dart';

class TimeEntryCard extends StatelessWidget {
  final TimeEntryModel entry;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool showTaskName;
  final bool showProjectName;
  final bool showDate;
  final bool isCompact;

  const TimeEntryCard({
    Key? key,
    required this.entry,
    this.onEdit,
    this.onDelete,
    this.showTaskName = true,
    this.showProjectName = false,
    this.showDate = false,
    this.isCompact = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 1,
      child: InkWell(
        onTap: onEdit,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: EdgeInsets.all(isCompact ? 12 : 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row
              Row(
                children: [
                  // Type indicator
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: _getTypeColor().withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      entry.type.displayName,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: _getTypeColor(),
                      ),
                    ),
                  ),
                  
                  const SizedBox(width: 8),
                  
                  // Active indicator
                  if (entry.isActive) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.success.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: AppColors.success,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Text(
                            'ACTIVE',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: AppColors.success,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  
                  const Spacer(),
                  
                  // Duration
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primaryBlue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      entry.formattedDuration,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryBlue,
                      ),
                    ),
                  ),
                  
                  // Menu button
                  if (onEdit != null || onDelete != null) ...[
                    const SizedBox(width: 8),
                    PopupMenuButton<String>(
                      onSelected: (value) {
                        switch (value) {
                          case 'edit':
                            onEdit?.call();
                            break;
                          case 'delete':
                            onDelete?.call();
                            break;
                        }
                      },
                      itemBuilder: (context) => [
                        if (onEdit != null)
                          const PopupMenuItem(
                            value: 'edit',
                            child: Row(
                              children: [
                                Icon(Icons.edit_outlined, size: 16),
                                SizedBox(width: 8),
                                Text('Edit'),
                              ],
                            ),
                          ),
                        if (onDelete != null)
                          const PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(Icons.delete_outlined, size: 16, color: AppColors.error),
                                SizedBox(width: 8),
                                Text('Delete', style: TextStyle(color: AppColors.error)),
                              ],
                            ),
                          ),
                      ],
                      child: Icon(
                        Icons.more_vert_rounded,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ],
              ),
              
              if (!isCompact) ...[
                const SizedBox(height: 12),
                
                // Project and task info
                Consumer<TimeTrackingViewModel>(
                  builder: (context, timeTrackingVM, child) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (showProjectName) ...[
                          Row(
                            children: [
                              Icon(
                                Icons.folder_outlined,
                                size: 16,
                                color: Colors.grey[600],
                              ),
                              const SizedBox(width: 4),
                              Text(
                                timeTrackingVM.getProjectName(entry.projectId),
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey[700],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                        ],
                        
                        if (showTaskName) ...[
                          Row(
                            children: [
                              Icon(
                                Icons.task_alt_outlined,
                                size: 16,
                                color: Colors.grey[600],
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  timeTrackingVM.getTaskName(entry.taskId),
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    );
                  },
                ),
                
                // Description
                if (entry.description.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    entry.description,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                
                const SizedBox(height: 8),
                
                // Time info
                Row(
                  children: [
                    Icon(
                      Icons.access_time_rounded,
                      size: 14,
                      color: Colors.grey[500],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _getTimeRangeText(),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    
                    if (showDate) ...[
                      const SizedBox(width: 16),
                      Icon(
                        Icons.calendar_today_outlined,
                        size: 14,
                        color: Colors.grey[500],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        AppDateUtils.formatDate(entry.startTime, pattern: 'MMM dd'),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ],
                ),
              ] else ...[
                // Compact mode content
                const SizedBox(height: 4),
                Consumer<TimeTrackingViewModel>(
                  builder: (context, timeTrackingVM, child) {
                    return Text(
                      timeTrackingVM.getTaskName(entry.taskId),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    );
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Color _getTypeColor() {
    switch (entry.type) {
      case TimeEntryType.tracked:
        return AppColors.success;
      case TimeEntryType.manual:
        return AppColors.warning;
    }
  }

  String _getTimeRangeText() {
    final startTime = AppDateUtils.formatDateTime(entry.startTime, pattern: 'HH:mm');
    
    if (entry.endTime != null) {
      final endTime = AppDateUtils.formatDateTime(entry.endTime!, pattern: 'HH:mm');
      return '$startTime - $endTime';
    } else if (entry.isActive) {
      return '$startTime - Active';
    } else {
      return startTime;
    }
  }
}