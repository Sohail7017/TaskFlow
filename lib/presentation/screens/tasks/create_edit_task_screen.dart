import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/routes/route_names.dart';
import '../../../core/theme/app_colors.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/app_text_form_field.dart';
import '../../widgets/common/priority_badge.dart';
import '../../widgets/common/status_badge.dart';
import '../../widgets/common/user_avatar.dart';

/// Form modes supported by [CreateEditTaskScreen]
enum TaskFormMode {
  create,
  edit,
}

/// Presentation model for project selector
class _ProjectOption {
  const _ProjectOption({
    required this.id,
    required this.name,
    required this.initials,
    required this.color,
    required this.taskCount,
  });

  final String id;
  final String name;
  final String initials;
  final Color color;
  final int taskCount;
}

/// Presentation model for team member
class _TeamMemberOption {
  const _TeamMemberOption({
    required this.name,
    required this.initials,
    required this.role,
  });

  final String name;
  final String initials;
  final String role;
}

/// Premium, production-quality Create and Edit Task Form Screen for TaskFlow
class CreateEditTaskScreen extends StatefulWidget {
  const CreateEditTaskScreen({
    super.key,
    this.mode = TaskFormMode.create,
    this.taskId,
  });

  final TaskFormMode mode;
  final String? taskId;

  @override
  State<CreateEditTaskScreen> createState() => _CreateEditTaskScreenState();
}

