import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/api/endpoints.dart';
import '../models/stay_model.dart';

final stayRepositoryProvider = Provider<StayRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return StayRepository(apiClient);
});

class StayRepository {
  final ApiClient _apiClient;

  StayRepository(this._apiClient);

  /// Fetch all stays for the current user
  Future<List<Stay>> getStays() async {
    final response = await _apiClient.get<List<dynamic>>(Endpoints.stays);
    final data = response.data ?? [];
    return data.map((json) => Stay.fromJson(_convertKeys(json))).toList();
  }

  /// Fetch a single stay by ID
  Future<Stay> getStay(int id) async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      Endpoints.stay(id),
    );
    return Stay.fromJson(_convertKeys(response.data!));
  }

  /// Create a new stay
  Future<Stay> createStay(StayRequest request) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      Endpoints.stays,
      data: _toSnakeCase(request.toJson()),
    );
    return Stay.fromJson(_convertKeys(response.data!));
  }

  /// Update an existing stay
  Future<Stay> updateStay(int id, StayRequest request) async {
    final response = await _apiClient.patch<Map<String, dynamic>>(
      Endpoints.stay(id),
      data: _toSnakeCase(request.toJson()),
    );
    return Stay.fromJson(_convertKeys(response.data!));
  }

  /// Delete a stay
  Future<void> deleteStay(int id) async {
    await _apiClient.delete(Endpoints.stay(id));
  }

  /// Fetch weather data for a stay
  Future<Map<String, dynamic>> getWeather(int stayId) async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      Endpoints.stayWeather(stayId),
    );
    return response.data ?? {};
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
          : value is DateTime
              ? value.toIso8601String().split('T').first
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
