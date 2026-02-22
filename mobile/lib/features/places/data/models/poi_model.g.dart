// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'poi_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PoiImpl _$$PoiImplFromJson(Map<String, dynamic> json) => _$PoiImpl(
  id: (json['id'] as num).toInt(),
  placeId: (json['placeId'] as num?)?.toInt(),
  name: json['name'] as String,
  category: json['category'] as String,
  latitude: (json['latitude'] as num).toDouble(),
  longitude: (json['longitude'] as num).toDouble(),
  distanceMeters: (json['distanceMeters'] as num?)?.toInt(),
  address: json['address'] as String?,
  openingHours: json['openingHours'] as String?,
  favorite: json['favorite'] as bool? ?? false,
  foursquareRating: (json['foursquareRating'] as num?)?.toDouble(),
  foursquarePrice: (json['foursquarePrice'] as num?)?.toInt(),
  foursquarePhotoUrl: json['foursquarePhotoUrl'] as String?,
);

Map<String, dynamic> _$$PoiImplToJson(_$PoiImpl instance) => <String, dynamic>{
  'id': instance.id,
  'placeId': instance.placeId,
  'name': instance.name,
  'category': instance.category,
  'latitude': instance.latitude,
  'longitude': instance.longitude,
  'distanceMeters': instance.distanceMeters,
  'address': instance.address,
  'openingHours': instance.openingHours,
  'favorite': instance.favorite,
  'foursquareRating': instance.foursquareRating,
  'foursquarePrice': instance.foursquarePrice,
  'foursquarePhotoUrl': instance.foursquarePhotoUrl,
};

_$PlaceImpl _$$PlaceImplFromJson(Map<String, dynamic> json) => _$PlaceImpl(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String,
  category: json['category'] as String,
  latitude: (json['latitude'] as num).toDouble(),
  longitude: (json['longitude'] as num).toDouble(),
  address: json['address'] as String?,
  openingHours: json['openingHours'] as String?,
  foursquareRating: (json['foursquareRating'] as num?)?.toDouble(),
  foursquarePrice: (json['foursquarePrice'] as num?)?.toInt(),
  foursquarePhotoUrl: json['foursquarePhotoUrl'] as String?,
  foursquareTips: (json['foursquareTips'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  distanceMeters: (json['distanceMeters'] as num?)?.toInt(),
  favorite: json['favorite'] as bool? ?? false,
  inBucketList: json['inBucketList'] as bool? ?? false,
);

Map<String, dynamic> _$$PlaceImplToJson(_$PlaceImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'category': instance.category,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'address': instance.address,
      'openingHours': instance.openingHours,
      'foursquareRating': instance.foursquareRating,
      'foursquarePrice': instance.foursquarePrice,
      'foursquarePhotoUrl': instance.foursquarePhotoUrl,
      'foursquareTips': instance.foursquareTips,
      'distanceMeters': instance.distanceMeters,
      'favorite': instance.favorite,
      'inBucketList': instance.inBucketList,
    };
