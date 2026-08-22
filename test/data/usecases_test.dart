import 'package:flutter_test/flutter_test.dart';
import 'package:task_flow/core/storage/secure_storage_service.dart';
import 'package:task_flow/data/datasources/mock_data_source.dart';
import 'package:task_flow/data/repositories/auth_repository_impl.dart';
import 'package:task_flow/data/repositories/project_repository_impl.dart';
import 'package:task_flow/data/repositories/task_repository_impl.dart';
import 'package:task_flow/domain/usecases/auth/check_auth_status.dart';
import 'package:task_flow/domain/usecases/auth/login.dart';
import 'package:task_flow/domain/usecases/auth/logout.dart';
import 'package:task_flow/domain/usecases/auth/refresh_token.dart';
import 'package:task_flow/domain/usecases/projects/get_project_by_id.dart';
import 'package:task_flow/domain/usecases/projects/get_projects.dart';
import 'package:task_flow/domain/usecases/tasks/get_task_by_id.dart';
import 'package:task_flow/domain/usecases/tasks/get_tasks.dart';
import 'package:task_flow/domain/usecases/tasks/get_tasks_by_project.dart';

class _FakeSecureStorageService implements SecureStorageService {
  final Map<String, String> _storage = {};

  @override
  Future<String?> read({required String key}) async => _storage[key];
  @override
  Future<void> write({required String key, required String value}) async => _storage[key] = value;
  @override
  Future<void> delete({required String key}) async => _storage.remove(key);
  @override
  Future<void> deleteAll() async => _storage.clear();
  @override
  Future<bool> containsKey({required String key}) async => _storage.containsKey(key);

  @override
  Future<void> saveAuthSession({
    required String accessToken,
    required String refreshToken,
    required DateTime accessTokenExpiry,
    required DateTime refreshTokenExpiry,
    String? userId,
    String? orgId,
    String? name,
    String? email,
    String? avatarUrl,
    String? role,
  }) async {
    _storage['access_token'] = accessToken;
    _storage['refresh_token'] = refreshToken;
    _storage['access_token_expiry'] = accessTokenExpiry.toIso8601String();
    _storage['refresh_token_expiry'] = refreshTokenExpiry.toIso8601String();
    if (userId != null) _storage['current_user_id'] = userId;
    if (orgId != null) _storage['current_org_id'] = orgId;
    if (name != null) _storage['current_user_name'] = name;
    if (email != null) _storage['current_user_email'] = email;
    if (avatarUrl != null) _storage['current_user_avatar'] = avatarUrl;
    if (role != null) _storage['current_user_role'] = role;
  }

