// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'stay_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Stay _$StayFromJson(Map<String, dynamic> json) {
  return _Stay.fromJson(json);
}

/// @nodoc
mixin _$Stay {
  int get id => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String? get stayType => throw _privateConstructorUsedError;
  String? get bookingUrl => throw _privateConstructorUsedError;
  String? get imageUrl => throw _privateConstructorUsedError;
  String? get address => throw _privateConstructorUsedError;
  String get city => throw _privateConstructorUsedError;
  String? get state => throw _privateConstructorUsedError;
  String? get country => throw _privateConstructorUsedError;
  double? get latitude => throw _privateConstructorUsedError;
  double? get longitude => throw _privateConstructorUsedError;
  DateTime? get checkIn => throw _privateConstructorUsedError;
  DateTime? get checkOut => throw _privateConstructorUsedError;
  int? get priceTotalCents => throw _privateConstructorUsedError;
  String get currency => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  bool get booked => throw _privateConstructorUsedError;
  bool get isWishlist => throw _privateConstructorUsedError;
  int get durationDays => throw _privateConstructorUsedError;
  int? get daysUntilCheckIn => throw _privateConstructorUsedError;
  bool get isOwner => throw _privateConstructorUsedError;
  bool get canEdit =>
      throw _privateConstructorUsedError; // Full details (only present when fetching single stay)
  String? get notes => throw _privateConstructorUsedError;
  Map<String, dynamic>? get weather => throw _privateConstructorUsedError;
  int get bucketListCount => throw _privateConstructorUsedError;
  int get bucketListCompletedCount => throw _privateConstructorUsedError;
  int get collaboratorCount => throw _privateConstructorUsedError;

  /// Serializes this Stay to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Stay
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $StayCopyWith<Stay> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $StayCopyWith<$Res> {
  factory $StayCopyWith(Stay value, $Res Function(Stay) then) =
      _$StayCopyWithImpl<$Res, Stay>;
  @useResult
  $Res call({
    int id,
    String title,
    String? stayType,
    String? bookingUrl,
    String? imageUrl,
    String? address,
    String city,
    String? state,
    String? country,
    double? latitude,
    double? longitude,
    DateTime? checkIn,
    DateTime? checkOut,
    int? priceTotalCents,
    String currency,
    String status,
    bool booked,
    bool isWishlist,
    int durationDays,
    int? daysUntilCheckIn,
    bool isOwner,
    bool canEdit,
    String? notes,
    Map<String, dynamic>? weather,
    int bucketListCount,
    int bucketListCompletedCount,
    int collaboratorCount,
  });
}

/// @nodoc
class _$StayCopyWithImpl<$Res, $Val extends Stay>
    implements $StayCopyWith<$Res> {
  _$StayCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Stay
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? stayType = freezed,
    Object? bookingUrl = freezed,
    Object? imageUrl = freezed,
    Object? address = freezed,
    Object? city = null,
    Object? state = freezed,
    Object? country = freezed,
    Object? latitude = freezed,
    Object? longitude = freezed,
    Object? checkIn = freezed,
    Object? checkOut = freezed,
    Object? priceTotalCents = freezed,
    Object? currency = null,
    Object? status = null,
    Object? booked = null,
    Object? isWishlist = null,
    Object? durationDays = null,
    Object? daysUntilCheckIn = freezed,
    Object? isOwner = null,
    Object? canEdit = null,
    Object? notes = freezed,
    Object? weather = freezed,
    Object? bucketListCount = null,
    Object? bucketListCompletedCount = null,
    Object? collaboratorCount = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as int,
            title: null == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                      as String,
            stayType: freezed == stayType
                ? _value.stayType
                : stayType // ignore: cast_nullable_to_non_nullable
                      as String?,
            bookingUrl: freezed == bookingUrl
                ? _value.bookingUrl
                : bookingUrl // ignore: cast_nullable_to_non_nullable
                      as String?,
            imageUrl: freezed == imageUrl
                ? _value.imageUrl
                : imageUrl // ignore: cast_nullable_to_non_nullable
                      as String?,
            address: freezed == address
                ? _value.address
                : address // ignore: cast_nullable_to_non_nullable
                      as String?,
            city: null == city
                ? _value.city
                : city // ignore: cast_nullable_to_non_nullable
                      as String,
            state: freezed == state
                ? _value.state
                : state // ignore: cast_nullable_to_non_nullable
                      as String?,
            country: freezed == country
                ? _value.country
                : country // ignore: cast_nullable_to_non_nullable
                      as String?,
            latitude: freezed == latitude
                ? _value.latitude
                : latitude // ignore: cast_nullable_to_non_nullable
                      as double?,
            longitude: freezed == longitude
                ? _value.longitude
                : longitude // ignore: cast_nullable_to_non_nullable
                      as double?,
            checkIn: freezed == checkIn
                ? _value.checkIn
                : checkIn // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            checkOut: freezed == checkOut
                ? _value.checkOut
                : checkOut // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            priceTotalCents: freezed == priceTotalCents
                ? _value.priceTotalCents
                : priceTotalCents // ignore: cast_nullable_to_non_nullable
                      as int?,
            currency: null == currency
                ? _value.currency
                : currency // ignore: cast_nullable_to_non_nullable
                      as String,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as String,
            booked: null == booked
                ? _value.booked
                : booked // ignore: cast_nullable_to_non_nullable
                      as bool,
            isWishlist: null == isWishlist
                ? _value.isWishlist
                : isWishlist // ignore: cast_nullable_to_non_nullable
                      as bool,
            durationDays: null == durationDays
                ? _value.durationDays
                : durationDays // ignore: cast_nullable_to_non_nullable
                      as int,
            daysUntilCheckIn: freezed == daysUntilCheckIn
                ? _value.daysUntilCheckIn
                : daysUntilCheckIn // ignore: cast_nullable_to_non_nullable
                      as int?,
            isOwner: null == isOwner
                ? _value.isOwner
                : isOwner // ignore: cast_nullable_to_non_nullable
                      as bool,
            canEdit: null == canEdit
                ? _value.canEdit
                : canEdit // ignore: cast_nullable_to_non_nullable
                      as bool,
            notes: freezed == notes
                ? _value.notes
                : notes // ignore: cast_nullable_to_non_nullable
                      as String?,
            weather: freezed == weather
                ? _value.weather
                : weather // ignore: cast_nullable_to_non_nullable
                      as Map<String, dynamic>?,
            bucketListCount: null == bucketListCount
                ? _value.bucketListCount
                : bucketListCount // ignore: cast_nullable_to_non_nullable
                      as int,
            bucketListCompletedCount: null == bucketListCompletedCount
                ? _value.bucketListCompletedCount
                : bucketListCompletedCount // ignore: cast_nullable_to_non_nullable
                      as int,
            collaboratorCount: null == collaboratorCount
                ? _value.collaboratorCount
                : collaboratorCount // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$StayImplCopyWith<$Res> implements $StayCopyWith<$Res> {
  factory _$$StayImplCopyWith(
    _$StayImpl value,
    $Res Function(_$StayImpl) then,
  ) = __$$StayImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int id,
    String title,
    String? stayType,
    String? bookingUrl,
    String? imageUrl,
    String? address,
    String city,
    String? state,
    String? country,
    double? latitude,
    double? longitude,
    DateTime? checkIn,
    DateTime? checkOut,
    int? priceTotalCents,
    String currency,
    String status,
    bool booked,
    bool isWishlist,
    int durationDays,
    int? daysUntilCheckIn,
    bool isOwner,
    bool canEdit,
    String? notes,
    Map<String, dynamic>? weather,
    int bucketListCount,
    int bucketListCompletedCount,
    int collaboratorCount,
  });
}

