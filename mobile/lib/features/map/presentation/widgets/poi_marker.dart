import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../../../shared/constants/tulip_colors.dart';
import '../../../places/data/models/poi_model.dart';

/// Creates markers for POIs with category-specific styling
class PoiMarkerBuilder {
  /// Build a marker for a POI
  static Marker build({
    required Poi poi,
    required VoidCallback onTap,
    bool isSelected = false,
  }) {
    return Marker(
      point: LatLng(poi.latitude, poi.longitude),
      width: isSelected ? 36 : 28,
      height: isSelected ? 36 : 28,
      child: GestureDetector(
        onTap: onTap,
        child: _PoiMarkerIcon(
          poi: poi,
          isSelected: isSelected,
        ),
      ),
    );
  }

  /// Build markers for multiple POIs
  static List<Marker> buildAll({
    required List<Poi> pois,
    required void Function(Poi poi) onTap,
    int? selectedPoiId,
    Set<String>? enabledCategories,
  }) {
    return pois
        .where((poi) => enabledCategories == null || enabledCategories.contains(poi.category))
        .map((poi) => build(
              poi: poi,
              onTap: () => onTap(poi),
              isSelected: poi.id == selectedPoiId,
            ))
        .toList();
  }
}

class _PoiMarkerIcon extends StatelessWidget {
  final Poi poi;
  final bool isSelected;

  const _PoiMarkerIcon({
    required this.poi,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = _getCategoryColor();
    final size = isSelected ? 36.0 : 28.0;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(
          color: color,
          width: isSelected ? 3 : 2,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.3),
            blurRadius: isSelected ? 6 : 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Icon(
        _getCategoryIcon(),
        color: color,
        size: isSelected ? 18 : 14,
      ),
    );
  }

  Color _getCategoryColor() {
    switch (poi.category) {
      case 'coffee':
        return const Color(0xFF8B4513); // Brown
      case 'restaurants':
      case 'restaurant':
        return TulipColors.coral;
      case 'grocery':
        return TulipColors.sage;
      case 'bars':
      case 'bar':
        return TulipColors.lavender;
      case 'gyms':
      case 'gym':
        return const Color(0xFF4A90D9); // Blue
      case 'parks':
      case 'park':
        return const Color(0xFF2E8B57); // Green
      case 'transit':
      case 'stations':
      case 'bus_stops':
        return const Color(0xFF666666); // Gray
      case 'attractions':
        return TulipColors.rose;
      default:
        return TulipColors.taupe;
    }
  }

  IconData _getCategoryIcon() {
    switch (poi.category) {
      case 'coffee':
        return Icons.coffee;
      case 'restaurants':
      case 'restaurant':
        return Icons.restaurant;
      case 'grocery':
        return Icons.shopping_cart;
      case 'bars':
      case 'bar':
        return Icons.local_bar;
      case 'gyms':
      case 'gym':
        return Icons.fitness_center;
      case 'parks':
      case 'park':
        return Icons.park;
      case 'transit':
      case 'stations':
        return Icons.train;
      case 'bus_stops':
        return Icons.directions_bus;
      case 'attractions':
        return Icons.museum;
      default:
        return Icons.place;
    }
  }
}
