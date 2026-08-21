import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';

import '../../data/datasources/local/taskflow_local_data_source.dart';
import '../storage/hive_service.dart';
import '../storage/secure_storage_service.dart';

/// Global service locator instance
final GetIt sl = GetIt.instance;

/// Initialize core infrastructure dependencies
Future<void> initDependencies({
  String? hiveStoragePath,
  HiveService? hiveServiceOverride,
  FlutterSecureStorage? secureStorageOverride,
}) async {
  // 1. Storage Services
  final hiveService = hiveServiceOverride ?? HiveServiceImpl();
  await hiveService.init(hiveStoragePath);
  sl.registerLazySingleton<HiveService>(() => hiveService);

  final secureStorage = secureStorageOverride ?? const FlutterSecureStorage();
  sl.registerLazySingleton<FlutterSecureStorage>(() => secureStorage);
  sl.registerLazySingleton<SecureStorageService>(
    () => SecureStorageServiceImpl(secureStorage: sl()),
  );

  // 2. Data Sources (Local Mock Asset Data Source)
  sl.registerLazySingleton<TaskFlowLocalDataSource>(
    () => TaskFlowLocalDataSourceImpl(),
  );

  // Note: Feature repositories, use cases, and Blocs/Cubits will be registered
  // centrally here as their respective features are implemented.
}
