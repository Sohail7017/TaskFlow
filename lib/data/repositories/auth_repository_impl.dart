import '../../core/errors/exceptions.dart';
import '../../core/storage/secure_storage_service.dart';
import '../../domain/entities/user.dart';
import '../../domain/entities/enums.dart';
import '../../domain/entities/auth_credentials.dart';
import '../../domain/entities/mock_login_response.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/mock_data_source.dart';

/// Concrete implementation of [AuthRepository] managing authentication against [MockDataSource]
/// and securely persisting tokens and session state via [SecureStorageService].
class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl({
    required this.mockDataSource,
    required this.secureStorageService,
  });

  final MockDataSource mockDataSource;
  final SecureStorageService secureStorageService;

  @override
  Future<MockLoginResponse> login(String email, String password) async {
    final trimmedEmail = email.trim().toLowerCase();
    final trimmedPassword = password.trim();

    if (trimmedEmail.isEmpty || trimmedPassword.isEmpty) {
      throw const ValidationException(
        message: 'Please provide both email and password.',
      );
    }

    final credentials = await mockDataSource.getAuthCredentials();
    AuthCredentials? matchedCredential;

    for (final cred in credentials) {
      if (cred.email.toLowerCase() == trimmedEmail && cred.password == trimmedPassword) {
        matchedCredential = cred;
        break;
      }
    }

    if (matchedCredential == null) {
      throw const AuthenticationException(
        message: 'Invalid email or password.',
      );
    }

    // Find user name and ID from users mock data
    final users = await mockDataSource.getUsers();
    final matchedUser = users.firstWhere(
      (u) => u.email.toLowerCase() == trimmedEmail,
      orElse: () => throw const AuthenticationException(message: 'User profile not found.'),
    );

    final response = await mockDataSource.getMockLoginResponse();
    final now = DateTime.now();
    final accessTokenExpiry = now.add(Duration(seconds: response.accessTokenExpiresInSeconds));
    final refreshTokenExpiry = now.add(Duration(seconds: response.refreshTokenExpiresInSeconds));

    await secureStorageService.saveAuthSession(
      accessToken: response.accessToken,
      refreshToken: response.refreshToken,
      accessTokenExpiry: accessTokenExpiry,
      refreshTokenExpiry: refreshTokenExpiry,
      userId: matchedUser.id,
      orgId: matchedCredential.orgId,
      name: matchedUser.name,
      email: matchedCredential.email,
      avatarUrl: matchedUser.avatarUrl,
      role: matchedCredential.role.name,
    );

    return response;
  }

  @override
  Future<MockLoginResponse?> refreshToken(String refreshToken) async {
    final storedRefreshToken = await secureStorageService.getRefreshToken();
    final refreshExpiry = await secureStorageService.getRefreshTokenExpiry();

    if (storedRefreshToken == null || storedRefreshToken != refreshToken) {
      return null;
    }

    if (refreshExpiry != null && DateTime.now().isAfter(refreshExpiry)) {
      await logout();
      return null;
    }

    // Simulate refresh by getting the mock login response again
    final response = await mockDataSource.getMockLoginResponse();
    final now = DateTime.now();
    final accessTokenExpiry = now.add(Duration(seconds: response.accessTokenExpiresInSeconds));
    final refreshTokenExpiry = now.add(Duration(seconds: response.refreshTokenExpiresInSeconds));

    await secureStorageService.saveTokens(
      accessToken: response.accessToken,
      refreshToken: response.refreshToken,
      accessTokenExpiry: accessTokenExpiry,
      refreshTokenExpiry: refreshTokenExpiry,
    );

    return response;
  }

  @override
  Future<bool> isAuthenticated() async {
    final accessToken = await secureStorageService.getAccessToken();
    if (accessToken == null || accessToken.isEmpty) {
      return false;
    }

    final accessExpiry = await secureStorageService.getAccessTokenExpiry();
    final now = DateTime.now();

    // 1. If access token is not expired, user is authenticated
    if (accessExpiry != null && now.isBefore(accessExpiry)) {
      return true;
    }

    // 2. If access token is expired, check if refresh token is valid and refresh
    final refreshTokenStr = await secureStorageService.getRefreshToken();
    final refreshExpiry = await secureStorageService.getRefreshTokenExpiry();

    if (refreshTokenStr != null &&
        refreshExpiry != null &&
        now.isBefore(refreshExpiry)) {
      final refreshed = await refreshToken(refreshTokenStr);
      return refreshed != null;
    }

    // 3. If both are expired or missing, clear session and return false
    await logout();
    return false;
  }

  @override
  Future<String?> getAuthToken() async {
    return secureStorageService.getAccessToken();
  }

  @override
  Future<String?> getOrgId() async {
    return secureStorageService.getOrgId();
  }

  @override
  Future<User?> getAuthenticatedUser() async {
    final id = await secureStorageService.getUserId();
    final name = await secureStorageService.getUserName();
    final email = await secureStorageService.getUserEmail();
    final avatarUrl = await secureStorageService.getUserAvatar();

    if (id == null || name == null || email == null) return null;

    return User(
      id: id,
      name: name,
      email: email,
      avatarUrl: avatarUrl ?? '',
    );
  }

  @override
  Future<OrgRole?> getUserRole() async {
    final roleStr = await secureStorageService.getUserRole();
    if (roleStr == null) return null;
    return OrgRole.values.firstWhere(
      (e) => e.name == roleStr,
      orElse: () => OrgRole.member,
    );
  }

  @override
  Future<List<AuthCredentials>> getTestCredentials() async {
    return mockDataSource.getAuthCredentials();
  }

  @override
  Future<void> logout() async {
    await secureStorageService.clearSession();
  }
}
