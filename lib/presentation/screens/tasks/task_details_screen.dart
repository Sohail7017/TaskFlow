import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/routes/route_names.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/task.dart';
import '../../../domain/entities/enums.dart';
import '../../bloc/tasks/task_bloc.dart';
import '../../bloc/tasks/task_event.dart';
import '../../bloc/tasks/task_state.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/app_error_view.dart';
import '../../widgets/common/priority_badge.dart';
import '../../widgets/common/status_badge.dart';
import '../../widgets/common/user_avatar.dart';

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
  @override
  void initState() {
    super.initState();
    context.read<TaskBloc>().add(LoadTaskDetails(widget.taskId));
  }

  void _showDeleteDialog(BuildContext context, Task task) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusXL.r),
        ),
        title: Text(
          'Delete task?',
          style: textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
            fontSize: 18.sp,
          ),
        ),
        content: Text(
          'Are you sure you want to delete "${task.title}"? This action cannot be undone.',
          style: textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
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
              context.read<TaskBloc>().add(DeleteTask(task.id));
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return BlocConsumer<TaskBloc, TaskState>(
      listener: (context, state) {
        if (state.status == TaskStatusEnum.success && state.selectedTask == null) {
          if (context.canPop()) {
            context.pop();
          } else {
            context.go(RouteNames.tasks);
          }
        }
      },
      builder: (context, state) {
        final task = state.selectedTask;

        if (state.status == TaskStatusEnum.loading && task == null) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        if (state.status == TaskStatusEnum.error && task == null) {
          return Scaffold(
            appBar: AppBar(),
            body: AppErrorView(
              title: 'Task not found',
              message: state.errorMessage ?? 'Unable to load task details.',
              onRetry: () => context.read<TaskBloc>().add(LoadTaskDetails(widget.taskId)),
            ),
          );
        }

        if (task == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));

        return Scaffold(
          body: LayoutBuilder(
            builder: (context, constraints) {
              final isTablet = constraints.maxWidth >= 840;
              final horizontalPadding = (isTablet ? AppDimensions.space32 : AppDimensions.space20).w;

              return RefreshIndicator(
                onRefresh: () async {
                  context.read<TaskBloc>().add(LoadTaskDetails(widget.taskId));
                },
                color: colorScheme.primary,
                edgeOffset: 120.h,
                child: CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: ClampingScrollPhysics(),
                  ),
                  slivers: [
                    _buildCollapsingHeader(context, isTablet, horizontalPadding, task),

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
                            child: _buildQuickActionBar(context, task),
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
                            child: isTablet
                                ? _buildTabletLayout(context, task)
                                : _buildMobileLayout(context, task),
                          ),
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
          ),
        );
      },
    );
  }

  Widget _buildCollapsingHeader(BuildContext context, bool isTablet, double horizontalPadding, Task task) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
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
              context.push('/tasks/${task.id}/edit');
            } else if (value == 'delete') {
              _showDeleteDialog(context, task);
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit_outlined, size: 18.r),
                  SizedBox(width: 8.w),
                  const Text('Edit Task'),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete_outline_rounded, size: 18.r, color: colorScheme.error),
                  SizedBox(width: 8.w),
                  Text('Delete Task', style: TextStyle(color: colorScheme.error, fontWeight: FontWeight.w600)),
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
                  if (progress < 0.5)
                    Positioned(
                      left: 56.w,
                      right: 60.w,
                      top: 18.h,
                      child: Opacity(
                        opacity: ((1.0 - progress * 2.0)).clamp(0.0, 1.0),
                        child: Text(
                          task.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            decoration: task.status == TaskStatus.done ? TextDecoration.lineThrough : null,
                          ),
                        ),
                      ),
                    ),

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
                             Text(
                              'Task Details',
                              style: textTheme.labelMedium?.copyWith(
                                color: colorScheme.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: 6.h),

                            Text(
                              task.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: textTheme.headlineMedium?.copyWith(
                                fontSize: (isTablet ? 22.0 : 19.5).sp,
                                fontWeight: FontWeight.w700,
                                decoration: task.status == TaskStatus.done ? TextDecoration.lineThrough : null,
                              ),
                            ),
                            SizedBox(height: 6.h),

                            Row(
                              children: [
                                StatusBadge(status: task.status.name, showDot: true),
                                SizedBox(width: 8.w),
                                PriorityBadge(priority: task.priority.name),
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

  Widget _buildQuickActionBar(BuildContext context, Task task) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isCompleted = task.status == TaskStatus.done;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLG.r),
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: isDark ? 0.35 : 0.6),
          width: 1.0,
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            InkWell(
              onTap: () {
                final newStatus = isCompleted ? TaskStatus.inProgress : TaskStatus.done;
                context.read<TaskBloc>().add(UpdateTaskStatus(taskId: task.id, status: newStatus));
              },
              child: Row(
                children: [
                  Icon(
                    isCompleted ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                    color: isCompleted ? AppColors.success : colorScheme.outline,
                  ),
                  SizedBox(width: 8.w),
                  Text(isCompleted ? 'Completed' : 'Mark Complete', style: textTheme.labelLarge),
                ],
              ),
            ),
            SizedBox(width: 20.w),
            _buildInteractiveBadgeChip(context, label: task.status.name, icon: Icons.donut_large_rounded, onTap: () => _showStatusModal(context, task)),
            SizedBox(width: 8.w),
            _buildInteractiveBadgeChip(context, label: task.priority.name, icon: Icons.flag_outlined, onTap: () => _showPriorityModal(context, task)),
          ],
        ),
      ),
    );
  }

  Widget _buildInteractiveBadgeChip(BuildContext context, {required String label, required IconData icon, required VoidCallback onTap}) {
    return ActionChip(
      avatar: Icon(icon, size: 14),
      label: Text(label),
      onPressed: onTap,
    );
  }

  Widget _buildMobileLayout(BuildContext context, Task task) {
    return Column(
      children: [
        _buildDescriptionCard(context, task),
        SizedBox(height: 12.h),
        _buildMetadataCard(context, task),
      ],
    );
  }

  Widget _buildTabletLayout(BuildContext context, Task task) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 6, child: _buildDescriptionCard(context, task)),
        SizedBox(width: 16.w),
        Expanded(flex: 4, child: _buildMetadataCard(context, task)),
      ],
    );
  }

  Widget _buildDescriptionCard(BuildContext context, Task task) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLG.r),
        border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Description', style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
          SizedBox(height: 8.h),
          Text(task.description, style: textTheme.bodyMedium),
        ],
      ),
    );
  }

  Widget _buildMetadataCard(BuildContext context, Task task) {
    final theme = Theme.of(context);
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLG.r),
        border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.5)),
      ),
      child: Column(
        children: [
           ListTile(
             leading: const Icon(Icons.person_outline),
             title: const Text('Assignee'),
             subtitle: Text(task.assigneeId ?? 'Unassigned'),
           ),
           ListTile(
             leading: const Icon(Icons.calendar_today_outlined),
             title: const Text('Due Date'),
             subtitle: Text(task.dueDate != null ? '${task.dueDate!.day}/${task.dueDate!.month}/${task.dueDate!.year}' : 'No due date'),
           ),
        ],
      ),
    );
  }

  void _showStatusModal(BuildContext context, Task task) {
     showModalBottomSheet<void>(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: TaskStatus.values.map((s) => ListTile(
          title: Text(s.name),
          onTap: () {
            context.read<TaskBloc>().add(UpdateTaskStatus(taskId: task.id, status: s));
            Navigator.pop(context);
          },
        )).toList(),
      ),
    );
  }

  void _showPriorityModal(BuildContext context, Task task) {
    showModalBottomSheet<void>(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: TaskPriority.values.map((p) => ListTile(
          title: Text(p.name),
          onTap: () {
            context.read<TaskBloc>().add(UpdateTaskPriority(taskId: task.id, priority: p));
            Navigator.pop(context);
          },
        )).toList(),
      ),
    );
  }
}
