import '../../entities/project.dart';
import '../../repositories/project_repository.dart';

/// UseCase to get a single project by ID
class GetProjectById {
  const GetProjectById(this.repository);

  final ProjectRepository repository;

  Future<Project?> call(String id) {
    return repository.getProjectById(id);
  }
}
