
// lib/presentation/widgets/project/project_time_chart.dart

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../data/models/time_entry_model.dart';
import '../../../core/constants/app_colors.dart';

class ProjectTimeChart extends StatelessWidget {
  final List<TimeEntryModel> timeEntries;
  final ChartType chartType;

  const ProjectTimeChart({
    Key? key,
    required this.timeEntries,
    this.chartType = ChartType.bar,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    switch (chartType) {
      case ChartType.bar:
        return _buildBarChart();
      case ChartType.line:
        return _buildLineChart();
      case ChartType.pie:
        return _buildPieChart();
    }
  }

  Widget _buildBarChart() {
    final dailyHours = _getDailyHours();
    
    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: dailyHours.values.isNotEmpty 
              ? dailyHours.values.reduce((a, b) => a > b ? a : b) * 1.2
              : 10,
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              tooltipBgColor: AppColors.surface,
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                return BarTooltipItem(
                  '${rod.toY.toStringAsFixed(1)}h',
                  const TextStyle(color: AppColors.primaryBlue),
                );
              },
            ),
          ),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  return Text(
                    '${value.toInt()}h',
                    style: const TextStyle(fontSize: 10),
                  );
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final days = dailyHours.keys.toList();
                  if (value.toInt() < days.length) {
                    final day = days[value.toInt()];
                    return Text(
                      '${day.day}/${day.month}',
                      style: const TextStyle(fontSize: 10),
                    );
                  }
                  return const Text('');
                },
              ),
            ),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          barGroups: dailyHours.entries.map((entry) {
            final index = dailyHours.keys.toList().indexOf(entry.key);
            return BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: entry.value,
                  color: AppColors.primaryBlue,
                  width: 16,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildLineChart() {
    final dailyHours = _getDailyHours();
    
    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      child: LineChart(
        LineChartData(
          gridData: const FlGridData(show: true),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  return Text(
                    '${value.toInt()}h',
                    style: const TextStyle(fontSize: 10),
                  );
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final days = dailyHours.keys.toList();
                  if (value.toInt() < days.length) {
                    final day = days[value.toInt()];
                    return Text(
                      '${day.day}/${day.month}',
                      style: const TextStyle(fontSize: 10),
                    );
                  }
                  return const Text('');
                },
              ),
            ),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(
            show: true,
            border: Border.all(color: AppColors.borderLight),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: dailyHours.entries.map((entry) {
                final index = dailyHours.keys.toList().indexOf(entry.key).toDouble();
                return FlSpot(index, entry.value);
              }).toList(),
              isCurved: true,
              color: AppColors.primaryBlue,
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: true),
              belowBarData: BarAreaData(
                show: true,
                color: AppColors.primaryBlue.withOpacity(0.1),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPieChart() {
    final taskHours = _getTaskHours();
    final colors = [
      AppColors.primaryBlue,
      AppColors.success,
      AppColors.warning,
      AppColors.error,
      AppColors.info,
      AppColors.secondary,
    ];

    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      child: PieChart(
        PieChartData(
          sectionsSpace: 2,
          centerSpaceRadius: 40,
          sections: taskHours.entries.map((entry) {
            final index = taskHours.keys.toList().indexOf(entry.key);
            final color = colors[index % colors.length];
            final percentage = (entry.value / taskHours.values.reduce((a, b) => a + b)) * 100;
            
            return PieChartSectionData(
              color: color,
              value: entry.value,
              title: '${percentage.toStringAsFixed(1)}%',
              radius: 60,
              titleStyle: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Map<DateTime, double> _getDailyHours() {
    final dailyHours = <DateTime, double>{};
    
    for (final entry in timeEntries) {
      final date = DateTime(
        entry.startTime.year,
        entry.startTime.month,
        entry.startTime.day,
      );
      dailyHours[date] = (dailyHours[date] ?? 0.0) + entry.durationHours;
    }
    
    return Map.fromEntries(
      dailyHours.entries.toList()..sort((a, b) => a.key.compareTo(b.key))
    );
  }

  Map<String, double> _getTaskHours() {
    final taskHours = <String, double>{};
    
    for (final entry in timeEntries) {
      final taskName = entry.taskId; // You might want to resolve this to actual task name
      taskHours[taskName] = (taskHours[taskName] ?? 0.0) + entry.durationHours;
    }
    
    return taskHours;
  }
}

enum ChartType { bar, line, pie }