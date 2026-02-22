import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/api/endpoints.dart';
import '../models/poi_model.dart';

final poiRepositoryProvider = Provider<PoiRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return PoiRepository(apiClient);
});

class PoiRepository {
  final ApiClient _apiClient;

  PoiRepository(this._apiClient);

  /// Fetch POIs for a specific stay
  Future<List<Poi>> getPoisForStay(int stayId) async {
    final response = await _apiClient.get<List<dynamic>>(
      Endpoints.stayPois(stayId),
    );
    final data = response.data ?? [];
    return data.map((json) => Poi.fromJson(_convertKeys(json))).toList();
  }

  /// Fetch/refresh POIs for a stay (triggers server-side fetch if needed)
  Future<List<Poi>> fetchPoisForStay(int stayId, {String? category}) async {
    final response = await _apiClient.post<List<dynamic>>(
      Endpoints.stayPoisFetch(stayId),
      data: category != null ? {'category': category} : null,
    );
    final data = response.data ?? [];
    return data.map((json) => Poi.fromJson(_convertKeys(json))).toList();
  }

  /// Search POIs by viewport (for map exploration)
  Future<List<Poi>> searchPois({
    required double lat,
    required double lng,
    double? radius,
    String? category,
    CancelToken? cancelToken,
  }) async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      Endpoints.mapPoisSearch,
      queryParameters: {
        'lat': lat,
        'lng': lng,
        if (radius != null) 'radius': radius,
        if (category != null) 'category': category,
      },
      cancelToken: cancelToken,
    );
    final pois = response.data?['pois'] as List<dynamic>? ?? [];
    return pois.map((json) => Poi.fromJson(_convertKeys(json))).toList();
  }

  /// Toggle favorite status for a POI
  Future<Poi> toggleFavorite(int stayId, int poiId) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      Endpoints.stayPoisToggleFavorite(stayId),
      data: {'poi_id': poiId},
    );
    return Poi.fromJson(_convertKeys(response.data!));
  }

  /// Get place details
  Future<Place> getPlace(int placeId) async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      Endpoints.place(placeId),
    );
    return Place.fromJson(_convertKeys(response.data!));
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

  String _toCamelCase(String str) {
    final parts = str.split('_');
    if (parts.length == 1) return str;
    return parts.first +
        parts.skip(1).map((p) => p.isEmpty ? '' : '${p[0].toUpperCase()}${p.substring(1)}').join();
  }
}
