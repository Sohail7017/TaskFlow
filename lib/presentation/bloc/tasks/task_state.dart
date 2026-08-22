import 'package:equatable/equatable.dart';
import '../../../domain/entities/task.dart';
import '../../../domain/entities/enums.dart';

enum TaskStatusEnum {
  initial,
  loading,
  success,
  empty,
  error,
}

class TaskState extends Equatable {
  const TaskState({
    this.status = TaskStatusEnum.initial,
    this.tasks = const [],
    this.selectedTask,
    this.errorMessage,
    this.filterStatus,
    this.filterPriority,
    this.filterAssigneeId,
    this.filterStartDate,
    this.filterEndDate,
  });

  final TaskStatusEnum status;
  final List<Task> tasks;
  final Task? selectedTask;
  final String? errorMessage;

  // Filters
  final TaskStatus? filterStatus;
  final TaskPriority? filterPriority;
  final String? filterAssigneeId;
  final DateTime? filterStartDate;
  final DateTime? filterEndDate;

  TaskState copyWith({
    TaskStatusEnum? status,
    List<Task>? tasks,
    Task? selectedTask,
    String? errorMessage,
    TaskStatus? filterStatus,
    TaskPriority? filterPriority,
    String? filterAssigneeId,
    DateTime? filterStartDate,
    DateTime? filterEndDate,
    bool clearStatus = false,
    bool clearPriority = false,
    bool clearAssignee = false,
    bool clearDates = false,
  }) {
    return TaskState(
      status: status ?? this.status,
      tasks: tasks ?? this.tasks,
      selectedTask: selectedTask ?? this.selectedTask,
      errorMessage: errorMessage ?? this.errorMessage,
      filterStatus: clearStatus ? null : (filterStatus ?? this.filterStatus),
      filterPriority: clearPriority ? null : (filterPriority ?? this.filterPriority),
      filterAssigneeId: clearAssignee ? null : (filterAssigneeId ?? this.filterAssigneeId),
      filterStartDate: clearDates ? null : (filterStartDate ?? this.filterStartDate),
      filterEndDate: clearDates ? null : (filterEndDate ?? this.filterEndDate),
    );
  }

  @override
  List<Object?> get props => [
        status,
        tasks,
        selectedTask,
        errorMessage,
        filterStatus,
        filterPriority,
        filterAssigneeId,
        filterStartDate,
        filterEndDate,
      ];
}
