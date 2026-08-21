/// Contract for task data operations
abstract interface class TaskRepository {
  /// Fetch all tasks (or filtered by project/assignee)
  Future<List<Map<String, dynamic>>> getTasks();

  /// Fetch a specific task by id
  Future<Map<String, dynamic>?> getTaskById(String id);
}
