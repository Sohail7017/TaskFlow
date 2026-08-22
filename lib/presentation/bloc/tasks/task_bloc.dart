import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/errors/exceptions.dart';
import '../../../domain/entities/task.dart';
import '../../../domain/repositories/auth_repository.dart';
import '../../../domain/repositories/project_repository.dart';
import '../../../domain/repositories/task_repository.dart';
import '../../../domain/repositories/user_repository.dart';
import 'task_event.dart';
import 'task_state.dart';

class TaskBloc extends Bloc<TaskEvent, TaskState> {
  TaskBloc({
    required this.taskRepository,
    required this.authRepository,
    required this.projectRepository,
    required this.userRepository,
  }) : super(const TaskState()) {
    on<LoadTasks>(_onLoadTasks);
    on<RefreshTasks>(_onRefreshTasks);
    on<LoadTaskDetails>(_onLoadTaskDetails);
    on<CreateTask>(_onCreateTask);
    on<UpdateTask>(_onUpdateTask);
    on<DeleteTask>(_onDeleteTask);
    on<UpdateTaskStatus>(_onUpdateTaskStatus);
    on<UpdateTaskPriority>(_onUpdateTaskPriority);
    on<AssignTask>(_onAssignTask);
    on<UnassignTask>(_onUnassignTask);
    on<ApplyTaskFilters>(_onApplyTaskFilters);
    on<ClearTaskFilters>(_onClearTaskFilters);
  }

  final TaskRepository taskRepository;
  final AuthRepository authRepository;
  final ProjectRepository projectRepository;
  final UserRepository userRepository;

  Future<void> _onLoadTasks(
    LoadTasks event,
    Emitter<TaskState> emit,
  ) async {
    emit(state.copyWith(status: TaskStatusEnum.loading));
    await _fetchTasks(emit, event.projectId);
  }

  Future<void> _onRefreshTasks(
    RefreshTasks event,
    Emitter<TaskState> emit,
  ) async {
    await _fetchTasks(emit, event.projectId);
  }

  Future<void> _fetchTasks(Emitter<TaskState> emit, String? projectId) async {
    try {
      List<Task> tasks;
      if (projectId != null) {
        tasks = await taskRepository.getTasksByProjectId(projectId);
      } else {
        tasks = await taskRepository.getTasks();
      }

      // Apply Filters
      final filteredTasks = _applyFilters(tasks);

      if (filteredTasks.isEmpty) {
        emit(state.copyWith(status: TaskStatusEnum.empty, tasks: []));
      } else {
        emit(state.copyWith(status: TaskStatusEnum.success, tasks: filteredTasks));
      }
    } on AppException catch (e) {
      emit(state.copyWith(status: TaskStatusEnum.error, errorMessage: e.message));
    } catch (_) {
      emit(state.copyWith(
        status: TaskStatusEnum.error,
        errorMessage: 'Unable to load tasks.',
      ));
    }
  }

  List<Task> _applyFilters(List<Task> tasks) {
    var filtered = tasks;
    if (state.filterStatus != null) {
      filtered = filtered.where((t) => t.status == state.filterStatus).toList();
    }
    if (state.filterPriority != null) {
      filtered = filtered.where((t) => t.priority == state.filterPriority).toList();
    }
    if (state.filterAssigneeId != null) {
      filtered = filtered.where((t) => t.assigneeId == state.filterAssigneeId).toList();
    }
    if (state.filterStartDate != null) {
      filtered = filtered.where((t) => t.dueDate != null && t.dueDate!.isAfter(state.filterStartDate!)).toList();
    }
    if (state.filterEndDate != null) {
      filtered = filtered.where((t) => t.dueDate != null && t.dueDate!.isBefore(state.filterEndDate!)).toList();
    }
    return filtered;
  }

  Future<void> _onLoadTaskDetails(
    LoadTaskDetails event,
    Emitter<TaskState> emit,
  ) async {
    emit(state.copyWith(status: TaskStatusEnum.loading));
    try {
      final task = await taskRepository.getTaskById(event.taskId);
      if (task == null) {
        emit(state.copyWith(status: TaskStatusEnum.error, errorMessage: 'Task not found.'));
      } else {
        emit(state.copyWith(status: TaskStatusEnum.success, selectedTask: task));
      }
    } on AppException catch (e) {
      emit(state.copyWith(status: TaskStatusEnum.error, errorMessage: e.message));
    } catch (_) {
      emit(state.copyWith(
        status: TaskStatusEnum.error,
        errorMessage: 'Unable to load task details.',
      ));
    }
  }

  Future<void> _onCreateTask(
    CreateTask event,
    Emitter<TaskState> emit,
  ) async {
    emit(state.copyWith(status: TaskStatusEnum.loading));
    try {
      // Validation: Organization consistency
      final orgId = await authRepository.getOrgId();
      final project = await projectRepository.getProjectById(event.projectId);
      if (project == null || project.orgId != orgId) {
        throw const ValidationException(message: 'This project does not belong to your organization.');
      }

      // Validation: Assignee organization
      if (event.assigneeId != null) {
        final members = await userRepository.getMembersByOrgId(orgId!);
        if (!members.any((m) => m.userId == event.assigneeId)) {
          throw const ValidationException(message: 'This user does not belong to your organization.');
        }
      }

      final newTask = Task(
        id: 'task_${DateTime.now().millisecondsSinceEpoch}',
        projectId: event.projectId,
        title: event.title,
        description: event.description,
        status: event.status,
        priority: event.priority,
        assigneeId: event.assigneeId,
        dueDate: event.dueDate,
        createdAt: DateTime.now(),
      );

      await taskRepository.createTask(newTask);
      emit(state.copyWith(status: TaskStatusEnum.success));
    } on AppException catch (e) {
      emit(state.copyWith(status: TaskStatusEnum.error, errorMessage: e.message));
    } catch (_) {
      emit(state.copyWith(status: TaskStatusEnum.error, errorMessage: 'Unable to create task.'));
    }
  }

