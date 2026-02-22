import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../../../shared/constants/tulip_colors.dart';

/// Base map widget using flutter_map with OpenStreetMap tiles
class TulipMap extends StatelessWidget {
  final MapController? mapController;
  final LatLng? initialCenter;
  final double initialZoom;
  final List<Marker> markers;
  final List<Polyline> polylines;
  final List<Widget> children;
  final PositionCallback? onPositionChanged;
  final void Function(TapPosition, LatLng)? onTap;
  final bool interactionOptions;

  const TulipMap({
    super.key,
    this.mapController,
    this.initialCenter,
    this.initialZoom = 12.0,
    this.markers = const [],
    this.polylines = const [],
    this.children = const [],
    this.onPositionChanged,
    this.onTap,
    this.interactionOptions = true,
  });

  // Default center (Portland, OR - matches the web app's default)
  static const defaultCenter = LatLng(45.5152, -122.6784);

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      mapController: mapController,
      options: MapOptions(
        initialCenter: initialCenter ?? defaultCenter,
        initialZoom: initialZoom,
        minZoom: 3,
        maxZoom: 18,
        onPositionChanged: onPositionChanged,
        onTap: onTap,
        interactionOptions: interactionOptions
            ? const InteractionOptions(
                flags: InteractiveFlag.all,
              )
            : const InteractionOptions(
                flags: InteractiveFlag.none,
              ),
        backgroundColor: TulipColors.cream,
      ),
      children: [
        // OpenStreetMap tile layer with cottagecore-friendly style
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.tulip.app',
          maxZoom: 19,
          tileBuilder: _tileBuilder,
        ),
        // Polylines layer (for transit routes)
        if (polylines.isNotEmpty)
          PolylineLayer(polylines: polylines),
        // Markers layer
        if (markers.isNotEmpty)
          MarkerLayer(markers: markers),
        // Additional children (like marker clusters)
        ...children,
      ],
    );
  }

  /// Apply a subtle warm tint to map tiles for cottagecore aesthetic
  Widget _tileBuilder(BuildContext context, Widget tileWidget, TileImage tile) {
    return ColorFiltered(
      colorFilter: const ColorFilter.matrix(<double>[
        1.0, 0.0, 0.0, 0.0, 5.0,   // Red
        0.0, 1.0, 0.0, 0.0, 3.0,   // Green
        0.0, 0.0, 0.95, 0.0, 0.0,  // Blue (slightly reduced)
        0.0, 0.0, 0.0, 1.0, 0.0,   // Alpha
      ]),
      child: tileWidget,
    );
  }
}

/// Mini map for stay detail pages (non-interactive)
class TulipMiniMap extends StatelessWidget {
  final LatLng center;
  final double zoom;
  final List<Marker> markers;

  const TulipMiniMap({
    super.key,
    required this.center,
    this.zoom = 14.0,
    this.markers = const [],
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        height: 150,
        child: TulipMap(
          initialCenter: center,
          initialZoom: zoom,
          markers: markers,
          interactionOptions: false,
        ),
      ),
    );
  }
}

/// Map control button widget
class MapControlButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final String? tooltip;

  const MapControlButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(icon, color: TulipColors.brown),
        onPressed: onPressed,
        tooltip: tooltip,
        iconSize: 24,
        padding: const EdgeInsets.all(8),
        constraints: const BoxConstraints(
          minWidth: 40,
          minHeight: 40,
        ),
      ),
    );
  }
}
