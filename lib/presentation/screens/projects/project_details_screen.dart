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

/// Sample task item for project details demonstration
class _ProjectTaskItem {
  const _ProjectTaskItem({
    required this.id,
    required this.title,
    required this.status,
    required this.priority,
    required this.assigneeName,
    required this.assigneeInitials,
    required this.dueDate,
    this.isCompleted = false,
  });

  final String id;
  final String title;
  final String status;
  final String priority;
  final String assigneeName;
  final String assigneeInitials;
  final String dueDate;
  final bool isCompleted;
}

/// Premium, production-quality Project Details Screen for TaskFlow
class ProjectDetailsScreen extends StatefulWidget {
  const ProjectDetailsScreen({
    super.key,
    required this.projectId,
  });

  final String projectId;

  @override
  State<ProjectDetailsScreen> createState() => _ProjectDetailsScreenState();
}

class _ProjectDetailsScreenState extends State<ProjectDetailsScreen> {
  // Local filter and search states for UI preview demonstration
  String _selectedTaskFilter = 'All';
  final TextEditingController _taskSearchController = TextEditingController();
  bool _isSearchVisible = false;

  // Interactive demo states
  bool _isLoading = false;
  bool _isError = false;

  // Static project presentation data
  final String _projectName = 'Website Relaunch';
  final String _projectInitials = 'WR';
  final String _projectDescription =
      'Redesign and rebuild the marketing website on the new design system.';
  final String _projectStatus = 'Active';
  final double _projectProgress = 0.83;
  final int _totalTasks = 6;
  final int _completedTasks = 5;
  final int _inProgressTasks = 1;
  final int _todoTasks = 0;

  // Static sample project tasks
  static const List<_ProjectTaskItem> _projectTasks = [
    _ProjectTaskItem(
      id: 'task-1',
      title: 'Fix broken contact form',
      status: 'In Progress',
      priority: 'Urgent',
      assigneeName: 'Ava Patel',
      assigneeInitials: 'AP',
      dueDate: 'Due Today',
    ),
    _ProjectTaskItem(
      id: 'task-3',
      title: 'Set up design tokens in Figma',
      status: 'Done',
      priority: 'High',
      assigneeName: 'Priya Nair',
      assigneeInitials: 'PN',
      dueDate: 'Completed Jan 06',
      isCompleted: true,
    ),
    _ProjectTaskItem(
      id: 'task-4',
      title: 'Write homepage copy',
      status: 'Done',
      priority: 'Low',
      assigneeName: 'Elena Garcia',
      assigneeInitials: 'EG',
      dueDate: 'Completed Jan 05',
      isCompleted: true,
    ),
    _ProjectTaskItem(
      id: 'task-8',
      title: 'Optimize bundle size and assets',
      status: 'Done',
      priority: 'Low',
      assigneeName: 'Elena Garcia',
      assigneeInitials: 'EG',
      dueDate: 'Completed Jan 05',
      isCompleted: true,
    ),
    _ProjectTaskItem(
      id: 'task-9',
      title: 'Implement responsive layout for mobile',
      status: 'Done',
      priority: 'Medium',
      assigneeName: 'Marcus Lee',
      assigneeInitials: 'ML',
      dueDate: 'Completed Jan 04',
      isCompleted: true,
    ),
    _ProjectTaskItem(
      id: 'task-10',
      title: 'Setup Google Analytics 4 tags',
      status: 'Done',
      priority: 'Low',
      assigneeName: 'Daniel Brooks',
      assigneeInitials: 'DB',
      dueDate: 'Completed Jan 03',
      isCompleted: true,
    ),
  ];

  @override
  void dispose() {
    _taskSearchController.dispose();
    super.dispose();
  }

