import 'package:hive_flutter/hive_flutter.dart';

/// Contract for local caching and offline key-value storage using Hive
abstract interface class HiveService {
  /// Initialize Hive (supports custom path for testing/custom directories)
  Future<void> init([String? path]);

  /// Retrieve a value from a specified Hive box
  T? get<T>(String boxName, String key, {T? defaultValue});

  /// Store a value in a specified Hive box
  Future<void> put<T>(String boxName, String key, T value);

  /// Remove a key-value entry from a specified Hive box
  Future<void> delete(String boxName, String key);

  /// Clear all entries from a specified Hive box
  Future<void> clear(String boxName);

  /// Check if a key exists in a specified Hive box
  bool containsKey(String boxName, String key);

  /// Retrieve all values from a specified Hive box
  List<T> getAll<T>(String boxName);

  /// Open a specific box if not already open
  Future<Box<dynamic>> openBox(String boxName);

  /// Close all open boxes
  Future<void> close();
}

/// Concrete implementation of [HiveService] wrapping Hive APIs
class HiveServiceImpl implements HiveService {
  @override
  Future<void> init([String? path]) async {
    if (path != null) {
      Hive.init(path);
    } else {
      await Hive.initFlutter();
    }
  }

  @override
  Future<Box<dynamic>> openBox(String boxName) async {
    if (Hive.isBoxOpen(boxName)) {
      return Hive.box(boxName);
    }
    return Hive.openBox(boxName);
  }

  Box<dynamic> _getBox(String boxName) {
    if (!Hive.isBoxOpen(boxName)) {
      throw StateError(
        'Hive box "$boxName" is not opened. Ensure openBox is called before access.',
      );
    }
    return Hive.box(boxName);
  }

  @override
  T? get<T>(String boxName, String key, {T? defaultValue}) {
    final box = _getBox(boxName);
    return box.get(key, defaultValue: defaultValue) as T?;
  }

  @override
  Future<void> put<T>(String boxName, String key, T value) async {
    final box = _getBox(boxName);
    await box.put(key, value);
  }

  @override
  Future<void> delete(String boxName, String key) async {
    final box = _getBox(boxName);
    await box.delete(key);
  }

  @override
  Future<void> clear(String boxName) async {
    final box = _getBox(boxName);
    await box.clear();
  }

  @override
  bool containsKey(String boxName, String key) {
    final box = _getBox(boxName);
    return box.containsKey(key);
  }

  @override
  List<T> getAll<T>(String boxName) {
    final box = _getBox(boxName);
    return box.values.cast<T>().toList();
  }

  @override
  Future<void> close() async {
    await Hive.close();
  }
}
