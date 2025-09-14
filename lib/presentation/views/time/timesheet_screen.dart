// lib/presentation/views/time/timesheet_screen.dart

import 'package:flowence/data/models/time_entry_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/time_tracking_viewmodel.dart';
import '../../widgets/common/custom_app_bar.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/error_widget.dart';
import '../../widgets/time/timer_widget.dart';
import '../../widgets/time/time_entry_card.dart';
import '../../widgets/time/add_time_entry_dialog.dart';
import '../../widgets/time/start_timer_dialog.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/date_utils.dart';
import '../../../core/utils/app_utils.dart';

class TimesheetScreen extends StatefulWidget {
  const TimesheetScreen({Key? key}) : super(key: key);

  @override
  State<TimesheetScreen> createState() => _TimesheetScreenState();
}

class _TimesheetScreenState extends State<TimesheetScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  DateTime _selectedDate = DateTime.now();

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
      timeTrackingVM.loadTimeEntries(),
      timeTrackingVM.loadSupportingData(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Timesheet',
        actions: [
          IconButton(
            onPressed: _showDatePicker,
            icon: const Icon(Icons.calendar_today_rounded),
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
                    Text('Export Data'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'filters',
                child: Row(
                  children: [
                    Icon(Icons.filter_list_rounded),
                    SizedBox(width: 8),
                    Text('Filters'),
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
              // Timer Widget
              Container(
                padding: const EdgeInsets.all(16),
                child: TimerWidget(
                  onStartTimer: () => _showStartTimerDialog(context),
                ),
              ),
              
              // Date selector and summary
              _buildDateSelectorAndSummary(timeTrackingVM),
              
              // Tabs
              TabBar(
                controller: _tabController,
                labelColor: AppColors.primaryBlue,
                unselectedLabelColor: AppColors.textSecondary,
                indicatorColor: AppColors.primaryBlue,
                tabs: const [
                  Tab(text: 'Today'),
                  Tab(text: 'Week'),
                  Tab(text: 'All'),
                ],
              ),
              
              // Tab Content
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildTodayTab(timeTrackingVM),
                    _buildWeekTab(timeTrackingVM),
                    _buildAllEntriesTab(timeTrackingVM),
                  ],
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: "start_timer_fab",
            onPressed: () => _showStartTimerDialog(context),
            backgroundColor: AppColors.success,
            child: const Icon(Icons.play_arrow_rounded, color: Colors.white),
          ),
          const SizedBox(height: 16),
          FloatingActionButton(
            heroTag: "add_manual_entry_fab",
            onPressed: () => _showAddTimeEntryDialog(context),
            backgroundColor: AppColors.primaryBlue,
            child: const Icon(Icons.add_rounded, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildDateSelectorAndSummary(TimeTrackingViewModel timeTrackingVM) {
    final dailyHours = timeTrackingVM.getDailyHours(date: _selectedDate);
    final totalHours = dailyHours.values.fold(0.0, (sum, hours) => sum + hours);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(
          bottom: BorderSide(color: AppColors.borderLight),
        ),
      ),
      child: Column(
        children: [
          // Date selector
          Row(
            children: [
              IconButton(
                onPressed: () => _changeDate(-1),
                icon: const Icon(Icons.chevron_left_rounded),
              ),
              Expanded(
                child: Center(
                  child: GestureDetector(
                    onTap: _showDatePicker,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.borderLight),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        AppDateUtils.formatDate(_selectedDate, pattern: 'EEEE, MMM dd, yyyy'),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              IconButton(
                onPressed: _canGoToNextDay() ? () => _changeDate(1) : null,
                icon: const Icon(Icons.chevron_right_rounded),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Daily summary
          if (totalHours > 0) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.info.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.info.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.timer_rounded, color: AppColors.info, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Total: ${totalHours.toStringAsFixed(1)}h',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.info,
                    ),
                  ),
                  const Spacer(),
                  if (dailyHours.length > 1)
                    Text(
                      '${dailyHours.length} projects',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.info.withOpacity(0.8),
                      ),
                    ),
                ],
              ),
            ),
          ] else ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.timer_off_outlined, color: Colors.grey[600], size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'No time entries for this day',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTodayTab(TimeTrackingViewModel timeTrackingVM) {
    if (timeTrackingVM.isLoading) {
      return const LoadingWidget(message: 'Loading time entries...');
    }

    if (timeTrackingVM.errorMessage != null) {
      return CustomErrorWidget(
        message: timeTrackingVM.errorMessage!,
        onRetry: _loadData,
      );
    }

    final todayEntries = timeTrackingVM.filteredTimeEntries
        .where((entry) => _isSameDay(entry.startTime, _selectedDate))
        .toList()
      ..sort((a, b) => b.startTime.compareTo(a.startTime));

    if (todayEntries.isEmpty) {
      return _buildEmptyState('No entries for today', 'Start tracking time or add a manual entry');
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: todayEntries.length,
        itemBuilder: (context, index) {
          final entry = todayEntries[index];
          return TimeEntryCard(
            entry: entry,
            onEdit: () => _showEditTimeEntryDialog(context, entry),
            onDelete: () => _deleteTimeEntry(entry.id),
            showTaskName: true,
            showProjectName: true,
          );
        },
      ),
    );
  }

  Widget _buildWeekTab(TimeTrackingViewModel timeTrackingVM) {
    if (timeTrackingVM.isLoading) {
      return const LoadingWidget(message: 'Loading time entries...');
    }

    final weekStart = _selectedDate.subtract(Duration(days: _selectedDate.weekday - 1));
    final weekEnd = weekStart.add(const Duration(days: 6));
    
    final weekEntries = timeTrackingVM.filteredTimeEntries
        .where((entry) => 
          entry.startTime.isAfter(weekStart.subtract(const Duration(days: 1))) &&
          entry.startTime.isBefore(weekEnd.add(const Duration(days: 1))))
        .toList()
      ..sort((a, b) => b.startTime.compareTo(a.startTime));

    if (weekEntries.isEmpty) {
      return _buildEmptyState('No entries this week', 'Start tracking time for your tasks');
    }

    // Group entries by day
    final groupedEntries = <DateTime, List<TimeEntryModel>>{};
    for (final entry in weekEntries) {
      final entryDate = DateTime(entry.startTime.year, entry.startTime.month, entry.startTime.day);
      groupedEntries.putIfAbsent(entryDate, () => []).add(entry);
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: groupedEntries.keys.length,
        itemBuilder: (context, index) {
          final date = groupedEntries.keys.toList()[index];
          final dayEntries = groupedEntries[date]!
            ..sort((a, b) => b.startTime.compareTo(a.startTime));
          
          final dailyTotal = dayEntries.fold(0.0, (sum, entry) => sum + entry.durationHours);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Day header
              Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    Text(
                      AppDateUtils.formatDate(date, pattern: 'EEEE, MMM dd'),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${dailyTotal.toStringAsFixed(1)}h',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryBlue,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Day entries
              ...dayEntries.map((entry) => TimeEntryCard(
                entry: entry,
                onEdit: () => _showEditTimeEntryDialog(context, entry),
                onDelete: () => _deleteTimeEntry(entry.id),
                showTaskName: true,
                showProjectName: true,
              )),
              
              const SizedBox(height: 16),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAllEntriesTab(TimeTrackingViewModel timeTrackingVM) {
    if (timeTrackingVM.isLoading) {
      return const LoadingWidget(message: 'Loading time entries...');
    }

    final allEntries = timeTrackingVM.filteredTimeEntries
      ..sort((a, b) => b.startTime.compareTo(a.startTime));

    if (allEntries.isEmpty) {
      return _buildEmptyState('No time entries found', 'Start tracking time to see your entries here');
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: allEntries.length,
        itemBuilder: (context, index) {
          final entry = allEntries[index];
          return TimeEntryCard(
            entry: entry,
            onEdit: () => _showEditTimeEntryDialog(context, entry),
            onDelete: () => _deleteTimeEntry(entry.id),
            showTaskName: true,
            showProjectName: true,
            showDate: true,
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(String title, String subtitle) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.timer_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _showStartTimerDialog(context),
            icon: const Icon(Icons.play_arrow_rounded),
            label: const Text('Start Timer'),
          ),
        ],
      ),
    );
  }

  // Helper methods
  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
           date1.month == date2.month &&
           date1.day == date2.day;
  }

  bool _canGoToNextDay() {
    final tomorrow = _selectedDate.add(const Duration(days: 1));
    final now = DateTime.now();
    return tomorrow.isBefore(DateTime(now.year, now.month, now.day + 1));
  }

  void _changeDate(int days) {
    setState(() {
      _selectedDate = _selectedDate.add(Duration(days: days));
    });
  }

  Future<void> _showDatePicker() async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
    );

    if (selectedDate != null) {
      setState(() {
        _selectedDate = selectedDate;
      });
    }
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'export':
        _exportTimeEntries();
        break;
      case 'filters':
        _showFiltersDialog();
        break;
    }
  }

  void _showStartTimerDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const StartTimerDialog(),
    );
  }

  void _showAddTimeEntryDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const AddTimeEntryDialog(),
    );
  }

  void _showEditTimeEntryDialog(BuildContext context, TimeEntryModel entry) {
    showDialog(
      context: context,
      builder: (context) => AddTimeEntryDialog(entryToEdit: entry),
    );
  }

  Future<void> _deleteTimeEntry(String entryId) async {
    final confirmed = await AppUtils.showConfirmDialog(
      context,
      title: 'Delete Time Entry',
      content: 'Are you sure you want to delete this time entry? This action cannot be undone.',
      confirmText: 'Delete',
    );

    if (confirmed) {
      final timeTrackingVM = context.read<TimeTrackingViewModel>();
      final success = await timeTrackingVM.deleteTimeEntry(entryId);

      if (success && mounted) {
        AppUtils.showSuccessSnackBar(context, 'Time entry deleted successfully');
      } else if (mounted) {
        AppUtils.showErrorSnackBar(
          context,
          timeTrackingVM.errorMessage ?? 'Failed to delete time entry',
        );
      }
    }
  }

  void _exportTimeEntries() async {
    final timeTrackingVM = context.read<TimeTrackingViewModel>();
    
    // Show date range picker for export
    final startDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 30)),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
      helpText: 'Select start date for export',
    );
    
    if (startDate == null) return;
    
    final endDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: startDate,
      lastDate: DateTime.now(),
      helpText: 'Select end date for export',
    );
    
    if (endDate == null) return;

    AppUtils.showLoadingDialog(context);
    
    try {
      final exportData = await timeTrackingVM.getTimeEntriesForExport(
        startDate: startDate,
        endDate: endDate,
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
      AppUtils.showErrorSnackBar(context, 'Failed to export time entries');
    }
  }

  void _showFiltersDialog() {
    final timeTrackingVM = context.read<TimeTrackingViewModel>();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Time Entries'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Project filter
              const Text('Project:', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              DropdownButtonFormField<String?>(
                value: timeTrackingVM.filterProjectId,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                items: [
                  const DropdownMenuItem(value: null, child: Text('All Projects')),
                  ...timeTrackingVM.projects.map((project) =>
                    DropdownMenuItem(value: project.id, child: Text(project.name))
                  ),
                ],
                onChanged: (value) => timeTrackingVM.setProjectFilter(value),
              ),
              
              const SizedBox(height: 16),
              
              // Task filter
              const Text('Task:', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              DropdownButtonFormField<String?>(
                value: timeTrackingVM.filterTaskId,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                items: [
                  const DropdownMenuItem(value: null, child: Text('All Tasks')),
                  ...timeTrackingVM.getTasksForProject(timeTrackingVM.filterProjectId)
                    .map((task) => DropdownMenuItem(value: task.id, child: Text(task.title))),
                ],
                onChanged: (value) => timeTrackingVM.setTaskFilter(value),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              timeTrackingVM.clearFilters();
              Navigator.pop(context);
            },
            child: const Text('Clear All'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}