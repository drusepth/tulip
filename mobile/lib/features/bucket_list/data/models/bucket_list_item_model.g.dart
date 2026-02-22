// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bucket_list_item_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$BucketListItemImpl _$$BucketListItemImplFromJson(Map<String, dynamic> json) =>
    _$BucketListItemImpl(
      id: (json['id'] as num).toInt(),
      title: json['title'] as String,
      category: json['category'] as String?,
      notes: json['notes'] as String?,
      address: json['address'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      completed: json['completed'] as bool? ?? false,
      completedAt: json['completedAt'] == null
          ? null
          : DateTime.parse(json['completedAt'] as String),
      stayId: (json['stayId'] as num).toInt(),
      placeId: (json['placeId'] as num?)?.toInt(),
      averageRating: (json['averageRating'] as num?)?.toDouble(),
      userRating: (json['userRating'] as num?)?.toInt(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$BucketListItemImplToJson(
  _$BucketListItemImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'category': instance.category,
  'notes': instance.notes,
  'address': instance.address,
  'latitude': instance.latitude,
  'longitude': instance.longitude,
  'completed': instance.completed,
  'completedAt': instance.completedAt?.toIso8601String(),
  'stayId': instance.stayId,
  'placeId': instance.placeId,
  'averageRating': instance.averageRating,
  'userRating': instance.userRating,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
};

_$BucketListItemRequestImpl _$$BucketListItemRequestImplFromJson(
  Map<String, dynamic> json,
) => _$BucketListItemRequestImpl(
  title: json['title'] as String,
  category: json['category'] as String?,
  notes: json['notes'] as String?,
  address: json['address'] as String?,
  latitude: (json['latitude'] as num?)?.toDouble(),
  longitude: (json['longitude'] as num?)?.toDouble(),
  placeId: (json['placeId'] as num?)?.toInt(),
);

Map<String, dynamic> _$$BucketListItemRequestImplToJson(
  _$BucketListItemRequestImpl instance,
) => <String, dynamic>{
  'title': instance.title,
  'category': instance.category,
  'notes': instance.notes,
  'address': instance.address,
  'latitude': instance.latitude,
  'longitude': instance.longitude,
  'placeId': instance.placeId,
};
