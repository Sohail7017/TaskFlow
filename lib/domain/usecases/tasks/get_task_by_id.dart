import '../../entities/task.dart';
import '../../repositories/task_repository.dart';

/// UseCase to get a single task by ID
class GetTaskById {
  const GetTaskById(this.repository);

  final TaskRepository repository;

  Future<Task?> call(String id) {
    return repository.getTaskById(id);
  }
}