  Future<void> _onUpdateTask(
    UpdateTask event,
    Emitter<TaskState> emit,
  ) async {
    emit(state.copyWith(status: TaskStatusEnum.loading));
    try {
      await taskRepository.updateTask(event.task);
      emit(state.copyWith(status: TaskStatusEnum.success, selectedTask: event.task));
    } on AppException catch (e) {
      emit(state.copyWith(status: TaskStatusEnum.error, errorMessage: e.message));
    } catch (_) {
      emit(state.copyWith(status: TaskStatusEnum.error, errorMessage: 'Unable to update task.'));
    }
  }

  Future<void> _onDeleteTask(
    DeleteTask event,
    Emitter<TaskState> emit,
  ) async {
    emit(state.copyWith(status: TaskStatusEnum.loading));
    try {
      await taskRepository.deleteTask(event.taskId);
      emit(state.copyWith(status: TaskStatusEnum.success));
    } on AppException catch (e) {
      emit(state.copyWith(status: TaskStatusEnum.error, errorMessage: e.message));
    } catch (_) {
      emit(state.copyWith(status: TaskStatusEnum.error, errorMessage: 'Unable to delete task.'));
    }
  }

  Future<void> _onUpdateTaskStatus(
    UpdateTaskStatus event,
    Emitter<TaskState> emit,
  ) async {
    try {
      final task = await taskRepository.getTaskById(event.taskId);
      if (task != null) {
        final updated = Task(
          id: task.id,
          projectId: task.projectId,
          title: task.title,
          description: task.description,
          status: event.status,
          priority: task.priority,
          assigneeId: task.assigneeId,
          dueDate: task.dueDate,
          createdAt: task.createdAt,
        );
        await taskRepository.updateTask(updated);
        emit(state.copyWith(selectedTask: updated));
      }
    } catch (_) {}
  }

  Future<void> _onUpdateTaskPriority(
    UpdateTaskPriority event,
    Emitter<TaskState> emit,
  ) async {
    try {
      final task = await taskRepository.getTaskById(event.taskId);
      if (task != null) {
        final updated = Task(
          id: task.id,
          projectId: task.projectId,
          title: task.title,
          description: task.description,
          status: task.status,
          priority: event.priority,
          assigneeId: task.assigneeId,
          dueDate: task.dueDate,
          createdAt: task.createdAt,
        );
        await taskRepository.updateTask(updated);
        emit(state.copyWith(selectedTask: updated));
      }
    } catch (_) {}
  }

  Future<void> _onAssignTask(
    AssignTask event,
    Emitter<TaskState> emit,
  ) async {
    try {
      final orgId = await authRepository.getOrgId();
      final members = await userRepository.getMembersByOrgId(orgId!);
      if (!members.any((m) => m.userId == event.userId)) {
        emit(state.copyWith(status: TaskStatusEnum.error, errorMessage: 'This user does not belong to your organization.'));
        return;
      }

      final task = await taskRepository.getTaskById(event.taskId);
      if (task != null) {
        final updated = Task(
          id: task.id,
          projectId: task.projectId,
          title: task.title,
          description: task.description,
          status: task.status,
          priority: task.priority,
          assigneeId: event.userId,
          dueDate: task.dueDate,
          createdAt: task.createdAt,
        );
        await taskRepository.updateTask(updated);
        emit(state.copyWith(selectedTask: updated));
      }
    } catch (_) {}
  }

  Future<void> _onUnassignTask(
    UnassignTask event,
    Emitter<TaskState> emit,
  ) async {
    try {
      final task = await taskRepository.getTaskById(event.taskId);
      if (task != null) {
        final updated = Task(
          id: task.id,
          projectId: task.projectId,
          title: task.title,
          description: task.description,
          status: task.status,
          priority: task.priority,
          assigneeId: null,
          dueDate: task.dueDate,
          createdAt: task.createdAt,
        );
        await taskRepository.updateTask(updated);
        emit(state.copyWith(selectedTask: updated));
      }
    } catch (_) {}
  }

  void _onApplyTaskFilters(
    ApplyTaskFilters event,
    Emitter<TaskState> emit,
  ) {
    emit(state.copyWith(
      filterStatus: event.status,
      filterPriority: event.priority,
      filterAssigneeId: event.assigneeId,
      filterStartDate: event.startDate,
      filterEndDate: event.endDate,
    ));
    add(const LoadTasks());
  }

  void _onClearTaskFilters(
    ClearTaskFilters event,
    Emitter<TaskState> emit,
  ) {
    emit(state.copyWith(
      clearStatus: true,
      clearPriority: true,
      clearAssignee: true,
      clearDates: true,
    ));
    add(const LoadTasks());
  }
}
