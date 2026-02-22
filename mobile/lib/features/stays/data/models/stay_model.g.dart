// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stay_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$StayImpl _$$StayImplFromJson(Map<String, dynamic> json) => _$StayImpl(
  id: (json['id'] as num).toInt(),
  title: json['title'] as String,
  stayType: json['stayType'] as String?,
  bookingUrl: json['bookingUrl'] as String?,
  imageUrl: json['imageUrl'] as String?,
  address: json['address'] as String?,
  city: json['city'] as String,
  state: json['state'] as String?,
  country: json['country'] as String?,
  latitude: (json['latitude'] as num?)?.toDouble(),
  longitude: (json['longitude'] as num?)?.toDouble(),
  checkIn: json['checkIn'] == null
      ? null
      : DateTime.parse(json['checkIn'] as String),
  checkOut: json['checkOut'] == null
      ? null
      : DateTime.parse(json['checkOut'] as String),
  priceTotalCents: (json['priceTotalCents'] as num?)?.toInt(),
  currency: json['currency'] as String? ?? 'USD',
  status: json['status'] as String,
  booked: json['booked'] as bool? ?? false,
  isWishlist: json['isWishlist'] as bool? ?? false,
  durationDays: (json['durationDays'] as num?)?.toInt() ?? 0,
  daysUntilCheckIn: (json['daysUntilCheckIn'] as num?)?.toInt(),
  isOwner: json['isOwner'] as bool? ?? false,
  canEdit: json['canEdit'] as bool? ?? false,
  notes: json['notes'] as String?,
  weather: json['weather'] as Map<String, dynamic>?,
  bucketListCount: (json['bucketListCount'] as num?)?.toInt() ?? 0,
  bucketListCompletedCount:
      (json['bucketListCompletedCount'] as num?)?.toInt() ?? 0,
  collaboratorCount: (json['collaboratorCount'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$$StayImplToJson(_$StayImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'stayType': instance.stayType,
      'bookingUrl': instance.bookingUrl,
      'imageUrl': instance.imageUrl,
      'address': instance.address,
      'city': instance.city,
      'state': instance.state,
      'country': instance.country,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'checkIn': instance.checkIn?.toIso8601String(),
      'checkOut': instance.checkOut?.toIso8601String(),
      'priceTotalCents': instance.priceTotalCents,
      'currency': instance.currency,
      'status': instance.status,
      'booked': instance.booked,
      'isWishlist': instance.isWishlist,
      'durationDays': instance.durationDays,
      'daysUntilCheckIn': instance.daysUntilCheckIn,
      'isOwner': instance.isOwner,
      'canEdit': instance.canEdit,
      'notes': instance.notes,
      'weather': instance.weather,
      'bucketListCount': instance.bucketListCount,
      'bucketListCompletedCount': instance.bucketListCompletedCount,
      'collaboratorCount': instance.collaboratorCount,
    };

_$StayRequestImpl _$$StayRequestImplFromJson(Map<String, dynamic> json) =>
    _$StayRequestImpl(
      title: json['title'] as String,
      stayType: json['stayType'] as String?,
      bookingUrl: json['bookingUrl'] as String?,
      imageUrl: json['imageUrl'] as String?,
      address: json['address'] as String?,
      city: json['city'] as String,
      state: json['state'] as String?,
      country: json['country'] as String?,
      checkIn: json['checkIn'] == null
          ? null
          : DateTime.parse(json['checkIn'] as String),
      checkOut: json['checkOut'] == null
          ? null
          : DateTime.parse(json['checkOut'] as String),
      priceTotalDollars: (json['priceTotalDollars'] as num?)?.toDouble(),
      currency: json['currency'] as String? ?? 'USD',
      notes: json['notes'] as String?,
      booked: json['booked'] as bool? ?? false,
    );

Map<String, dynamic> _$$StayRequestImplToJson(_$StayRequestImpl instance) =>
    <String, dynamic>{
      'title': instance.title,
      'stayType': instance.stayType,
      'bookingUrl': instance.bookingUrl,
      'imageUrl': instance.imageUrl,
      'address': instance.address,
      'city': instance.city,
      'state': instance.state,
      'country': instance.country,
      'checkIn': instance.checkIn?.toIso8601String(),
      'checkOut': instance.checkOut?.toIso8601String(),
      'priceTotalDollars': instance.priceTotalDollars,
      'currency': instance.currency,
      'notes': instance.notes,
      'booked': instance.booked,
    };
