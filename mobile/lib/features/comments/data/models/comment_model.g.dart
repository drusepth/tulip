// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'comment_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CommentImpl _$$CommentImplFromJson(Map<String, dynamic> json) =>
    _$CommentImpl(
      id: (json['id'] as num).toInt(),
      body: json['body'] as String,
      parentId: (json['parentId'] as num?)?.toInt(),
      userId: (json['userId'] as num).toInt(),
      userName: json['userName'] as String,
      userEmail: json['userEmail'] as String,
      editable: json['editable'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$CommentImplToJson(_$CommentImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'body': instance.body,
      'parentId': instance.parentId,
      'userId': instance.userId,
      'userName': instance.userName,
      'userEmail': instance.userEmail,
      'editable': instance.editable,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

_$CommentRequestImpl _$$CommentRequestImplFromJson(Map<String, dynamic> json) =>
    _$CommentRequestImpl(
      body: json['body'] as String,
      parentId: (json['parentId'] as num?)?.toInt(),
    );

Map<String, dynamic> _$$CommentRequestImplToJson(
  _$CommentRequestImpl instance,
) => <String, dynamic>{'body': instance.body, 'parentId': instance.parentId};
