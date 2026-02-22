import 'package:freezed_annotation/freezed_annotation.dart';

part 'poi_model.freezed.dart';
part 'poi_model.g.dart';

@freezed
class Poi with _$Poi {
  const Poi._();

  const factory Poi({
    required int id,
    int? placeId,
    required String name,
    required String category,
    required double latitude,
    required double longitude,
    int? distanceMeters,
    String? address,
    String? openingHours,
    @Default(false) bool favorite,
    double? foursquareRating,
    int? foursquarePrice,
    String? foursquarePhotoUrl,
  }) = _Poi;

  factory Poi.fromJson(Map<String, dynamic> json) => _$PoiFromJson(json);

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

  /// Check if POI has Foursquare enrichment
  bool get hasEnrichment => foursquareRating != null || foursquarePhotoUrl != null;
}

@freezed
class Place with _$Place {
  const Place._();

  const factory Place({
    required int id,
    required String name,
    required String category,
    required double latitude,
    required double longitude,
    String? address,
    String? openingHours,
    double? foursquareRating,
    int? foursquarePrice,
    String? foursquarePhotoUrl,
    List<String>? foursquareTips,
    // Contextual data when viewing from a stay
    int? distanceMeters,
    @Default(false) bool favorite,
    @Default(false) bool inBucketList,
  }) = _Place;

  factory Place.fromJson(Map<String, dynamic> json) => _$PlaceFromJson(json);

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

  /// Check if place has Foursquare enrichment
  bool get hasEnrichment => foursquareRating != null || foursquarePhotoUrl != null;
}
