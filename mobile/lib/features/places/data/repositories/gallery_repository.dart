import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/api/api_client.dart';
import '../models/gallery_item_model.dart';

final galleryRepositoryProvider = Provider<GalleryRepository>((ref) {
  return GalleryRepository(ref.watch(apiClientProvider));
});

class GalleryRepository {
  final ApiClient _client;

  GalleryRepository(this._client);

  /// Fetch gallery items for a stay with pagination
  Future<GalleryResponse> getGallery(int stayId, {int page = 1}) async {
    final response = await _client.get('/api/v1/stays/$stayId/gallery', queryParameters: {
      'page': page,
    });

    final data = response.data as Map<String, dynamic>;
    return GalleryResponse.fromJson(_convertResponseKeys(data));
  }

  /// Convert snake_case response to camelCase and handle type coercion
  Map<String, dynamic> _convertResponseKeys(Map<String, dynamic> json) {
    final placesJson = json['places'] as List<dynamic>? ?? [];
    final convertedPlaces = placesJson.map((p) {
      final place = p as Map<String, dynamic>;
      return _convertPlaceKeys(place);
    }).toList();

    return {
      'places': convertedPlaces,
      'page': json['page'],
      'totalPages': json['total_pages'],
      'totalCount': json['total_count'],
      'hasMore': json['has_more'],
    };
  }

  Map<String, dynamic> _convertPlaceKeys(Map<String, dynamic> place) {
    return {
      'id': place['id'],
      'name': place['name'],
      'category': place['category'],
      'address': place['address'],
      'latitude': _toDouble(place['latitude']),
      'longitude': _toDouble(place['longitude']),
      'distanceMeters': _toInt(place['distance_meters']),
      'favorite': place['favorite'] ?? false,
      'inBucketList': place['in_bucket_list'] ?? false,
      'foursquarePhotoUrl': place['foursquare_photo_url'],
      'foursquareRating': _toDouble(place['foursquare_rating']),
      'foursquarePrice': _toInt(place['foursquare_price']),
    };
  }

  /// Safely convert value to double, handling strings
  double? _toDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  /// Safely convert value to int, handling strings and doubles
  int? _toInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.round();
    if (value is String) return int.tryParse(value);
    return null;
  }
}
