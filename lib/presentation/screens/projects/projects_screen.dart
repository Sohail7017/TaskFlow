import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/routes/route_names.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/project.dart';
import '../../bloc/projects/project_bloc.dart';
import '../../bloc/projects/project_event.dart';
import '../../bloc/projects/project_state.dart';
import '../../widgets/common/app_empty_view.dart';
import '../../widgets/common/app_error_view.dart';
import '../../widgets/common/status_badge.dart';

/// Supported sort options for the Projects List UI
enum ProjectSortOption {
  recent('Recently Updated', Icons.update_rounded),
  name('Project Name', Icons.sort_by_alpha_rounded),
  tasks('Task Count', Icons.checklist_rounded);

  const ProjectSortOption(this.label, this.icon);
  final String label;
  final IconData icon;
}

/// Premium, production-quality Projects Screen for TaskFlow
class ProjectsScreen extends StatefulWidget {
  const ProjectsScreen({super.key});

  @override
  State<ProjectsScreen> createState() => _ProjectsScreenState();
}

class _ProjectsScreenState extends State<ProjectsScreen> {
  // Search state
  final TextEditingController _searchController = TextEditingController();
  bool _hasSearchText = false;

  // Local filter states for UI preview demonstration
  String _selectedStatusFilter = 'All';
  ProjectSortOption _selectedSort = ProjectSortOption.recent;

