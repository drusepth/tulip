// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'comment_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Comment _$CommentFromJson(Map<String, dynamic> json) {
  return _Comment.fromJson(json);
}

/// @nodoc
mixin _$Comment {
  int get id => throw _privateConstructorUsedError;
  String get body => throw _privateConstructorUsedError;
  int? get parentId => throw _privateConstructorUsedError;
  int get userId => throw _privateConstructorUsedError;
  String get userName => throw _privateConstructorUsedError;
  String get userEmail => throw _privateConstructorUsedError;
  bool get editable => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this Comment to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Comment
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CommentCopyWith<Comment> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CommentCopyWith<$Res> {
  factory $CommentCopyWith(Comment value, $Res Function(Comment) then) =
      _$CommentCopyWithImpl<$Res, Comment>;
  @useResult
  $Res call({
    int id,
    String body,
    int? parentId,
    int userId,
    String userName,
    String userEmail,
    bool editable,
    DateTime createdAt,
    DateTime updatedAt,
  });
}

/// @nodoc
class _$CommentCopyWithImpl<$Res, $Val extends Comment>
    implements $CommentCopyWith<$Res> {
  _$CommentCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Comment
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? body = null,
    Object? parentId = freezed,
    Object? userId = null,
    Object? userName = null,
    Object? userEmail = null,
    Object? editable = null,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as int,
            body: null == body
                ? _value.body
                : body // ignore: cast_nullable_to_non_nullable
                      as String,
            parentId: freezed == parentId
                ? _value.parentId
                : parentId // ignore: cast_nullable_to_non_nullable
                      as int?,
            userId: null == userId
                ? _value.userId
                : userId // ignore: cast_nullable_to_non_nullable
                      as int,
            userName: null == userName
                ? _value.userName
                : userName // ignore: cast_nullable_to_non_nullable
                      as String,
            userEmail: null == userEmail
                ? _value.userEmail
                : userEmail // ignore: cast_nullable_to_non_nullable
                      as String,
            editable: null == editable
                ? _value.editable
                : editable // ignore: cast_nullable_to_non_nullable
                      as bool,
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
abstract class _$$CommentImplCopyWith<$Res> implements $CommentCopyWith<$Res> {
  factory _$$CommentImplCopyWith(
    _$CommentImpl value,
    $Res Function(_$CommentImpl) then,
  ) = __$$CommentImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int id,
    String body,
    int? parentId,
    int userId,
    String userName,
    String userEmail,
    bool editable,
    DateTime createdAt,
    DateTime updatedAt,
  });
}

