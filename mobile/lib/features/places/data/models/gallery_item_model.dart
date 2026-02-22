import 'package:freezed_annotation/freezed_annotation.dart';

part 'gallery_item_model.freezed.dart';
part 'gallery_item_model.g.dart';

/// Gallery item model for places displayed in the gallery view
@freezed
class GalleryItem with _$GalleryItem {
  const GalleryItem._();

  const factory GalleryItem({
    required int id,
    required String name,
    required String category,
    required double latitude,
    required double longitude,
    String? address,
    int? distanceMeters,
    @Default(false) bool favorite,
    @Default(false) bool inBucketList,
    String? foursquarePhotoUrl,
    double? foursquareRating,
    int? foursquarePrice,
  }) = _GalleryItem;

  factory GalleryItem.fromJson(Map<String, dynamic> json) => _$GalleryItemFromJson(json);

  /// Returns formatted distance string
  String? get distanceFormatted {
    if (distanceMeters == null) return null;
    if (distanceMeters! < 1000) {
      return '${distanceMeters}m';
    }
    return '${(distanceMeters! / 1000).toStringAsFixed(1)}km';
  }

  /// Returns the category display name
  String get categoryDisplay {
    return category.replaceAll('_', ' ').split(' ')
        .map((word) => word.isNotEmpty ? '${word[0].toUpperCase()}${word.substring(1)}' : '')
        .join(' ');
  }

  /// Returns price level as dollar signs
  String? get priceDisplay {
    if (foursquarePrice == null) return null;
    return '\$' * foursquarePrice!;
  }

  /// Check if item has a photo
  bool get hasPhoto => foursquarePhotoUrl != null && foursquarePhotoUrl!.isNotEmpty;

  /// Check if item has rating
  bool get hasRating => foursquareRating != null;
}

/// Response from gallery API endpoint
@freezed
class GalleryResponse with _$GalleryResponse {
  const factory GalleryResponse({
    required List<GalleryItem> places,
    required int page,
    required int totalPages,
    required int totalCount,
    required bool hasMore,
  }) = _GalleryResponse;

  factory GalleryResponse.fromJson(Map<String, dynamic> json) {
    final placesJson = json['places'] as List<dynamic>? ?? [];
    return GalleryResponse(
      places: placesJson.map((p) => GalleryItem.fromJson(p as Map<String, dynamic>)).toList(),
      page: (json['page'] as num?)?.toInt() ?? 1,
      totalPages: (json['totalPages'] as num?)?.toInt() ?? 1,
      totalCount: (json['totalCount'] as num?)?.toInt() ?? 0,
      hasMore: json['hasMore'] as bool? ?? false,
    );
  }
}
