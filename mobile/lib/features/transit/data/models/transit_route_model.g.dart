// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transit_route_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TransitRouteImpl _$$TransitRouteImplFromJson(Map<String, dynamic> json) =>
    _$TransitRouteImpl(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      routeType: json['routeType'] as String,
      color: json['color'] as String?,
      geometry: (json['geometry'] as List<dynamic>)
          .map(
            (e) => (e as List<dynamic>)
                .map(
                  (e) => (e as List<dynamic>)
                      .map((e) => (e as num).toDouble())
                      .toList(),
                )
                .toList(),
          )
          .toList(),
    );

Map<String, dynamic> _$$TransitRouteImplToJson(_$TransitRouteImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'routeType': instance.routeType,
      'color': instance.color,
      'geometry': instance.geometry,
    };
