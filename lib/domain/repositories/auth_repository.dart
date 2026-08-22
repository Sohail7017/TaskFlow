import '../entities/enums.dart';
import '../entities/auth_credentials.dart';
import '../entities/mock_login_response.dart';
import '../entities/user.dart';

/// Contract for authentication operations
abstract interface class AuthRepository {
  /// Check if a user is currently authenticated (verifying access/refresh tokens and expiries)
  Future<bool> isAuthenticated();

  /// Retrieve the current cached auth token, if any
  Future<String?> getAuthToken();

  /// Retrieve the current cached org id, if any
  Future<String?> getOrgId();

  /// Retrieve the current cached user profile, if any
  Future<User?> getAuthenticatedUser();

  /// Retrieve the current cached user role, if any
  Future<OrgRole?> getUserRole();

  /// Attempt login with email and password
  Future<MockLoginResponse> login(String email, String password);

  /// Refresh auth token
  Future<MockLoginResponse?> refreshToken(String refreshToken);

  /// Fetch mock test credentials from data source
  Future<List<AuthCredentials>> getTestCredentials();

  /// Clear the active session and tokens
  Future<void> logout();
}
