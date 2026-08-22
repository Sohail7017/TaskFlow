import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'core/constants/app_constants.dart';
import 'core/routes/app_router.dart';
import 'core/theme/app_theme.dart';

/// Root application widget configuring ScreenUtil, Themes, and GoRouter
class TaskFlowApp extends StatelessWidget {
  const TaskFlowApp({super.key});

  /// Standard base design size for responsive scaling (width: 375, height: 812)
  static const Size _designSize = Size(375, 812);

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: _designSize,
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp.router(
          title: AppConstants.appName,
          debugShowCheckedModeBanner: false,
          routerConfig: AppRouter.router,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: ThemeMode.light,
        );
      },
    );
  }
}
