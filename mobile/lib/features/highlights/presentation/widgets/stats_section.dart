import 'package:flutter/material.dart';
import '../../../../shared/constants/tulip_colors.dart';
import '../../../../shared/constants/tulip_text_styles.dart';
import '../../../../shared/widgets/animated_widgets.dart';
import '../../data/models/highlights_model.dart';

/// Displays rating statistics with a hero Trip Average card and individual ratings
class StatsSection extends StatelessWidget {
  final HighlightsStats stats;

  const StatsSection({
    super.key,
    required this.stats,
  });

  @override
  Widget build(BuildContext context) {
    final hasStats = stats.tripAverage != null ||
        stats.userStats != null ||
        stats.collaboratorStats.isNotEmpty;

    if (!hasStats) {
      return const SizedBox.shrink();
    }

    // Count total ratings for the hero card subtitle
    int totalRatings = 0;
    if (stats.userStats != null) {
      totalRatings += stats.userStats!.count;
    }
    for (final collab in stats.collaboratorStats) {
      if (collab.stats != null) {
        totalRatings += collab.stats!.count;
      }
    }

    // Build list of individual stats (user + collaborators)
    final individualStats = <_IndividualStatData>[];
    if (stats.userStats != null) {
      individualStats.add(_IndividualStatData(
        name: 'You',
        average: stats.userStats!.average,
        count: stats.userStats!.count,
        isCurrentUser: true,
      ));
    }
    for (final collab in stats.collaboratorStats) {
      if (collab.stats != null) {
        individualStats.add(_IndividualStatData(
          name: collab.user.name,
          average: collab.stats!.average,
          count: collab.stats!.count,
          isCurrentUser: false,
          avatarUrl: collab.user.avatarUrl,
        ));
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Rating Overview', style: TulipTextStyles.label),
        const SizedBox(height: 12),

        // Hero card for trip average
        if (stats.tripAverage != null)
          SlideUp(
            duration: const Duration(milliseconds: 400),
            offset: 20,
            child: _TripAverageHeroCard(
              rating: stats.tripAverage!,
              totalRatings: totalRatings,
            ),
          ),

        // Divider with label (if we have both hero and individual stats)
        if (stats.tripAverage != null && individualStats.isNotEmpty) ...[
          const SizedBox(height: 20),
          SlideUp(
            duration: const Duration(milliseconds: 300),
            delay: const Duration(milliseconds: 200),
            offset: 15,
            child: const _DividerWithLabel(),
          ),
          const SizedBox(height: 16),
        ],

        // Individual ratings grid
        if (individualStats.isNotEmpty)
          _buildIndividualRatingsGrid(individualStats),
      ],
    );
  }

  Widget _buildIndividualRatingsGrid(List<_IndividualStatData> individuals) {
    // Border colors to cycle through for variety
    const borderColors = [
      TulipColors.sage,
      TulipColors.lavender,
      TulipColors.rose,
      TulipColors.taupe,
    ];

    final cards = <Widget>[];
    for (int i = 0; i < individuals.length; i++) {
      final stat = individuals[i];
      final delay = Duration(milliseconds: 100 + (75 * i));
      final borderColor = borderColors[i % borderColors.length];

      cards.add(
        SlideUp(
          duration: const Duration(milliseconds: 300),
          delay: delay,
          offset: 15,
          child: _IndividualRatingCard(
            name: stat.name,
            rating: stat.average,
            ratingCount: stat.count,
            borderColor: borderColor,
            isCurrentUser: stat.isCurrentUser,
            avatarUrl: stat.avatarUrl,
          ),
        ),
      );
    }

    // Layout logic based on count
    if (cards.length == 1) {
      // Single card - centered with constrained width
      return Center(
        child: FractionallySizedBox(
          widthFactor: 0.6,
          child: cards[0],
        ),
      );
    }

    if (cards.length == 2) {
      // Two cards side by side
      return Row(
        children: [
          Expanded(child: cards[0]),
          const SizedBox(width: 12),
          Expanded(child: cards[1]),
        ],
      );
    }

    if (cards.length == 3) {
      // First row: 2 cards, second row: 1 centered
      return Column(
        children: [
          Row(
            children: [
              Expanded(child: cards[0]),
              const SizedBox(width: 12),
              Expanded(child: cards[1]),
            ],
          ),
          const SizedBox(height: 12),
          Center(
            child: FractionallySizedBox(
              widthFactor: 0.5,
              child: cards[2],
            ),
          ),
        ],
      );
    }

    // 4+ cards: rows of 2
    final rows = <Widget>[];
    for (int i = 0; i < cards.length; i += 2) {
      if (i + 1 < cards.length) {
        rows.add(
          Row(
            children: [
              Expanded(child: cards[i]),
              const SizedBox(width: 12),
              Expanded(child: cards[i + 1]),
            ],
          ),
        );
      } else {
        // Odd card at end - center it
        rows.add(
          Center(
            child: FractionallySizedBox(
              widthFactor: 0.5,
              child: cards[i],
            ),
          ),
        );
      }
      if (i + 2 < cards.length) {
        rows.add(const SizedBox(height: 12));
      }
    }

    return Column(children: rows);
  }
}

