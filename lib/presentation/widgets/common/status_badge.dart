import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/theme/app_colors.dart';

/// Reusable status badge component for TaskFlow tasks
class StatusBadge extends StatelessWidget {
  const StatusBadge({
    super.key,
    required this.status,
    this.showDot = true,
  });

  final String status;
  final bool showDot;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final normalized = status.trim().toLowerCase();

    final Color foregroundColor;
    final Color backgroundColor;

    if (normalized == 'done' || normalized == 'completed') {
      foregroundColor = AppColors.statusDone;
      backgroundColor = isDark ? AppColors.statusDoneBgDark : AppColors.statusDoneBgLight;
    } else if (normalized == 'in progress' || normalized == 'in_progress') {
      foregroundColor = isDark ? AppColors.primaryLight : AppColors.statusInProgress;
      backgroundColor = isDark ? AppColors.statusInProgressBgDark : AppColors.statusInProgressBgLight;
    } else if (normalized == 'review' || normalized == 'in review' || normalized == 'in_review') {
      foregroundColor = isDark ? AppColors.warning : AppColors.statusReview;
      backgroundColor = isDark ? AppColors.statusReviewBgDark : AppColors.statusReviewBgLight;
    } else {
      // Todo / Default
      foregroundColor = isDark ? AppColors.textSecondaryDark : AppColors.statusTodo;
      backgroundColor = isDark ? AppColors.statusTodoBgDark : AppColors.statusTodoBgLight;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(AppDimensions.radiusFull.r),
        border: Border.all(
          color: foregroundColor.withValues(alpha: isDark ? 0.25 : 0.2),
          width: 0.8,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showDot) ...[
            Container(
              width: 6.r,
              height: 6.r,
              decoration: BoxDecoration(
                color: foregroundColor,
                shape: BoxShape.circle,
              ),
            ),
            SizedBox(width: 5.w),
          ],
          Flexible(
            child: Text(
              _formatStatus(status),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
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

  String _formatStatus(String text) {
    if (text.isEmpty) return text;
    final words = text.replaceAll('_', ' ').split(' ');
    return words
        .map((w) => w.isNotEmpty ? '${w[0].toUpperCase()}${w.substring(1).toLowerCase()}' : w)
        .join(' ');
  }
}
