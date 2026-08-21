/// Centralized storage key and box definitions for secure and local Hive storage
abstract final class StorageKeys {
  // Hive Box Names
  static const String appBox = 'app_box';
  static const String projectsBox = 'projects_box';
  static const String tasksBox = 'tasks_box';

  // Secure Storage Keys
  static const String accessToken = 'access_token';
  static const String refreshToken = 'refresh_token';
  static const String currentUserId = 'current_user_id';
  static const String currentOrgId = 'current_org_id';
  static const String sessionExpiry = 'session_expiry';

  // Local Hive Cache Keys
  static const String themeMode = 'theme_mode';
  static const String isFirstRun = 'is_first_run';
  static const String lastSyncTimestamp = 'last_sync_timestamp';
  static const String cachedTasksKey = 'cached_tasks';
  static const String cachedProjectsKey = 'cached_projects';
}
