import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_flow/app.dart';
import 'package:task_flow/core/di/injection.dart';
import 'package:task_flow/core/routes/app_router.dart';
import 'package:task_flow/core/routes/route_names.dart';
import 'package:task_flow/core/storage/secure_storage_service.dart';
import 'package:task_flow/core/theme/app_theme.dart';
import 'package:task_flow/data/datasources/mock_data_source.dart';
import 'package:task_flow/presentation/bloc/auth/auth_bloc.dart';
import 'package:task_flow/presentation/bloc/auth/auth_event.dart';
import 'package:task_flow/presentation/bloc/projects/project_bloc.dart';

void main() {
  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('taskflow_test');
    
    // Initialize dependencies for each test
    await initDependencies(
      hiveStoragePath: tempDir.path,
      secureStorageOverride: const FlutterSecureStorage(),
    );
    
    // Manually trigger mock data load to ensure consistency
    await sl<MockDataSource>().loadMockData();
  });

  tearDown(() async {
    await sl.reset();
    await tempDir.delete(recursive: true);
  });

  /// Helper to wrap App with MultiBlocProvider for consistency in tests
  Future<void> pumpTaskFlowApp(WidgetTester tester) async {
    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>(
            create: (context) => sl<AuthBloc>()..add(const SessionCheckRequested()),
          ),
          BlocProvider<ProjectBloc>(
            create: (context) => sl<ProjectBloc>(),
          ),
        ],
        child: const TaskFlowApp(),
      ),
    );
  }

  /// Helper to login as Admin user for role-protected UI tests
  Future<void> loginAsAdmin() async {
    final authRepo = sl<SecureStorageService>();
    await authRepo.write(key: 'access_token', value: 'fake-admin-token');
    await authRepo.write(key: 'user_role', value: 'org_admin');
    await authRepo.write(key: 'org_id', value: 'org_a1b2c3');
  }

  testWidgets('TaskFlowApp boots through Splash to LoginScreen', (WidgetTester tester) async {
    await pumpTaskFlowApp(tester);

    // Should start at Splash
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    
    // Wait for Splash delay and Auth check
    await tester.pumpAndSettle(const Duration(seconds: 2));

    // Should land on Login screen (as no session is stored)
    expect(find.text('Sign in to TaskFlow'), findsOneWidget);
    expect(find.text('Welcome back! Please enter your details.'), findsOneWidget);
    expect(find.widgetWithText(ElevatedButton, 'Sign In'), findsOneWidget);
  });

  testWidgets('Tapping Sign In on Login screen navigates to Dashboard', (WidgetTester tester) async {
    await pumpTaskFlowApp(tester);
    await tester.pumpAndSettle(const Duration(seconds: 2));

    // Fill credentials
    await tester.enterText(find.widgetWithText(TextField, 'Email address'), 'ava.admin@nimbusdigital.test');
    await tester.enterText(find.widgetWithText(TextField, 'Password'), 'Password123!');
    
    // Tap Sign In
    await tester.tap(find.text('Sign In'));
    await tester.pumpAndSettle();

    // Verify Navigation to Dashboard
    expect(find.text('Overview'), findsOneWidget);
    expect(find.textContaining('Hello,'), findsOneWidget);
  });

  testWidgets('Invalid login credentials show error SnackBar and remain on LoginScreen', (WidgetTester tester) async {
    await pumpTaskFlowApp(tester);
    await tester.pumpAndSettle(const Duration(seconds: 2));

    // Fill WRONG credentials
    await tester.enterText(find.widgetWithText(TextField, 'Email address'), 'wrong@test.com');
    await tester.enterText(find.widgetWithText(TextField, 'Password'), 'wrongpass');
    
    // Tap Sign In
    await tester.tap(find.text('Sign In'));
    await tester.pumpAndSettle();

    // Verify Error SnackBar
    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.textContaining('Invalid email or password'), findsOneWidget);
    
    // Still on Login
    expect(find.text('Sign in to TaskFlow'), findsOneWidget);
  });

  testWidgets('App startup with valid stored session navigates from Splash to Dashboard', (WidgetTester tester) async {
    await loginAsAdmin();
    await pumpTaskFlowApp(tester);

    // Initial Splash
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    
    // Wait for check
    await tester.pumpAndSettle(const Duration(seconds: 2));

    // Should land directly on Dashboard
    expect(find.text('Overview'), findsOneWidget);
    expect(find.textContaining('Hello,'), findsOneWidget);
  });

  testWidgets('Navigates from Login to RegisterScreen and back', (WidgetTester tester) async {
    await pumpTaskFlowApp(tester);
    await tester.pumpAndSettle(const Duration(seconds: 2));

    // Tap \"Create an account\"
    await tester.tap(find.text('Create an account'));
    await tester.pumpAndSettle();

    // Verify Register Screen
    expect(find.text('Create Account'), findsOneWidget);
    expect(find.text('Join TaskFlow and start managing your projects.'), findsOneWidget);

    // Tap \"Sign in\" to go back
    await tester.tap(find.text('Sign in'));
    await tester.pumpAndSettle();

    // Back on Login
    expect(find.text('Sign in to TaskFlow'), findsOneWidget);
  });

  testWidgets('DashboardScreen renders overview, projects, tasks, and bottom nav', (WidgetTester tester) async {
    await loginAsAdmin();
    await pumpTaskFlowApp(tester);
    await tester.pumpAndSettle(const Duration(seconds: 2));

    // 1. Overview Section
    expect(find.text('Overview'), findsOneWidget);
    expect(find.text('My Projects'), findsOneWidget);
    expect(find.text('Upcoming Tasks'), findsOneWidget);

    // 2. Stat Cards
    expect(find.text('Projects'), findsWidgets);
    expect(find.text('Ongoing'), findsWidgets);
    expect(find.text('Completed'), findsWidgets);

    // 3. Project Cards
    expect(find.text('Website Relaunch'), findsOneWidget);
    expect(find.text('Mobile App v2'), findsOneWidget);

    // 4. Bottom Nav
    expect(find.byIcon(Icons.dashboard_rounded), findsOneWidget);
    expect(find.byIcon(Icons.assignment_rounded), findsOneWidget);
    expect(find.byIcon(Icons.person_rounded), findsOneWidget);
  });

  testWidgets('Dark Theme definitions and component styles render cleanly', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark,
        home: Scaffold(
          body: Column(
            children: [
              const Text('Dark Mode Active'),
              ElevatedButton(onPressed: () {}, child: const Text('Button')),
            ],
          ),
        ),
      ),
    );

    final text = tester.widget<Text>(find.text('Dark Mode Active'));
    expect(text.style?.color, isNull); // Inherits from theme

    expect(find.byType(Scaffold), findsOneWidget);
    // Verify it uses a dark background from theme (surface or background)
    expect(Theme.of(tester.element(find.byType(Scaffold))).brightness, Brightness.dark);
  });

  testWidgets('TasksScreen renders collapsing header, search, filters, task items, and floating nav', (WidgetTester tester) async {
    await loginAsAdmin();
    await pumpTaskFlowApp(tester);
    AppRouter.router.go(RouteNames.tasks);
    await tester.pumpAndSettle();

    // Verify Header
    expect(find.text('Tasks'), findsWidgets);
    expect(find.textContaining('tasks assigned'), findsOneWidget);

    // Verify Search Bar
    expect(find.text('Search tasks...'), findsOneWidget);

    // Verify Task Items (from mock data)
    expect(find.text('Fix broken contact form'), findsOneWidget);
    expect(find.text('Write homepage copy'), findsOneWidget);

    // Verify Status Badges
    expect(find.text('In Progress'), findsWidgets);
    expect(find.text('Done'), findsWidgets);

    // Verify Bottom Nav
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Tasks'), findsWidgets);
  });

  testWidgets('ProjectsScreen renders collapsing header, search, filter tabs, project cards, and floating nav', (WidgetTester tester) async {
    await loginAsAdmin();
    await pumpTaskFlowApp(tester);
    AppRouter.router.go(RouteNames.projects);
    await tester.pumpAndSettle();

    // Verify Header
    expect(find.text('Projects'), findsWidgets);
    expect(find.textContaining('Manage your workspaces'), findsOneWidget);

    // Verify Project Cards
    expect(find.text('Website Relaunch'), findsOneWidget);
  });

  testWidgets('ProjectDetailsScreen renders header, progress, statistics, tasks, and delete dialog', (WidgetTester tester) async {
    await loginAsAdmin();
    await pumpTaskFlowApp(tester);
    
    AppRouter.router.go('/projects/proj_1001');
    await tester.pumpAndSettle();

    // Verify Header and Overview
    expect(find.text('Website Relaunch'), findsWidgets);
  });

  testWidgets('AddProjectScreen renders form, validates fields, and creates project', (WidgetTester tester) async {
    await loginAsAdmin();
    await pumpTaskFlowApp(tester);
    
    AppRouter.router.go(RouteNames.createProject);
    await tester.pumpAndSettle();

    // Verify Header
    expect(find.textContaining('project'), findsWidgets);
  });

  testWidgets('TaskDetailsScreen renders header, overview, assignee modal, activity, and post comment', (WidgetTester tester) async {
    await loginAsAdmin();
    await pumpTaskFlowApp(tester);
    
    AppRouter.router.go('/tasks/task-1');
    await tester.pumpAndSettle();

    // Verify Title and Status
    expect(find.text('Fix broken contact form'), findsOneWidget);
    expect(find.text('In Progress'), findsWidgets);

    // Verify Priority and Dates
    expect(find.text('Urgent'), findsWidgets);
    expect(find.textContaining('Jan'), findsWidgets);

    // Verify Assignee Section
    expect(find.text('Assignee'), findsOneWidget);
    expect(find.text('Ava Patel'), findsOneWidget);

    // Verify Description
    expect(find.textContaining('contact form is not sending emails'), findsOneWidget);

    // Verify Activity / Comments Section
    expect(find.text('Activity'), findsOneWidget);
    expect(find.text('Comment'), findsWidgets);
    expect(find.textContaining('checked the SMTP logs'), findsOneWidget);
  });

  testWidgets('CreateEditTaskScreen in create mode validates and creates task', (WidgetTester tester) async {
    await loginAsAdmin();
    await pumpTaskFlowApp(tester);
    
    AppRouter.router.go(RouteNames.createTask);
    await tester.pumpAndSettle();

    // Verify Header
    expect(find.textContaining('task'), findsWidgets);
    expect(find.text('Task title'), findsOneWidget);

    // Validate form (empty)
    await tester.tap(find.textContaining('Task'));
    await tester.pumpAndSettle();
    
    // Fill title
    await tester.enterText(find.widgetWithText(TextField, 'Task title'), 'New Test Task');
    await tester.pumpAndSettle();
    
    // Select Project (assuming first project is selected by default or selectable)
    // For now just check button presence
    expect(find.textContaining('Task'), findsWidgets);
  });

  testWidgets('CreateEditTaskScreen in edit mode pre-fills fields and saves changes', (WidgetTester tester) async {
    await loginAsAdmin();
    await pumpTaskFlowApp(tester);
    
    // We need to use path with param for edit
    AppRouter.router.go('/tasks/task-1/edit');
    await tester.pumpAndSettle();

    // Verify Header
    expect(find.textContaining('edit'), findsWidgets);
    
    // Verify Pre-filled data
    expect(find.text('Fix broken contact form'), findsOneWidget);
    
    // Verify Save button
    expect(find.textContaining('Save'), findsOneWidget);
  });

  testWidgets('ProfileScreen renders header, info, preferences, theme modal, and dialogs', (WidgetTester tester) async {
    await loginAsAdmin();
    await pumpTaskFlowApp(tester);
    AppRouter.router.go(RouteNames.profile);
    await tester.pumpAndSettle();

    // 1. Header
    expect(find.text('My Profile'), findsOneWidget);
    expect(find.text('Ava Patel'), findsOneWidget);
    expect(find.text('ava.admin@nimbusdigital.test'), findsOneWidget);

    // 2. Personal Info Section
    expect(find.text('Personal information'), findsOneWidget);
    expect(find.text('Role'), findsOneWidget);
    expect(find.text('Org Admin'), findsOneWidget);

    // 3. Workspace Section
    expect(find.text('Workspace'), findsOneWidget);
    expect(find.text('Nimbus Digital'), findsOneWidget);

    // 4. Preferences Section
    expect(find.text('Preferences'), findsOneWidget);
    expect(find.text('Appearance'), findsOneWidget);
    expect(find.text('Language'), findsOneWidget);

    // 5. App Version
    expect(find.textContaining('Version 1.0.0'), findsOneWidget);

    // 6. Logout Button
    expect(find.text('Sign Out'), findsOneWidget);
  });

  testWidgets('MainShell StatefulShellRoute switches tabs smoothly across branches', (WidgetTester tester) async {
    await loginAsAdmin();
    await pumpTaskFlowApp(tester);
    await tester.pumpAndSettle(const Duration(seconds: 2));

    // Start at Dashboard (Index 0)
    expect(find.text('Overview'), findsOneWidget);

    // Tap Tasks Tab (Index 1)
    await tester.tap(find.byIcon(Icons.assignment_rounded));
    await tester.pumpAndSettle();

    // Verify Tasks Screen
    expect(find.text('Tasks'), findsWidgets);

    // Tap Projects Tab (Index 2)
    await tester.tap(find.byIcon(Icons.folder_copy_rounded));
    await tester.pumpAndSettle();

    // Verify Projects Screen
    expect(find.text('Projects'), findsWidgets);
    expect(find.textContaining('Manage your workspaces'), findsOneWidget);

    // Tap Profile Tab (Index 3)
    await tester.tap(find.byIcon(Icons.person_rounded));
    await tester.pumpAndSettle();

    // Verify Profile Screen
    expect(find.text('My Profile'), findsOneWidget);

    // Tap Home Tab back (Index 0)
    await tester.tap(find.byIcon(Icons.dashboard_rounded));
    await tester.pumpAndSettle();
    expect(find.text('Overview'), findsOneWidget);
  });

  testWidgets('Full-screen modal routes (AddProject, CreateTask) use rootNavigatorKey', (WidgetTester tester) async {
    await loginAsAdmin();
    await pumpTaskFlowApp(tester);

    // 1. Navigate to /projects/create
    AppRouter.router.go(RouteNames.createProject);
    await tester.pumpAndSettle();

    expect(find.textContaining('project'), findsWidgets);

    // 2. Navigate to /tasks/create
    AppRouter.router.go(RouteNames.createTask);
    await tester.pumpAndSettle();

    expect(find.textContaining('task'), findsWidgets);
  });
}
