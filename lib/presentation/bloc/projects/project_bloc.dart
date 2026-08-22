import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/errors/exceptions.dart';
import '../../../domain/entities/project.dart';
import '../../../domain/repositories/auth_repository.dart';
import '../../../domain/repositories/project_repository.dart';
import 'project_event.dart';
import 'project_state.dart';

class ProjectBloc extends Bloc<ProjectEvent, ProjectState> {
  ProjectBloc({
    required this.projectRepository,
    required this.authRepository,
  }) : super(const ProjectState()) {
    on<LoadProjects>(_onLoadProjects);
    on<RefreshProjects>(_onRefreshProjects);
    on<LoadProjectDetails>(_onLoadProjectDetails);
    on<CreateProject>(_onCreateProject);
    on<UpdateProject>(_onUpdateProject);
    on<DeleteProject>(_onDeleteProject);
  }

  final ProjectRepository projectRepository;
  final AuthRepository authRepository;

  Future<void> _onLoadProjects(
    LoadProjects event,
    Emitter<ProjectState> emit,
  ) async {
    emit(state.copyWith(status: ProjectStatus.loading));
    await _fetchProjects(emit);
  }

  Future<void> _onRefreshProjects(
    RefreshProjects event,
    Emitter<ProjectState> emit,
  ) async {
    await _fetchProjects(emit);
  }

  Future<void> _fetchProjects(Emitter<ProjectState> emit) async {
    try {
      final orgId = await authRepository.getOrgId();
      if (orgId == null) {
        emit(state.copyWith(
          status: ProjectStatus.error,
          errorMessage: 'Organization session not found.',
        ));
        return;
      }

      final projects = await projectRepository.getProjectsByOrgId(orgId);
      if (projects.isEmpty) {
        emit(state.copyWith(status: ProjectStatus.empty, projects: []));
      } else {
        emit(state.copyWith(status: ProjectStatus.success, projects: projects));
      }
    } on AppException catch (e) {
      emit(state.copyWith(status: ProjectStatus.error, errorMessage: e.message));
    } catch (_) {
      emit(state.copyWith(
        status: ProjectStatus.error,
        errorMessage: 'Unable to load projects.',
      ));
    }
  }

  Future<void> _onLoadProjectDetails(
    LoadProjectDetails event,
    Emitter<ProjectState> emit,
  ) async {
    emit(state.copyWith(status: ProjectStatus.loading));
    try {
      final project = await projectRepository.getProjectById(event.projectId);
      if (project == null) {
        emit(state.copyWith(
          status: ProjectStatus.error,
          errorMessage: 'Project not found.',
        ));
      } else {
        emit(state.copyWith(status: ProjectStatus.success, selectedProject: project));
      }
    } on AppException catch (e) {
      emit(state.copyWith(status: ProjectStatus.error, errorMessage: e.message));
    } catch (_) {
      emit(state.copyWith(
        status: ProjectStatus.error,
        errorMessage: 'Unable to load project details.',
      ));
    }
  }

  Future<void> _onCreateProject(
    CreateProject event,
    Emitter<ProjectState> emit,
  ) async {
    emit(state.copyWith(status: ProjectStatus.loading));
    try {
      final orgId = await authRepository.getOrgId();
      if (orgId == null) throw const AuthenticationException(message: 'Session expired.');

      final newProject = Project(
        id: 'proj_${DateTime.now().millisecondsSinceEpoch}',
        orgId: orgId,
        name: event.name,
        description: event.description,
        taskCount: 0,
        status: 'active',
        createdAt: DateTime.now(),
      );

      await projectRepository.createProject(newProject);
      emit(state.copyWith(status: ProjectStatus.success));
      add(const LoadProjects());
    } on AppException catch (e) {
      emit(state.copyWith(status: ProjectStatus.error, errorMessage: e.message));
    } catch (_) {
      emit(state.copyWith(
        status: ProjectStatus.error,
        errorMessage: 'Unable to create project.',
      ));
    }
  }

  Future<void> _onUpdateProject(
    UpdateProject event,
    Emitter<ProjectState> emit,
  ) async {
    emit(state.copyWith(status: ProjectStatus.loading));
    try {
      await projectRepository.updateProject(event.project);
      emit(state.copyWith(status: ProjectStatus.success));
      add(const LoadProjects());
    } on AppException catch (e) {
      emit(state.copyWith(status: ProjectStatus.error, errorMessage: e.message));
    } catch (_) {
      emit(state.copyWith(
        status: ProjectStatus.error,
        errorMessage: 'Unable to update project.',
      ));
    }
  }

  Future<void> _onDeleteProject(
    DeleteProject event,
    Emitter<ProjectState> emit,
  ) async {
    emit(state.copyWith(status: ProjectStatus.loading));
    try {
      await projectRepository.deleteProject(event.projectId);
      emit(state.copyWith(status: ProjectStatus.success));
      add(const LoadProjects());
    } on AppException catch (e) {
      emit(state.copyWith(status: ProjectStatus.error, errorMessage: e.message));
    } catch (_) {
      emit(state.copyWith(
        status: ProjectStatus.error,
        errorMessage: 'Unable to delete project.',
      ));
    }
  }
}
