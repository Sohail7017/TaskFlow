import 'package:equatable/equatable.dart';
import '../../../domain/entities/project.dart';

enum ProjectStatus {
  initial,
  loading,
  success,
  empty,
  error,
}

class ProjectState extends Equatable {
  final ProjectStatus status;
  final List<Project> projects;
  final Project? selectedProject;
  final String? errorMessage;

  const ProjectState({
    this.status = ProjectStatus.initial,
    this.projects = const [],
    this.selectedProject,
    this.errorMessage,
  });

  ProjectState copyWith({
    ProjectStatus? status,
    List<Project>? projects,
    Project? selectedProject,
    String? errorMessage,
  }) {
    return ProjectState(
      status: status ?? this.status,
      projects: projects ?? this.projects,
      selectedProject: selectedProject ?? this.selectedProject,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, projects, selectedProject, errorMessage];
}
