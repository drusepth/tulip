// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'poi_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Poi _$PoiFromJson(Map<String, dynamic> json) {
  return _Poi.fromJson(json);
}

/// @nodoc
mixin _$Poi {
  int get id => throw _privateConstructorUsedError;
  int? get placeId => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get category => throw _privateConstructorUsedError;
  double get latitude => throw _privateConstructorUsedError;
  double get longitude => throw _privateConstructorUsedError;
  int? get distanceMeters => throw _privateConstructorUsedError;
  String? get address => throw _privateConstructorUsedError;
  String? get openingHours => throw _privateConstructorUsedError;
  bool get favorite => throw _privateConstructorUsedError;
  double? get foursquareRating => throw _privateConstructorUsedError;
  int? get foursquarePrice => throw _privateConstructorUsedError;
  String? get foursquarePhotoUrl => throw _privateConstructorUsedError;

  /// Serializes this Poi to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Poi
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PoiCopyWith<Poi> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PoiCopyWith<$Res> {
  factory $PoiCopyWith(Poi value, $Res Function(Poi) then) =
      _$PoiCopyWithImpl<$Res, Poi>;
  @useResult
  $Res call({
    int id,
    int? placeId,
    String name,
    String category,
    double latitude,
    double longitude,
    int? distanceMeters,
    String? address,
    String? openingHours,
    bool favorite,
    double? foursquareRating,
    int? foursquarePrice,
    String? foursquarePhotoUrl,
  });
}

/// @nodoc
class _$PoiCopyWithImpl<$Res, $Val extends Poi> implements $PoiCopyWith<$Res> {
  _$PoiCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Poi
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? placeId = freezed,
    Object? name = null,
    Object? category = null,
    Object? latitude = null,
    Object? longitude = null,
    Object? distanceMeters = freezed,
    Object? address = freezed,
    Object? openingHours = freezed,
    Object? favorite = null,
    Object? foursquareRating = freezed,
    Object? foursquarePrice = freezed,
    Object? foursquarePhotoUrl = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as int,
            placeId: freezed == placeId
                ? _value.placeId
                : placeId // ignore: cast_nullable_to_non_nullable
                      as int?,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            category: null == category
                ? _value.category
                : category // ignore: cast_nullable_to_non_nullable
                      as String,
            latitude: null == latitude
                ? _value.latitude
                : latitude // ignore: cast_nullable_to_non_nullable
                      as double,
            longitude: null == longitude
                ? _value.longitude
                : longitude // ignore: cast_nullable_to_non_nullable
                      as double,
            distanceMeters: freezed == distanceMeters
                ? _value.distanceMeters
                : distanceMeters // ignore: cast_nullable_to_non_nullable
                      as int?,
            address: freezed == address
                ? _value.address
                : address // ignore: cast_nullable_to_non_nullable
                      as String?,
            openingHours: freezed == openingHours
                ? _value.openingHours
                : openingHours // ignore: cast_nullable_to_non_nullable
                      as String?,
            favorite: null == favorite
                ? _value.favorite
                : favorite // ignore: cast_nullable_to_non_nullable
                      as bool,
            foursquareRating: freezed == foursquareRating
                ? _value.foursquareRating
                : foursquareRating // ignore: cast_nullable_to_non_nullable
                      as double?,
            foursquarePrice: freezed == foursquarePrice
                ? _value.foursquarePrice
                : foursquarePrice // ignore: cast_nullable_to_non_nullable
                      as int?,
            foursquarePhotoUrl: freezed == foursquarePhotoUrl
                ? _value.foursquarePhotoUrl
                : foursquarePhotoUrl // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$PoiImplCopyWith<$Res> implements $PoiCopyWith<$Res> {
  factory _$$PoiImplCopyWith(_$PoiImpl value, $Res Function(_$PoiImpl) then) =
      __$$PoiImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int id,
    int? placeId,
    String name,
    String category,
    double latitude,
    double longitude,
    int? distanceMeters,
    String? address,
    String? openingHours,
    bool favorite,
    double? foursquareRating,
    int? foursquarePrice,
    String? foursquarePhotoUrl,
  });
}

