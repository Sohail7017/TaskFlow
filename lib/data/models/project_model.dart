import '../../domain/entities/project.dart';

/// Data model for [Project]
class ProjectModel extends Project {
  const ProjectModel({
    required super.id,
    required super.orgId,
    required super.name,
    required super.description,
    required super.taskCount,
    required super.status,
    required super.createdAt,
  });

  factory ProjectModel.fromJson(Map<String, dynamic> json) {
    return ProjectModel(
      id: json['id'] as String? ?? '',
      orgId: json['org_id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      taskCount: (json['task_count'] as num?)?.toInt() ?? 0,
      status: json['status'] as String? ?? 'active',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'org_id': orgId,
      'name': name,
      'description': description,
      'task_count': taskCount,
      'status': status,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
