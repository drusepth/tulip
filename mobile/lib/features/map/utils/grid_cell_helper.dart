import 'package:latlong2/latlong.dart';

/// Grid calculation utility for viewport-based POI loading.
/// Matches the web app's logic for consistent caching behavior.
class GridCellHelper {
  /// Grid size in degrees (~1km at equator)
  static const double gridSize = 0.01;

  /// Gets a unique grid key for a given location and category.
  /// Format: "category:lat:lng" where lat/lng are rounded to grid boundaries.
  static String getGridKey(double lat, double lng, String category) {
    final roundedLat = (lat / gridSize).floor() * gridSize;
    final roundedLng = (lng / gridSize).floor() * gridSize;
    return '$category:${roundedLat.toStringAsFixed(2)}:${roundedLng.toStringAsFixed(2)}';
  }

  /// Gets the center point of a grid cell.
  static LatLng getGridCellCenter(double lat, double lng) {
    final roundedLat = (lat / gridSize).floor() * gridSize;
    final roundedLng = (lng / gridSize).floor() * gridSize;
    return LatLng(
      roundedLat + gridSize / 2,
      roundedLng + gridSize / 2,
    );
  }

  /// Gets all visible grid cells around a center point (5x5 grid).
  /// Returns a list of (gridKey, cellCenter) pairs for a given category.
  static List<GridCell> getVisibleGridCells(LatLng center, String category) {
    final cells = <GridCell>[];
    final baseLat = (center.latitude / gridSize).floor() * gridSize;
    final baseLng = (center.longitude / gridSize).floor() * gridSize;

    // 5x5 grid centered on the current cell
    for (int i = -2; i <= 2; i++) {
      for (int j = -2; j <= 2; j++) {
        final cellLat = baseLat + (i * gridSize);
        final cellLng = baseLng + (j * gridSize);
        final key = '$category:${cellLat.toStringAsFixed(2)}:${cellLng.toStringAsFixed(2)}';
        final cellCenter = LatLng(
          cellLat + gridSize / 2,
          cellLng + gridSize / 2,
        );
        cells.add(GridCell(key: key, center: cellCenter, category: category));
      }
    }

    return cells;
  }
}

/// Represents a single grid cell for POI searching.
class GridCell {
  final String key;
  final LatLng center;
  final String category;

  const GridCell({
    required this.key,
    required this.center,
    required this.category,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GridCell && runtimeType == other.runtimeType && key == other.key;

  @override
  int get hashCode => key.hashCode;
}
