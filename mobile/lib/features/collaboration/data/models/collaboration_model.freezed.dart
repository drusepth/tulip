// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'collaboration_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Collaboration _$CollaborationFromJson(Map<String, dynamic> json) {
  return _Collaboration.fromJson(json);
}

/// @nodoc
mixin _$Collaboration {
  int get id => throw _privateConstructorUsedError;
  String get role => throw _privateConstructorUsedError;
  String? get invitedEmail => throw _privateConstructorUsedError;
  bool get inviteAccepted => throw _privateConstructorUsedError;
  String? get inviteToken => throw _privateConstructorUsedError;
  CollaboratorUser? get user => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Serializes this Collaboration to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Collaboration
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CollaborationCopyWith<Collaboration> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CollaborationCopyWith<$Res> {
  factory $CollaborationCopyWith(
    Collaboration value,
    $Res Function(Collaboration) then,
  ) = _$CollaborationCopyWithImpl<$Res, Collaboration>;
  @useResult
  $Res call({
    int id,
    String role,
    String? invitedEmail,
    bool inviteAccepted,
    String? inviteToken,
    CollaboratorUser? user,
    DateTime createdAt,
  });

  $CollaboratorUserCopyWith<$Res>? get user;
}

/// @nodoc
class _$CollaborationCopyWithImpl<$Res, $Val extends Collaboration>
    implements $CollaborationCopyWith<$Res> {
  _$CollaborationCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Collaboration
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? role = null,
    Object? invitedEmail = freezed,
    Object? inviteAccepted = null,
    Object? inviteToken = freezed,
    Object? user = freezed,
    Object? createdAt = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as int,
            role: null == role
                ? _value.role
                : role // ignore: cast_nullable_to_non_nullable
                      as String,
            invitedEmail: freezed == invitedEmail
                ? _value.invitedEmail
                : invitedEmail // ignore: cast_nullable_to_non_nullable
                      as String?,
            inviteAccepted: null == inviteAccepted
                ? _value.inviteAccepted
                : inviteAccepted // ignore: cast_nullable_to_non_nullable
                      as bool,
            inviteToken: freezed == inviteToken
                ? _value.inviteToken
                : inviteToken // ignore: cast_nullable_to_non_nullable
                      as String?,
            user: freezed == user
                ? _value.user
                : user // ignore: cast_nullable_to_non_nullable
                      as CollaboratorUser?,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
          )
          as $Val,
    );
  }

  /// Create a copy of Collaboration
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $CollaboratorUserCopyWith<$Res>? get user {
    if (_value.user == null) {
      return null;
    }

    return $CollaboratorUserCopyWith<$Res>(_value.user!, (value) {
      return _then(_value.copyWith(user: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$CollaborationImplCopyWith<$Res>
    implements $CollaborationCopyWith<$Res> {
  factory _$$CollaborationImplCopyWith(
    _$CollaborationImpl value,
    $Res Function(_$CollaborationImpl) then,
  ) = __$$CollaborationImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int id,
    String role,
    String? invitedEmail,
    bool inviteAccepted,
    String? inviteToken,
    CollaboratorUser? user,
    DateTime createdAt,
  });

  @override
  $CollaboratorUserCopyWith<$Res>? get user;
}

/// @nodoc
class __$$CollaborationImplCopyWithImpl<$Res>
    extends _$CollaborationCopyWithImpl<$Res, _$CollaborationImpl>
    implements _$$CollaborationImplCopyWith<$Res> {
  __$$CollaborationImplCopyWithImpl(
    _$CollaborationImpl _value,
    $Res Function(_$CollaborationImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Collaboration
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? role = null,
    Object? invitedEmail = freezed,
    Object? inviteAccepted = null,
    Object? inviteToken = freezed,
    Object? user = freezed,
    Object? createdAt = null,
  }) {
    return _then(
      _$CollaborationImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as int,
        role: null == role
            ? _value.role
            : role // ignore: cast_nullable_to_non_nullable
                  as String,
        invitedEmail: freezed == invitedEmail
            ? _value.invitedEmail
            : invitedEmail // ignore: cast_nullable_to_non_nullable
                  as String?,
        inviteAccepted: null == inviteAccepted
            ? _value.inviteAccepted
            : inviteAccepted // ignore: cast_nullable_to_non_nullable
                  as bool,
        inviteToken: freezed == inviteToken
            ? _value.inviteToken
            : inviteToken // ignore: cast_nullable_to_non_nullable
                  as String?,
        user: freezed == user
            ? _value.user
            : user // ignore: cast_nullable_to_non_nullable
                  as CollaboratorUser?,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$CollaborationImpl extends _Collaboration {
  const _$CollaborationImpl({
    required this.id,
    required this.role,
    this.invitedEmail,
    this.inviteAccepted = false,
    this.inviteToken,
    this.user,
    required this.createdAt,
  }) : super._();

  factory _$CollaborationImpl.fromJson(Map<String, dynamic> json) =>
      _$$CollaborationImplFromJson(json);

  @override
  final int id;
  @override
  final String role;
  @override
  final String? invitedEmail;
  @override
  @JsonKey()
  final bool inviteAccepted;
  @override
  final String? inviteToken;
  @override
  final CollaboratorUser? user;
  @override
  final DateTime createdAt;

  @override
  String toString() {
    return 'Collaboration(id: $id, role: $role, invitedEmail: $invitedEmail, inviteAccepted: $inviteAccepted, inviteToken: $inviteToken, user: $user, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CollaborationImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.role, role) || other.role == role) &&
            (identical(other.invitedEmail, invitedEmail) ||
                other.invitedEmail == invitedEmail) &&
            (identical(other.inviteAccepted, inviteAccepted) ||
                other.inviteAccepted == inviteAccepted) &&
            (identical(other.inviteToken, inviteToken) ||
                other.inviteToken == inviteToken) &&
            (identical(other.user, user) || other.user == user) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    role,
    invitedEmail,
    inviteAccepted,
    inviteToken,
    user,
    createdAt,
  );

  /// Create a copy of Collaboration
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CollaborationImplCopyWith<_$CollaborationImpl> get copyWith =>
      __$$CollaborationImplCopyWithImpl<_$CollaborationImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CollaborationImplToJson(this);
  }
}

abstract class _Collaboration extends Collaboration {
  const factory _Collaboration({
    required final int id,
    required final String role,
    final String? invitedEmail,
    final bool inviteAccepted,
    final String? inviteToken,
    final CollaboratorUser? user,
    required final DateTime createdAt,
  }) = _$CollaborationImpl;
  const _Collaboration._() : super._();

  factory _Collaboration.fromJson(Map<String, dynamic> json) =
      _$CollaborationImpl.fromJson;

  @override
  int get id;
  @override
  String get role;
  @override
  String? get invitedEmail;
  @override
  bool get inviteAccepted;
  @override
  String? get inviteToken;
  @override
  CollaboratorUser? get user;
  @override
  DateTime get createdAt;

  /// Create a copy of Collaboration
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CollaborationImplCopyWith<_$CollaborationImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

CollaboratorUser _$CollaboratorUserFromJson(Map<String, dynamic> json) {
  return _CollaboratorUser.fromJson(json);
}

/// @nodoc
mixin _$CollaboratorUser {
  int get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get email => throw _privateConstructorUsedError;

  /// Serializes this CollaboratorUser to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CollaboratorUser
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CollaboratorUserCopyWith<CollaboratorUser> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CollaboratorUserCopyWith<$Res> {
  factory $CollaboratorUserCopyWith(
    CollaboratorUser value,
    $Res Function(CollaboratorUser) then,
  ) = _$CollaboratorUserCopyWithImpl<$Res, CollaboratorUser>;
  @useResult
  $Res call({int id, String name, String email});
}

/// @nodoc
class _$CollaboratorUserCopyWithImpl<$Res, $Val extends CollaboratorUser>
    implements $CollaboratorUserCopyWith<$Res> {
  _$CollaboratorUserCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CollaboratorUser
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? id = null, Object? name = null, Object? email = null}) {
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
            email: null == email
                ? _value.email
                : email // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$CollaboratorUserImplCopyWith<$Res>
    implements $CollaboratorUserCopyWith<$Res> {
  factory _$$CollaboratorUserImplCopyWith(
    _$CollaboratorUserImpl value,
    $Res Function(_$CollaboratorUserImpl) then,
  ) = __$$CollaboratorUserImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int id, String name, String email});
}

/// @nodoc
class __$$CollaboratorUserImplCopyWithImpl<$Res>
    extends _$CollaboratorUserCopyWithImpl<$Res, _$CollaboratorUserImpl>
    implements _$$CollaboratorUserImplCopyWith<$Res> {
  __$$CollaboratorUserImplCopyWithImpl(
    _$CollaboratorUserImpl _value,
    $Res Function(_$CollaboratorUserImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CollaboratorUser
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? id = null, Object? name = null, Object? email = null}) {
    return _then(
      _$CollaboratorUserImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as int,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        email: null == email
            ? _value.email
            : email // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$CollaboratorUserImpl implements _CollaboratorUser {
  const _$CollaboratorUserImpl({
    required this.id,
    required this.name,
    required this.email,
  });

  factory _$CollaboratorUserImpl.fromJson(Map<String, dynamic> json) =>
      _$$CollaboratorUserImplFromJson(json);

  @override
  final int id;
  @override
  final String name;
  @override
  final String email;

  @override
  String toString() {
    return 'CollaboratorUser(id: $id, name: $name, email: $email)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CollaboratorUserImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.email, email) || other.email == email));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, name, email);

  /// Create a copy of CollaboratorUser
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CollaboratorUserImplCopyWith<_$CollaboratorUserImpl> get copyWith =>
      __$$CollaboratorUserImplCopyWithImpl<_$CollaboratorUserImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$CollaboratorUserImplToJson(this);
  }
}

abstract class _CollaboratorUser implements CollaboratorUser {
  const factory _CollaboratorUser({
    required final int id,
    required final String name,
    required final String email,
  }) = _$CollaboratorUserImpl;

  factory _CollaboratorUser.fromJson(Map<String, dynamic> json) =
      _$CollaboratorUserImpl.fromJson;

  @override
  int get id;
  @override
  String get name;
  @override
  String get email;

  /// Create a copy of CollaboratorUser
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CollaboratorUserImplCopyWith<_$CollaboratorUserImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

CollaborationsResponse _$CollaborationsResponseFromJson(
  Map<String, dynamic> json,
) {
  return _CollaborationsResponse.fromJson(json);
}

/// @nodoc
mixin _$CollaborationsResponse {
  List<Collaboration> get pending => throw _privateConstructorUsedError;
  List<Collaboration> get accepted => throw _privateConstructorUsedError;

  /// Serializes this CollaborationsResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CollaborationsResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CollaborationsResponseCopyWith<CollaborationsResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CollaborationsResponseCopyWith<$Res> {
  factory $CollaborationsResponseCopyWith(
    CollaborationsResponse value,
    $Res Function(CollaborationsResponse) then,
  ) = _$CollaborationsResponseCopyWithImpl<$Res, CollaborationsResponse>;
  @useResult
  $Res call({List<Collaboration> pending, List<Collaboration> accepted});
}

/// @nodoc
class _$CollaborationsResponseCopyWithImpl<
  $Res,
  $Val extends CollaborationsResponse
>
    implements $CollaborationsResponseCopyWith<$Res> {
  _$CollaborationsResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CollaborationsResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? pending = null, Object? accepted = null}) {
    return _then(
      _value.copyWith(
            pending: null == pending
                ? _value.pending
                : pending // ignore: cast_nullable_to_non_nullable
                      as List<Collaboration>,
            accepted: null == accepted
                ? _value.accepted
                : accepted // ignore: cast_nullable_to_non_nullable
                      as List<Collaboration>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$CollaborationsResponseImplCopyWith<$Res>
    implements $CollaborationsResponseCopyWith<$Res> {
  factory _$$CollaborationsResponseImplCopyWith(
    _$CollaborationsResponseImpl value,
    $Res Function(_$CollaborationsResponseImpl) then,
  ) = __$$CollaborationsResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({List<Collaboration> pending, List<Collaboration> accepted});
}

/// @nodoc
class __$$CollaborationsResponseImplCopyWithImpl<$Res>
    extends
        _$CollaborationsResponseCopyWithImpl<$Res, _$CollaborationsResponseImpl>
    implements _$$CollaborationsResponseImplCopyWith<$Res> {
  __$$CollaborationsResponseImplCopyWithImpl(
    _$CollaborationsResponseImpl _value,
    $Res Function(_$CollaborationsResponseImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CollaborationsResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? pending = null, Object? accepted = null}) {
    return _then(
      _$CollaborationsResponseImpl(
        pending: null == pending
            ? _value._pending
            : pending // ignore: cast_nullable_to_non_nullable
                  as List<Collaboration>,
        accepted: null == accepted
            ? _value._accepted
            : accepted // ignore: cast_nullable_to_non_nullable
                  as List<Collaboration>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$CollaborationsResponseImpl implements _CollaborationsResponse {
  const _$CollaborationsResponseImpl({
    final List<Collaboration> pending = const [],
    final List<Collaboration> accepted = const [],
  }) : _pending = pending,
       _accepted = accepted;

  factory _$CollaborationsResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$CollaborationsResponseImplFromJson(json);

  final List<Collaboration> _pending;
  @override
  @JsonKey()
  List<Collaboration> get pending {
    if (_pending is EqualUnmodifiableListView) return _pending;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_pending);
  }

  final List<Collaboration> _accepted;
  @override
  @JsonKey()
  List<Collaboration> get accepted {
    if (_accepted is EqualUnmodifiableListView) return _accepted;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_accepted);
  }

  @override
  String toString() {
    return 'CollaborationsResponse(pending: $pending, accepted: $accepted)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CollaborationsResponseImpl &&
            const DeepCollectionEquality().equals(other._pending, _pending) &&
            const DeepCollectionEquality().equals(other._accepted, _accepted));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    const DeepCollectionEquality().hash(_pending),
    const DeepCollectionEquality().hash(_accepted),
  );

  /// Create a copy of CollaborationsResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CollaborationsResponseImplCopyWith<_$CollaborationsResponseImpl>
  get copyWith =>
      __$$CollaborationsResponseImplCopyWithImpl<_$CollaborationsResponseImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$CollaborationsResponseImplToJson(this);
  }
}

abstract class _CollaborationsResponse implements CollaborationsResponse {
  const factory _CollaborationsResponse({
    final List<Collaboration> pending,
    final List<Collaboration> accepted,
  }) = _$CollaborationsResponseImpl;

  factory _CollaborationsResponse.fromJson(Map<String, dynamic> json) =
      _$CollaborationsResponseImpl.fromJson;

  @override
  List<Collaboration> get pending;
  @override
  List<Collaboration> get accepted;

  /// Create a copy of CollaborationsResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CollaborationsResponseImplCopyWith<_$CollaborationsResponseImpl>
  get copyWith => throw _privateConstructorUsedError;
}

CollaborationRequest _$CollaborationRequestFromJson(Map<String, dynamic> json) {
  return _CollaborationRequest.fromJson(json);
}

/// @nodoc
mixin _$CollaborationRequest {
  String get invitedEmail => throw _privateConstructorUsedError;
  String get role => throw _privateConstructorUsedError;

  /// Serializes this CollaborationRequest to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CollaborationRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CollaborationRequestCopyWith<CollaborationRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CollaborationRequestCopyWith<$Res> {
  factory $CollaborationRequestCopyWith(
    CollaborationRequest value,
    $Res Function(CollaborationRequest) then,
  ) = _$CollaborationRequestCopyWithImpl<$Res, CollaborationRequest>;
  @useResult
  $Res call({String invitedEmail, String role});
}

/// @nodoc
class _$CollaborationRequestCopyWithImpl<
  $Res,
  $Val extends CollaborationRequest
>
    implements $CollaborationRequestCopyWith<$Res> {
  _$CollaborationRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CollaborationRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? invitedEmail = null, Object? role = null}) {
    return _then(
      _value.copyWith(
            invitedEmail: null == invitedEmail
                ? _value.invitedEmail
                : invitedEmail // ignore: cast_nullable_to_non_nullable
                      as String,
            role: null == role
                ? _value.role
                : role // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$CollaborationRequestImplCopyWith<$Res>
    implements $CollaborationRequestCopyWith<$Res> {
  factory _$$CollaborationRequestImplCopyWith(
    _$CollaborationRequestImpl value,
    $Res Function(_$CollaborationRequestImpl) then,
  ) = __$$CollaborationRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String invitedEmail, String role});
}

/// @nodoc
class __$$CollaborationRequestImplCopyWithImpl<$Res>
    extends _$CollaborationRequestCopyWithImpl<$Res, _$CollaborationRequestImpl>
    implements _$$CollaborationRequestImplCopyWith<$Res> {
  __$$CollaborationRequestImplCopyWithImpl(
    _$CollaborationRequestImpl _value,
    $Res Function(_$CollaborationRequestImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CollaborationRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? invitedEmail = null, Object? role = null}) {
    return _then(
      _$CollaborationRequestImpl(
        invitedEmail: null == invitedEmail
            ? _value.invitedEmail
            : invitedEmail // ignore: cast_nullable_to_non_nullable
                  as String,
        role: null == role
            ? _value.role
            : role // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$CollaborationRequestImpl implements _CollaborationRequest {
  const _$CollaborationRequestImpl({
    required this.invitedEmail,
    this.role = 'editor',
  });

  factory _$CollaborationRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$CollaborationRequestImplFromJson(json);

  @override
  final String invitedEmail;
  @override
  @JsonKey()
  final String role;

  @override
  String toString() {
    return 'CollaborationRequest(invitedEmail: $invitedEmail, role: $role)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CollaborationRequestImpl &&
            (identical(other.invitedEmail, invitedEmail) ||
                other.invitedEmail == invitedEmail) &&
            (identical(other.role, role) || other.role == role));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, invitedEmail, role);

  /// Create a copy of CollaborationRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CollaborationRequestImplCopyWith<_$CollaborationRequestImpl>
  get copyWith =>
      __$$CollaborationRequestImplCopyWithImpl<_$CollaborationRequestImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$CollaborationRequestImplToJson(this);
  }
}

abstract class _CollaborationRequest implements CollaborationRequest {
  const factory _CollaborationRequest({
    required final String invitedEmail,
    final String role,
  }) = _$CollaborationRequestImpl;

  factory _CollaborationRequest.fromJson(Map<String, dynamic> json) =
      _$CollaborationRequestImpl.fromJson;

  @override
  String get invitedEmail;
  @override
  String get role;

  /// Create a copy of CollaborationRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CollaborationRequestImplCopyWith<_$CollaborationRequestImpl>
  get copyWith => throw _privateConstructorUsedError;
}
