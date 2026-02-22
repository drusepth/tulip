import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import '../../../stays/data/models/stay_model.dart';
import '../../../stays/presentation/providers/stays_provider.dart';
import '../../../transit/data/models/transit_route_model.dart';

/// Provider for map state
final mapStateProvider = StateNotifierProvider<MapStateNotifier, MapState>((ref) {
  return MapStateNotifier();
});

class MapState {
  final int? selectedStayId;
  final LatLng? center;
  final double zoom;
  final Set<String> enabledPoiCategories;
  final Set<TransitRouteType> enabledTransitLayers;
  final bool showPois;

  const MapState({
    this.selectedStayId,
    this.center,
    this.zoom = 12.0,
    this.enabledPoiCategories = const {
      'coffee',
      'restaurants',
      'grocery',
      'transit',
    },
    this.enabledTransitLayers = const {},
    this.showPois = true,
  });

  MapState copyWith({
    int? selectedStayId,
    LatLng? center,
    double? zoom,
    Set<String>? enabledPoiCategories,
    Set<TransitRouteType>? enabledTransitLayers,
    bool? showPois,
    bool clearSelectedStay = false,
  }) {
    return MapState(
      selectedStayId: clearSelectedStay ? null : (selectedStayId ?? this.selectedStayId),
      center: center ?? this.center,
      zoom: zoom ?? this.zoom,
      enabledPoiCategories: enabledPoiCategories ?? this.enabledPoiCategories,
      enabledTransitLayers: enabledTransitLayers ?? this.enabledTransitLayers,
      showPois: showPois ?? this.showPois,
    );
  }
}

class MapStateNotifier extends StateNotifier<MapState> {
  MapStateNotifier() : super(const MapState());

  void selectStay(int? stayId) {
    state = state.copyWith(
      selectedStayId: stayId,
      clearSelectedStay: stayId == null,
    );
  }

  void clearSelection() {
    state = state.copyWith(clearSelectedStay: true);
  }

  void setCenter(LatLng center) {
    state = state.copyWith(center: center);
  }

  void setZoom(double zoom) {
    state = state.copyWith(zoom: zoom);
  }

  void togglePoiCategory(String category) {
    final categories = Set<String>.from(state.enabledPoiCategories);
    if (categories.contains(category)) {
      categories.remove(category);
    } else {
      categories.add(category);
    }
    state = state.copyWith(enabledPoiCategories: categories);
  }

  void toggleShowPois() {
    state = state.copyWith(showPois: !state.showPois);
  }

  void setEnabledCategories(Set<String> categories) {
    state = state.copyWith(enabledPoiCategories: categories);
  }

  void toggleTransitLayer(TransitRouteType type) {
    final layers = Set<TransitRouteType>.from(state.enabledTransitLayers);
    if (layers.contains(type)) {
      layers.remove(type);
    } else {
      layers.add(type);
    }
    state = state.copyWith(enabledTransitLayers: layers);
  }

  void setEnabledTransitLayers(Set<TransitRouteType> layers) {
    state = state.copyWith(enabledTransitLayers: layers);
  }
}

/// Provider for the currently selected stay on the map
final selectedMapStayProvider = Provider<Stay?>((ref) {
  final mapState = ref.watch(mapStateProvider);
  final staysAsync = ref.watch(staysProvider);

  if (mapState.selectedStayId == null) return null;

  return staysAsync.whenOrNull(
    data: (stays) => stays.where((s) => s.id == mapState.selectedStayId).firstOrNull,
  );
});

/// Provider for stays with coordinates (for map display)
final mapStaysProvider = Provider<List<Stay>>((ref) {
  final staysAsync = ref.watch(staysProvider);
  return staysAsync.whenOrNull(
    data: (stays) => stays.where((s) => s.hasCoordinates).toList(),
  ) ?? [];
});

/// Available POI categories for the layer toggle
class PoiCategory {
  final String id;
  final String label;
  final String icon;

  const PoiCategory({
    required this.id,
    required this.label,
    required this.icon,
  });

  static const List<PoiCategory> all = [
    PoiCategory(id: 'coffee', label: 'Coffee', icon: 'coffee'),
    PoiCategory(id: 'restaurants', label: 'Restaurants', icon: 'restaurant'),
    PoiCategory(id: 'grocery', label: 'Grocery', icon: 'shopping_cart'),
    PoiCategory(id: 'bars', label: 'Bars', icon: 'local_bar'),
    PoiCategory(id: 'gyms', label: 'Gyms', icon: 'fitness_center'),
    PoiCategory(id: 'parks', label: 'Parks', icon: 'park'),
    PoiCategory(id: 'transit', label: 'Transit', icon: 'directions_transit'),
    PoiCategory(id: 'attractions', label: 'Attractions', icon: 'museum'),
  ];
}
