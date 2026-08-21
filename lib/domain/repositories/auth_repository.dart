/// Contract for authentication and session management
abstract interface class AuthRepository {
  /// Check if a user is currently authenticated
  Future<bool> isAuthenticated();

  /// Retrieve the current cached auth token, if any
  Future<String?> getAuthToken();

  /// Clear the active session and tokens
  Future<void> logout();
}
