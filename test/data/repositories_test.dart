import 'package:flutter_test/flutter_test.dart';
import 'package:task_flow/core/storage/secure_storage_service.dart';
import 'package:task_flow/data/datasources/mock_data_source.dart';
import 'package:task_flow/data/repositories/auth_repository_impl.dart';
import 'package:task_flow/data/repositories/comment_repository_impl.dart';
import 'package:task_flow/data/repositories/notification_repository_impl.dart';
import 'package:task_flow/data/repositories/organization_repository_impl.dart';
import 'package:task_flow/data/repositories/project_repository_impl.dart';
import 'package:task_flow/data/repositories/task_repository_impl.dart';
import 'package:task_flow/data/repositories/user_repository_impl.dart';
import 'package:task_flow/domain/entities/enums.dart';
import 'package:task_flow/domain/repositories/auth_repository.dart';
import 'package:task_flow/domain/repositories/comment_repository.dart';
import 'package:task_flow/domain/repositories/notification_repository.dart';
import 'package:task_flow/domain/repositories/organization_repository.dart';
import 'package:task_flow/domain/repositories/project_repository.dart';
import 'package:task_flow/domain/repositories/task_repository.dart';
import 'package:task_flow/domain/repositories/user_repository.dart';

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
  late OrganizationRepository organizationRepo;
  late UserRepository userRepo;
  late ProjectRepository projectRepo;
  late TaskRepository taskRepo;
  late CommentRepository commentRepo;
  late NotificationRepository notificationRepo;
  late AuthRepository authRepo;

  setUp(() {
    mockDataSource = MockDataSource();
    secureStorageService = _FakeSecureStorageService();
    authRepo = AuthRepositoryImpl(
      mockDataSource: mockDataSource,
      secureStorageService: secureStorageService,
    );
    organizationRepo = OrganizationRepositoryImpl(mockDataSource: mockDataSource);
    userRepo = UserRepositoryImpl(mockDataSource: mockDataSource);
    projectRepo = ProjectRepositoryImpl(mockDataSource: mockDataSource, authRepository: authRepo);
    taskRepo = TaskRepositoryImpl(mockDataSource: mockDataSource);
    commentRepo = CommentRepositoryImpl(mockDataSource: mockDataSource);
    notificationRepo = NotificationRepositoryImpl(mockDataSource: mockDataSource);
  });

  group('OrganizationRepository', () {
    test('getOrganizations returns 2 organizations', () async {
      final orgs = await organizationRepo.getOrganizations();
      expect(orgs.length, 2);
      expect(orgs.map((o) => o.id), containsAll(['org_a1b2c3', 'org_d4e5f6']));
    });

    test('getOrganizationById returns correct org or null', () async {
      final org = await organizationRepo.getOrganizationById('org_a1b2c3');
      expect(org, isNotNull);
      expect(org!.name, 'Nimbus Digital');

      final nonExistent = await organizationRepo.getOrganizationById('unknown');
      expect(nonExistent, isNull);
    });
  });

  group('UserRepository', () {
    test('getUsers returns 5 users', () async {
      final users = await userRepo.getUsers();
      expect(users.length, 5);
    });

    test('getUserById returns correct user or null', () async {
      final user = await userRepo.getUserById('user_001');
      expect(user, isNotNull);
      expect(user!.name, 'Ava Thompson');

      final nonExistent = await userRepo.getUserById('invalid');
      expect(nonExistent, isNull);
    });

    test('getMembersByOrgId and getUsersByOrgId filter correctly', () async {
      final membersOrgA = await userRepo.getMembersByOrgId('org_a1b2c3');
      expect(membersOrgA.length, 3);
      expect(membersOrgA.first.role, OrgRole.orgAdmin);

      final membersOrgB = await userRepo.getMembersByOrgId('org_d4e5f6');
      expect(membersOrgB.length, 2);

      final usersOrgA = await userRepo.getUsersByOrgId('org_a1b2c3');
      expect(usersOrgA.length, 3);
      expect(usersOrgA.map((u) => u.name), contains('Ava Thompson'));
    });
  });

  group('ProjectRepository', () {
    test('getProjects returns 3 projects', () async {
      final projects = await projectRepo.getProjects();
      expect(projects.length, 3);
    });

    test('getProjectById returns correct project or null', () async {
      final project = await projectRepo.getProjectById('proj_1001');
      expect(project, isNotNull);
      expect(project!.name, 'Website Relaunch');

      final invalid = await projectRepo.getProjectById('invalid');
      expect(invalid, isNull);
    });

    test('getProjectsByOrgId returns projects matching org', () async {
      final orgAProjects = await projectRepo.getProjectsByOrgId('org_a1b2c3');
      expect(orgAProjects.length, 2);

      final orgBProjects = await projectRepo.getProjectsByOrgId('org_d4e5f6');
      expect(orgBProjects.length, 1);
      expect(orgBProjects.first.id, 'proj_1003');
    });
  });

  group('TaskRepository', () {
    test('getTasks returns 15 tasks', () async {
      final tasks = await taskRepo.getTasks();
      expect(tasks.length, 15);
    });

    test('getTaskById returns correct task or null', () async {
      final task = await taskRepo.getTaskById('task_2001');
      expect(task, isNotNull);
      expect(task!.title, 'Set up design tokens in Figma');

      final invalid = await taskRepo.getTaskById('invalid');
      expect(invalid, isNull);
    });

    test('getTasksByProjectId filters tasks for specific project', () async {
      final proj1Tasks = await taskRepo.getTasksByProjectId('proj_1001');
      expect(proj1Tasks.length, 6);

      final proj2Tasks = await taskRepo.getTasksByProjectId('proj_1002');
      expect(proj2Tasks.length, 5);

      final proj3Tasks = await taskRepo.getTasksByProjectId('proj_1003');
      expect(proj3Tasks.length, 4);
    });
  });

  group('CommentRepository', () {
    test('getComments returns 4 comments', () async {
      final comments = await commentRepo.getComments();
      expect(comments.length, 4);
    });

    test('getCommentsByTaskId filters comments by task', () async {
      final task2002Comments = await commentRepo.getCommentsByTaskId('task_2002');
      expect(task2002Comments.length, 2);

      final task2004Comments = await commentRepo.getCommentsByTaskId('task_2004');
      expect(task2004Comments.length, 1);

      final nonExistent = await commentRepo.getCommentsByTaskId('task_none');
      expect(nonExistent, isEmpty);
    });
  });

  group('NotificationRepository', () {
    test('getNotifications returns 3 notifications', () async {
      final notifs = await notificationRepo.getNotifications();
      expect(notifs.length, 3);
    });

    test('getNotificationsByUserId filters notifications by user', () async {
      final user2Notifs = await notificationRepo.getNotificationsByUserId('user_002');
      expect(user2Notifs.length, 1);
      expect(user2Notifs.first.taskId, 'task_2004');

      final user5Notifs = await notificationRepo.getNotificationsByUserId('user_005');
      expect(user5Notifs.length, 1);
    });
  });

  group('AuthRepository', () {
    test('getTestCredentials returns 4 test credential pairs', () async {
      final credentials = await authRepo.getTestCredentials();
      expect(credentials.length, 4);
    });

    test('login validates test credentials correctly', () async {
      final validResponse = await authRepo.login(
        'ava.admin@nimbusdigital.test',
        'Password123!',
      );
      expect(validResponse.accessToken, 'mock.access.token.short_lived');

      expect(
        () => authRepo.login('ava.admin@nimbusdigital.test', 'WrongPassword'),
        throwsException,
      );
    });

    test('refreshToken returns login response when valid', () async {
      await authRepo.login('ava.admin@nimbusdigital.test', 'Password123!');
      final response = await authRepo.refreshToken('mock.refresh.token.long_lived');
      expect(response, isNotNull);
      expect(response!.accessTokenExpiresInSeconds, 900);

      final invalidResponse = await authRepo.refreshToken('invalid.token');
      expect(invalidResponse, isNull);
    });
  });
}
