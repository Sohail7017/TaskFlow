import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:task_flow/app.dart';
import 'package:task_flow/core/di/injection.dart';
import 'package:task_flow/core/routes/app_router.dart';
import 'package:task_flow/core/routes/route_names.dart';
import 'package:task_flow/core/theme/app_theme.dart';

void main() {
  late Directory tempDir;

  setUp(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    tempDir = await Directory.systemTemp.createTemp('task_flow_test_');
    await sl.reset();
    await initDependencies(hiveStoragePath: tempDir.path);
    AppRouter.router.go(RouteNames.splash);
  });

  tearDown(() async {
    if (tempDir.existsSync()) {
      await tempDir.delete(recursive: true);
    }
  });

  testWidgets('TaskFlowApp boots through Splash to LoginScreen', (WidgetTester tester) async {
    await tester.pumpWidget(const TaskFlowApp());
    // Splash screen renders
    expect(find.text('TaskFlow'), findsWidgets);
    expect(find.text('Organize. Focus. Deliver.'), findsOneWidget);

    // Wait for timer and transition to LoginScreen
    await tester.pumpAndSettle(const Duration(seconds: 3));

    expect(find.text('Welcome back'), findsOneWidget);
    expect(find.text('Sign In'), findsOneWidget);
    expect(find.byType(TextFormField), findsNWidgets(2));
  });

  testWidgets('Tapping Sign In on Login screen navigates to Dashboard', (WidgetTester tester) async {
    await tester.pumpWidget(const TaskFlowApp());
    await tester.pumpAndSettle(const Duration(seconds: 3));

    // Fill in email and password
    final textFields = find.byType(TextFormField);
    await tester.enterText(textFields.first, 'ava@nimbus.com');
    await tester.enterText(textFields.last, 'password123');
    await tester.pumpAndSettle();

    // Scroll until Sign In button is visible and tap
    final signInFinder = find.text('Sign In');
    expect(signInFinder, findsOneWidget);
    await tester.ensureVisible(signInFinder);
    await tester.pumpAndSettle();
    await tester.tap(signInFinder);
    await tester.pumpAndSettle();

    // Verify Dashboard screen is shown
    expect(find.text('Good morning, Ava'), findsOneWidget);
    expect(find.text('Nimbus Digital'), findsWidgets);

    final projectsFinder = find.text('Your Projects');
    await tester.scrollUntilVisible(projectsFinder, 300, scrollable: find.byType(Scrollable).first);
    expect(projectsFinder, findsOneWidget);
  });

  testWidgets('Navigates from Login to RegisterScreen and back', (WidgetTester tester) async {
    await tester.pumpWidget(const TaskFlowApp());
    await tester.pumpAndSettle(const Duration(seconds: 3));

    // Scroll until "Create account" is visible and tap
    final createAccountFinder = find.text('Create account');
    expect(createAccountFinder, findsOneWidget);
    await tester.ensureVisible(createAccountFinder);
    await tester.pumpAndSettle();
    await tester.tap(createAccountFinder);
    await tester.pumpAndSettle();

    // Verify Register screen is displayed
    expect(find.text('Create an account'), findsOneWidget);
    expect(find.text('Create Account'), findsOneWidget);
    expect(find.byType(TextFormField), findsNWidgets(4));

    // Scroll until "Sign in" is visible and tap
    final signInFinder = find.text('Sign in');
    expect(signInFinder, findsOneWidget);
    await tester.ensureVisible(signInFinder);
    await tester.pumpAndSettle();
    await tester.tap(signInFinder);
    await tester.pumpAndSettle();

    // Verify Login screen is back
    expect(find.text('Welcome back'), findsOneWidget);
  });

  testWidgets('DashboardScreen renders overview, projects, tasks, and bottom nav', (WidgetTester tester) async {
    await tester.pumpWidget(const TaskFlowApp());
    AppRouter.router.go(RouteNames.dashboard);
    await tester.pumpAndSettle();

    // Verify Header & Organization
    expect(find.text('Good morning, Ava'), findsOneWidget);
    expect(find.text('Nimbus Digital'), findsWidgets);

    // Verify Overview Statistics
    expect(find.text('Total Projects'), findsOneWidget);
    expect(find.text('Total Tasks'), findsOneWidget);
    expect(find.text('Due Soon'), findsOneWidget);
    expect(find.text('Completed'), findsOneWidget);

    // Verify Quick Actions
    expect(find.text('New Task'), findsOneWidget);
    expect(find.text('New Project'), findsOneWidget);

    // Scroll to verify Projects Section
    final projectsFinder = find.text('Your Projects');
    await tester.scrollUntilVisible(projectsFinder, 300, scrollable: find.byType(Scrollable).first);
    expect(projectsFinder, findsOneWidget);
    expect(find.text('Website Relaunch'), findsWidgets);
    expect(find.text('Mobile App v2'), findsWidgets);

    // Scroll to verify Recent Tasks Section
    final tasksFinder = find.text('Recent Tasks');
    await tester.scrollUntilVisible(tasksFinder, 300, scrollable: find.byType(Scrollable).first);
    expect(tasksFinder, findsOneWidget);
    expect(find.text('Fix broken contact form'), findsOneWidget);
    expect(find.text('Set up design tokens in Figma'), findsOneWidget);

    // Verify Floating Bottom Navigation
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Projects'), findsOneWidget);
    expect(find.text('Tasks'), findsOneWidget);
    expect(find.text('Profile'), findsOneWidget);
  });

  testWidgets('Dark Theme definitions and component styles render cleanly', (WidgetTester tester) async {
    expect(AppTheme.light.brightness, Brightness.light);
    expect(AppTheme.dark.brightness, Brightness.dark);
    expect(AppTheme.light.scaffoldBackgroundColor, isNotNull);
    expect(AppTheme.dark.scaffoldBackgroundColor, isNotNull);
    expect(AppTheme.dark.cardTheme.color, isNotNull);
    expect(AppTheme.dark.inputDecorationTheme.filled, isTrue);
  });

  testWidgets('TasksScreen renders collapsing header, search, filters, task items, and floating nav', (WidgetTester tester) async {
    await tester.pumpWidget(const TaskFlowApp());
    AppRouter.router.go(RouteNames.tasks);
    await tester.pumpAndSettle();

    // Verify Header
    expect(find.text('Tasks'), findsWidgets);
    expect(find.text('Stay organized and keep your work moving.'), findsOneWidget);
    expect(find.text('15 tasks'), findsOneWidget);

    // Verify Search and Filters
    expect(find.text('Search tasks...'), findsOneWidget);
    expect(find.text('Status'), findsOneWidget);
    expect(find.text('Priority'), findsOneWidget);
    expect(find.text('Assignee'), findsOneWidget);
    expect(find.text('Due Date'), findsOneWidget);
    expect(find.text('Sort'), findsOneWidget);

    // Verify Task Items
    expect(find.text('Fix broken contact form'), findsOneWidget);
    expect(find.text('Build responsive nav component'), findsOneWidget);

    // Test Status Filter Bottom Sheet
    final statusFilterBtn = find.text('Status');
    await tester.tap(statusFilterBtn);
    await tester.pumpAndSettle();

    expect(find.text('Filter by Status'), findsOneWidget);
    expect(find.text('Apply'), findsOneWidget);

    // Select Review inside bottom sheet and Apply
    final reviewOption = find.descendant(
      of: find.byType(BottomSheet),
      matching: find.text('Review'),
    );
    await tester.tap(reviewOption.first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Apply'));
    await tester.pumpAndSettle();

    // Verify Active Filter Tag is displayed
    expect(find.text('Status: Review'), findsWidgets);
    expect(find.text('Clear all'), findsOneWidget);

    // Tap Clear all
    await tester.tap(find.text('Clear all'));
    await tester.pumpAndSettle();
    expect(find.text('Status: Review'), findsNothing);

    // Verify Floating Bottom Navigation is present
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Tasks'), findsWidgets);
  });

  testWidgets('ProjectsScreen renders collapsing header, search, filter tabs, project cards, and floating nav', (WidgetTester tester) async {
    await tester.pumpWidget(const TaskFlowApp());
    AppRouter.router.go(RouteNames.projects);
    await tester.pumpAndSettle();

    // Verify Header
    expect(find.text('Projects'), findsWidgets);
    expect(find.text('Manage your workspaces and keep every project moving forward.'), findsOneWidget);
    expect(find.text('3 active projects'), findsOneWidget);

    // Verify Search and Filter tabs
    expect(find.text('Search projects...'), findsOneWidget);
    expect(find.text('All'), findsOneWidget);
    expect(find.text('Active'), findsWidgets);
    expect(find.text('Completed'), findsOneWidget);
    expect(find.text('Sort'), findsOneWidget);

    // Verify Project Cards
    expect(find.text('Website Relaunch'), findsOneWidget);
    expect(find.text('Mobile App v2'), findsOneWidget);
    expect(find.text('Client Onboarding Revamp'), findsOneWidget);

    // Verify Floating Bottom Navigation is present
    expect(find.text('Projects'), findsWidgets);
    expect(find.text('Home'), findsOneWidget);
  });

  testWidgets('ProjectDetailsScreen renders header, progress, statistics, tasks, and delete dialog', (WidgetTester tester) async {
    await tester.pumpWidget(const TaskFlowApp());
    AppRouter.router.go('/projects/proj-1');
    await tester.pumpAndSettle();

    // Verify Header and Overview
    expect(find.text('Website Relaunch'), findsWidgets);
    expect(find.text('WR'), findsOneWidget);
    expect(find.text('Project progress'), findsOneWidget);
    expect(find.text('5 of 6 tasks completed'), findsOneWidget);

    // Verify Statistics & Distribution
    expect(find.text('Done'), findsWidgets);
    expect(find.text('Active'), findsWidgets);
    expect(find.text('Project Tasks'), findsOneWidget);

    // Verify Task Items
    expect(find.text('Fix broken contact form'), findsOneWidget);
    expect(find.text('Set up design tokens in Figma'), findsOneWidget);

    // Verify More menu and delete dialog
    final moreButtonFinder = find.byIcon(Icons.more_vert_rounded);
    expect(moreButtonFinder, findsOneWidget);
    await tester.tap(moreButtonFinder);
    await tester.pumpAndSettle();

    expect(find.text('Edit Project'), findsOneWidget);
    expect(find.text('Delete Project'), findsOneWidget);

    // Tap Delete Project
    await tester.tap(find.text('Delete Project'));
    await tester.pumpAndSettle();

    // Confirm Delete Dialog is shown
    expect(find.text('Delete project?'), findsOneWidget);
    expect(find.text('Cancel'), findsOneWidget);
    expect(find.text('Delete'), findsOneWidget);

    // Close Dialog
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(find.text('Delete project?'), findsNothing);
  });

  testWidgets('AddProjectScreen renders form, validates fields, and creates project', (WidgetTester tester) async {
    await tester.pumpWidget(const TaskFlowApp());
    AppRouter.router.go(RouteNames.createProject);
    await tester.pumpAndSettle();

    // Verify Header
    expect(find.text('Create a project'), findsOneWidget);
    expect(find.text('Set up a new project and start organizing your work.'), findsOneWidget);

    // Verify Section Headings
    expect(find.text('Project details'), findsOneWidget);
    expect(find.text('Project status'), findsOneWidget);
    expect(find.text('Timeline'), findsOneWidget);

    // Verify Default Initials Badge (NP when empty)
    expect(find.text('NP'), findsOneWidget);

    // Verify Form Fields
    expect(find.text('Project name'), findsOneWidget);
    expect(find.text('Description'), findsOneWidget);
    expect(find.text('Start date'), findsOneWidget);
    expect(find.text('End date'), findsOneWidget);

    // Verify Buttons
    final createBtnFinder = find.text('Create Project');
    expect(find.text('Cancel'), findsOneWidget);
    expect(createBtnFinder, findsOneWidget);

    // Scroll to Create Project and tap to trigger validation with empty inputs
    await tester.ensureVisible(createBtnFinder);
    await tester.pumpAndSettle();
    await tester.tap(createBtnFinder);
    await tester.pumpAndSettle();

    // Scroll to check error messages
    final nameErrorFinder = find.text('Project name is required');
    await tester.ensureVisible(nameErrorFinder);
    expect(nameErrorFinder, findsOneWidget);

    final descErrorFinder = find.text('Please add a short description');
    await tester.ensureVisible(descErrorFinder);
    expect(descErrorFinder, findsOneWidget);

    // Fill valid inputs
    final textFields = find.byType(TextFormField);
    await tester.enterText(textFields.first, 'Mobile App Redesign');
    await tester.enterText(textFields.last, 'Build a modern mobile redesign.');
    await tester.pumpAndSettle();

    // Verify Initials Updated dynamically to "MA"
    expect(find.text('MA'), findsOneWidget);

    // Select Status "Review"
    final reviewFinder = find.text('Review');
    await tester.ensureVisible(reviewFinder);
    await tester.tap(reviewFinder);
    await tester.pumpAndSettle();

    // Submit form
    await tester.ensureVisible(createBtnFinder);
    await tester.tap(createBtnFinder);
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pumpAndSettle();

    // Verify SnackBar success
    expect(find.text('Project "Mobile App Redesign" created successfully!'), findsOneWidget);
  });

  testWidgets('TaskDetailsScreen renders header, overview, assignee modal, activity, and post comment', (WidgetTester tester) async {
    await tester.pumpWidget(const TaskFlowApp());
    AppRouter.router.go('/tasks/task-1');
    await tester.pumpAndSettle();

    // Verify Header and Overview
    expect(find.text('Fix broken contact form'), findsWidgets);
    expect(find.text('Website Relaunch'), findsWidgets);
    expect(find.text('In Progress'), findsWidgets);
    expect(find.text('Urgent'), findsWidgets);

    // Verify Description Card
    expect(find.text('Description'), findsOneWidget);
    expect(find.textContaining('The contact form on the marketing website is currently failing'), findsOneWidget);

    // Verify Assignee and Due Date
    expect(find.text('Assignee'), findsOneWidget);
    expect(find.text('Ava Patel'), findsWidgets);
    expect(find.text('Due date'), findsOneWidget);

    // Scroll to and verify Activity & Comments
    final activityHeaderFinder = find.text('Activity & Comments');
    await tester.scrollUntilVisible(activityHeaderFinder, 300, scrollable: find.byType(Scrollable).first);
    expect(activityHeaderFinder, findsOneWidget);
    expect(find.text('Moved task to In Progress'), findsOneWidget);

    // Test Comment Input
    final commentInputFinder = find.byType(TextField).last;
    await tester.scrollUntilVisible(commentInputFinder, 200, scrollable: find.byType(Scrollable).first);
    await tester.enterText(commentInputFinder, 'Root cause identified: API timeout.');
    await tester.pumpAndSettle();

    final sendBtnFinder = find.byIcon(Icons.send_rounded);
    await tester.tap(sendBtnFinder);
    await tester.pumpAndSettle();

    // Verify newly added comment in activity timeline
    expect(find.text('Root cause identified: API timeout.'), findsOneWidget);

    // Test More Menu & Delete Dialog in pinned SliverAppBar
    final moreBtnFinder = find.byIcon(Icons.more_vert_rounded);
    await tester.tap(moreBtnFinder);
    await tester.pumpAndSettle();

    expect(find.text('Edit Task'), findsOneWidget);
    expect(find.text('Duplicate Task'), findsOneWidget);
    expect(find.text('Delete Task'), findsOneWidget);

    await tester.tap(find.text('Delete Task'));
    await tester.pumpAndSettle();

    expect(find.text('Delete task?'), findsOneWidget);
    expect(find.text('Cancel'), findsOneWidget);
    expect(find.text('Delete'), findsOneWidget);

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(find.text('Delete task?'), findsNothing);
  });

  testWidgets('CreateEditTaskScreen in create mode validates and creates task', (WidgetTester tester) async {
    await tester.pumpWidget(const TaskFlowApp());
    AppRouter.router.go(RouteNames.createTask);
    await tester.pumpAndSettle();

    // Verify Header
    expect(find.text('Create task'), findsOneWidget);
    expect(find.text('Add a task and keep your project moving forward.'), findsOneWidget);

    // Verify Sections
    expect(find.text('Task information'), findsOneWidget);
    expect(find.text('Task title'), findsOneWidget);
    expect(find.text('Description'), findsOneWidget);
    expect(find.text('Project'), findsWidgets);
    expect(find.text('Status & Priority'), findsOneWidget);
    expect(find.text('Assignee & Timeline'), findsOneWidget);

    // Verify Action Buttons
    final createBtnFinder = find.text('Create Task');
    expect(find.text('Cancel'), findsOneWidget);
    expect(createBtnFinder, findsOneWidget);

    // Trigger validation with empty inputs
    await tester.scrollUntilVisible(createBtnFinder, 300, scrollable: find.byType(Scrollable).first);
    await tester.tap(createBtnFinder);
    await tester.pumpAndSettle();

    expect(find.text('Task title is required'), findsOneWidget);
    expect(find.text('Please add a short description'), findsOneWidget);

    // Fill valid form fields
    final textFields = find.byType(TextFormField);
    await tester.enterText(textFields.first, 'Write onboarding documentation');
    await tester.enterText(textFields.last, 'Document step-by-step setup guides.');
    await tester.pumpAndSettle();

    // Submit form
    await tester.scrollUntilVisible(createBtnFinder, 300, scrollable: find.byType(Scrollable).first);
    await tester.tap(createBtnFinder);
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pumpAndSettle();

    // Verify SnackBar success
    expect(find.text('Task "Write onboarding documentation" created successfully!'), findsOneWidget);
  });

  testWidgets('CreateEditTaskScreen in edit mode pre-fills fields and saves changes', (WidgetTester tester) async {
    await tester.pumpWidget(const TaskFlowApp());
    AppRouter.router.go('/tasks/task-1/edit');
    await tester.pumpAndSettle();

    // Verify Header
    expect(find.text('Edit task'), findsOneWidget);
    expect(find.text('Update the details of this task.'), findsOneWidget);

    // Verify pre-filled data
    expect(find.text('Fix broken contact form'), findsOneWidget);
    expect(find.textContaining('Investigate and fix the contact form submission issue'), findsOneWidget);

    // Verify Save Changes button
    final saveBtnFinder = find.text('Save Changes');
    await tester.scrollUntilVisible(saveBtnFinder, 300, scrollable: find.byType(Scrollable).first);
    expect(saveBtnFinder, findsOneWidget);

    // Submit changes
    await tester.tap(saveBtnFinder);
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pumpAndSettle();

    // Verify SnackBar update message
    expect(find.text('Task "Fix broken contact form" updated successfully!'), findsOneWidget);
  });

  testWidgets('ProfileScreen renders header, info, preferences, theme modal, and dialogs', (WidgetTester tester) async {
    await tester.pumpWidget(const TaskFlowApp());
    AppRouter.router.go(RouteNames.profile);
    await tester.pumpAndSettle();

    // Verify Profile Header
    expect(find.text('Ava Patel'), findsWidgets);
    expect(find.text('Product Designer'), findsWidgets);
    expect(find.text('ava.patel@example.com'), findsWidgets);

    // Verify Sections
    expect(find.text('Personal information'), findsOneWidget);
    expect(find.text('Edit Profile'), findsOneWidget);
    expect(find.text('Preferences'), findsOneWidget);
    expect(find.text('Appearance'), findsOneWidget);
    expect(find.text('Notifications'), findsOneWidget);
    expect(find.text('Email notifications'), findsOneWidget);

    // Drag CustomScrollView to bring Preferences into center view
    await tester.drag(find.byType(CustomScrollView), const Offset(0, -450));
    await tester.pumpAndSettle();

    // Test Appearance bottom sheet
    final appearanceFinder = find.text('Appearance');
    await tester.tap(appearanceFinder);
    await tester.pumpAndSettle();

    expect(find.text('System default'), findsWidgets);
    expect(find.text('Light'), findsOneWidget);
    expect(find.text('Dark'), findsOneWidget);

    // Select Dark theme
    await tester.tap(find.text('Dark'));
    await tester.pumpAndSettle();

    // Scroll to see organization and account sections
    await tester.drag(find.byType(CustomScrollView), const Offset(0, -350));
    await tester.pumpAndSettle();

    final orgFinder = find.text('Nimbus Digital');
    expect(orgFinder, findsWidgets);
    expect(find.text('3 active projects • 15 tasks'), findsOneWidget);

    expect(find.text('Change password'), findsOneWidget);
    expect(find.text('Privacy'), findsOneWidget);
    expect(find.text('Help & Support'), findsOneWidget);

    // Scroll to see Danger Zone
    await tester.drag(find.byType(CustomScrollView), const Offset(0, -500));
    await tester.pumpAndSettle();
    await tester.drag(find.byType(CustomScrollView), const Offset(0, -500));
    await tester.pumpAndSettle();

    final logoutFinder = find.text('Log out');
    expect(logoutFinder, findsOneWidget);
    expect(find.text('Delete account'), findsOneWidget);

    // Test Logout Confirmation Dialog
    await tester.tap(logoutFinder);
    await tester.pumpAndSettle();

    expect(find.text('Log out?'), findsOneWidget);
    expect(find.text('Cancel'), findsOneWidget);

    // Cancel Logout
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(find.text('Log out?'), findsNothing);

    // Verify Floating Bottom Navigation
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Profile'), findsWidgets);
  });

  testWidgets('MainShell StatefulShellRoute switches tabs smoothly across branches', (WidgetTester tester) async {
    await tester.pumpWidget(const TaskFlowApp());
    AppRouter.router.go(RouteNames.dashboard);
    await tester.pumpAndSettle();

    // 1. Initial State: Dashboard is displayed
    expect(find.text('Good morning, Ava'), findsOneWidget);
    expect(find.text('Home'), findsOneWidget);

    // 2. Tap "Projects" tab in FloatingBottomNav
    final projectsTabFinder = find.text('Projects');
    expect(projectsTabFinder, findsWidgets);
    await tester.tap(projectsTabFinder.first);
    await tester.pumpAndSettle();

    // Verify ProjectsScreen is active
    expect(find.text('Manage your workspaces and keep every project moving forward.'), findsOneWidget);
    expect(find.text('3 active projects'), findsOneWidget);

    // 3. Tap "Tasks" tab in FloatingBottomNav
    final tasksTabFinder = find.text('Tasks');
    expect(tasksTabFinder, findsWidgets);
    await tester.tap(tasksTabFinder.first);
    await tester.pumpAndSettle();

    // Verify TasksScreen is active
    expect(find.text('Search tasks...'), findsOneWidget);
    expect(find.text('Build responsive nav component'), findsOneWidget);

    // 4. Tap "Profile" tab in FloatingBottomNav
    final profileTabFinder = find.text('Profile');
    expect(profileTabFinder, findsWidgets);
    await tester.tap(profileTabFinder.first);
    await tester.pumpAndSettle();

    // Verify ProfileScreen is active
    expect(find.text('Personal information'), findsOneWidget);
    expect(find.text('ava.patel@example.com'), findsWidgets);

    // 5. Tap "Home" tab to return to Dashboard
    final homeTabFinder = find.text('Home');
    expect(homeTabFinder, findsOneWidget);
    await tester.tap(homeTabFinder);
    await tester.pumpAndSettle();

    // Verify back on Dashboard
    expect(find.text('Good morning, Ava'), findsOneWidget);
  });

  testWidgets('Full-screen modal routes (AddProject, CreateTask) use rootNavigatorKey', (WidgetTester tester) async {
    await tester.pumpWidget(const TaskFlowApp());

    // 1. Navigate to /projects/create
    AppRouter.router.go(RouteNames.createProject);
    await tester.pumpAndSettle();

    expect(find.text('Create Project'), findsWidgets);
    expect(find.text('Project name'), findsOneWidget);

    // 2. Navigate to /tasks/create
    AppRouter.router.go(RouteNames.createTask);
    await tester.pumpAndSettle();

    expect(find.text('Create task'), findsOneWidget);
    expect(find.text('Task title'), findsOneWidget);
    expect(find.text('Create Task'), findsOneWidget);

    // 3. Navigate to /tasks/task-1 then /tasks/task-1/edit
    AppRouter.router.go('/tasks/task-1');
    await tester.pumpAndSettle();
    AppRouter.router.go('/tasks/task-1/edit');
    await tester.pumpAndSettle();

    expect(find.text('Edit task'), findsOneWidget);
    expect(find.text('Save Changes'), findsOneWidget);
  });
}

