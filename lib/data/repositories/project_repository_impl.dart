import '../../core/errors/exceptions.dart';
import '../../domain/entities/enums.dart';
import '../../domain/entities/project.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/project_repository.dart';
import '../datasources/mock_data_source.dart';
import '../models/project_model.dart';

/// Concrete implementation of [ProjectRepository] backed by [MockDataSource].
/// Includes organization scoping and admin authorization for deletions.
class ProjectRepositoryImpl implements ProjectRepository {
  const ProjectRepositoryImpl({
    required this.mockDataSource,
    required this.authRepository,
  });

  final MockDataSource mockDataSource;
  final AuthRepository authRepository;

  @override
  Future<List<Project>> getProjects() async {
    return mockDataSource.getProjects();
  }

  @override
  Future<Project?> getProjectById(String id) async {
    final projects = await mockDataSource.getProjects();
    final project = projects.where((p) => p.id == id).firstOrNull;
    
    // Simulated Error: Specific ID triggers Not Found
    if (id == 'simulated-error-id') {
      throw const ServerException(message: 'Project not found (Simulated Error)');
    }
    
    return project;
  }

  @override
  Future<List<Project>> getProjectsByOrgId(String orgId) async {
    final projects = await mockDataSource.getProjects();
    return projects.where((p) => p.orgId == orgId).toList();
  }

  @override
  Future<Project> createProject(Project project) async {
    // Simulated Error: Specific name triggers error
    if (project.name.toLowerCase() == 'error') {
      throw const ServerException(message: 'Unable to create project (Simulated Error)');
    }

    final model = ProjectModel(
      id: project.id,
      orgId: project.orgId,
      name: project.name,
      description: project.description,
      taskCount: project.taskCount,
      status: project.status,
      createdAt: project.createdAt,
    );
    return mockDataSource.createProject(model);
  }

  @override
  Future<Project> updateProject(Project project) async {
    final model = ProjectModel(
      id: project.id,
      orgId: project.orgId,
      name: project.name,
      description: project.description,
      taskCount: project.taskCount,
      status: project.status,
      createdAt: project.createdAt,
    );
    return mockDataSource.updateProject(model);
  }

  @override
  Future<void> deleteProject(String id) async {
    // Authorization Check
    final role = await authRepository.getUserRole();
    if (role != OrgRole.orgAdmin) {
      throw const AuthenticationException(
        message: 'You do not have permission to delete this project.',
      );
    }

    return mockDataSource.deleteProject(id);
  }
}
