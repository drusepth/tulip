import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../shared/constants/tulip_colors.dart';
import '../../../../shared/constants/tulip_text_styles.dart';
import '../../data/repositories/explored_repository.dart';
import '../providers/explored_provider.dart';

/// Colors assigned to visited states, cycling through cottagecore palette
const _visitedColors = [
  TulipColors.sage,
  TulipColors.rose,
  TulipColors.lavender,
  TulipColors.taupe,
];

const _upcomingColor = TulipColors.coral;
const _unvisitedColor = Color(0xFFD4D4D4);
const _borderColor = TulipColors.brown;

class ExploredScreen extends ConsumerStatefulWidget {
  const ExploredScreen({super.key});

  @override
  ConsumerState<ExploredScreen> createState() => _ExploredScreenState();
}

class _ExploredScreenState extends ConsumerState<ExploredScreen> {
  final MapController _mapController = MapController();
  List<Map<String, dynamic>>? _geoJsonFeatures;
  String? _selectedState;

  @override
  void initState() {
    super.initState();
    _loadGeoJson();
  }

  Future<void> _loadGeoJson() async {
    try {
      final jsonString = await rootBundle.loadString('assets/us-states.geo.json');
      final geoJson = json.decode(jsonString) as Map<String, dynamic>;
      final features = (geoJson['features'] as List<dynamic>)
          .cast<Map<String, dynamic>>();
      setState(() {
        _geoJsonFeatures = features;
      });
    } catch (e) {
      debugPrint('Failed to load GeoJSON: $e');
    }
  }

  Color _colorForState(String name) {
    int hash = 0;
    for (int i = 0; i < name.length; i++) {
      hash = ((hash << 5) - hash) + name.codeUnitAt(i);
      hash &= 0x7FFFFFFF;
    }
    return _visitedColors[hash % _visitedColors.length];
  }

  /// Parse GeoJSON coordinates into LatLng lists for polygons
  List<List<LatLng>> _parseGeometry(Map<String, dynamic> geometry) {
    final type = geometry['type'] as String;
    final coordinates = geometry['coordinates'];
    final polygons = <List<LatLng>>[];

    if (type == 'Polygon') {
      for (final ring in coordinates as List) {
        polygons.add(_parseRing(ring as List));
      }
    } else if (type == 'MultiPolygon') {
      for (final polygon in coordinates as List) {
        for (final ring in polygon as List) {
          polygons.add(_parseRing(ring as List));
        }
      }
    }
    return polygons;
  }

  List<LatLng> _parseRing(List ring) {
    return ring
        .map((coord) => LatLng(
              (coord[1] as num).toDouble(),
              (coord[0] as num).toDouble(),
            ))
        .toList();
  }

  /// Compute centroid of a polygon for label placement
  LatLng _computeCentroid(List<List<LatLng>> rings) {
    if (rings.isEmpty || rings.first.isEmpty) return const LatLng(0, 0);
    final points = rings.first;
    double lat = 0, lng = 0;
    for (final p in points) {
      lat += p.latitude;
      lng += p.longitude;
    }
    return LatLng(lat / points.length, lng / points.length);
  }

  void _onStateTapped(String stateName, ExploredData data) {
    setState(() {
      _selectedState = stateName;
    });
    _showStatePanel(stateName, data);
  }

