import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../shared/constants/tulip_colors.dart';
import '../../../../shared/constants/tulip_text_styles.dart';
import '../../../bucket_list/presentation/widgets/rating_stars.dart';
import '../../data/models/highlights_model.dart';

/// Carousel widget displaying unrated highlight items with hero cards
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

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToPage(int page) {
    _pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty) return const SizedBox.shrink();

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            TulipColors.coral.withValues(alpha: 0.15),
            TulipColors.lavender.withValues(alpha: 0.15),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Stack(
        children: [
          // Decorative sparkle icons
          _buildDecorativeIcons(),
          // Main content
          Padding(
            padding: const EdgeInsets.all(20),
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
          ),
        ],
      ),
    );
  }

  Widget _buildDecorativeIcons() {
    return Positioned.fill(
      child: IgnorePointer(
        child: Stack(
          children: [
            Positioned(
              top: 16,
              right: 16,
              child: Icon(
                Icons.auto_awesome,
                size: 20,
                color: TulipColors.coral.withValues(alpha: 0.3),
              ),
            ),
            Positioned(
              bottom: 40,
              left: 16,
              child: Icon(
                Icons.star_outline,
                size: 16,
                color: TulipColors.lavender.withValues(alpha: 0.4),
              ),
            ),
            Positioned(
              top: 60,
              left: 30,
              child: Icon(
                Icons.auto_awesome,
                size: 14,
                color: TulipColors.coral.withValues(alpha: 0.2),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final itemCount = widget.items.length;
    final memoryText = itemCount == 1 ? 'memory' : 'memories';

    return Row(
      children: [
        Icon(
          Icons.star_border,
          size: 24,
          color: TulipColors.coral,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Rate Your Experiences',
                style: TulipTextStyles.label.copyWith(
                  fontWeight: FontWeight.w600,
                  color: TulipColors.brown,
                ),
              ),
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
    );
  }

  Widget _buildCarouselCards() {
    return SizedBox(
      height: 340,
      child: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: widget.items.length,
            onPageChanged: (page) {
              setState(() => _currentPage = page);
            },
            itemBuilder: (context, index) {
              return _buildHeroCard(widget.items[index]);
            },
          ),
          // Navigation arrows
          if (widget.items.length > 1) ...[
            // Previous button
            if (_currentPage > 0)
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                child: Center(
                  child: _buildNavButton(
                    icon: Icons.chevron_left,
                    onTap: () => _goToPage(_currentPage - 1),
                  ),
                ),
              ),
            // Next button
            if (_currentPage < widget.items.length - 1)
              Positioned(
                right: 0,
                top: 0,
                bottom: 0,
                child: Center(
                  child: _buildNavButton(
                    icon: Icons.chevron_right,
                    onTap: () => _goToPage(_currentPage + 1),
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildNavButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          icon,
          size: 24,
          color: TulipColors.brown,
        ),
      ),
    );
  }

  Widget _buildHeroCard(HighlightItem item) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Hero image or gradient placeholder
            _buildHeroImage(item),
            // Card content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      item.title,
                      style: TulipTextStyles.heading3.copyWith(
                        fontSize: 18,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    // Address
                    if (item.address != null && item.address!.isNotEmpty)
                      Row(
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            size: 14,
                            color: TulipColors.brownLighter,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              item.address!,
                              style: TulipTextStyles.caption,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    // Completion date
                    if (item.completedAt != null) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today_outlined,
                            size: 14,
                            color: TulipColors.brownLighter,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            DateFormat('MMM d, y').format(item.completedAt!),
                            style: TulipTextStyles.caption,
                          ),
                        ],
                      ),
                    ],
                    const Spacer(),
                    // Divider
                    const Divider(height: 1),
                    const SizedBox(height: 12),
                    // Rating prompt
                    Center(
                      child: Column(
                        children: [
                          Text(
                            'How was it?',
                            style: TulipTextStyles.bodySmall.copyWith(
                              color: TulipColors.brownLight,
                            ),
                          ),
                          const SizedBox(height: 8),
                          RatingStars(
                            rating: 0,
                            size: 36,
                            onRatingChanged: (rating) {
                              _showRatingDialog(context, item, rating);
                            },
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Click to rate',
                            style: TulipTextStyles.caption.copyWith(
                              color: TulipColors.coral,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
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

  Widget _buildHeroImage(HighlightItem item) {
    // Gradient placeholder with location icon
    return Container(
      height: 100,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            TulipColors.coral.withValues(alpha: 0.3),
            TulipColors.lavender.withValues(alpha: 0.3),
          ],
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Stack(
        children: [
          Center(
            child: Icon(
              Icons.place_outlined,
              size: 40,
              color: Colors.white.withValues(alpha: 0.7),
            ),
          ),
          // Category badge
          Positioned(
            top: 12,
            right: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _formatCategory(item.category),
                style: TulipTextStyles.caption.copyWith(
                  color: TulipColors.brown,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIndicators() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Dot indicators
        Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(widget.items.length, (index) {
            final isActive = index == _currentPage;
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: isActive ? 8 : 6,
              height: isActive ? 8 : 6,
              decoration: BoxDecoration(
                color: isActive ? TulipColors.coral : TulipColors.taupeLight,
                shape: BoxShape.circle,
              ),
            );
          }),
        ),
        const SizedBox(width: 12),
        // Counter
        Text(
          '${_currentPage + 1} of ${widget.items.length}',
          style: TulipTextStyles.caption.copyWith(
            color: TulipColors.brownLight,
          ),
        ),
      ],
    );
  }

  void _showRatingDialog(BuildContext context, HighlightItem item, int initialRating) async {
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
