import '../../entities/task.dart';
import '../../repositories/task_repository.dart';

/// UseCase to get tasks for a specific project
class GetTasksByProject {
  const GetTasksByProject(this.repository);

  final TaskRepository repository;

  Future<List<Task>> call(String projectId) {
    return repository.getTasksByProjectId(projectId);
  }
}
