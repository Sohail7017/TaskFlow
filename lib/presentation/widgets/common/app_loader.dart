import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/constants/app_dimensions.dart';

/// Reusable loading indicators (inline and full-screen content loader)
class AppLoader extends StatelessWidget {
  const AppLoader({
    super.key,
    this.message,
    this.size,
    this.color,
    this.strokeWidth = 3.0,
  });

  /// Full-screen or centered content loader with optional message
  const AppLoader.fullScreen({
    super.key,
    this.message = 'Loading...',
    this.size = 36.0,
    this.color,
    this.strokeWidth = 3.5,
  });

  final String? message;
  final double? size;
  final Color? color;
  final double strokeWidth;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loaderColor = color ?? theme.colorScheme.primary;

    final indicator = SizedBox(
      width: (size ?? 24.0).r,
      height: (size ?? 24.0).r,
      child: CircularProgressIndicator(
        strokeWidth: strokeWidth,
        valueColor: AlwaysStoppedAnimation<Color>(loaderColor),
      ),
    );

    if (message == null) {
      return Center(child: indicator);
    }

    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppDimensions.space24.r),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            indicator,
            SizedBox(height: AppDimensions.space16.h),
            Text(
              message!,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontSize: 14.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
