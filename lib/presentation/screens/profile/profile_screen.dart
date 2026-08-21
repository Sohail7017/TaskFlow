import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/routes/route_names.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/user_avatar.dart';

/// Supported theme modes for the presentation-level theme selector
enum AppThemeMode {
  system('System default', Icons.brightness_auto_rounded),
  light('Light', Icons.light_mode_rounded),
  dark('Dark', Icons.dark_mode_rounded);

  const AppThemeMode(this.label, this.icon);
  final String label;
  final IconData icon;
}

/// Premium, production-quality Profile and Settings Screen for TaskFlow
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Local presentation state for settings demonstration
  AppThemeMode _selectedTheme = AppThemeMode.system;
  bool _notificationsEnabled = true;
  bool _emailNotificationsEnabled = true;

  // Static user profile details
  final String _name = 'Ava Patel';
  final String _email = 'ava.patel@example.com';
  final String _role = 'Product Designer';
  final String _organization = 'Nimbus Digital';

  void _showThemeSelectorModal(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppDimensions.radiusXL.r),
          ),
          border: Border(
            top: BorderSide(
              color: Theme.of(context).colorScheme.outline.withValues(
                    alpha: Theme.of(context).brightness == Brightness.dark ? 0.35 : 0.6,
                  ),
            ),
          ),
        ),
        padding: EdgeInsets.only(
          left: AppDimensions.space20.w,
          right: AppDimensions.space20.w,
          top: AppDimensions.space12.h,
          bottom: AppDimensions.space24.h + MediaQuery.of(context).padding.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 36.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusFull.r),
                ),
              ),
            ),
            SizedBox(height: AppDimensions.space14.h),
            Text(
              'Appearance',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                  ),
            ),
            SizedBox(height: AppDimensions.space12.h),
            ...AppThemeMode.values.map((mode) {
              final isSelected = _selectedTheme == mode;

              return Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    setState(() => _selectedTheme = mode);
                    Navigator.of(context).pop();
                  },
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMD.r),
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 8.w),
                    child: Row(
                      children: [
                        Icon(
                          mode.icon,
                          size: 18.r,
                          color: isSelected
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Text(
                            mode.label,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  fontSize: 14.sp,
                                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                  color: isSelected
                                      ? Theme.of(context).colorScheme.primary
                                      : Theme.of(context).colorScheme.onSurface,
                                ),
                          ),
                        ),
                        Icon(
                          isSelected
                              ? Icons.radio_button_checked_rounded
                              : Icons.radio_button_unchecked_rounded,
                          size: 20.r,
                          color: isSelected
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.outline.withValues(alpha: 0.6),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    final theme = Theme.of(context);

    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusXL.r),
        ),
        title: Text(
          'Log out?',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
            fontSize: 18.sp,
          ),
        ),
        content: Text(
          'Are you sure you want to log out of your TaskFlow account?',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            fontSize: 13.5.sp,
            height: 1.4,
          ),
        ),
        actionsPadding: EdgeInsets.only(
          left: AppDimensions.space20.w,
          right: AppDimensions.space20.w,
          bottom: AppDimensions.space16.h,
        ),
        actions: [
          AppButton(
            text: 'Cancel',
            type: AppButtonType.outlined,
            isFullWidth: false,
            height: 38.h,
            onPressed: () => Navigator.of(context).pop(),
          ),
          SizedBox(width: 8.w),
          AppButton(
            text: 'Log out',
            isDestructive: true,
            isFullWidth: false,
            height: 38.h,
            onPressed: () {
              Navigator.of(context).pop();
              context.go(RouteNames.login);
            },
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    final theme = Theme.of(context);

    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusXL.r),
        ),
        title: Text(
          'Delete account?',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
            fontSize: 18.sp,
          ),
        ),
        content: Text(
          'This action permanently removes your account and all associated workspace data. This action cannot be undone.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            fontSize: 13.5.sp,
            height: 1.4,
          ),
        ),
        actionsPadding: EdgeInsets.only(
          left: AppDimensions.space20.w,
          right: AppDimensions.space20.w,
          bottom: AppDimensions.space16.h,
        ),
        actions: [
          AppButton(
            text: 'Cancel',
            type: AppButtonType.outlined,
            isFullWidth: false,
            height: 38.h,
            onPressed: () => Navigator.of(context).pop(),
          ),
          SizedBox(width: 8.w),
          AppButton(
            text: 'Delete Account',
            isDestructive: true,
            isFullWidth: false,
            height: 38.h,
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Account deletion is UI-only in this demo.'),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isTablet = constraints.maxWidth >= 720;
          final horizontalPadding = (isTablet ? AppDimensions.space32 : AppDimensions.space20).w;

          return CustomScrollView(
            cacheExtent: 1500.0,
            physics: const AlwaysScrollableScrollPhysics(
              parent: ClampingScrollPhysics(),
            ),
            slivers: [
              // 1. Collapsing Profile Header
              _buildCollapsingHeader(context, isTablet, horizontalPadding),

              // 2. Main Content Sections
              SliverToBoxAdapter(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 720),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: horizontalPadding,
                        vertical: AppDimensions.space16.h,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Personal Information Section
                          _buildSectionTitle(context, 'Personal information'),
                          SizedBox(height: AppDimensions.space10.h),
                          _buildPersonalInfoCard(context),
                          SizedBox(height: AppDimensions.space24.h),

                          // Preferences Section
                          _buildSectionTitle(context, 'Preferences'),
                          SizedBox(height: AppDimensions.space10.h),
                          _buildPreferencesCard(context),
                          SizedBox(height: AppDimensions.space24.h),

                          // Organization Section
                          _buildSectionTitle(context, 'Organization'),
                          SizedBox(height: AppDimensions.space10.h),
                          _buildOrganizationCard(context),
                          SizedBox(height: AppDimensions.space24.h),

                          // Account & Security Section
                          _buildSectionTitle(context, 'Account & Security'),
                          SizedBox(height: AppDimensions.space10.h),
                          _buildAccountCard(context),
                          SizedBox(height: AppDimensions.space24.h),

                          // Danger Zone Section
                          _buildSectionTitle(context, 'Danger zone'),
                          SizedBox(height: AppDimensions.space10.h),
                          _buildDangerZoneCard(context),
                          SizedBox(height: AppDimensions.space16.h),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // 3. Scroll clearance for Floating Bottom Nav
              SliverPadding(
                padding: EdgeInsets.only(bottom: 108.h),
              ),
            ],
          );
        },
      ),
    );
  }

  // ==========================================================================
  // 1. Collapsing Profile Header
  // ==========================================================================
  Widget _buildCollapsingHeader(BuildContext context, bool isTablet, double horizontalPadding) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final expandedHeight = (isTablet ? 210.0 : 190.0).h.clamp(160.0, 230.0);
    final toolbarHeight = 64.h.clamp(56.0, 72.0);

    return SliverAppBar(
      pinned: true,
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: theme.scaffoldBackgroundColor,
      expandedHeight: expandedHeight,
      toolbarHeight: toolbarHeight,
      flexibleSpace: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final topSafeArea = MediaQuery.of(context).padding.top;
          final minHeight = toolbarHeight + topSafeArea;
          final maxHeight = expandedHeight + topSafeArea;
          final currentHeight = constraints.biggest.height;
          final delta = maxHeight - minHeight;
          final progress = delta > 0 ? ((currentHeight - minHeight) / delta).clamp(0.0, 1.0) : 0.0;

          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  theme.colorScheme.primary.withValues(alpha: isDark ? 0.14 : 0.06),
                  theme.scaffoldBackgroundColor,
                ],
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // --- Collapsed Title (Fades in when scrolling up) ---
                  if (progress < 0.5)
                    Positioned(
                      left: horizontalPadding,
                      top: 18.h,
                      child: Opacity(
                        opacity: ((1.0 - progress * 2.0)).clamp(0.0, 1.0),
                        child: Text(
                          'Profile & Settings',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontSize: 17.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),

                  // --- Expanded Header Content (Fades out when scrolling up) ---
                  if (progress > 0.05)
                    Positioned(
                      left: horizontalPadding,
                      right: horizontalPadding,
                      bottom: 12.h,
                      child: Opacity(
                        opacity: progress.clamp(0.0, 1.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Avatar with Edit Badge
                            Stack(
                              clipBehavior: Clip.none,
                              children: [
                                UserAvatar(
                                  name: _name,
                                  initials: 'AP',
                                  size: 64.0,
                                ),
                                Positioned(
                                  right: -2,
                                  bottom: -2,
                                  child: Container(
                                    width: 22.r,
                                    height: 22.r,
                                    decoration: BoxDecoration(
                                      color: theme.colorScheme.primary,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: theme.scaffoldBackgroundColor,
                                        width: 2,
                                      ),
                                    ),
                                    alignment: Alignment.center,
                                    child: Icon(
                                      Icons.edit_rounded,
                                      size: 11.r,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(width: 14.w),

                            // User Info
                            Expanded(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: theme.textTheme.headlineSmall?.copyWith(
                                      fontSize: 18.5.sp,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: -0.3,
                                    ),
                                  ),
                                  SizedBox(height: 2.h),
                                  Text(
                                    _role,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: theme.textTheme.labelMedium?.copyWith(
                                      color: theme.colorScheme.primary,
                                      fontSize: 12.5.sp,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  SizedBox(height: 1.h),
                                  Text(
                                    _email,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.colorScheme.onSurfaceVariant,
                                      fontSize: 11.5.sp,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    final theme = Theme.of(context);
    return Text(
      title,
      style: theme.textTheme.titleSmall?.copyWith(
        fontWeight: FontWeight.w700,
        fontSize: 13.5.sp,
      ),
    );
  }

  // ==========================================================================
  // Personal Information Card
  // ==========================================================================
  Widget _buildPersonalInfoCard(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLG.r),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: isDark ? 0.35 : 0.6),
          width: 1.0,
        ),
      ),
      padding: EdgeInsets.all(AppDimensions.space16.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildInfoRow(context, label: 'Name', value: _name, icon: Icons.person_outline_rounded),
          Divider(height: 20.h, color: theme.colorScheme.outline.withValues(alpha: 0.2)),
          _buildInfoRow(context, label: 'Email', value: _email, icon: Icons.mail_outline_rounded),
          Divider(height: 20.h, color: theme.colorScheme.outline.withValues(alpha: 0.2)),
          _buildInfoRow(context, label: 'Role', value: _role, icon: Icons.badge_outlined),
          Divider(height: 20.h, color: theme.colorScheme.outline.withValues(alpha: 0.2)),
          _buildInfoRow(context, label: 'Organization', value: _organization, icon: Icons.business_outlined),
          SizedBox(height: AppDimensions.space14.h),
          AppButton(
            text: 'Edit Profile',
            type: AppButtonType.outlined,
            prefixIcon: Icons.edit_outlined,
            height: 42.h,
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Edit Profile form is UI-only in this demo.'),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context, {
    required String label,
    required String value,
    required IconData icon,
  }) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Icon(icon, size: 18.r, color: theme.colorScheme.onSurfaceVariant),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                value,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontSize: 13.5.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ==========================================================================
  // Preferences Card
  // ==========================================================================
  Widget _buildPreferencesCard(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLG.r),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: isDark ? 0.35 : 0.6),
          width: 1.0,
        ),
      ),
      child: Column(
        children: [
          // Appearance Setting Tile
          _SettingsTile(
            icon: Icons.palette_outlined,
            title: 'Appearance',
            subtitle: 'Choose your application theme',
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _selectedTheme.label,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(width: 4.w),
                Icon(
                  Icons.chevron_right_rounded,
                  size: 18.r,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ],
            ),
            onTap: () => _showThemeSelectorModal(context),
          ),
          Divider(height: 1, color: theme.colorScheme.outline.withValues(alpha: 0.2)),

          // Notifications Switch Tile
          _SettingsTile(
            icon: Icons.notifications_outlined,
            title: 'Notifications',
            subtitle: 'Receive task and project alerts',
            trailing: Switch(
              value: _notificationsEnabled,
              onChanged: (val) => setState(() => _notificationsEnabled = val),
            ),
          ),
          Divider(height: 1, color: theme.colorScheme.outline.withValues(alpha: 0.2)),

          // Email Notifications Switch Tile
          _SettingsTile(
            icon: Icons.alternate_email_rounded,
            title: 'Email notifications',
            subtitle: 'Receive daily summary and digest',
            trailing: Switch(
              value: _emailNotificationsEnabled,
              onChanged: (val) => setState(() => _emailNotificationsEnabled = val),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // Organization Card
  // ==========================================================================
  Widget _buildOrganizationCard(BuildContext context) {
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
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 42.r,
            height: 42.r,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: isDark ? 0.2 : 0.1),
              borderRadius: BorderRadius.circular(AppDimensions.radiusMD.r),
            ),
            alignment: Alignment.center,
            child: Text(
              'ND',
              style: theme.textTheme.titleSmall?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _organization,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontSize: 14.5.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  '3 active projects • 15 tasks',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontSize: 12.sp,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right_rounded,
            size: 20.r,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // Account & Security Card
  // ==========================================================================
  Widget _buildAccountCard(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLG.r),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: isDark ? 0.35 : 0.6),
          width: 1.0,
        ),
      ),
      child: Column(
        children: [
          _SettingsTile(
            icon: Icons.lock_outline_rounded,
            title: 'Change password',
            subtitle: 'Update your account password',
            trailing: Icon(
              Icons.chevron_right_rounded,
              size: 18.r,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Password change is UI-only in this demo.')),
              );
            },
          ),
          Divider(height: 1, color: theme.colorScheme.outline.withValues(alpha: 0.2)),
          _SettingsTile(
            icon: Icons.privacy_tip_outlined,
            title: 'Privacy',
            subtitle: 'Manage your privacy settings',
            trailing: Icon(
              Icons.chevron_right_rounded,
              size: 18.r,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Privacy settings are UI-only in this demo.')),
              );
            },
          ),
          Divider(height: 1, color: theme.colorScheme.outline.withValues(alpha: 0.2)),
          _SettingsTile(
            icon: Icons.help_outline_rounded,
            title: 'Help & Support',
            subtitle: 'Get assistance with TaskFlow',
            trailing: Icon(
              Icons.chevron_right_rounded,
              size: 18.r,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Help & Support center is UI-only in this demo.')),
              );
            },
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // Danger Zone Card
  // ==========================================================================
  Widget _buildDangerZoneCard(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLG.r),
        border: Border.all(
          color: theme.colorScheme.error.withValues(alpha: isDark ? 0.35 : 0.4),
          width: 1.0,
        ),
      ),
      child: Column(
        children: [
          // Log Out Tile
          _SettingsTile(
            icon: Icons.logout_rounded,
            iconColor: theme.colorScheme.error,
            title: 'Log out',
            subtitle: 'Sign out of your TaskFlow session',
            trailing: Icon(
              Icons.chevron_right_rounded,
              size: 18.r,
              color: theme.colorScheme.error,
            ),
            onTap: () => _showLogoutDialog(context),
          ),
          Divider(height: 1, color: theme.colorScheme.error.withValues(alpha: 0.2)),

          // Delete Account Tile
          _SettingsTile(
            icon: Icons.delete_forever_outlined,
            iconColor: theme.colorScheme.error,
            title: 'Delete account',
            subtitle: 'Permanently remove your account and data',
            trailing: Icon(
              Icons.chevron_right_rounded,
              size: 18.r,
              color: theme.colorScheme.error,
            ),
            onTap: () => _showDeleteAccountDialog(context),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// Private Settings Tile Component
// ============================================================================
class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.iconColor,
    this.trailing,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final Color? iconColor;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: AppDimensions.space16.w,
            vertical: 12.h,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 20.r,
                color: iconColor ?? theme.colorScheme.onSurfaceVariant,
              ),
              SizedBox(width: 14.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontSize: 13.5.sp,
                        fontWeight: FontWeight.w600,
                        color: iconColor ?? theme.colorScheme.onSurface,
                      ),
                    ),
                    if (subtitle != null) ...[
                      SizedBox(height: 2.h),
                      Text(
                        subtitle!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontSize: 11.5.sp,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (trailing != null) ...[
                SizedBox(width: 8.w),
                trailing!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}
