import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'app.dart';
import 'core/di/injection.dart';
import 'presentation/bloc/auth/auth_bloc.dart';
import 'presentation/bloc/auth/auth_event.dart';
import 'presentation/bloc/projects/project_bloc.dart';
import 'presentation/bloc/tasks/task_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize service locator and core dependencies
  await initDependencies();

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (context) => sl<AuthBloc>()..add(const SessionCheckRequested()),
        ),
        BlocProvider<ProjectBloc>(
          create: (context) => sl<ProjectBloc>(),
        ),
        BlocProvider<TaskBloc>(
          create: (context) => sl<TaskBloc>(),
        ),
      ],
      child: const TaskFlowApp(),
    ),
  );
}