/// @nodoc
class __$$PoiImplCopyWithImpl<$Res> extends _$PoiCopyWithImpl<$Res, _$PoiImpl>
    implements _$$PoiImplCopyWith<$Res> {
  __$$PoiImplCopyWithImpl(_$PoiImpl _value, $Res Function(_$PoiImpl) _then)
    : super(_value, _then);

  /// Create a copy of Poi
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? placeId = freezed,
    Object? name = null,
    Object? category = null,
    Object? latitude = null,
    Object? longitude = null,
    Object? distanceMeters = freezed,
    Object? address = freezed,
    Object? openingHours = freezed,
    Object? favorite = null,
    Object? foursquareRating = freezed,
    Object? foursquarePrice = freezed,
    Object? foursquarePhotoUrl = freezed,
  }) {
    return _then(
      _$PoiImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as int,
        placeId: freezed == placeId
            ? _value.placeId
            : placeId // ignore: cast_nullable_to_non_nullable
                  as int?,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        category: null == category
            ? _value.category
            : category // ignore: cast_nullable_to_non_nullable
                  as String,
        latitude: null == latitude
            ? _value.latitude
            : latitude // ignore: cast_nullable_to_non_nullable
                  as double,
        longitude: null == longitude
            ? _value.longitude
            : longitude // ignore: cast_nullable_to_non_nullable
                  as double,
        distanceMeters: freezed == distanceMeters
            ? _value.distanceMeters
            : distanceMeters // ignore: cast_nullable_to_non_nullable
                  as int?,
        address: freezed == address
            ? _value.address
            : address // ignore: cast_nullable_to_non_nullable
                  as String?,
        openingHours: freezed == openingHours
            ? _value.openingHours
            : openingHours // ignore: cast_nullable_to_non_nullable
                  as String?,
        favorite: null == favorite
            ? _value.favorite
            : favorite // ignore: cast_nullable_to_non_nullable
                  as bool,
        foursquareRating: freezed == foursquareRating
            ? _value.foursquareRating
            : foursquareRating // ignore: cast_nullable_to_non_nullable
                  as double?,
        foursquarePrice: freezed == foursquarePrice
            ? _value.foursquarePrice
            : foursquarePrice // ignore: cast_nullable_to_non_nullable
                  as int?,
        foursquarePhotoUrl: freezed == foursquarePhotoUrl
            ? _value.foursquarePhotoUrl
            : foursquarePhotoUrl // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$PoiImpl extends _Poi {
  const _$PoiImpl({
    required this.id,
    this.placeId,
    required this.name,
    required this.category,
    required this.latitude,
    required this.longitude,
    this.distanceMeters,
    this.address,
    this.openingHours,
    this.favorite = false,
    this.foursquareRating,
    this.foursquarePrice,
    this.foursquarePhotoUrl,
  }) : super._();

  factory _$PoiImpl.fromJson(Map<String, dynamic> json) =>
      _$$PoiImplFromJson(json);

  @override
  final int id;
  @override
  final int? placeId;
  @override
  final String name;
  @override
  final String category;
  @override
  final double latitude;
  @override
  final double longitude;
  @override
  final int? distanceMeters;
  @override
  final String? address;
  @override
  final String? openingHours;
  @override
  @JsonKey()
  final bool favorite;
  @override
  final double? foursquareRating;
  @override
  final int? foursquarePrice;
  @override
  final String? foursquarePhotoUrl;

  @override
  String toString() {
    return 'Poi(id: $id, placeId: $placeId, name: $name, category: $category, latitude: $latitude, longitude: $longitude, distanceMeters: $distanceMeters, address: $address, openingHours: $openingHours, favorite: $favorite, foursquareRating: $foursquareRating, foursquarePrice: $foursquarePrice, foursquarePhotoUrl: $foursquarePhotoUrl)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PoiImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.placeId, placeId) || other.placeId == placeId) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.latitude, latitude) ||
                other.latitude == latitude) &&
            (identical(other.longitude, longitude) ||
                other.longitude == longitude) &&
            (identical(other.distanceMeters, distanceMeters) ||
                other.distanceMeters == distanceMeters) &&
            (identical(other.address, address) || other.address == address) &&
            (identical(other.openingHours, openingHours) ||
                other.openingHours == openingHours) &&
            (identical(other.favorite, favorite) ||
                other.favorite == favorite) &&
            (identical(other.foursquareRating, foursquareRating) ||
                other.foursquareRating == foursquareRating) &&
            (identical(other.foursquarePrice, foursquarePrice) ||
                other.foursquarePrice == foursquarePrice) &&
            (identical(other.foursquarePhotoUrl, foursquarePhotoUrl) ||
                other.foursquarePhotoUrl == foursquarePhotoUrl));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    placeId,
    name,
    category,
    latitude,
    longitude,
    distanceMeters,
    address,
    openingHours,
    favorite,
    foursquareRating,
    foursquarePrice,
    foursquarePhotoUrl,
  );

  /// Create a copy of Poi
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PoiImplCopyWith<_$PoiImpl> get copyWith =>
      __$$PoiImplCopyWithImpl<_$PoiImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PoiImplToJson(this);
  }
}

