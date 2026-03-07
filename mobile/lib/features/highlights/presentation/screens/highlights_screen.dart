import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/constants/tulip_colors.dart';
import '../../../../shared/constants/tulip_text_styles.dart';
import '../providers/highlights_provider.dart';
import '../widgets/stats_section.dart';
import '../widgets/unrated_carousel.dart';
import '../widgets/rated_section.dart';

/// Screen displaying trip highlights - completed bucket list items with ratings
class HighlightsScreen extends ConsumerWidget {
  final int stayId;
  final String? stayTitle;

  const HighlightsScreen({
    super.key,
    required this.stayId,
    this.stayTitle,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final highlightsAsync = ref.watch(highlightsProvider(stayId));

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Trip Highlights',
          style: TulipTextStyles.heading3,
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      backgroundColor: TulipColors.cream,
      body: highlightsAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: TulipColors.sage),
        ),
        error: (error, stack) => _buildError(context, ref, error),
        data: (highlights) => _buildContent(context, ref, highlights),
      ),
    );
  }

  Widget _buildError(BuildContext context, WidgetRef ref, Object error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: TulipColors.brownLighter,
            ),
            const SizedBox(height: 16),
            Text(
              'Unable to load highlights',
              style: TulipTextStyles.heading3,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              error.toString(),
              style: TulipTextStyles.bodySmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => ref.invalidate(highlightsProvider(stayId)),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, WidgetRef ref, dynamic highlights) {
    if (!highlights.hasItems) {
      return _buildEmptyState(context);
    }

    final unratedItems = highlights.getUnratedItems();
    final ratedItems = highlights.getRatedItems();

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(highlightsProvider(stayId));
      },
      color: TulipColors.sage,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            _buildHeader(highlights),
            const SizedBox(height: 24),

            // Stats section
            StatsSection(stats: highlights.stats),
            const SizedBox(height: 24),

            // Unrated items carousel
            if (unratedItems.isNotEmpty) ...[
              UnratedCarousel(
                items: unratedItems,
                currentUserId: highlights.currentUserId,
                onRate: (itemId, rating) async {
                  await rateHighlightItem(ref, stayId, itemId, rating);
                },
              ),
              const SizedBox(height: 24),
            ],

            // Rated items section
            if (ratedItems.isNotEmpty)
              RatedSection(
                items: ratedItems,
                currentUserId: highlights.currentUserId,
                onRate: (itemId, rating) async {
                  await rateHighlightItem(ref, stayId, itemId, rating);
                },
              ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(dynamic highlights) {
    final stay = highlights.stay;
    final title = stayTitle ?? stay.title;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TulipTextStyles.heading2,
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Icon(
              Icons.check_circle,
              size: 16,
              color: TulipColors.sage,
            ),
            const SizedBox(width: 6),
            Text(
              '${highlights.totalItems} completed ${highlights.totalItems == 1 ? 'item' : 'items'}',
              style: TulipTextStyles.bodySmall.copyWith(
                color: TulipColors.sage,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.auto_awesome_outlined,
              size: 64,
              color: TulipColors.brownLighter,
            ),
            const SizedBox(height: 16),
            Text(
              'No highlights yet',
              style: TulipTextStyles.heading3,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Complete items from your bucket list to see them here.',
              style: TulipTextStyles.bodySmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            OutlinedButton(
              onPressed: () => context.pop(),
              style: OutlinedButton.styleFrom(
                foregroundColor: TulipColors.sage,
                side: const BorderSide(color: TulipColors.sage),
              ),
              child: const Text('Go Back'),
            ),
          ],
        ),
      ),
    );
  }
}
