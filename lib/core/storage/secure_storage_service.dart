import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/storage_keys.dart';

/// Contract for secure key-value storage (auth tokens, session keys)
abstract interface class SecureStorageService {
  Future<String?> read({required String key});
  Future<void> write({required String key, required String value});
  Future<void> delete({required String key});
  Future<void> deleteAll();
  Future<bool> containsKey({required String key});

  // Session-specific helper methods
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
  });
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
    required DateTime accessTokenExpiry,
    required DateTime refreshTokenExpiry,
  });
  Future<String?> getAccessToken();
  Future<String?> getRefreshToken();
  Future<DateTime?> getAccessTokenExpiry();
  Future<DateTime?> getRefreshTokenExpiry();
  Future<String?> getUserId();
  Future<String?> getOrgId();
  Future<String?> getUserName();
  Future<String?> getUserEmail();
  Future<String?> getUserAvatar();
  Future<String?> getUserRole();
  Future<void> clearSession();
}

/// Implementation of [SecureStorageService] using [FlutterSecureStorage]
class SecureStorageServiceImpl implements SecureStorageService {
  const SecureStorageServiceImpl({
    required this.secureStorage,
  });

  final FlutterSecureStorage secureStorage;

  @override
  Future<String?> read({required String key}) async {
    return secureStorage.read(key: key);
  }

  @override
  Future<void> write({required String key, required String value}) async {
    await secureStorage.write(key: key, value: value);
  }

  @override
  Future<void> delete({required String key}) async {
    await secureStorage.delete(key: key);
  }

  @override
  Future<void> deleteAll() async {
    await secureStorage.deleteAll();
  }

  @override
  Future<bool> containsKey({required String key}) async {
    return secureStorage.containsKey(key: key);
  }

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
    await secureStorage.write(key: StorageKeys.accessToken, value: accessToken);
    await secureStorage.write(key: StorageKeys.refreshToken, value: refreshToken);
    await secureStorage.write(
      key: StorageKeys.accessTokenExpiry,
      value: accessTokenExpiry.toIso8601String(),
    );
    await secureStorage.write(
      key: StorageKeys.refreshTokenExpiry,
      value: refreshTokenExpiry.toIso8601String(),
    );
    if (userId != null) {
      await secureStorage.write(key: StorageKeys.currentUserId, value: userId);
    }
    if (orgId != null) {
      await secureStorage.write(key: StorageKeys.currentOrgId, value: orgId);
    }
    if (name != null) {
      await secureStorage.write(key: StorageKeys.currentUserName, value: name);
    }
    if (email != null) {
      await secureStorage.write(key: StorageKeys.currentUserEmail, value: email);
    }
    if (avatarUrl != null) {
      await secureStorage.write(key: StorageKeys.currentUserAvatar, value: avatarUrl);
    }
    if (role != null) {
      await secureStorage.write(key: StorageKeys.currentUserRole, value: role);
    }
  }

  @override
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
    required DateTime accessTokenExpiry,
    required DateTime refreshTokenExpiry,
  }) async {
    await secureStorage.write(key: StorageKeys.accessToken, value: accessToken);
    await secureStorage.write(key: StorageKeys.refreshToken, value: refreshToken);
    await secureStorage.write(
      key: StorageKeys.accessTokenExpiry,
      value: accessTokenExpiry.toIso8601String(),
    );
    await secureStorage.write(
      key: StorageKeys.refreshTokenExpiry,
      value: refreshTokenExpiry.toIso8601String(),
    );
  }

  @override
  Future<String?> getAccessToken() async {
    return secureStorage.read(key: StorageKeys.accessToken);
  }

  @override
  Future<String?> getRefreshToken() async {
    return secureStorage.read(key: StorageKeys.refreshToken);
  }

  @override
  Future<DateTime?> getAccessTokenExpiry() async {
    final raw = await secureStorage.read(key: StorageKeys.accessTokenExpiry);
    if (raw == null || raw.isEmpty) return null;
    return DateTime.tryParse(raw);
  }

  @override
  Future<DateTime?> getRefreshTokenExpiry() async {
    final raw = await secureStorage.read(key: StorageKeys.refreshTokenExpiry);
    if (raw == null || raw.isEmpty) return null;
    return DateTime.tryParse(raw);
  }

  @override
  Future<String?> getUserId() async {
    return secureStorage.read(key: StorageKeys.currentUserId);
  }

  @override
  Future<String?> getOrgId() async {
    return secureStorage.read(key: StorageKeys.currentOrgId);
  }

  @override
  Future<String?> getUserName() async {
    return secureStorage.read(key: StorageKeys.currentUserName);
  }

  @override
  Future<String?> getUserEmail() async {
    return secureStorage.read(key: StorageKeys.currentUserEmail);
  }

  @override
  Future<String?> getUserAvatar() async {
    return secureStorage.read(key: StorageKeys.currentUserAvatar);
  }

  @override
  Future<String?> getUserRole() async {
    return secureStorage.read(key: StorageKeys.currentUserRole);
  }

  @override
  Future<void> clearSession() async {
    await secureStorage.delete(key: StorageKeys.accessToken);
    await secureStorage.delete(key: StorageKeys.refreshToken);
    await secureStorage.delete(key: StorageKeys.accessTokenExpiry);
    await secureStorage.delete(key: StorageKeys.refreshTokenExpiry);
    await secureStorage.delete(key: StorageKeys.currentUserId);
    await secureStorage.delete(key: StorageKeys.currentOrgId);
    await secureStorage.delete(key: StorageKeys.currentUserName);
    await secureStorage.delete(key: StorageKeys.currentUserEmail);
    await secureStorage.delete(key: StorageKeys.currentUserAvatar);
    await secureStorage.delete(key: StorageKeys.currentUserRole);
    await secureStorage.delete(key: StorageKeys.sessionExpiry);
  }
}
