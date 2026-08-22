import '../../core/errors/exceptions.dart';
import '../../domain/entities/task.dart';
import '../../domain/repositories/task_repository.dart';
import '../datasources/mock_data_source.dart';
import '../models/task_model.dart';

/// Concrete implementation of [TaskRepository] backed by [MockDataSource]
class TaskRepositoryImpl implements TaskRepository {
  const TaskRepositoryImpl({
    required this.mockDataSource,
  });

  final MockDataSource mockDataSource;

  @override
  Future<List<Task>> getTasks() async {
    return mockDataSource.getTasks();
  }

  @override
  Future<Task?> getTaskById(String id) async {
    final tasks = await mockDataSource.getTasks();
    final task = tasks.where((t) => t.id == id).firstOrNull;

    // Simulated Error: Specific ID triggers Not Found
    if (id == 'simulated-task-error-id') {
      throw const ServerException(message: 'Task not found (Simulated Error)');
    }

    return task;
  }

  @override
  Future<List<Task>> getTasksByProjectId(String projectId) async {
    final tasks = await mockDataSource.getTasks();
    return tasks.where((t) => t.projectId == projectId).toList();
  }

  @override
  Future<Task> createTask(Task task) async {
    final model = TaskModel(
      id: task.id,
      projectId: task.projectId,
      title: task.title,
      description: task.description,
      status: task.status,
      priority: task.priority,
      assigneeId: task.assigneeId,
      dueDate: task.dueDate,
      createdAt: task.createdAt,
    );
    return mockDataSource.createTask(model);
  }

  @override
  Future<Task> updateTask(Task task) async {
    final model = TaskModel(
      id: task.id,
      projectId: task.projectId,
      title: task.title,
      description: task.description,
      status: task.status,
      priority: task.priority,
      assigneeId: task.assigneeId,
      dueDate: task.dueDate,
      createdAt: task.createdAt,
    );
    return mockDataSource.updateTask(model);
  }

  @override
  Future<void> deleteTask(String id) async {
    return mockDataSource.deleteTask(id);
  }
}
