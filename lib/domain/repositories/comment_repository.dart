import '../entities/comment.dart';

/// Contract for task comment operations
abstract interface class CommentRepository {
  /// Fetch all comments
  Future<List<Comment>> getComments();

  /// Fetch comments belonging to a specific task ID
  Future<List<Comment>> getCommentsByTaskId(String taskId);
}
