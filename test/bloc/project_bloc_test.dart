import 'package:flutter_test/flutter_test.dart';
import 'package:task_flow/domain/entities/project.dart';
import 'package:task_flow/domain/entities/enums.dart';
import 'package:task_flow/domain/entities/user.dart';
import 'package:task_flow/domain/entities/mock_login_response.dart';
import 'package:task_flow/domain/entities/auth_credentials.dart';
import 'package:task_flow/domain/repositories/auth_repository.dart';
import 'package:task_flow/domain/repositories/project_repository.dart';
import 'package:task_flow/presentation/bloc/projects/project_bloc.dart';
import 'package:task_flow/presentation/bloc/projects/project_event.dart';
import 'package:task_flow/presentation/bloc/projects/project_state.dart';

class FakeProjectRepository implements ProjectRepository {
  List<Project> projects = [];

  @override
  Future<List<Project>> getProjects() async => projects;

  @override
  Future<Project?> getProjectById(String id) async =>
      projects.where((p) => p.id == id).firstOrNull;

  @override
  Future<List<Project>> getProjectsByOrgId(String orgId) async =>
      projects.where((p) => p.orgId == orgId).toList();

  @override
  Future<Project> createProject(Project project) async {
    projects.add(project);
    return project;
  }

  @override
  Future<Project> updateProject(Project project) async {
    final index = projects.indexWhere((p) => p.id == project.id);
    if (index != -1) projects[index] = project;
    return project;
  }

  @override
  Future<void> deleteProject(String id) async {
    projects.removeWhere((p) => p.id == id);
  }
}

class FakeAuthRepository implements AuthRepository {
  @override
  Future<String?> getOrgId() async => 'org_123';
  
  @override
  Future<bool> isAuthenticated() async => true;
  @override
  Future<String?> getAuthToken() async => 'token';
  @override
  Future<User?> getAuthenticatedUser() async => null;
  @override
  Future<OrgRole?> getUserRole() async => OrgRole.orgAdmin;
  @override
  Future<MockLoginResponse> login(String email, String password) async => throw UnimplementedError();
  @override
  Future<MockLoginResponse?> refreshToken(String refreshToken) async => null;
  @override
  Future<List<AuthCredentials>> getTestCredentials() async => [];
  @override
  Future<void> logout() async {}
}

void main() {
  late FakeProjectRepository projectRepository;
  late FakeAuthRepository authRepository;
  late ProjectBloc projectBloc;

  setUp(() {
    projectRepository = FakeProjectRepository();
    authRepository = FakeAuthRepository();
    projectBloc = ProjectBloc(
      projectRepository: projectRepository,
      authRepository: authRepository,
    );
  });

  tearDown(() {
    projectBloc.close();
  });

  group('ProjectBloc', () {
    test('initial state is correct', () {
      expect(projectBloc.state, const ProjectState());
    });

    test('emits [loading, success] when projects are loaded', () async {
      final project = Project(
        id: '1',
        orgId: 'org_123',
        name: 'Project 1',
        description: 'Desc',
        taskCount: 0,
        status: 'active',
        createdAt: DateTime.now(),
      );
      projectRepository.projects = [project];

      final expected = [
        const ProjectState(status: ProjectStatus.loading),
        ProjectState(status: ProjectStatus.success, projects: [project]),
      ];

      expectLater(projectBloc.stream, emitsInOrder(expected));
      projectBloc.add(const LoadProjects());
    });

    test('emits [loading, empty] when no projects are found', () async {
      final expected = [
        const ProjectState(status: ProjectStatus.loading),
        const ProjectState(status: ProjectStatus.empty, projects: []),
      ];

      expectLater(projectBloc.stream, emitsInOrder(expected));
      projectBloc.add(const LoadProjects());
    });

    test('emits [loading, success] then re-loads when project created', () async {
      projectBloc.add(const CreateProject(name: 'New', description: 'Desc'));
      
      await expectLater(
        projectBloc.stream,
        emitsThrough(predicate((ProjectState state) => state.status == ProjectStatus.success)),
      );
    });
  });
}
