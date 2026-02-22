import 'package:freezed_annotation/freezed_annotation.dart';

part 'bucket_list_item_model.freezed.dart';
part 'bucket_list_item_model.g.dart';

@freezed
class BucketListItem with _$BucketListItem {
  const BucketListItem._();

  const factory BucketListItem({
    required int id,
    required String title,
    String? category,
    String? notes,
    String? address,
    double? latitude,
    double? longitude,
    @Default(false) bool completed,
    DateTime? completedAt,
    required int stayId,
    int? placeId,
    double? averageRating,
    int? userRating,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _BucketListItem;

  factory BucketListItem.fromJson(Map<String, dynamic> json) =>
      _$BucketListItemFromJson(json);

  /// Returns the category display name
  String get categoryDisplay {
    if (category == null || category!.isEmpty) return 'Other';
    return category!.replaceAll('_', ' ').split(' ')
        .map((word) => word.isNotEmpty ? '${word[0].toUpperCase()}${word.substring(1)}' : '')
        .join(' ');
  }

  /// Check if item has a location
  bool get hasLocation => latitude != null && longitude != null;

  /// Check if item has a rating
  bool get hasRating => averageRating != null && averageRating! > 0;
}

/// Request model for creating/updating a bucket list item
@freezed
class BucketListItemRequest with _$BucketListItemRequest {
  const factory BucketListItemRequest({
    required String title,
    String? category,
    String? notes,
    String? address,
    double? latitude,
    double? longitude,
    int? placeId,
  }) = _BucketListItemRequest;

  factory BucketListItemRequest.fromJson(Map<String, dynamic> json) =>
      _$BucketListItemRequestFromJson(json);
}
