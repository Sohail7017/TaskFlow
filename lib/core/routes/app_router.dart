import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'route_names.dart';

/// Centralized GoRouter routing configuration
abstract final class AppRouter {
  // Global Navigator Key
  static final GlobalKey<NavigatorState> rootNavigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'root_navigator');

  /// Centralized GoRouter instance
  static final GoRouter router = GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: RouteNames.splash,
    debugLogDiagnostics: false,
    routes: <RouteBase>[
      GoRoute(
        path: RouteNames.splash,
        name: 'splash',
        builder: (context, state) => const _RoutePlaceholderScreen(
          title: 'TaskFlow',
          subtitle: 'Splash & Initialization',
        ),
      ),
      GoRoute(
        path: RouteNames.login,
        name: 'login',
        builder: (context, state) => const _RoutePlaceholderScreen(
          title: 'Login',
          subtitle: 'Authentication screen placeholder',
        ),
      ),
      GoRoute(
        path: RouteNames.register,
        name: 'register',
        builder: (context, state) => const _RoutePlaceholderScreen(
          title: 'Register',
          subtitle: 'Registration screen placeholder',
        ),
      ),
      GoRoute(
        path: RouteNames.dashboard,
        name: 'dashboard',
        builder: (context, state) => const _RoutePlaceholderScreen(
          title: 'Dashboard',
          subtitle: 'Dashboard screen placeholder',
        ),
      ),
      GoRoute(
        path: RouteNames.projects,
        name: 'projects',
        builder: (context, state) => const _RoutePlaceholderScreen(
          title: 'Projects',
          subtitle: 'Project list screen placeholder',
        ),
      ),
      GoRoute(
        path: RouteNames.projectDetails,
        name: 'projectDetails',
        builder: (context, state) => _RoutePlaceholderScreen(
          title: 'Project Details',
          subtitle: 'Project ID: ${state.pathParameters['projectId']}',
        ),
      ),
      GoRoute(
        path: RouteNames.tasks,
        name: 'tasks',
        builder: (context, state) => const _RoutePlaceholderScreen(
          title: 'Tasks',
          subtitle: 'Task list screen placeholder',
        ),
      ),
      GoRoute(
        path: RouteNames.createTask,
        name: 'createTask',
        builder: (context, state) => const _RoutePlaceholderScreen(
          title: 'Create Task',
          subtitle: 'Create new task screen placeholder',
        ),
      ),
      GoRoute(
        path: RouteNames.taskDetails,
        name: 'taskDetails',
        builder: (context, state) => _RoutePlaceholderScreen(
          title: 'Task Details',
          subtitle: 'Task ID: ${state.pathParameters['taskId']}',
        ),
      ),
      GoRoute(
        path: RouteNames.editTask,
        name: 'editTask',
        builder: (context, state) => _RoutePlaceholderScreen(
          title: 'Edit Task',
          subtitle: 'Editing Task ID: ${state.pathParameters['taskId']}',
        ),
      ),
      GoRoute(
        path: RouteNames.profile,
        name: 'profile',
        builder: (context, state) => const _RoutePlaceholderScreen(
          title: 'Profile',
          subtitle: 'User Profile & Settings placeholder',
        ),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(title: const Text('Page Not Found')),
      body: Center(
        child: Text('No route defined for ${state.uri}'),
      ),
    ),
  );
}

/// Minimal temporary placeholder screen for compilation and router testing
class _RoutePlaceholderScreen extends StatelessWidget {
  const _RoutePlaceholderScreen({
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
