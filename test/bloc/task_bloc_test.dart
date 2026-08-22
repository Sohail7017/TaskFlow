import 'package:flutter_test/flutter_test.dart';
import 'package:task_flow/domain/entities/task.dart';
import 'package:task_flow/domain/entities/project.dart';
import 'package:task_flow/domain/entities/enums.dart';
import 'package:task_flow/domain/entities/user.dart';
import 'package:task_flow/domain/entities/org_member.dart';
import 'package:task_flow/domain/entities/mock_login_response.dart';
import 'package:task_flow/domain/entities/auth_credentials.dart';
import 'package:task_flow/domain/repositories/auth_repository.dart';
import 'package:task_flow/domain/repositories/project_repository.dart';
import 'package:task_flow/domain/repositories/task_repository.dart';
import 'package:task_flow/domain/repositories/user_repository.dart';
import 'package:task_flow/presentation/bloc/tasks/task_bloc.dart';
import 'package:task_flow/presentation/bloc/tasks/task_event.dart';
import 'package:task_flow/presentation/bloc/tasks/task_state.dart';

class FakeTaskRepository implements TaskRepository {
  List<Task> tasks = [];

  @override
  Future<List<Task>> getTasks() async => tasks;

  @override
  Future<Task?> getTaskById(String id) async =>
      tasks.where((t) => t.id == id).firstOrNull;

  @override
  Future<List<Task>> getTasksByProjectId(String projectId) async =>
      tasks.where((t) => t.projectId == projectId).toList();

  @override
  Future<Task> createTask(Task task) async {
    tasks.add(task);
    return task;
  }

  @override
  Future<Task> updateTask(Task task) async {
    final index = tasks.indexWhere((t) => t.id == task.id);
    if (index != -1) tasks[index] = task;
    return task;
  }

  @override
  Future<void> deleteTask(String id) async {
    tasks.removeWhere((t) => t.id == id);
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

class FakeProjectRepository implements ProjectRepository {
  @override
  Future<List<Project>> getProjects() async => [];
  @override
  Future<Project?> getProjectById(String id) async {
    if (id == 'proj_123') {
      return Project(id: 'proj_123', orgId: 'org_123', name: 'Proj', description: '', taskCount: 0, status: 'active', createdAt: DateTime.now());
    }
    return null;
  }
  @override
  Future<List<Project>> getProjectsByOrgId(String orgId) async => [];
  @override
  Future<Project> createProject(Project project) async => project;
  @override
  Future<Project> updateProject(Project project) async => project;
  @override
  Future<void> deleteProject(String id) async {}
}

class FakeUserRepository implements UserRepository {
  @override
  Future<List<User>> getUsers() async => [];
  @override
  Future<User?> getUserById(String id) async => null;
  @override
  Future<List<OrgMember>> getOrgMembers() async => [];
  @override
  Future<List<OrgMember>> getMembersByOrgId(String orgId) async {
    if (orgId == 'org_123') {
      return [OrgMember(orgId: 'org_123', userId: 'user_123', role: OrgRole.member)];
    }
    return [];
  }
  @override
  Future<List<User>> getUsersByOrgId(String orgId) async => [];
}

void main() {
  late FakeTaskRepository taskRepository;
  late FakeAuthRepository authRepository;
  late FakeProjectRepository projectRepository;
  late FakeUserRepository userRepository;
  late TaskBloc taskBloc;

  setUp(() {
    taskRepository = FakeTaskRepository();
    authRepository = FakeAuthRepository();
    projectRepository = FakeProjectRepository();
    userRepository = FakeUserRepository();
    taskBloc = TaskBloc(
      taskRepository: taskRepository,
      authRepository: authRepository,
      projectRepository: projectRepository,
      userRepository: userRepository,
    );
  });

  group('TaskBloc', () {
    test('initial state is correct', () {
      expect(taskBloc.state, const TaskState());
    });

    test('emits [loading, success] when tasks are loaded', () async {
      final task = Task(
        id: '1',
        projectId: 'proj_123',
        title: 'Task 1',
        description: 'Desc',
        status: TaskStatus.todo,
        priority: TaskPriority.medium,
        createdAt: DateTime.now(),
      );
      taskRepository.tasks = [task];

      final expected = [
        const TaskState(status: TaskStatusEnum.loading),
        TaskState(status: TaskStatusEnum.success, tasks: [task]),
      ];

      expectLater(taskBloc.stream, emitsInOrder(expected));
      taskBloc.add(const LoadTasks());
    });

    test('emits [loading, success] when task is created', () async {
      taskBloc.add(const CreateTask(
        projectId: 'proj_123',
        title: 'New Task',
        description: 'Desc',
        status: TaskStatus.todo,
        priority: TaskPriority.medium,
      ));

      await expectLater(
        taskBloc.stream,
        emitsThrough(const TaskState(status: TaskStatusEnum.success)),
      );
    });

    test('emits [error] when user from another org is assigned', () async {
      taskBloc.add(const CreateTask(
        projectId: 'proj_123',
        title: 'New Task',
        description: 'Desc',
        status: TaskStatus.todo,
        priority: TaskPriority.medium,
        assigneeId: 'user_999', // Not in org_123
      ));

      await expectLater(
        taskBloc.stream,
        emitsThrough(predicate((TaskState state) => 
          state.status == TaskStatusEnum.error && 
          state.errorMessage == 'This user does not belong to your organization.')),
      );
    });
  });
}
