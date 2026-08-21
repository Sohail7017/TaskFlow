import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_dimensions.dart';

/// A lightweight, reusable AppBar for TaskFlow screens
class AppAppBar extends StatelessWidget implements PreferredSizeWidget {
  const AppAppBar({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.showBackButton = true,
    this.actions,
    this.centerTitle = false,
    this.bottom,
    this.backgroundColor,
  });

  final String title;
  final String? subtitle;
  final Widget? leading;
  final bool showBackButton;
  final List<Widget>? actions;
  final bool centerTitle;
  final PreferredSizeWidget? bottom;
  final Color? backgroundColor;

  @override
  Size get preferredSize => Size.fromHeight(
        (subtitle != null ? 64.0 : 56.0).h + (bottom?.preferredSize.height ?? 0),
      );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppBar(
      centerTitle: centerTitle,
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: backgroundColor,
      leading: leading ?? (showBackButton && (context.canPop() || Navigator.canPop(context))
          ? IconButton(
              icon: Icon(
                Icons.arrow_back_rounded,
                size: AppDimensions.iconLG.r,
              ),
              onPressed: () {
                if (context.canPop()) {
                  context.pop();
                } else if (Navigator.canPop(context)) {
                  Navigator.of(context).pop();
                }
              },
            )
          : null),
      title: Column(
        crossAxisAlignment: centerTitle ? CrossAxisAlignment.center : CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.titleLarge?.copyWith(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (subtitle != null) ...[
            SizedBox(height: 2.h),
            Text(
              subtitle!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontSize: 12.sp,
              ),
            ),
          ],
        ],
      ),
      actions: actions != null
          ? [
              ...actions!,
              SizedBox(width: AppDimensions.space8.w),
            ]
          : null,
      bottom: bottom,
    );
  }
}