/// @nodoc
class __$$StayImplCopyWithImpl<$Res>
    extends _$StayCopyWithImpl<$Res, _$StayImpl>
    implements _$$StayImplCopyWith<$Res> {
  __$$StayImplCopyWithImpl(_$StayImpl _value, $Res Function(_$StayImpl) _then)
    : super(_value, _then);

  /// Create a copy of Stay
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? stayType = freezed,
    Object? bookingUrl = freezed,
    Object? imageUrl = freezed,
    Object? address = freezed,
    Object? city = null,
    Object? state = freezed,
    Object? country = freezed,
    Object? latitude = freezed,
    Object? longitude = freezed,
    Object? checkIn = freezed,
    Object? checkOut = freezed,
    Object? priceTotalCents = freezed,
    Object? currency = null,
    Object? status = null,
    Object? booked = null,
    Object? isWishlist = null,
    Object? durationDays = null,
    Object? daysUntilCheckIn = freezed,
    Object? isOwner = null,
    Object? canEdit = null,
    Object? notes = freezed,
    Object? weather = freezed,
    Object? bucketListCount = null,
    Object? bucketListCompletedCount = null,
    Object? collaboratorCount = null,
  }) {
    return _then(
      _$StayImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as int,
        title: null == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String,
        stayType: freezed == stayType
            ? _value.stayType
            : stayType // ignore: cast_nullable_to_non_nullable
                  as String?,
        bookingUrl: freezed == bookingUrl
            ? _value.bookingUrl
            : bookingUrl // ignore: cast_nullable_to_non_nullable
                  as String?,
        imageUrl: freezed == imageUrl
            ? _value.imageUrl
            : imageUrl // ignore: cast_nullable_to_non_nullable
                  as String?,
        address: freezed == address
            ? _value.address
            : address // ignore: cast_nullable_to_non_nullable
                  as String?,
        city: null == city
            ? _value.city
            : city // ignore: cast_nullable_to_non_nullable
                  as String,
        state: freezed == state
            ? _value.state
            : state // ignore: cast_nullable_to_non_nullable
                  as String?,
        country: freezed == country
            ? _value.country
            : country // ignore: cast_nullable_to_non_nullable
                  as String?,
        latitude: freezed == latitude
            ? _value.latitude
            : latitude // ignore: cast_nullable_to_non_nullable
                  as double?,
        longitude: freezed == longitude
            ? _value.longitude
            : longitude // ignore: cast_nullable_to_non_nullable
                  as double?,
        checkIn: freezed == checkIn
            ? _value.checkIn
            : checkIn // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        checkOut: freezed == checkOut
            ? _value.checkOut
            : checkOut // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        priceTotalCents: freezed == priceTotalCents
            ? _value.priceTotalCents
            : priceTotalCents // ignore: cast_nullable_to_non_nullable
                  as int?,
        currency: null == currency
            ? _value.currency
            : currency // ignore: cast_nullable_to_non_nullable
                  as String,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as String,
        booked: null == booked
            ? _value.booked
            : booked // ignore: cast_nullable_to_non_nullable
                  as bool,
        isWishlist: null == isWishlist
            ? _value.isWishlist
            : isWishlist // ignore: cast_nullable_to_non_nullable
                  as bool,
        durationDays: null == durationDays
            ? _value.durationDays
            : durationDays // ignore: cast_nullable_to_non_nullable
                  as int,
        daysUntilCheckIn: freezed == daysUntilCheckIn
            ? _value.daysUntilCheckIn
            : daysUntilCheckIn // ignore: cast_nullable_to_non_nullable
                  as int?,
        isOwner: null == isOwner
            ? _value.isOwner
            : isOwner // ignore: cast_nullable_to_non_nullable
                  as bool,
        canEdit: null == canEdit
            ? _value.canEdit
            : canEdit // ignore: cast_nullable_to_non_nullable
                  as bool,
        notes: freezed == notes
            ? _value.notes
            : notes // ignore: cast_nullable_to_non_nullable
                  as String?,
        weather: freezed == weather
            ? _value._weather
            : weather // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>?,
        bucketListCount: null == bucketListCount
            ? _value.bucketListCount
            : bucketListCount // ignore: cast_nullable_to_non_nullable
                  as int,
        bucketListCompletedCount: null == bucketListCompletedCount
            ? _value.bucketListCompletedCount
            : bucketListCompletedCount // ignore: cast_nullable_to_non_nullable
                  as int,
        collaboratorCount: null == collaboratorCount
            ? _value.collaboratorCount
            : collaboratorCount // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$StayImpl extends _Stay {
  const _$StayImpl({
    required this.id,
    required this.title,
    this.stayType,
    this.bookingUrl,
    this.imageUrl,
    this.address,
    required this.city,
    this.state,
    this.country,
    this.latitude,
    this.longitude,
    this.checkIn,
    this.checkOut,
    this.priceTotalCents,
    this.currency = 'USD',
    required this.status,
    this.booked = false,
    this.isWishlist = false,
    this.durationDays = 0,
    this.daysUntilCheckIn,
    this.isOwner = false,
    this.canEdit = false,
    this.notes,
    final Map<String, dynamic>? weather,
    this.bucketListCount = 0,
    this.bucketListCompletedCount = 0,
    this.collaboratorCount = 0,
  }) : _weather = weather,
       super._();

  factory _$StayImpl.fromJson(Map<String, dynamic> json) =>
      _$$StayImplFromJson(json);

  @override
  final int id;
  @override
  final String title;
  @override
  final String? stayType;
  @override
  final String? bookingUrl;
  @override
  final String? imageUrl;
  @override
  final String? address;
  @override
  final String city;
  @override
  final String? state;
  @override
  final String? country;
  @override
  final double? latitude;
  @override
  final double? longitude;
  @override
  final DateTime? checkIn;
  @override
  final DateTime? checkOut;
  @override
  final int? priceTotalCents;
  @override
  @JsonKey()
  final String currency;
  @override
  final String status;
  @override
  @JsonKey()
  final bool booked;
  @override
  @JsonKey()
  final bool isWishlist;
  @override
  @JsonKey()
  final int durationDays;
  @override
  final int? daysUntilCheckIn;
  @override
  @JsonKey()
  final bool isOwner;
  @override
  @JsonKey()
  final bool canEdit;
  // Full details (only present when fetching single stay)
  @override
  final String? notes;
  final Map<String, dynamic>? _weather;
  @override
  Map<String, dynamic>? get weather {
    final value = _weather;
    if (value == null) return null;
    if (_weather is EqualUnmodifiableMapView) return _weather;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  @JsonKey()
  final int bucketListCount;
  @override
  @JsonKey()
  final int bucketListCompletedCount;
  @override
  @JsonKey()
  final int collaboratorCount;

  @override
  String toString() {
    return 'Stay(id: $id, title: $title, stayType: $stayType, bookingUrl: $bookingUrl, imageUrl: $imageUrl, address: $address, city: $city, state: $state, country: $country, latitude: $latitude, longitude: $longitude, checkIn: $checkIn, checkOut: $checkOut, priceTotalCents: $priceTotalCents, currency: $currency, status: $status, booked: $booked, isWishlist: $isWishlist, durationDays: $durationDays, daysUntilCheckIn: $daysUntilCheckIn, isOwner: $isOwner, canEdit: $canEdit, notes: $notes, weather: $weather, bucketListCount: $bucketListCount, bucketListCompletedCount: $bucketListCompletedCount, collaboratorCount: $collaboratorCount)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$StayImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.stayType, stayType) ||
                other.stayType == stayType) &&
            (identical(other.bookingUrl, bookingUrl) ||
                other.bookingUrl == bookingUrl) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl) &&
            (identical(other.address, address) || other.address == address) &&
            (identical(other.city, city) || other.city == city) &&
            (identical(other.state, state) || other.state == state) &&
            (identical(other.country, country) || other.country == country) &&
            (identical(other.latitude, latitude) ||
                other.latitude == latitude) &&
            (identical(other.longitude, longitude) ||
                other.longitude == longitude) &&
            (identical(other.checkIn, checkIn) || other.checkIn == checkIn) &&
            (identical(other.checkOut, checkOut) ||
                other.checkOut == checkOut) &&
            (identical(other.priceTotalCents, priceTotalCents) ||
                other.priceTotalCents == priceTotalCents) &&
            (identical(other.currency, currency) ||
                other.currency == currency) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.booked, booked) || other.booked == booked) &&
            (identical(other.isWishlist, isWishlist) ||
                other.isWishlist == isWishlist) &&
            (identical(other.durationDays, durationDays) ||
                other.durationDays == durationDays) &&
            (identical(other.daysUntilCheckIn, daysUntilCheckIn) ||
                other.daysUntilCheckIn == daysUntilCheckIn) &&
            (identical(other.isOwner, isOwner) || other.isOwner == isOwner) &&
            (identical(other.canEdit, canEdit) || other.canEdit == canEdit) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            const DeepCollectionEquality().equals(other._weather, _weather) &&
            (identical(other.bucketListCount, bucketListCount) ||
                other.bucketListCount == bucketListCount) &&
            (identical(
                  other.bucketListCompletedCount,
                  bucketListCompletedCount,
                ) ||
                other.bucketListCompletedCount == bucketListCompletedCount) &&
            (identical(other.collaboratorCount, collaboratorCount) ||
                other.collaboratorCount == collaboratorCount));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
    runtimeType,
    id,
    title,
    stayType,
    bookingUrl,
    imageUrl,
    address,
    city,
    state,
    country,
    latitude,
    longitude,
    checkIn,
    checkOut,
    priceTotalCents,
    currency,
    status,
    booked,
    isWishlist,
    durationDays,
    daysUntilCheckIn,
    isOwner,
    canEdit,
    notes,
    const DeepCollectionEquality().hash(_weather),
    bucketListCount,
    bucketListCompletedCount,
    collaboratorCount,
  ]);

  /// Create a copy of Stay
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$StayImplCopyWith<_$StayImpl> get copyWith =>
      __$$StayImplCopyWithImpl<_$StayImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$StayImplToJson(this);
  }
}

