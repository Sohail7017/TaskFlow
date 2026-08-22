import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/theme/app_colors.dart';

/// Reusable priority badge component for TaskFlow tasks
class PriorityBadge extends StatelessWidget {
  const PriorityBadge({
    super.key,
    required this.priority,
    this.showIcon = true,
  });

  final String priority;
  final bool showIcon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final normalized = priority.trim().toLowerCase();

    final Color foregroundColor;
    final Color backgroundColor;
    final IconData icon;

    if (normalized == 'urgent') {
      foregroundColor = isDark ? AppColors.priorityUrgentDark : AppColors.priorityUrgent;
      backgroundColor = isDark ? AppColors.priorityUrgentBgDark : AppColors.priorityUrgentBgLight;
      icon = Icons.priority_high_rounded;
    } else if (normalized == 'high') {
      foregroundColor = isDark ? AppColors.priorityHighDark : AppColors.priorityHigh;
      backgroundColor = isDark ? AppColors.priorityHighBgDark : AppColors.priorityHighBgLight;
      icon = Icons.keyboard_double_arrow_up_rounded;
    } else if (normalized == 'medium') {
      foregroundColor = isDark ? AppColors.priorityMediumDark : AppColors.priorityMedium;
      backgroundColor = isDark ? AppColors.priorityMediumBgDark : AppColors.priorityMediumBgLight;
      icon = Icons.drag_handle_rounded;
    } else {
      // Low / Default
      foregroundColor = isDark ? AppColors.priorityLowDark : AppColors.priorityLow;
      backgroundColor = isDark ? AppColors.priorityLowBgDark : AppColors.priorityLowBgLight;
      icon = Icons.keyboard_arrow_down_rounded;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(AppDimensions.radiusSM.r),
        border: Border.all(
          color: foregroundColor.withValues(alpha: isDark ? 0.25 : 0.2),
          width: 0.8,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showIcon) ...[
            Icon(
              icon,
              size: 14.r,
              color: foregroundColor,
            ),
            SizedBox(width: 4.w),
          ],
          Flexible(
            child: Text(
              _formatPriority(priority),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelSmall?.copyWith(
                color: foregroundColor,
                fontSize: 11.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatPriority(String text) {
    if (text.isEmpty) return text;
    return '${text[0].toUpperCase()}${text.substring(1).toLowerCase()}';
  }
}
