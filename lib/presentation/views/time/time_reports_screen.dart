// lib/presentation/views/time/time_reports_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../viewmodels/time_tracking_viewmodel.dart';
import '../../widgets/common/custom_app_bar.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/dashboard/stats_card.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/date_utils.dart';
import '../../../core/utils/app_utils.dart';

class TimeReportsScreen extends StatefulWidget {
  const TimeReportsScreen({Key? key}) : super(key: key);

  @override
  State<TimeReportsScreen> createState() => _TimeReportsScreenState();
}

class _TimeReportsScreenState extends State<TimeReportsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 7));
  DateTime _endDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final timeTrackingVM = context.read<TimeTrackingViewModel>();
    await Future.wait([
      timeTrackingVM.loadTimeEntries(
        startDate: _startDate,
        endDate: _endDate,
      ),
      timeTrackingVM.loadSupportingData(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Time Reports',
        actions: [
          IconButton(
            onPressed: _showDateRangePicker,
            icon: const Icon(Icons.date_range_rounded),
          ),
          PopupMenuButton<String>(
            onSelected: _handleMenuAction,
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'export',
                child: Row(
                  children: [
                    Icon(Icons.download_rounded),
                    SizedBox(width: 8),
                    Text('Export Report'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Consumer<TimeTrackingViewModel>(
        builder: (context, timeTrackingVM, child) {
          return Column(
            children: [
              // Date Range Display
              _buildDateRangeHeader(),
              
              // Overview Stats
              _buildOverviewStats(timeTrackingVM),
              
              // Tabs
              TabBar(
                controller: _tabController,
                labelColor: AppColors.primaryBlue,
                unselectedLabelColor: AppColors.textSecondary,
                indicatorColor: AppColors.primaryBlue,
                tabs: const [
                  Tab(text: 'Daily'),
                  Tab(text: 'Projects'),
                  Tab(text: 'Tasks'),
                ],
              ),
              
              // Tab Content
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildDailyTab(timeTrackingVM),
                    _buildProjectsTab(timeTrackingVM),
                    _buildTasksTab(timeTrackingVM),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDateRangeHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(
          bottom: BorderSide(color: AppColors.borderLight),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.date_range_rounded, color: AppColors.primaryBlue),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '${AppDateUtils.formatDate(_startDate)} - ${AppDateUtils.formatDate(_endDate)}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          TextButton.icon(
            onPressed: _showDateRangePicker,
            icon: const Icon(Icons.edit_rounded, size: 16),
            label: const Text('Change'),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewStats(TimeTrackingViewModel timeTrackingVM) {
    if (timeTrackingVM.isLoading) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: LoadingWidget(),
      );
    }

    final totalHours = timeTrackingVM.getTotalHoursForPeriod(
      startDate: _startDate,
      endDate: _endDate,
    );
    
    final projectHours = timeTrackingVM.getProjectHours(
      startDate: _startDate,
      endDate: _endDate,
    );
    
    final averageHoursPerDay = totalHours / (_endDate.difference(_startDate).inDays + 1);
    
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Overview',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: StatsCard(
                  title: 'Total Hours',
                  value: totalHours.toStringAsFixed(1),
                  icon: Icons.timer_rounded,
                  color: AppColors.primaryBlue,
                  subtitle: 'This period',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: StatsCard(
                  title: 'Daily Average',
                  value: averageHoursPerDay.toStringAsFixed(1),
                  icon: Icons.trending_up_rounded,
                  color: AppColors.success,
                  subtitle: 'Hours per day',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: StatsCard(
                  title: 'Active Projects',
                  value: projectHours.keys.length.toString(),
                  icon: Icons.folder_rounded,
                  color: AppColors.info,
                  subtitle: 'With time logged',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: StatsCard(
                  title: 'Working Days',
                  value: _getWorkingDaysCount().toString(),
                  icon: Icons.calendar_today_rounded,
                  color: AppColors.warning,
                  subtitle: 'Days with entries',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDailyTab(TimeTrackingViewModel timeTrackingVM) {
    if (timeTrackingVM.isLoading) {
      return const LoadingWidget(message: 'Loading daily data...');
    }

    final dailyData = _getDailyData(timeTrackingVM);
    
    if (dailyData.isEmpty) {
      return _buildEmptyState('No time entries found for the selected period');
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Daily Hours Chart
          const Text(
            'Daily Hours',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                height: 300,
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: dailyData.values.reduce((a, b) => a > b ? a : b) * 1.2,
                    barTouchData: BarTouchData(
                      touchTooltipData: BarTouchTooltipData(
                        getTooltipItem: (group, groupIndex, rod, rodIndex) {
                          final date = dailyData.keys.elementAt(groupIndex);
                          final hours = rod.toY;
                          return BarTooltipItem(
                            '${AppDateUtils.formatDate(date, pattern: 'MMM dd')}\n${hours.toStringAsFixed(1)}h',
                            const TextStyle(color: Colors.white),
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
                            final index = value.toInt();
                            if (index >= 0 && index < dailyData.keys.length) {
                              final date = dailyData.keys.elementAt(index);
                              return Text(
                                AppDateUtils.formatDate(date, pattern: 'dd'),
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
                    barGroups: dailyData.entries.map((entry) {
                      final index = dailyData.keys.toList().indexOf(entry.key);
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
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Daily Breakdown List
          const Text(
            'Daily Breakdown',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...dailyData.entries.map((entry) {
            final date = entry.key;
            final hours = entry.value;
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    AppDateUtils.formatDate(date, pattern: 'dd'),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryBlue,
                    ),
                  ),
                ),
                title: Text(AppDateUtils.formatDate(date, pattern: 'EEEE, MMM dd')),
                trailing: Text(
                  '${hours.toStringAsFixed(1)}h',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryBlue,
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildProjectsTab(TimeTrackingViewModel timeTrackingVM) {
    if (timeTrackingVM.isLoading) {
      return const LoadingWidget(message: 'Loading project data...');
    }

    final projectHours = timeTrackingVM.getProjectHours(
      startDate: _startDate,
      endDate: _endDate,
    );
    
    if (projectHours.isEmpty) {
      return _buildEmptyState('No project time data found for the selected period');
    }

    final sortedProjects = projectHours.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Project Hours Pie Chart
          const Text(
            'Time by Project',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                height: 300,
                child: Row(
                  children: [
                    Expanded(
                      child: PieChart(
                        PieChartData(
                          sectionsSpace: 2,
                          centerSpaceRadius: 60,
                          sections: sortedProjects.asMap().entries.map((entry) {
                            final index = entry.key;
                            final projectEntry = entry.value;
                            final color = _getProjectColor(index);
                            final percentage = (projectEntry.value / projectHours.values.reduce((a, b) => a + b)) * 100;
                            
                            return PieChartSectionData(
                              color: color,
                              value: projectEntry.value,
                              title: '${percentage.toStringAsFixed(0)}%',
                              radius: 80,
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
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: sortedProjects.asMap().entries.map((entry) {
                          final index = entry.key;
                          final projectEntry = entry.value;
                          final color = _getProjectColor(index);
                          
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              children: [
                                Container(
                                  width: 12,
                                  height: 12,
                                  decoration: BoxDecoration(
                                    color: color,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    projectEntry.key,
                                    style: const TextStyle(fontSize: 12),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Text(
                                  '${projectEntry.value.toStringAsFixed(1)}h',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Project Hours List
          const Text(
            'Project Details',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...sortedProjects.map((entry) {
            final projectName = entry.key;
            final hours = entry.value;
            final totalHours = projectHours.values.reduce((a, b) => a + b);
            final percentage = (hours / totalHours) * 100;
            
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            projectName,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Text(
                          '${hours.toStringAsFixed(1)}h',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryBlue,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: percentage / 100,
                      backgroundColor: AppColors.borderLight,
                      valueColor: const AlwaysStoppedAnimation(AppColors.primaryBlue),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${percentage.toStringAsFixed(1)}% of total time',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildTasksTab(TimeTrackingViewModel timeTrackingVM) {
    if (timeTrackingVM.isLoading) {
      return const LoadingWidget(message: 'Loading task data...');
    }

    final taskData = _getTaskTimeData(timeTrackingVM);
    
    if (taskData.isEmpty) {
      return _buildEmptyState('No task time data found for the selected period');
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Time by Task',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...taskData.entries.map((entry) {
            final taskName = entry.key;
            final data = entry.value;
            final actualHours = data['actual'] as double;
            final estimatedHours = data['estimated'] as double?;
            
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      taskName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.timer_rounded, size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          'Actual: ${actualHours.toStringAsFixed(1)}h',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (estimatedHours != null) ...[
                          const SizedBox(width: 16),
                          Icon(Icons.schedule_rounded, size: 16, color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          Text(
                            'Estimated: ${estimatedHours.toStringAsFixed(1)}h',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ],
                    ),
                    if (estimatedHours != null) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: LinearProgressIndicator(
                              value: (actualHours / estimatedHours).clamp(0.0, 1.0),
                              backgroundColor: AppColors.borderLight,
                              valueColor: AlwaysStoppedAnimation(
                                actualHours > estimatedHours 
                                    ? AppColors.error 
                                    : AppColors.success,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            actualHours > estimatedHours 
                                ? '+${(actualHours - estimatedHours).toStringAsFixed(1)}h over'
                                : '${(estimatedHours - actualHours).toStringAsFixed(1)}h remaining',
                            style: TextStyle(
                              fontSize: 12,
                              color: actualHours > estimatedHours 
                                  ? AppColors.error 
                                  : AppColors.success,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.analytics_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // Helper methods
  Map<DateTime, double> _getDailyData(TimeTrackingViewModel timeTrackingVM) {
    final dailyData = <DateTime, double>{};
    
    // Initialize all days in range with 0 hours
    DateTime currentDate = DateTime(_startDate.year, _startDate.month, _startDate.day);
    final endDate = DateTime(_endDate.year, _endDate.month, _endDate.day);
    
    while (currentDate.isBefore(endDate.add(const Duration(days: 1)))) {
      dailyData[currentDate] = 0.0;
      currentDate = currentDate.add(const Duration(days: 1));
    }
    
    // Add actual hours from time entries
    for (final entry in timeTrackingVM.filteredTimeEntries) {
      final entryDate = DateTime(
        entry.startTime.year,
        entry.startTime.month,
        entry.startTime.day,
      );
      
      if (dailyData.containsKey(entryDate)) {
        dailyData[entryDate] = dailyData[entryDate]! + entry.durationHours;
      }
    }
    
    return dailyData;
  }

  Map<String, Map<String, dynamic>> _getTaskTimeData(TimeTrackingViewModel timeTrackingVM) {
    final taskData = <String, Map<String, dynamic>>{};
    
    for (final entry in timeTrackingVM.filteredTimeEntries) {
      final taskName = timeTrackingVM.getTaskName(entry.taskId);
      
      if (!taskData.containsKey(taskName)) {
        // Get estimated time for the task
        final task = timeTrackingVM.tasks.firstWhere(
          (t) => t.id == entry.taskId,
          // orElse: () => null,
        );
        
        taskData[taskName] = {
          'actual': 0.0,
          'estimated': task?.estimatedTimeHours,
        };
      }
      
      taskData[taskName]!['actual'] = 
          (taskData[taskName]!['actual'] as double) + entry.durationHours;
    }
    
    // Sort by actual hours descending
    final sortedEntries = taskData.entries.toList()
      ..sort((a, b) => (b.value['actual'] as double).compareTo(a.value['actual'] as double));
    
    return Map.fromEntries(sortedEntries);
  }

  int _getWorkingDaysCount() {
    final timeTrackingVM = context.read<TimeTrackingViewModel>();
    final daysWithEntries = <DateTime>{};
    
    for (final entry in timeTrackingVM.filteredTimeEntries) {
      final entryDate = DateTime(
        entry.startTime.year,
        entry.startTime.month,
        entry.startTime.day,
      );
      daysWithEntries.add(entryDate);
    }
    
    return daysWithEntries.length;
  }

  Color _getProjectColor(int index) {
    final colors = [
      AppColors.primaryBlue,
      AppColors.success,
      AppColors.warning,
      AppColors.error,
      AppColors.info,
      AppColors.secondary,
    ];
    return colors[index % colors.length];
  }

  Future<void> _showDateRangePicker() async {
    final startDate = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
      helpText: 'Select start date',
    );
    
    if (startDate == null) return;
    
    final endDate = await showDatePicker(
      context: context,
      initialDate: _endDate,
      firstDate: startDate,
      lastDate: DateTime.now(),
      helpText: 'Select end date',
    );
    
    if (endDate == null) return;

    setState(() {
      _startDate = startDate;
      _endDate = endDate;
    });
    
    _loadData();
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'export':
        _exportReport();
        break;
    }
  }

  void _exportReport() async {
    final timeTrackingVM = context.read<TimeTrackingViewModel>();
    
    AppUtils.showLoadingDialog(context);
    
    try {
      final exportData = await timeTrackingVM.getTimeEntriesForExport(
        startDate: _startDate,
        endDate: _endDate,
      );
      
      AppUtils.hideLoadingDialog(context);
      
      if (exportData.isNotEmpty) {
        final csvData = AppUtils.generateCSV(exportData);
        // Here you would normally save the CSV file
        // For this example, we'll just show a success message
        AppUtils.showSuccessSnackBar(
          context, 
          'Exported ${exportData.length} time entries'
        );
      } else {
        AppUtils.showErrorSnackBar(context, 'No time entries found for the selected period');
      }
    } catch (e) {
      AppUtils.hideLoadingDialog(context);
      AppUtils.showErrorSnackBar(context, 'Failed to export time report');
    }
  }
}