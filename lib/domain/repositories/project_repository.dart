import '../entities/project.dart';

/// Contract for project data operations
abstract interface class ProjectRepository {
  /// Fetch all projects
  Future<List<Project>> getProjects();

  /// Fetch a specific project by ID
  Future<Project?> getProjectById(String id);

  /// Fetch projects belonging to a specific organization
  Future<List<Project>> getProjectsByOrgId(String orgId);

  /// Create a new project
  Future<Project> createProject(Project project);

  /// Update an existing project
  Future<Project> updateProject(Project project);

  /// Delete a project by ID
  Future<void> deleteProject(String id);
}