abstract class _Poi extends Poi {
  const factory _Poi({
    required final int id,
    final int? placeId,
    required final String name,
    required final String category,
    required final double latitude,
    required final double longitude,
    final int? distanceMeters,
    final String? address,
    final String? openingHours,
    final bool favorite,
    final double? foursquareRating,
    final int? foursquarePrice,
    final String? foursquarePhotoUrl,
  }) = _$PoiImpl;
  const _Poi._() : super._();

  factory _Poi.fromJson(Map<String, dynamic> json) = _$PoiImpl.fromJson;

  @override
  int get id;
  @override
  int? get placeId;
  @override
  String get name;
  @override
  String get category;
  @override
  double get latitude;
  @override
  double get longitude;
  @override
  int? get distanceMeters;
  @override
  String? get address;
  @override
  String? get openingHours;
  @override
  bool get favorite;
  @override
  double? get foursquareRating;
  @override
  int? get foursquarePrice;
  @override
  String? get foursquarePhotoUrl;

  /// Create a copy of Poi
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PoiImplCopyWith<_$PoiImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

Place _$PlaceFromJson(Map<String, dynamic> json) {
  return _Place.fromJson(json);
}

/// @nodoc
mixin _$Place {
  int get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get category => throw _privateConstructorUsedError;
  double get latitude => throw _privateConstructorUsedError;
  double get longitude => throw _privateConstructorUsedError;
  String? get address => throw _privateConstructorUsedError;
  String? get openingHours => throw _privateConstructorUsedError;
  double? get foursquareRating => throw _privateConstructorUsedError;
  int? get foursquarePrice => throw _privateConstructorUsedError;
  String? get foursquarePhotoUrl => throw _privateConstructorUsedError;
  List<String>? get foursquareTips =>
      throw _privateConstructorUsedError; // Contextual data when viewing from a stay
  int? get distanceMeters => throw _privateConstructorUsedError;
  bool get favorite => throw _privateConstructorUsedError;
  bool get inBucketList => throw _privateConstructorUsedError;

  /// Serializes this Place to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Place
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PlaceCopyWith<Place> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PlaceCopyWith<$Res> {
  factory $PlaceCopyWith(Place value, $Res Function(Place) then) =
      _$PlaceCopyWithImpl<$Res, Place>;
  @useResult
  $Res call({
    int id,
    String name,
    String category,
    double latitude,
    double longitude,
    String? address,
    String? openingHours,
    double? foursquareRating,
    int? foursquarePrice,
    String? foursquarePhotoUrl,
    List<String>? foursquareTips,
    int? distanceMeters,
    bool favorite,
    bool inBucketList,
  });
}

/// @nodoc
class _$PlaceCopyWithImpl<$Res, $Val extends Place>
    implements $PlaceCopyWith<$Res> {
  _$PlaceCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Place
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? category = null,
    Object? latitude = null,
    Object? longitude = null,
    Object? address = freezed,
    Object? openingHours = freezed,
    Object? foursquareRating = freezed,
    Object? foursquarePrice = freezed,
    Object? foursquarePhotoUrl = freezed,
    Object? foursquareTips = freezed,
    Object? distanceMeters = freezed,
    Object? favorite = null,
    Object? inBucketList = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as int,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            category: null == category
                ? _value.category
                : category // ignore: cast_nullable_to_non_nullable
                      as String,
            latitude: null == latitude
                ? _value.latitude
                : latitude // ignore: cast_nullable_to_non_nullable
                      as double,
            longitude: null == longitude
                ? _value.longitude
                : longitude // ignore: cast_nullable_to_non_nullable
                      as double,
            address: freezed == address
                ? _value.address
                : address // ignore: cast_nullable_to_non_nullable
                      as String?,
            openingHours: freezed == openingHours
                ? _value.openingHours
                : openingHours // ignore: cast_nullable_to_non_nullable
                      as String?,
            foursquareRating: freezed == foursquareRating
                ? _value.foursquareRating
                : foursquareRating // ignore: cast_nullable_to_non_nullable
                      as double?,
            foursquarePrice: freezed == foursquarePrice
                ? _value.foursquarePrice
                : foursquarePrice // ignore: cast_nullable_to_non_nullable
                      as int?,
            foursquarePhotoUrl: freezed == foursquarePhotoUrl
                ? _value.foursquarePhotoUrl
                : foursquarePhotoUrl // ignore: cast_nullable_to_non_nullable
                      as String?,
            foursquareTips: freezed == foursquareTips
                ? _value.foursquareTips
                : foursquareTips // ignore: cast_nullable_to_non_nullable
                      as List<String>?,
            distanceMeters: freezed == distanceMeters
                ? _value.distanceMeters
                : distanceMeters // ignore: cast_nullable_to_non_nullable
                      as int?,
            favorite: null == favorite
                ? _value.favorite
                : favorite // ignore: cast_nullable_to_non_nullable
                      as bool,
            inBucketList: null == inBucketList
                ? _value.inBucketList
                : inBucketList // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$PlaceImplCopyWith<$Res> implements $PlaceCopyWith<$Res> {
  factory _$$PlaceImplCopyWith(
    _$PlaceImpl value,
    $Res Function(_$PlaceImpl) then,
  ) = __$$PlaceImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int id,
    String name,
    String category,
    double latitude,
    double longitude,
    String? address,
    String? openingHours,
    double? foursquareRating,
    int? foursquarePrice,
    String? foursquarePhotoUrl,
    List<String>? foursquareTips,
    int? distanceMeters,
    bool favorite,
    bool inBucketList,
  });
}

