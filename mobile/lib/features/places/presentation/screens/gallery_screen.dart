import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../shared/constants/tulip_colors.dart';
import '../../../../shared/constants/tulip_text_styles.dart';
import '../../data/models/gallery_item_model.dart';
import '../providers/gallery_provider.dart';

class GalleryScreen extends ConsumerStatefulWidget {
  final int stayId;
  final String? stayTitle;

  const GalleryScreen({
    super.key,
    required this.stayId,
    this.stayTitle,
  });

  @override
  ConsumerState<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends ConsumerState<GalleryScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(galleryProvider(widget.stayId).notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final galleryAsync = ref.watch(galleryProvider(widget.stayId));

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.stayTitle != null ? 'Explore ${widget.stayTitle}' : 'Gallery'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: galleryAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: TulipColors.sage),
        ),
        error: (error, stack) => _buildErrorState(error),
        data: (state) => _buildGalleryGrid(state),
      ),
    );
  }

  Widget _buildErrorState(Object error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: TulipColors.roseDark),
          const SizedBox(height: 16),
          Text('Unable to load gallery', style: TulipTextStyles.heading3),
          const SizedBox(height: 8),
          Text(
            error.toString(),
            style: TulipTextStyles.bodySmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => ref.read(galleryProvider(widget.stayId).notifier).refresh(),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildGalleryGrid(GalleryState state) {
    if (state.items.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(galleryProvider(widget.stayId).notifier).refresh(),
      color: TulipColors.sage,
      child: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // Header with count
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(
                    Icons.photo_library_outlined,
                    size: 20,
                    color: TulipColors.brownLight,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${state.totalCount} places nearby',
                    style: TulipTextStyles.label,
                  ),
                ],
              ),
            ),
          ),

          // Grid of gallery items
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.75,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  if (index < state.items.length) {
                    return _GalleryItemCard(
                      item: state.items[index],
                      stayId: widget.stayId,
                      onTap: () => context.push('/places/${state.items[index].id}?stay_id=${widget.stayId}'),
                    );
                  }
                  return null;
                },
                childCount: state.items.length,
              ),
            ),
          ),

          // Loading indicator for pagination
          if (state.isLoadingMore)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Center(
                  child: CircularProgressIndicator(color: TulipColors.sage),
                ),
              ),
            ),

          // Bottom padding
          const SliverToBoxAdapter(
            child: SizedBox(height: 32),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.photo_library_outlined,
            size: 64,
            color: TulipColors.brownLighter,
          ),
          const SizedBox(height: 16),
          Text(
            'No places found',
            style: TulipTextStyles.heading3,
          ),
          const SizedBox(height: 8),
          Text(
            'We couldn\'t find any places near this stay',
            style: TulipTextStyles.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _GalleryItemCard extends StatelessWidget {
  final GalleryItem item;
  final int stayId;
  final VoidCallback onTap;

  const _GalleryItemCard({
    required this.item,
    required this.stayId,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image section
            Expanded(
              flex: 3,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Image or placeholder
                  if (item.hasPhoto)
                    CachedNetworkImage(
                      imageUrl: item.foursquarePhotoUrl!,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: TulipColors.taupeLight,
                      ),
                      errorWidget: (context, url, error) => _buildPlaceholder(),
                    )
                  else
                    _buildPlaceholder(),

                  // Status badges
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Row(
                      children: [
                        if (item.favorite)
                          _buildBadge(Icons.favorite, TulipColors.rose),
                        if (item.inBucketList) ...[
                          if (item.favorite) const SizedBox(width: 4),
                          _buildBadge(Icons.checklist, TulipColors.sage),
                        ],
                      ],
                    ),
                  ),

                  // Rating badge
                  if (item.hasRating)
                    Positioned(
                      bottom: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.star,
                              size: 14,
                              color: TulipColors.coral,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              item.foursquareRating!.toStringAsFixed(1),
                              style: TulipTextStyles.caption.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Info section
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name
                    Text(
                      item.name,
                      style: TulipTextStyles.label,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    // Category and distance
                    Row(
                      children: [
                        Icon(
                          _getCategoryIcon(item.category),
                          size: 12,
                          color: TulipColors.brownLighter,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            item.categoryDisplay,
                            style: TulipTextStyles.caption,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    if (item.distanceFormatted != null || item.priceDisplay != null)
                      Row(
                        children: [
                          if (item.distanceFormatted != null) ...[
                            Icon(
                              Icons.directions_walk,
                              size: 12,
                              color: TulipColors.brownLighter,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              item.distanceFormatted!,
                              style: TulipTextStyles.caption,
                            ),
                          ],
                          if (item.distanceFormatted != null && item.priceDisplay != null)
                            const SizedBox(width: 8),
                          if (item.priceDisplay != null)
                            Text(
                              item.priceDisplay!,
                              style: TulipTextStyles.caption.copyWith(
                                color: TulipColors.sage,
                              ),
                            ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: TulipColors.taupeLight,
      child: Center(
        child: Icon(
          _getCategoryIcon(item.category),
          size: 32,
          color: TulipColors.brownLighter,
        ),
      ),
    );
  }

  Widget _buildBadge(IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
          ),
        ],
      ),
      child: Icon(
        icon,
        size: 14,
        color: color,
      ),
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
      case 'attractions':
        return Icons.museum;
      default:
        return Icons.place;
    }
  }
}
