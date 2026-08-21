import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:task_flow/core/theme/app_theme.dart';
import 'package:task_flow/presentation/widgets/common/app_button.dart';

Widget _buildTestApp({
  required Widget child,
  ThemeData? theme,
}) {
  return ScreenUtilInit(
    designSize: const Size(375, 812),
    minTextAdapt: true,
    splitScreenMode: true,
    builder: (context, _) => MaterialApp(
      theme: theme ?? AppTheme.light,
      home: Scaffold(
        body: Center(child: child),
      ),
    ),
  );
}

void main() {
  testWidgets('AppButton renders filled text button and handles tap', (WidgetTester tester) async {
    bool tapped = false;

    await tester.pumpWidget(
      _buildTestApp(
        child: AppButton(
          text: 'Create Project',
          onPressed: () => tapped = true,
        ),
      ),
    );

    expect(find.text('Create Project'), findsOneWidget);
    await tester.tap(find.text('Create Project'));
    await tester.pumpAndSettle();

    expect(tapped, isTrue);
  });

  testWidgets('AppButton renders outlined button and handles tap', (WidgetTester tester) async {
    bool tapped = false;

    await tester.pumpWidget(
      _buildTestApp(
        child: AppButton(
          text: 'Cancel',
          type: AppButtonType.outlined,
          onPressed: () => tapped = true,
        ),
      ),
    );

    expect(find.text('Cancel'), findsOneWidget);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(tapped, isTrue);
  });

  testWidgets('AppButton renders leading and trailing icons', (WidgetTester tester) async {
    await tester.pumpWidget(
      _buildTestApp(
        child: AppButton(
          text: 'Continue',
          icon: Icons.add,
          trailingIcon: Icons.arrow_forward,
          onPressed: () {},
        ),
      ),
    );

    expect(find.text('Continue'), findsOneWidget);
    expect(find.byIcon(Icons.add), findsOneWidget);
    expect(find.byIcon(Icons.arrow_forward), findsOneWidget);
  });

  testWidgets('AppButton renders loading indicator and ignores taps when isLoading is true', (WidgetTester tester) async {
    bool tapped = false;

    await tester.pumpWidget(
      _buildTestApp(
        child: AppButton(
          text: 'Submit',
          isLoading: true,
          onPressed: () => tapped = true,
        ),
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    await tester.tap(find.byType(AppButton));
    await tester.pump(const Duration(milliseconds: 100));

    expect(tapped, isFalse);
  });

  testWidgets('AppButton ignores taps when enabled is false or onPressed is null', (WidgetTester tester) async {
    bool tapped = false;

    await tester.pumpWidget(
      _buildTestApp(
        child: AppButton(
          text: 'Disabled Action',
          enabled: false,
          onPressed: () => tapped = true,
        ),
      ),
    );

    expect(find.text('Disabled Action'), findsOneWidget);
    await tester.tap(find.text('Disabled Action'));
    await tester.pumpAndSettle();

    expect(tapped, isFalse);
  });

  testWidgets('AppButton supports pill shape and custom border radius', (WidgetTester tester) async {
    await tester.pumpWidget(
      _buildTestApp(
        child: Column(
          children: [
            AppButton(
              text: 'Pill Button',
              shape: AppButtonShape.pill,
              onPressed: () {},
            ),
            AppButton(
              text: 'Custom Radius',
              borderRadius: 24,
              onPressed: () {},
            ),
          ],
        ),
      ),
    );

    expect(find.text('Pill Button'), findsOneWidget);
    expect(find.text('Custom Radius'), findsOneWidget);
  });

  testWidgets('AppButton supports destructive styling in dark theme', (WidgetTester tester) async {
    await tester.pumpWidget(
      _buildTestApp(
        theme: AppTheme.dark,
        child: AppButton(
          text: 'Delete',
          isDestructive: true,
          onPressed: () {},
        ),
      ),
    );

    expect(find.text('Delete'), findsOneWidget);
  });

  testWidgets('AppButton supports icon-only mode with tooltip semantic label', (WidgetTester tester) async {
    await tester.pumpWidget(
      _buildTestApp(
        child: AppButton(
          icon: Icons.add,
          isIconOnly: true,
          semanticLabel: 'Add Item',
          onPressed: () {},
        ),
      ),
    );

    expect(find.byIcon(Icons.add), findsOneWidget);
    expect(find.byType(Tooltip), findsOneWidget);
  });
}
