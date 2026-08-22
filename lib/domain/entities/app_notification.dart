/// Notification domain entity
class AppNotification {
  const AppNotification({
    required this.id,
    required this.userId,
    required this.type,
    required this.taskId,
    required this.message,
    required this.read,
    required this.createdAt,
  });

  final String id;
  final String userId;
  final String type;
  final String taskId;
  final String message;
  final bool read;
  final DateTime createdAt;
}
