// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'gallery_item_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

GalleryItem _$GalleryItemFromJson(Map<String, dynamic> json) {
  return _GalleryItem.fromJson(json);
}

/// @nodoc
mixin _$GalleryItem {
  int get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get category => throw _privateConstructorUsedError;
  double get latitude => throw _privateConstructorUsedError;
  double get longitude => throw _privateConstructorUsedError;
  String? get address => throw _privateConstructorUsedError;
  int? get distanceMeters => throw _privateConstructorUsedError;
  bool get favorite => throw _privateConstructorUsedError;
  bool get inBucketList => throw _privateConstructorUsedError;
  String? get foursquarePhotoUrl => throw _privateConstructorUsedError;
  double? get foursquareRating => throw _privateConstructorUsedError;
  int? get foursquarePrice => throw _privateConstructorUsedError;

  /// Serializes this GalleryItem to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of GalleryItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $GalleryItemCopyWith<GalleryItem> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GalleryItemCopyWith<$Res> {
  factory $GalleryItemCopyWith(
    GalleryItem value,
    $Res Function(GalleryItem) then,
  ) = _$GalleryItemCopyWithImpl<$Res, GalleryItem>;
  @useResult
  $Res call({
    int id,
    String name,
    String category,
    double latitude,
    double longitude,
    String? address,
    int? distanceMeters,
    bool favorite,
    bool inBucketList,
    String? foursquarePhotoUrl,
    double? foursquareRating,
    int? foursquarePrice,
  });
}

/// @nodoc
class _$GalleryItemCopyWithImpl<$Res, $Val extends GalleryItem>
    implements $GalleryItemCopyWith<$Res> {
  _$GalleryItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of GalleryItem
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
    Object? distanceMeters = freezed,
    Object? favorite = null,
    Object? inBucketList = null,
    Object? foursquarePhotoUrl = freezed,
    Object? foursquareRating = freezed,
    Object? foursquarePrice = freezed,
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
            foursquarePhotoUrl: freezed == foursquarePhotoUrl
                ? _value.foursquarePhotoUrl
                : foursquarePhotoUrl // ignore: cast_nullable_to_non_nullable
                      as String?,
            foursquareRating: freezed == foursquareRating
                ? _value.foursquareRating
                : foursquareRating // ignore: cast_nullable_to_non_nullable
                      as double?,
            foursquarePrice: freezed == foursquarePrice
                ? _value.foursquarePrice
                : foursquarePrice // ignore: cast_nullable_to_non_nullable
                      as int?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$GalleryItemImplCopyWith<$Res>
    implements $GalleryItemCopyWith<$Res> {
  factory _$$GalleryItemImplCopyWith(
    _$GalleryItemImpl value,
    $Res Function(_$GalleryItemImpl) then,
  ) = __$$GalleryItemImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int id,
    String name,
    String category,
    double latitude,
    double longitude,
    String? address,
    int? distanceMeters,
    bool favorite,
    bool inBucketList,
    String? foursquarePhotoUrl,
    double? foursquareRating,
    int? foursquarePrice,
  });
}

