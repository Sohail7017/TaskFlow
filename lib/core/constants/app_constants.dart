/// Core application constants
abstract final class AppConstants {
  static const String appName = 'TaskFlow';
  static const String appVersion = '1.0.0';

  // Timeouts & Durations
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration splashDuration = Duration(seconds: 2);
}
