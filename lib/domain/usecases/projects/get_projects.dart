import '../../entities/project.dart';
import '../../repositories/project_repository.dart';

/// UseCase to get all projects or projects filtered by organization
class GetProjects {
  const GetProjects(this.repository);

  final ProjectRepository repository;

  Future<List<Project>> call([String? orgId]) {
    if (orgId != null && orgId.isNotEmpty) {
      return repository.getProjectsByOrgId(orgId);
    }
    return repository.getProjects();
  }
}
