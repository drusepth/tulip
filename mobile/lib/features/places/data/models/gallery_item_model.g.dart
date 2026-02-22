// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gallery_item_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$GalleryItemImpl _$$GalleryItemImplFromJson(Map<String, dynamic> json) =>
    _$GalleryItemImpl(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      category: json['category'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      address: json['address'] as String?,
      distanceMeters: (json['distanceMeters'] as num?)?.toInt(),
      favorite: json['favorite'] as bool? ?? false,
      inBucketList: json['inBucketList'] as bool? ?? false,
      foursquarePhotoUrl: json['foursquarePhotoUrl'] as String?,
      foursquareRating: (json['foursquareRating'] as num?)?.toDouble(),
      foursquarePrice: (json['foursquarePrice'] as num?)?.toInt(),
    );

Map<String, dynamic> _$$GalleryItemImplToJson(_$GalleryItemImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'category': instance.category,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'address': instance.address,
      'distanceMeters': instance.distanceMeters,
      'favorite': instance.favorite,
      'inBucketList': instance.inBucketList,
      'foursquarePhotoUrl': instance.foursquarePhotoUrl,
      'foursquareRating': instance.foursquareRating,
      'foursquarePrice': instance.foursquarePrice,
    };
