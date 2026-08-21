import '../../../core/constants/storage_keys.dart';
import '../../../core/storage/secure_storage_service.dart';
import '../../../domain/repositories/auth_repository.dart';
import '../datasources/local/taskflow_local_data_source.dart';

/// Implementation of [AuthRepository]
class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl({
    required TaskFlowLocalDataSource localDataSource,
    required SecureStorageService secureStorageService,
  })  : _localDataSource = localDataSource,
        _secureStorageService = secureStorageService;

  // Reserved for future auth verification against local mock JSON or remote API
  // ignore: unused_field
  final TaskFlowLocalDataSource _localDataSource;
  final SecureStorageService _secureStorageService;

  @override
  Future<bool> isAuthenticated() async {
    final token = await _secureStorageService.read(key: StorageKeys.accessToken);
    return token != null && token.isNotEmpty;
  }

  @override
  Future<String?> getAuthToken() async {
    return _secureStorageService.read(key: StorageKeys.accessToken);
  }

  @override
  Future<void> logout() async {
    await _secureStorageService.delete(key: StorageKeys.accessToken);
    await _secureStorageService.delete(key: StorageKeys.currentUserId);
    await _secureStorageService.delete(key: StorageKeys.currentOrgId);
  }
}