class _CreateEditTaskScreenState extends State<CreateEditTaskScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;

  // Selected Form Values (Presentation state)
  late _ProjectOption _selectedProject;
  late String _selectedStatus;
  late String _selectedPriority;
  late _TeamMemberOption _selectedAssignee;
  late DateTime _selectedDueDate;

  bool _isLoading = false;

  // Static Project Choices
  static const List<_ProjectOption> _projects = [
    _ProjectOption(
      id: 'proj-1',
      name: 'Website Relaunch',
      initials: 'WR',
      color: AppColors.primary,
      taskCount: 6,
    ),
    _ProjectOption(
      id: 'proj-2',
      name: 'Mobile App v2',
      initials: 'MA',
      color: AppColors.secondary,
      taskCount: 8,
    ),
    _ProjectOption(
      id: 'proj-3',
      name: 'Design System',
      initials: 'DS',
      color: Color(0xFF0284C7),
      taskCount: 4,
    ),
    _ProjectOption(
      id: 'proj-4',
      name: 'Client Onboarding Revamp',
      initials: 'CO',
      color: Color(0xFF9333EA),
      taskCount: 5,
    ),
  ];

  // Static Team Members
  static const List<_TeamMemberOption> _teamMembers = [
    _TeamMemberOption(name: 'Ava Patel', initials: 'AP', role: 'Lead Designer & Dev'),
    _TeamMemberOption(name: 'Marcus Lee', initials: 'ML', role: 'Full-Stack Engineer'),
    _TeamMemberOption(name: 'Priya Nair', initials: 'PN', role: 'Product Design Lead'),
    _TeamMemberOption(name: 'Daniel Brooks', initials: 'DB', role: 'QA & DevOps Engineer'),
    _TeamMemberOption(name: 'Elena Garcia', initials: 'EG', role: 'Content Strategist'),
  ];

  @override
  void initState() {
    super.initState();
    final isEdit = widget.mode == TaskFormMode.edit;

    _titleController = TextEditingController(
      text: isEdit ? 'Fix broken contact form' : '',
    );
    _descriptionController = TextEditingController(
      text: isEdit
          ? 'Investigate and fix the contact form submission issue across supported browsers.'
          : '',
    );

    _selectedProject = _projects.first;
    _selectedStatus = isEdit ? 'In Progress' : 'Todo';
    _selectedPriority = isEdit ? 'Urgent' : 'Medium';
    _selectedAssignee = _teamMembers.first;
    _selectedDueDate = isEdit
        ? DateTime(2026, 1, 8)
        : DateTime.now().add(const Duration(days: 3));
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
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

  Future<void> _selectDueDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDueDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );
    if (picked != null) {
      setState(() => _selectedDueDate = picked);
    }
  }

  Future<void> _handleSubmit() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 600));

    if (!mounted) return;
    setState(() => _isLoading = false);

    final isEdit = widget.mode == TaskFormMode.edit;
    final message = isEdit
        ? 'Task "${_titleController.text.trim()}" updated successfully!'
        : 'Task "${_titleController.text.trim()}" created successfully!';

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMD.r),
        ),
      ),
    );

    if (context.canPop()) {
      context.pop();
    } else {
      context.go(RouteNames.tasks);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEdit = widget.mode == TaskFormMode.edit;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isTablet = constraints.maxWidth >= 720;
            final horizontalPadding = (isTablet ? AppDimensions.space32 : AppDimensions.space20).w;

            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 680),
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.symmetric(
                    horizontal: horizontalPadding,
                    vertical: AppDimensions.space20.h,
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // --- Header with Back Navigation ---
                        _buildHeader(context, isEdit),
                        SizedBox(height: AppDimensions.space24.h),

                        // --- Section 1: Task Information ---
                        _buildSectionHeader(context, 'Task information'),
                        SizedBox(height: AppDimensions.space12.h),

                        // Task Title
                        AppTextFormField(
                          controller: _titleController,
                          label: 'Task title',
                          hintText: 'e.g. Fix broken contact form',
                          textInputAction: TextInputAction.next,
                          textCapitalization: TextCapitalization.sentences,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Task title is required';
                            }
                            if (value.trim().length < 3) {
                              return 'Title must be at least 3 characters';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: AppDimensions.space16.h),

                        // Description Field
                        AppTextFormField(
                          controller: _descriptionController,
                          label: 'Description',
                          hintText: 'Describe what needs to be done...',
                          maxLines: 4,
                          minLines: 3,
                          textInputAction: TextInputAction.done,
                          textCapitalization: TextCapitalization.sentences,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please add a short description';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: AppDimensions.space24.h),

                        // --- Section 2: Project Selection ---
                        _buildSectionHeader(context, 'Project'),
                        SizedBox(height: AppDimensions.space12.h),
                        _buildProjectSelector(context),
                        SizedBox(height: AppDimensions.space24.h),

                        // --- Section 3: Status & Priority ---
                        _buildSectionHeader(context, 'Status & Priority'),
                        SizedBox(height: AppDimensions.space12.h),
                        Row(
                          children: [
                            Expanded(
                              child: _buildStatusSelector(context),
                            ),
                            SizedBox(width: AppDimensions.space12.w),
                            Expanded(
                              child: _buildPrioritySelector(context),
                            ),
                          ],
                        ),
                        SizedBox(height: AppDimensions.space24.h),

                        // --- Section 4: Assignee & Timeline ---
                        _buildSectionHeader(context, 'Assignee & Timeline'),
                        SizedBox(height: AppDimensions.space12.h),
                        Row(
                          children: [
                            Expanded(
                              child: _buildAssigneeSelector(context),
                            ),
                            SizedBox(width: AppDimensions.space12.w),
                            Expanded(
                              child: _buildDueDateSelector(context),
                            ),
                          ],
                        ),
                        SizedBox(height: AppDimensions.space32.h),

                        // --- Form Actions ---
                        _buildFormActions(context, isEdit),
                        SizedBox(height: AppDimensions.space24.h),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // ==========================================================================
  // Header
  // ==========================================================================
  Widget _buildHeader(BuildContext context, bool isEdit) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        IconButton.filledTonal(
          icon: const Icon(Icons.arrow_back_rounded),
          tooltip: 'Back',
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go(RouteNames.tasks);
            }
          },
        ),
        SizedBox(width: AppDimensions.space12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isEdit ? 'Edit task' : 'Create task',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 20.sp,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                isEdit
                    ? 'Update the details of this task.'
                    : 'Add a task and keep your project moving forward.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontSize: 13.sp,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    final theme = Theme.of(context);
    return Text(
      title,
      style: theme.textTheme.titleSmall?.copyWith(
        fontWeight: FontWeight.w700,
        fontSize: 14.sp,
      ),
    );
  }

  // ==========================================================================
  // Project Selector
  // ==========================================================================
  Widget _buildProjectSelector(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Material(
      color: theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(AppDimensions.radiusLG.r),
      child: InkWell(
        onTap: () => _showProjectPickerModal(context),
        borderRadius: BorderRadius.circular(AppDimensions.radiusLG.r),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppDimensions.radiusLG.r),
            border: Border.all(
              color: theme.colorScheme.outline.withValues(alpha: isDark ? 0.35 : 0.6),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 34.r,
                height: 34.r,
                decoration: BoxDecoration(
                  color: _selectedProject.color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusSM.r),
                ),
                alignment: Alignment.center,
                child: Text(
                  _selectedProject.initials,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: _selectedProject.color,
                    fontWeight: FontWeight.w700,
                  ),
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
                      ),
                    ),
                    Text(
                      _selectedProject.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 20.r,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showProjectPickerModal(BuildContext context) {
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
              'Select Project',
              style: theme.textTheme.titleMedium?.copyWith(
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: AppDimensions.space12.h),
            ..._projects.map((proj) {
              final isSelected = proj.id == _selectedProject.id;

              return Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    setState(() => _selectedProject = proj);
                    Navigator.of(context).pop();
                  },
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMD.r),
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 6.w),
                    child: Row(
                      children: [
                        Container(
                          width: 32.r,
                          height: 32.r,
                          decoration: BoxDecoration(
                            color: proj.color.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(AppDimensions.radiusSM.r),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            proj.initials,
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: proj.color,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        SizedBox(width: 10.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                proj.name,
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontSize: 13.5.sp,
                                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                ),
                              ),
                              Text(
                                '${proj.taskCount} tasks',
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
  // Status Selector
  // ==========================================================================
  Widget _buildStatusSelector(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Material(
      color: theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(AppDimensions.radiusLG.r),
      child: InkWell(
        onTap: () => _showStatusPickerModal(context),
        borderRadius: BorderRadius.circular(AppDimensions.radiusLG.r),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppDimensions.radiusLG.r),
            border: Border.all(
              color: theme.colorScheme.outline.withValues(alpha: isDark ? 0.35 : 0.6),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Status',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontSize: 11.sp,
                ),
              ),
              SizedBox(height: 4.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: StatusBadge(status: _selectedStatus, showDot: false),
                  ),
                  Icon(
                    Icons.arrow_drop_down_rounded,
                    size: 20.r,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showStatusPickerModal(BuildContext context) {
    const statuses = ['Todo', 'In Progress', 'Review', 'Done'];

    showModalBottomSheet<void>(
      context: context,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _SelectOptionModal(
        title: 'Select Status',
        options: statuses,
        selectedOption: _selectedStatus,
        onSelect: (value) {
          setState(() => _selectedStatus = value);
          Navigator.of(context).pop();
        },
      ),
    );
  }

  // ==========================================================================
  // Priority Selector
  // ==========================================================================
  Widget _buildPrioritySelector(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Material(
      color: theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(AppDimensions.radiusLG.r),
      child: InkWell(
        onTap: () => _showPriorityPickerModal(context),
        borderRadius: BorderRadius.circular(AppDimensions.radiusLG.r),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppDimensions.radiusLG.r),
            border: Border.all(
              color: theme.colorScheme.outline.withValues(alpha: isDark ? 0.35 : 0.6),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Priority',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontSize: 11.sp,
                ),
              ),
              SizedBox(height: 4.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: PriorityBadge(priority: _selectedPriority),
                  ),
                  Icon(
                    Icons.arrow_drop_down_rounded,
                    size: 20.r,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showPriorityPickerModal(BuildContext context) {
    const priorities = ['Low', 'Medium', 'High', 'Urgent'];

    showModalBottomSheet<void>(
      context: context,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _SelectOptionModal(
        title: 'Select Priority',
        options: priorities,
        selectedOption: _selectedPriority,
        onSelect: (value) {
          setState(() => _selectedPriority = value);
          Navigator.of(context).pop();
        },
      ),
    );
  }

  // ==========================================================================
  // Assignee Selector
  // ==========================================================================
  Widget _buildAssigneeSelector(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Material(
      color: theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(AppDimensions.radiusLG.r),
      child: InkWell(
        onTap: () => _showAssigneePickerModal(context),
        borderRadius: BorderRadius.circular(AppDimensions.radiusLG.r),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppDimensions.radiusLG.r),
            border: Border.all(
              color: theme.colorScheme.outline.withValues(alpha: isDark ? 0.35 : 0.6),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Assignee',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontSize: 11.sp,
                ),
              ),
              SizedBox(height: 4.h),
              Row(
                children: [
                  UserAvatar(
                    name: _selectedAssignee.name,
                    initials: _selectedAssignee.initials,
                    size: 22.0,
                  ),
                  SizedBox(width: 6.w),
                  Expanded(
                    child: Text(
                      _selectedAssignee.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.labelMedium?.copyWith(
                        fontSize: 12.5.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.arrow_drop_down_rounded,
                    size: 20.r,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAssigneePickerModal(BuildContext context) {
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
              'Assign Task To',
              style: theme.textTheme.titleMedium?.copyWith(
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: AppDimensions.space12.h),
            ..._teamMembers.map((member) {
              final isSelected = member.name == _selectedAssignee.name;

              return Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    setState(() => _selectedAssignee = member);
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
  // Due Date Selector
  // ==========================================================================
  Widget _buildDueDateSelector(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Material(
      color: theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(AppDimensions.radiusLG.r),
      child: InkWell(
        onTap: () => _selectDueDate(context),
        borderRadius: BorderRadius.circular(AppDimensions.radiusLG.r),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppDimensions.radiusLG.r),
            border: Border.all(
              color: theme.colorScheme.outline.withValues(alpha: isDark ? 0.35 : 0.6),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Due date',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontSize: 11.sp,
                ),
              ),
              SizedBox(height: 4.h),
              Row(
                children: [
                  Icon(
                    Icons.calendar_today_rounded,
                    size: 16.r,
                    color: AppColors.warning,
                  ),
                  SizedBox(width: 6.w),
                  Expanded(
                    child: Text(
                      _formatDate(_selectedDueDate),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.labelMedium?.copyWith(
                        fontSize: 12.5.sp,
                        fontWeight: FontWeight.w600,
                      ),
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

  // ==========================================================================
  // Form Action Buttons
  // ==========================================================================
  Widget _buildFormActions(BuildContext context, bool isEdit) {
    return Row(
      children: [
        Expanded(
          flex: 4,
          child: AppButton(
            text: 'Cancel',
            type: AppButtonType.outlined,
            height: 48.h,
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go(RouteNames.tasks);
              }
            },
          ),
        ),
        SizedBox(width: AppDimensions.space12.w),
        Expanded(
          flex: 6,
          child: AppButton(
            text: isEdit ? 'Save Changes' : 'Create Task',
            prefixIcon: isEdit ? Icons.check_rounded : Icons.add_rounded,
            height: 48.h,
            isLoading: _isLoading,
            onPressed: _handleSubmit,
          ),
        ),
      ],
    );
  }
}

// ============================================================================
// Private Helper Modal for Option Selection
// ============================================================================
class _SelectOptionModal extends StatelessWidget {
  const _SelectOptionModal({
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
