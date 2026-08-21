import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/routes/route_names.dart';
import '../../../core/theme/app_colors.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/app_empty_view.dart';
import '../../widgets/common/app_error_view.dart';
import '../../widgets/common/priority_badge.dart';
import '../../widgets/common/status_badge.dart';
import '../../widgets/common/user_avatar.dart';

/// Supported sort options for the Task List UI preview
enum TaskSortOption {
  dueDate('Due Date', Icons.calendar_today_rounded),
  priority('Priority', Icons.flag_outlined),
  recentlyUpdated('Recently Updated', Icons.update_rounded),
  status('Status', Icons.donut_large_rounded);

  const TaskSortOption(this.label, this.icon);
  final String label;
  final IconData icon;
}

/// A sample presentation data model for the Task List UI
class _TaskItemData {
  const _TaskItemData({
    required this.id,
    required this.title,
    required this.projectName,
    required this.status,
    required this.priority,
    required this.assigneeName,
    required this.assigneeInitials,
    required this.dueDate,
    this.dueDateType = _DueDateType.normal,
    this.isCompleted = false,
  });

  final String id;
  final String title;
  final String projectName;
  final String status;
  final String priority;
  final String assigneeName;
  final String assigneeInitials;
  final String dueDate;
  final _DueDateType dueDateType;
  final bool isCompleted;
}

enum _DueDateType {
  normal,
  dueSoon,
  overdue,
  completed,
}

