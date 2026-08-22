import '../../domain/entities/enums.dart';
import '../../domain/entities/task.dart';

/// Data model for [Task]
class TaskModel extends Task {
  const TaskModel({
    required super.id,
    required super.projectId,
    required super.title,
    required super.description,
    required super.status,
    required super.priority,
    super.assigneeId,
    super.dueDate,
    required super.createdAt,
  });

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    DateTime? parsedDueDate;
    if (json['due_date'] != null) {
      parsedDueDate = DateTime.tryParse(json['due_date'] as String);
    }

    return TaskModel(
      id: json['id'] as String? ?? '',
      projectId: json['project_id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      status: _parseTaskStatus(json['status'] as String?),
      priority: _parseTaskPriority(json['priority'] as String?),
      assigneeId: json['assignee_id'] as String?,
      dueDate: parsedDueDate,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'project_id': projectId,
      'title': title,
      'description': description,
      'status': _statusToJson(status),
      'priority': _priorityToJson(priority),
      'assignee_id': assigneeId,
      'due_date': dueDate != null
          ? '${dueDate!.year.toString().padLeft(4, '0')}-${dueDate!.month.toString().padLeft(2, '0')}-${dueDate!.day.toString().padLeft(2, '0')}'
          : null,
      'created_at': createdAt.toIso8601String(),
    };
  }

  static TaskStatus _parseTaskStatus(String? value) {
    switch (value) {
      case 'in_progress':
        return TaskStatus.inProgress;
      case 'review':
        return TaskStatus.review;
      case 'done':
        return TaskStatus.done;
      default:
        return TaskStatus.todo;
    }
  }

  static String _statusToJson(TaskStatus status) {
    switch (status) {
      case TaskStatus.inProgress:
        return 'in_progress';
      case TaskStatus.review:
        return 'review';
      case TaskStatus.done:
        return 'done';
      case TaskStatus.todo:
        return 'todo';
    }
  }

  static TaskPriority _parseTaskPriority(String? value) {
    switch (value) {
      case 'low':
        return TaskPriority.low;
      case 'high':
        return TaskPriority.high;
      case 'urgent':
        return TaskPriority.urgent;
      default:
        return TaskPriority.medium;
    }
  }

  static String _priorityToJson(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.low:
        return 'low';
      case TaskPriority.medium:
        return 'medium';
      case TaskPriority.high:
        return 'high';
      case TaskPriority.urgent:
        return 'urgent';
    }
  }
}
