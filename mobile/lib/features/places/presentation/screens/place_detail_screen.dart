import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:latlong2/latlong.dart';
import '../../../../shared/constants/tulip_colors.dart';
import '../../../../shared/constants/tulip_text_styles.dart';
import '../../../../shared/widgets/cozy_card.dart';
import '../../../map/presentation/widgets/tulip_map.dart';
import '../../data/models/poi_model.dart';
import '../providers/poi_provider.dart';

class PlaceDetailScreen extends ConsumerWidget {
  final int placeId;
  final int? stayId; // Optional: if viewing from a stay context

  const PlaceDetailScreen({
    super.key,
    required this.placeId,
    this.stayId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final placeAsync = ref.watch(placeDetailProvider(placeId));

    return Scaffold(
      body: placeAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: TulipColors.sage),
        ),
        error: (error, stack) => _buildErrorState(context, error),
        data: (place) => _buildPlaceDetail(context, ref, place),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, Object error) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: TulipColors.roseDark),
            const SizedBox(height: 16),
            Text('Unable to load place', style: TulipTextStyles.heading3),
            const SizedBox(height: 8),
            Text(
              error.toString(),
              style: TulipTextStyles.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceDetail(BuildContext context, WidgetRef ref, Place place) {
    return CustomScrollView(
      slivers: [
        // App bar with photo
        SliverAppBar(
          expandedHeight: place.foursquarePhotoUrl != null ? 250 : 0,
          pinned: true,
          leading: IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.9),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.arrow_back, size: 20),
            ),
            onPressed: () => context.pop(),
          ),
          flexibleSpace: place.foursquarePhotoUrl != null
              ? FlexibleSpaceBar(
                  background: CachedNetworkImage(
                    imageUrl: place.foursquarePhotoUrl!,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: TulipColors.taupeLight,
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: TulipColors.taupeLight,
                      child: Icon(
                        _getCategoryIcon(place.category),
                        color: TulipColors.brownLighter,
                        size: 64,
                      ),
                    ),
                  ),
                )
              : null,
        ),
        // Content
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name and category
                Text(place.name, style: TulipTextStyles.heading2),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      _getCategoryIcon(place.category),
                      size: 16,
                      color: TulipColors.brownLight,
                    ),
                    const SizedBox(width: 4),
                    Text(place.categoryDisplay, style: TulipTextStyles.bodySmall),
                    if (place.distanceFormatted != null) ...[
                      const SizedBox(width: 12),
                      Icon(
                        Icons.directions_walk,
                        size: 14,
                        color: TulipColors.brownLight,
                      ),
                      const SizedBox(width: 2),
                      Text(place.distanceFormatted!, style: TulipTextStyles.bodySmall),
                    ],
                  ],
                ),
                const SizedBox(height: 16),

                // Rating and price
                if (place.foursquareRating != null || place.foursquarePrice != null)
                  CozyCard(
                    child: Row(
                      children: [
                        if (place.foursquareRating != null) ...[
                          Icon(Icons.star, color: TulipColors.coral, size: 20),
                          const SizedBox(width: 4),
                          Text(
                            place.foursquareRating!.toStringAsFixed(1),
                            style: TulipTextStyles.heading3,
                          ),
                          Text('/10', style: TulipTextStyles.caption),
                        ],
                        if (place.foursquareRating != null && place.priceDisplay != null)
                          const SizedBox(width: 24),
                        if (place.priceDisplay != null) ...[
                          Text(
                            place.priceDisplay!,
                            style: TulipTextStyles.heading3.copyWith(
                              color: TulipColors.sage,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                const SizedBox(height: 16),

                // Address
                if (place.address != null)
                  CozyCard(
                    child: Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          color: TulipColors.brownLight,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(place.address!, style: TulipTextStyles.body),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 16),

                // Opening hours
                if (place.openingHours != null)
                  CozyCard(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.schedule,
                          color: TulipColors.brownLight,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(place.openingHours!, style: TulipTextStyles.body),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 16),

                // Mini map
                Text('Location', style: TulipTextStyles.label),
                const SizedBox(height: 8),
                TulipMiniMap(
                  center: LatLng(place.latitude, place.longitude),
                  zoom: 15,
                ),
                const SizedBox(height: 24),

                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: _ActionButton(
                        icon: place.favorite ? Icons.favorite : Icons.favorite_border,
                        label: place.favorite ? 'Favorited' : 'Favorite',
                        color: place.favorite ? TulipColors.rose : null,
                        onTap: () {
                          // TODO: Toggle favorite
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _ActionButton(
                        icon: place.inBucketList ? Icons.check_circle : Icons.add_circle_outline,
                        label: place.inBucketList ? 'In Bucket List' : 'Add to List',
                        color: place.inBucketList ? TulipColors.sage : null,
                        onTap: () {
                          // TODO: Add to bucket list
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ],
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
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

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: TulipColors.taupeLight),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 20, color: color ?? TulipColors.brownLight),
            const SizedBox(width: 8),
            Text(
              label,
              style: TulipTextStyles.label.copyWith(
                color: color ?? TulipColors.brown,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
