import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/constants/app_dimensions.dart';

/// Supported visual button types for [AppButton]
enum AppButtonType { filled, outlined }

/// Supported button shapes for [AppButton]
enum AppButtonShape { rounded, pill }

/// A single, unified, premium reusable button component for TaskFlow
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    this.text,
    required this.onPressed,
    this.type = AppButtonType.filled,
    this.shape = AppButtonShape.rounded,
    this.borderRadius,
    this.isFullWidth = true,
    this.isLoading = false,
    this.enabled = true,
    this.isDestructive = false,
    this.icon,
    this.trailingIcon,
    this.prefixIcon,
    this.suffixIcon,
    this.isIconOnly = false,
    this.semanticLabel,
    this.width,
    this.height,
  });

  final String? text;
  final VoidCallback? onPressed;
  final AppButtonType type;
  final AppButtonShape shape;
  final double? borderRadius;
  final bool isFullWidth;
  final bool isLoading;
  final bool enabled;
  final bool isDestructive;
  final IconData? icon;
  final IconData? trailingIcon;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final bool isIconOnly;
  final String? semanticLabel;
  final double? width;
  final double? height;

  bool get _isInteractive => enabled && !isLoading && onPressed != null;

  IconData? get _effectiveLeadingIcon => icon ?? prefixIcon;
  IconData? get _effectiveTrailingIcon => trailingIcon ?? suffixIcon;

  double _getEffectiveRadius() {
    if (borderRadius != null) {
      return borderRadius!.r;
    }
    switch (shape) {
      case AppButtonShape.pill:
        return AppDimensions.radiusFull.r;
      case AppButtonShape.rounded:
        return AppDimensions.radiusMD.r;
    }
  }

  @override
  Widget build(BuildContext context) {
    final effectiveHeight = height ?? 48.h;
    final effectiveWidth = isFullWidth ? (width ?? double.infinity) : width;
    final radius = _getEffectiveRadius();
    final border = _getBorder(context);

    Widget buttonContent = Semantics(
      button: true,
      enabled: _isInteractive,
      label: semanticLabel ?? text,
      child: AnimatedContainer(
        duration: AppAnimations.fast,
        curve: Curves.easeInOut,
        child: Material(
          color: _getBackgroundColor(context),
          borderRadius: BorderRadius.circular(radius),
          child: InkWell(
            onTap: _isInteractive ? onPressed : null,
            borderRadius: BorderRadius.circular(radius),
            splashColor: _getSplashColor(context),
            highlightColor: Colors.transparent,
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: isIconOnly ? 12.w : 16.w,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(radius),
                border: border,
              ),
              child: Center(
                child: AnimatedSwitcher(
                  duration: AppAnimations.fast,
                  child: isLoading
                      ? _buildLoader(context)
                      : _buildContent(context),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    if (effectiveWidth != null || height != null) {
      buttonContent = SizedBox(
        width: effectiveWidth,
        height: effectiveHeight,
        child: buttonContent,
      );
    } else {
      buttonContent = ConstrainedBox(
        constraints: BoxConstraints(minHeight: effectiveHeight),
        child: buttonContent,
      );
    }

    if (semanticLabel != null) {
      return Tooltip(message: semanticLabel!, child: buttonContent);
    }

    return buttonContent;
  }

  Widget _buildContent(BuildContext context) {
    final textColor = _getTextColor(context);
    final leading = _effectiveLeadingIcon;
    final trailing = _effectiveTrailingIcon;

    if (isIconOnly && leading != null) {
      return Icon(
        leading,
        key: const ValueKey<String>('app_button_icon_only'),
        size: AppDimensions.iconMD.r,
        color: textColor,
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (leading != null) ...[
          Icon(
            leading,
            key: const ValueKey<String>('app_button_leading_icon'),
            size: AppDimensions.iconMD.r,
            color: textColor,
          ),
          SizedBox(width: AppDimensions.space8.w),
        ],
        if (text != null && text!.isNotEmpty)
          Flexible(
            child: Text(
              text!,
              key: const ValueKey<String>('app_button_text'),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: textColor,
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        if (trailing != null) ...[
          SizedBox(width: AppDimensions.space8.w),
          Icon(
            trailing,
            key: const ValueKey<String>('app_button_trailing_icon'),
            size: AppDimensions.iconMD.r,
            color: textColor,
          ),
        ],
      ],
    );
  }

  Widget _buildLoader(BuildContext context) {
    return SizedBox(
      key: const ValueKey<String>('app_button_loader'),
      width: 20.r,
      height: 20.r,
      child: CircularProgressIndicator(
        strokeWidth: 2.2,
        valueColor: AlwaysStoppedAnimation<Color>(_getTextColor(context)),
      ),
    );
  }

  Color _getBackgroundColor(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (!_isInteractive) {
      if (type == AppButtonType.outlined) {
        return Colors.transparent;
      }
      return colorScheme.onSurface.withValues(alpha: 0.12);
    }

    switch (type) {
      case AppButtonType.filled:
        return isDestructive ? colorScheme.error : colorScheme.primary;
      case AppButtonType.outlined:
        return Colors.transparent;
    }
  }

  Border? _getBorder(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (type == AppButtonType.filled) {
      return null;
    }

    if (!_isInteractive) {
      return Border.all(
        color: colorScheme.onSurface.withValues(alpha: 0.15),
        width: 1.0,
      );
    }

    if (isDestructive) {
      return Border.all(color: colorScheme.error, width: 1.2);
    }

    return Border.all(color: colorScheme.primary, width: 1.2);
  }

  Color _getTextColor(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (!_isInteractive) {
      return colorScheme.onSurface.withValues(alpha: 0.38);
    }

    switch (type) {
      case AppButtonType.filled:
        return isDestructive ? colorScheme.onError : colorScheme.onPrimary;
      case AppButtonType.outlined:
        return isDestructive ? colorScheme.error : colorScheme.primary;
    }
  }

  Color _getSplashColor(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (type == AppButtonType.filled) {
      return (isDestructive ? colorScheme.onError : colorScheme.onPrimary)
          .withValues(alpha: 0.15);
    }

    return (isDestructive ? colorScheme.error : colorScheme.primary).withValues(
      alpha: 0.12,
    );
  }
}
