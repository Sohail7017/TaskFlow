import '../../domain/entities/app_notification.dart';
import '../../domain/repositories/notification_repository.dart';
import '../datasources/mock_data_source.dart';

/// Concrete implementation of [NotificationRepository] backed by [MockDataSource]
class NotificationRepositoryImpl implements NotificationRepository {
  const NotificationRepositoryImpl({
    required this.mockDataSource,
  });

  final MockDataSource mockDataSource;

  @override
  Future<List<AppNotification>> getNotifications() async {
    return mockDataSource.getNotifications();
  }

  @override
  Future<List<AppNotification>> getNotificationsByUserId(String userId) async {
    final notifications = await mockDataSource.getNotifications();
    return notifications.where((n) => n.userId == userId).toList();
  }
}
