import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../presentation/screens/auth/login_screen.dart';
import '../../presentation/screens/auth/register_screen.dart';
import '../../presentation/screens/auth/splash_screen.dart';
import '../../presentation/screens/dashboard/dashboard_screen.dart';
import '../../presentation/screens/profile/profile_screen.dart';
import '../../presentation/screens/projects/add_project_screen.dart';
import '../../presentation/screens/projects/project_details_screen.dart';
import '../../presentation/screens/projects/projects_screen.dart';
import '../../presentation/screens/tasks/create_edit_task_screen.dart';
import '../../presentation/screens/tasks/task_details_screen.dart';
import '../../presentation/screens/tasks/tasks_screen.dart';
import '../../presentation/shell/main_shell.dart';
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
      // Top-level Auth and Splash routes
      GoRoute(
        path: RouteNames.splash,
        name: 'splash',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: RouteNames.login,
        name: 'login',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: RouteNames.register,
        name: 'register',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const RegisterScreen(),
      ),

      // Persistent Main Application Shell with 4 Navigation Branches
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) => MainShell(
          navigationShell: navigationShell,
        ),
        branches: <StatefulShellBranch>[
          // Branch 0: Dashboard
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: RouteNames.dashboard,
                name: 'dashboard',
                builder: (context, state) => const DashboardScreen(),
              ),
            ],
          ),

          // Branch 1: Projects
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: RouteNames.projects,
                name: 'projects',
                builder: (context, state) => const ProjectsScreen(),
                routes: <RouteBase>[
                  GoRoute(
                    path: 'create',
                    name: 'createProject',
                    parentNavigatorKey: rootNavigatorKey,
                    builder: (context, state) => const AddProjectScreen(),
                  ),
                  GoRoute(
                    path: ':projectId',
                    name: 'projectDetails',
                    builder: (context, state) => ProjectDetailsScreen(
                      projectId: state.pathParameters['projectId'] ?? '',
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Branch 2: Tasks
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: RouteNames.tasks,
                name: 'tasks',
                builder: (context, state) => const TasksScreen(),
                routes: <RouteBase>[
                  GoRoute(
                    path: 'create',
                    name: 'createTask',
                    parentNavigatorKey: rootNavigatorKey,
                    builder: (context, state) => const CreateEditTaskScreen(
                      mode: TaskFormMode.create,
                    ),
                  ),
                  GoRoute(
                    path: ':taskId',
                    name: 'taskDetails',
                    builder: (context, state) => TaskDetailsScreen(
                      taskId: state.pathParameters['taskId'] ?? '',
                    ),
                    routes: <RouteBase>[
                      GoRoute(
                        path: 'edit',
                        name: 'editTask',
                        parentNavigatorKey: rootNavigatorKey,
                        builder: (context, state) => CreateEditTaskScreen(
                          mode: TaskFormMode.edit,
                          taskId: state.pathParameters['taskId'],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),

          // Branch 3: Profile
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: RouteNames.profile,
                name: 'profile',
                builder: (context, state) => const ProfileScreen(),
              ),
            ],
          ),
        ],
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
