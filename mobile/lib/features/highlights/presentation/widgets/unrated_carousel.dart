import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../../../shared/constants/tulip_colors.dart';
import '../../../../shared/constants/tulip_text_styles.dart';
import '../../../../shared/widgets/animated_widgets.dart';
import '../../../bucket_list/presentation/widgets/rating_stars.dart';
import '../../data/models/highlights_model.dart';

/// Carousel widget displaying unrated highlight items with rich hero cards,
/// watercolor texture overlays, and engaging rating interactions
class UnratedCarousel extends StatefulWidget {
  final List<HighlightItem> items;
  final int currentUserId;
  final void Function(int itemId, int rating) onRate;

  const UnratedCarousel({
    super.key,
    required this.items,
    required this.currentUserId,
    required this.onRate,
  });

  @override
  State<UnratedCarousel> createState() => _UnratedCarouselState();
}

class _UnratedCarouselState extends State<UnratedCarousel> {
  late PageController _pageController;
  int _currentPage = 0;

  static const _categoryGradients = <String, List<Color>>{
    'food': [Color(0xFFE8C4A0), Color(0xFFD4A080)],
    'restaurant': [Color(0xFFE8C4A0), Color(0xFFD4A080)],
    'cafe': [Color(0xFFD4BCA8), Color(0xFFC0A890)],
    'attraction': [Color(0xFFC8BFD4), Color(0xFFB0A4C0)],
    'nature': [Color(0xFFB8C9B8), Color(0xFF9CB09C)],
    'shopping': [Color(0xFFD4A5A5), Color(0xFFC09090)],
    'nightlife': [Color(0xFFB0A4C8), Color(0xFF9888B4)],
  };

