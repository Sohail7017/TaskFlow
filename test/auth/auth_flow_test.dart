import 'package:flutter_test/flutter_test.dart';
import 'package:task_flow/core/constants/storage_keys.dart';
import 'package:task_flow/core/errors/exceptions.dart';
import 'package:task_flow/core/storage/secure_storage_service.dart';
import 'package:task_flow/data/datasources/mock_data_source.dart';
import 'package:task_flow/data/repositories/auth_repository_impl.dart';

/// In-memory fake implementation of [SecureStorageService] for fast, deterministic tests
class InMemorySecureStorageService implements SecureStorageService {
  final Map<String, String> _storage = {};

  @override
  Future<String?> read({required String key}) async => _storage[key];

  @override
  Future<void> write({required String key, required String value}) async {
    _storage[key] = value;
  }

  @override
  Future<void> delete({required String key}) async {
    _storage.remove(key);
  }

  @override
  Future<void> deleteAll() async {
    _storage.clear();
  }

  @override
  Future<bool> containsKey({required String key}) async => _storage.containsKey(key);

  @override
  Future<void> saveAuthSession({
    required String accessToken,
    required String refreshToken,
    required DateTime accessTokenExpiry,
    required DateTime refreshTokenExpiry,
    String? userId,
    String? orgId,
    String? name,
    String? email,
    String? avatarUrl,
    String? role,
  }) async {
    _storage[StorageKeys.accessToken] = accessToken;
    _storage[StorageKeys.refreshToken] = refreshToken;
    _storage[StorageKeys.accessTokenExpiry] = accessTokenExpiry.toIso8601String();
    _storage[StorageKeys.refreshTokenExpiry] = refreshTokenExpiry.toIso8601String();
    if (userId != null) _storage[StorageKeys.currentUserId] = userId;
    if (orgId != null) _storage[StorageKeys.currentOrgId] = orgId;
    if (name != null) _storage[StorageKeys.currentUserName] = name;
    if (email != null) _storage[StorageKeys.currentUserEmail] = email;
    if (avatarUrl != null) _storage[StorageKeys.currentUserAvatar] = avatarUrl;
    if (role != null) _storage[StorageKeys.currentUserRole] = role;
  }