/// Data class for individual stats
class _IndividualStatData {
  final String name;
  final double average;
  final int count;
  final bool isCurrentUser;
  final String? avatarUrl;

  _IndividualStatData({
    required this.name,
    required this.average,
    required this.count,
    required this.isCurrentUser,
    this.avatarUrl,
  });
}

/// Hero card for the trip average rating
class _TripAverageHeroCard extends StatelessWidget {
  final double rating;
  final int totalRatings;

  const _TripAverageHeroCard({
    required this.rating,
    required this.totalRatings,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFFFF5F0), // Warm cream
            Color(0xFFFDF0E8), // Soft peach
            Color(0xFFF8E8E0), // Warm blush
          ],
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: TulipColors.coral.withValues(alpha: 0.4),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: TulipColors.coral.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: TulipColors.coral.withValues(alpha: 0.1),
            blurRadius: 40,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Decorative sparkle icons in corners
          Positioned(
            top: 0,
            left: 0,
            child: Icon(
              Icons.auto_awesome,
              size: 16,
              color: TulipColors.coral.withValues(alpha: 0.25),
            ),
          ),
          Positioned(
            top: 0,
            right: 0,
            child: Icon(
              Icons.auto_awesome,
              size: 12,
              color: TulipColors.coral.withValues(alpha: 0.2),
            ),
          ),
          Positioned(
            bottom: 0,
            right: 8,
            child: Icon(
              Icons.auto_awesome,
              size: 14,
              color: TulipColors.coral.withValues(alpha: 0.15),
            ),
          ),

          // Main content
          Column(
            children: [
              // Label
              Text(
                'OUR TRIP TOGETHER',
                style: TulipTextStyles.caption.copyWith(
                  color: TulipColors.coralDark,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.5,
                  fontSize: 11,
                ),
              ),
              const SizedBox(height: 16),

              // Large rating display
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    rating.toStringAsFixed(1),
                    style: TulipTextStyles.heading1.copyWith(
                      fontSize: 48,
                      fontWeight: FontWeight.w600,
                      color: TulipColors.coral,
                      height: 1,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Icon(
                      Icons.star_rounded,
                      size: 32,
                      color: TulipColors.coral,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Subtitle
              Text(
                totalRatings == 1
                    ? 'from 1 shared moment'
                    : 'from $totalRatings shared moments',
                style: TulipTextStyles.bodySmall.copyWith(
                  color: TulipColors.brownLight,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Decorative divider with center label
class _DividerWithLabel extends StatelessWidget {
  const _DividerWithLabel();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  TulipColors.taupe.withValues(alpha: 0.5),
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Individual Reflections',
            style: TulipTextStyles.caption.copyWith(
              fontStyle: FontStyle.italic,
              color: TulipColors.brownLighter,
            ),
          ),
        ),
        Expanded(
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  TulipColors.taupe.withValues(alpha: 0.5),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Individual rating card for user or collaborator
class _IndividualRatingCard extends StatelessWidget {
  final String name;
  final double rating;
  final int ratingCount;
  final Color borderColor;
  final bool isCurrentUser;
  final String? avatarUrl;

  const _IndividualRatingCard({
    required this.name,
    required this.rating,
    required this.ratingCount,
    required this.borderColor,
    required this.isCurrentUser,
    this.avatarUrl,
  });

  @override
  Widget build(BuildContext context) {
    // Avatar gradient colors based on user type
    final avatarGradient = isCurrentUser
        ? [TulipColors.sage, TulipColors.sageDark]
        : [TulipColors.lavender, TulipColors.lavenderDark];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: borderColor.withValues(alpha: 0.5),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: borderColor.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Avatar and name row
          Row(
            children: [
              // Avatar
              _buildAvatar(avatarGradient),
              const SizedBox(width: 10),
              // Name
              Expanded(
                child: Text(
                  name,
                  style: TulipTextStyles.label.copyWith(
                    fontWeight: FontWeight.w500,
                    color: TulipColors.brown,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Rating display
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                rating.toStringAsFixed(1),
                style: TulipTextStyles.heading2.copyWith(
                  color: TulipColors.coral,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.star_rounded,
                size: 20,
                color: TulipColors.coral,
              ),
            ],
          ),
          const SizedBox(height: 4),

          // Rating count
          Text(
            ratingCount == 1 ? '1 rating' : '$ratingCount ratings',
            style: TulipTextStyles.caption.copyWith(
              color: TulipColors.brownLighter,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar(List<Color> gradient) {
    if (avatarUrl != null) {
      return CircleAvatar(
        radius: 16,
        backgroundImage: NetworkImage(avatarUrl!),
        backgroundColor: TulipColors.taupeLight,
      );
    }

    // Gradient avatar with icon or initial
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradient,
        ),
      ),
      child: Center(
        child: isCurrentUser
            ? const Icon(
                Icons.person,
                size: 18,
                color: Colors.white,
              )
            : Text(
                name.isNotEmpty ? name[0].toUpperCase() : '?',
                style: TulipTextStyles.label.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
      ),
    );
  }
}