/// @nodoc
class __$$PlaceImplCopyWithImpl<$Res>
    extends _$PlaceCopyWithImpl<$Res, _$PlaceImpl>
    implements _$$PlaceImplCopyWith<$Res> {
  __$$PlaceImplCopyWithImpl(
    _$PlaceImpl _value,
    $Res Function(_$PlaceImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Place
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? category = null,
    Object? latitude = null,
    Object? longitude = null,
    Object? address = freezed,
    Object? openingHours = freezed,
    Object? foursquareRating = freezed,
    Object? foursquarePrice = freezed,
    Object? foursquarePhotoUrl = freezed,
    Object? foursquareTips = freezed,
    Object? distanceMeters = freezed,
    Object? favorite = null,
    Object? inBucketList = null,
  }) {
    return _then(
      _$PlaceImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as int,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        category: null == category
            ? _value.category
            : category // ignore: cast_nullable_to_non_nullable
                  as String,
        latitude: null == latitude
            ? _value.latitude
            : latitude // ignore: cast_nullable_to_non_nullable
                  as double,
        longitude: null == longitude
            ? _value.longitude
            : longitude // ignore: cast_nullable_to_non_nullable
                  as double,
        address: freezed == address
            ? _value.address
            : address // ignore: cast_nullable_to_non_nullable
                  as String?,
        openingHours: freezed == openingHours
            ? _value.openingHours
            : openingHours // ignore: cast_nullable_to_non_nullable
                  as String?,
        foursquareRating: freezed == foursquareRating
            ? _value.foursquareRating
            : foursquareRating // ignore: cast_nullable_to_non_nullable
                  as double?,
        foursquarePrice: freezed == foursquarePrice
            ? _value.foursquarePrice
            : foursquarePrice // ignore: cast_nullable_to_non_nullable
                  as int?,
        foursquarePhotoUrl: freezed == foursquarePhotoUrl
            ? _value.foursquarePhotoUrl
            : foursquarePhotoUrl // ignore: cast_nullable_to_non_nullable
                  as String?,
        foursquareTips: freezed == foursquareTips
            ? _value._foursquareTips
            : foursquareTips // ignore: cast_nullable_to_non_nullable
                  as List<String>?,
        distanceMeters: freezed == distanceMeters
            ? _value.distanceMeters
            : distanceMeters // ignore: cast_nullable_to_non_nullable
                  as int?,
        favorite: null == favorite
            ? _value.favorite
            : favorite // ignore: cast_nullable_to_non_nullable
                  as bool,
        inBucketList: null == inBucketList
            ? _value.inBucketList
            : inBucketList // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$PlaceImpl extends _Place {
  const _$PlaceImpl({
    required this.id,
    required this.name,
    required this.category,
    required this.latitude,
    required this.longitude,
    this.address,
    this.openingHours,
    this.foursquareRating,
    this.foursquarePrice,
    this.foursquarePhotoUrl,
    final List<String>? foursquareTips,
    this.distanceMeters,
    this.favorite = false,
    this.inBucketList = false,
  }) : _foursquareTips = foursquareTips,
       super._();

  factory _$PlaceImpl.fromJson(Map<String, dynamic> json) =>
      _$$PlaceImplFromJson(json);

  @override
  final int id;
  @override
  final String name;
  @override
  final String category;
  @override
  final double latitude;
  @override
  final double longitude;
  @override
  final String? address;
  @override
  final String? openingHours;
  @override
  final double? foursquareRating;
  @override
  final int? foursquarePrice;
  @override
  final String? foursquarePhotoUrl;
  final List<String>? _foursquareTips;
  @override
  List<String>? get foursquareTips {
    final value = _foursquareTips;
    if (value == null) return null;
    if (_foursquareTips is EqualUnmodifiableListView) return _foursquareTips;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  // Contextual data when viewing from a stay
  @override
  final int? distanceMeters;
  @override
  @JsonKey()
  final bool favorite;
  @override
  @JsonKey()
  final bool inBucketList;

  @override
  String toString() {
    return 'Place(id: $id, name: $name, category: $category, latitude: $latitude, longitude: $longitude, address: $address, openingHours: $openingHours, foursquareRating: $foursquareRating, foursquarePrice: $foursquarePrice, foursquarePhotoUrl: $foursquarePhotoUrl, foursquareTips: $foursquareTips, distanceMeters: $distanceMeters, favorite: $favorite, inBucketList: $inBucketList)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PlaceImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.latitude, latitude) ||
                other.latitude == latitude) &&
            (identical(other.longitude, longitude) ||
                other.longitude == longitude) &&
            (identical(other.address, address) || other.address == address) &&
            (identical(other.openingHours, openingHours) ||
                other.openingHours == openingHours) &&
            (identical(other.foursquareRating, foursquareRating) ||
                other.foursquareRating == foursquareRating) &&
            (identical(other.foursquarePrice, foursquarePrice) ||
                other.foursquarePrice == foursquarePrice) &&
            (identical(other.foursquarePhotoUrl, foursquarePhotoUrl) ||
                other.foursquarePhotoUrl == foursquarePhotoUrl) &&
            const DeepCollectionEquality().equals(
              other._foursquareTips,
              _foursquareTips,
            ) &&
            (identical(other.distanceMeters, distanceMeters) ||
                other.distanceMeters == distanceMeters) &&
            (identical(other.favorite, favorite) ||
                other.favorite == favorite) &&
            (identical(other.inBucketList, inBucketList) ||
                other.inBucketList == inBucketList));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    name,
    category,
    latitude,
    longitude,
    address,
    openingHours,
    foursquareRating,
    foursquarePrice,
    foursquarePhotoUrl,
    const DeepCollectionEquality().hash(_foursquareTips),
    distanceMeters,
    favorite,
    inBucketList,
  );

  /// Create a copy of Place
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PlaceImplCopyWith<_$PlaceImpl> get copyWith =>
      __$$PlaceImplCopyWithImpl<_$PlaceImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PlaceImplToJson(this);
  }
}

abstract class _Place extends Place {
  const factory _Place({
    required final int id,
    required final String name,
    required final String category,
    required final double latitude,
    required final double longitude,
    final String? address,
    final String? openingHours,
    final double? foursquareRating,
    final int? foursquarePrice,
    final String? foursquarePhotoUrl,
    final List<String>? foursquareTips,
    final int? distanceMeters,
    final bool favorite,
    final bool inBucketList,
  }) = _$PlaceImpl;
  const _Place._() : super._();

  factory _Place.fromJson(Map<String, dynamic> json) = _$PlaceImpl.fromJson;

  @override
  int get id;
  @override
  String get name;
  @override
  String get category;
  @override
  double get latitude;
  @override
  double get longitude;
  @override
  String? get address;
  @override
  String? get openingHours;
  @override
  double? get foursquareRating;
  @override
  int? get foursquarePrice;
  @override
  String? get foursquarePhotoUrl;
  @override
  List<String>? get foursquareTips; // Contextual data when viewing from a stay
  @override
  int? get distanceMeters;
  @override
  bool get favorite;
  @override
  bool get inBucketList;

  /// Create a copy of Place
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PlaceImplCopyWith<_$PlaceImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
