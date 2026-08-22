/// Task comment domain entity
class Comment {
  const Comment({
    required this.id,
    required this.taskId,
    required this.authorId,
    required this.body,
    required this.createdAt,
  });

  final String id;
  final String taskId;
  final String authorId;
  final String body;
  final DateTime createdAt;
}
