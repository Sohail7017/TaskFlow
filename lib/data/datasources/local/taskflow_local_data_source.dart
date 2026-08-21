import 'dart:convert';
import 'package:flutter/services.dart';
import '../../../core/constants/asset_paths.dart';
import '../../../core/errors/exceptions.dart';

/// Contract for the local mock JSON data source
abstract interface class TaskFlowLocalDataSource {
  /// Load and parse raw JSON mock database from bundled assets
  Future<Map<String, dynamic>> loadMockDatabase();

  /// Retrieve specific collection from the mock database
  Future<List<dynamic>> getCollection(String collectionName);
}

/// Concrete implementation of [TaskFlowLocalDataSource] reading from asset bundle
class TaskFlowLocalDataSourceImpl implements TaskFlowLocalDataSource {
  TaskFlowLocalDataSourceImpl({
    AssetBundle? assetBundle,
    String? assetPath,
  })  : _assetBundle = assetBundle ?? rootBundle,
        _assetPath = assetPath ?? AssetPaths.mockDataJson;

  final AssetBundle _assetBundle;
  final String _assetPath;
  Map<String, dynamic>? _cachedDatabase;

  @override
  Future<Map<String, dynamic>> loadMockDatabase() async {
    if (_cachedDatabase != null) {
      return _cachedDatabase!;
    }

    try {
      final jsonString = await _assetBundle.loadString(_assetPath);
      final dynamic decoded = json.decode(jsonString);
      if (decoded is Map<String, dynamic>) {
        _cachedDatabase = decoded;
        return _cachedDatabase!;
      } else {
        throw const CacheException(
          message: 'Invalid mock data format: expected root JSON map.',
        );
      }
    } on AppException {
      rethrow;
    } catch (e) {
      throw CacheException(
        message: 'Failed to load mock data asset from $_assetPath: $e',
      );
    }
  }

  @override
  Future<List<dynamic>> getCollection(String collectionName) async {
    final db = await loadMockDatabase();
    final collection = db[collectionName];
    if (collection is List) {
      return collection;
    }
    return <dynamic>[];
  }
}
