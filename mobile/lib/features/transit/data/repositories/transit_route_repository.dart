import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/api/api_client.dart';
import '../models/transit_route_model.dart';

final transitRouteRepositoryProvider = Provider<TransitRouteRepository>((ref) {
  return TransitRouteRepository(ref.watch(apiClientProvider));
});

class TransitRouteRepository {
  final ApiClient _client;

  TransitRouteRepository(this._client);

  /// Get cached transit routes for a stay
  Future<List<TransitRoute>> getTransitRoutes(
    int stayId, {
    TransitRouteType? routeType,
  }) async {
    final queryParams = <String, dynamic>{};
    if (routeType != null) {
      queryParams['route_type'] = routeType.apiValue;
    }

    final response = await _client.get(
      '/api/v1/stays/$stayId/transit_routes',
      queryParameters: queryParams,
    );

    final data = response.data as List<dynamic>;
    return data
        .map((json) => TransitRoute.fromJson(_convertKeys(json as Map<String, dynamic>)))
        .toList();
  }

  /// Fetch transit routes from Overpass API (triggers backend fetch if not cached)
  Future<List<TransitRoute>> fetchTransitRoutes(
    int stayId,
    TransitRouteType routeType,
  ) async {
    final response = await _client.post(
      '/api/v1/stays/$stayId/transit_routes/fetch',
      queryParameters: {'route_type': routeType.apiValue},
    );

    final data = response.data as List<dynamic>;
    return data
        .map((json) => TransitRoute.fromJson(_convertKeys(json as Map<String, dynamic>)))
        .toList();
  }

  /// Convert snake_case response keys to camelCase
  Map<String, dynamic> _convertKeys(Map<String, dynamic> json) {
    return {
      'id': json['id'],
      'name': json['name'],
      'routeType': json['route_type'],
      'color': json['color'],
      'geometry': json['geometry'] ?? [],
    };
  }
}
