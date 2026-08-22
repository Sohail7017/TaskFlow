import '../../entities/task.dart';
import '../../repositories/task_repository.dart';

/// UseCase to get all tasks
class GetTasks {
  const GetTasks(this.repository);

  final TaskRepository repository;

  Future<List<Task>> call([String? projectId]) {
    if (projectId != null && projectId.isNotEmpty) {
      return repository.getTasksByProjectId(projectId);
    }
    return repository.getTasks();
  }
}
