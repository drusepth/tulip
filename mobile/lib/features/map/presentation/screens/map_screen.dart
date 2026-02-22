import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import '../../../../shared/constants/tulip_colors.dart';
import '../../../../shared/constants/tulip_text_styles.dart';
import '../../../bucket_list/data/models/bucket_list_item_model.dart';
import '../../../bucket_list/presentation/providers/bucket_list_provider.dart';
import '../../../places/data/models/poi_model.dart';
import '../../../stays/data/models/stay_model.dart';
import '../../../stays/presentation/providers/stays_provider.dart';
import '../../../transit/data/models/transit_route_model.dart';
import '../../../transit/presentation/providers/transit_route_provider.dart';
import '../providers/map_provider.dart';
import '../providers/viewport_poi_provider.dart';
import '../widgets/tulip_map.dart';
import '../widgets/stay_marker.dart';
import '../widgets/poi_marker.dart';
import '../widgets/poi_popup.dart';
import '../widgets/layer_toggle_panel.dart';

class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  final MapController _mapController = MapController();
  bool _showLayerPanel = false;
  bool _mapReady = false;
  Set<String> _previousEnabledCategories = {};

  @override
  void initState() {
    super.initState();
  }

  void _onMapReady() {
    if (_mapReady) return;
    _mapReady = true;
    // Small delay to ensure the map is fully rendered
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        _fitToStays();
      }
    });
  }

  void _onPositionChanged(MapPosition position, bool hasGesture) {
    if (position.center == null || position.zoom == null) return;

    final mapState = ref.read(mapStateProvider);
    final mapStays = ref.read(mapStaysProvider);

    // Notify viewport POI provider of the change
    ref.read(viewportPoiProvider.notifier).onViewportChanged(
          center: position.center!,
          zoom: position.zoom!,
          enabledCategories: mapState.enabledPoiCategories,
          stays: mapStays,
        );
  }

  /// Find the nearest stay to a given POI for bucket list context
  Stay? _findNearestStay(Poi poi, List<Stay> stays) {
    if (stays.isEmpty) return null;

    Stay? nearest;
    double minDistance = double.infinity;
    const distance = Distance();

    for (final stay in stays) {
      if (!stay.hasCoordinates) continue;

      final d = distance.as(
        LengthUnit.Meter,
        LatLng(poi.latitude, poi.longitude),
        LatLng(stay.latitude!, stay.longitude!),
      );

      if (d < minDistance) {
        minDistance = d;
        nearest = stay;
      }
    }

    return nearest;
  }

  /// Handle adding a POI to a stay's bucket list
  Future<bool> _addPoiToBucketList(Poi poi, Stay stay) async {
    try {
      final request = BucketListItemRequest(
        title: poi.name,
        category: poi.category,
        address: poi.address,
        latitude: poi.latitude,
        longitude: poi.longitude,
        placeId: poi.placeId,
      );

      final item = await ref.read(bucketListProvider(stay.id).notifier).createItem(request);
      return item != null;
    } catch (e) {
      return false;
    }
  }

  void _fitToStays() {
    final stays = ref.read(mapStaysProvider);
    if (stays.isEmpty) return;

    final points = stays
        .where((s) => s.hasCoordinates)
        .map((s) => LatLng(s.latitude!, s.longitude!))
        .toList();

    if (points.isEmpty) return;

    if (points.length == 1) {
      _mapController.move(points.first, 14);
    } else {
      final bounds = LatLngBounds.fromPoints(points);
      _mapController.fitCamera(
        CameraFit.bounds(
          bounds: bounds,
          padding: const EdgeInsets.all(50),
        ),
      );
    }
  }

  /// Build polylines for all enabled transit layers
  List<Polyline> _buildTransitPolylines(List<Stay> stays, Set<TransitRouteType> enabledLayers) {
    if (enabledLayers.isEmpty) return [];

    final polylines = <Polyline>[];

    for (final stay in stays) {
      for (final type in enabledLayers) {
        final routesAsync = ref.watch(
          transitRoutesProvider(TransitRouteQuery(stayId: stay.id, routeType: type)),
        );

        routesAsync.whenData((routes) {
          for (final route in routes) {
            final color = _parseColor(route.displayColor);
            for (final path in route.paths) {
              if (path.length >= 2) {
                polylines.add(Polyline(
                  points: path,
                  color: color.withValues(alpha: route.lineOpacity),
                  strokeWidth: route.lineWeight,
                ));
              }
            }
          }
        });
      }
    }

    return polylines;
  }

  Color _parseColor(String hexColor) {
    final hex = hexColor.replaceFirst('#', '');
    if (hex.length == 6) {
      return Color(int.parse('FF$hex', radix: 16));
    }
    return TulipColors.brownLight;
  }

  @override
  Widget build(BuildContext context) {
    final staysAsync = ref.watch(staysProvider);
    final mapStays = ref.watch(mapStaysProvider);
    final mapState = ref.watch(mapStateProvider);
    final selectedStay = ref.watch(selectedMapStayProvider);
    final viewportPoiState = ref.watch(viewportPoiProvider);
    final transitPolylines = _buildTransitPolylines(mapStays, mapState.enabledTransitLayers);

    // Handle category disabling
    final currentCategories = mapState.enabledPoiCategories;
    final disabledCategories = _previousEnabledCategories.difference(currentCategories);
    for (final category in disabledCategories) {
      // Use Future.microtask to avoid calling notifier during build
      Future.microtask(() {
        ref.read(viewportPoiProvider.notifier).onCategoryDisabled(category);
      });
    }
    _previousEnabledCategories = Set.from(currentCategories);

    // Combine stay markers with POI markers
    final stayMarkers = StayMarkerBuilder.buildAll(
      stays: mapStays,
      onTap: (stay) {
        ref.read(viewportPoiProvider.notifier).clearSelection();
        ref.read(mapStateProvider.notifier).selectStay(stay.id);
      },
      selectedStayId: mapState.selectedStayId,
    );

    final poiMarkers = PoiMarkerBuilder.buildAll(
      pois: viewportPoiState.poisForCategories(mapState.enabledPoiCategories),
      onTap: (poi) {
        ref.read(mapStateProvider.notifier).clearSelection();
        ref.read(viewportPoiProvider.notifier).selectPoi(poi);
      },
      selectedPoiId: viewportPoiState.selectedPoi?.id,
      enabledCategories: mapState.enabledPoiCategories,
    );

    final allMarkers = [...poiMarkers, ...stayMarkers]; // Stay markers on top

    return Scaffold(
      body: Stack(
        children: [
          // Map
          staysAsync.when(
            loading: () => const Center(
              child: CircularProgressIndicator(color: TulipColors.sage),
            ),
            error: (error, stack) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 48, color: TulipColors.roseDark),
                  const SizedBox(height: 16),
                  Text('Unable to load map', style: TulipTextStyles.heading3),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () => ref.read(staysProvider.notifier).refresh(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
            data: (_) => TulipMap(
              mapController: _mapController,
              markers: allMarkers,
              polylines: transitPolylines,
              onMapReady: _onMapReady,
              onPositionChanged: _onPositionChanged,
              onTap: (_, __) {
                // Tap on map clears all selections
                ref.read(mapStateProvider.notifier).clearSelection();
                ref.read(viewportPoiProvider.notifier).clearSelection();
              },
            ),
          ),

          // Top controls
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            left: 16,
            right: 16,
            child: Row(
              children: [
                const Spacer(),
                // Layer toggle
                MapControlButton(
                  icon: Icons.layers,
                  onPressed: () {
                    setState(() {
                      _showLayerPanel = !_showLayerPanel;
                    });
                  },
                  tooltip: 'Layers',
                ),
              ],
            ),
          ),

          // Right side controls
          Positioned(
            right: 16,
            bottom: (selectedStay != null || viewportPoiState.selectedPoi != null) ? 220 : 100,
            child: Column(
              children: [
                MapControlButton(
                  icon: Icons.my_location,
                  onPressed: _fitToStays,
                  tooltip: 'Fit to stays',
                ),
                const SizedBox(height: 8),
                MapControlButton(
                  icon: Icons.add,
                  onPressed: () {
                    _mapController.move(
                      _mapController.camera.center,
                      _mapController.camera.zoom + 1,
                    );
                  },
                  tooltip: 'Zoom in',
                ),
                const SizedBox(height: 8),
                MapControlButton(
                  icon: Icons.remove,
                  onPressed: () {
                    _mapController.move(
                      _mapController.camera.center,
                      _mapController.camera.zoom - 1,
                    );
                  },
                  tooltip: 'Zoom out',
                ),
              ],
            ),
          ),

          // Selected stay popup
          if (selectedStay != null)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: StayMarkerPopup(
                stay: selectedStay,
                onTap: () {
                  context.push('/stays/${selectedStay.id}');
                },
                onClose: () {
                  ref.read(mapStateProvider.notifier).clearSelection();
                },
              ),
            ),

          // Selected POI popup
          if (viewportPoiState.selectedPoi != null && selectedStay == null)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: PoiPopup(
                poi: viewportPoiState.selectedPoi!,
                nearestStay: _findNearestStay(viewportPoiState.selectedPoi!, mapStays),
                onClose: () {
                  ref.read(viewportPoiProvider.notifier).clearSelection();
                },
                onAddToBucketList: (stay) => _addPoiToBucketList(viewportPoiState.selectedPoi!, stay),
              ),
            ),

          // Layer toggle panel
          if (_showLayerPanel)
            Positioned(
              top: MediaQuery.of(context).padding.top + 70,
              right: 16,
              child: LayerTogglePanel(
                enabledCategories: mapState.enabledPoiCategories,
                enabledTransitLayers: mapState.enabledTransitLayers,
                onCategoryToggled: (category) {
                  ref.read(mapStateProvider.notifier).togglePoiCategory(category);
                },
                onTransitLayerToggled: (type) {
                  ref.read(mapStateProvider.notifier).toggleTransitLayer(type);
                },
                onClose: () {
                  setState(() {
                    _showLayerPanel = false;
                  });
                },
              ),
            ),

          // Empty state
          if (mapStays.isEmpty && staysAsync.hasValue)
            Center(
              child: Container(
                margin: const EdgeInsets.all(32),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.map_outlined,
                      size: 48,
                      color: TulipColors.brownLighter,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No stays to show',
                      style: TulipTextStyles.heading3,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Add a stay with a location to see it on the map',
                      style: TulipTextStyles.bodySmall,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () => context.push('/stays/new'),
                      icon: const Icon(Icons.add),
                      label: const Text('Add Stay'),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
