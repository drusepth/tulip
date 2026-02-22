// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'transit_route_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

TransitRoute _$TransitRouteFromJson(Map<String, dynamic> json) {
  return _TransitRoute.fromJson(json);
}

/// @nodoc
mixin _$TransitRoute {
  int get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get routeType => throw _privateConstructorUsedError;
  String? get color => throw _privateConstructorUsedError;
  List<List<List<double>>> get geometry => throw _privateConstructorUsedError;

  /// Serializes this TransitRoute to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TransitRoute
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TransitRouteCopyWith<TransitRoute> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TransitRouteCopyWith<$Res> {
  factory $TransitRouteCopyWith(
    TransitRoute value,
    $Res Function(TransitRoute) then,
  ) = _$TransitRouteCopyWithImpl<$Res, TransitRoute>;
  @useResult
  $Res call({
    int id,
    String name,
    String routeType,
    String? color,
    List<List<List<double>>> geometry,
  });
}

/// @nodoc
class _$TransitRouteCopyWithImpl<$Res, $Val extends TransitRoute>
    implements $TransitRouteCopyWith<$Res> {
  _$TransitRouteCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TransitRoute
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? routeType = null,
    Object? color = freezed,
    Object? geometry = null,
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
            routeType: null == routeType
                ? _value.routeType
                : routeType // ignore: cast_nullable_to_non_nullable
                      as String,
            color: freezed == color
                ? _value.color
                : color // ignore: cast_nullable_to_non_nullable
                      as String?,
            geometry: null == geometry
                ? _value.geometry
                : geometry // ignore: cast_nullable_to_non_nullable
                      as List<List<List<double>>>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$TransitRouteImplCopyWith<$Res>
    implements $TransitRouteCopyWith<$Res> {
  factory _$$TransitRouteImplCopyWith(
    _$TransitRouteImpl value,
    $Res Function(_$TransitRouteImpl) then,
  ) = __$$TransitRouteImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int id,
    String name,
    String routeType,
    String? color,
    List<List<List<double>>> geometry,
  });
}

/// @nodoc
class __$$TransitRouteImplCopyWithImpl<$Res>
    extends _$TransitRouteCopyWithImpl<$Res, _$TransitRouteImpl>
    implements _$$TransitRouteImplCopyWith<$Res> {
  __$$TransitRouteImplCopyWithImpl(
    _$TransitRouteImpl _value,
    $Res Function(_$TransitRouteImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of TransitRoute
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? routeType = null,
    Object? color = freezed,
    Object? geometry = null,
  }) {
    return _then(
      _$TransitRouteImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as int,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        routeType: null == routeType
            ? _value.routeType
            : routeType // ignore: cast_nullable_to_non_nullable
                  as String,
        color: freezed == color
            ? _value.color
            : color // ignore: cast_nullable_to_non_nullable
                  as String?,
        geometry: null == geometry
            ? _value._geometry
            : geometry // ignore: cast_nullable_to_non_nullable
                  as List<List<List<double>>>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$TransitRouteImpl extends _TransitRoute {
  const _$TransitRouteImpl({
    required this.id,
    required this.name,
    required this.routeType,
    this.color,
    required final List<List<List<double>>> geometry,
  }) : _geometry = geometry,
       super._();

  factory _$TransitRouteImpl.fromJson(Map<String, dynamic> json) =>
      _$$TransitRouteImplFromJson(json);

  @override
  final int id;
  @override
  final String name;
  @override
  final String routeType;
  @override
  final String? color;
  final List<List<List<double>>> _geometry;
  @override
  List<List<List<double>>> get geometry {
    if (_geometry is EqualUnmodifiableListView) return _geometry;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_geometry);
  }

  @override
  String toString() {
    return 'TransitRoute(id: $id, name: $name, routeType: $routeType, color: $color, geometry: $geometry)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TransitRouteImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.routeType, routeType) ||
                other.routeType == routeType) &&
            (identical(other.color, color) || other.color == color) &&
            const DeepCollectionEquality().equals(other._geometry, _geometry));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    name,
    routeType,
    color,
    const DeepCollectionEquality().hash(_geometry),
  );

  /// Create a copy of TransitRoute
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TransitRouteImplCopyWith<_$TransitRouteImpl> get copyWith =>
      __$$TransitRouteImplCopyWithImpl<_$TransitRouteImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TransitRouteImplToJson(this);
  }
}

abstract class _TransitRoute extends TransitRoute {
  const factory _TransitRoute({
    required final int id,
    required final String name,
    required final String routeType,
    final String? color,
    required final List<List<List<double>>> geometry,
  }) = _$TransitRouteImpl;
  const _TransitRoute._() : super._();

  factory _TransitRoute.fromJson(Map<String, dynamic> json) =
      _$TransitRouteImpl.fromJson;

  @override
  int get id;
  @override
  String get name;
  @override
  String get routeType;
  @override
  String? get color;
  @override
  List<List<List<double>>> get geometry;

  /// Create a copy of TransitRoute
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TransitRouteImplCopyWith<_$TransitRouteImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
