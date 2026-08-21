import '../../../domain/repositories/task_repository.dart';
import '../datasources/local/taskflow_local_data_source.dart';

/// Implementation of [TaskRepository]
class TaskRepositoryImpl implements TaskRepository {
  const TaskRepositoryImpl({
    required TaskFlowLocalDataSource localDataSource,
  }) : _localDataSource = localDataSource;

  final TaskFlowLocalDataSource _localDataSource;

  @override
  Future<List<Map<String, dynamic>>> getTasks() async {
    final rawList = await _localDataSource.getCollection('tasks');
    return rawList.whereType<Map<String, dynamic>>().toList();
  }

  @override
  Future<Map<String, dynamic>?> getTaskById(String id) async {
    final tasks = await getTasks();
    for (final task in tasks) {
      if (task['id'] == id) {
        return task;
      }
    }
    return null;
  }
}
