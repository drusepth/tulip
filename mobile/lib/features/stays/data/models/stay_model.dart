import 'package:freezed_annotation/freezed_annotation.dart';

part 'stay_model.freezed.dart';
part 'stay_model.g.dart';

@freezed
class Stay with _$Stay {
  const Stay._();

  const factory Stay({
    required int id,
    required String title,
    String? stayType,
    String? bookingUrl,
    String? imageUrl,
    String? address,
    required String city,
    String? state,
    String? country,
    double? latitude,
    double? longitude,
    DateTime? checkIn,
    DateTime? checkOut,
    int? priceTotalCents,
    @Default('USD') String currency,
    required String status,
    @Default(false) bool booked,
    @Default(false) bool isWishlist,
    @Default(0) int durationDays,
    int? daysUntilCheckIn,
    @Default(false) bool isOwner,
    @Default(false) bool canEdit,
    // Full details (only present when fetching single stay)
    String? notes,
    Map<String, dynamic>? weather,
    @Default(0) int bucketListCount,
    @Default(0) int bucketListCompletedCount,
    @Default(0) int collaboratorCount,
  }) = _Stay;

  factory Stay.fromJson(Map<String, dynamic> json) => _$StayFromJson(json);

  /// Returns the location string (city, state/country)
  String get location {
    final parts = <String>[city];
    if (state != null && state!.isNotEmpty) {
      parts.add(state!);
    } else if (country != null && country!.isNotEmpty) {
      parts.add(country!);
    }
    return parts.join(', ');
  }

  /// Returns formatted price string
  String? get priceFormatted {
    if (priceTotalCents == null) return null;
    final dollars = priceTotalCents! / 100.0;
    return '$currency ${dollars.toStringAsFixed(2)}';
  }

  /// Returns per-night price if duration is known
  String? get pricePerNight {
    if (priceTotalCents == null || durationDays == 0) return null;
    final perNight = (priceTotalCents! / 100.0) / durationDays;
    return '$currency ${perNight.toStringAsFixed(0)}/night';
  }

  /// Check if stay is currently active
  bool get isCurrent => status == 'current';

  /// Check if stay is upcoming
  bool get isUpcoming => status == 'upcoming';

  /// Check if stay is past
  bool get isPast => status == 'past';

  /// Check if stay has valid coordinates
  bool get hasCoordinates => latitude != null && longitude != null;

  /// Returns formatted date range string
  String? get dateRange {
    if (checkIn == null || checkOut == null) return null;
    final checkInStr = _formatDate(checkIn!);
    final checkOutStr = _formatDate(checkOut!);
    return '$checkInStr - $checkOutStr';
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}';
  }
}

/// Request model for creating/updating a stay
@freezed
class StayRequest with _$StayRequest {
  const factory StayRequest({
    required String title,
    String? stayType,
    String? bookingUrl,
    String? imageUrl,
    String? address,
    required String city,
    String? state,
    String? country,
    DateTime? checkIn,
    DateTime? checkOut,
    double? priceTotalDollars,
    @Default('USD') String currency,
    String? notes,
    @Default(false) bool booked,
  }) = _StayRequest;

  factory StayRequest.fromJson(Map<String, dynamic> json) =>
      _$StayRequestFromJson(json);
}