  @override
  void initState() {
    super.initState();
    context.read<ProjectBloc>().add(const LoadProjects());
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

  void _clearFilters() {
    setState(() {
      _selectedStatusFilter = 'All';
      _searchController.clear();
    });
  }

  List<Project> _filterAndSort(List<Project> projects) {
    var filtered = List<Project>.from(projects);
    
    // Search filter
    if (_hasSearchText) {
      final query = _searchController.text.toLowerCase();
      filtered = filtered.where((p) => 
        p.name.toLowerCase().contains(query) || 
        p.description.toLowerCase().contains(query)
      ).toList();
    }

    // Status filter
    if (_selectedStatusFilter != 'All') {
      filtered = filtered.where((p) => 
        p.status.toLowerCase() == _selectedStatusFilter.toLowerCase()
      ).toList();
    }

    // Sort
    switch (_selectedSort) {
      case ProjectSortOption.recent:
        filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      case ProjectSortOption.name:
        filtered.sort((a, b) => a.name.compareTo(b.name));
      case ProjectSortOption.tasks:
        filtered.sort((a, b) => b.taskCount.compareTo(a.taskCount));
    }

    return filtered;
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

          return BlocBuilder<ProjectBloc, ProjectState>(
            builder: (context, state) {
              final projects = _filterAndSort(state.projects);

              return RefreshIndicator(
                onRefresh: () async {
                  context.read<ProjectBloc>().add(const RefreshProjects());
                },
                color: colorScheme.primary,
                edgeOffset: 120.h,
                child: CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: ClampingScrollPhysics(),
                  ),
                  slivers: [
                    // 1. Collapsing Project Header
                    _buildCollapsingHeader(context, isTablet, horizontalPadding, state.projects.length),

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

                    // 3. Filter Chips Row
                    SliverToBoxAdapter(
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 1000),
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                            child: _buildFilterTabsRow(context),
                          ),
                        ),
                      ),
                    ),

                    // Spacing before Project list
                    SliverToBoxAdapter(
                      child: SizedBox(height: AppDimensions.space16.h),
                    ),

                    // 4. Main Project Content / Loading / Error / Empty States
                    if (state.status == ProjectStatus.loading && state.projects.isEmpty)
                      SliverToBoxAdapter(
                        child: Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 1000),
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                              child: _buildSkeletonLoading(context, isTablet),
                            ),
                          ),
                        ),
                      )
                    else if (state.status == ProjectStatus.error)
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
                                title: 'Unable to load projects',
                                message: state.errorMessage ?? 'Something went wrong.',
                                onRetry: () {
                                  context.read<ProjectBloc>().add(const LoadProjects());
                                },
                              ),
                            ),
                          ),
                        ),
                      )
                    else if (state.status == ProjectStatus.empty || projects.isEmpty)
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
                                title: _hasSearchText || _selectedStatusFilter != 'All' ? 'No projects found' : 'No projects yet',
                                description: _hasSearchText || _selectedStatusFilter != 'All' 
                                  ? 'Adjust your filters or try a different search term.'
                                  : 'Create your first project and start organizing your work.',
                                actionText: _hasSearchText || _selectedStatusFilter != 'All' ? 'Clear Filters' : 'Create Project',
                                onAction: () {
                                  if (_hasSearchText || _selectedStatusFilter != 'All') {
                                    _clearFilters();
                                  } else {
                                    context.push(RouteNames.createProject);
                                  }
                                },
                              ),
                            ),
                          ),
                        ),
                      )
                    else
                      // Project Cards List / Responsive Grid
                      SliverPadding(
                        padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                        sliver: SliverToBoxAdapter(
                          child: Center(
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 1000),
                              child: isTablet
                                  ? _buildTabletGrid(context, projects)
                                  : _buildMobileList(context, projects),
                            ),
                          ),
                        ),
                      ),

                    // 5. Scroll clearance so floating bottom nav never obscures items
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

  // ==========================================================================
  // 1. Collapsing Project Header
  // ==========================================================================
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
                              'Projects',
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

                  // --- Persistent Add Project Action Button (Top Right) ---
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
                          onPressed: () => context.push(RouteNames.createProject),
                          style: IconButton.styleFrom(
                            backgroundColor: colorScheme.primary.withValues(
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
                            _buildCountBadge(context, '$totalCount active projects'),
                            SizedBox(height: 6.h),

                            // Main Title Headline
                            Text(
                              'Projects',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: textTheme.headlineMedium?.copyWith(
                                fontSize: (isTablet ? 26.0 : 22.0).sp,
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.4,
                              ),
                            ),
                            SizedBox(height: 2.h),

                            // Subtitle
                            Text(
                              'Manage your workspaces and keep every project moving forward.',
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
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final isDark = theme.brightness == Brightness.dark;

    return Row(
      children: [
        // Search Input Field
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
                      hintText: 'Search projects...',
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
                    onTap: _clearFilters,
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

        // Sort Action Button
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
                    _selectedSort.icon,
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

  // ==========================================================================
  // 3. Filter Tabs Row (All / Active / Completed)
  // ==========================================================================
  Widget _buildFilterTabsRow(BuildContext context) {
    const filters = ['All', 'Active', 'Completed'];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: filters
            .map(
              (filter) => Padding(
                padding: EdgeInsets.only(right: 8.w),
                child: _FilterTabChip(
                  label: filter,
                  isSelected: _selectedStatusFilter == filter,
                  onTap: () => setState(() => _selectedStatusFilter = filter),
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  // ==========================================================================
  // 4. Project Card Lists (Mobile Stacked & Tablet Grid)
  // ==========================================================================
  Widget _buildMobileList(BuildContext context, List<Project> projects) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: projects
          .map(
            (project) => Padding(
              padding: EdgeInsets.only(bottom: AppDimensions.space12.h),
              child: _ProjectCardItem(
                project: project,
                onTap: () => context.push('/projects/${project.id}'),
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildTabletGrid(BuildContext context, List<Project> projects) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth = (constraints.maxWidth - 16.w) / 2;

        return Wrap(
          spacing: 16.w,
          runSpacing: 16.h,
          children: projects
              .map(
                (project) => SizedBox(
                  width: cardWidth,
                  child: _ProjectCardItem(
                    project: project,
                    onTap: () => context.push('/projects/${project.id}'),
                  ),
                ),
              )
              .toList(),
        );
      },
    );
  }

  // ==========================================================================
  // Sort Bottom Sheet
  // ==========================================================================
  void _showSortModal(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    showModalBottomSheet<void>(
      context: context,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
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
              'Sort Projects By',
              style: theme.textTheme.titleMedium?.copyWith(
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: AppDimensions.space12.h),

            // Option tiles
            ...ProjectSortOption.values.map(
              (option) => Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    setState(() => _selectedSort = option);
                    Navigator.of(context).pop();
                  },
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMD.r),
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 8.w),
                    child: Row(
                      children: [
                        Icon(
                          option.icon,
                          size: 18.r,
                          color: _selectedSort == option
                              ? theme.colorScheme.primary
                              : theme.colorScheme.onSurfaceVariant,
                        ),
                        SizedBox(width: 10.w),
                        Expanded(
                          child: Text(
                            option.label,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontSize: 14.sp,
                              fontWeight: _selectedSort == option
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              color: _selectedSort == option
                                  ? theme.colorScheme.primary
                                  : theme.colorScheme.onSurface,
                            ),
                          ),
                        ),
                        Icon(
                          _selectedSort == option
                              ? Icons.radio_button_checked_rounded
                              : Icons.radio_button_unchecked_rounded,
                          size: 20.r,
                          color: _selectedSort == option
                              ? theme.colorScheme.primary
                              : theme.colorScheme.outline.withValues(alpha: 0.6),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
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
      key: const ValueKey<String>('projects_skeleton'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: List.generate(
        3,
        (index) => Padding(
          padding: EdgeInsets.only(bottom: AppDimensions.space12.h),
          child: Container(
            height: 120.h,
            decoration: BoxDecoration(
              color: shimmerBase,
              borderRadius: BorderRadius.circular(AppDimensions.radiusLG.r),
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// Private Helper Widgets (Scoped to ProjectsScreen only)
// ============================================================================

/// Filter tab chip (All / Active / Completed)
class _FilterTabChip extends StatelessWidget {
  const _FilterTabChip({
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
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

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
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 7.h),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppDimensions.radiusFull.r),
            border: Border.all(color: borderColor, width: 1.0),
          ),
          child: Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              color: textColor,
              fontSize: 12.sp,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}

/// Refined Productivity Project Card Item
class _ProjectCardItem extends StatelessWidget {
  const _ProjectCardItem({
    required this.project,
    required this.onTap,
  });

  final Project project;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final isDark = theme.brightness == Brightness.dark;
    final effectiveAccent = colorScheme.primary;
    // Mock progress calculation as it's not in entity
    final progress = project.status.toLowerCase() == 'done' ? 1.0 : 0.6;
    final percentText = '${(progress * 100).toInt()}%';
    final initials = project.name.split(' ').take(2).map((e) => e.isNotEmpty ? e[0] : '').join().toUpperCase();

    return Material(
      color: colorScheme.surface,
      borderRadius: BorderRadius.circular(AppDimensions.radiusLG.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLG.r),
        child: Container(
          padding: EdgeInsets.all(AppDimensions.space16.r),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppDimensions.radiusLG.r),
            border: Border.all(
              color: colorScheme.outline.withValues(alpha: isDark ? 0.35 : 0.6),
              width: 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: colorScheme.shadow.withValues(alpha: isDark ? 0.15 : 0.02),
                blurRadius: 8.r,
                offset: Offset(0, 2.h),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Row: Project Initials Icon + Name + Trailing Chevron
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Initials Container
                  Container(
                    width: 36.r,
                    height: 36.r,
                    decoration: BoxDecoration(
                      color: effectiveAccent.withValues(alpha: isDark ? 0.2 : 0.1),
                      borderRadius: BorderRadius.circular(AppDimensions.radiusSM.r),
                      border: Border.all(
                        color: effectiveAccent.withValues(alpha: 0.3),
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      initials,
                      style: textTheme.labelMedium?.copyWith(
                        color: effectiveAccent,
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  SizedBox(width: AppDimensions.space10.w),
                  // Title
                  Expanded(
                    child: Text(
                      project.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.titleMedium?.copyWith(
                        fontSize: 15.5.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  SizedBox(width: 6.w),
                  Icon(
                    Icons.chevron_right_rounded,
                    size: 20.r,
                    color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                  ),
                ],
              ),
              SizedBox(height: AppDimensions.space10.h),

              // Description
              Text(
                project.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontSize: 12.5.sp,
                  height: 1.35,
                ),
              ),
              SizedBox(height: AppDimensions.space14.h),

              // Progress Header Row (Status \u0026 Percentage)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  StatusBadge(status: project.status, showDot: false),
                  Text(
                    percentText,
                    style: textTheme.labelSmall?.copyWith(
                      color: effectiveAccent,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 6.h),

              // Progress Bar
              ClipRRect(
                borderRadius: BorderRadius.circular(AppDimensions.radiusFull.r),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 5.h,
                  backgroundColor: colorScheme.primaryContainer.withValues(alpha: 0.4),
                  valueColor: AlwaysStoppedAnimation<Color>(effectiveAccent),
                ),
              ),
              SizedBox(height: AppDimensions.space10.h),

              // Bottom Row (Task Count)
              Row(
                children: [
                  Icon(
                    Icons.checklist_rounded,
                    size: 14.r,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  SizedBox(width: 4.w),
                  Text(
                    '${project.taskCount} Tasks',
                    style: textTheme.labelSmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontSize: 11.5.sp,
                      fontWeight: FontWeight.w600,
                    ),
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