  void _showStatePanel(String stateName, ExploredData data) {
    final stateData = data.states[stateName];
    final isVisited = stateData != null;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _StateBottomSheet(
        stateName: stateName,
        stateData: stateData,
        isVisited: isVisited,
        onStayTapped: (stayId) {
          Navigator.pop(context);
          context.push('/stays/$stayId');
        },
        onAddDreamDestination: () {
          Navigator.pop(context);
          context.push('/stays/new?state=$stateName');
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final exploredAsync = ref.watch(exploredDataProvider);

    return Scaffold(
      body: exploredAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: TulipColors.sage),
        ),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 48, color: TulipColors.roseDark),
              const SizedBox(height: 16),
              Text('Unable to load explored data', style: TulipTextStyles.heading3),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () => ref.invalidate(exploredDataProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (data) => Column(
          children: [
            // Stats banner
            _StatsBanner(
              totalVisited: data.totalVisited,
              totalStates: data.totalStates,
            ),
            // Map
            Expanded(
              child: _buildMap(data),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMap(ExploredData data) {
    final polygons = <Polygon>[];
    final markers = <Marker>[];

    if (_geoJsonFeatures != null) {
      for (final feature in _geoJsonFeatures!) {
        final name = feature['properties']?['name'] as String? ?? '';
        final geometry = feature['geometry'] as Map<String, dynamic>;
        final rings = _parseGeometry(geometry);
        final hasState = data.states.containsKey(name);
        final isVisited = data.hasVisitedStays(name);
        final isUpcomingOnly = data.hasOnlyUpcomingStays(name);

        // Determine color: visited (past/current) > upcoming > unvisited
        Color stateColor;
        double borderAlpha;
        double borderWidth;

        if (isVisited) {
          stateColor = _colorForState(name).withValues(alpha: 0.6);
          borderAlpha = 0.5;
          borderWidth = 1.0;
        } else if (isUpcomingOnly) {
          stateColor = _upcomingColor.withValues(alpha: 0.5);
          borderAlpha = 0.4;
          borderWidth = 1.0;
        } else {
          stateColor = _unvisitedColor.withValues(alpha: 0.4);
          borderAlpha = 0.2;
          borderWidth = 0.5;
        }

        for (final ring in rings) {
          polygons.add(Polygon(
            points: ring,
            color: stateColor,
            borderColor: _borderColor.withValues(alpha: borderAlpha),
            borderStrokeWidth: borderWidth,
            isFilled: true,
          ));
        }

        // Add count badge marker for states with stays
        if (hasState && rings.isNotEmpty) {
          final centroid = _computeCentroid(rings);
          final count = data.states[name]!.count;
          markers.add(Marker(
            point: centroid,
            width: 28,
            height: 28,
            child: GestureDetector(
              onTap: () => _onStateTapped(name, data),
              child: Container(
                decoration: BoxDecoration(
                  color: isUpcomingOnly ? TulipColors.coralDark : TulipColors.brown,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 3,
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    '$count',
                    style: const TextStyle(
                      color: TulipColors.cream,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
          ));
        }
      }
    }

    return Stack(
      children: [
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: const LatLng(39.8, -98.5),
            initialZoom: 4,
            minZoom: 3,
            maxZoom: 8,
            backgroundColor: TulipColors.cream,
            onTap: (tapPosition, point) {
              // Find which state was tapped by checking if point is inside any polygon
              if (_geoJsonFeatures != null) {
                for (final feature in _geoJsonFeatures!) {
                  final name = feature['properties']?['name'] as String? ?? '';
                  final geometry = feature['geometry'] as Map<String, dynamic>;
                  final rings = _parseGeometry(geometry);
                  for (final ring in rings) {
                    if (_isPointInPolygon(point, ring)) {
                      _onStateTapped(name, ref.read(exploredDataProvider).value!);
                      return;
                    }
                  }
                }
              }
            },
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.tulip.app',
              maxZoom: 19,
              tileBuilder: _tileBuilder,
            ),
            PolygonLayer(polygons: polygons),
            MarkerLayer(markers: markers),
          ],
        ),
      ],
    );
  }

  /// Apply warm tint to match existing TulipMap style
  Widget _tileBuilder(BuildContext context, Widget tileWidget, TileImage tile) {
    return ColorFiltered(
      colorFilter: const ColorFilter.matrix(<double>[
        1.0, 0.0, 0.0, 0.0, 5.0,
        0.0, 1.0, 0.0, 0.0, 3.0,
        0.0, 0.0, 0.95, 0.0, 0.0,
        0.0, 0.0, 0.0, 1.0, 0.0,
      ]),
      child: tileWidget,
    );
  }

  /// Ray-casting algorithm for point-in-polygon test
  bool _isPointInPolygon(LatLng point, List<LatLng> polygon) {
    bool inside = false;
    int j = polygon.length - 1;
    for (int i = 0; i < polygon.length; i++) {
      if ((polygon[i].latitude > point.latitude) !=
              (polygon[j].latitude > point.latitude) &&
          point.longitude <
              (polygon[j].longitude - polygon[i].longitude) *
                      (point.latitude - polygon[i].latitude) /
                      (polygon[j].latitude - polygon[i].latitude) +
                  polygon[i].longitude) {
        inside = !inside;
      }
      j = i;
    }
    return inside;
  }
}

class _StatsBanner extends StatelessWidget {
  final int totalVisited;
  final int totalStates;

  const _StatsBanner({
    required this.totalVisited,
    required this.totalStates,
  });

  @override
  Widget build(BuildContext context) {
    final pct = totalStates > 0 ? totalVisited / totalStates : 0.0;

    return Container(
      color: Colors.white,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 12,
        left: 16,
        right: 16,
        bottom: 12,
      ),
      child: Row(
        children: [
          Text('Explored', style: TulipTextStyles.heading2),
          const SizedBox(width: 12),
          Text(
            '$totalVisited of $totalStates states',
            style: TulipTextStyles.bodySmall,
          ),
          const Spacer(),
          SizedBox(
            width: 80,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: pct,
                backgroundColor: TulipColors.taupeLight,
                color: TulipColors.sage,
                minHeight: 6,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StateBottomSheet extends StatelessWidget {
  final String stateName;
  final ExploredState? stateData;
  final bool isVisited;
  final void Function(int stayId) onStayTapped;
  final VoidCallback onAddDreamDestination;

  const _StateBottomSheet({
    required this.stateName,
    this.stateData,
    required this.isVisited,
    required this.onStayTapped,
    required this.onAddDreamDestination,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.6,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: TulipColors.taupeLight,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(stateName, style: TulipTextStyles.heading2),
                      const SizedBox(height: 2),
                      Text(
                        isVisited
                            ? '${stateData!.count} ${stateData!.count == 1 ? "stay" : "stays"}'
                            : 'Not yet explored',
                        style: TulipTextStyles.bodySmall,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: TulipColors.brown),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // Content
          if (isVisited)
            Flexible(
              child: _StaysList(
                stateData: stateData!,
                onStayTapped: onStayTapped,
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: TulipColors.lavenderLight,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.favorite_outline,
                      size: 32,
                      color: TulipColors.lavenderDark,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'You haven\'t explored $stateName yet.',
                    style: TulipTextStyles.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: onAddDreamDestination,
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Add to dream destinations'),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _StayCard extends StatelessWidget {
  final ExploredStay stay;
  final VoidCallback onTap;
  final bool isUpcoming;

  const _StayCard({
    required this.stay,
    required this.onTap,
    this.isUpcoming = false,
  });

  String _formatDates() {
    if (stay.checkIn == null || stay.checkOut == null) return '';
    try {
      final checkIn = DateTime.parse(stay.checkIn!);
      final checkOut = DateTime.parse(stay.checkOut!);
      final months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
      ];
      return '${months[checkIn.month - 1]} ${checkIn.day}, ${checkIn.year}'
          ' — ${months[checkOut.month - 1]} ${checkOut.day}, ${checkOut.year}';
    } catch (_) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isUpcoming
              ? TulipColors.coral.withValues(alpha: 0.05)
              : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isUpcoming ? TulipColors.coral.withValues(alpha: 0.4) : TulipColors.taupeLight,
          ),
        ),
        child: Row(
          children: [
            // Image
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                width: 56,
                height: 56,
                child: stay.imageUrl != null
                    ? CachedNetworkImage(
                        imageUrl: stay.imageUrl!,
                        fit: BoxFit.cover,
                        placeholder: (_, __) => Container(
                          color: TulipColors.taupeLight,
                        ),
                        errorWidget: (_, __, ___) => _placeholderIcon(),
                      )
                    : _placeholderIcon(),
              ),
            ),
            const SizedBox(width: 12),
            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    stay.title,
                    style: TulipTextStyles.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (stay.city != null) ...[
                    const SizedBox(height: 2),
                    Text(stay.city!, style: TulipTextStyles.caption),
                  ],
                  const SizedBox(height: 2),
                  Text(_formatDates(), style: TulipTextStyles.caption),
                  if (stay.durationDays != null && stay.durationDays! > 0) ...[
                    const SizedBox(height: 2),
                    Text(
                      '${stay.durationDays} nights',
                      style: TulipTextStyles.caption.copyWith(
                        color: TulipColors.sageDark,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: TulipColors.taupe, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _placeholderIcon() {
    return Container(
      color: TulipColors.taupeLight,
      child: const Icon(Icons.home_outlined, color: TulipColors.taupe, size: 24),
    );
  }
}

class _StaysList extends StatelessWidget {
  final ExploredState stateData;
  final void Function(int stayId) onStayTapped;

  const _StaysList({
    required this.stateData,
    required this.onStayTapped,
  });

  @override
  Widget build(BuildContext context) {
    // Group stays by status
    final pastStays = stateData.stays
        .where((s) => s.status == 'past' || s.status == 'current')
        .toList();
    final upcomingStays = stateData.stays
        .where((s) => s.status == 'upcoming')
        .toList();

    return ListView(
      shrinkWrap: true,
      padding: const EdgeInsets.all(16),
      children: [
        // Past/Current stays section
        if (pastStays.isNotEmpty) ...[
          _buildSectionHeader(
            icon: Icons.check_circle,
            iconColor: TulipColors.sage,
            title: 'Visited',
            count: pastStays.length,
          ),
          const SizedBox(height: 8),
          ...pastStays.map((stay) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _StayCard(
                  stay: stay,
                  onTap: () => onStayTapped(stay.id),
                ),
              )),
        ],

        // Upcoming stays section
        if (upcomingStays.isNotEmpty) ...[
          if (pastStays.isNotEmpty) const SizedBox(height: 16),
          _buildSectionHeader(
            icon: Icons.schedule,
            iconColor: TulipColors.coral,
            title: 'Upcoming',
            count: upcomingStays.length,
          ),
          const SizedBox(height: 8),
          ...upcomingStays.map((stay) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _StayCard(
                  stay: stay,
                  onTap: () => onStayTapped(stay.id),
                  isUpcoming: true,
                ),
              )),
        ],
      ],
    );
  }

  Widget _buildSectionHeader({
    required IconData icon,
    required Color iconColor,
    required String title,
    required int count,
  }) {
    return Row(
      children: [
        Icon(icon, size: 18, color: iconColor),
        const SizedBox(width: 8),
        Text(
          title,
          style: TulipTextStyles.label.copyWith(
            color: iconColor,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(width: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            '$count',
            style: TulipTextStyles.caption.copyWith(
              color: iconColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
