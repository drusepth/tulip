import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Provider for the cache service
final cacheServiceProvider = Provider<CacheService>((ref) {
  return CacheService();
});

/// Simple JSON-based caching service using SharedPreferences
/// Provides cache-first pattern for offline support
class CacheService {
  static const String _cachePrefix = 'cache_';
  static const String _timestampPrefix = 'cache_ts_';

  /// Default cache expiry duration (24 hours)
  static const Duration defaultExpiry = Duration(hours: 24);

  /// Get cached data for a key
  Future<T?> get<T>(
    String key, {
    T Function(Map<String, dynamic>)? fromJson,
    Duration? maxAge,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final cacheKey = '$_cachePrefix$key';
    final timestampKey = '$_timestampPrefix$key';

    final cachedData = prefs.getString(cacheKey);
    if (cachedData == null) return null;

    // Check if cache has expired
    if (maxAge != null) {
      final timestamp = prefs.getInt(timestampKey);
      if (timestamp != null) {
        final cacheTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
        if (DateTime.now().difference(cacheTime) > maxAge) {
          // Cache expired, remove it
          await remove(key);
          return null;
        }
      }
    }

    try {
      final decoded = json.decode(cachedData);
      if (fromJson != null && decoded is Map<String, dynamic>) {
        return fromJson(decoded);
      }
      return decoded as T?;
    } catch (e) {
      // Invalid cache data, remove it
      await remove(key);
      return null;
    }
  }

  /// Get cached list data for a key
  Future<List<T>?> getList<T>(
    String key, {
    required T Function(Map<String, dynamic>) fromJson,
    Duration? maxAge,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final cacheKey = '$_cachePrefix$key';
    final timestampKey = '$_timestampPrefix$key';

    final cachedData = prefs.getString(cacheKey);
    if (cachedData == null) return null;

    // Check if cache has expired
    if (maxAge != null) {
      final timestamp = prefs.getInt(timestampKey);
      if (timestamp != null) {
        final cacheTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
        if (DateTime.now().difference(cacheTime) > maxAge) {
          await remove(key);
          return null;
        }
      }
    }

    try {
      final decoded = json.decode(cachedData) as List<dynamic>;
      return decoded
          .map((item) => fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      await remove(key);
      return null;
    }
  }

  /// Set cached data for a key
  Future<void> set(String key, dynamic data) async {
    final prefs = await SharedPreferences.getInstance();
    final cacheKey = '$_cachePrefix$key';
    final timestampKey = '$_timestampPrefix$key';

    await prefs.setString(cacheKey, json.encode(data));
    await prefs.setInt(timestampKey, DateTime.now().millisecondsSinceEpoch);
  }

  /// Remove cached data for a key
  Future<void> remove(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('$_cachePrefix$key');
    await prefs.remove('$_timestampPrefix$key');
  }

  /// Clear all cached data
  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();
    for (final key in keys) {
      if (key.startsWith(_cachePrefix) || key.startsWith(_timestampPrefix)) {
        await prefs.remove(key);
      }
    }
  }

  /// Check if cache exists and is not expired
  Future<bool> hasValidCache(String key, {Duration? maxAge}) async {
    final prefs = await SharedPreferences.getInstance();
    final cacheKey = '$_cachePrefix$key';
    final timestampKey = '$_timestampPrefix$key';

    if (!prefs.containsKey(cacheKey)) return false;

    if (maxAge != null) {
      final timestamp = prefs.getInt(timestampKey);
      if (timestamp != null) {
        final cacheTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
        return DateTime.now().difference(cacheTime) <= maxAge;
      }
    }

    return true;
  }
}

/// Cache keys for different data types
class CacheKeys {
  static const String stays = 'stays';
  static String stayDetail(int id) => 'stay_$id';
  static String bucketList(int stayId) => 'bucket_list_$stayId';
  static String comments(int stayId) => 'comments_$stayId';
  static const String notifications = 'notifications';
  static const String userProfile = 'user_profile';
}
