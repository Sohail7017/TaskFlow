import '../../domain/entities/comment.dart';

/// Data model for [Comment] with JSON serialization
class CommentModel extends Comment {
  const CommentModel({
    required super.id,
    required super.taskId,
    required super.authorId,
    required super.body,
    required super.createdAt,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    return CommentModel(
      id: json['id'] as String? ?? '',
      taskId: json['task_id'] as String? ?? '',
      authorId: json['author_id'] as String? ?? '',
      body: json['body'] as String? ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
    );
  }

  factory CommentModel.fromEntity(Comment entity) {
    return CommentModel(
      id: entity.id,
      taskId: entity.taskId,
      authorId: entity.authorId,
      body: entity.body,
      createdAt: entity.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'task_id': taskId,
      'author_id': authorId,
      'body': body,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