/// @nodoc
class __$$CommentImplCopyWithImpl<$Res>
    extends _$CommentCopyWithImpl<$Res, _$CommentImpl>
    implements _$$CommentImplCopyWith<$Res> {
  __$$CommentImplCopyWithImpl(
    _$CommentImpl _value,
    $Res Function(_$CommentImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Comment
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? body = null,
    Object? parentId = freezed,
    Object? userId = null,
    Object? userName = null,
    Object? userEmail = null,
    Object? editable = null,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(
      _$CommentImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as int,
        body: null == body
            ? _value.body
            : body // ignore: cast_nullable_to_non_nullable
                  as String,
        parentId: freezed == parentId
            ? _value.parentId
            : parentId // ignore: cast_nullable_to_non_nullable
                  as int?,
        userId: null == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as int,
        userName: null == userName
            ? _value.userName
            : userName // ignore: cast_nullable_to_non_nullable
                  as String,
        userEmail: null == userEmail
            ? _value.userEmail
            : userEmail // ignore: cast_nullable_to_non_nullable
                  as String,
        editable: null == editable
            ? _value.editable
            : editable // ignore: cast_nullable_to_non_nullable
                  as bool,
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
class _$CommentImpl extends _Comment {
  const _$CommentImpl({
    required this.id,
    required this.body,
    this.parentId,
    required this.userId,
    required this.userName,
    required this.userEmail,
    this.editable = false,
    required this.createdAt,
    required this.updatedAt,
  }) : super._();

  factory _$CommentImpl.fromJson(Map<String, dynamic> json) =>
      _$$CommentImplFromJson(json);

  @override
  final int id;
  @override
  final String body;
  @override
  final int? parentId;
  @override
  final int userId;
  @override
  final String userName;
  @override
  final String userEmail;
  @override
  @JsonKey()
  final bool editable;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;

  @override
  String toString() {
    return 'Comment(id: $id, body: $body, parentId: $parentId, userId: $userId, userName: $userName, userEmail: $userEmail, editable: $editable, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CommentImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.body, body) || other.body == body) &&
            (identical(other.parentId, parentId) ||
                other.parentId == parentId) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.userName, userName) ||
                other.userName == userName) &&
            (identical(other.userEmail, userEmail) ||
                other.userEmail == userEmail) &&
            (identical(other.editable, editable) ||
                other.editable == editable) &&
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
    body,
    parentId,
    userId,
    userName,
    userEmail,
    editable,
    createdAt,
    updatedAt,
  );

  /// Create a copy of Comment
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CommentImplCopyWith<_$CommentImpl> get copyWith =>
      __$$CommentImplCopyWithImpl<_$CommentImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CommentImplToJson(this);
  }
}

abstract class _Comment extends Comment {
  const factory _Comment({
    required final int id,
    required final String body,
    final int? parentId,
    required final int userId,
    required final String userName,
    required final String userEmail,
    final bool editable,
    required final DateTime createdAt,
    required final DateTime updatedAt,
  }) = _$CommentImpl;
  const _Comment._() : super._();

  factory _Comment.fromJson(Map<String, dynamic> json) = _$CommentImpl.fromJson;

  @override
  int get id;
  @override
  String get body;
  @override
  int? get parentId;
  @override
  int get userId;
  @override
  String get userName;
  @override
  String get userEmail;
  @override
  bool get editable;
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt;

  /// Create a copy of Comment
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CommentImplCopyWith<_$CommentImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

CommentRequest _$CommentRequestFromJson(Map<String, dynamic> json) {
  return _CommentRequest.fromJson(json);
}

/// @nodoc
mixin _$CommentRequest {
  String get body => throw _privateConstructorUsedError;
  int? get parentId => throw _privateConstructorUsedError;

  /// Serializes this CommentRequest to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CommentRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CommentRequestCopyWith<CommentRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CommentRequestCopyWith<$Res> {
  factory $CommentRequestCopyWith(
    CommentRequest value,
    $Res Function(CommentRequest) then,
  ) = _$CommentRequestCopyWithImpl<$Res, CommentRequest>;
  @useResult
  $Res call({String body, int? parentId});
}

/// @nodoc
class _$CommentRequestCopyWithImpl<$Res, $Val extends CommentRequest>
    implements $CommentRequestCopyWith<$Res> {
  _$CommentRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CommentRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? body = null, Object? parentId = freezed}) {
    return _then(
      _value.copyWith(
            body: null == body
                ? _value.body
                : body // ignore: cast_nullable_to_non_nullable
                      as String,
            parentId: freezed == parentId
                ? _value.parentId
                : parentId // ignore: cast_nullable_to_non_nullable
                      as int?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$CommentRequestImplCopyWith<$Res>
    implements $CommentRequestCopyWith<$Res> {
  factory _$$CommentRequestImplCopyWith(
    _$CommentRequestImpl value,
    $Res Function(_$CommentRequestImpl) then,
  ) = __$$CommentRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String body, int? parentId});
}

/// @nodoc
class __$$CommentRequestImplCopyWithImpl<$Res>
    extends _$CommentRequestCopyWithImpl<$Res, _$CommentRequestImpl>
    implements _$$CommentRequestImplCopyWith<$Res> {
  __$$CommentRequestImplCopyWithImpl(
    _$CommentRequestImpl _value,
    $Res Function(_$CommentRequestImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CommentRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? body = null, Object? parentId = freezed}) {
    return _then(
      _$CommentRequestImpl(
        body: null == body
            ? _value.body
            : body // ignore: cast_nullable_to_non_nullable
                  as String,
        parentId: freezed == parentId
            ? _value.parentId
            : parentId // ignore: cast_nullable_to_non_nullable
                  as int?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$CommentRequestImpl implements _CommentRequest {
  const _$CommentRequestImpl({required this.body, this.parentId});

  factory _$CommentRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$CommentRequestImplFromJson(json);

  @override
  final String body;
  @override
  final int? parentId;

  @override
  String toString() {
    return 'CommentRequest(body: $body, parentId: $parentId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CommentRequestImpl &&
            (identical(other.body, body) || other.body == body) &&
            (identical(other.parentId, parentId) ||
                other.parentId == parentId));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, body, parentId);

  /// Create a copy of CommentRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CommentRequestImplCopyWith<_$CommentRequestImpl> get copyWith =>
      __$$CommentRequestImplCopyWithImpl<_$CommentRequestImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$CommentRequestImplToJson(this);
  }
}

abstract class _CommentRequest implements CommentRequest {
  const factory _CommentRequest({
    required final String body,
    final int? parentId,
  }) = _$CommentRequestImpl;

  factory _CommentRequest.fromJson(Map<String, dynamic> json) =
      _$CommentRequestImpl.fromJson;

  @override
  String get body;
  @override
  int? get parentId;

  /// Create a copy of CommentRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CommentRequestImplCopyWith<_$CommentRequestImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