/// Premium, production-quality Task List Screen for TaskFlow
class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  // Search state
  final TextEditingController _searchController = TextEditingController();
  bool _hasSearchText = false;

  // Local filter states for UI preview demonstration
  String _selectedStatus = 'All';
  String _selectedPriority = 'All';
  String _selectedAssignee = 'All';
  String _selectedDueDate = 'All';
  TaskSortOption _selectedSort = TaskSortOption.dueDate;

  // Interactive demo states
  bool _isLoading = false;
  bool _isError = false;

  // Static sample tasks
  static const List<_TaskItemData> _allTasks = [
    _TaskItemData(
      id: 'task-1',
      title: 'Fix broken contact form',
      projectName: 'Website Relaunch',
      status: 'In Progress',
      priority: 'Urgent',
      assigneeName: 'Ava Patel',
      assigneeInitials: 'AP',
      dueDate: 'Due Today',
      dueDateType: _DueDateType.dueSoon,
    ),
    _TaskItemData(
      id: 'task-2',
      title: 'Build responsive nav component',
      projectName: 'Mobile App v2',
      status: 'Todo',
      priority: 'Medium',
      assigneeName: 'Marcus Lee',
      assigneeInitials: 'ML',
      dueDate: 'Due Tomorrow',
      dueDateType: _DueDateType.dueSoon,
    ),
    _TaskItemData(
      id: 'task-3',
      title: 'Set up design tokens in Figma',
      projectName: 'Design System',
      status: 'In Progress',
      priority: 'High',
      assigneeName: 'Priya Nair',
      assigneeInitials: 'PN',
      dueDate: 'Due Jan 10',
      dueDateType: _DueDateType.normal,
    ),
    _TaskItemData(
      id: 'task-4',
      title: 'Write homepage copy',
      projectName: 'Website Relaunch',
      status: 'Review',
      priority: 'Low',
      assigneeName: 'Elena Garcia',
      assigneeInitials: 'EG',
      dueDate: 'Due Jan 15',
      dueDateType: _DueDateType.normal,
    ),
    _TaskItemData(
      id: 'task-5',
      title: 'Review onboarding flow',
      projectName: 'Mobile App v2',
      status: 'Todo',
      priority: 'High',
      assigneeName: 'Daniel Brooks',
      assigneeInitials: 'DB',
      dueDate: 'Overdue (Jan 04)',
      dueDateType: _DueDateType.overdue,
    ),
    _TaskItemData(
      id: 'task-6',
      title: 'Implement authentication UI',
      projectName: 'Mobile App v2',
      status: 'Done',
      priority: 'Urgent',
      assigneeName: 'Ava Patel',
      assigneeInitials: 'AP',
      dueDate: 'Completed Jan 06',
      dueDateType: _DueDateType.completed,
      isCompleted: true,
    ),
    _TaskItemData(
      id: 'task-7',
      title: 'Configure push notifications',
      projectName: 'Infrastructure',
      status: 'Todo',
      priority: 'Medium',
      assigneeName: 'Marcus Lee',
      assigneeInitials: 'ML',
      dueDate: 'Due Jan 18',
      dueDateType: _DueDateType.normal,
    ),
    _TaskItemData(
      id: 'task-8',
      title: 'Optimize bundle size and assets',
      projectName: 'Website Relaunch',
      status: 'Done',
      priority: 'Low',
      assigneeName: 'Elena Garcia',
      assigneeInitials: 'EG',
      dueDate: 'Completed Jan 05',
      dueDateType: _DueDateType.completed,
      isCompleted: true,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      final hasText = _searchController.text.trim().isNotEmpty;
      if (hasText != _hasSearchText) {
        setState(() => _hasSearchText = hasText);
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  bool get _hasActiveFilters =>
      _selectedStatus != 'All' ||
      _selectedPriority != 'All' ||
      _selectedAssignee != 'All' ||
      _selectedDueDate != 'All';

  void _clearAllFilters() {
    setState(() {
      _selectedStatus = 'All';
      _selectedPriority = 'All';
      _selectedAssignee = 'All';
      _selectedDueDate = 'All';
      _searchController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isTablet = constraints.maxWidth >= 720;
          final horizontalPadding = (isTablet ? AppDimensions.space32 : AppDimensions.space20).w;

          return RefreshIndicator(
            onRefresh: () async {
              setState(() => _isLoading = true);
              await Future.delayed(const Duration(milliseconds: 800));
              if (mounted) setState(() => _isLoading = false);
            },
            color: theme.colorScheme.primary,
            edgeOffset: 120.h,
            child: CustomScrollView(
              cacheExtent: 1500.0,
              physics: const AlwaysScrollableScrollPhysics(
                parent: ClampingScrollPhysics(),
              ),
              slivers: [
                // 1. Collapsing Task Header
                _buildCollapsingHeader(context, isTablet, horizontalPadding),

                // 2. Search & Sort Bar
                SliverToBoxAdapter(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1000),
                      child: Padding(
                        padding: EdgeInsets.only(
                          left: horizontalPadding,
                          right: horizontalPadding,
                          top: AppDimensions.space12.h,
                          bottom: AppDimensions.space12.h,
                        ),
                        child: _buildSearchAndSortBar(context),
                      ),
                    ),
                  ),
                ),

                // 3. Filter Buttons Row
                SliverToBoxAdapter(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1000),
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                        child: _buildFilterChipsRow(context),
                      ),
                    ),
                  ),
                ),

                // 4. Active Removable Filter Tags (if any)
                if (_hasActiveFilters)
                  SliverToBoxAdapter(
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1000),
                        child: Padding(
                          padding: EdgeInsets.only(
                            left: horizontalPadding,
                            right: horizontalPadding,
                            top: AppDimensions.space10.h,
                          ),
                          child: _buildActiveFilterTags(context),
                        ),
                      ),
                    ),
                  ),

                // Spacing before Task list
                SliverToBoxAdapter(
                  child: SizedBox(height: AppDimensions.space16.h),
                ),

                // 5. Main Task Content / Loading / Error / Empty States
                if (_isLoading)
                  SliverToBoxAdapter(
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1000),
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                          child: _buildSkeletonLoading(context),
                        ),
                      ),
                    ),
                  )
                else if (_isError)
                  SliverToBoxAdapter(
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 600),
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: horizontalPadding,
                            vertical: AppDimensions.space40.h,
                          ),
                          child: AppErrorView(
                            title: 'Unable to load tasks',
                            message: 'Something went wrong while loading your tasks.',
                            onRetry: () {
                              setState(() => _isError = false);
                            },
                          ),
                        ),
                      ),
                    ),
                  )
                else if (_allTasks.isEmpty)
                  SliverToBoxAdapter(
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 600),
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: horizontalPadding,
                            vertical: AppDimensions.space40.h,
                          ),
                          child: AppEmptyView(
                            title: 'No tasks found',
                            description: 'There are no tasks matching your current filters.',
                            actionText: 'Clear Filters',
                            onAction: _clearAllFilters,
                          ),
                        ),
                      ),
                    ),
                  )
                else
                  // Task Items List
                  SliverPadding(
                    padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                    sliver: SliverToBoxAdapter(
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 1000),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: _allTasks
                                .map(
                                  (task) => Padding(
                                    padding: EdgeInsets.only(bottom: AppDimensions.space10.h),
                                    child: _TaskCardItem(
                                      task: task,
                                      onTap: () => context.go('/tasks/${task.id}'),
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                        ),
                      ),
                    ),
                  ),

                // 6. Scroll clearance so floating bottom nav never obscures items
                SliverPadding(
                  padding: EdgeInsets.only(bottom: 108.h),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ==========================================================================
  // 1. Collapsing Task Header
  // ==========================================================================
  Widget _buildCollapsingHeader(BuildContext context, bool isTablet, double horizontalPadding) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final expandedHeight = (isTablet ? 180.0 : 165.0).h.clamp(150.0, 210.0);
    final toolbarHeight = 64.h.clamp(56.0, 72.0);

    return SliverAppBar(
      pinned: true,
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: theme.scaffoldBackgroundColor,
      expandedHeight: expandedHeight,
      toolbarHeight: toolbarHeight,
      flexibleSpace: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final topSafeArea = MediaQuery.of(context).padding.top;
          final minHeight = toolbarHeight + topSafeArea;
          final maxHeight = expandedHeight + topSafeArea;
          final currentHeight = constraints.biggest.height;
          final delta = maxHeight - minHeight;
          final progress = delta > 0 ? ((currentHeight - minHeight) / delta).clamp(0.0, 1.0) : 0.0;

          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  theme.colorScheme.primary.withValues(alpha: isDark ? 0.14 : 0.06),
                  theme.scaffoldBackgroundColor,
                ],
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // --- Collapsed Title (Fades in when scrolling up) ---
                  if (progress < 0.6)
                    Positioned(
                      left: horizontalPadding,
                      top: 16.h,
                      child: Opacity(
                        opacity: ((1.0 - progress * 1.6)).clamp(0.0, 1.0),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Tasks',
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            SizedBox(width: 8.w),
                            _buildCountBadge(context, '15'),
                          ],
                        ),
                      ),
                    ),

                  // --- Persistent Add Task Action Button (Top Right) ---
                  Positioned(
                    right: horizontalPadding,
                    top: 8.h,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton.filledTonal(
                          icon: Icon(
                            Icons.add_rounded,
                            size: AppDimensions.iconMD.r,
                            color: theme.colorScheme.primary,
                          ),
                          onPressed: () => context.go(RouteNames.createTask),
                          style: IconButton.styleFrom(
                            backgroundColor: theme.colorScheme.primary.withValues(
                              alpha: isDark ? 0.2 : 0.1,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // --- Expanded Header Content (Fades out when scrolling up) ---
                  if (progress > 0.05)
                    Positioned(
                      left: horizontalPadding,
                      right: horizontalPadding + 60.w,
                      bottom: 10.h,
                      child: Opacity(
                        opacity: progress.clamp(0.0, 1.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Pill Count Tag
                            _buildCountBadge(context, '15 tasks'),
                            SizedBox(height: 6.h),

                            // Main Title Headline
                            Text(
                              'Tasks',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.headlineMedium?.copyWith(
                                fontSize: (isTablet ? 26.0 : 22.0).sp,
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.4,
                              ),
                            ),
                            SizedBox(height: 2.h),

                            // Subtitle
                            Text(
                              'Stay organized and keep your work moving.',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                                fontSize: 12.5.sp,
                                height: 1.25,
                              ),
                            ),
                          ],
                        ),
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

  Widget _buildCountBadge(BuildContext context, String text) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: isDark ? 0.18 : 0.1),
        borderRadius: BorderRadius.circular(AppDimensions.radiusFull.r),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.3),
        ),
      ),
      child: Text(
        text,
        style: theme.textTheme.labelSmall?.copyWith(
          color: theme.colorScheme.primary,
          fontSize: 11.sp,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  // ==========================================================================
  // 2. Search and Sort Bar
  // ==========================================================================
  Widget _buildSearchAndSortBar(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Row(
      children: [
        // Search Input Field
        Expanded(
          child: Container(
            height: 44.h,
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(AppDimensions.radiusMD.r),
              border: Border.all(
                color: theme.colorScheme.outline.withValues(alpha: isDark ? 0.35 : 0.6),
                width: 1.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.shadow.withValues(alpha: isDark ? 0.15 : 0.02),
                  blurRadius: 6.r,
                  offset: Offset(0, 2.h),
                ),
              ],
            ),
            padding: EdgeInsets.symmetric(horizontal: 12.w),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  Icons.search_rounded,
                  size: AppDimensions.iconSM.r,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontSize: 13.5.sp,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Search tasks...',
                      hintStyle: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                        fontSize: 13.sp,
                      ),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
                if (_hasSearchText)
                  GestureDetector(
                    onTap: () => _searchController.clear(),
                    child: Padding(
                      padding: EdgeInsets.all(4.r),
                      child: Icon(
                        Icons.close_rounded,
                        size: 16.r,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        SizedBox(width: AppDimensions.space10.w),

        // Sort Action Button
        Material(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMD.r),
          child: InkWell(
            onTap: () => _showSortModal(context),
            borderRadius: BorderRadius.circular(AppDimensions.radiusMD.r),
            child: Container(
              height: 44.h,
              padding: EdgeInsets.symmetric(horizontal: 12.w),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppDimensions.radiusMD.r),
                border: Border.all(
                  color: theme.colorScheme.outline.withValues(alpha: isDark ? 0.35 : 0.6),
                  width: 1.0,
                ),
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.shadow.withValues(alpha: isDark ? 0.15 : 0.02),
                    blurRadius: 6.r,
                    offset: Offset(0, 2.h),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _selectedSort.icon,
                    size: 16.r,
                    color: theme.colorScheme.primary,
                  ),
                  SizedBox(width: 6.w),
                  Text(
                    'Sort',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.onSurface,
                      fontSize: 12.5.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ==========================================================================
  // 3. Filter Chips Row
  // ==========================================================================
  Widget _buildFilterChipsRow(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: [
          _FilterButton(
            label: 'Status',
            selectedLabel: _selectedStatus == 'All' ? null : _selectedStatus,
            icon: Icons.donut_large_rounded,
            onTap: () => _showStatusFilterModal(context),
          ),
          SizedBox(width: 8.w),
          _FilterButton(
            label: 'Priority',
            selectedLabel: _selectedPriority == 'All' ? null : _selectedPriority,
            icon: Icons.flag_outlined,
            onTap: () => _showPriorityFilterModal(context),
          ),
          SizedBox(width: 8.w),
          _FilterButton(
            label: 'Assignee',
            selectedLabel: _selectedAssignee == 'All' ? null : _selectedAssignee,
            icon: Icons.person_outline_rounded,
            onTap: () => _showAssigneeFilterModal(context),
          ),
          SizedBox(width: 8.w),
          _FilterButton(
            label: 'Due Date',
            selectedLabel: _selectedDueDate == 'All' ? null : _selectedDueDate,
            icon: Icons.calendar_today_rounded,
            onTap: () => _showDueDateFilterModal(context),
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // 4. Active Filter Tags
  // ==========================================================================
  Widget _buildActiveFilterTags(BuildContext context) {
    final theme = Theme.of(context);

    return Wrap(
      spacing: 6.w,
      runSpacing: 6.h,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        if (_selectedStatus != 'All')
          _ActiveFilterTag(
            label: 'Status: $_selectedStatus',
            onRemove: () => setState(() => _selectedStatus = 'All'),
          ),
        if (_selectedPriority != 'All')
          _ActiveFilterTag(
            label: 'Priority: $_selectedPriority',
            onRemove: () => setState(() => _selectedPriority = 'All'),
          ),
        if (_selectedAssignee != 'All')
          _ActiveFilterTag(
            label: 'Assignee: $_selectedAssignee',
            onRemove: () => setState(() => _selectedAssignee = 'All'),
          ),
        if (_selectedDueDate != 'All')
          _ActiveFilterTag(
            label: 'Due: $_selectedDueDate',
            onRemove: () => setState(() => _selectedDueDate = 'All'),
          ),
        TextButton(
          onPressed: _clearAllFilters,
          style: TextButton.styleFrom(
            padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(
            'Clear all',
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.primary,
              fontSize: 11.5.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  // ==========================================================================
  // Filter & Sort Bottom Sheets
  // ==========================================================================

  void _showSortModal(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _FilterBottomSheet(
        title: 'Sort Tasks By',
        content: Column(
          children: TaskSortOption.values
              .map(
                (option) => _BottomSheetRadioTile(
                  title: option.label,
                  icon: option.icon,
                  isSelected: _selectedSort == option,
                  onTap: () {
                    setState(() => _selectedSort = option);
                    Navigator.of(context).pop();
                  },
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  void _showStatusFilterModal(BuildContext context) {
    const statuses = ['All', 'Todo', 'In Progress', 'Review', 'Done'];
    String tempSelected = _selectedStatus;

    showModalBottomSheet<void>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => _FilterBottomSheet(
          title: 'Filter by Status',
          onClear: () {
            setState(() => _selectedStatus = 'All');
            Navigator.of(context).pop();
          },
          onApply: () {
            setState(() => _selectedStatus = tempSelected);
            Navigator.of(context).pop();
          },
          content: Column(
            children: statuses
                .map(
                  (status) => _BottomSheetRadioTile(
                    title: status,
                    isSelected: tempSelected == status,
                    trailing: status != 'All'
                        ? StatusBadge(status: status, showDot: false)
                        : null,
                    onTap: () => setModalState(() => tempSelected = status),
                  ),
                )
                .toList(),
          ),
        ),
      ),
    );
  }

  void _showPriorityFilterModal(BuildContext context) {
    const priorities = ['All', 'Low', 'Medium', 'High', 'Urgent'];
    String tempSelected = _selectedPriority;

    showModalBottomSheet<void>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => _FilterBottomSheet(
          title: 'Filter by Priority',
          onClear: () {
            setState(() => _selectedPriority = 'All');
            Navigator.of(context).pop();
          },
          onApply: () {
            setState(() => _selectedPriority = tempSelected);
            Navigator.of(context).pop();
          },
          content: Column(
            children: priorities
                .map(
                  (priority) => _BottomSheetRadioTile(
                    title: priority,
                    isSelected: tempSelected == priority,
                    trailing: priority != 'All'
                        ? PriorityBadge(priority: priority)
                        : null,
                    onTap: () => setModalState(() => tempSelected = priority),
                  ),
                )
                .toList(),
          ),
        ),
      ),
    );
  }

  void _showAssigneeFilterModal(BuildContext context) {
    const members = [
      ('All', ''),
      ('Ava Patel', 'AP'),
      ('Marcus Lee', 'ML'),
      ('Priya Nair', 'PN'),
      ('Daniel Brooks', 'DB'),
      ('Elena Garcia', 'EG'),
    ];
    String tempSelected = _selectedAssignee;

    showModalBottomSheet<void>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => _FilterBottomSheet(
          title: 'Filter by Assignee',
          onClear: () {
            setState(() => _selectedAssignee = 'All');
            Navigator.of(context).pop();
          },
          onApply: () {
            setState(() => _selectedAssignee = tempSelected);
            Navigator.of(context).pop();
          },
          content: Column(
            children: members
                .map(
                  (member) => _BottomSheetRadioTile(
                    title: member.$1,
                    isSelected: tempSelected == member.$1,
                    leading: member.$2.isNotEmpty
                        ? UserAvatar(
                            name: member.$1,
                            initials: member.$2,
                            size: 24.0,
                          )
                        : null,
                    onTap: () => setModalState(() => tempSelected = member.$1),
                  ),
                )
                .toList(),
          ),
        ),
      ),
    );
  }

  void _showDueDateFilterModal(BuildContext context) {
    const options = ['All', 'Today', 'Tomorrow', 'This Week', 'Overdue', 'Custom'];
    String tempSelected = _selectedDueDate;

    showModalBottomSheet<void>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => _FilterBottomSheet(
          title: 'Filter by Due Date',
          onClear: () {
            setState(() => _selectedDueDate = 'All');
            Navigator.of(context).pop();
          },
          onApply: () {
            setState(() => _selectedDueDate = tempSelected);
            Navigator.of(context).pop();
          },
          content: Column(
            children: options
                .map(
                  (option) => _BottomSheetRadioTile(
                    title: option,
                    icon: Icons.calendar_month_rounded,
                    isSelected: tempSelected == option,
                    onTap: () => setModalState(() => tempSelected = option),
                  ),
                )
                .toList(),
          ),
        ),
      ),
    );
  }

  // ==========================================================================
  // Skeleton Loading State
  // ==========================================================================
  Widget _buildSkeletonLoading(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final shimmerBase = isDark ? theme.colorScheme.surface : AppColors.borderLight;

    return Column(
      key: const ValueKey<String>('tasks_skeleton'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: List.generate(
        5,
        (index) => Padding(
          padding: EdgeInsets.only(bottom: AppDimensions.space10.h),
          child: Container(
            height: 76.h,
            decoration: BoxDecoration(
              color: shimmerBase,
              borderRadius: BorderRadius.circular(AppDimensions.radiusMD.r),
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// Private Helper Widgets (Scoped to TasksScreen only)
// ============================================================================

/// Compact filter button chip with active state support
class _FilterButton extends StatelessWidget {
  const _FilterButton({
    required this.label,
    required this.onTap,
    this.selectedLabel,
    this.icon,
  });

  final String label;
  final String? selectedLabel;
  final VoidCallback onTap;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isSelected = selectedLabel != null;

    final bgColor = isSelected
        ? theme.colorScheme.primary.withValues(alpha: isDark ? 0.2 : 0.1)
        : theme.colorScheme.surface;
    final borderColor = isSelected
        ? theme.colorScheme.primary.withValues(alpha: 0.5)
        : theme.colorScheme.outline.withValues(alpha: isDark ? 0.35 : 0.6);
    final textColor = isSelected
        ? theme.colorScheme.primary
        : theme.colorScheme.onSurfaceVariant;

    return Material(
      color: bgColor,
      borderRadius: BorderRadius.circular(AppDimensions.radiusFull.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimensions.radiusFull.r),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 7.h),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppDimensions.radiusFull.r),
            border: Border.all(color: borderColor, width: 1.0),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 14.r, color: textColor),
                SizedBox(width: 5.w),
              ],
              Text(
                selectedLabel != null ? '$label: $selectedLabel' : label,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: textColor,
                  fontSize: 12.sp,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
              SizedBox(width: 4.w),
              Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 15.r,
                color: textColor,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Active filter tag with remove icon
class _ActiveFilterTag extends StatelessWidget {
  const _ActiveFilterTag({
    required this.label,
    required this.onRemove,
  });

  final String label;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.only(left: 10.w, right: 6.w, top: 4.h, bottom: 4.h),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: isDark ? 0.18 : 0.09),
        borderRadius: BorderRadius.circular(AppDimensions.radiusFull.r),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.35),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.primary,
              fontSize: 11.5.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(width: 4.w),
          GestureDetector(
            onTap: onRemove,
            child: Icon(
              Icons.close_rounded,
              size: 14.r,
              color: theme.colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}

/// Compact, polished Task Item Row
class _TaskCardItem extends StatelessWidget {
  const _TaskCardItem({
    required this.task,
    required this.onTap,
  });

  final _TaskItemData task;
  final VoidCallback onTap;

  Color _getDueDateColor(BuildContext context, _DueDateType type) {
    final theme = Theme.of(context);
    switch (type) {
      case _DueDateType.overdue:
        return theme.colorScheme.error;
      case _DueDateType.dueSoon:
        return AppColors.warning;
      case _DueDateType.completed:
        return AppColors.success;
      case _DueDateType.normal:
        return theme.colorScheme.onSurfaceVariant;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final dueDateColor = _getDueDateColor(context, task.dueDateType);

    return Material(
      color: theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(AppDimensions.radiusMD.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMD.r),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: AppDimensions.space14.w,
            vertical: AppDimensions.space12.h,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppDimensions.radiusMD.r),
            border: Border.all(
              color: theme.colorScheme.outline.withValues(alpha: isDark ? 0.35 : 0.6),
              width: 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: theme.colorScheme.shadow.withValues(alpha: isDark ? 0.12 : 0.02),
                blurRadius: 6.r,
                offset: Offset(0, 2.h),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Top Row: Checkmark / Title + Priority ---
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status check indicator
                  Padding(
                    padding: EdgeInsets.only(top: 2.h, right: 8.w),
                    child: Icon(
                      task.isCompleted
                          ? Icons.check_circle_rounded
                          : Icons.radio_button_unchecked_rounded,
                      size: 17.r,
                      color: task.isCompleted
                          ? AppColors.success
                          : theme.colorScheme.outline.withValues(alpha: 0.8),
                    ),
                  ),
                  // Title
                  Expanded(
                    child: Text(
                      task.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                        color: task.isCompleted
                            ? theme.colorScheme.onSurfaceVariant
                            : theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  PriorityBadge(priority: task.priority),
                ],
              ),
              SizedBox(height: AppDimensions.space6.h),

              // --- Project Tag ---
              Padding(
                padding: EdgeInsets.only(left: 25.w),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.folder_outlined,
                      size: 13.r,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    SizedBox(width: 4.w),
                    Flexible(
                      child: Text(
                        task.projectName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontSize: 11.5.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: AppDimensions.space10.h),

              // --- Bottom Metadata: Assignee, Due Date, Status ---
              Padding(
                padding: EdgeInsets.only(left: 25.w),
                child: Wrap(
                  spacing: 12.w,
                  runSpacing: 6.h,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    // Assignee
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        UserAvatar(
                          name: task.assigneeName,
                          initials: task.assigneeInitials,
                          size: 18.0,
                        ),
                        SizedBox(width: 5.w),
                        Text(
                          task.assigneeName,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),

                    // Due Date
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.schedule_rounded,
                          size: 13.r,
                          color: dueDateColor,
                        ),
                        SizedBox(width: 3.w),
                        Text(
                          task.dueDate,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: dueDateColor,
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),

                    // Status Badge
                    StatusBadge(status: task.status),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Generic Filter Modal Bottom Sheet wrapper
class _FilterBottomSheet extends StatelessWidget {
  const _FilterBottomSheet({
    required this.title,
    required this.content,
    this.onClear,
    this.onApply,
  });

  final String title;
  final Widget content;
  final VoidCallback? onClear;
  final VoidCallback? onApply;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppDimensions.radiusXL.r),
        ),
        border: Border(
          top: BorderSide(
            color: theme.colorScheme.outline.withValues(alpha: isDark ? 0.35 : 0.6),
            width: 1.0,
          ),
        ),
      ),
      padding: EdgeInsets.only(
        left: AppDimensions.space20.w,
        right: AppDimensions.space20.w,
        top: AppDimensions.space12.h,
        bottom: AppDimensions.space24.h + MediaQuery.of(context).padding.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 36.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: theme.colorScheme.outline.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(AppDimensions.radiusFull.r),
              ),
            ),
          ),
          SizedBox(height: AppDimensions.space14.h),

          // Title
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: AppDimensions.space12.h),

          // Options List
          content,
          SizedBox(height: AppDimensions.space16.h),

          // Optional Action Buttons (Clear & Apply)
          if (onApply != null)
            Row(
              children: [
                if (onClear != null)
                  Expanded(
                    flex: 4,
                    child: AppButton(
                      text: 'Clear',
                      type: AppButtonType.outlined,
                      height: 44.h,
                      onPressed: onClear,
                    ),
                  ),
                if (onClear != null) SizedBox(width: AppDimensions.space12.w),
                Expanded(
                  flex: 6,
                  child: AppButton(
                    text: 'Apply',
                    height: 44.h,
                    onPressed: onApply,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

/// Radio selection row item for bottom sheets
class _BottomSheetRadioTile extends StatelessWidget {
  const _BottomSheetRadioTile({
    required this.title,
    required this.isSelected,
    required this.onTap,
    this.icon,
    this.leading,
    this.trailing,
  });

  final String title;
  final bool isSelected;
  final VoidCallback onTap;
  final IconData? icon;
  final Widget? leading;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMD.r),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 8.w),
          child: Row(
            children: [
              if (leading != null) ...[
                leading!,
                SizedBox(width: 10.w),
              ] else if (icon != null) ...[
                Icon(
                  icon,
                  size: 18.r,
                  color: isSelected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurfaceVariant,
                ),
                SizedBox(width: 10.w),
              ],
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontSize: 14.sp,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurface,
                  ),
                ),
              ),
              if (trailing != null) ...[
                trailing!,
                SizedBox(width: 8.w),
              ],
              Icon(
                isSelected
                    ? Icons.radio_button_checked_rounded
                    : Icons.radio_button_unchecked_rounded,
                size: 20.r,
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.outline.withValues(alpha: 0.6),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