/// @nodoc
class __$$GalleryItemImplCopyWithImpl<$Res>
    extends _$GalleryItemCopyWithImpl<$Res, _$GalleryItemImpl>
    implements _$$GalleryItemImplCopyWith<$Res> {
  __$$GalleryItemImplCopyWithImpl(
    _$GalleryItemImpl _value,
    $Res Function(_$GalleryItemImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of GalleryItem
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
    Object? distanceMeters = freezed,
    Object? favorite = null,
    Object? inBucketList = null,
    Object? foursquarePhotoUrl = freezed,
    Object? foursquareRating = freezed,
    Object? foursquarePrice = freezed,
  }) {
    return _then(
      _$GalleryItemImpl(
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
        foursquarePhotoUrl: freezed == foursquarePhotoUrl
            ? _value.foursquarePhotoUrl
            : foursquarePhotoUrl // ignore: cast_nullable_to_non_nullable
                  as String?,
        foursquareRating: freezed == foursquareRating
            ? _value.foursquareRating
            : foursquareRating // ignore: cast_nullable_to_non_nullable
                  as double?,
        foursquarePrice: freezed == foursquarePrice
            ? _value.foursquarePrice
            : foursquarePrice // ignore: cast_nullable_to_non_nullable
                  as int?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$GalleryItemImpl extends _GalleryItem {
  const _$GalleryItemImpl({
    required this.id,
    required this.name,
    required this.category,
    required this.latitude,
    required this.longitude,
    this.address,
    this.distanceMeters,
    this.favorite = false,
    this.inBucketList = false,
    this.foursquarePhotoUrl,
    this.foursquareRating,
    this.foursquarePrice,
  }) : super._();

  factory _$GalleryItemImpl.fromJson(Map<String, dynamic> json) =>
      _$$GalleryItemImplFromJson(json);

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
  final int? distanceMeters;
  @override
  @JsonKey()
  final bool favorite;
  @override
  @JsonKey()
  final bool inBucketList;
  @override
  final String? foursquarePhotoUrl;
  @override
  final double? foursquareRating;
  @override
  final int? foursquarePrice;

  @override
  String toString() {
    return 'GalleryItem(id: $id, name: $name, category: $category, latitude: $latitude, longitude: $longitude, address: $address, distanceMeters: $distanceMeters, favorite: $favorite, inBucketList: $inBucketList, foursquarePhotoUrl: $foursquarePhotoUrl, foursquareRating: $foursquareRating, foursquarePrice: $foursquarePrice)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GalleryItemImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.latitude, latitude) ||
                other.latitude == latitude) &&
            (identical(other.longitude, longitude) ||
                other.longitude == longitude) &&
            (identical(other.address, address) || other.address == address) &&
            (identical(other.distanceMeters, distanceMeters) ||
                other.distanceMeters == distanceMeters) &&
            (identical(other.favorite, favorite) ||
                other.favorite == favorite) &&
            (identical(other.inBucketList, inBucketList) ||
                other.inBucketList == inBucketList) &&
            (identical(other.foursquarePhotoUrl, foursquarePhotoUrl) ||
                other.foursquarePhotoUrl == foursquarePhotoUrl) &&
            (identical(other.foursquareRating, foursquareRating) ||
                other.foursquareRating == foursquareRating) &&
            (identical(other.foursquarePrice, foursquarePrice) ||
                other.foursquarePrice == foursquarePrice));
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
    distanceMeters,
    favorite,
    inBucketList,
    foursquarePhotoUrl,
    foursquareRating,
    foursquarePrice,
  );

  /// Create a copy of GalleryItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GalleryItemImplCopyWith<_$GalleryItemImpl> get copyWith =>
      __$$GalleryItemImplCopyWithImpl<_$GalleryItemImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$GalleryItemImplToJson(this);
  }
}

abstract class _GalleryItem extends GalleryItem {
  const factory _GalleryItem({
    required final int id,
    required final String name,
    required final String category,
    required final double latitude,
    required final double longitude,
    final String? address,
    final int? distanceMeters,
    final bool favorite,
    final bool inBucketList,
    final String? foursquarePhotoUrl,
    final double? foursquareRating,
    final int? foursquarePrice,
  }) = _$GalleryItemImpl;
  const _GalleryItem._() : super._();

  factory _GalleryItem.fromJson(Map<String, dynamic> json) =
      _$GalleryItemImpl.fromJson;

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
  int? get distanceMeters;
  @override
  bool get favorite;
  @override
  bool get inBucketList;
  @override
  String? get foursquarePhotoUrl;
  @override
  double? get foursquareRating;
  @override
  int? get foursquarePrice;

  /// Create a copy of GalleryItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GalleryItemImplCopyWith<_$GalleryItemImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$GalleryResponse {
  List<GalleryItem> get places => throw _privateConstructorUsedError;
  int get page => throw _privateConstructorUsedError;
  int get totalPages => throw _privateConstructorUsedError;
  int get totalCount => throw _privateConstructorUsedError;
  bool get hasMore => throw _privateConstructorUsedError;

  /// Create a copy of GalleryResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $GalleryResponseCopyWith<GalleryResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GalleryResponseCopyWith<$Res> {
  factory $GalleryResponseCopyWith(
    GalleryResponse value,
    $Res Function(GalleryResponse) then,
  ) = _$GalleryResponseCopyWithImpl<$Res, GalleryResponse>;
  @useResult
  $Res call({
    List<GalleryItem> places,
    int page,
    int totalPages,
    int totalCount,
    bool hasMore,
  });
}

/// @nodoc
class _$GalleryResponseCopyWithImpl<$Res, $Val extends GalleryResponse>
    implements $GalleryResponseCopyWith<$Res> {
  _$GalleryResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of GalleryResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? places = null,
    Object? page = null,
    Object? totalPages = null,
    Object? totalCount = null,
    Object? hasMore = null,
  }) {
    return _then(
      _value.copyWith(
            places: null == places
                ? _value.places
                : places // ignore: cast_nullable_to_non_nullable
                      as List<GalleryItem>,
            page: null == page
                ? _value.page
                : page // ignore: cast_nullable_to_non_nullable
                      as int,
            totalPages: null == totalPages
                ? _value.totalPages
                : totalPages // ignore: cast_nullable_to_non_nullable
                      as int,
            totalCount: null == totalCount
                ? _value.totalCount
                : totalCount // ignore: cast_nullable_to_non_nullable
                      as int,
            hasMore: null == hasMore
                ? _value.hasMore
                : hasMore // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$GalleryResponseImplCopyWith<$Res>
    implements $GalleryResponseCopyWith<$Res> {
  factory _$$GalleryResponseImplCopyWith(
    _$GalleryResponseImpl value,
    $Res Function(_$GalleryResponseImpl) then,
  ) = __$$GalleryResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    List<GalleryItem> places,
    int page,
    int totalPages,
    int totalCount,
    bool hasMore,
  });
}

/// @nodoc
class __$$GalleryResponseImplCopyWithImpl<$Res>
    extends _$GalleryResponseCopyWithImpl<$Res, _$GalleryResponseImpl>
    implements _$$GalleryResponseImplCopyWith<$Res> {
  __$$GalleryResponseImplCopyWithImpl(
    _$GalleryResponseImpl _value,
    $Res Function(_$GalleryResponseImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of GalleryResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? places = null,
    Object? page = null,
    Object? totalPages = null,
    Object? totalCount = null,
    Object? hasMore = null,
  }) {
    return _then(
      _$GalleryResponseImpl(
        places: null == places
            ? _value._places
            : places // ignore: cast_nullable_to_non_nullable
                  as List<GalleryItem>,
        page: null == page
            ? _value.page
            : page // ignore: cast_nullable_to_non_nullable
                  as int,
        totalPages: null == totalPages
            ? _value.totalPages
            : totalPages // ignore: cast_nullable_to_non_nullable
                  as int,
        totalCount: null == totalCount
            ? _value.totalCount
            : totalCount // ignore: cast_nullable_to_non_nullable
                  as int,
        hasMore: null == hasMore
            ? _value.hasMore
            : hasMore // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc

class _$GalleryResponseImpl implements _GalleryResponse {
  const _$GalleryResponseImpl({
    required final List<GalleryItem> places,
    required this.page,
    required this.totalPages,
    required this.totalCount,
    required this.hasMore,
  }) : _places = places;

  final List<GalleryItem> _places;
  @override
  List<GalleryItem> get places {
    if (_places is EqualUnmodifiableListView) return _places;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_places);
  }

  @override
  final int page;
  @override
  final int totalPages;
  @override
  final int totalCount;
  @override
  final bool hasMore;

  @override
  String toString() {
    return 'GalleryResponse(places: $places, page: $page, totalPages: $totalPages, totalCount: $totalCount, hasMore: $hasMore)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GalleryResponseImpl &&
            const DeepCollectionEquality().equals(other._places, _places) &&
            (identical(other.page, page) || other.page == page) &&
            (identical(other.totalPages, totalPages) ||
                other.totalPages == totalPages) &&
            (identical(other.totalCount, totalCount) ||
                other.totalCount == totalCount) &&
            (identical(other.hasMore, hasMore) || other.hasMore == hasMore));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    const DeepCollectionEquality().hash(_places),
    page,
    totalPages,
    totalCount,
    hasMore,
  );

  /// Create a copy of GalleryResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GalleryResponseImplCopyWith<_$GalleryResponseImpl> get copyWith =>
      __$$GalleryResponseImplCopyWithImpl<_$GalleryResponseImpl>(
        this,
        _$identity,
      );
}

abstract class _GalleryResponse implements GalleryResponse {
  const factory _GalleryResponse({
    required final List<GalleryItem> places,
    required final int page,
    required final int totalPages,
    required final int totalCount,
    required final bool hasMore,
  }) = _$GalleryResponseImpl;

  @override
  List<GalleryItem> get places;
  @override
  int get page;
  @override
  int get totalPages;
  @override
  int get totalCount;
  @override
  bool get hasMore;

  /// Create a copy of GalleryResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GalleryResponseImplCopyWith<_$GalleryResponseImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
