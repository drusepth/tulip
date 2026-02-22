// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'collaboration_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CollaborationImpl _$$CollaborationImplFromJson(Map<String, dynamic> json) =>
    _$CollaborationImpl(
      id: (json['id'] as num).toInt(),
      role: json['role'] as String,
      invitedEmail: json['invitedEmail'] as String?,
      inviteAccepted: json['inviteAccepted'] as bool? ?? false,
      inviteToken: json['inviteToken'] as String?,
      user: json['user'] == null
          ? null
          : CollaboratorUser.fromJson(json['user'] as Map<String, dynamic>),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$$CollaborationImplToJson(_$CollaborationImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'role': instance.role,
      'invitedEmail': instance.invitedEmail,
      'inviteAccepted': instance.inviteAccepted,
      'inviteToken': instance.inviteToken,
      'user': instance.user,
      'createdAt': instance.createdAt.toIso8601String(),
    };

_$CollaboratorUserImpl _$$CollaboratorUserImplFromJson(
  Map<String, dynamic> json,
) => _$CollaboratorUserImpl(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String,
  email: json['email'] as String,
);

Map<String, dynamic> _$$CollaboratorUserImplToJson(
  _$CollaboratorUserImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'email': instance.email,
};

_$CollaborationsResponseImpl _$$CollaborationsResponseImplFromJson(
  Map<String, dynamic> json,
) => _$CollaborationsResponseImpl(
  pending:
      (json['pending'] as List<dynamic>?)
          ?.map((e) => Collaboration.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  accepted:
      (json['accepted'] as List<dynamic>?)
          ?.map((e) => Collaboration.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
);

Map<String, dynamic> _$$CollaborationsResponseImplToJson(
  _$CollaborationsResponseImpl instance,
) => <String, dynamic>{
  'pending': instance.pending,
  'accepted': instance.accepted,
};

_$CollaborationRequestImpl _$$CollaborationRequestImplFromJson(
  Map<String, dynamic> json,
) => _$CollaborationRequestImpl(
  invitedEmail: json['invitedEmail'] as String,
  role: json['role'] as String? ?? 'editor',
);

Map<String, dynamic> _$$CollaborationRequestImplToJson(
  _$CollaborationRequestImpl instance,
) => <String, dynamic>{
  'invitedEmail': instance.invitedEmail,
  'role': instance.role,
};
