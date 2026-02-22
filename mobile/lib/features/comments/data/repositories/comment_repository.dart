import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/api/api_client.dart';
import '../models/comment_model.dart';

final commentRepositoryProvider = Provider<CommentRepository>((ref) {
  return CommentRepository(ref.watch(apiClientProvider));
});

class CommentRepository {
  final ApiClient _client;

  CommentRepository(this._client);

  /// Fetch all comments for a stay
  Future<List<Comment>> getCommentsForStay(int stayId) async {
    final response = await _client.get<List<dynamic>>(
      '/api/v1/stays/$stayId/comments',
    );
    final data = response.data ?? [];
    return data.map((json) {
      final rawJson = json as Map<String, dynamic>;
      final convertedJson = _convertKeys(rawJson);
      try {
        return Comment.fromJson(convertedJson);
      } catch (e) {
        debugPrint('Failed to parse comment JSON: $convertedJson');
        debugPrint('Parse error: $e');
        rethrow;
      }
    }).toList();
  }

  /// Create a new comment
  Future<Comment> createComment(int stayId, CommentRequest request) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/api/v1/stays/$stayId/comments',
      data: _toSnakeCase(request.toJson()),
    );
    return Comment.fromJson(_convertKeys(response.data!));
  }

  /// Update a comment
  Future<Comment> updateComment(int commentId, CommentRequest request) async {
    final response = await _client.patch<Map<String, dynamic>>(
      '/api/v1/comments/$commentId',
      data: _toSnakeCase(request.toJson()),
    );
    return Comment.fromJson(_convertKeys(response.data!));
  }

  /// Delete a comment
  Future<void> deleteComment(int commentId) async {
    await _client.delete('/api/v1/comments/$commentId');
  }

  /// Convert snake_case keys to camelCase and handle type coercion
  Map<String, dynamic> _convertKeys(Map<String, dynamic> json) {
    return json.map((key, value) {
      final newKey = _toCamelCase(key);
      dynamic newValue = value;

      // Handle nested structures
      if (value is Map<String, dynamic>) {
        newValue = _convertKeys(value);
      } else if (value is List) {
        newValue = value.map((e) => e is Map<String, dynamic> ? _convertKeys(e) : e).toList();
      }

      // Handle type coercion for numeric fields that may come as strings
      if (newKey == 'id' || newKey == 'parentId' || newKey == 'userId') {
        newValue = _toInt(value, fieldName: newKey);
      }

      return MapEntry(newKey, newValue);
    });
  }

  /// Safely convert value to int
  int? _toInt(dynamic value, {String? fieldName}) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.round();
    if (value is String) {
      final parsed = int.tryParse(value);
      if (parsed == null && value.isNotEmpty) {
        debugPrint('Warning: Could not parse "$value" as int for field $fieldName');
      }
      return parsed;
    }
    debugPrint('Warning: Unexpected type ${value.runtimeType} for field $fieldName: $value');
    return null;
  }

  /// Convert camelCase to snake_case for API requests
  Map<String, dynamic> _toSnakeCase(Map<String, dynamic> json) {
    return json.map((key, value) {
      final newKey = _toSnakeCaseString(key);
      final newValue = value is Map<String, dynamic>
          ? _toSnakeCase(value)
          : value;
      return MapEntry(newKey, newValue);
    })..removeWhere((key, value) => value == null);
  }

  String _toCamelCase(String str) {
    final parts = str.split('_');
    if (parts.length == 1) return str;
    return parts.first +
        parts.skip(1).map((p) => p.isEmpty ? '' : '${p[0].toUpperCase()}${p.substring(1)}').join();
  }

  String _toSnakeCaseString(String str) {
    return str.replaceAllMapped(
      RegExp(r'[A-Z]'),
      (match) => '_${match.group(0)!.toLowerCase()}',
    );
  }
}
