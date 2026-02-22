// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'bucket_list_item_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

BucketListItem _$BucketListItemFromJson(Map<String, dynamic> json) {
  return _BucketListItem.fromJson(json);
}

/// @nodoc
mixin _$BucketListItem {
  int get id => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String? get category => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;
  String? get address => throw _privateConstructorUsedError;
  double? get latitude => throw _privateConstructorUsedError;
  double? get longitude => throw _privateConstructorUsedError;
  bool get completed => throw _privateConstructorUsedError;
  DateTime? get completedAt => throw _privateConstructorUsedError;
  int get stayId => throw _privateConstructorUsedError;
  int? get placeId => throw _privateConstructorUsedError;
  double? get averageRating => throw _privateConstructorUsedError;
  int? get userRating => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this BucketListItem to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of BucketListItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $BucketListItemCopyWith<BucketListItem> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BucketListItemCopyWith<$Res> {
  factory $BucketListItemCopyWith(
    BucketListItem value,
    $Res Function(BucketListItem) then,
  ) = _$BucketListItemCopyWithImpl<$Res, BucketListItem>;
  @useResult
  $Res call({
    int id,
    String title,
    String? category,
    String? notes,
    String? address,
    double? latitude,
    double? longitude,
    bool completed,
    DateTime? completedAt,
    int stayId,
    int? placeId,
    double? averageRating,
    int? userRating,
    DateTime createdAt,
    DateTime updatedAt,
  });
}

/// @nodoc
class _$BucketListItemCopyWithImpl<$Res, $Val extends BucketListItem>
    implements $BucketListItemCopyWith<$Res> {
  _$BucketListItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of BucketListItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? category = freezed,
    Object? notes = freezed,
    Object? address = freezed,
    Object? latitude = freezed,
    Object? longitude = freezed,
    Object? completed = null,
    Object? completedAt = freezed,
    Object? stayId = null,
    Object? placeId = freezed,
    Object? averageRating = freezed,
    Object? userRating = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
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
            category: freezed == category
                ? _value.category
                : category // ignore: cast_nullable_to_non_nullable
                      as String?,
            notes: freezed == notes
                ? _value.notes
                : notes // ignore: cast_nullable_to_non_nullable
                      as String?,
            address: freezed == address
                ? _value.address
                : address // ignore: cast_nullable_to_non_nullable
                      as String?,
            latitude: freezed == latitude
                ? _value.latitude
                : latitude // ignore: cast_nullable_to_non_nullable
                      as double?,
            longitude: freezed == longitude
                ? _value.longitude
                : longitude // ignore: cast_nullable_to_non_nullable
                      as double?,
            completed: null == completed
                ? _value.completed
                : completed // ignore: cast_nullable_to_non_nullable
                      as bool,
            completedAt: freezed == completedAt
                ? _value.completedAt
                : completedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            stayId: null == stayId
                ? _value.stayId
                : stayId // ignore: cast_nullable_to_non_nullable
                      as int,
            placeId: freezed == placeId
                ? _value.placeId
                : placeId // ignore: cast_nullable_to_non_nullable
                      as int?,
            averageRating: freezed == averageRating
                ? _value.averageRating
                : averageRating // ignore: cast_nullable_to_non_nullable
                      as double?,
            userRating: freezed == userRating
                ? _value.userRating
                : userRating // ignore: cast_nullable_to_non_nullable
                      as int?,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            updatedAt: null == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$BucketListItemImplCopyWith<$Res>
    implements $BucketListItemCopyWith<$Res> {
  factory _$$BucketListItemImplCopyWith(
    _$BucketListItemImpl value,
    $Res Function(_$BucketListItemImpl) then,
  ) = __$$BucketListItemImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int id,
    String title,
    String? category,
    String? notes,
    String? address,
    double? latitude,
    double? longitude,
    bool completed,
    DateTime? completedAt,
    int stayId,
    int? placeId,
    double? averageRating,
    int? userRating,
    DateTime createdAt,
    DateTime updatedAt,
  });
}

