// lib/presentation/widgets/time/timer_widget.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/time_tracking_viewmodel.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/app_utils.dart';

class TimerWidget extends StatefulWidget {
  final bool isCompact;
  final VoidCallback? onStartTimer;
  
  const TimerWidget({
    Key? key,
    this.isCompact = false,
    this.onStartTimer,
  }) : super(key: key);

  @override
  State<TimerWidget> createState() => _TimerWidgetState();
}

class _TimerWidgetState extends State<TimerWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TimeTrackingViewModel>(
      builder: (context, timeTrackingVM, child) {
        if (widget.isCompact) {
          return _buildCompactTimer(timeTrackingVM);
        }
        return _buildFullTimer(timeTrackingVM);
      },
    );
  }

  Widget _buildCompactTimer(TimeTrackingViewModel timeTrackingVM) {
    if (!timeTrackingVM.hasActiveTimer) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.timer_outlined,
              size: 16,
              color: Colors.grey[600],
            ),
            const SizedBox(width: 4),
            Text(
              'No active timer',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return GestureDetector(
      onTap: () => _showTimerDetails(context, timeTrackingVM),
      child: AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _pulseAnimation.value,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.success.withOpacity(0.3),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppColors.success,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _formatDuration(timeTrackingVM.currentTimerDuration),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.success,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFullTimer(TimeTrackingViewModel timeTrackingVM) {
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                const Icon(
                  Icons.timer_rounded,
                  color: AppColors.primaryBlue,
                  size: 24,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Time Tracker',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const Spacer(),
                if (timeTrackingVM.hasActiveTimer)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.success.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'ACTIVE',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: AppColors.success,
                      ),
                    ),
                  ),
              ],
            ),
            
            const SizedBox(height: 16),

            if (timeTrackingVM.hasActiveTimer) ...[
              // Active timer display
              _buildActiveTimerDisplay(timeTrackingVM),
            ] else ...[
              // No active timer
              _buildNoActiveTimer(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildActiveTimerDisplay(TimeTrackingViewModel timeTrackingVM) {
    final activeEntry = timeTrackingVM.activeTimeEntry!;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Task info
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.primaryBlue.withOpacity(0.05),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: AppColors.primaryBlue.withOpacity(0.1),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                timeTrackingVM.getTaskName(activeEntry.taskId),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                timeTrackingVM.getProjectName(activeEntry.projectId),
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              if (activeEntry.description.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  activeEntry.description,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ],
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Timer display
        Center(
          child: AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.success.withOpacity(0.3),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.success.withOpacity(0.2 * _pulseAnimation.value),
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Text(
                  _formatDuration(timeTrackingVM.currentTimerDuration),
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: AppColors.success,
                    fontFamily: 'monospace',
                  ),
                ),
              );
            },
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Controls
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: timeTrackingVM.isUpdating ? null : () => _stopTimer(timeTrackingVM),
                icon: timeTrackingVM.isUpdating 
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.stop_rounded),
                label: Text(timeTrackingVM.isUpdating ? 'Stopping...' : 'Stop Timer'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.error,
                  side: const BorderSide(color: AppColors.error),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _showEditTimerDialog(context, timeTrackingVM),
                icon: const Icon(Icons.edit_rounded),
                label: const Text('Edit'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildNoActiveTimer() {
    return Column(
      children: [
        Icon(
          Icons.timer_off_outlined,
          size: 64,
          color: Colors.grey[400],
        ),
        const SizedBox(height: 16),
        Text(
          'No active timer',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Start tracking time for a task',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[500],
          ),
        ),
        const SizedBox(height: 16),
        ElevatedButton.icon(
          onPressed: widget.onStartTimer,
          icon: const Icon(Icons.play_arrow_rounded),
          label: const Text('Start Timer'),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
        ),
      ],
    );
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    final seconds = duration.inSeconds % 60;
    
    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    } else {
      return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
  }

  Future<void> _stopTimer(TimeTrackingViewModel timeTrackingVM) async {
    final success = await timeTrackingVM.stopTimer();
    
    if (success && mounted) {
      AppUtils.showSuccessSnackBar(context, 'Timer stopped successfully');
    } else if (mounted) {
      AppUtils.showErrorSnackBar(
        context,
        timeTrackingVM.errorMessage ?? 'Failed to stop timer',
      );
    }
  }

  void _showTimerDetails(BuildContext context, TimeTrackingViewModel timeTrackingVM) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  'Active Timer',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildActiveTimerDisplay(timeTrackingVM),
          ],
        ),
      ),
    );
  }

  void _showEditTimerDialog(BuildContext context, TimeTrackingViewModel timeTrackingVM) {
    final activeEntry = timeTrackingVM.activeTimeEntry!;
    final descriptionController = TextEditingController(text: activeEntry.description);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Timer'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Task: ${timeTrackingVM.getTaskName(activeEntry.taskId)}',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final success = await timeTrackingVM.updateTimeEntry(
                activeEntry.id,
                description: descriptionController.text.trim(),
              );
              
              Navigator.pop(context);
              
              if (success && mounted) {
                AppUtils.showSuccessSnackBar(context, 'Timer updated successfully');
              } else if (mounted) {
                AppUtils.showErrorSnackBar(
                  context,
                  timeTrackingVM.errorMessage ?? 'Failed to update timer',
                );
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}