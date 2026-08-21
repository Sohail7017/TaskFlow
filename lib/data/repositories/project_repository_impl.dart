import '../../../domain/repositories/project_repository.dart';
import '../datasources/local/taskflow_local_data_source.dart';

/// Implementation of [ProjectRepository]
class ProjectRepositoryImpl implements ProjectRepository {
  const ProjectRepositoryImpl({
    required TaskFlowLocalDataSource localDataSource,
  }) : _localDataSource = localDataSource;

  final TaskFlowLocalDataSource _localDataSource;

  @override
  Future<List<Map<String, dynamic>>> getProjects() async {
    final rawList = await _localDataSource.getCollection('projects');
    return rawList.whereType<Map<String, dynamic>>().toList();
  }

  @override
  Future<Map<String, dynamic>?> getProjectById(String id) async {
    final projects = await getProjects();
    for (final project in projects) {
      if (project['id'] == id) {
        return project;
      }
    }
    return null;
  }
}