abstract class _Stay extends Stay {
  const factory _Stay({
    required final int id,
    required final String title,
    final String? stayType,
    final String? bookingUrl,
    final String? imageUrl,
    final String? address,
    required final String city,
    final String? state,
    final String? country,
    final double? latitude,
    final double? longitude,
    final DateTime? checkIn,
    final DateTime? checkOut,
    final int? priceTotalCents,
    final String currency,
    required final String status,
    final bool booked,
    final bool isWishlist,
    final int durationDays,
    final int? daysUntilCheckIn,
    final bool isOwner,
    final bool canEdit,
    final String? notes,
    final Map<String, dynamic>? weather,
    final int bucketListCount,
    final int bucketListCompletedCount,
    final int collaboratorCount,
  }) = _$StayImpl;
  const _Stay._() : super._();

  factory _Stay.fromJson(Map<String, dynamic> json) = _$StayImpl.fromJson;

  @override
  int get id;
  @override
  String get title;
  @override
  String? get stayType;
  @override
  String? get bookingUrl;
  @override
  String? get imageUrl;
  @override
  String? get address;
  @override
  String get city;
  @override
  String? get state;
  @override
  String? get country;
  @override
  double? get latitude;
  @override
  double? get longitude;
  @override
  DateTime? get checkIn;
  @override
  DateTime? get checkOut;
  @override
  int? get priceTotalCents;
  @override
  String get currency;
  @override
  String get status;
  @override
  bool get booked;
  @override
  bool get isWishlist;
  @override
  int get durationDays;
  @override
  int? get daysUntilCheckIn;
  @override
  bool get isOwner;
  @override
  bool get canEdit; // Full details (only present when fetching single stay)
  @override
  String? get notes;
  @override
  Map<String, dynamic>? get weather;
  @override
  int get bucketListCount;
  @override
  int get bucketListCompletedCount;
  @override
  int get collaboratorCount;

