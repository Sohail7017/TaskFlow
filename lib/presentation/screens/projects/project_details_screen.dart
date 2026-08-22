import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/routes/route_names.dart';
import '../../../domain/entities/project.dart';
import '../../../domain/entities/task.dart';
import '../../bloc/projects/project_bloc.dart';
import '../../bloc/projects/project_event.dart';
import '../../bloc/projects/project_state.dart';
import '../../bloc/tasks/task_bloc.dart';
import '../../bloc/tasks/task_event.dart';
import '../../bloc/tasks/task_state.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/app_error_view.dart';
import '../../widgets/common/status_badge.dart';
import '../../widgets/common/priority_badge.dart';

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

  @override
  void initState() {
    super.initState();
    context.read<ProjectBloc>().add(LoadProjectDetails(widget.projectId));
    context.read<TaskBloc>().add(LoadTasks(projectId: widget.projectId));
  }

  void _showDeleteDialog(BuildContext context, Project project) {
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
          'Delete project?',
          style: textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
            fontSize: 18.sp,
          ),
        ),
        content: Text(
          'Are you sure you want to delete ${project.name}? This action cannot be undone and all associated tasks will be removed.',
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
              context.read<ProjectBloc>().add(DeleteProject(project.id));
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

    return BlocConsumer<ProjectBloc, ProjectState>(
      listenWhen: (previous, current) => 
        previous.status == ProjectStatus.loading && 
        (current.status == ProjectStatus.success || current.status == ProjectStatus.error),
      listener: (context, state) {
        if (state.status == ProjectStatus.success && state.selectedProject == null) {
          if (context.canPop()) {
            context.pop();
          } else {
            context.go(RouteNames.projects);
          }
        }
      },
      builder: (context, state) {
        final project = state.selectedProject;

        if (state.status == ProjectStatus.error && project == null) {
          return Scaffold(
            appBar: AppBar(),
            body: AppErrorView(
              title: 'Project not found',
              message: state.errorMessage ?? 'Unable to load project details.',
              onRetry: () => context.read<ProjectBloc>().add(LoadProjectDetails(widget.projectId)),
            ),
          );
        }

        if (project == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));

        return Scaffold(
          body: LayoutBuilder(
            builder: (context, constraints) {
              final isTablet = constraints.maxWidth >= 720;
              final horizontalPadding = (isTablet ? AppDimensions.space32 : AppDimensions.space20).w;

              return RefreshIndicator(
                onRefresh: () async {
                  context.read<ProjectBloc>().add(LoadProjectDetails(widget.projectId));
                  context.read<TaskBloc>().add(RefreshTasks(projectId: widget.projectId));
                },
                color: colorScheme.primary,
                edgeOffset: 120.h,
                child: CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: ClampingScrollPhysics(),
                  ),
                  slivers: [
                    _buildCollapsingHeader(context, isTablet, horizontalPadding, project),

                    SliverToBoxAdapter(
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 1000),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Padding(
                                padding: EdgeInsets.only(
                                  left: horizontalPadding,
                                  right: horizontalPadding,
                                  top: AppDimensions.space16.h,
                                  bottom: AppDimensions.space20.h,
                                ),
                                child: isTablet
                                    ? _buildTabletOverviewSection(context, project)
                                    : _buildMobileOverviewSection(context, project),
                              ),

                              Padding(
                                padding: EdgeInsets.only(
                                  left: horizontalPadding,
                                  right: horizontalPadding,
                                  bottom: AppDimensions.space24.h,
                                ),
                                child: _buildStatusDistributionBar(context),
                              ),

                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                                child: _buildTasksSectionHeader(context, project),
                              ),

                              SizedBox(height: AppDimensions.space12.h),

                              BlocBuilder<TaskBloc, TaskState>(
                                builder: (context, taskState) {
                                  if (taskState.status == TaskStatusEnum.loading && taskState.tasks.isEmpty) {
                                    return const Center(child: Padding(
                                      padding: EdgeInsets.all(20.0),
                                      child: CircularProgressIndicator(),
                                    ));
                                  }
                                  if (taskState.tasks.isEmpty) {
                                     return Center(
                                      child: Padding(
                                        padding: const EdgeInsets.all(40.0),
                                        child: Text('No tasks found for this project.', style: theme.textTheme.bodyMedium),
                                      ),
                                    );
                                  }
                                  return Padding(
                                    padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                                    child: Column(
                                      children: taskState.tasks.map((t) => _TaskListItem(task: t)).toList(),
                                    ),
                                  );
                                },
                              ),
                            ],
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

  Widget _buildCollapsingHeader(BuildContext context, bool isTablet, double horizontalPadding, Project project) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final isDark = theme.brightness == Brightness.dark;
    final initials = project.name.split(' ').take(2).map((e) => e.isNotEmpty ? e[0] : '').join().toUpperCase();

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
          context.pop();
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
              context.push('/projects/${project.id}/edit');
            } else if (value == 'delete') {
              _showDeleteDialog(context, project);
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit_outlined, size: 18.r),
                  SizedBox(width: 8.w),
                  const Text('Edit Project'),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete_outline_rounded, size: 18.r, color: colorScheme.error),
                  SizedBox(width: 8.w),
                  Text('Delete Project', style: TextStyle(color: colorScheme.error, fontWeight: FontWeight.w600)),
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
                        child: Row(
                          children: [
                            Expanded(child: Text(project.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: textTheme.titleMedium)),
                            SizedBox(width: 8.w),
                            StatusBadge(status: project.status, showDot: false),
                          ],
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
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  width: 38.r,
                                  height: 38.r,
                                  decoration: BoxDecoration(
                                    color: colorScheme.primary.withValues(alpha: isDark ? 0.22 : 0.12),
                                    borderRadius: BorderRadius.circular(AppDimensions.radiusSM.r),
                                    border: Border.all(color: colorScheme.primary.withValues(alpha: 0.35)),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(initials, style: textTheme.labelLarge?.copyWith(color: colorScheme.primary, fontWeight: FontWeight.w700)),
                                ),
                                StatusBadge(status: project.status, showDot: true),
                              ],
                            ),
                            SizedBox(height: 8.h),
                            Text(project.name, style: textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700)),
                            SizedBox(height: 3.h),
                            Text(project.description, maxLines: 2, overflow: TextOverflow.ellipsis, style: textTheme.bodyMedium),
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

  Widget _buildMobileOverviewSection(BuildContext context, Project project) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildProgressCard(context, project),
        SizedBox(height: AppDimensions.space12.h),
        _buildStatisticsGrid(context, project),
      ],
    );
  }

  Widget _buildTabletOverviewSection(BuildContext context, Project project) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 5, child: _buildProgressCard(context, project)),
        SizedBox(width: AppDimensions.space16.w),
        Expanded(flex: 6, child: _buildStatisticsGrid(context, project)),
      ],
    );
  }

  Widget _buildProgressCard(BuildContext context, Project project) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final isDark = theme.brightness == Brightness.dark;
    final progress = project.status.toLowerCase() == 'done' ? 1.0 : 0.6;
    final percentText = '${(progress * 100).toInt()}%';

    return Container(
      padding: EdgeInsets.all(AppDimensions.space16.r),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLG.r),
        border: Border.all(color: colorScheme.outline.withValues(alpha: isDark ? 0.35 : 0.6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: Text('Project progress', style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700))),
              Text(percentText, style: textTheme.titleSmall?.copyWith(color: colorScheme.primary, fontWeight: FontWeight.w700)),
            ],
          ),
          SizedBox(height: 10.h),
          LinearProgressIndicator(value: progress, minHeight: 6.h),
          SizedBox(height: 8.h),
          Text('${project.taskCount} tasks associated', style: textTheme.bodySmall),
        ],
      ),
    );
  }

  Widget _buildStatisticsGrid(BuildContext context, Project project) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Container(
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLG.r),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _StatBlock(label: 'Tasks', value: '${project.taskCount}', icon: Icons.checklist_rounded, color: colorScheme.primary),
        ],
      ),
    );
  }

  Widget _buildStatusDistributionBar(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMD.r),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.5)),
      ),
      child: const Text('Status Breakdown placeholder'),
    );
  }

  Widget _buildTasksSectionHeader(BuildContext context, Project project) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('Tasks', style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
        AppButton(
          text: 'New Task',
          prefixIcon: Icons.add_rounded,
          height: 36.h,
          isFullWidth: false,
          onPressed: () => context.push(RouteNames.createTask),
        ),
      ],
    );
  }
}

class _StatBlock extends StatelessWidget {
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

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(fontSize: 10)),
      ],
    );
  }
}

class _TaskListItem extends StatelessWidget {
  const _TaskListItem({required this.task});
  final Task task;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(task.title),
      subtitle: Text(task.status.name),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          PriorityBadge(priority: task.priority.name),
          SizedBox(width: 8.w),
          StatusBadge(status: task.status.name),
        ],
      ),
      onTap: () => context.push('/tasks/${task.id}'),
    );
  }
}