/// @nodoc
class __$$BucketListItemImplCopyWithImpl<$Res>
    extends _$BucketListItemCopyWithImpl<$Res, _$BucketListItemImpl>
    implements _$$BucketListItemImplCopyWith<$Res> {
  __$$BucketListItemImplCopyWithImpl(
    _$BucketListItemImpl _value,
    $Res Function(_$BucketListItemImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of BucketListItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? category = freezed,
    Object? notes = freezed,
    Object? address = freezed,
    Object? latitude = freezed,
    Object? longitude = freezed,
    Object? completed = null,
    Object? completedAt = freezed,
    Object? stayId = null,
    Object? placeId = freezed,
    Object? averageRating = freezed,
    Object? userRating = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(
      _$BucketListItemImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as int,
        title: null == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String,
        category: freezed == category
            ? _value.category
            : category // ignore: cast_nullable_to_non_nullable
                  as String?,
        notes: freezed == notes
            ? _value.notes
            : notes // ignore: cast_nullable_to_non_nullable
                  as String?,
        address: freezed == address
            ? _value.address
            : address // ignore: cast_nullable_to_non_nullable
                  as String?,
        latitude: freezed == latitude
            ? _value.latitude
            : latitude // ignore: cast_nullable_to_non_nullable
                  as double?,
        longitude: freezed == longitude
            ? _value.longitude
            : longitude // ignore: cast_nullable_to_non_nullable
                  as double?,
        completed: null == completed
            ? _value.completed
            : completed // ignore: cast_nullable_to_non_nullable
                  as bool,
        completedAt: freezed == completedAt
            ? _value.completedAt
            : completedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        stayId: null == stayId
            ? _value.stayId
            : stayId // ignore: cast_nullable_to_non_nullable
                  as int,
        placeId: freezed == placeId
            ? _value.placeId
            : placeId // ignore: cast_nullable_to_non_nullable
                  as int?,
        averageRating: freezed == averageRating
            ? _value.averageRating
            : averageRating // ignore: cast_nullable_to_non_nullable
                  as double?,
        userRating: freezed == userRating
            ? _value.userRating
            : userRating // ignore: cast_nullable_to_non_nullable
                  as int?,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        updatedAt: null == updatedAt
            ? _value.updatedAt
            : updatedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$BucketListItemImpl extends _BucketListItem {
  const _$BucketListItemImpl({
    required this.id,
    required this.title,
    this.category,
    this.notes,
    this.address,
    this.latitude,
    this.longitude,
    this.completed = false,
    this.completedAt,
    required this.stayId,
    this.placeId,
    this.averageRating,
    this.userRating,
    required this.createdAt,
    required this.updatedAt,
  }) : super._();

  factory _$BucketListItemImpl.fromJson(Map<String, dynamic> json) =>
      _$$BucketListItemImplFromJson(json);

  @override
  final int id;
  @override
  final String title;
  @override
  final String? category;
  @override
  final String? notes;
  @override
  final String? address;
  @override
  final double? latitude;
  @override
  final double? longitude;
  @override
  @JsonKey()
  final bool completed;
  @override
  final DateTime? completedAt;
  @override
  final int stayId;
  @override
  final int? placeId;
  @override
  final double? averageRating;
  @override
  final int? userRating;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;

  @override
  String toString() {
    return 'BucketListItem(id: $id, title: $title, category: $category, notes: $notes, address: $address, latitude: $latitude, longitude: $longitude, completed: $completed, completedAt: $completedAt, stayId: $stayId, placeId: $placeId, averageRating: $averageRating, userRating: $userRating, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BucketListItemImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.address, address) || other.address == address) &&
            (identical(other.latitude, latitude) ||
                other.latitude == latitude) &&
            (identical(other.longitude, longitude) ||
                other.longitude == longitude) &&
            (identical(other.completed, completed) ||
                other.completed == completed) &&
            (identical(other.completedAt, completedAt) ||
                other.completedAt == completedAt) &&
            (identical(other.stayId, stayId) || other.stayId == stayId) &&
            (identical(other.placeId, placeId) || other.placeId == placeId) &&
            (identical(other.averageRating, averageRating) ||
                other.averageRating == averageRating) &&
            (identical(other.userRating, userRating) ||
                other.userRating == userRating) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    title,
    category,
    notes,
    address,
    latitude,
    longitude,
    completed,
    completedAt,
    stayId,
    placeId,
    averageRating,
    userRating,
    createdAt,
    updatedAt,
  );

  /// Create a copy of BucketListItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$BucketListItemImplCopyWith<_$BucketListItemImpl> get copyWith =>
      __$$BucketListItemImplCopyWithImpl<_$BucketListItemImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$BucketListItemImplToJson(this);
  }
}

abstract class _BucketListItem extends BucketListItem {
  const factory _BucketListItem({
    required final int id,
    required final String title,
    final String? category,
    final String? notes,
    final String? address,
    final double? latitude,
    final double? longitude,
    final bool completed,
    final DateTime? completedAt,
    required final int stayId,
    final int? placeId,
    final double? averageRating,
    final int? userRating,
    required final DateTime createdAt,
    required final DateTime updatedAt,
  }) = _$BucketListItemImpl;
  const _BucketListItem._() : super._();

  factory _BucketListItem.fromJson(Map<String, dynamic> json) =
      _$BucketListItemImpl.fromJson;

  @override
  int get id;
  @override
  String get title;
  @override
  String? get category;
  @override
  String? get notes;
  @override
  String? get address;
  @override
  double? get latitude;
  @override
  double? get longitude;
  @override
  bool get completed;
  @override
  DateTime? get completedAt;
  @override
  int get stayId;
  @override
  int? get placeId;
  @override
  double? get averageRating;
  @override
  int? get userRating;
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt;

  /// Create a copy of BucketListItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$BucketListItemImplCopyWith<_$BucketListItemImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

BucketListItemRequest _$BucketListItemRequestFromJson(
  Map<String, dynamic> json,
) {
  return _BucketListItemRequest.fromJson(json);
}

/// @nodoc
mixin _$BucketListItemRequest {
  String get title => throw _privateConstructorUsedError;
  String? get category => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;
  String? get address => throw _privateConstructorUsedError;
  double? get latitude => throw _privateConstructorUsedError;
  double? get longitude => throw _privateConstructorUsedError;
  int? get placeId => throw _privateConstructorUsedError;

  /// Serializes this BucketListItemRequest to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of BucketListItemRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $BucketListItemRequestCopyWith<BucketListItemRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BucketListItemRequestCopyWith<$Res> {
  factory $BucketListItemRequestCopyWith(
    BucketListItemRequest value,
    $Res Function(BucketListItemRequest) then,
  ) = _$BucketListItemRequestCopyWithImpl<$Res, BucketListItemRequest>;
  @useResult
  $Res call({
    String title,
    String? category,
    String? notes,
    String? address,
    double? latitude,
    double? longitude,
    int? placeId,
  });
}

/// @nodoc
class _$BucketListItemRequestCopyWithImpl<
  $Res,
  $Val extends BucketListItemRequest
>
    implements $BucketListItemRequestCopyWith<$Res> {
  _$BucketListItemRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of BucketListItemRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? title = null,
    Object? category = freezed,
    Object? notes = freezed,
    Object? address = freezed,
    Object? latitude = freezed,
    Object? longitude = freezed,
    Object? placeId = freezed,
  }) {
    return _then(
      _value.copyWith(
            title: null == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                      as String,
            category: freezed == category
                ? _value.category
                : category // ignore: cast_nullable_to_non_nullable
                      as String?,
            notes: freezed == notes
                ? _value.notes
                : notes // ignore: cast_nullable_to_non_nullable
                      as String?,
            address: freezed == address
                ? _value.address
                : address // ignore: cast_nullable_to_non_nullable
                      as String?,
            latitude: freezed == latitude
                ? _value.latitude
                : latitude // ignore: cast_nullable_to_non_nullable
                      as double?,
            longitude: freezed == longitude
                ? _value.longitude
                : longitude // ignore: cast_nullable_to_non_nullable
                      as double?,
            placeId: freezed == placeId
                ? _value.placeId
                : placeId // ignore: cast_nullable_to_non_nullable
                      as int?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$BucketListItemRequestImplCopyWith<$Res>
    implements $BucketListItemRequestCopyWith<$Res> {
  factory _$$BucketListItemRequestImplCopyWith(
    _$BucketListItemRequestImpl value,
    $Res Function(_$BucketListItemRequestImpl) then,
  ) = __$$BucketListItemRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String title,
    String? category,
    String? notes,
    String? address,
    double? latitude,
    double? longitude,
    int? placeId,
  });
}

/// @nodoc
class __$$BucketListItemRequestImplCopyWithImpl<$Res>
    extends
        _$BucketListItemRequestCopyWithImpl<$Res, _$BucketListItemRequestImpl>
    implements _$$BucketListItemRequestImplCopyWith<$Res> {
  __$$BucketListItemRequestImplCopyWithImpl(
    _$BucketListItemRequestImpl _value,
    $Res Function(_$BucketListItemRequestImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of BucketListItemRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? title = null,
    Object? category = freezed,
    Object? notes = freezed,
    Object? address = freezed,
    Object? latitude = freezed,
    Object? longitude = freezed,
    Object? placeId = freezed,
  }) {
    return _then(
      _$BucketListItemRequestImpl(
        title: null == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String,
        category: freezed == category
            ? _value.category
            : category // ignore: cast_nullable_to_non_nullable
                  as String?,
        notes: freezed == notes
            ? _value.notes
            : notes // ignore: cast_nullable_to_non_nullable
                  as String?,
        address: freezed == address
            ? _value.address
            : address // ignore: cast_nullable_to_non_nullable
                  as String?,
        latitude: freezed == latitude
            ? _value.latitude
            : latitude // ignore: cast_nullable_to_non_nullable
                  as double?,
        longitude: freezed == longitude
            ? _value.longitude
            : longitude // ignore: cast_nullable_to_non_nullable
                  as double?,
        placeId: freezed == placeId
            ? _value.placeId
            : placeId // ignore: cast_nullable_to_non_nullable
                  as int?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$BucketListItemRequestImpl implements _BucketListItemRequest {
  const _$BucketListItemRequestImpl({
    required this.title,
    this.category,
    this.notes,
    this.address,
    this.latitude,
    this.longitude,
    this.placeId,
  });

  factory _$BucketListItemRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$BucketListItemRequestImplFromJson(json);

  @override
  final String title;
  @override
  final String? category;
  @override
  final String? notes;
  @override
  final String? address;
  @override
  final double? latitude;
  @override
  final double? longitude;
  @override
  final int? placeId;

  @override
  String toString() {
    return 'BucketListItemRequest(title: $title, category: $category, notes: $notes, address: $address, latitude: $latitude, longitude: $longitude, placeId: $placeId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BucketListItemRequestImpl &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.address, address) || other.address == address) &&
            (identical(other.latitude, latitude) ||
                other.latitude == latitude) &&
            (identical(other.longitude, longitude) ||
                other.longitude == longitude) &&
            (identical(other.placeId, placeId) || other.placeId == placeId));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    title,
    category,
    notes,
    address,
    latitude,
    longitude,
    placeId,
  );

  /// Create a copy of BucketListItemRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$BucketListItemRequestImplCopyWith<_$BucketListItemRequestImpl>
  get copyWith =>
      __$$BucketListItemRequestImplCopyWithImpl<_$BucketListItemRequestImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$BucketListItemRequestImplToJson(this);
  }
}

abstract class _BucketListItemRequest implements BucketListItemRequest {
  const factory _BucketListItemRequest({
    required final String title,
    final String? category,
    final String? notes,
    final String? address,
    final double? latitude,
    final double? longitude,
    final int? placeId,
  }) = _$BucketListItemRequestImpl;

  factory _BucketListItemRequest.fromJson(Map<String, dynamic> json) =
      _$BucketListItemRequestImpl.fromJson;

  @override
  String get title;
  @override
  String? get category;
  @override
  String? get notes;
  @override
  String? get address;
  @override
  double? get latitude;
  @override
  double? get longitude;
  @override
  int? get placeId;

  /// Create a copy of BucketListItemRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$BucketListItemRequestImplCopyWith<_$BucketListItemRequestImpl>
  get copyWith => throw _privateConstructorUsedError;
}
