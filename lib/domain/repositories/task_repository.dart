import '../entities/task.dart';

/// Contract for task data operations
abstract interface class TaskRepository {
  /// Fetch all tasks
  Future<List<Task>> getTasks();

  /// Fetch a specific task by ID
  Future<Task?> getTaskById(String id);

  /// Fetch tasks associated with a specific project ID
  Future<List<Task>> getTasksByProjectId(String projectId);

  /// Create a new task
  Future<Task> createTask(Task task);

  /// Update an existing task
  Future<Task> updateTask(Task task);

  /// Delete a task by ID
  Future<void> deleteTask(String id);
}