  @override
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
    required DateTime accessTokenExpiry,
    required DateTime refreshTokenExpiry,
  }) async {
    _storage['access_token'] = accessToken;
    _storage['refresh_token'] = refreshToken;
    _storage['access_token_expiry'] = accessTokenExpiry.toIso8601String();
    _storage['refresh_token_expiry'] = refreshTokenExpiry.toIso8601String();
  }

  @override
  Future<String?> getAccessToken() async => _storage['access_token'];
  @override
  Future<String?> getRefreshToken() async => _storage['refresh_token'];
  @override
  Future<DateTime?> getAccessTokenExpiry() async =>
      _storage['access_token_expiry'] != null ? DateTime.tryParse(_storage['access_token_expiry']!) : null;
  @override
  Future<DateTime?> getRefreshTokenExpiry() async =>
      _storage['refresh_token_expiry'] != null ? DateTime.tryParse(_storage['refresh_token_expiry']!) : null;
  @override
  Future<String?> getUserId() async => _storage['current_user_id'];
  @override
  Future<String?> getOrgId() async => _storage['current_org_id'];
  @override
  Future<String?> getUserName() async => _storage['current_user_name'];
  @override
  Future<String?> getUserEmail() async => _storage['current_user_email'];
  @override
  Future<String?> getUserAvatar() async => _storage['current_user_avatar'];
  @override
  Future<String?> getUserRole() async => _storage['current_user_role'];
  @override
  Future<void> clearSession() async => _storage.clear();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockDataSource mockDataSource;
  late SecureStorageService secureStorageService;
  late ProjectRepositoryImpl projectRepo;
  late TaskRepositoryImpl taskRepo;
  late AuthRepositoryImpl authRepo;

  late GetProjects getProjects;
  late GetProjectById getProjectById;
  late GetTasks getTasks;
  late GetTaskById getTaskById;
  late GetTasksByProject getTasksByProject;
  late Login login;
  late Logout logout;
  late RefreshToken refreshToken;
  late CheckAuthStatus checkAuthStatus;

  setUp(() {
    mockDataSource = MockDataSource();
    secureStorageService = _FakeSecureStorageService();
    authRepo = AuthRepositoryImpl(
      mockDataSource: mockDataSource,
      secureStorageService: secureStorageService,
    );
    projectRepo = ProjectRepositoryImpl(mockDataSource: mockDataSource, authRepository: authRepo);
    taskRepo = TaskRepositoryImpl(mockDataSource: mockDataSource);

    getProjects = GetProjects(projectRepo);
    getProjectById = GetProjectById(projectRepo);
    getTasks = GetTasks(taskRepo);
    getTaskById = GetTaskById(taskRepo);
    getTasksByProject = GetTasksByProject(taskRepo);
    login = Login(authRepo);
    logout = Logout(authRepo);
    refreshToken = RefreshToken(authRepo);
    checkAuthStatus = CheckAuthStatus(authRepo);
  });

  group('Project UseCases', () {
    test('GetProjects returns all projects or filtered by org', () async {
      final allProjects = await getProjects();
      expect(allProjects.length, 3);

      final orgProjects = await getProjects('org_a1b2c3');
      expect(orgProjects.length, 2);
    });

    test('GetProjectById returns matching project or null', () async {
      final project = await getProjectById('proj_1001');
      expect(project, isNotNull);
      expect(project!.name, 'Website Relaunch');

      final notFound = await getProjectById('unknown');
      expect(notFound, isNull);
    });
  });

  group('Task UseCases', () {
    test('GetTasks returns all tasks or filtered by project', () async {
      final allTasks = await getTasks();
      expect(allTasks.length, 15);

      final proj1Tasks = await getTasks('proj_1001');
      expect(proj1Tasks.length, 6);
    });

    test('GetTaskById returns matching task or null', () async {
      final task = await getTaskById('task_2001');
      expect(task, isNotNull);
      expect(task!.title, 'Set up design tokens in Figma');

      final notFound = await getTaskById('unknown');
      expect(notFound, isNull);
    });

    test('GetTasksByProject returns tasks for specified project', () async {
      final tasks = await getTasksByProject('proj_1002');
      expect(tasks.length, 5);
      expect(tasks.every((t) => t.projectId == 'proj_1002'), isTrue);
    });
  });

  group('Auth UseCases', () {
    test('Login calls repository and validates credentials', () async {
      final response = await login('ava.admin@nimbusdigital.test', 'Password123!');
      expect(response.accessToken, 'mock.access.token.short_lived');

      expect(
        () => login('ava.admin@nimbusdigital.test', 'Wrong'),
        throwsException,
      );
    });

    test('RefreshToken calls repository', () async {
      await login('ava.admin@nimbusdigital.test', 'Password123!');
      final response = await refreshToken('mock.refresh.token.long_lived');
      expect(response, isNotNull);
    });

    test('CheckAuthStatus returns active status', () async {
      final isAuthBefore = await checkAuthStatus();
      expect(isAuthBefore, isFalse);

      await login('ava.admin@nimbusdigital.test', 'Password123!');
      final isAuthAfter = await checkAuthStatus();
      expect(isAuthAfter, isTrue);
    });

    test('Logout calls repository without error', () async {
      await expectLater(logout(), completes);
    });
  });
}
