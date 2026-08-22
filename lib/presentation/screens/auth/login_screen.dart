import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/routes/route_names.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/auth/auth_event.dart';
import '../../bloc/auth/auth_state.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/app_logo.dart';
import '../../widgets/common/app_text_form_field.dart';

/// Authentication Login screen for TaskFlow connected to AuthBloc with SnackBar feedback
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    FocusScope.of(context).unfocus();

    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    context.read<AuthBloc>().add(
          LoginRequested(
            email: _emailController.text.trim(),
            password: _passwordController.text,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state.status == AuthStatus.success) {
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Login successful',
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              backgroundColor: colorScheme.primary,
              behavior: SnackBarBehavior.floating,
            ),
          );
          context.go(RouteNames.dashboard);
        } else if (state.status == AuthStatus.error && state.errorMessage != null) {
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                state.errorMessage!,
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onError,
                  fontWeight: FontWeight.w500,
                ),
              ),
              backgroundColor: colorScheme.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      builder: (context, state) {
        final isLoading = state.status == AuthStatus.loading;

        return Scaffold(
          body: SafeArea(
            child: GestureDetector(
              onTap: () => FocusScope.of(context).unfocus(),
              behavior: HitTestBehavior.opaque,
              child: Center(
                child: SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  padding: EdgeInsets.symmetric(
                    horizontal: AppDimensions.space24.w,
                    vertical: AppDimensions.space16.h,
                  ),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 440),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SizedBox(height: AppDimensions.space16.h),

                        // Brand Header
                        Center(
                          child: Column(
                            children: [
                              const AppLogo(size: 60.0),
                              SizedBox(height: AppDimensions.space16.h),
                              Text(
                                'Welcome back',
                                style: textTheme.headlineMedium?.copyWith(
                                  fontSize: 22.sp,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: -0.3,
                                ),
                              ),
                              SizedBox(height: AppDimensions.space6.h),
                              Text(
                                'Sign in to your workspace to manage tasks',
                                textAlign: TextAlign.center,
                                style: textTheme.bodyMedium?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                  fontSize: 13.sp,
                                ),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: AppDimensions.space28.h),

                        // Login Form Card
                        Container(
                          padding: EdgeInsets.all(AppDimensions.space20.r),
                          decoration: BoxDecoration(
                            color: colorScheme.surface,
                            borderRadius: BorderRadius.circular(AppDimensions.radiusLG.r),
                            border: Border.all(
                              color: colorScheme.outline,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: colorScheme.shadow.withValues(alpha: 0.04),
                                blurRadius: 16.r,
                                offset: Offset(0, 4.h),
                              ),
                            ],
                          ),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // Email Field
                                AppTextFormField(
                                  label: 'Email address',
                                  hintText: 'name@organization.com',
                                  controller: _emailController,
                                  keyboardType: TextInputType.emailAddress,
                                  textInputAction: TextInputAction.next,
                                  enabled: !isLoading,
                                  prefixIcon: Icon(
                                    Icons.mail_outline_rounded,
                                    size: AppDimensions.iconMD.r,
                                  ),
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return 'Email is required';
                                    }
                                    final emailRegex = RegExp(
                                      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
                                    );
                                    if (!emailRegex.hasMatch(value.trim())) {
                                      return 'Please enter a valid email';
                                    }
                                    return null;
                                  },
                                ),

                                SizedBox(height: AppDimensions.space16.h),

                                // Password Field
                                AppTextFormField(
                                  label: 'Password',
                                  hintText: '••••••••',
                                  controller: _passwordController,
                                  obscureText: true,
                                  textInputAction: TextInputAction.done,
                                  enabled: !isLoading,
                                  prefixIcon: Icon(
                                    Icons.lock_outline_rounded,
                                    size: AppDimensions.iconMD.r,
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Password is required';
                                    }
                                    if (value.length < 6) {
                                      return 'Password must be at least 6 characters';
                                    }
                                    return null;
                                  },
                                  onFieldSubmitted: (_) => isLoading ? null : _handleLogin(),
                                ),

                                SizedBox(height: AppDimensions.space8.h),

                                // Forgot Password Action (UI-only)
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: TextButton(
                                    onPressed: () {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'Password reset functionality will be enabled in future phase.',
                                            style: textTheme.bodyMedium?.copyWith(
                                              color: colorScheme.onPrimary,
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                    style: TextButton.styleFrom(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: AppDimensions.space4.w,
                                        vertical: AppDimensions.space4.h,
                                      ),
                                      minimumSize: Size.zero,
                                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                    ),
                                    child: Text(
                                      'Forgot password?',
                                      style: textTheme.labelMedium?.copyWith(
                                        color: colorScheme.primary,
                                        fontSize: 12.sp,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),

                                SizedBox(height: AppDimensions.space20.h),

                                // Sign In Button
                                AppButton(
                                  text: 'Sign In',
                                  isLoading: isLoading,
                                  onPressed: isLoading ? null : _handleLogin,
                                ),
                              ],
                            ),
                          ),
                        ),

                        SizedBox(height: AppDimensions.space24.h),

                        // Footer / Register Navigation
                        Wrap(
                          alignment: WrapAlignment.center,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Text(
                              "Don't have an account? ",
                              style: textTheme.bodyMedium?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                                fontSize: 13.sp,
                              ),
                            ),
                            GestureDetector(
                              onTap: () => context.push(RouteNames.register),
                              child: Padding(
                                padding: EdgeInsets.symmetric(vertical: 4.h),
                                child: Text(
                                  'Create account',
                                  style: textTheme.labelMedium?.copyWith(
                                    color: colorScheme.primary,
                                    fontSize: 13.sp,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: AppDimensions.space16.h),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
