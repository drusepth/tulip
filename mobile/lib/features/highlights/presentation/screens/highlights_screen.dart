import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/constants/tulip_colors.dart';
import '../../../../shared/constants/tulip_text_styles.dart';
import '../../../../shared/widgets/animated_widgets.dart';
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
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.8),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.arrow_back, size: 20),
          ),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Trip Highlights',
          style: TulipTextStyles.heading3,
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: [0.0, 0.3, 1.0],
            colors: [
              Color(0xFFFFF5EE), // Warm peach tint at top
              TulipColors.cream,
              Color(0xFFF5F0EB), // Slightly warmer cream at bottom
            ],
          ),
        ),
        child: highlightsAsync.when(
          loading: () => const Center(
            child: CircularProgressIndicator(color: TulipColors.sage),
          ),
          error: (error, stack) => _buildError(context, ref, error),
          data: (highlights) => _buildContent(context, ref, highlights),
        ),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Warm header area with extra top padding for app bar
            _buildHeader(highlights),

            // Stats section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: StatsSection(stats: highlights.stats),
            ),
            const SizedBox(height: 28),

            // Unrated items carousel
            if (unratedItems.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: UnratedCarousel(
                  items: unratedItems,
                  currentUserId: highlights.currentUserId,
                  onRate: (itemId, rating) async {
                    await rateHighlightItem(ref, stayId, itemId, rating);
                  },
                ),
              ),
              const SizedBox(height: 28),
            ],

            // Rated items section
            if (ratedItems.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: RatedSection(
                  items: ratedItems,
                  currentUserId: highlights.currentUserId,
                  onRate: (itemId, rating) async {
                    await rateHighlightItem(ref, stayId, itemId, rating);
                  },
                ),
              ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(dynamic highlights) {
    final stay = highlights.stay;
    final title = stayTitle ?? stay.title;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 100, 20, 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFFFFF5EE),
            TulipColors.rose.withValues(alpha: 0.15),
            TulipColors.lavender.withValues(alpha: 0.1),
          ],
        ),
      ),
      child: SlideUp(
        duration: const Duration(milliseconds: 500),
        offset: 20,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Stay title
            Text(
              title,
              style: TulipTextStyles.heading1.copyWith(
                fontSize: 28,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 8),
            // Completion badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: TulipColors.sage.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: TulipColors.sage.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.check_circle,
                    size: 16,
                    color: TulipColors.sageDark,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${highlights.totalItems} completed ${highlights.totalItems == 1 ? 'item' : 'items'}',
                    style: TulipTextStyles.bodySmall.copyWith(
                      color: TulipColors.sageDark,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    TulipColors.lavender.withValues(alpha: 0.3),
                    TulipColors.rose.withValues(alpha: 0.3),
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.auto_awesome_outlined,
                size: 36,
                color: TulipColors.brownLight,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'No highlights yet',
              style: TulipTextStyles.heading2,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Complete items from your bucket list\nto see them here.',
              style: TulipTextStyles.bodySmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),
            OutlinedButton(
              onPressed: () => context.pop(),
              style: OutlinedButton.styleFrom(
                foregroundColor: TulipColors.sage,
                side: const BorderSide(color: TulipColors.sage),
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              child: const Text('Go Back'),
            ),
          ],
        ),
      ),
    );
  }
}