  @override
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
    required DateTime accessTokenExpiry,
    required DateTime refreshTokenExpiry,
  }) async {
    _storage[StorageKeys.accessToken] = accessToken;
    _storage[StorageKeys.refreshToken] = refreshToken;
    _storage[StorageKeys.accessTokenExpiry] = accessTokenExpiry.toIso8601String();
    _storage[StorageKeys.refreshTokenExpiry] = refreshTokenExpiry.toIso8601String();
  }

  @override
  Future<String?> getAccessToken() async => _storage[StorageKeys.accessToken];

  @override
  Future<String?> getRefreshToken() async => _storage[StorageKeys.refreshToken];

  @override
  Future<DateTime?> getAccessTokenExpiry() async {
    final raw = _storage[StorageKeys.accessTokenExpiry];
    if (raw == null) return null;
    return DateTime.tryParse(raw);
  }

  @override
  Future<DateTime?> getRefreshTokenExpiry() async {
    final raw = _storage[StorageKeys.refreshTokenExpiry];
    if (raw == null) return null;
    return DateTime.tryParse(raw);
  }

  @override
  Future<String?> getUserId() async => _storage[StorageKeys.currentUserId];

  @override
  Future<String?> getOrgId() async => _storage[StorageKeys.currentOrgId];

  @override
  Future<String?> getUserName() async => _storage[StorageKeys.currentUserName];

  @override
  Future<String?> getUserEmail() async => _storage[StorageKeys.currentUserEmail];

  @override
  Future<String?> getUserAvatar() async => _storage[StorageKeys.currentUserAvatar];

  @override
  Future<String?> getUserRole() async => _storage[StorageKeys.currentUserRole];

  @override
  Future<void> clearSession() async {
    _storage.remove(StorageKeys.accessToken);
    _storage.remove(StorageKeys.refreshToken);
    _storage.remove(StorageKeys.accessTokenExpiry);
    _storage.remove(StorageKeys.refreshTokenExpiry);
    _storage.remove(StorageKeys.currentUserId);
    _storage.remove(StorageKeys.currentOrgId);
    _storage.remove(StorageKeys.currentUserName);
    _storage.remove(StorageKeys.currentUserEmail);
    _storage.remove(StorageKeys.currentUserAvatar);
    _storage.remove(StorageKeys.currentUserRole);
    _storage.remove(StorageKeys.sessionExpiry);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockDataSource mockDataSource;
  late InMemorySecureStorageService secureStorageService;
  late AuthRepositoryImpl authRepository;

  setUp(() {
    mockDataSource = MockDataSource();
    secureStorageService = InMemorySecureStorageService();
    authRepository = AuthRepositoryImpl(
      mockDataSource: mockDataSource,
      secureStorageService: secureStorageService,
    );
  });

  group('Authentication Flow & Secure Storage Integration', () {
    test('1. Valid login saves session, tokens, and expiry without storing password', () async {
      final response = await authRepository.login(
        'ava.admin@nimbusdigital.test',
        'Password123!',
      );

      expect(response.accessToken, 'mock.access.token.short_lived');
      expect(response.refreshToken, 'mock.refresh.token.long_lived');

      // Verify tokens and expiries saved in secure storage
      final storedAccessToken = await secureStorageService.getAccessToken();
      final storedRefreshToken = await secureStorageService.getRefreshToken();
      final accessExpiry = await secureStorageService.getAccessTokenExpiry();
      final refreshExpiry = await secureStorageService.getRefreshTokenExpiry();

      expect(storedAccessToken, 'mock.access.token.short_lived');
      expect(storedRefreshToken, 'mock.refresh.token.long_lived');
      expect(accessExpiry, isNotNull);
      expect(refreshExpiry, isNotNull);
      expect(accessExpiry!.isAfter(DateTime.now()), isTrue);
      expect(refreshExpiry!.isAfter(DateTime.now()), isTrue);

      // Verify password is NOT stored anywhere in secure storage
      final allKeys = secureStorageService._storage.keys.toList();
      expect(allKeys, isNot(contains('password')));
      for (final value in secureStorageService._storage.values) {
        expect(value, isNot(contains('Password123!')));
      }
    });

    test('2. Case-insensitive email login succeeds', () async {
      final response = await authRepository.login(
        'AVA.ADMIN@NIMBUSDIGITAL.TEST',
        'Password123!',
      );
      expect(response.accessToken, 'mock.access.token.short_lived');
    });

    test('3. Invalid login throws AuthenticationException and does not save session', () async {
      expect(
        () => authRepository.login(
          'ava.admin@nimbusdigital.test',
          'WrongPassword',
        ),
        throwsA(isA<AuthenticationException>()),
      );

      final token = await secureStorageService.getAccessToken();
      expect(token, isNull);
    });

    test('4. Empty credentials throw ValidationException', () async {
      expect(
        () => authRepository.login('', ''),
        throwsA(isA<ValidationException>()),
      );
      expect(
        () => authRepository.login('ava@test.com', ''),
        throwsA(isA<ValidationException>()),
      );
      expect(
        () => authRepository.login('', 'Password123!'),
        throwsA(isA<ValidationException>()),
      );
    });

    test('5. Session check returns false when no session is stored', () async {
      final isAuth = await authRepository.isAuthenticated();
      expect(isAuth, isFalse);
    });

    test('6. Session check returns true when access token is valid and unexpired', () async {
      await secureStorageService.saveAuthSession(
        accessToken: 'valid.token',
        refreshToken: 'valid.refresh',
        accessTokenExpiry: DateTime.now().add(const Duration(minutes: 15)),
        refreshTokenExpiry: DateTime.now().add(const Duration(days: 7)),
      );

      final isAuth = await authRepository.isAuthenticated();
      expect(isAuth, isTrue);
    });

    test('7. Expired access token with valid refresh token automatically refreshes session', () async {
      // Simulate expired access token (1 minute ago) but valid refresh token (expires in 7 days)
      await secureStorageService.saveAuthSession(
        accessToken: 'expired.access.token',
        refreshToken: 'mock.refresh.token.long_lived',
        accessTokenExpiry: DateTime.now().subtract(const Duration(minutes: 1)),
        refreshTokenExpiry: DateTime.now().add(const Duration(days: 7)),
      );

      final isAuth = await authRepository.isAuthenticated();
      expect(isAuth, isTrue);

      // Verify updated access token and new expiry in secure storage
      final newAccessToken = await secureStorageService.getAccessToken();
      final newAccessExpiry = await secureStorageService.getAccessTokenExpiry();
      expect(newAccessToken, 'mock.access.token.short_lived');
      expect(newAccessExpiry!.isAfter(DateTime.now()), isTrue);
    });

    test('8. Expired access token with expired refresh token clears session and returns false', () async {
      // Both access token and refresh token expired
      await secureStorageService.saveAuthSession(
        accessToken: 'expired.access.token',
        refreshToken: 'expired.refresh.token',
        accessTokenExpiry: DateTime.now().subtract(const Duration(minutes: 20)),
        refreshTokenExpiry: DateTime.now().subtract(const Duration(minutes: 5)),
      );

      final isAuth = await authRepository.isAuthenticated();
      expect(isAuth, isFalse);

      // Verify session was cleared
      final accessToken = await secureStorageService.getAccessToken();
      final refreshToken = await secureStorageService.getRefreshToken();
      expect(accessToken, isNull);
      expect(refreshToken, isNull);
    });

    test('9. Logout completely clears stored session and tokens', () async {
      await authRepository.login(
        'ava.admin@nimbusdigital.test',
        'Password123!',
      );

      expect(await secureStorageService.getAccessToken(), isNotNull);

      await authRepository.logout();

      expect(await secureStorageService.getAccessToken(), isNull);
      expect(await secureStorageService.getRefreshToken(), isNull);
      expect(await secureStorageService.getAccessTokenExpiry(), isNull);
      expect(await secureStorageService.getRefreshTokenExpiry(), isNull);
      expect(await authRepository.isAuthenticated(), isFalse);
    });
  });
}
