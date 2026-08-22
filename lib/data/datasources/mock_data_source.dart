import 'dart:convert';
import 'package:flutter/services.dart';
import '../../core/constants/asset_paths.dart';
import '../../core/errors/exceptions.dart';
import '../models/auth_credentials_model.dart';
import '../models/comment_model.dart';
import '../models/mock_login_response_model.dart';
import '../models/notification_model.dart';
import '../models/org_member_model.dart';
import '../models/organization_model.dart';
import '../models/project_model.dart';
import '../models/task_model.dart';
import '../models/user_model.dart';

/// Loads, parses, and caches in-memory mock collections from JSON asset
class MockDataSource {
  MockDataSource({
    AssetBundle? assetBundle,
    String? assetPath,
  })  : assetBundle = assetBundle ?? rootBundle,
        assetPath = assetPath ?? AssetPaths.mockDataJson;

  final AssetBundle assetBundle;
  final String assetPath;

  bool _isLoaded = false;
  List<OrganizationModel> _organizations = const [];
  List<UserModel> _users = const [];
  List<OrgMemberModel> _orgMembers = const [];
  List<ProjectModel> _projects = const [];
  List<TaskModel> _tasks = const [];
  List<CommentModel> _comments = const [];
  List<NotificationModel> _notifications = const [];
  List<AuthCredentialsModel> _authCredentials = const [];
  MockLoginResponseModel? _mockLoginResponse;

  /// Loads and parses the mock JSON database if not already cached
  Future<void> loadMockData() async {
    if (_isLoaded) {
      return;
    }

    try {
      final jsonString = await assetBundle.loadString(assetPath);
      final dynamic decoded = json.decode(jsonString);

      if (decoded is! Map<String, dynamic>) {
        throw const CacheException(
          message: 'Invalid mock data format: root must be a JSON object.',
        );
      }

      // Organizations
      final rawOrgs = decoded['organizations'] as List<dynamic>? ?? [];
      _organizations = rawOrgs
          .whereType<Map<String, dynamic>>()
          .map(OrganizationModel.fromJson)
          .toList();

      // Users
      final rawUsers = decoded['users'] as List<dynamic>? ?? [];
      _users = rawUsers
          .whereType<Map<String, dynamic>>()
          .map(UserModel.fromJson)
          .toList();

      // Org Members
      final rawMembers = decoded['org_members'] as List<dynamic>? ?? [];
      _orgMembers = rawMembers
          .whereType<Map<String, dynamic>>()
          .map(OrgMemberModel.fromJson)
          .toList();

      // Projects
      final rawProjects = decoded['projects'] as List<dynamic>? ?? [];
      _projects = rawProjects
          .whereType<Map<String, dynamic>>()
          .map(ProjectModel.fromJson)
          .toList();

      // Tasks
      final rawTasks = decoded['tasks'] as List<dynamic>? ?? [];
      _tasks = rawTasks
          .whereType<Map<String, dynamic>>()
          .map(TaskModel.fromJson)
          .toList();

      // Comments
      final rawComments = decoded['comments'] as List<dynamic>? ?? [];
      _comments = rawComments
          .whereType<Map<String, dynamic>>()
          .map(CommentModel.fromJson)
          .toList();

      // Notifications
      final rawNotifications = decoded['notifications'] as List<dynamic>? ?? [];
      _notifications = rawNotifications
          .whereType<Map<String, dynamic>>()
          .map(NotificationModel.fromJson)
          .toList();

      // Auth Mock (Test credentials & Login response)
      final authMock = decoded['auth_mock'] as Map<String, dynamic>? ?? {};
      final rawCredentials =
          authMock['test_credentials'] as List<dynamic>? ?? [];
      _authCredentials = rawCredentials
          .whereType<Map<String, dynamic>>()
          .map(AuthCredentialsModel.fromJson)
          .toList();

      final rawLoginResponse =
          authMock['mock_login_response'] as Map<String, dynamic>?;
      if (rawLoginResponse != null) {
        _mockLoginResponse = MockLoginResponseModel.fromJson(rawLoginResponse);
      } else {
        _mockLoginResponse = const MockLoginResponseModel(
          accessToken: '',
          refreshToken: '',
          accessTokenExpiresInSeconds: 0,
          refreshTokenExpiresInSeconds: 0,
        );
      }

      _isLoaded = true;
    } on AppException {
      rethrow;
    } catch (e) {
      throw CacheException(
        message: 'Failed to load or parse mock data asset from $assetPath: $e',
      );
    }
  }

  Future<List<OrganizationModel>> getOrganizations() async {
    if (!_isLoaded) await loadMockData();
    return _organizations;
  }

  Future<List<UserModel>> getUsers() async {
    if (!_isLoaded) await loadMockData();
    return _users;
  }

  Future<List<OrgMemberModel>> getOrgMembers() async {
    if (!_isLoaded) await loadMockData();
    return _orgMembers;
  }

  Future<List<ProjectModel>> getProjects() async {
    if (!_isLoaded) await loadMockData();
    return _projects;
  }

  Future<List<TaskModel>> getTasks() async {
    if (!_isLoaded) await loadMockData();
    return _tasks;
  }

  Future<List<CommentModel>> getComments() async {
    if (!_isLoaded) await loadMockData();
    return _comments;
  }

  Future<List<NotificationModel>> getNotifications() async {
    if (!_isLoaded) await loadMockData();
    return _notifications;
  }

  Future<List<AuthCredentialsModel>> getAuthCredentials() async {
    if (!_isLoaded) await loadMockData();
    return _authCredentials;
  }

  Future<MockLoginResponseModel> getMockLoginResponse() async {
    if (!_isLoaded) await loadMockData();
    return _mockLoginResponse ??
        const MockLoginResponseModel(
          accessToken: '',
          refreshToken: '',
          accessTokenExpiresInSeconds: 0,
          refreshTokenExpiresInSeconds: 0,
        );
  }

  // --- Mutation Methods (In-Memory Only) ---

  Future<ProjectModel> createProject(ProjectModel project) async {
    if (!_isLoaded) await loadMockData();
    _projects = List.from(_projects)..add(project);
    return project;
  }

  Future<ProjectModel> updateProject(ProjectModel project) async {
    if (!_isLoaded) await loadMockData();
    final index = _projects.indexWhere((p) => p.id == project.id);
    if (index == -1) {
      throw const ServerException(message: 'Project not found');
    }
    _projects = List.from(_projects)..[index] = project;
    return project;
  }

  Future<void> deleteProject(String id) async {
    if (!_isLoaded) await loadMockData();
    final index = _projects.indexWhere((p) => p.id == id);
    if (index == -1) {
      throw const ServerException(message: 'Project not found');
    }
    _projects = List.from(_projects)..removeAt(index);
  }

  Future<TaskModel> createTask(TaskModel task) async {
    if (!_isLoaded) await loadMockData();
    _tasks = List.from(_tasks)..add(task);
    return task;
  }

  Future<TaskModel> updateTask(TaskModel task) async {
    if (!_isLoaded) await loadMockData();
    final index = _tasks.indexWhere((t) => t.id == task.id);
    if (index == -1) {
      throw const ServerException(message: 'Task not found');
    }
    _tasks = List.from(_tasks)..[index] = task;
    return task;
  }

  Future<void> deleteTask(String id) async {
    if (!_isLoaded) await loadMockData();
    final index = _tasks.indexWhere((t) => t.id == id);
    if (index == -1) {
      throw const ServerException(message: 'Task not found');
    }
    _tasks = List.from(_tasks)..removeAt(index);
  }
}
