import '../../domain/entities/comment.dart';
import '../../domain/repositories/comment_repository.dart';
import '../datasources/mock_data_source.dart';

/// Concrete implementation of [CommentRepository] backed by [MockDataSource]
class CommentRepositoryImpl implements CommentRepository {
  const CommentRepositoryImpl({
    required this.mockDataSource,
  });

  final MockDataSource mockDataSource;

  @override
  Future<List<Comment>> getComments() async {
    return mockDataSource.getComments();
  }

  @override
  Future<List<Comment>> getCommentsByTaskId(String taskId) async {
    final comments = await mockDataSource.getComments();
    return comments.where((c) => c.taskId == taskId).toList();
  }
}
