import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';

import '../../data/datasources/mock_data_source.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../data/repositories/comment_repository_impl.dart';
import '../../data/repositories/notification_repository_impl.dart';
import '../../data/repositories/organization_repository_impl.dart';
import '../../data/repositories/project_repository_impl.dart';
import '../../data/repositories/task_repository_impl.dart';
import '../../data/repositories/user_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/comment_repository.dart';
import '../../domain/repositories/notification_repository.dart';
import '../../domain/repositories/organization_repository.dart';
import '../../domain/repositories/project_repository.dart';
import '../../domain/repositories/task_repository.dart';
import '../../domain/repositories/user_repository.dart';
import '../../domain/usecases/projects/get_project_by_id.dart';
import '../../domain/usecases/projects/get_projects.dart';
import '../../domain/usecases/tasks/get_task_by_id.dart';
import '../../domain/usecases/tasks/get_tasks.dart';
import '../../domain/usecases/tasks/get_tasks_by_project.dart';
import '../../presentation/bloc/auth/auth_bloc.dart';
import '../../presentation/bloc/projects/project_bloc.dart';
import '../../presentation/bloc/tasks/task_bloc.dart';
import '../storage/hive_service.dart';
import '../storage/secure_storage_service.dart';

/// Global service locator instance
final GetIt sl = GetIt.instance;

/// Initialize core infrastructure dependencies, repositories, usecases, and blocs
Future<void> initDependencies({
  String? hiveStoragePath,
  HiveService? hiveServiceOverride,
  FlutterSecureStorage? secureStorageOverride,
  MockDataSource? mockDataSourceOverride,
}) async {
  // 1. Storage Services
  final hiveService = hiveServiceOverride ?? HiveServiceImpl();
  await hiveService.init(hiveStoragePath);
  sl.registerLazySingleton<HiveService>(() => hiveService);

  final secureStorage = secureStorageOverride ?? const FlutterSecureStorage();
  sl.registerLazySingleton<FlutterSecureStorage>(() => secureStorage);
  sl.registerLazySingleton<SecureStorageService>(() => SecureStorageServiceImpl(secureStorage: sl()),);

  // 2. Data Sources
  final mockDataSource = mockDataSourceOverride ?? MockDataSource();
  sl.registerLazySingleton<MockDataSource>(() => mockDataSource);

  // 3. Repositories
  sl.registerLazySingleton<OrganizationRepository>(
    () => OrganizationRepositoryImpl(mockDataSource: sl()),
  );
  sl.registerLazySingleton<UserRepository>(
    () => UserRepositoryImpl(mockDataSource: sl()),
  );
  sl.registerLazySingleton<ProjectRepository>(() => ProjectRepositoryImpl(mockDataSource: sl(), authRepository: sl()),);
  sl.registerLazySingleton<TaskRepository>(() => TaskRepositoryImpl(mockDataSource: sl()),);
  sl.registerLazySingleton<CommentRepository>(() => CommentRepositoryImpl(mockDataSource: sl()),);
  sl.registerLazySingleton<NotificationRepository>(() => NotificationRepositoryImpl(mockDataSource: sl()),);
  sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(mockDataSource: sl(), secureStorageService: sl(),),);

  sl.registerLazySingleton<GetProjects>(() => GetProjects(sl()));
  sl.registerLazySingleton<GetProjectById>(() => GetProjectById(sl()));

  sl.registerLazySingleton<GetTasks>(() => GetTasks(sl()));
  sl.registerLazySingleton<GetTaskById>(() => GetTaskById(sl()));
  sl.registerLazySingleton<GetTasksByProject>(() => GetTasksByProject(sl()));

  // 5. BLoCs
  sl.registerLazySingleton<AuthBloc>(() => AuthBloc(authRepository: sl(),),);
  sl.registerLazySingleton<ProjectBloc>(
    () => ProjectBloc(
      projectRepository: sl(),
      authRepository: sl(),
    ),
  );
  sl.registerLazySingleton<TaskBloc>(
    () => TaskBloc(
      taskRepository: sl(),
      authRepository: sl(),
      projectRepository: sl(),
      userRepository: sl(),
    ),
  );
}
