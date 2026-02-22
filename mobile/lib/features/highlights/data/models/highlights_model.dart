import 'package:freezed_annotation/freezed_annotation.dart';

part 'highlights_model.freezed.dart';
part 'highlights_model.g.dart';

@freezed
class HighlightsData with _$HighlightsData {
  const HighlightsData._();

  const factory HighlightsData({
    @Default(0) int currentUserId,
    required StaySummary stay,
    required HighlightsStats stats,
    required List<String> categories,
    required Map<String, List<HighlightItem>> itemsByCategory,
  }) = _HighlightsData;

  factory HighlightsData.fromJson(Map<String, dynamic> json) =>
      _$HighlightsDataFromJson(json);

  /// Total number of completed items
  int get totalItems => itemsByCategory.values.fold(0, (sum, items) => sum + items.length);

  /// Check if there are any items
  bool get hasItems => totalItems > 0;

  /// Check if there are any ratings
  bool get hasRatings => stats.tripAverage != null;
}

@freezed
class StaySummary with _$StaySummary {
  const factory StaySummary({
    required int id,
    required String title,
    String? city,
    String? country,
    DateTime? checkIn,
    DateTime? checkOut,
  }) = _StaySummary;

  factory StaySummary.fromJson(Map<String, dynamic> json) =>
      _$StaySummaryFromJson(json);
}

@freezed
class HighlightsStats with _$HighlightsStats {
  const factory HighlightsStats({
    double? tripAverage,
    UserStats? userStats,
    @Default([]) List<CollaboratorStats> collaboratorStats,
  }) = _HighlightsStats;

  factory HighlightsStats.fromJson(Map<String, dynamic> json) =>
      _$HighlightsStatsFromJson(json);
}

@freezed
class UserStats with _$UserStats {
  const factory UserStats({
    required double average,
    required int count,
    @Default([0, 0, 0, 0, 0]) List<int> distribution,
  }) = _UserStats;

  factory UserStats.fromJson(Map<String, dynamic> json) =>
      _$UserStatsFromJson(json);
}

@freezed
class CollaboratorStats with _$CollaboratorStats {
  const factory CollaboratorStats({
    required UserInfo user,
    UserStats? stats,
  }) = _CollaboratorStats;

  factory CollaboratorStats.fromJson(Map<String, dynamic> json) =>
      _$CollaboratorStatsFromJson(json);
}

@freezed
class UserInfo with _$UserInfo {
  const factory UserInfo({
    required int id,
    required String name,
    String? avatarUrl,
  }) = _UserInfo;

  factory UserInfo.fromJson(Map<String, dynamic> json) =>
      _$UserInfoFromJson(json);
}

@freezed
class HighlightItem with _$HighlightItem {
  const HighlightItem._();

  const factory HighlightItem({
    required int id,
    required String title,
    String? address,
    @Default('other') String category,
    DateTime? completedAt,
    double? averageRating,
    @Default([]) List<ItemRating> ratings,
  }) = _HighlightItem;

  factory HighlightItem.fromJson(Map<String, dynamic> json) =>
      _$HighlightItemFromJson(json);

  /// Check if item has ratings
  bool get hasRatings => ratings.isNotEmpty;

  /// Get rating count
  int get ratingCount => ratings.length;
}

@freezed
class ItemRating with _$ItemRating {
  const factory ItemRating({
    required int userId,
    required String userName,
    String? avatarUrl,
    required int rating,
  }) = _ItemRating;

  factory ItemRating.fromJson(Map<String, dynamic> json) =>
      _$ItemRatingFromJson(json);
}
