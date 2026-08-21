/// Contract for project data operations
abstract interface class ProjectRepository {
  /// Fetch all projects (or by organization)
  Future<List<Map<String, dynamic>>> getProjects();

  /// Fetch a specific project by id
  Future<Map<String, dynamic>?> getProjectById(String id);
}
