import 'dart:math' as math;
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

/// Screen displaying trip highlights - completed bucket list items with ratings.
/// Uses a SliverAppBar that collapses on scroll for a premium feel.
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
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: [0.0, 0.3, 1.0],
            colors: [
              Color(0xFFFFF5EE),
              TulipColors.cream,
              Color(0xFFF5F0EB),
            ],
          ),
        ),
        child: Stack(
          children: [
            // Background botanical decorations
            const _BackgroundBotanicals(),
            // Main content
            highlightsAsync.when(
              loading: () => const Center(
                child: CircularProgressIndicator(color: TulipColors.sage),
              ),
              error: (error, stack) => _buildError(context, ref, error),
              data: (highlights) => _buildContent(context, ref, highlights),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildError(BuildContext context, WidgetRef ref, Object error) {
    return SafeArea(
      child: Center(
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
      ),
    );
  }

  Widget _buildContent(BuildContext context, WidgetRef ref, dynamic highlights) {
    if (!highlights.hasItems) {
      return _buildEmptyState(context);
    }

    final unratedItems = highlights.getUnratedItems();
    final ratedItems = highlights.getRatedItems();
    final stay = highlights.stay;
    final title = stayTitle ?? stay.title;
    final totalItems = highlights.totalItems;

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(highlightsProvider(stayId));
      },
      color: TulipColors.sage,
      edgeOffset: 120,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        slivers: [
          // Collapsing app bar with header
          SliverAppBar(
            expandedHeight: 180,
            floating: false,
            pinned: true,
            stretch: true,
            backgroundColor: const Color(0xFFFFF5EE),
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            scrolledUnderElevation: 0.5,
            leading: Padding(
              padding: const EdgeInsets.all(8),
              child: GestureDetector(
                onTap: () => context.pop(),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.85),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.06),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.arrow_back, size: 20),
                ),
              ),
            ),
            title: Text(
              'Trip Highlights',
              style: TulipTextStyles.heading3.copyWith(fontSize: 18),
            ),
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.pin,
              background: _buildExpandedHeader(title, totalItems),
            ),
          ),

          // Vine connector after header
          SliverToBoxAdapter(
            child: _VineConnector(height: 32),
          ),

          // Stats section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: StatsSection(stats: highlights.stats),
            ),
          ),

          // Vine connector between stats and carousel/rated
          if (unratedItems.isNotEmpty || ratedItems.isNotEmpty)
            SliverToBoxAdapter(
              child: _VineConnector(height: 28),
            ),

          // Unrated items carousel
          if (unratedItems.isNotEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: UnratedCarousel(
                  items: unratedItems,
                  currentUserId: highlights.currentUserId,
                  onRate: (itemId, rating) async {
                    await rateHighlightItem(ref, stayId, itemId, rating);
                  },
                ),
              ),
            ),

          // Vine connector between carousel and rated
          if (unratedItems.isNotEmpty && ratedItems.isNotEmpty)
            SliverToBoxAdapter(
              child: _VineConnector(height: 28),
            ),

          // Rated items section
          if (ratedItems.isNotEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: RatedSection(
                  items: ratedItems,
                  currentUserId: highlights.currentUserId,
                  onRate: (itemId, rating) async {
                    await rateHighlightItem(ref, stayId, itemId, rating);
                  },
                ),
              ),
            ),

          // Bottom padding
          const SliverToBoxAdapter(
            child: SizedBox(height: 48),
          ),
        ],
      ),
    );
  }

  Widget _buildExpandedHeader(String title, int totalItems) {
    return Container(
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
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 56, 20, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              SlideUp(
                duration: const Duration(milliseconds: 500),
                offset: 20,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TulipTextStyles.heading1.copyWith(
                        fontSize: 28,
                        height: 1.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
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
                            '$totalItems completed ${totalItems == 1 ? 'item' : 'items'}',
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
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return SafeArea(
      child: Center(
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                child: const Text('Go Back'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Floating botanical decorations in the background
class _BackgroundBotanicals extends StatelessWidget {
  const _BackgroundBotanicals();

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return IgnorePointer(
      child: Stack(
        children: [
          // Top-right watercolor blob
          Positioned(
            top: screenHeight * 0.15,
            right: -30,
            child: _WatercolorBlob(
              size: 120,
              color: TulipColors.rose.withValues(alpha: 0.06),
            ),
          ),
          // Mid-left botanical
          Positioned(
            top: screenHeight * 0.35,
            left: -15,
            child: Transform.rotate(
              angle: -0.4,
              child: Icon(
                Icons.eco,
                size: 60,
                color: TulipColors.sage.withValues(alpha: 0.06),
              ),
            ),
          ),
          // Mid-right watercolor blob
          Positioned(
            top: screenHeight * 0.55,
            right: -20,
            child: _WatercolorBlob(
              size: 90,
              color: TulipColors.lavender.withValues(alpha: 0.05),
            ),
          ),
          // Bottom-left botanical
          Positioned(
            top: screenHeight * 0.75,
            left: screenWidth * 0.1,
            child: Transform.rotate(
              angle: 0.6,
              child: Icon(
                Icons.eco,
                size: 40,
                color: TulipColors.sage.withValues(alpha: 0.05),
              ),
            ),
          ),
          // Bottom-right accent
          Positioned(
            top: screenHeight * 0.85,
            right: screenWidth * 0.05,
            child: _WatercolorBlob(
              size: 70,
              color: TulipColors.coral.withValues(alpha: 0.04),
            ),
          ),
        ],
      ),
    );
  }
}

/// Soft watercolor-style blob decoration
class _WatercolorBlob extends StatelessWidget {
  final double size;
  final Color color;

  const _WatercolorBlob({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            color,
            color.withValues(alpha: 0),
          ],
          stops: const [0.0, 1.0],
        ),
      ),
    );
  }
}

/// Subtle vine/stem connecting element between sections
class _VineConnector extends StatelessWidget {
  final double height;

  const _VineConnector({this.height = 28});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Center(
        child: CustomPaint(
          size: Size(2, height),
          painter: _VinePainter(),
        ),
      ),
    );
  }
}

class _VinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    // Faded gradient vine stroke
    final gradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        TulipColors.sage.withValues(alpha: 0.0),
        TulipColors.sage.withValues(alpha: 0.2),
        TulipColors.sage.withValues(alpha: 0.0),
      ],
    );

    paint.shader = gradient.createShader(
      Rect.fromLTWH(0, 0, size.width, size.height),
    );

    // Slight sinusoidal curve for organic feel
    final path = Path();
    path.moveTo(size.width / 2, 0);
    path.quadraticBezierTo(
      size.width / 2 + 4,
      size.height * 0.35,
      size.width / 2,
      size.height * 0.5,
    );
    path.quadraticBezierTo(
      size.width / 2 - 4,
      size.height * 0.65,
      size.width / 2,
      size.height,
    );

    canvas.drawPath(path, paint);

    // Tiny leaf at the midpoint
    final leafPaint = Paint()
      ..color = TulipColors.sage.withValues(alpha: 0.15)
      ..style = PaintingStyle.fill;

    final leafPath = Path();
    final midY = size.height * 0.5;
    final midX = size.width / 2;
    leafPath.moveTo(midX, midY - 3);
    leafPath.quadraticBezierTo(midX + 5, midY, midX, midY + 3);
    leafPath.quadraticBezierTo(midX - 5, midY, midX, midY - 3);
    canvas.drawPath(leafPath, leafPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
