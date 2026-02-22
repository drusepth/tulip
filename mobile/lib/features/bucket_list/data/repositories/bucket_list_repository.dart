import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/api/endpoints.dart';
import '../models/bucket_list_item_model.dart';

final bucketListRepositoryProvider = Provider<BucketListRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return BucketListRepository(apiClient);
});

class BucketListRepository {
  final ApiClient _apiClient;

  BucketListRepository(this._apiClient);

  /// Fetch all bucket list items for a stay
  Future<List<BucketListItem>> getItemsForStay(int stayId) async {
    final response = await _apiClient.get<List<dynamic>>(
      Endpoints.stayBucketListItems(stayId),
    );
    final data = response.data ?? [];
    return data.map((json) => BucketListItem.fromJson(_convertKeys(json))).toList();
  }

  /// Create a new bucket list item
  Future<BucketListItem> createItem(int stayId, BucketListItemRequest request) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      Endpoints.stayBucketListItems(stayId),
      data: _toSnakeCase(request.toJson()),
    );
    return BucketListItem.fromJson(_convertKeys(response.data!));
  }

  /// Update a bucket list item
  Future<BucketListItem> updateItem(int id, BucketListItemRequest request) async {
    final response = await _apiClient.patch<Map<String, dynamic>>(
      Endpoints.bucketListItem(id),
      data: _toSnakeCase(request.toJson()),
    );
    return BucketListItem.fromJson(_convertKeys(response.data!));
  }

  /// Toggle completed status
  Future<BucketListItem> toggleItem(int id) async {
    final response = await _apiClient.patch<Map<String, dynamic>>(
      Endpoints.bucketListItemToggle(id),
    );
    return BucketListItem.fromJson(_convertKeys(response.data!));
  }

  /// Rate a bucket list item
  Future<Map<String, dynamic>> rateItem(int id, int rating) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      Endpoints.bucketListItemRate(id),
      data: {'rating': rating},
    );
    return response.data ?? {};
  }

  /// Delete a bucket list item
  Future<void> deleteItem(int id) async {
    await _apiClient.delete(Endpoints.bucketListItem(id));
  }

  /// Convert snake_case keys to camelCase
  Map<String, dynamic> _convertKeys(Map<String, dynamic> json) {
    return json.map((key, value) {
      final newKey = _toCamelCase(key);
      final newValue = value is Map<String, dynamic>
          ? _convertKeys(value)
          : value is List
              ? value.map((e) => e is Map<String, dynamic> ? _convertKeys(e) : e).toList()
              : value;
      return MapEntry(newKey, newValue);
    });
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
