import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:latlong2/latlong.dart';

part 'transit_route_model.freezed.dart';
part 'transit_route_model.g.dart';

/// Transit route types matching the Rails backend
enum TransitRouteType {
  rails,
  train,
  ferry,
  bus;

  String get displayName {
    switch (this) {
      case TransitRouteType.rails:
        return 'Rail/Subway';
      case TransitRouteType.train:
        return 'Train';
      case TransitRouteType.ferry:
        return 'Ferry';
      case TransitRouteType.bus:
        return 'Bus';
    }
  }

  String get apiValue => name;
}

/// Transit route model representing a transit line near a stay
@freezed
class TransitRoute with _$TransitRoute {
  const TransitRoute._();

  const factory TransitRoute({
    required int id,
    required String name,
    required String routeType,
    String? color,
    required List<List<List<double>>> geometry,
  }) = _TransitRoute;

  factory TransitRoute.fromJson(Map<String, dynamic> json) =>
      _$TransitRouteFromJson(json);

  /// Get the route type as enum
  TransitRouteType? get type {
    return TransitRouteType.values.cast<TransitRouteType?>().firstWhere(
          (t) => t?.apiValue == routeType,
          orElse: () => null,
        );
  }

  /// Convert geometry to list of LatLng paths for rendering
  List<List<LatLng>> get paths {
    return geometry.map((path) {
      return path.map((coord) {
        if (coord.length >= 2) {
          return LatLng(coord[0], coord[1]);
        }
        return const LatLng(0, 0);
      }).toList();
    }).toList();
  }

  /// Get the display color, falling back to type default
  String get displayColor {
    if (color != null && color!.isNotEmpty) {
      return color!.startsWith('#') ? color! : '#$color';
    }
    return defaultColorForType;
  }

  /// Default colors matching web app
  String get defaultColorForType {
    switch (type) {
      case TransitRouteType.rails:
        return '#e11d48'; // Rose
      case TransitRouteType.train:
        return '#1d4ed8'; // Blue
      case TransitRouteType.ferry:
        return '#0284c7'; // Cyan
      case TransitRouteType.bus:
        return '#65a30d'; // Lime
      default:
        return '#6b7280'; // Gray
    }
  }

  /// Line weight for rendering
  double get lineWeight {
    switch (type) {
      case TransitRouteType.train:
        return 5.0;
      case TransitRouteType.rails:
      case TransitRouteType.ferry:
        return 4.0;
      case TransitRouteType.bus:
        return 3.0;
      default:
        return 3.0;
    }
  }

  /// Line opacity for rendering
  double get lineOpacity {
    switch (type) {
      case TransitRouteType.train:
      case TransitRouteType.rails:
        return 0.8;
      case TransitRouteType.ferry:
        return 0.7;
      case TransitRouteType.bus:
        return 0.6;
      default:
        return 0.7;
    }
  }
}
