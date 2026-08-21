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

/// Activity timeline model for demonstration
class _ActivityEntry {
  const _ActivityEntry({
    required this.id,
    required this.userName,
    required this.userInitials,
    required this.action,
    required this.timestamp,
    this.commentText,
    this.icon = Icons.circle,
  });

  final String id;
  final String userName;
  final String userInitials;
  final String action;
  final String timestamp;
  final String? commentText;
  final IconData icon;
}

/// Team member model for assignment selector
class _TeamMember {
  const _TeamMember({
    required this.name,
    required this.initials,
    required this.role,
  });

  final String name;
  final String initials;
  final String role;
}

/// Premium, production-quality Task Details Screen for TaskFlow
class TaskDetailsScreen extends StatefulWidget {
  const TaskDetailsScreen({
    super.key,
    required this.taskId,
  });

  final String taskId;

  @override
  State<TaskDetailsScreen> createState() => _TaskDetailsScreenState();
}

class _TaskDetailsScreenState extends State<TaskDetailsScreen> {
  // Local presentation state for UI preview
  final String _taskTitle = 'Fix broken contact form';
  String _currentStatus = 'In Progress';
  String _currentPriority = 'Urgent';
  bool _isCompleted = false;
  DateTime _dueDate = DateTime(2026, 1, 8);

  _TeamMember _assignedMember = const _TeamMember(
    name: 'Ava Patel',
    initials: 'AP',
    role: 'Lead Designer & Dev',
  );

  final String _projectName = 'Website Relaunch';
  final String _projectId = 'proj-1';
  final String _projectDescription =
      'Redesign and rebuild the marketing website on the new design system.';

  final String _taskDescription =
      'The contact form on the marketing website is currently failing to submit successfully for some users. Investigate the issue, identify the root cause, and ensure submissions work reliably across supported devices and browsers.';

  // Comment input
  final TextEditingController _commentController = TextEditingController();

  // Activity list (modifiable locally for comment demonstration)
  late List<_ActivityEntry> _activities;

  // Interactive demo states
  bool _isLoading = false;
  bool _isError = false;

  // Static organization members
  static const List<_TeamMember> _teamMembers = [
    _TeamMember(name: 'Ava Patel', initials: 'AP', role: 'Lead Designer & Dev'),
    _TeamMember(name: 'Marcus Lee', initials: 'ML', role: 'Full-Stack Engineer'),
    _TeamMember(name: 'Priya Nair', initials: 'PN', role: 'Product Design Lead'),
    _TeamMember(name: 'Daniel Brooks', initials: 'DB', role: 'QA & DevOps Engineer'),
    _TeamMember(name: 'Elena Garcia', initials: 'EG', role: 'Content Strategist'),
  ];

  @override
  void initState() {
    super.initState();
    _activities = [
      const _ActivityEntry(
        id: 'act-1',
        userName: 'Ava Patel',
        userInitials: 'AP',
        action: 'Moved task to In Progress',
        timestamp: '2 hours ago',
        icon: Icons.play_arrow_rounded,
      ),
      const _ActivityEntry(
        id: 'act-2',
        userName: 'Marcus Lee',
        userInitials: 'ML',
        action: 'Added a comment',
        commentText: 'Investigated the CORS policy on staging endpoint. Looking into SSL certificate next.',
        timestamp: 'Yesterday',
        icon: Icons.chat_bubble_outline_rounded,
      ),
      const _ActivityEntry(
        id: 'act-3',
        userName: 'Priya Nair',
        userInitials: 'PN',
        action: 'Changed priority to Urgent',
        timestamp: '2 days ago',
        icon: Icons.flag_outlined,
      ),
    ];
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final day = date.day.toString().padLeft(2, '0');
    final month = months[date.month - 1];
    final year = date.year;
    return '$day $month $year';
  }

