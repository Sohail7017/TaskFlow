import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/routes/route_names.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/auth/auth_state.dart';
import '../../widgets/common/app_logo.dart';

/// Premium animated splash screen for TaskFlow with robust auth state resolution
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _scaleAnimation;
  Timer? _minDisplayTimer;
  bool _minDisplayElapsed = false;
  bool _hasNavigated = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.7, curve: Curves.easeOut),
    );

    _scaleAnimation = Tween<double>(begin: 0.88, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.7, curve: Curves.easeOutCubic),
      ),
    );

    _animationController.forward();

    // Minimum display duration to allow brand entrance animation to complete smoothly
    _minDisplayTimer = Timer(const Duration(milliseconds: 1500), () {
      if (mounted) {
        _minDisplayElapsed = true;
        _checkAndNavigate(context.read<AuthBloc>().state);
      }
    });
  }

  void _checkAndNavigate(AuthState state) {
    if (_hasNavigated || !mounted || !_minDisplayElapsed) return;

    if (state.status == AuthStatus.success) {
      _hasNavigated = true;
      context.go(RouteNames.dashboard);
    } else if (state.status != AuthStatus.loading && state.status != AuthStatus.initial) {
      _hasNavigated = true;
      context.go(RouteNames.login);
    }
  }

  @override
  void dispose() {
    _minDisplayTimer?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        _checkAndNavigate(state);
      },
      child: Scaffold(
        body: SafeArea(
          child: Center(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: AppDimensions.space32.w),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Spacer(flex: 3),
                      // Brand Logo
                      const AppLogo(size: 80.0),
                      SizedBox(height: AppDimensions.space24.h),

                      // App Name
                      Text(
                        'TaskFlow',
                        style: textTheme.displayMedium?.copyWith(
                          fontSize: 32.sp,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.5,
                        ),
                      ),
                      SizedBox(height: AppDimensions.space8.h),

                      // Tagline
                      Text(
                        'Organize. Focus. Deliver.',
                        textAlign: TextAlign.center,
                        style: textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w400,
                          letterSpacing: 0.3,
                        ),
                      ),
                      const Spacer(flex: 2),

                      // Subtle indicator
                      SizedBox(
                        width: 24.r,
                        height: 24.r,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            colorScheme.primary,
                          ),
                        ),
                      ),
                      SizedBox(height: AppDimensions.space32.h),
                      const Spacer(flex: 1),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