  void _showDeleteDialog(BuildContext context) {
    final theme = Theme.of(context);

    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusXL.r),
        ),
        title: Text(
          'Delete project?',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
            fontSize: 18.sp,
          ),
        ),
        content: Text(
          'Are you sure you want to delete $_projectName? This action cannot be undone and all associated tasks will be removed.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            fontSize: 13.5.sp,
            height: 1.4,
          ),
        ),
        actionsPadding: EdgeInsets.only(
          left: AppDimensions.space20.w,
          right: AppDimensions.space20.w,
          bottom: AppDimensions.space16.h,
        ),
        actions: [
          AppButton(
            text: 'Cancel',
            type: AppButtonType.outlined,
            isFullWidth: false,
            height: 38.h,
            onPressed: () => Navigator.of(context).pop(),
          ),
          SizedBox(width: 8.w),
          AppButton(
            text: 'Delete',
            isDestructive: true,
            isFullWidth: false,
            height: 38.h,
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Project deletion is UI-only in this demo.'),
                ),
              );
            },
          ),
        ],
      ),
    );
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
                // 1. Collapsing Project Header
                _buildCollapsingHeader(context, isTablet, horizontalPadding),

                // 2. Main Project Content / Loading / Error / Empty States
                if (_isLoading)
                  SliverToBoxAdapter(
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1000),
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: horizontalPadding,
                            vertical: AppDimensions.space16.h,
                          ),
                          child: _buildSkeletonLoading(context, isTablet),
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
                            title: 'Unable to load project',
                            message: 'Something went wrong while loading this project details.',
                            onRetry: () {
                              setState(() => _isError = false);
                            },
                          ),
                        ),
                      ),
                    ),
                  )
                else ...[
                  // Progress & Overview Statistics Section
                  SliverToBoxAdapter(
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1000),
                        child: Padding(
                          padding: EdgeInsets.only(
                            left: horizontalPadding,
                            right: horizontalPadding,
                            top: AppDimensions.space16.h,
                            bottom: AppDimensions.space20.h,
                          ),
                          child: isTablet
                              ? _buildTabletOverviewSection(context)
                              : _buildMobileOverviewSection(context),
                        ),
                      ),
                    ),
                  ),

                  // Status Distribution Breakdown
                  SliverToBoxAdapter(
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1000),
                        child: Padding(
                          padding: EdgeInsets.only(
                            left: horizontalPadding,
                            right: horizontalPadding,
                            bottom: AppDimensions.space24.h,
                          ),
                          child: _buildStatusDistributionBar(context),
                        ),
                      ),
                    ),
                  ),

                  // Tasks Section Header & Filter/Search Controls
                  SliverToBoxAdapter(
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1000),
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                          child: _buildTasksSectionHeader(context),
                        ),
                      ),
                    ),
                  ),

                  SliverToBoxAdapter(
                    child: SizedBox(height: AppDimensions.space12.h),
                  ),

                  // Project Tasks List
                  if (_projectTasks.isEmpty)
                    SliverToBoxAdapter(
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 600),
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: horizontalPadding,
                              vertical: AppDimensions.space32.h,
                            ),
                            child: AppEmptyView(
                              title: 'No tasks yet',
                              description: "This project doesn't have any tasks.",
                              actionText: 'Create Task',
                              onAction: () => context.go(RouteNames.createTask),
                            ),
                          ),
                        ),
                      ),
                    )
                  else
                    SliverPadding(
                      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                      sliver: SliverToBoxAdapter(
                        child: Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 1000),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: _projectTasks
                                  .map(
                                    (task) => Padding(
                                      padding: EdgeInsets.only(bottom: AppDimensions.space10.h),
                                      child: _ProjectTaskCardItem(
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
                ],

                // 3. Scroll clearance so floating bottom nav never obscures content
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
  // 1. Collapsing Project Details Header
  // ==========================================================================
  Widget _buildCollapsingHeader(BuildContext context, bool isTablet, double horizontalPadding) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final expandedHeight = (isTablet ? 210.0 : 190.0).h.clamp(170.0, 230.0);
    final toolbarHeight = 64.h.clamp(56.0, 72.0);

    return SliverAppBar(
      pinned: true,
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: theme.scaffoldBackgroundColor,
      expandedHeight: expandedHeight,
      toolbarHeight: toolbarHeight,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_rounded),
        tooltip: 'Back to Projects',
        onPressed: () {
          if (context.canPop()) {
            context.pop();
          } else {
            context.go(RouteNames.projects);
          }
        },
      ),
      actions: [
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert_rounded),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusMD.r),
          ),
          onSelected: (value) {
            if (value == 'edit') {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Edit Project modal will open here.'),
                ),
              );
            } else if (value == 'delete') {
              _showDeleteDialog(context);
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(
                    Icons.edit_outlined,
                    size: 18.r,
                    color: theme.colorScheme.onSurface,
                  ),
                  SizedBox(width: 8.w),
                  Text('Edit Project', style: theme.textTheme.bodyMedium),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(
                    Icons.delete_outline_rounded,
                    size: 18.r,
                    color: theme.colorScheme.error,
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    'Delete Project',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.error,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        SizedBox(width: 4.w),
      ],
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
                  // --- Collapsed Compact Title (Fades in when scrolling up) ---
                  if (progress < 0.5)
                    Positioned(
                      left: 56.w,
                      right: 60.w,
                      top: 18.h,
                      child: Opacity(
                        opacity: ((1.0 - progress * 2.0)).clamp(0.0, 1.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                _projectName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontSize: 16.5.sp,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            SizedBox(width: 8.w),
                            StatusBadge(status: _projectStatus, showDot: false),
                          ],
                        ),
                      ),
                    ),

                  // --- Expanded Header Content (Fades out when scrolling up) ---
                  if (progress > 0.05)
                    Positioned(
                      left: horizontalPadding,
                      right: horizontalPadding,
                      bottom: 12.h,
                      child: Opacity(
                        opacity: progress.clamp(0.0, 1.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Project Initials Badge + Status Row
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  width: 38.r,
                                  height: 38.r,
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.primary.withValues(
                                      alpha: isDark ? 0.22 : 0.12,
                                    ),
                                    borderRadius: BorderRadius.circular(AppDimensions.radiusSM.r),
                                    border: Border.all(
                                      color: theme.colorScheme.primary.withValues(alpha: 0.35),
                                    ),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    _projectInitials,
                                    style: theme.textTheme.labelLarge?.copyWith(
                                      color: theme.colorScheme.primary,
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                                StatusBadge(status: _projectStatus, showDot: true),
                              ],
                            ),
                            SizedBox(height: 8.h),

                            // Main Title Headline
                            Text(
                              _projectName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.headlineMedium?.copyWith(
                                fontSize: (isTablet ? 24.0 : 21.0).sp,
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.4,
                              ),
                            ),
                            SizedBox(height: 3.h),

                            // Description
                            Text(
                              _projectDescription,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                                fontSize: 12.5.sp,
                                height: 1.3,
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

  // ==========================================================================
  // 2. Progress & Overview Statistics
  // ==========================================================================
  Widget _buildMobileOverviewSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildProgressCard(context),
        SizedBox(height: AppDimensions.space12.h),
        _buildStatisticsGrid(context),
      ],
    );
  }

  Widget _buildTabletOverviewSection(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 5,
          child: _buildProgressCard(context),
        ),
        SizedBox(width: AppDimensions.space16.w),
        Expanded(
          flex: 6,
          child: _buildStatisticsGrid(context),
        ),
      ],
    );
  }

  Widget _buildProgressCard(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final percentText = '${(_projectProgress * 100).toInt()}%';

    return Container(
      padding: EdgeInsets.all(AppDimensions.space16.r),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLG.r),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: isDark ? 0.35 : 0.6),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: isDark ? 0.15 : 0.02),
            blurRadius: 8.r,
            offset: Offset(0, 2.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Project progress',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 14.sp,
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              Text(
                percentText,
                style: theme.textTheme.titleSmall?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w700,
                  fontSize: 14.sp,
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),

          // Slim Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(AppDimensions.radiusFull.r),
            child: LinearProgressIndicator(
              value: _projectProgress,
              minHeight: 6.h,
              backgroundColor: theme.colorScheme.primaryContainer.withValues(alpha: 0.4),
              valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
            ),
          ),
          SizedBox(height: 8.h),

          Text(
            '$_completedTasks of $_totalTasks tasks completed',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsGrid(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final stats = [
      _StatBlock(
        label: 'Tasks',
        value: '$_totalTasks',
        icon: Icons.checklist_rounded,
        color: theme.colorScheme.primary,
      ),
      _StatBlock(
        label: 'Done',
        value: '$_completedTasks',
        icon: Icons.check_circle_rounded,
        color: AppColors.success,
      ),
      _StatBlock(
        label: 'Active',
        value: '$_inProgressTasks',
        icon: Icons.hourglass_bottom_rounded,
        color: theme.colorScheme.secondary,
      ),
      _StatBlock(
        label: 'Todo',
        value: '$_todoTasks',
        icon: Icons.radio_button_unchecked_rounded,
        color: AppColors.warning,
      ),
    ];

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppDimensions.space12.w,
        vertical: AppDimensions.space12.h,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLG.r),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: isDark ? 0.35 : 0.6),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: isDark ? 0.15 : 0.02),
            blurRadius: 8.r,
            offset: Offset(0, 2.h),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: stats
            .map(
              (stat) => Flexible(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: EdgeInsets.all(6.r),
                      decoration: BoxDecoration(
                        color: stat.color.withValues(alpha: isDark ? 0.18 : 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(stat.icon, size: 15.r, color: stat.color),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      stat.value,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      stat.label,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  // ==========================================================================
  // 3. Status Distribution Breakdown
  // ==========================================================================
  Widget _buildStatusDistributionBar(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final breakdownItems = [
      ('Todo', '0', AppColors.statusTodo),
      ('In Progress', '1', theme.colorScheme.secondary),
      ('Review', '0', AppColors.statusReview),
      ('Done', '5', AppColors.statusDone),
    ];

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppDimensions.space14.w,
        vertical: AppDimensions.space10.h,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMD.r),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: isDark ? 0.35 : 0.6),
          width: 1.0,
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(
          children: breakdownItems
              .map(
                (item) => Padding(
                  padding: EdgeInsets.only(right: 14.w),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 7.r,
                        height: 7.r,
                        decoration: BoxDecoration(
                          color: item.$3,
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: 5.w),
                      Text(
                        '${item.$1}: ',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontSize: 11.5.sp,
                        ),
                      ),
                      Text(
                        item.$2,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface,
                          fontSize: 11.5.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  // ==========================================================================
  // 4. Tasks Section Header & Filter Controls
  // ==========================================================================
  Widget _buildTasksSectionHeader(BuildContext context) {
    final theme = Theme.of(context);
    final filters = ['All', 'Todo', 'In Progress', 'Review', 'Done'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Title Row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: Text(
                      'Project Tasks',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontSize: 17.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 2.h),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppDimensions.radiusFull.r),
                    ),
                    child: Text(
                      '$_totalTasks',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.primary,
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 8.w),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(
                    _isSearchVisible ? Icons.close_rounded : Icons.search_rounded,
                    size: 19.r,
                  ),
                  tooltip: 'Search tasks',
                  onPressed: () {
                    setState(() {
                      _isSearchVisible = !_isSearchVisible;
                      if (!_isSearchVisible) _taskSearchController.clear();
                    });
                  },
                ),
                SizedBox(width: 2.w),
                AppButton(
                  text: 'New Task',
                  prefixIcon: Icons.add_rounded,
                  height: 36.h,
                  isFullWidth: false,
                  onPressed: () => context.go(RouteNames.createTask),
                ),
              ],
            ),
          ],
        ),

        // Optional Search Input
        if (_isSearchVisible) ...[
          SizedBox(height: 8.h),
          Container(
            height: 40.h,
            padding: EdgeInsets.symmetric(horizontal: 10.w),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(AppDimensions.radiusMD.r),
              border: Border.all(
                color: theme.colorScheme.outline.withValues(alpha: 0.5),
              ),
            ),
            child: TextField(
              controller: _taskSearchController,
              style: theme.textTheme.bodyMedium?.copyWith(fontSize: 13.sp),
              decoration: InputDecoration(
                hintText: 'Search project tasks...',
                hintStyle: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                  fontSize: 12.5.sp,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: 10.h),
              ),
            ),
          ),
        ],
        SizedBox(height: 10.h),

        // Filter Tabs
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: filters
                .map(
                  (filter) => Padding(
                    padding: EdgeInsets.only(right: 6.w),
                    child: _TaskFilterChip(
                      label: filter,
                      isSelected: _selectedTaskFilter == filter,
                      onTap: () => setState(() => _selectedTaskFilter = filter),
                    ),
                  ),
                )
                .toList(),
          ),
        ),
      ],
    );
  }

  // ==========================================================================
  // Skeleton Loading State
  // ==========================================================================
  Widget _buildSkeletonLoading(BuildContext context, bool isTablet) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final shimmerBase = isDark ? theme.colorScheme.surface : AppColors.borderLight;

    return Column(
      key: const ValueKey<String>('project_details_skeleton'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          height: 80.h,
          decoration: BoxDecoration(
            color: shimmerBase,
            borderRadius: BorderRadius.circular(AppDimensions.radiusLG.r),
          ),
        ),
        SizedBox(height: 12.h),
        Container(
          height: 60.h,
          decoration: BoxDecoration(
            color: shimmerBase,
            borderRadius: BorderRadius.circular(AppDimensions.radiusMD.r),
          ),
        ),
        SizedBox(height: 20.h),
        ...List.generate(
          3,
          (i) => Padding(
            padding: EdgeInsets.only(bottom: 10.h),
            child: Container(
              height: 72.h,
              decoration: BoxDecoration(
                color: shimmerBase,
                borderRadius: BorderRadius.circular(AppDimensions.radiusMD.r),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ============================================================================
// Private Helper Widgets (Scoped to ProjectDetailsScreen only)
// ============================================================================

class _StatBlock {
  const _StatBlock({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;
}

class _TaskFilterChip extends StatelessWidget {
  const _TaskFilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

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
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppDimensions.radiusFull.r),
            border: Border.all(color: borderColor, width: 1.0),
          ),
          child: Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              color: textColor,
              fontSize: 11.5.sp,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}

class _ProjectTaskCardItem extends StatelessWidget {
  const _ProjectTaskCardItem({
    required this.task,
    required this.onTap,
  });

  final _ProjectTaskItem task;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Material(
      color: theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(AppDimensions.radiusMD.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMD.r),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: AppDimensions.space12.w,
            vertical: AppDimensions.space12.h,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppDimensions.radiusMD.r),
            border: Border.all(
              color: theme.colorScheme.outline.withValues(alpha: isDark ? 0.35 : 0.6),
              width: 1.0,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Row: Checkmark / Title + Priority
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(top: 2.h, right: 8.w),
                    child: Icon(
                      task.isCompleted
                          ? Icons.check_circle_rounded
                          : Icons.radio_button_unchecked_rounded,
                      size: 16.r,
                      color: task.isCompleted
                          ? AppColors.success
                          : theme.colorScheme.outline.withValues(alpha: 0.8),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      task.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontSize: 13.5.sp,
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
              SizedBox(height: AppDimensions.space10.h),

              // Bottom Metadata
              Padding(
                padding: EdgeInsets.only(left: 24.w),
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
                    Text(
                      task.dueDate,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: task.isCompleted
                            ? AppColors.success
                            : theme.colorScheme.onSurfaceVariant,
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w500,
                      ),
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
