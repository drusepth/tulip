import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/api/endpoints.dart';
import '../models/highlights_model.dart';

final highlightsRepositoryProvider = Provider<HighlightsRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return HighlightsRepository(apiClient);
});

class HighlightsRepository {
  final ApiClient _apiClient;

  HighlightsRepository(this._apiClient);

  /// Fetch highlights data for a stay
  Future<HighlightsData> getHighlights(int stayId) async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      Endpoints.stayHighlights(stayId),
    );
    final data = response.data!;
    return HighlightsData.fromJson(_convertKeys(data));
  }

  /// Convert snake_case keys to camelCase
  Map<String, dynamic> _convertKeys(Map<String, dynamic> json) {
    return json.map((key, value) {
      final newKey = _toCamelCase(key);
      dynamic newValue = value;

      // Handle nested structures
      if (value is Map<String, dynamic>) {
        newValue = _convertKeys(value);
      } else if (value is List) {
        newValue = value.map((e) {
          if (e is Map<String, dynamic>) {
            return _convertKeys(e);
          }
          return e;
        }).toList();
      }

      // Handle type coercion for numeric fields
      if (newKey == 'tripAverage' || newKey == 'average' || newKey == 'averageRating') {
        newValue = _toDouble(value);
      } else if (newKey == 'count' || newKey == 'rating' || newKey == 'userId' || newKey == 'id') {
        newValue = _toInt(value);
      } else if (newKey == 'distribution') {
        newValue = (value as List?)?.map((e) => _toInt(e) ?? 0).toList() ?? <int>[];
      }

      return MapEntry(newKey, newValue);
    });
  }

  /// Safely convert value to double
  double? _toDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  /// Safely convert value to int
  int? _toInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.round();
    if (value is String) return int.tryParse(value);
    return null;
  }

  String _toCamelCase(String str) {
    final parts = str.split('_');
    if (parts.length == 1) return str;
    return parts.first +
        parts.skip(1).map((p) => p.isEmpty ? '' : '${p[0].toUpperCase()}${p.substring(1)}').join();
  }
}
