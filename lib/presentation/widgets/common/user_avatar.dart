import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Reusable user avatar with fallback initials and theme-adaptive styling
class UserAvatar extends StatelessWidget {
  const UserAvatar({
    super.key,
    this.name = 'Ava Davis',
    this.initials,
    this.size = 36.0,
    this.imageUrl,
    this.backgroundColor,
    this.textColor,
    this.border,
  });

  final String name;
  final String? initials;
  final double size;
  final String? imageUrl;
  final Color? backgroundColor;
  final Color? textColor;
  final BoxBorder? border;

  String get _effectiveInitials {
    if (initials != null && initials!.isNotEmpty) {
      return initials!;
    }
    final parts = name.trim().split(' ');
    if (parts.length >= 2 && parts[0].isNotEmpty && parts[1].isNotEmpty) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    if (name.isNotEmpty) {
      return name.substring(0, name.length >= 2 ? 2 : 1).toUpperCase();
    }
    return 'U';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bgColor = backgroundColor ?? theme.colorScheme.primaryContainer;
    final fgColor = textColor ?? theme.colorScheme.primary;

    return Container(
      width: size.r,
      height: size.r,
      decoration: BoxDecoration(
        color: bgColor,
        shape: BoxShape.circle,
        border: border ??
            Border.all(
              color: theme.colorScheme.outline,
              width: 1.0,
            ),
      ),
      child: Center(
        child: Text(
          _effectiveInitials,
          style: theme.textTheme.labelSmall?.copyWith(
            color: fgColor,
            fontSize: (size * 0.38).sp,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
