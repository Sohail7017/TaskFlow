import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/routes/route_names.dart';
import '../../../core/theme/app_colors.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/app_text_form_field.dart';

/// Supported status choices for a new project
enum _ProjectStatusChoice {
  active('Active', 'In active development', AppColors.statusInProgress, Icons.play_circle_outline_rounded),
  review('Review', 'Under review / approval', AppColors.statusReview, Icons.rate_review_outlined),
  completed('Completed', 'All objectives achieved', AppColors.statusDone, Icons.check_circle_outline_rounded);

  const _ProjectStatusChoice(this.label, this.description, this.color, this.icon);
  final String label;
  final String description;
  final Color color;
  final IconData icon;
}

/// Premium, production-quality Add Project form screen for TaskFlow
class AddProjectScreen extends StatefulWidget {
  const AddProjectScreen({super.key});

  @override
  State<AddProjectScreen> createState() => _AddProjectScreenState();
}

class _AddProjectScreenState extends State<AddProjectScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  // Local form state
  _ProjectStatusChoice _selectedStatus = _ProjectStatusChoice.active;
  DateTime? _startDate;
  DateTime? _endDate;
  Color _selectedAccentColor = AppColors.primaryLight;
  bool _isLoading = false;

  // Available brand accent color options for project identity
  static const List<Color> _accentColors = [
    AppColors.primaryLight, // Indigo 600
    AppColors.secondary, // Teal 600
    AppColors.info, // Sky Blue
    Color(0xFF7C3AED), // Purple 600
    Color(0xFFEA580C), // Orange 600
    Color(0xFF059669), // Emerald 600
  ];

  @override
  void initState() {
    super.initState();
    // Default initial dates
    _startDate = DateTime.now();
    _endDate = DateTime.now().add(const Duration(days: 30));
    _nameController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  String _computeInitials(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return 'NP';
    final parts = trimmed.split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.length >= 2) {
      return (parts[0][0] + parts[1][0]).toUpperCase();
    }
    if (parts[0].length >= 2) {
      return parts[0].substring(0, 2).toUpperCase();
    }
    return parts[0][0].toUpperCase();
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Select date';
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final day = date.day.toString().padLeft(2, '0');
    final month = months[date.month - 1];
    final year = date.year;
    return '$day $month $year';
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final initialDate = isStartDate ? (_startDate ?? DateTime.now()) : (_endDate ?? DateTime.now());
    final firstDate = isStartDate
        ? DateTime(2020)
        : (_startDate ?? DateTime(2020));
    final lastDate = DateTime(2035);

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
    );

    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
          if (_endDate != null && _endDate!.isBefore(_startDate!)) {
            _endDate = _startDate!.add(const Duration(days: 14));
          }
        } else {
          _endDate = picked;
        }
      });
    }
  }

  Future<void> _handleSubmit() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    // Simulate local UI submission delay
    await Future.delayed(const Duration(milliseconds: 700));

    if (!mounted) return;

    setState(() => _isLoading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Project "${_nameController.text.trim()}" created successfully!'),
        backgroundColor: AppColors.success,
      ),
    );

    if (context.canPop()) {
      context.pop();
    } else {
      context.go(RouteNames.projects);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          padding: EdgeInsets.symmetric(
            horizontal: AppDimensions.space20.w,
            vertical: AppDimensions.space16.h,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 680),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // 1. Header with Back Button & Titles
                    _buildHeader(context),

                    SizedBox(height: AppDimensions.space24.h),

                    // 2. Project Details Section (Name, Identity Badge, Description)
                    _buildSectionContainer(
                      context,
                      title: 'Project details',
                      subtitle: 'Basic information identifying your project',
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Project Name with dynamic Identity Initials Preview
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Identity Initials Avatar preview
                              Padding(
                                padding: EdgeInsets.only(top: 24.h, right: 12.w),
                                child: AnimatedContainer(
                                  duration: AppAnimations.fast,
                                  width: 44.r,
                                  height: 44.r,
                                  decoration: BoxDecoration(
                                    color: _selectedAccentColor.withValues(
                                      alpha: isDark ? 0.25 : 0.15,
                                    ),
                                    borderRadius: BorderRadius.circular(AppDimensions.radiusMD.r),
                                    border: Border.all(
                                      color: _selectedAccentColor.withValues(alpha: 0.5),
                                      width: 1.5,
                                    ),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    _computeInitials(_nameController.text),
                                    style: theme.textTheme.titleMedium?.copyWith(
                                      color: _selectedAccentColor,
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: AppTextFormField(
                                  controller: _nameController,
                                  label: 'Project name',
                                  hintText: 'e.g. Website Relaunch',
                                  textInputAction: TextInputAction.next,
                                  textCapitalization: TextCapitalization.words,
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return 'Project name is required';
                                    }
                                    if (value.trim().length < 3) {
                                      return 'Must be at least 3 characters';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                            ],
                          ),

                          SizedBox(height: AppDimensions.space16.h),

                          // Accent Color Picker
                          Text(
                            'Project identity color',
                            style: theme.textTheme.labelMedium?.copyWith(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: AppDimensions.space8.h),
                          Wrap(
                            spacing: 10.w,
                            runSpacing: 8.h,
                            children: _accentColors.map((color) {
                              final isSelected = _selectedAccentColor == color;
                              return GestureDetector(
                                onTap: () => setState(() => _selectedAccentColor = color),
                                child: AnimatedContainer(
                                  duration: AppAnimations.fast,
                                  width: 32.r,
                                  height: 32.r,
                                  decoration: BoxDecoration(
                                    color: color,
                                    shape: BoxShape.circle,
                                    border: isSelected
                                        ? Border.all(
                                            color: theme.colorScheme.onSurface,
                                            width: 2.5,
                                          )
                                        : null,
                                    boxShadow: isSelected
                                        ? [
                                            BoxShadow(
                                              color: color.withValues(alpha: 0.4),
                                              blurRadius: 6.r,
                                              offset: Offset(0, 2.h),
                                            ),
                                          ]
                                        : null,
                                  ),
                                  child: isSelected
                                      ? Icon(
                                          Icons.check_rounded,
                                          size: 18.r,
                                          color: Colors.white,
                                        )
                                      : null,
                                ),
                              );
                            }).toList(),
                          ),

                          SizedBox(height: AppDimensions.space20.h),

                          // Description Multiline field
                          AppTextFormField(
                            controller: _descriptionController,
                            label: 'Description',
                            hintText: 'Describe what this project is about, objectives, or scope...',
                            maxLines: 4,
                            minLines: 3,
                            textCapitalization: TextCapitalization.sentences,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please add a short description';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: AppDimensions.space20.h),

                    // 3. Project Status Section
                    _buildSectionContainer(
                      context,
                      title: 'Project status',
                      subtitle: 'Current lifecycle state of this project',
                      child: Column(
                        children: _ProjectStatusChoice.values.map((choice) {
                          final isSelected = _selectedStatus == choice;
                          return Padding(
                            padding: EdgeInsets.only(bottom: 8.h),
                            child: Material(
                              color: isSelected
                                  ? choice.color.withValues(alpha: isDark ? 0.18 : 0.08)
                                  : theme.colorScheme.surface,
                              borderRadius: BorderRadius.circular(AppDimensions.radiusMD.r),
                              child: InkWell(
                                onTap: () => setState(() => _selectedStatus = choice),
                                borderRadius: BorderRadius.circular(AppDimensions.radiusMD.r),
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 14.w,
                                    vertical: 12.h,
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(AppDimensions.radiusMD.r),
                                    border: Border.all(
                                      color: isSelected
                                          ? choice.color.withValues(alpha: 0.6)
                                          : theme.colorScheme.outline.withValues(
                                              alpha: isDark ? 0.35 : 0.6,
                                            ),
                                      width: isSelected ? 1.4 : 1.0,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: EdgeInsets.all(6.r),
                                        decoration: BoxDecoration(
                                          color: choice.color.withValues(alpha: 0.15),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          choice.icon,
                                          size: 18.r,
                                          color: choice.color,
                                        ),
                                      ),
                                      SizedBox(width: 12.w),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              choice.label,
                                              style: theme.textTheme.titleSmall?.copyWith(
                                                fontSize: 14.sp,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            Text(
                                              choice.description,
                                              style: theme.textTheme.bodySmall?.copyWith(
                                                color: theme.colorScheme.onSurfaceVariant,
                                                fontSize: 12.sp,
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
                                            ? choice.color
                                            : theme.colorScheme.outline.withValues(alpha: 0.6),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),

                    SizedBox(height: AppDimensions.space20.h),

                    // 4. Timeline Section (Start Date & End Date)
                    _buildSectionContainer(
                      context,
                      title: 'Timeline',
                      subtitle: 'Estimated start and completion targets',
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final isNarrow = constraints.maxWidth < 420;

                          final startField = _buildDateSelectorField(
                            context: context,
                            label: 'Start date',
                            dateText: _formatDate(_startDate),
                            onTap: () => _selectDate(context, true),
                          );

                          final endField = _buildDateSelectorField(
                            context: context,
                            label: 'End date',
                            dateText: _formatDate(_endDate),
                            onTap: () => _selectDate(context, false),
                          );

                          if (isNarrow) {
                            return Column(
                              children: [
                                startField,
                                SizedBox(height: 12.h),
                                endField,
                              ],
                            );
                          }

                          return Row(
                            children: [
                              Expanded(child: startField),
                              SizedBox(width: 12.w),
                              Expanded(child: endField),
                            ],
                          );
                        },
                      ),
                    ),

                    SizedBox(height: AppDimensions.space32.h),

                    // 5. Action Buttons (Cancel & Create Project)
                    _buildActionButtons(context),

                    SizedBox(height: AppDimensions.space24.h),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ==========================================================================
  // Header
  // ==========================================================================
  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        IconButton.filledTonal(
          icon: const Icon(Icons.arrow_back_rounded),
          tooltip: 'Back',
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go(RouteNames.projects);
            }
          },
        ),
        SizedBox(width: 14.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Create a project',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontSize: 22.sp,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.3,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                'Set up a new project and start organizing your work.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontSize: 12.5.sp,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ==========================================================================
  // Section Container Helper
  // ==========================================================================
  Widget _buildSectionContainer(
    BuildContext context, {
    required String title,
    required String subtitle,
    required Widget child,
  }) {
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
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontSize: 15.5.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            subtitle,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontSize: 12.sp,
            ),
          ),
          SizedBox(height: AppDimensions.space16.h),
          child,
        ],
      ),
    );
  }

  // ==========================================================================
  // Date Selector Field Widget
  // ==========================================================================
  Widget _buildDateSelectorField({
    required BuildContext context,
    required String label,
    required String dateText,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.labelMedium?.copyWith(
            fontSize: 13.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: AppDimensions.space6.h),
        Material(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMD.r),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(AppDimensions.radiusMD.r),
            child: Container(
              height: 48.h,
              padding: EdgeInsets.symmetric(horizontal: 12.w),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppDimensions.radiusMD.r),
                border: Border.all(
                  color: theme.colorScheme.outline.withValues(alpha: isDark ? 0.35 : 0.6),
                  width: 1.0,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.calendar_today_rounded,
                    size: 17.r,
                    color: theme.colorScheme.primary,
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Text(
                      dateText,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontSize: 13.5.sp,
                        fontWeight: FontWeight.w500,
                      ),
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
  // Action Buttons (Cancel & Create Project)
  // ==========================================================================
  Widget _buildActionButtons(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 360;

        final cancelButton = AppButton(
          text: 'Cancel',
          type: AppButtonType.outlined,
          isFullWidth: isNarrow,
          height: 48.h,
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go(RouteNames.projects);
            }
          },
        );

        final submitButton = AppButton(
          text: 'Create Project',
          icon: Icons.add_rounded,
          isFullWidth: isNarrow,
          height: 48.h,
          isLoading: _isLoading,
          onPressed: _handleSubmit,
        );

        if (isNarrow) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              submitButton,
              SizedBox(height: 10.h),
              cancelButton,
            ],
          );
        }

        return Row(
          children: [
            Expanded(
              flex: 4,
              child: cancelButton,
            ),
            SizedBox(width: 12.w),
            Expanded(
              flex: 6,
              child: submitButton,
            ),
          ],
        );
      },
    );
  }
}
