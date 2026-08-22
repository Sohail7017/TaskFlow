import 'package:equatable/equatable.dart';
import '../../../domain/entities/task.dart';
import '../../../domain/entities/enums.dart';

abstract class TaskEvent extends Equatable {
  const TaskEvent();

  @override
  List<Object?> get props => [];
}

class LoadTasks extends TaskEvent {
  const LoadTasks({this.projectId});
  final String? projectId;

  @override
  List<Object?> get props => [projectId];
}

class RefreshTasks extends TaskEvent {
  const RefreshTasks({this.projectId});
  final String? projectId;

  @override
  List<Object?> get props => [projectId];
}

class LoadTaskDetails extends TaskEvent {
  const LoadTaskDetails(this.taskId);
  final String taskId;

  @override
  List<Object?> get props => [taskId];
}

class CreateTask extends TaskEvent {
  const CreateTask({
    required this.projectId,
    required this.title,
    required this.description,
    required this.status,
    required this.priority,
    this.assigneeId,
    this.dueDate,
  });

  final String projectId;
  final String title;
  final String description;
  final TaskStatus status;
  final TaskPriority priority;
  final String? assigneeId;
  final DateTime? dueDate;

  @override
  List<Object?> get props => [
        projectId,
        title,
        description,
        status,
        priority,
        assigneeId,
        dueDate,
      ];
}

class UpdateTask extends TaskEvent {
  const UpdateTask(this.task);
  final Task task;

  @override
  List<Object?> get props => [task];
}

class DeleteTask extends TaskEvent {
  const DeleteTask(this.taskId);
  final String taskId;

  @override
  List<Object?> get props => [taskId];
}

class UpdateTaskStatus extends TaskEvent {
  const UpdateTaskStatus({required this.taskId, required this.status});
  final String taskId;
  final TaskStatus status;

  @override
  List<Object?> get props => [taskId, status];
}

class UpdateTaskPriority extends TaskEvent {
  const UpdateTaskPriority({required this.taskId, required this.priority});
  final String taskId;
  final TaskPriority priority;

  @override
  List<Object?> get props => [taskId, priority];
}

class AssignTask extends TaskEvent {
  const AssignTask({required this.taskId, required this.userId});
  final String taskId;
  final String userId;

  @override
  List<Object?> get props => [taskId, userId];
}

class UnassignTask extends TaskEvent {
  const UnassignTask(this.taskId);
  final String taskId;

  @override
  List<Object?> get props => [taskId];
}

class ApplyTaskFilters extends TaskEvent {
  const ApplyTaskFilters({
    this.status,
    this.priority,
    this.assigneeId,
    this.startDate,
    this.endDate,
  });

  final TaskStatus? status;
  final TaskPriority? priority;
  final String? assigneeId;
  final DateTime? startDate;
  final DateTime? endDate;

  @override
  List<Object?> get props => [status, priority, assigneeId, startDate, endDate];
}

class ClearTaskFilters extends TaskEvent {
  const ClearTaskFilters();
}
