import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/routes/route_names.dart';

/// Supported main destination tabs
enum NavTab {
  home,
  projects,
  tasks,
  profile,
}

/// A floating, pill-shaped navigation dock for TaskFlow main screens
class FloatingBottomNav extends StatelessWidget {
  const FloatingBottomNav({
    super.key,
    required this.currentTab,
    this.onTabSelected,
  });

  final NavTab currentTab;
  final ValueChanged<NavTab>? onTabSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Align(
      alignment: Alignment.bottomCenter,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.only(
            left: 20.w,
            right: 20.w,
            bottom: 12.h,
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 460),
            child: Container(
              constraints: const BoxConstraints(minHeight: 56.0),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface.withValues(alpha: isDark ? 0.94 : 0.97),
                borderRadius: BorderRadius.circular(AppDimensions.radiusFull.r),
                border: Border.all(
                  color: theme.colorScheme.outline.withValues(alpha: isDark ? 0.4 : 0.6),
                  width: 1.0,
                ),
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.shadow.withValues(alpha: isDark ? 0.35 : 0.08),
                    blurRadius: 20.r,
                    offset: Offset(0, 6.h),
                  ),
                ],
              ),
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildNavItem(
                    context,
                    tab: NavTab.home,
                    icon: Icons.dashboard_outlined,
                    activeIcon: Icons.dashboard_rounded,
                    label: 'Home',
                    route: RouteNames.dashboard,
                  ),
                  _buildNavItem(
                    context,
                    tab: NavTab.projects,
                    icon: Icons.folder_outlined,
                    activeIcon: Icons.folder_rounded,
                    label: 'Projects',
                    route: RouteNames.projects,
                  ),
                  _buildNavItem(
                    context,
                    tab: NavTab.tasks,
                    icon: Icons.checklist_outlined,
                    activeIcon: Icons.checklist_rounded,
                    label: 'Tasks',
                    route: RouteNames.tasks,
                  ),
                  _buildNavItem(
                    context,
                    tab: NavTab.profile,
                    icon: Icons.person_outline_rounded,
                    activeIcon: Icons.person_rounded,
                    label: 'Profile',
                    route: RouteNames.profile,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context, {
    required NavTab tab,
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required String route,
  }) {
    final theme = Theme.of(context);
    final isSelected = currentTab == tab;
    final primaryColor = theme.colorScheme.primary;
    final inactiveColor = theme.colorScheme.onSurfaceVariant;

    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            if (onTabSelected != null) {
              onTabSelected!(tab);
            } else if (!isSelected) {
              context.go(route);
            }
          },
          borderRadius: BorderRadius.circular(AppDimensions.radiusFull.r),
          child: AnimatedContainer(
            duration: AppAnimations.fast,
            curve: Curves.easeInOut,
            padding: EdgeInsets.symmetric(vertical: 4.h),
            decoration: BoxDecoration(
              color: isSelected
                  ? primaryColor.withValues(alpha: 0.1)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(AppDimensions.radiusFull.r),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedSwitcher(
                  duration: AppAnimations.fast,
                  child: Icon(
                    isSelected ? activeIcon : icon,
                    key: ValueKey<bool>(isSelected),
                    size: 20.r,
                    color: isSelected ? primaryColor : inactiveColor,
                  ),
                ),
                SizedBox(height: 2.h),
                Flexible(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: isSelected ? primaryColor : inactiveColor,
                      fontSize: 10.5.sp,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
