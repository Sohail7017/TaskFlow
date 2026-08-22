import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/routes/route_names.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/task.dart';
import '../../bloc/tasks/task_bloc.dart';
import '../../bloc/tasks/task_event.dart';
import '../../bloc/tasks/task_state.dart';
import '../../widgets/common/app_empty_view.dart';
import '../../widgets/common/app_error_view.dart';
import '../../widgets/common/priority_badge.dart';
import '../../widgets/common/status_badge.dart';
import '../../widgets/common/user_avatar.dart';

/// Premium, production-quality Task List Screen for TaskFlow
class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key, this.projectId});

  final String? projectId;

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _hasSearchText = false;

  @override
  void initState() {
    super.initState();
    context.read<TaskBloc>().add(LoadTasks(projectId: widget.projectId));
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

  void _clearAllFilters() {
    context.read<TaskBloc>().add(const ClearTaskFilters());
    _searchController.clear();
  }

  List<Task> _applySearch(List<Task> tasks) {
    if (!_hasSearchText) return tasks;
    final query = _searchController.text.toLowerCase();
    return tasks.where((t) => 
      t.title.toLowerCase().contains(query) || 
      t.description.toLowerCase().contains(query)
    ).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isTablet = constraints.maxWidth >= 720;
          final horizontalPadding = (isTablet ? AppDimensions.space32 : AppDimensions.space20).w;

          return BlocBuilder<TaskBloc, TaskState>(
            builder: (context, state) {
              final tasks = _applySearch(state.tasks);

              return RefreshIndicator(
                onRefresh: () async {
                  context.read<TaskBloc>().add(RefreshTasks(projectId: widget.projectId));
                },
                color: colorScheme.primary,
                edgeOffset: 120.h,
                child: CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: ClampingScrollPhysics(),
                  ),
                  slivers: [
                    _buildCollapsingHeader(context, isTablet, horizontalPadding, state.tasks.length),

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

                    SliverToBoxAdapter(
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 1000),
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                            child: _buildFilterChipsRow(context, state),
                          ),
                        ),
                      ),
                    ),

                    if (state.filterStatus != null || state.filterPriority != null || state.filterAssigneeId != null)
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
                              child: _buildActiveFilterTags(context, state),
                            ),
                          ),
                        ),
                      ),

                    SliverToBoxAdapter(
                      child: SizedBox(height: AppDimensions.space16.h),
                    ),

                    if (state.status == TaskStatusEnum.loading && state.tasks.isEmpty)
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
                    else if (state.status == TaskStatusEnum.error)
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
                                message: state.errorMessage ?? 'Something went wrong.',
                                onRetry: () {
                                  context.read<TaskBloc>().add(LoadTasks(projectId: widget.projectId));
                                },
                              ),
                            ),
                          ),
                        ),
                      )
                    else if (state.status == TaskStatusEnum.empty || tasks.isEmpty)
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
                                title: _hasSearchText || state.filterStatus != null ? 'No tasks found' : 'No tasks yet',
                                description: _hasSearchText || state.filterStatus != null 
                                  ? 'Adjust your filters or try a different search term.'
                                  : 'Create your first task and start organizing your work.',
                                actionText: _hasSearchText || state.filterStatus != null ? 'Clear Filters' : 'Create Task',
                                onAction: () {
                                  if (_hasSearchText || state.filterStatus != null) {
                                    _clearAllFilters();
                                  } else {
                                    context.push(RouteNames.createTask);
                                  }
                                },
                              ),
                            ),
                          ),
                        ),
                      )
                    else
                      SliverPadding(
                        padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) => Padding(
                              padding: EdgeInsets.only(bottom: AppDimensions.space10.h),
                              child: _TaskCardItem(
                                task: tasks[index],
                                onTap: () => context.push('/tasks/${tasks[index].id}'),
                              ),
                            ),
                            childCount: tasks.length,
                          ),
                        ),
                      ),

                    SliverPadding(
                      padding: EdgeInsets.only(bottom: 108.h),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildCollapsingHeader(BuildContext context, bool isTablet, double horizontalPadding, int totalCount) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
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
                  colorScheme.primary.withValues(alpha: isDark ? 0.14 : 0.06),
                  theme.scaffoldBackgroundColor,
                ],
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Stack(
                fit: StackFit.expand,
                children: [
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
                              style: textTheme.titleLarge?.copyWith(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            SizedBox(width: 8.w),
                            _buildCountBadge(context, '$totalCount'),
                          ],
                        ),
                      ),
                    ),

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
                            color: colorScheme.primary,
                          ),
                          onPressed: () => context.push(RouteNames.createTask),
                          style: IconButton.styleFrom(
                            backgroundColor: colorScheme.primary.withValues(
                              alpha: isDark ? 0.2 : 0.1,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

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
                            _buildCountBadge(context, '$totalCount tasks'),
                            SizedBox(height: 6.h),

                            Text(
                              'Tasks',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: textTheme.headlineMedium?.copyWith(
                                fontSize: (isTablet ? 26.0 : 22.0).sp,
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.4,
                              ),
                            ),
                            SizedBox(height: 2.h),

                            Text(
                              'Stay organized and keep your work moving.',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: textTheme.bodyMedium?.copyWith(
                                color: colorScheme.onSurfaceVariant,
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
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: colorScheme.primary.withValues(alpha: isDark ? 0.18 : 0.1),
        borderRadius: BorderRadius.circular(AppDimensions.radiusFull.r),
        border: Border.all(
          color: colorScheme.primary.withValues(alpha: 0.3),
        ),
      ),
      child: Text(
        text,
        style: theme.textTheme.labelSmall?.copyWith(
          color: colorScheme.primary,
          fontSize: 11.sp,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildSearchAndSortBar(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final isDark = theme.brightness == Brightness.dark;

    return Row(
      children: [
        Expanded(
          child: Container(
            height: 44.h,
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(AppDimensions.radiusMD.r),
              border: Border.all(
                color: colorScheme.outline.withValues(alpha: isDark ? 0.35 : 0.6),
                width: 1.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: colorScheme.shadow.withValues(alpha: isDark ? 0.15 : 0.02),
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
                  color: colorScheme.onSurfaceVariant,
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    style: textTheme.bodyMedium?.copyWith(
                      fontSize: 13.5.sp,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Search tasks...',
                      hintStyle: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
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
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        SizedBox(width: AppDimensions.space10.w),

        Material(
          color: colorScheme.surface,
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
                  color: colorScheme.outline.withValues(alpha: isDark ? 0.35 : 0.6),
                  width: 1.0,
                ),
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.shadow.withValues(alpha: isDark ? 0.15 : 0.02),
                    blurRadius: 6.r,
                    offset: Offset(0, 2.h),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.sort_rounded,
                    size: 16.r,
                    color: colorScheme.primary,
                  ),
                  SizedBox(width: 6.w),
                  Text(
                    'Sort',
                    style: textTheme.labelMedium?.copyWith(
                      color: colorScheme.onSurface,
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

  Widget _buildFilterChipsRow(BuildContext context, TaskState state) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: [
          _FilterButton(
            label: 'Status',
            selectedLabel: state.filterStatus?.name,
            icon: Icons.donut_large_rounded,
            onTap: () => _showStatusFilterModal(context, state),
          ),
          SizedBox(width: 8.w),
          _FilterButton(
            label: 'Priority',
            selectedLabel: state.filterPriority?.name,
            icon: Icons.flag_outlined,
            onTap: () => _showPriorityFilterModal(context, state),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveFilterTags(BuildContext context, TaskState state) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Wrap(
      spacing: 6.w,
      runSpacing: 6.h,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        if (state.filterStatus != null)
          _ActiveFilterTag(
            label: 'Status: ${state.filterStatus!.name}',
            onRemove: () => context.read<TaskBloc>().add(const ApplyTaskFilters()),
          ),
        if (state.filterPriority != null)
          _ActiveFilterTag(
            label: 'Priority: ${state.filterPriority!.name}',
            onRemove: () => context.read<TaskBloc>().add(const ApplyTaskFilters()),
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
            style: textTheme.labelSmall?.copyWith(
              color: colorScheme.primary,
              fontSize: 11.5.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  void _showSortModal(BuildContext context) {
    // Placeholder for sort
  }

  void _showStatusFilterModal(BuildContext context, TaskState state) {
    final statuses = TaskStatus.values;
    showModalBottomSheet<void>(
      context: context,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _FilterBottomSheet(
        title: 'Filter by Status',
        content: Column(
          children: [
             _BottomSheetRadioTile(
                  title: 'All',
                  isSelected: state.filterStatus == null,
                  onTap: () {
                    context.read<TaskBloc>().add(const ApplyTaskFilters());
                    Navigator.of(context).pop();
                  },
                ),
            ...statuses.map(
                (status) => _BottomSheetRadioTile(
                  title: status.name,
                  isSelected: state.filterStatus == status,
                  trailing: StatusBadge(status: status.name, showDot: false),
                  onTap: () {
                    context.read<TaskBloc>().add(ApplyTaskFilters(status: status));
                    Navigator.of(context).pop();
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showPriorityFilterModal(BuildContext context, TaskState state) {
    final priorities = TaskPriority.values;
    showModalBottomSheet<void>(
      context: context,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _FilterBottomSheet(
        title: 'Filter by Priority',
        content: Column(
          children: [
            _BottomSheetRadioTile(
                  title: 'All',
                  isSelected: state.filterPriority == null,
                  onTap: () {
                    context.read<TaskBloc>().add(const ApplyTaskFilters());
                    Navigator.of(context).pop();
                  },
                ),
            ...priorities.map(
                (priority) => _BottomSheetRadioTile(
                  title: priority.name,
                  isSelected: state.filterPriority == priority,
                  trailing: PriorityBadge(priority: priority.name),
                  onTap: () {
                    context.read<TaskBloc>().add(ApplyTaskFilters(priority: priority));
                    Navigator.of(context).pop();
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSkeletonLoading(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final shimmerBase = isDark ? colorScheme.surface : AppColors.borderLight;

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
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final isDark = theme.brightness == Brightness.dark;
    final isSelected = selectedLabel != null;

    final bgColor = isSelected
        ? colorScheme.primary.withValues(alpha: isDark ? 0.2 : 0.1)
        : colorScheme.surface;
    final borderColor = isSelected
        ? colorScheme.primary.withValues(alpha: 0.5)
        : colorScheme.outline.withValues(alpha: isDark ? 0.35 : 0.6);
    final textColor = isSelected
        ? colorScheme.primary
        : colorScheme.onSurfaceVariant;

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
                style: textTheme.labelMedium?.copyWith(
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
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.only(left: 10.w, right: 6.w, top: 4.h, bottom: 4.h),
      decoration: BoxDecoration(
        color: colorScheme.primary.withValues(alpha: isDark ? 0.18 : 0.09),
        borderRadius: BorderRadius.circular(AppDimensions.radiusFull.r),
        border: Border.all(
          color: colorScheme.primary.withValues(alpha: 0.35),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: textTheme.labelSmall?.copyWith(
              color: colorScheme.primary,
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
              color: colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}

class _TaskCardItem extends StatelessWidget {
  const _TaskCardItem({
    required this.task,
    required this.onTap,
  });

  final Task task;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final isDark = theme.brightness == Brightness.dark;
    final isCompleted = task.status == TaskStatus.done;

    return Material(
      color: colorScheme.surface,
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
              color: colorScheme.outline.withValues(alpha: isDark ? 0.35 : 0.6),
              width: 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: colorScheme.shadow.withValues(alpha: isDark ? 0.12 : 0.02),
                blurRadius: 6.r,
                offset: Offset(0, 2.h),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(top: 2.h, right: 8.w),
                    child: Icon(
                      isCompleted
                          ? Icons.check_circle_rounded
                          : Icons.radio_button_unchecked_rounded,
                      size: 17.r,
                      color: isCompleted
                          ? AppColors.success
                          : colorScheme.outline.withValues(alpha: 0.8),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      task.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.bodyMedium?.copyWith(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        decoration: isCompleted ? TextDecoration.lineThrough : null,
                        color: isCompleted
                            ? colorScheme.onSurfaceVariant
                            : colorScheme.onSurface,
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  PriorityBadge(priority: task.priority.name),
                ],
              ),
              SizedBox(height: AppDimensions.space10.h),

              Padding(
                padding: EdgeInsets.only(left: 25.w),
                child: Wrap(
                  spacing: 12.w,
                  runSpacing: 6.h,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    if (task.assigneeId != null)
                      UserAvatar(
                        name: 'Assignee',
                        size: 18.0,
                      )
                    else
                      Text('Unassigned', style: textTheme.bodySmall),

                    if (task.dueDate != null)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.schedule_rounded,
                            size: 13.r,
                            color: colorScheme.onSurfaceVariant,
                          ),
                          SizedBox(width: 3.w),
                          Text(
                            'Due ${task.dueDate!.day}/${task.dueDate!.month}',
                            style: textTheme.bodySmall?.copyWith(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),

                    StatusBadge(status: task.status.name),
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

class _FilterBottomSheet extends StatelessWidget {
  const _FilterBottomSheet({
    required this.title,
    required this.content,
  });

  final String title;
  final Widget content;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppDimensions.radiusXL.r),
        ),
        border: Border(
          top: BorderSide(
            color: colorScheme.outline.withValues(alpha: isDark ? 0.35 : 0.6),
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
          Center(
            child: Container(
              width: 36.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: colorScheme.outline.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(AppDimensions.radiusFull.r),
              ),
            ),
          ),
          SizedBox(height: AppDimensions.space14.h),

          Text(
            title,
            style: textTheme.titleMedium?.copyWith(
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: AppDimensions.space12.h),

          content,
        ],
      ),
    );
  }
}

class _BottomSheetRadioTile extends StatelessWidget {
  const _BottomSheetRadioTile({
    required this.title,
    required this.isSelected,
    required this.onTap,
    this.trailing,
  });

  final String title;
  final bool isSelected;
  final VoidCallback onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMD.r),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 8.w),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: textTheme.bodyMedium?.copyWith(
                    fontSize: 14.sp,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected
                        ? colorScheme.primary
                        : colorScheme.onSurface,
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
                    ? colorScheme.primary
                    : colorScheme.outline.withValues(alpha: 0.6),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