  void _handleAddComment() {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _activities.insert(
        0,
        _ActivityEntry(
          id: 'act-${DateTime.now().millisecondsSinceEpoch}',
          userName: 'Ava Patel',
          userInitials: 'AP',
          action: 'Added a comment',
          commentText: text,
          timestamp: 'Just now',
          icon: Icons.chat_bubble_outline_rounded,
        ),
      );
      _commentController.clear();
    });
    FocusScope.of(context).unfocus();
  }

  void _toggleCompleted() {
    setState(() {
      _isCompleted = !_isCompleted;
      if (_isCompleted) {
        _currentStatus = 'Done';
      } else {
        _currentStatus = 'In Progress';
      }
    });
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
          'Delete task?',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
            fontSize: 18.sp,
          ),
        ),
        content: Text(
          'Are you sure you want to delete "$_taskTitle"? This action cannot be undone.',
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
                  content: Text('Task deletion is UI-only in this demo.'),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Future<void> _selectDueDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );
    if (picked != null) {
      setState(() => _dueDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isTablet = constraints.maxWidth >= 840;
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

                // 2. Main Task Details Content / Loading / Error States
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
                            title: 'Unable to load task',
                            message: 'Something went wrong while loading this task details.',
                            onRetry: () => setState(() => _isError = false),
                          ),
                        ),
                      ),
                    ),
                  )
                else ...[
                  // Quick Actions Bar (Mark Done, Status/Priority selectors, etc.)
                  SliverToBoxAdapter(
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1000),
                        child: Padding(
                          padding: EdgeInsets.only(
                            left: horizontalPadding,
                            right: horizontalPadding,
                            top: AppDimensions.space16.h,
                            bottom: AppDimensions.space16.h,
                          ),
                          child: _buildQuickActionBar(context),
                        ),
                      ),
                    ),
                  ),

                  // Main Content Layout (Responsive Tablet 2-Column / Mobile Stack)
                  SliverToBoxAdapter(
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1000),
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                          child: isTablet
                              ? _buildTabletLayout(context)
                              : _buildMobileLayout(context),
                        ),
                      ),
                    ),
                  ),

                  // Activity Timeline & Comments Section
                  SliverToBoxAdapter(
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1000),
                        child: Padding(
                          padding: EdgeInsets.only(
                            left: horizontalPadding,
                            right: horizontalPadding,
                            top: AppDimensions.space20.h,
                            bottom: AppDimensions.space16.h,
                          ),
                          child: _buildActivitySection(context),
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
  // 1. Collapsing Task Header
  // ==========================================================================
  Widget _buildCollapsingHeader(BuildContext context, bool isTablet, double horizontalPadding) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final expandedHeight = (isTablet ? 190.0 : 175.0).h.clamp(155.0, 215.0);
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
        tooltip: 'Back to Tasks',
        onPressed: () {
          if (context.canPop()) {
            context.pop();
          } else {
            context.go(RouteNames.tasks);
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
              context.go('/tasks/${widget.taskId}/edit');
            } else if (value == 'delete') {
              _showDeleteDialog(context);
            } else if (value == 'duplicate') {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Task duplicated successfully.')),
              );
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit_outlined, size: 18.r, color: theme.colorScheme.onSurface),
                  SizedBox(width: 8.w),
                  Text('Edit Task', style: theme.textTheme.bodyMedium),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'duplicate',
              child: Row(
                children: [
                  Icon(Icons.copy_rounded, size: 18.r, color: theme.colorScheme.onSurface),
                  SizedBox(width: 8.w),
                  Text('Duplicate Task', style: theme.textTheme.bodyMedium),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete_outline_rounded, size: 18.r, color: theme.colorScheme.error),
                  SizedBox(width: 8.w),
                  Text(
                    'Delete Task',
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
                        child: Text(
                          _taskTitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontSize: 16.5.sp,
                            fontWeight: FontWeight.w700,
                            decoration: _isCompleted ? TextDecoration.lineThrough : null,
                          ),
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
                            // Project Folder Pill Tag
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.folder_outlined,
                                  size: 14.r,
                                  color: theme.colorScheme.primary,
                                ),
                                SizedBox(width: 5.w),
                                Flexible(
                                  child: Text(
                                    _projectName,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: theme.textTheme.labelMedium?.copyWith(
                                      color: theme.colorScheme.primary,
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 6.h),

                            // Main Task Title Headline
                            Text(
                              _taskTitle,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.headlineMedium?.copyWith(
                                fontSize: (isTablet ? 22.0 : 19.5).sp,
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.3,
                                decoration: _isCompleted ? TextDecoration.lineThrough : null,
                              ),
                            ),
                            SizedBox(height: 6.h),

                            // Status & Priority Badges Row
                            Row(
                              children: [
                                StatusBadge(status: _currentStatus, showDot: true),
                                SizedBox(width: 8.w),
                                PriorityBadge(priority: _currentPriority),
                              ],
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
  // 2. Quick Action / Interactive Toggle Bar
  // ==========================================================================
  Widget _buildQuickActionBar(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
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
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Completion Toggle
            InkWell(
              onTap: _toggleCompleted,
              borderRadius: BorderRadius.circular(AppDimensions.radiusSM.r),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 4.h),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedContainer(
                      duration: AppAnimations.fast,
                      width: 22.r,
                      height: 22.r,
                      decoration: BoxDecoration(
                        color: _isCompleted ? AppColors.success : Colors.transparent,
                        borderRadius: BorderRadius.circular(AppDimensions.radiusSM.r),
                        border: Border.all(
                          color: _isCompleted
                              ? AppColors.success
                              : theme.colorScheme.outline.withValues(alpha: 0.8),
                          width: 1.5,
                        ),
                      ),
                      child: _isCompleted
                          ? Icon(Icons.check_rounded, size: 16.r, color: Colors.white)
                          : null,
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      _isCompleted ? 'Completed' : 'Mark Complete',
                      style: theme.textTheme.labelMedium?.copyWith(
                        fontSize: 12.5.sp,
                        fontWeight: FontWeight.w600,
                        color: _isCompleted ? AppColors.success : theme.colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(width: 16.w),

            // Interactive Status & Priority Quick Dropdowns
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildInteractiveBadgeChip(
                  context,
                  label: _currentStatus,
                  icon: Icons.donut_large_rounded,
                  onTap: () => _showStatusModal(context),
                ),
                SizedBox(width: 8.w),
                _buildInteractiveBadgeChip(
                  context,
                  label: _currentPriority,
                  icon: Icons.flag_outlined,
                  onTap: () => _showPriorityModal(context),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInteractiveBadgeChip(
    BuildContext context, {
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Material(
      color: theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(AppDimensions.radiusFull.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimensions.radiusFull.r),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppDimensions.radiusFull.r),
            border: Border.all(
              color: theme.colorScheme.outline.withValues(alpha: isDark ? 0.35 : 0.6),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 13.r, color: theme.colorScheme.primary),
              SizedBox(width: 4.w),
              Text(
                label,
                style: theme.textTheme.labelSmall?.copyWith(
                  fontSize: 11.5.sp,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              SizedBox(width: 2.w),
              Icon(
                Icons.arrow_drop_down_rounded,
                size: 16.r,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================================================
  // Layout Variations (Mobile & Tablet)
  // ==========================================================================
  Widget _buildMobileLayout(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildDescriptionCard(context),
        SizedBox(height: AppDimensions.space14.h),
        _buildProjectInfoCard(context),
        SizedBox(height: AppDimensions.space14.h),
        _buildAssigneeCard(context),
        SizedBox(height: AppDimensions.space14.h),
        _buildDueDateCard(context),
      ],
    );
  }

  Widget _buildTabletLayout(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left Column (Description & Project Info)
        Expanded(
          flex: 6,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildDescriptionCard(context),
              SizedBox(height: AppDimensions.space14.h),
              _buildProjectInfoCard(context),
            ],
          ),
        ),
        SizedBox(width: AppDimensions.space16.w),
        // Right Column (Assignee & Due Date)
        Expanded(
          flex: 5,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildAssigneeCard(context),
              SizedBox(height: AppDimensions.space14.h),
              _buildDueDateCard(context),
            ],
          ),
        ),
      ],
    );
  }

  // ==========================================================================
  // Description Card
  // ==========================================================================
  Widget _buildDescriptionCard(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.all(AppDimensions.space16.r),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLG.r),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: isDark ? 0.35 : 0.6),
          width: 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Description',
            style: theme.textTheme.titleSmall?.copyWith(
              fontSize: 14.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            _taskDescription,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontSize: 13.5.sp,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // Project Information Card
  // ==========================================================================
  Widget _buildProjectInfoCard(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Material(
      color: theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(AppDimensions.radiusLG.r),
      child: InkWell(
        onTap: () => context.go('/projects/$_projectId'),
        borderRadius: BorderRadius.circular(AppDimensions.radiusLG.r),
        child: Container(
          padding: EdgeInsets.all(AppDimensions.space16.r),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppDimensions.radiusLG.r),
            border: Border.all(
              color: theme.colorScheme.outline.withValues(alpha: isDark ? 0.35 : 0.6),
              width: 1.0,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 38.r,
                height: 38.r,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: isDark ? 0.22 : 0.12),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusSM.r),
                ),
                alignment: Alignment.center,
                child: Icon(
                  Icons.folder_open_rounded,
                  size: 20.r,
                  color: theme.colorScheme.primary,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Project',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      _projectName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontSize: 14.5.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      _projectDescription,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontSize: 11.5.sp,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                size: 20.r,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================================================
  // Assignee Card
  // ==========================================================================
  Widget _buildAssigneeCard(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Material(
      color: theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(AppDimensions.radiusLG.r),
      child: InkWell(
        onTap: () => _showAssigneeModal(context),
        borderRadius: BorderRadius.circular(AppDimensions.radiusLG.r),
        child: Container(
          padding: EdgeInsets.all(AppDimensions.space16.r),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppDimensions.radiusLG.r),
            border: Border.all(
              color: theme.colorScheme.outline.withValues(alpha: isDark ? 0.35 : 0.6),
              width: 1.0,
            ),
          ),
          child: Row(
            children: [
              UserAvatar(
                name: _assignedMember.name,
                initials: _assignedMember.initials,
                size: 38.0,
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Assignee',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      _assignedMember.name,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontSize: 14.5.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      _assignedMember.role,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontSize: 11.5.sp,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                'Change',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                size: 18.r,
                color: theme.colorScheme.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================================================
  // Due Date Card
  // ==========================================================================
  Widget _buildDueDateCard(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Material(
      color: theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(AppDimensions.radiusLG.r),
      child: InkWell(
        onTap: () => _selectDueDate(context),
        borderRadius: BorderRadius.circular(AppDimensions.radiusLG.r),
        child: Container(
          padding: EdgeInsets.all(AppDimensions.space16.r),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppDimensions.radiusLG.r),
            border: Border.all(
              color: theme.colorScheme.outline.withValues(alpha: isDark ? 0.35 : 0.6),
              width: 1.0,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 38.r,
                height: 38.r,
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: isDark ? 0.22 : 0.12),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusSM.r),
                ),
                alignment: Alignment.center,
                child: Icon(
                  Icons.calendar_today_rounded,
                  size: 18.r,
                  color: AppColors.warning,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Due date',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      _formatDate(_dueDate),
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontSize: 14.5.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              Flexible(
                flex: 0,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withValues(alpha: isDark ? 0.2 : 0.1),
                    borderRadius: BorderRadius.circular(AppDimensions.radiusFull.r),
                  ),
                  child: Text(
                    'Due Soon',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: AppColors.warning,
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================================================
  // Activity & Comments Section
  // ==========================================================================
  Widget _buildActivitySection(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.all(AppDimensions.space16.r),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLG.r),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: isDark ? 0.35 : 0.6),
          width: 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Activity & Comments',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              Text(
                '${_activities.length} entries',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontSize: 12.sp,
                ),
              ),
            ],
          ),
          SizedBox(height: AppDimensions.space16.h),

          // Timeline Entries
          if (_activities.isEmpty)
            const AppEmptyView(
              title: 'No activity yet',
              description: 'Updates and comments will appear here.',
            )
          else
            ...List.generate(_activities.length, (index) {
              final activity = _activities[index];
              final isLast = index == _activities.length - 1;

              return IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Avatar & Vertical Connector Line
                    Column(
                      children: [
                        UserAvatar(
                          name: activity.userName,
                          initials: activity.userInitials,
                          size: 26.0,
                        ),
                        if (!isLast)
                          Expanded(
                            child: Container(
                              width: 1.5,
                              margin: EdgeInsets.symmetric(vertical: 4.h),
                              color: theme.colorScheme.outline.withValues(alpha: 0.4),
                            ),
                          ),
                      ],
                    ),
                    SizedBox(width: 12.w),

                    // Description & Content
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(bottom: isLast ? 12.h : 20.h),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    activity.userName,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: theme.textTheme.labelMedium?.copyWith(
                                      fontSize: 13.sp,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 6.w),
                                Text(
                                  '• ${activity.timestamp}',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                    fontSize: 11.sp,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 2.h),
                            Text(
                              activity.action,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                                fontSize: 12.5.sp,
                              ),
                            ),
                            if (activity.commentText != null) ...[
                              SizedBox(height: 6.h),
                              Container(
                                padding: EdgeInsets.all(10.r),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.surfaceContainerHighest.withValues(
                                    alpha: isDark ? 0.3 : 0.5,
                                  ),
                                  borderRadius: BorderRadius.circular(AppDimensions.radiusMD.r),
                                ),
                                child: Text(
                                  activity.commentText!,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontSize: 13.sp,
                                    height: 1.35,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),

          SizedBox(height: AppDimensions.space10.h),

          // Add Comment Input Box
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 44.h,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusMD.r),
                    border: Border.all(
                      color: theme.colorScheme.outline.withValues(alpha: isDark ? 0.35 : 0.6),
                    ),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 12.w),
                  child: Row(
                    children: [
                      Icon(
                        Icons.chat_bubble_outline_rounded,
                        size: 16.r,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: TextField(
                          controller: _commentController,
                          style: theme.textTheme.bodyMedium?.copyWith(fontSize: 13.sp),
                          decoration: InputDecoration(
                            hintText: 'Write a comment...',
                            hintStyle: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                              fontSize: 12.5.sp,
                            ),
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                          onSubmitted: (_) => _handleAddComment(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              IconButton.filled(
                icon: const Icon(Icons.send_rounded, size: 16),
                tooltip: 'Post comment',
                onPressed: _handleAddComment,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // Status Modal Bottom Sheet
  // ==========================================================================
  void _showStatusModal(BuildContext context) {
    final statuses = ['Todo', 'In Progress', 'Review', 'Done'];

    showModalBottomSheet<void>(
      context: context,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _DetailsOptionModal(
        title: 'Change Status',
        options: statuses,
        selectedOption: _currentStatus,
        onSelect: (selected) {
          setState(() {
            _currentStatus = selected;
            _isCompleted = selected == 'Done';
            _activities.insert(
              0,
              _ActivityEntry(
                id: 'act-${DateTime.now().millisecondsSinceEpoch}',
                userName: 'Ava Patel',
                userInitials: 'AP',
                action: 'Moved task to $selected',
                timestamp: 'Just now',
                icon: Icons.donut_large_rounded,
              ),
            );
          });
          Navigator.of(context).pop();
        },
      ),
    );
  }

  // ==========================================================================
  // Priority Modal Bottom Sheet
  // ==========================================================================
  void _showPriorityModal(BuildContext context) {
    final priorities = ['Low', 'Medium', 'High', 'Urgent'];

    showModalBottomSheet<void>(
      context: context,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _DetailsOptionModal(
        title: 'Change Priority',
        options: priorities,
        selectedOption: _currentPriority,
        onSelect: (selected) {
          setState(() {
            _currentPriority = selected;
            _activities.insert(
              0,
              _ActivityEntry(
                id: 'act-${DateTime.now().millisecondsSinceEpoch}',
                userName: 'Ava Patel',
                userInitials: 'AP',
                action: 'Changed priority to $selected',
                timestamp: 'Just now',
                icon: Icons.flag_outlined,
              ),
            );
          });
          Navigator.of(context).pop();
        },
      ),
    );
  }

  // ==========================================================================
  // Assignee Member Selection Modal
  // ==========================================================================
  void _showAssigneeModal(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    showModalBottomSheet<void>(
      context: context,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppDimensions.radiusXL.r),
          ),
          border: Border(
            top: BorderSide(
              color: theme.colorScheme.outline.withValues(alpha: isDark ? 0.35 : 0.6),
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
              'Assign Member',
              style: theme.textTheme.titleMedium?.copyWith(
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: AppDimensions.space12.h),

            // Member list
            ..._teamMembers.map((member) {
              final isSelected = _assignedMember.name == member.name;

              return Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    setState(() {
                      _assignedMember = member;
                      _activities.insert(
                        0,
                        _ActivityEntry(
                          id: 'act-${DateTime.now().millisecondsSinceEpoch}',
                          userName: 'Ava Patel',
                          userInitials: 'AP',
                          action: 'Reassigned task to ${member.name}',
                          timestamp: 'Just now',
                          icon: Icons.person_outline_rounded,
                        ),
                      );
                    });
                    Navigator.of(context).pop();
                  },
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMD.r),
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 6.w),
                    child: Row(
                      children: [
                        UserAvatar(
                          name: member.name,
                          initials: member.initials,
                          size: 32.0,
                        ),
                        SizedBox(width: 10.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                member.name,
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontSize: 13.5.sp,
                                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                ),
                              ),
                              Text(
                                member.role,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                  fontSize: 11.sp,
                                ),
                              ),
                            ],
                          ),
                        ),
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
            }),
          ],
        ),
      ),
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
      key: const ValueKey<String>('task_details_skeleton'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          height: 48.h,
          decoration: BoxDecoration(
            color: shimmerBase,
            borderRadius: BorderRadius.circular(AppDimensions.radiusMD.r),
          ),
        ),
        SizedBox(height: 12.h),
        Container(
          height: 90.h,
          decoration: BoxDecoration(
            color: shimmerBase,
            borderRadius: BorderRadius.circular(AppDimensions.radiusLG.r),
          ),
        ),
        SizedBox(height: 12.h),
        Container(
          height: 70.h,
          decoration: BoxDecoration(
            color: shimmerBase,
            borderRadius: BorderRadius.circular(AppDimensions.radiusLG.r),
          ),
        ),
        SizedBox(height: 12.h),
        Container(
          height: 120.h,
          decoration: BoxDecoration(
            color: shimmerBase,
            borderRadius: BorderRadius.circular(AppDimensions.radiusLG.r),
          ),
        ),
      ],
    );
  }
}

// ============================================================================
// Private Helper Modal for Task Option Selection (Status / Priority)
// ============================================================================
class _DetailsOptionModal extends StatelessWidget {
  const _DetailsOptionModal({
    required this.title,
    required this.options,
    required this.selectedOption,
    required this.onSelect,
  });

  final String title;
  final List<String> options;
  final String selectedOption;
  final ValueChanged<String> onSelect;

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
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: AppDimensions.space12.h),
          ...options.map((opt) {
            final isSelected = opt == selectedOption;

            return Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => onSelect(opt),
                borderRadius: BorderRadius.circular(AppDimensions.radiusMD.r),
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 8.w),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        opt,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontSize: 14.sp,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          color: isSelected
                              ? theme.colorScheme.primary
                              : theme.colorScheme.onSurface,
                        ),
                      ),
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
          }),
        ],
      ),
    );
  }
}
