import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Contract for secure key-value storage (auth tokens, session keys)
abstract interface class SecureStorageService {
  Future<String?> read({required String key});
  Future<void> write({required String key, required String value});
  Future<void> delete({required String key});
  Future<void> deleteAll();
  Future<bool> containsKey({required String key});
}

/// Implementation of [SecureStorageService] using [FlutterSecureStorage]
class SecureStorageServiceImpl implements SecureStorageService {
  const SecureStorageServiceImpl({required FlutterSecureStorage secureStorage})
      : _secureStorage = secureStorage;

  final FlutterSecureStorage _secureStorage;

  @override
  Future<String?> read({required String key}) async {
    return _secureStorage.read(key: key);
  }

  @override
  Future<void> write({required String key, required String value}) async {
    await _secureStorage.write(key: key, value: value);
  }

  @override
  Future<void> delete({required String key}) async {
    await _secureStorage.delete(key: key);
  }

  @override
  Future<void> deleteAll() async {
    await _secureStorage.deleteAll();
  }

  @override
  Future<bool> containsKey({required String key}) async {
    return _secureStorage.containsKey(key: key);
  }
}
