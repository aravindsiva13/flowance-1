

// lib/presentation/widgets/dashboard/progress_chart.dart

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/constants/app_colors.dart';

class ProgressChart extends StatelessWidget {
  final List<Map<String, dynamic>> data;
  final bool showLegend;
  
  const ProgressChart({
    Key? key,
    required this.data,
    this.showLegend = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const Center(
        child: Text('No data available'),
      );
    }

    return Column(
      children: [
        Expanded(
          child: PieChart(
            PieChartData(
              sectionsSpace: 2,
              centerSpaceRadius: 30,
              sections: data.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;
                final count = (item['count'] as num).toInt(); // Fix: Convert to int
                final color = _parseColor(item['color']);
                
                return PieChartSectionData(
                  color: color,
                  value: count.toDouble(),
                  title: count > 0 ? count.toString() : '',
                  radius: 40,
                  titleStyle: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        if (showLegend) ...[
          const SizedBox(height: 16),
          Wrap(
            children: data.map((item) {
              final count = (item['count'] as num).toInt(); // Fix: Convert to int
              final status = item['status'] as String;
              final color = _parseColor(item['color']);
              
              return Padding(
                padding: const EdgeInsets.only(right: 16, bottom: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '$status ($count)',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ],
    );
  }

  Color _parseColor(String colorString) {
    try {
      return Color(int.parse(colorString.substring(1), radix: 16) + 0xFF000000);
    } catch (e) {
      return AppColors.primaryBlue;
    }
  }
}