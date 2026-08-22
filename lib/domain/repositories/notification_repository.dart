import '../entities/app_notification.dart';

/// Contract for notification operations
abstract interface class NotificationRepository {
  /// Fetch all notifications
  Future<List<AppNotification>> getNotifications();

  /// Fetch notifications for a specific user ID
  Future<List<AppNotification>> getNotificationsByUserId(String userId);
}
