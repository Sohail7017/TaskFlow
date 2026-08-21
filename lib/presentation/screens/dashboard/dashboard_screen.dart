import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/routes/route_names.dart';
import '../../../core/theme/app_colors.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/priority_badge.dart';
import '../../widgets/common/status_badge.dart';
import '../../widgets/common/user_avatar.dart';

/// Premium, refined Home / Dashboard screen for TaskFlow
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // UI State toggles for interactive previewing
  bool _isLoading = false;

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
              await Future.delayed(const Duration(milliseconds: 900));
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
                // 1. Collapsing Reactive SliverAppBar
                _buildCollapsingHeader(context, isTablet, horizontalPadding),

                // 2. Main Content or Skeleton Loading
                if (_isLoading)
                  SliverPadding(
                    padding: EdgeInsets.symmetric(
                      horizontal: horizontalPadding,
                      vertical: AppDimensions.space20.h,
                    ),
                    sliver: SliverToBoxAdapter(
                      child: _buildSkeletonLoading(context, isTablet),
                    ),
                  )
                else ...[
                  // Statistics Overview Grid
                  SliverToBoxAdapter(
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1000),
                        child: Padding(
                          padding: EdgeInsets.only(
                            left: horizontalPadding,
                            right: horizontalPadding,
                            top: AppDimensions.space16.h,
                            bottom: AppDimensions.space24.h,
                          ),
                          child: _buildStatisticsGrid(context),
                        ),
                      ),
                    ),
                  ),

                  // Quick Actions Bar
                  SliverToBoxAdapter(
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1000),
                        child: Padding(
                          padding: EdgeInsets.only(
                            left: horizontalPadding,
                            right: horizontalPadding,
                            bottom: AppDimensions.space28.h,
                          ),
                          child: _buildQuickActions(context),
                        ),
                      ),
                    ),
                  ),

                  // Main Content: Projects & Tasks
                  SliverToBoxAdapter(
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1000),
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                          child: isTablet
                              ? Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      flex: 5,
                                      child: _buildProjectsSection(context),
                                    ),
                                    SizedBox(width: AppDimensions.space24.w),
                                    Expanded(
                                      flex: 6,
                                      child: _buildRecentTasksSection(context),
                                    ),
                                  ],
                                )
                              : Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    _buildProjectsSection(context),
                                    SizedBox(height: AppDimensions.space28.h),
                                    _buildRecentTasksSection(context),
                                  ],
                                ),
                        ),
                      ),
                    ),
                  ),
                ],

                // 3. Scroll clearance so the floating bottom nav never obscures content
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
  // 1. Collapsing Dashboard Header
  // ==========================================================================
  Widget _buildCollapsingHeader(BuildContext context, bool isTablet, double horizontalPadding) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final expandedHeight = (isTablet ? 220.0 : 200.0).h.clamp(180.0, 240.0);
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
                  // --- Collapsed Compact Title (Fades in when scrolling up) ---
                  if (progress < 0.6)
                    Positioned(
                      left: horizontalPadding,
                      top: 14.h,
                      child: Opacity(
                        opacity: ((1.0 - progress * 1.6)).clamp(0.0, 1.0),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.surface,
                                borderRadius: BorderRadius.circular(AppDimensions.radiusSM.r),
                                border: Border.all(
                                  color: theme.colorScheme.outline.withValues(alpha: isDark ? 0.4 : 0.6),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.business_rounded,
                                    size: 13.r,
                                    color: theme.colorScheme.secondary,
                                  ),
                                  SizedBox(width: 4.w),
                                  Text(
                                    'Nimbus Digital',
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      fontSize: 11.sp,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  // --- Persistent Top Actions (Notifications & User Avatar) ---
                  Positioned(
                    right: horizontalPadding,
                    top: 8.h,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            IconButton(
                              icon: Icon(
                                Icons.notifications_outlined,
                                size: AppDimensions.iconLG.r,
                              ),
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Notifications will be integrated in future milestone.',
                                      style: theme.textTheme.bodyMedium?.copyWith(
                                        color: theme.colorScheme.onPrimary,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                            // Subtle unread indicator dot
                            Positioned(
                              right: 10.w,
                              top: 10.h,
                              child: Container(
                                width: 7.r,
                                height: 7.r,
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.error,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(width: 4.w),
                        GestureDetector(
                          onTap: () => context.go(RouteNames.profile),
                          child: const UserAvatar(
                            name: 'Ava Davis',
                            initials: 'AD',
                            size: 38.0,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // --- Expanded Header Content (Fades out when scrolling up) ---
                  if (progress > 0.05)
                    Positioned(
                      left: horizontalPadding,
                      right: horizontalPadding + 90.w,
                      bottom: 10.h,
                      child: Opacity(
                        opacity: progress.clamp(0.0, 1.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Organization Badge
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.surface,
                                borderRadius: BorderRadius.circular(AppDimensions.radiusSM.r),
                                border: Border.all(
                                  color: theme.colorScheme.outline.withValues(alpha: isDark ? 0.4 : 0.6),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.business_rounded,
                                    size: 13.r,
                                    color: theme.colorScheme.secondary,
                                  ),
                                  SizedBox(width: 4.w),
                                  Text(
                                    'Nimbus Digital',
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      fontSize: 11.sp,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 6.h),

                            // Main Greeting Headline
                            Text(
                              'Good morning, Ava',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.headlineMedium?.copyWith(
                                fontSize: (isTablet ? 24.0 : 20.0).sp,
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.4,
                              ),
                            ),
                            SizedBox(height: 2.h),

                            // Subtitle
                            Text(
                              "Here's what's happening with your workspace today.",
                              maxLines: 2,
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

  // ==========================================================================
  // 2. Overview Statistics Section (No plain card feel)
  // ==========================================================================
  Widget _buildStatisticsGrid(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final stats = [
      _StatItemData(
        label: 'Total Projects',
        value: '3',
        subtext: '+1 this month',
        icon: Icons.folder_outlined,
        accentColor: theme.colorScheme.primary,
        bgColor: theme.colorScheme.primary.withValues(alpha: isDark ? 0.16 : 0.09),
      ),
      _StatItemData(
        label: 'Total Tasks',
        value: '15',
        subtext: '+3 this week',
        icon: Icons.checklist_rounded,
        accentColor: theme.colorScheme.secondary,
        bgColor: theme.colorScheme.secondary.withValues(alpha: isDark ? 0.16 : 0.09),
      ),
      _StatItemData(
        label: 'Due Soon',
        value: '4',
        subtext: 'Next 48 hours',
        icon: Icons.schedule_rounded,
        accentColor: AppColors.warning,
        bgColor: AppColors.warning.withValues(alpha: isDark ? 0.16 : 0.1),
      ),
      _StatItemData(
        label: 'Completed',
        value: '6',
        subtext: '40% done',
        icon: Icons.check_circle_outline_rounded,
        accentColor: AppColors.success,
        bgColor: AppColors.success.withValues(alpha: isDark ? 0.16 : 0.1),
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth >= 720 ? 4 : 2;
        final cardWidth = (constraints.maxWidth - ((crossAxisCount - 1) * 12.w)) / crossAxisCount;

        return Wrap(
          spacing: 12.w,
          runSpacing: 12.h,
          children: stats
              .map(
                (stat) => SizedBox(
                  width: cardWidth,
                  child: _StatCard(data: stat),
                ),
              )
              .toList(),
        );
      },
    );
  }

  // ==========================================================================
  // 3. Quick Actions Section
  // ==========================================================================
  Widget _buildQuickActions(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 5,
          child: AppButton(
            text: 'New Task',
            prefixIcon: Icons.add_rounded,
            height: 46.h,
            onPressed: () => context.go(RouteNames.createTask),
          ),
        ),
        SizedBox(width: AppDimensions.space12.w),
        Expanded(
          flex: 4,
          child: AppButton(
            text: 'New Project',
            prefixIcon: Icons.create_new_folder_outlined,
            type: AppButtonType.outlined,
            height: 46.h,
            onPressed: () => context.go(RouteNames.createProject),
          ),
        ),
      ],
    );
  }

  // ==========================================================================
  // 4. Your Projects Section
  // ==========================================================================
  Widget _buildProjectsSection(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Text(
                'Your Projects',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontSize: 17.sp,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.2,
                ),
              ),
            ),
            TextButton(
              onPressed: () => context.go(RouteNames.projects),
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'View all',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.primary,
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(width: 2.w),
                  Icon(
                    Icons.arrow_forward_rounded,
                    size: 14.r,
                    color: theme.colorScheme.primary,
                  ),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: AppDimensions.space12.h),

        // Project Card 1
        _ProjectCard(
          title: 'Website Relaunch',
          description: 'Redesign and rebuild the marketing website on the new design system.',
          taskCount: '6 Tasks',
          status: 'Active',
          progress: 0.80,
          leadingIcon: Icons.language_rounded,
          accentColor: theme.colorScheme.primary,
          onTap: () => context.go('/projects/proj-1'),
        ),
        SizedBox(height: AppDimensions.space12.h),

        // Project Card 2
        _ProjectCard(
          title: 'Mobile App v2',
          description: 'Second major release of the customer-facing mobile app.',
          taskCount: '5 Tasks',
          status: 'Active',
          progress: 0.45,
          leadingIcon: Icons.smartphone_rounded,
          accentColor: theme.colorScheme.secondary,
          onTap: () => context.go('/projects/proj-2'),
        ),
      ],
    );
  }

  // ==========================================================================
  // 5. Recent Tasks Section
  // ==========================================================================
  Widget _buildRecentTasksSection(BuildContext context) {
    final theme = Theme.of(context);

    final recentTasks = [
      const _TaskItemData(
        id: 'task-1',
        title: 'Fix broken contact form',
        projectName: 'Website Relaunch',
        status: 'Todo',
        priority: 'Urgent',
        assigneeName: 'Ava Davis',
        assigneeInitials: 'AD',
        dueDate: 'Due Jan 08',
      ),
      const _TaskItemData(
        id: 'task-2',
        title: 'Set up design tokens in Figma',
        projectName: 'Website Relaunch',
        status: 'In Progress',
        priority: 'High',
        assigneeName: 'Sarah Connor',
        assigneeInitials: 'SC',
        dueDate: 'Due Jan 10',
      ),
      const _TaskItemData(
        id: 'task-3',
        title: 'Build responsive nav component',
        projectName: 'Mobile App v2',
        status: 'Todo',
        priority: 'Medium',
        assigneeName: 'Ava Davis',
        assigneeInitials: 'AD',
        dueDate: 'Due Jan 12',
      ),
      const _TaskItemData(
        id: 'task-4',
        title: 'Write homepage copy',
        projectName: 'Website Relaunch',
        status: 'Review',
        priority: 'Low',
        assigneeName: 'Elena Rostova',
        assigneeInitials: 'ER',
        dueDate: 'Due Jan 15',
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Text(
                'Recent Tasks',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontSize: 17.sp,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.2,
                ),
              ),
            ),
            TextButton(
              onPressed: () => context.go(RouteNames.tasks),
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'View all',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.primary,
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(width: 2.w),
                  Icon(
                    Icons.arrow_forward_rounded,
                    size: 14.r,
                    color: theme.colorScheme.primary,
                  ),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: AppDimensions.space12.h),

        // Task Items List with clean compact rows
        ...recentTasks.map(
          (task) => Padding(
            padding: EdgeInsets.only(bottom: AppDimensions.space10.h),
            child: _RecentTaskItem(
              data: task,
              onTap: () => context.go('/tasks/${task.id}'),
            ),
          ),
        ),
      ],
    );
  }

  // ==========================================================================
  // Skeleton Loading Placeholders
  // ==========================================================================
  Widget _buildSkeletonLoading(BuildContext context, bool isTablet) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final shimmerBase = isDark ? theme.colorScheme.surface : AppColors.borderLight;

    return Column(
      key: const ValueKey<String>('dashboard_skeleton'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Stats Skeleton
        Row(
          children: List.generate(
            isTablet ? 4 : 2,
            (index) => Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.w),
                child: Container(
                  height: 94.h,
                  decoration: BoxDecoration(
                    color: shimmerBase,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusLG.r),
                  ),
                ),
              ),
            ),
          ),
        ),
        SizedBox(height: AppDimensions.space24.h),

        // Quick Actions Skeleton
        Container(
          height: 46.h,
          decoration: BoxDecoration(
            color: shimmerBase,
            borderRadius: BorderRadius.circular(AppDimensions.radiusMD.r),
          ),
        ),
        SizedBox(height: AppDimensions.space28.h),

        // Project Cards Skeleton
        _SkeletonBox(width: 140.w, height: 20.h),
        SizedBox(height: 12.h),
        Container(
          height: 110.h,
          decoration: BoxDecoration(
            color: shimmerBase,
            borderRadius: BorderRadius.circular(AppDimensions.radiusLG.r),
          ),
        ),
        SizedBox(height: AppDimensions.space28.h),

        // Task Items Skeleton
        _SkeletonBox(width: 140.w, height: 20.h),
        SizedBox(height: 12.h),
        ...List.generate(
          3,
          (i) => Padding(
            padding: EdgeInsets.only(bottom: 10.h),
            child: Container(
              height: 68.h,
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
// Private Helper Widgets & Models (Scoped to Dashboard only)
// ============================================================================

class _StatItemData {
  const _StatItemData({
    required this.label,
    required this.value,
    required this.subtext,
    required this.icon,
    required this.accentColor,
    required this.bgColor,
  });

  final String label;
  final String value;
  final String subtext;
  final IconData icon;
  final Color accentColor;
  final Color bgColor;
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.data,
  });

  final _StatItemData data;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppDimensions.space14.w,
        vertical: AppDimensions.space14.h,
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
            color: theme.colorScheme.shadow.withValues(alpha: isDark ? 0.2 : 0.02),
            blurRadius: 10.r,
            offset: Offset(0, 3.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Icon Badge
              Container(
                width: 32.r,
                height: 32.r,
                decoration: BoxDecoration(
                  color: data.bgColor,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusSM.r),
                ),
                child: Icon(
                  data.icon,
                  size: 16.r,
                  color: data.accentColor,
                ),
              ),
              SizedBox(width: 6.w),
              // Large Dominant Value
              Flexible(
                child: Text(
                  data.value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.4,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: AppDimensions.space12.h),

          // Label
          Text(
            data.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 2.h),

          // Subtext metric
          Text(
            data.subtext,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall?.copyWith(
              color: data.accentColor,
              fontSize: 11.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProjectCard extends StatelessWidget {
  const _ProjectCard({
    required this.title,
    required this.description,
    required this.taskCount,
    required this.status,
    required this.progress,
    required this.onTap,
    this.leadingIcon = Icons.folder_rounded,
    this.accentColor,
  });

  final String title;
  final String description;
  final String taskCount;
  final String status;
  final double progress;
  final VoidCallback onTap;
  final IconData leadingIcon;
  final Color? accentColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final percentText = '${(progress * 100).toInt()}%';
    final effectiveAccent = accentColor ?? theme.colorScheme.primary;

    return Material(
      color: theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(AppDimensions.radiusLG.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLG.r),
        child: Container(
          padding: EdgeInsets.all(AppDimensions.space16.r),
          decoration: BoxDecoration(
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
              // Top Title + Status Row
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 32.r,
                    height: 32.r,
                    decoration: BoxDecoration(
                      color: effectiveAccent.withValues(alpha: isDark ? 0.18 : 0.1),
                      borderRadius: BorderRadius.circular(AppDimensions.radiusSM.r),
                    ),
                    child: Icon(
                      leadingIcon,
                      size: 16.r,
                      color: effectiveAccent,
                    ),
                  ),
                  SizedBox(width: AppDimensions.space10.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            fontSize: 12.sp,
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 8.w),
                  StatusBadge(status: status, showDot: false),
                ],
              ),
              SizedBox(height: AppDimensions.space14.h),

              // Progress Bar & Meta
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      taskCount,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontSize: 11.5.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Flexible(
                    child: Text(
                      percentText,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: effectiveAccent,
                        fontSize: 11.5.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 6.h),
              ClipRRect(
                borderRadius: BorderRadius.circular(AppDimensions.radiusFull.r),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 5.h,
                  backgroundColor: theme.colorScheme.primaryContainer.withValues(alpha: 0.4),
                  valueColor: AlwaysStoppedAnimation<Color>(effectiveAccent),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

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
  });

  final String id;
  final String title;
  final String projectName;
  final String status;
  final String priority;
  final String assigneeName;
  final String assigneeInitials;
  final String dueDate;
}

class _RecentTaskItem extends StatelessWidget {
  const _RecentTaskItem({
    required this.data,
    required this.onTap,
  });

  final _TaskItemData data;
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
              // Top Row: Title and Priority
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      data.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontSize: 13.5.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  PriorityBadge(priority: data.priority),
                ],
              ),
              SizedBox(height: AppDimensions.space10.h),

              // Bottom Metadata
              Wrap(
                spacing: 8.w,
                runSpacing: 6.h,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  // Project Tag
                  Text.rich(
                    TextSpan(
                      children: [
                        WidgetSpan(
                          alignment: PlaceholderAlignment.middle,
                          child: Padding(
                            padding: EdgeInsets.only(right: 3.w),
                            child: Icon(
                              Icons.folder_outlined,
                              size: 13.r,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                        TextSpan(
                          text: data.projectName,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            fontSize: 11.sp,
                          ),
                        ),
                      ],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  // Status
                  StatusBadge(status: data.status),
                  // Due Date
                  Text(
                    data.dueDate,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontSize: 11.sp,
                    ),
                  ),
                  // Assignee
                  UserAvatar(
                    name: data.assigneeName,
                    initials: data.assigneeInitials,
                    size: 20.0,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SkeletonBox extends StatelessWidget {
  const _SkeletonBox({
    required this.width,
    required this.height,
  });

  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusSM.r),
      ),
    );
  }
}