  static const _defaultGradient = [Color(0xFFCDB8A8), Color(0xFFB8A090)];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.92);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  List<Color> _gradientForCategory(String category) {
    final key = category.toLowerCase().replaceAll('_', '');
    for (final entry in _categoryGradients.entries) {
      if (key.contains(entry.key)) return entry.value;
    }
    return _defaultGradient;
  }

  IconData _iconForCategory(String category) {
    final key = category.toLowerCase();
    if (key.contains('food') || key.contains('restaurant')) {
      return Icons.restaurant;
    }
    if (key.contains('cafe') || key.contains('coffee')) return Icons.local_cafe;
    if (key.contains('nature') || key.contains('hik')) return Icons.park;
    if (key.contains('attract')) return Icons.attractions;
    if (key.contains('shop')) return Icons.shopping_bag_outlined;
    if (key.contains('night') || key.contains('bar')) return Icons.nightlife;
    if (key.contains('museum') || key.contains('art')) return Icons.museum;
    if (key.contains('beach')) return Icons.beach_access;
    return Icons.place_outlined;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty) return const SizedBox.shrink();

    return SlideUp(
      duration: const Duration(milliseconds: 500),
      delay: const Duration(milliseconds: 300),
      offset: 24,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 16),
          _buildCarouselCards(),
          if (widget.items.length > 1) ...[
            const SizedBox(height: 16),
            _buildIndicators(),
          ],
        ],
      ),
    );
  }

  Widget _buildHeader() {
    final itemCount = widget.items.length;
    final memoryText = itemCount == 1 ? 'memory' : 'memories';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: TulipColors.coral.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.auto_awesome,
              size: 20,
              color: TulipColors.coral,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Rate Your Experiences',
                  style: TulipTextStyles.label.copyWith(
                    fontWeight: FontWeight.w700,
                    color: TulipColors.brown,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$itemCount $memoryText waiting',
                  style: TulipTextStyles.caption.copyWith(
                    color: TulipColors.brownLight,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCarouselCards() {
    return SizedBox(
      height: 370,
      child: PageView.builder(
        controller: _pageController,
        itemCount: widget.items.length,
        onPageChanged: (page) {
          HapticFeedback.selectionClick();
          setState(() => _currentPage = page);
        },
        itemBuilder: (context, index) {
          return AnimatedBuilder(
            animation: _pageController,
            builder: (context, child) {
              double scale = 1.0;
              if (_pageController.position.haveDimensions) {
                final page =
                    _pageController.page ?? _currentPage.toDouble();
                scale =
                    (1 - (page - index).abs() * 0.06).clamp(0.94, 1.0);
              }
              return Transform.scale(
                scale: scale,
                child: child,
              );
            },
            child: _buildHeroCard(widget.items[index]),
          );
        },
      ),
    );
  }

  Widget _buildHeroCard(HighlightItem item) {
    final gradientColors = _gradientForCategory(item.category);
    final categoryIcon = _iconForCategory(item.category);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: gradientColors[0].withValues(alpha: 0.25),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeroImage(item, gradientColors, categoryIcon),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        style: TulipTextStyles.heading3.copyWith(
                          fontSize: 19,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      _buildMetadataRow(item),
                      const Spacer(),
                      _buildRatingSection(item),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeroImage(
    HighlightItem item,
    List<Color> gradientColors,
    IconData categoryIcon,
  ) {
    return Container(
      height: 130,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            gradientColors[0],
            gradientColors[1],
            gradientColors[0].withValues(alpha: 0.8),
          ],
        ),
      ),
      child: Stack(
        children: [
          // Watercolor texture overlay
          Positioned.fill(
            child: CustomPaint(
              painter: _WatercolorTexturePainter(
                baseColor: Colors.white,
                seed: item.title.hashCode,
              ),
            ),
          ),
          // Soft radial glow circles
          Positioned(
            top: -30,
            right: -15,
            child: Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Colors.white.withValues(alpha: 0.15),
                    Colors.white.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -35,
            left: -25,
            child: Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Colors.white.withValues(alpha: 0.1),
                    Colors.white.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),
          // Center icon with double ring
          Center(
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
              child: Icon(
                categoryIcon,
                size: 32,
                color: Colors.white.withValues(alpha: 0.9),
              ),
            ),
          ),
          // Category badge
          Positioned(
            top: 12,
            right: 12,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.92),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                _formatCategory(item.category),
                style: TulipTextStyles.caption.copyWith(
                  color: TulipColors.brown,
                  fontWeight: FontWeight.w600,
                  fontSize: 11,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetadataRow(HighlightItem item) {
    return Row(
      children: [
        if (item.completedAt != null) ...[
          Icon(
            Icons.calendar_today_outlined,
            size: 13,
            color: TulipColors.brownLighter,
          ),
          const SizedBox(width: 4),
          Text(
            DateFormat('MMM d, y').format(item.completedAt!),
            style: TulipTextStyles.caption.copyWith(fontSize: 12),
          ),
        ],
        if (item.address != null &&
            item.address!.isNotEmpty &&
            item.completedAt != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Container(
              width: 3,
              height: 3,
              decoration: const BoxDecoration(
                color: TulipColors.brownLighter,
                shape: BoxShape.circle,
              ),
            ),
          ),
        if (item.address != null && item.address!.isNotEmpty) ...[
          Icon(
            Icons.location_on_outlined,
            size: 13,
            color: TulipColors.brownLighter,
          ),
          const SizedBox(width: 3),
          Expanded(
            child: Text(
              item.address!,
              style: TulipTextStyles.caption.copyWith(fontSize: 12),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildRatingSection(HighlightItem item) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            TulipColors.cream,
            TulipColors.roseLight.withValues(alpha: 0.3),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: TulipColors.taupeLight,
        ),
      ),
      child: Column(
        children: [
          Text(
            'Share your memory',
            style: TulipTextStyles.bodySmall.copyWith(
              color: TulipColors.brownLight,
              fontWeight: FontWeight.w500,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 10),
          // Rating stars with scale-on-tap per star
          _InteractiveRatingStars(
            onRate: (rating) {
              HapticFeedback.lightImpact();
              _showRatingDialog(context, item, rating);
            },
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              PulsingDot(color: TulipColors.coral, size: 5),
              const SizedBox(width: 6),
              Text(
                'Tap a star to rate',
                style: TulipTextStyles.caption.copyWith(
                  color: TulipColors.brownLighter,
                  fontSize: 11,
                ),
              ),
              const SizedBox(width: 6),
              PulsingDot(color: TulipColors.coral, size: 5),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIndicators() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(widget.items.length, (index) {
            final isActive = index == _currentPage;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: isActive ? 24 : 8,
              height: 6,
              decoration: BoxDecoration(
                color: isActive
                    ? TulipColors.coral
                    : TulipColors.taupe.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(3),
              ),
            );
          }),
        ),
        const SizedBox(width: 14),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: TulipColors.taupe.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            '${_currentPage + 1}/${widget.items.length}',
            style: TulipTextStyles.caption.copyWith(
              color: TulipColors.brownLight,
              fontWeight: FontWeight.w600,
              fontSize: 11,
            ),
          ),
        ),
      ],
    );
  }

  void _showRatingDialog(
      BuildContext context, HighlightItem item, int initialRating) async {
    final rating = await showRatingDialog(
      context,
      title: 'Rate "${item.title}"',
      initialRating: initialRating,
    );

    if (rating != null) {
      widget.onRate(item.id, rating);
    }
  }

  String _formatCategory(String category) {
    if (category.isEmpty) return 'Other';
    return category
        .replaceAll('_', ' ')
        .split(' ')
        .map((word) =>
            word.isNotEmpty ? '${word[0].toUpperCase()}${word.substring(1)}' : '')
        .join(' ');
  }
}

/// Interactive rating stars with individual scale animations per star
class _InteractiveRatingStars extends StatefulWidget {
  final void Function(int rating) onRate;

  const _InteractiveRatingStars({required this.onRate});

  @override
  State<_InteractiveRatingStars> createState() =>
      _InteractiveRatingStarsState();
}

class _InteractiveRatingStarsState extends State<_InteractiveRatingStars> {
  int _hoveredStar = 0;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        final starValue = index + 1;
        final isHighlighted = starValue <= _hoveredStar;

        return GestureDetector(
          onTapDown: (_) => setState(() => _hoveredStar = starValue),
          onTapUp: (_) {
            widget.onRate(starValue);
            setState(() => _hoveredStar = 0);
          },
          onTapCancel: () => setState(() => _hoveredStar = 0),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: AnimatedScale(
              scale: isHighlighted ? 1.2 : 1.0,
              duration: const Duration(milliseconds: 150),
              curve: Curves.easeOutBack,
              child: Icon(
                isHighlighted ? Icons.star_rounded : Icons.star_outline_rounded,
                size: 34,
                color: isHighlighted
                    ? TulipColors.coral
                    : TulipColors.brownLighter,
              ),
            ),
          ),
        );
      }),
    );
  }
}

/// Paints soft watercolor-style texture splotches on carousel hero images
class _WatercolorTexturePainter extends CustomPainter {
  final Color baseColor;
  final int seed;

  _WatercolorTexturePainter({required this.baseColor, required this.seed});

  @override
  void paint(Canvas canvas, Size size) {
    final rng = math.Random(seed);

    // Paint 3-5 soft splotches
    final count = 3 + rng.nextInt(3);
    for (int i = 0; i < count; i++) {
      final x = rng.nextDouble() * size.width;
      final y = rng.nextDouble() * size.height;
      final radius = 20.0 + rng.nextDouble() * 40;
      final alpha = 0.04 + rng.nextDouble() * 0.06;

      final paint = Paint()
        ..shader = RadialGradient(
          colors: [
            baseColor.withValues(alpha: alpha),
            baseColor.withValues(alpha: 0),
          ],
        ).createShader(
          Rect.fromCircle(center: Offset(x, y), radius: radius),
        );

      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _WatercolorTexturePainter oldDelegate) =>
      oldDelegate.seed != seed;
}
