// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AppNotificationImpl _$$AppNotificationImplFromJson(
  Map<String, dynamic> json,
) => _$AppNotificationImpl(
  id: (json['id'] as num).toInt(),
  notificationType: json['notificationType'] as String,
  message: json['message'] as String,
  iconName: json['iconName'] as String?,
  ringColor: json['ringColor'] as String?,
  targetPath: json['targetPath'] as String?,
  read: json['read'] as bool? ?? false,
  createdAt: DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$$AppNotificationImplToJson(
  _$AppNotificationImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'notificationType': instance.notificationType,
  'message': instance.message,
  'iconName': instance.iconName,
  'ringColor': instance.ringColor,
  'targetPath': instance.targetPath,
  'read': instance.read,
  'createdAt': instance.createdAt.toIso8601String(),
};