  /// Create a copy of Stay
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$StayImplCopyWith<_$StayImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

StayRequest _$StayRequestFromJson(Map<String, dynamic> json) {
  return _StayRequest.fromJson(json);
}

/// @nodoc
mixin _$StayRequest {
  String get title => throw _privateConstructorUsedError;
  String? get stayType => throw _privateConstructorUsedError;
  String? get bookingUrl => throw _privateConstructorUsedError;
  String? get imageUrl => throw _privateConstructorUsedError;
  String? get address => throw _privateConstructorUsedError;
  String get city => throw _privateConstructorUsedError;
  String? get state => throw _privateConstructorUsedError;
  String? get country => throw _privateConstructorUsedError;
  DateTime? get checkIn => throw _privateConstructorUsedError;
  DateTime? get checkOut => throw _privateConstructorUsedError;
  double? get priceTotalDollars => throw _privateConstructorUsedError;
  String get currency => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;
  bool get booked => throw _privateConstructorUsedError;

  /// Serializes this StayRequest to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of StayRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $StayRequestCopyWith<StayRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $StayRequestCopyWith<$Res> {
  factory $StayRequestCopyWith(
    StayRequest value,
    $Res Function(StayRequest) then,
  ) = _$StayRequestCopyWithImpl<$Res, StayRequest>;
  @useResult
  $Res call({
    String title,
    String? stayType,
    String? bookingUrl,
    String? imageUrl,
    String? address,
    String city,
    String? state,
    String? country,
    DateTime? checkIn,
    DateTime? checkOut,
    double? priceTotalDollars,
    String currency,
    String? notes,
    bool booked,
  });
}

/// @nodoc
class _$StayRequestCopyWithImpl<$Res, $Val extends StayRequest>
    implements $StayRequestCopyWith<$Res> {
  _$StayRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of StayRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? title = null,
    Object? stayType = freezed,
    Object? bookingUrl = freezed,
    Object? imageUrl = freezed,
    Object? address = freezed,
    Object? city = null,
    Object? state = freezed,
    Object? country = freezed,
    Object? checkIn = freezed,
    Object? checkOut = freezed,
    Object? priceTotalDollars = freezed,
    Object? currency = null,
    Object? notes = freezed,
    Object? booked = null,
  }) {
    return _then(
      _value.copyWith(
            title: null == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                      as String,
            stayType: freezed == stayType
                ? _value.stayType
                : stayType // ignore: cast_nullable_to_non_nullable
                      as String?,
            bookingUrl: freezed == bookingUrl
                ? _value.bookingUrl
                : bookingUrl // ignore: cast_nullable_to_non_nullable
                      as String?,
            imageUrl: freezed == imageUrl
                ? _value.imageUrl
                : imageUrl // ignore: cast_nullable_to_non_nullable
                      as String?,
            address: freezed == address
                ? _value.address
                : address // ignore: cast_nullable_to_non_nullable
                      as String?,
            city: null == city
                ? _value.city
                : city // ignore: cast_nullable_to_non_nullable
                      as String,
            state: freezed == state
                ? _value.state
                : state // ignore: cast_nullable_to_non_nullable
                      as String?,
            country: freezed == country
                ? _value.country
                : country // ignore: cast_nullable_to_non_nullable
                      as String?,
            checkIn: freezed == checkIn
                ? _value.checkIn
                : checkIn // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            checkOut: freezed == checkOut
                ? _value.checkOut
                : checkOut // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            priceTotalDollars: freezed == priceTotalDollars
                ? _value.priceTotalDollars
                : priceTotalDollars // ignore: cast_nullable_to_non_nullable
                      as double?,
            currency: null == currency
                ? _value.currency
                : currency // ignore: cast_nullable_to_non_nullable
                      as String,
            notes: freezed == notes
                ? _value.notes
                : notes // ignore: cast_nullable_to_non_nullable
                      as String?,
            booked: null == booked
                ? _value.booked
                : booked // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$StayRequestImplCopyWith<$Res>
    implements $StayRequestCopyWith<$Res> {
  factory _$$StayRequestImplCopyWith(
    _$StayRequestImpl value,
    $Res Function(_$StayRequestImpl) then,
  ) = __$$StayRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String title,
    String? stayType,
    String? bookingUrl,
    String? imageUrl,
    String? address,
    String city,
    String? state,
    String? country,
    DateTime? checkIn,
    DateTime? checkOut,
    double? priceTotalDollars,
    String currency,
    String? notes,
    bool booked,
  });
}

/// @nodoc
class __$$StayRequestImplCopyWithImpl<$Res>
    extends _$StayRequestCopyWithImpl<$Res, _$StayRequestImpl>
    implements _$$StayRequestImplCopyWith<$Res> {
  __$$StayRequestImplCopyWithImpl(
    _$StayRequestImpl _value,
    $Res Function(_$StayRequestImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of StayRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? title = null,
    Object? stayType = freezed,
    Object? bookingUrl = freezed,
    Object? imageUrl = freezed,
    Object? address = freezed,
    Object? city = null,
    Object? state = freezed,
    Object? country = freezed,
    Object? checkIn = freezed,
    Object? checkOut = freezed,
    Object? priceTotalDollars = freezed,
    Object? currency = null,
    Object? notes = freezed,
    Object? booked = null,
  }) {
    return _then(
      _$StayRequestImpl(
        title: null == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String,
        stayType: freezed == stayType
            ? _value.stayType
            : stayType // ignore: cast_nullable_to_non_nullable
                  as String?,
        bookingUrl: freezed == bookingUrl
            ? _value.bookingUrl
            : bookingUrl // ignore: cast_nullable_to_non_nullable
                  as String?,
        imageUrl: freezed == imageUrl
            ? _value.imageUrl
            : imageUrl // ignore: cast_nullable_to_non_nullable
                  as String?,
        address: freezed == address
            ? _value.address
            : address // ignore: cast_nullable_to_non_nullable
                  as String?,
        city: null == city
            ? _value.city
            : city // ignore: cast_nullable_to_non_nullable
                  as String,
        state: freezed == state
            ? _value.state
            : state // ignore: cast_nullable_to_non_nullable
                  as String?,
        country: freezed == country
            ? _value.country
            : country // ignore: cast_nullable_to_non_nullable
                  as String?,
        checkIn: freezed == checkIn
            ? _value.checkIn
            : checkIn // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        checkOut: freezed == checkOut
            ? _value.checkOut
            : checkOut // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        priceTotalDollars: freezed == priceTotalDollars
            ? _value.priceTotalDollars
            : priceTotalDollars // ignore: cast_nullable_to_non_nullable
                  as double?,
        currency: null == currency
            ? _value.currency
            : currency // ignore: cast_nullable_to_non_nullable
                  as String,
        notes: freezed == notes
            ? _value.notes
            : notes // ignore: cast_nullable_to_non_nullable
                  as String?,
        booked: null == booked
            ? _value.booked
            : booked // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$StayRequestImpl implements _StayRequest {
  const _$StayRequestImpl({
    required this.title,
    this.stayType,
    this.bookingUrl,
    this.imageUrl,
    this.address,
    required this.city,
    this.state,
    this.country,
    this.checkIn,
    this.checkOut,
    this.priceTotalDollars,
    this.currency = 'USD',
    this.notes,
    this.booked = false,
  });

  factory _$StayRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$StayRequestImplFromJson(json);

  @override
  final String title;
  @override
  final String? stayType;
  @override
  final String? bookingUrl;
  @override
  final String? imageUrl;
  @override
  final String? address;
  @override
  final String city;
  @override
  final String? state;
  @override
  final String? country;
  @override
  final DateTime? checkIn;
  @override
  final DateTime? checkOut;
  @override
  final double? priceTotalDollars;
  @override
  @JsonKey()
  final String currency;
  @override
  final String? notes;
  @override
  @JsonKey()
  final bool booked;

  @override
  String toString() {
    return 'StayRequest(title: $title, stayType: $stayType, bookingUrl: $bookingUrl, imageUrl: $imageUrl, address: $address, city: $city, state: $state, country: $country, checkIn: $checkIn, checkOut: $checkOut, priceTotalDollars: $priceTotalDollars, currency: $currency, notes: $notes, booked: $booked)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$StayRequestImpl &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.stayType, stayType) ||
                other.stayType == stayType) &&
            (identical(other.bookingUrl, bookingUrl) ||
                other.bookingUrl == bookingUrl) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl) &&
            (identical(other.address, address) || other.address == address) &&
            (identical(other.city, city) || other.city == city) &&
            (identical(other.state, state) || other.state == state) &&
            (identical(other.country, country) || other.country == country) &&
            (identical(other.checkIn, checkIn) || other.checkIn == checkIn) &&
            (identical(other.checkOut, checkOut) ||
                other.checkOut == checkOut) &&
            (identical(other.priceTotalDollars, priceTotalDollars) ||
                other.priceTotalDollars == priceTotalDollars) &&
            (identical(other.currency, currency) ||
                other.currency == currency) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.booked, booked) || other.booked == booked));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    title,
    stayType,
    bookingUrl,
    imageUrl,
    address,
    city,
    state,
    country,
    checkIn,
    checkOut,
    priceTotalDollars,
    currency,
    notes,
    booked,
  );

  /// Create a copy of StayRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$StayRequestImplCopyWith<_$StayRequestImpl> get copyWith =>
      __$$StayRequestImplCopyWithImpl<_$StayRequestImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$StayRequestImplToJson(this);
  }
}

abstract class _StayRequest implements StayRequest {
  const factory _StayRequest({
    required final String title,
    final String? stayType,
    final String? bookingUrl,
    final String? imageUrl,
    final String? address,
    required final String city,
    final String? state,
    final String? country,
    final DateTime? checkIn,
    final DateTime? checkOut,
    final double? priceTotalDollars,
    final String currency,
    final String? notes,
    final bool booked,
  }) = _$StayRequestImpl;

  factory _StayRequest.fromJson(Map<String, dynamic> json) =
      _$StayRequestImpl.fromJson;

  @override
  String get title;
  @override
  String? get stayType;
  @override
  String? get bookingUrl;
  @override
  String? get imageUrl;
  @override
  String? get address;
  @override
  String get city;
  @override
  String? get state;
  @override
  String? get country;
  @override
  DateTime? get checkIn;
  @override
  DateTime? get checkOut;
  @override
  double? get priceTotalDollars;
  @override
  String get currency;
  @override
  String? get notes;
  @override
  bool get booked;

  /// Create a copy of StayRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$StayRequestImplCopyWith<_$StayRequestImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
