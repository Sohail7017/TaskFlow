import 'package:equatable/equatable.dart';
import '../../../domain/entities/project.dart';

abstract class ProjectEvent extends Equatable {
  const ProjectEvent();

  @override
  List<Object?> get props => [];
}

class LoadProjects extends ProjectEvent {
  const LoadProjects();
}

class RefreshProjects extends ProjectEvent {
  const RefreshProjects();
}

class LoadProjectDetails extends ProjectEvent {
  final String projectId;
  const LoadProjectDetails(this.projectId);

  @override
  List<Object?> get props => [projectId];
}

class CreateProject extends ProjectEvent {
  final String name;
  final String description;

  const CreateProject({
    required this.name,
    required this.description,
  });

  @override
  List<Object?> get props => [name, description];
}

class UpdateProject extends ProjectEvent {
  final Project project;

  const UpdateProject(this.project);

  @override
  List<Object?> get props => [project];
}

class DeleteProject extends ProjectEvent {
  final String projectId;

  const DeleteProject(this.projectId);

  @override
  List<Object?> get props => [projectId];
}
