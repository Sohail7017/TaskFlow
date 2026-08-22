import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/constants/app_dimensions.dart';
import 'app_button.dart';

/// Reusable empty-state display for lists and sections
class AppEmptyView extends StatelessWidget {
  const AppEmptyView({
    super.key,
    required this.title,
    this.description,
    this.icon = Icons.inbox_outlined,
    this.actionText,
    this.onAction,
    this.iconColor,
  });

  final String title;
  final String? description;
  final IconData icon;
  final String? actionText;
  final VoidCallback? onAction;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final effectiveIconColor = iconColor ?? colorScheme.onSurfaceVariant;

    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: AppDimensions.space32.w,
          vertical: AppDimensions.space24.h,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72.r,
              height: 72.r,
              decoration: BoxDecoration(
                color: colorScheme.surface,
                shape: BoxShape.circle,
                border: Border.all(
                  color: colorScheme.outline,
                ),
              ),
              child: Icon(
                icon,
                size: 36.r,
                color: effectiveIconColor,
              ),
            ),
            SizedBox(height: AppDimensions.space20.h),
            Text(
              title,
              textAlign: TextAlign.center,
              style: textTheme.titleMedium?.copyWith(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (description != null) ...[
              SizedBox(height: AppDimensions.space8.h),
              Text(
                description!,
                textAlign: TextAlign.center,
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontSize: 14.sp,
                  height: 1.4,
                ),
              ),
            ],
            if (actionText != null && onAction != null) ...[
              SizedBox(height: AppDimensions.space24.h),
              AppButton(
                text: actionText!,
                onPressed: onAction,
                isFullWidth: false,
                height: 40.h,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
