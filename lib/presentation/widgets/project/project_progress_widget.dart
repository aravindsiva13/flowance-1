
// lib/presentation/widgets/project/project_progress_widget.dart

import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class ProjectProgressWidget extends StatelessWidget {
  final double progress;
  final bool showLabel;
  final double height;
  
  const ProjectProgressWidget({
    Key? key,
    required this.progress,
    this.showLabel = false,
    this.height = 6,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showLabel) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Progress',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                '${(progress * 100).toInt()}%',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
        ],
        
        ClipRRect(
          borderRadius: BorderRadius.circular(height / 2),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: AppColors.borderLight,
            valueColor: AlwaysStoppedAnimation(
              _getProgressColor(progress),
            ),
            minHeight: height,
          ),
        ),
      ],
    );
  }

  Color _getProgressColor(double progress) {
    if (progress >= 1.0) return AppColors.success;
    if (progress >= 0.7) return AppColors.info;
    if (progress >= 0.4) return AppColors.warning;
    return AppColors.error;
  }
}