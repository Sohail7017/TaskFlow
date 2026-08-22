import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/routes/route_names.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/app_logo.dart';
import '../../widgets/common/app_text_form_field.dart';

/// Premium registration screen for TaskFlow (UI-only phase)
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleRegister() {
    FocusScope.of(context).unfocus();

    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    // UI-only loading demonstration
    setState(() {
      _isLoading = true;
    });

    Future.delayed(const Duration(milliseconds: 1200), () {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });

      final theme = Theme.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Account registration validation successful!',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onPrimary,
            ),
          ),
          backgroundColor: theme.colorScheme.primary,
          behavior: SnackBarBehavior.floating,
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

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
                    SizedBox(height: AppDimensions.space12.h),

                    // Brand Header
                    Center(
                      child: Column(
                        children: [
                          const AppLogo(size: 56.0),
                          SizedBox(height: AppDimensions.space16.h),
                          Text(
                            'Create an account',
                            style: textTheme.headlineMedium?.copyWith(
                              fontSize: 22.sp,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.3,
                            ),
                          ),
                          SizedBox(height: AppDimensions.space6.h),
                          Text(
                            'Start organizing and tracking your tasks today',
                            textAlign: TextAlign.center,
                            style: textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                              fontSize: 13.sp,
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: AppDimensions.space24.h),

                    // Registration Form Card
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
                            // Full Name Field
                            AppTextFormField(
                              label: 'Full Name',
                              hintText: 'Jane Doe',
                              controller: _nameController,
                              textCapitalization: TextCapitalization.words,
                              textInputAction: TextInputAction.next,
                              prefixIcon: Icon(
                                Icons.person_outline_rounded,
                                size: AppDimensions.iconMD.r,
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Full name is required';
                                }
                                if (value.trim().length < 2) {
                                  return 'Name must be at least 2 characters';
                                }
                                return null;
                              },
                            ),

                            SizedBox(height: AppDimensions.space16.h),

                            // Email Field
                            AppTextFormField(
                              label: 'Email address',
                              hintText: 'jane@organization.com',
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
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
                              hintText: 'At least 6 characters',
                              controller: _passwordController,
                              obscureText: true,
                              textInputAction: TextInputAction.next,
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
                            ),

                            SizedBox(height: AppDimensions.space16.h),

                            // Confirm Password Field
                            AppTextFormField(
                              label: 'Confirm Password',
                              hintText: 'Re-enter your password',
                              controller: _confirmPasswordController,
                              obscureText: true,
                              textInputAction: TextInputAction.done,
                              prefixIcon: Icon(
                                Icons.lock_clock_outlined,
                                size: AppDimensions.iconMD.r,
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please confirm your password';
                                }
                                if (value != _passwordController.text) {
                                  return 'Passwords do not match';
                                }
                                return null;
                              },
                              onFieldSubmitted: (_) => _handleRegister(),
                            ),

                            SizedBox(height: AppDimensions.space24.h),

                            // Create Account Button
                            AppButton(
                              text: 'Create Account',
                              isLoading: _isLoading,
                              onPressed: _handleRegister,
                            ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: AppDimensions.space24.h),

                    // Footer / Login Navigation
                    Wrap(
                      alignment: WrapAlignment.center,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          'Already have an account? ',
                          style: textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            fontSize: 13.sp,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => context.go(RouteNames.login),
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 4.h),
                            child: Text(
                              'Sign in',
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
  }
}
