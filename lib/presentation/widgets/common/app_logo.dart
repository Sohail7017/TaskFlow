import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/theme/app_colors.dart';

/// A premium, scalable brand logo for the TaskFlow application
class AppLogo extends StatelessWidget {
  const AppLogo({
    super.key,
    this.size = 64.0,
    this.showText = false,
    this.tagline,
  });

  final double size;
  final bool showText;
  final String? tagline;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final logoIcon = Container(
      width: size.r,
      height: size.r,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primaryLight,
            AppColors.primary,
            AppColors.primaryDark,
          ],
        ),
        borderRadius: BorderRadius.circular((size * 0.25).r),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: (size * 0.25).r,
            offset: Offset(0, (size * 0.08).r),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background subtle accent circle
          Positioned(
            right: (size * 0.12).r,
            top: (size * 0.12).r,
            child: Container(
              width: (size * 0.28).r,
              height: (size * 0.28).r,
              decoration: BoxDecoration(
                color: AppColors.mintAccent.withValues(alpha: 0.85),
                shape: BoxShape.circle,
              ),
            ),
          ),
          // Foreground icon
          Icon(
            Icons.checklist_rounded,
            size: (size * 0.55).r,
            color: Colors.white,
          ),
        ],
      ),
    );

    if (!showText) {
      return logoIcon;
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        logoIcon,
        SizedBox(height: AppDimensions.space16.h),
        Text(
          'TaskFlow',
          style: theme.textTheme.headlineLarge?.copyWith(
            fontSize: 24.sp,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
          ),
        ),
        if (tagline != null) ...[
          SizedBox(height: AppDimensions.space6.h),
          Text(
            tagline!,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontSize: 13.sp,
              fontWeight: FontWeight.w400,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ],
    );
  }
}
