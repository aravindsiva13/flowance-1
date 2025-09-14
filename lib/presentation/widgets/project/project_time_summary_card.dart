// lib/presentation/widgets/project/project_time_summary_card.dart

import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class ProjectTimeSummaryCard extends StatelessWidget {
  final String projectId;
  final double totalHours;
  final int entriesCount;
  final String dateRange;
  final double? budgetHours;
  final double? estimatedHours;

  const ProjectTimeSummaryCard({
    Key? key,
    required this.projectId,
    required this.totalHours,
    required this.entriesCount,
    required this.dateRange,
    this.budgetHours,
    this.estimatedHours,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.access_time_rounded,
                  color: AppColors.primaryBlue,
                  size: 20,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Time Summary',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Text(
                  dateRange,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildTimeMetric(
                    'Total Logged',
                    '${totalHours.toStringAsFixed(1)}h',
                    AppColors.primaryBlue,
                    Icons.schedule,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildTimeMetric(
                    'Entries',
                    entriesCount.toString(),
                    AppColors.success,
                    Icons.list_alt,
                  ),
                ),
              ],
            ),
            if (budgetHours != null || estimatedHours != null) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  if (budgetHours != null)
                    Expanded(
                      child: _buildTimeMetric(
                        'Budget',
                        '${budgetHours!.toStringAsFixed(1)}h',
                        _getBudgetColor(),
                        Icons.account_balance_wallet,
                      ),
                    ),
                  if (budgetHours != null && estimatedHours != null)
                    const SizedBox(width: 16),
                  if (estimatedHours != null)
                    Expanded(
                      child: _buildTimeMetric(
                        'Estimated',
                        '${estimatedHours!.toStringAsFixed(1)}h',
                        AppColors.warning,
                        Icons.timer,
                      ),
                    ),
                ],
              ),
            ],
            if (budgetHours != null) ...[
              const SizedBox(height: 16),
              _buildBudgetProgress(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTimeMetric(String label, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBudgetProgress() {
    if (budgetHours == null) return const SizedBox.shrink();
    
    final progress = totalHours / budgetHours!;
    final isOverBudget = progress > 1.0;
    final progressColor = isOverBudget 
        ? AppColors.error 
        : progress > 0.8 
            ? AppColors.warning 
            : AppColors.success;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Budget Progress',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              '${(progress * 100).toStringAsFixed(1)}%',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: progressColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: progress.clamp(0.0, 1.0),
          backgroundColor: progressColor.withOpacity(0.1),
          valueColor: AlwaysStoppedAnimation<Color>(progressColor),
        ),
        const SizedBox(height: 4),
        if (isOverBudget)
          Text(
            'Over budget by ${(totalHours - budgetHours!).toStringAsFixed(1)} hours',
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.error,
              fontWeight: FontWeight.w500,
            ),
          )
        else
          Text(
            '${(budgetHours! - totalHours).toStringAsFixed(1)} hours remaining',
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
      ],
    );
  }

  Color _getBudgetColor() {
    if (budgetHours == null) return AppColors.info;
    
    final progress = totalHours / budgetHours!;
    if (progress > 1.0) return AppColors.error;
    if (progress > 0.8) return AppColors.warning;
    return AppColors.success;
  }
}
