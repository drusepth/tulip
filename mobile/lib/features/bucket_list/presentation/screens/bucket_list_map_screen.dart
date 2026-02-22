import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import '../../../../shared/constants/tulip_colors.dart';
import '../../../../shared/constants/tulip_text_styles.dart';
import '../../../map/presentation/widgets/tulip_map.dart';
import '../../../stays/presentation/providers/stays_provider.dart';
import '../providers/bucket_list_provider.dart';
import '../../data/models/bucket_list_item_model.dart';

class BucketListMapScreen extends ConsumerStatefulWidget {
  final int stayId;
  final String? stayTitle;

  const BucketListMapScreen({
    super.key,
    required this.stayId,
    this.stayTitle,
  });

  @override
  ConsumerState<BucketListMapScreen> createState() =>
      _BucketListMapScreenState();
}

class _BucketListMapScreenState extends ConsumerState<BucketListMapScreen> {
  final MapController _mapController = MapController();
  BucketListItem? _selectedItem;
  bool _mapReady = false;

  @override
  void initState() {
    super.initState();
  }

  void _onMapReady() {
    if (_mapReady) return;
    _mapReady = true;
    // Small delay to ensure map is fully rendered
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        _fitToBucketListItems();
      }
    });
  }

  void _fitToBucketListItems() {
    final items = ref.read(bucketListProvider(widget.stayId)).valueOrNull ?? [];
    final itemsWithLocation = items.where((item) => item.hasLocation).toList();

    if (itemsWithLocation.isEmpty) {
      // Fall back to stay coordinates
      final stay = ref.read(stayDetailProvider(widget.stayId)).valueOrNull;
      if (stay != null && stay.hasCoordinates) {
        _mapController.move(LatLng(stay.latitude!, stay.longitude!), 14);
      }
      return;
    }

    final points = itemsWithLocation
        .map((item) => LatLng(item.latitude!, item.longitude!))
        .toList();

    if (points.length == 1) {
      _mapController.move(points.first, 15);
    } else {
      final bounds = LatLngBounds.fromPoints(points);
      _mapController.fitCamera(
        CameraFit.bounds(
          bounds: bounds,
          padding: const EdgeInsets.all(60),
        ),
      );
    }
  }

  List<Marker> _buildMarkers(List<BucketListItem> items) {
    return items.where((item) => item.hasLocation).map((item) {
      final isCompleted = item.completed;
      final isSelected = _selectedItem?.id == item.id;
      final color = isCompleted ? TulipColors.sage : TulipColors.rose;
      final size = isSelected ? 20.0 : 14.0;

      return Marker(
        point: LatLng(item.latitude!, item.longitude!),
        width: size + 8,
        height: size + 8,
        child: GestureDetector(
          onTap: () {
            setState(() {
              _selectedItem = item;
            });
          },
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white,
                width: isSelected ? 3 : 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: isCompleted
                ? Icon(
                    Icons.check,
                    size: size * 0.6,
                    color: Colors.white,
                  )
                : null,
          ),
        ),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final stayAsync = ref.watch(stayDetailProvider(widget.stayId));
    final bucketListAsync = ref.watch(bucketListProvider(widget.stayId));

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Bucket List Map'),
            if (widget.stayTitle != null)
              Text(
                widget.stayTitle!,
                style: TulipTextStyles.caption.copyWith(
                  color: TulipColors.brownLight,
                ),
              ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location),
            onPressed: _fitToBucketListItems,
            tooltip: 'Fit to items',
          ),
        ],
      ),
      body: stayAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: TulipColors.sage),
        ),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 48, color: TulipColors.roseDark),
              const SizedBox(height: 16),
              Text('Unable to load stay', style: TulipTextStyles.heading3),
            ],
          ),
        ),
        data: (stay) {
          final initialCenter = stay.hasCoordinates
              ? LatLng(stay.latitude!, stay.longitude!)
              : null;

          return bucketListAsync.when(
            loading: () => TulipMap(
              mapController: _mapController,
              initialCenter: initialCenter,
              initialZoom: 14,
              onMapReady: _onMapReady,
            ),
            error: (error, stack) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline,
                      size: 48, color: TulipColors.roseDark),
                  const SizedBox(height: 16),
                  Text('Unable to load bucket list',
                      style: TulipTextStyles.heading3),
                ],
              ),
            ),
            data: (items) {
              final itemsWithLocation =
                  items.where((item) => item.hasLocation).toList();

              return Stack(
                children: [
                  // Map
                  TulipMap(
                    mapController: _mapController,
                    initialCenter: initialCenter,
                    initialZoom: 14,
                    markers: _buildMarkers(items),
                    onMapReady: _onMapReady,
                    onTap: (_, __) {
                      setState(() {
                        _selectedItem = null;
                      });
                    },
                  ),

                  // Legend
                  Positioned(
                    top: 16,
                    left: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildLegendItem(
                            color: TulipColors.rose,
                            label: 'Pending',
                          ),
                          const SizedBox(width: 16),
                          _buildLegendItem(
                            color: TulipColors.sage,
                            label: 'Completed',
                            showCheck: true,
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Empty state overlay
                  if (itemsWithLocation.isEmpty)
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
                              Icons.location_off_outlined,
                              size: 48,
                              color: TulipColors.brownLighter,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No locations to show',
                              style: TulipTextStyles.heading3,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              items.isEmpty
                                  ? 'Add bucket list items with addresses to see them on the map'
                                  : 'None of your bucket list items have addresses yet',
                              style: TulipTextStyles.bodySmall,
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),

                  // Selected item popup
                  if (_selectedItem != null)
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: _buildItemPopup(_selectedItem!),
                    ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildLegendItem({
    required Color color,
    required String label,
    bool showCheck = false,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 2,
              ),
            ],
          ),
          child: showCheck
              ? const Icon(Icons.check, size: 8, color: Colors.white)
              : null,
        ),
        const SizedBox(width: 6),
        Text(label, style: TulipTextStyles.caption),
      ],
    );
  }

  Widget _buildItemPopup(BucketListItem item) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 12,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Status indicator
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: item.completed
                      ? TulipColors.sageLight
                      : TulipColors.roseLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  item.completed ? 'Completed' : 'Pending',
                  style: TulipTextStyles.caption.copyWith(
                    color:
                        item.completed ? TulipColors.sageDark : TulipColors.roseDark,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Spacer(),
              // Close button
              IconButton(
                icon: const Icon(Icons.close, size: 20),
                onPressed: () {
                  setState(() {
                    _selectedItem = null;
                  });
                },
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Title
          Text(
            item.title,
            style: TulipTextStyles.heading3,
          ),
          // Category
          if (item.category != null && item.category!.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              item.categoryDisplay,
              style: TulipTextStyles.caption.copyWith(
                color: TulipColors.brownLight,
              ),
            ),
          ],
          // Address
          if (item.address != null && item.address!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.location_on_outlined,
                  size: 16,
                  color: TulipColors.brownLight,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    item.address!,
                    style: TulipTextStyles.bodySmall,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
          // Notes
          if (item.notes != null && item.notes!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              item.notes!,
              style: TulipTextStyles.bodySmall,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          // Rating
          if (item.hasRating) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.star,
                  size: 16,
                  color: TulipColors.coral,
                ),
                const SizedBox(width: 4),
                Text(
                  item.averageRating!.toStringAsFixed(1),
                  style: TulipTextStyles.bodySmall.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
