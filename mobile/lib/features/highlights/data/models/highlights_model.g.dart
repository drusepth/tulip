// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'highlights_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$HighlightsDataImpl _$$HighlightsDataImplFromJson(Map<String, dynamic> json) =>
    _$HighlightsDataImpl(
      currentUserId: (json['currentUserId'] as num?)?.toInt() ?? 0,
      stay: StaySummary.fromJson(json['stay'] as Map<String, dynamic>),
      stats: HighlightsStats.fromJson(json['stats'] as Map<String, dynamic>),
      categories: (json['categories'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      itemsByCategory: (json['itemsByCategory'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(
          k,
          (e as List<dynamic>)
              .map((e) => HighlightItem.fromJson(e as Map<String, dynamic>))
              .toList(),
        ),
      ),
    );

Map<String, dynamic> _$$HighlightsDataImplToJson(
  _$HighlightsDataImpl instance,
) => <String, dynamic>{
  'currentUserId': instance.currentUserId,
  'stay': instance.stay,
  'stats': instance.stats,
  'categories': instance.categories,
  'itemsByCategory': instance.itemsByCategory,
};

_$StaySummaryImpl _$$StaySummaryImplFromJson(Map<String, dynamic> json) =>
    _$StaySummaryImpl(
      id: (json['id'] as num).toInt(),
      title: json['title'] as String,
      city: json['city'] as String?,
      country: json['country'] as String?,
      checkIn: json['checkIn'] == null
          ? null
          : DateTime.parse(json['checkIn'] as String),
      checkOut: json['checkOut'] == null
          ? null
          : DateTime.parse(json['checkOut'] as String),
    );

Map<String, dynamic> _$$StaySummaryImplToJson(_$StaySummaryImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'city': instance.city,
      'country': instance.country,
      'checkIn': instance.checkIn?.toIso8601String(),
      'checkOut': instance.checkOut?.toIso8601String(),
    };

_$HighlightsStatsImpl _$$HighlightsStatsImplFromJson(
  Map<String, dynamic> json,
) => _$HighlightsStatsImpl(
  tripAverage: (json['tripAverage'] as num?)?.toDouble(),
  userStats: json['userStats'] == null
      ? null
      : UserStats.fromJson(json['userStats'] as Map<String, dynamic>),
  collaboratorStats:
      (json['collaboratorStats'] as List<dynamic>?)
          ?.map((e) => CollaboratorStats.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
);

Map<String, dynamic> _$$HighlightsStatsImplToJson(
  _$HighlightsStatsImpl instance,
) => <String, dynamic>{
  'tripAverage': instance.tripAverage,
  'userStats': instance.userStats,
  'collaboratorStats': instance.collaboratorStats,
};

_$UserStatsImpl _$$UserStatsImplFromJson(Map<String, dynamic> json) =>
    _$UserStatsImpl(
      average: (json['average'] as num).toDouble(),
      count: (json['count'] as num).toInt(),
      distribution:
          (json['distribution'] as List<dynamic>?)
              ?.map((e) => (e as num).toInt())
              .toList() ??
          const [0, 0, 0, 0, 0],
    );

Map<String, dynamic> _$$UserStatsImplToJson(_$UserStatsImpl instance) =>
    <String, dynamic>{
      'average': instance.average,
      'count': instance.count,
      'distribution': instance.distribution,
    };

_$CollaboratorStatsImpl _$$CollaboratorStatsImplFromJson(
  Map<String, dynamic> json,
) => _$CollaboratorStatsImpl(
  user: UserInfo.fromJson(json['user'] as Map<String, dynamic>),
  stats: json['stats'] == null
      ? null
      : UserStats.fromJson(json['stats'] as Map<String, dynamic>),
);

Map<String, dynamic> _$$CollaboratorStatsImplToJson(
  _$CollaboratorStatsImpl instance,
) => <String, dynamic>{'user': instance.user, 'stats': instance.stats};

_$UserInfoImpl _$$UserInfoImplFromJson(Map<String, dynamic> json) =>
    _$UserInfoImpl(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      avatarUrl: json['avatarUrl'] as String?,
    );

Map<String, dynamic> _$$UserInfoImplToJson(_$UserInfoImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'avatarUrl': instance.avatarUrl,
    };

_$HighlightItemImpl _$$HighlightItemImplFromJson(Map<String, dynamic> json) =>
    _$HighlightItemImpl(
      id: (json['id'] as num).toInt(),
      title: json['title'] as String,
      address: json['address'] as String?,
      category: json['category'] as String? ?? 'other',
      completedAt: json['completedAt'] == null
          ? null
          : DateTime.parse(json['completedAt'] as String),
      averageRating: (json['averageRating'] as num?)?.toDouble(),
      ratings:
          (json['ratings'] as List<dynamic>?)
              ?.map((e) => ItemRating.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$$HighlightItemImplToJson(_$HighlightItemImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'address': instance.address,
      'category': instance.category,
      'completedAt': instance.completedAt?.toIso8601String(),
      'averageRating': instance.averageRating,
      'ratings': instance.ratings,
    };

_$ItemRatingImpl _$$ItemRatingImplFromJson(Map<String, dynamic> json) =>
    _$ItemRatingImpl(
      userId: (json['userId'] as num).toInt(),
      userName: json['userName'] as String,
      avatarUrl: json['avatarUrl'] as String?,
      rating: (json['rating'] as num).toInt(),
    );

Map<String, dynamic> _$$ItemRatingImplToJson(_$ItemRatingImpl instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'userName': instance.userName,
      'avatarUrl': instance.avatarUrl,
      'rating': instance.rating,
    };
