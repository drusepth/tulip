import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
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
        // Hero card for trip average
        if (stats.tripAverage != null)
          SlideUp(
            duration: const Duration(milliseconds: 500),
            offset: 24,
            child: _TripAverageHeroCard(
              rating: stats.tripAverage!,
              totalRatings: totalRatings,
            ),
          ),

        // Botanical divider
        if (stats.tripAverage != null && individualStats.isNotEmpty) ...[
          const SizedBox(height: 24),
          SlideUp(
            duration: const Duration(milliseconds: 300),
            delay: const Duration(milliseconds: 200),
            offset: 15,
            child: const _BotanicalDivider(),
          ),
          const SizedBox(height: 20),
        ],

        // Individual ratings
        if (individualStats.isNotEmpty)
          _buildIndividualRatingsGrid(individualStats),
      ],
    );
  }

  Widget _buildIndividualRatingsGrid(List<_IndividualStatData> individuals) {
    const accentColors = [
      TulipColors.sage,
      TulipColors.lavender,
      TulipColors.rose,
      TulipColors.taupe,
    ];

    final cards = <Widget>[];
    for (int i = 0; i < individuals.length; i++) {
      final stat = individuals[i];
      final delay = Duration(milliseconds: 150 + (100 * i));
      final accentColor = accentColors[i % accentColors.length];

      cards.add(
        SlideUp(
          duration: const Duration(milliseconds: 400),
          delay: delay,
          offset: 20,
          child: _IndividualRatingCard(
            name: stat.name,
            rating: stat.average,
            ratingCount: stat.count,
            accentColor: accentColor,
            isCurrentUser: stat.isCurrentUser,
            avatarUrl: stat.avatarUrl,
          ),
        ),
      );
    }

    if (cards.length == 1) {
      return Center(
        child: FractionallySizedBox(
          widthFactor: 0.55,
          child: cards[0],
        ),
      );
    }

    if (cards.length == 2) {
      return Row(
        children: [
          Expanded(child: cards[0]),
          const SizedBox(width: 12),
          Expanded(child: cards[1]),
        ],
      );
    }

    if (cards.length == 3) {
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

/// Hero card with shimmer glow effect on initial load
class _TripAverageHeroCard extends StatefulWidget {
  final double rating;
  final int totalRatings;

  const _TripAverageHeroCard({
    required this.rating,
    required this.totalRatings,
  });

  @override
  State<_TripAverageHeroCard> createState() => _TripAverageHeroCardState();
}

class _TripAverageHeroCardState extends State<_TripAverageHeroCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _shimmerController;
  bool _showShimmer = true;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    // Play shimmer once then stop
    _shimmerController.forward().then((_) {
      if (mounted) {
        setState(() => _showShimmer = false);
      }
    });
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          stops: [0.0, 0.4, 0.7, 1.0],
          colors: [
            Color(0xFFF9E4D8),
            Color(0xFFF2D5C4),
            Color(0xFFEDD0C8),
            Color(0xFFE8CCBD),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFE8B4A0).withValues(alpha: 0.35),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
          BoxShadow(
            color: const Color(0xFFD4A594).withValues(alpha: 0.15),
            blurRadius: 48,
            offset: const Offset(0, 24),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Stack(
          children: [
            // Radial highlight
            Positioned(
              top: -40,
              right: -20,
              child: Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      Colors.white.withValues(alpha: 0.25),
                      Colors.white.withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),
            ),

            // Decorative leaf shapes
            Positioned(
              top: 16,
              left: 16,
              child: _LeafIcon(
                size: 20,
                color: Colors.white.withValues(alpha: 0.4),
                rotation: -0.3,
              ),
            ),
            Positioned(
              top: 12,
              right: 20,
              child: _LeafIcon(
                size: 16,
                color: Colors.white.withValues(alpha: 0.3),
                rotation: 0.5,
              ),
            ),
            Positioned(
              bottom: 16,
              left: 28,
              child: _LeafIcon(
                size: 14,
                color: Colors.white.withValues(alpha: 0.25),
                rotation: -0.8,
              ),
            ),
            Positioned(
              bottom: 20,
              right: 16,
              child: _LeafIcon(
                size: 18,
                color: Colors.white.withValues(alpha: 0.3),
                rotation: 0.2,
              ),
            ),

            // Glass inner panel
            Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.5),
                    width: 1,
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      'OUR TRIP TOGETHER',
                      style: TulipTextStyles.caption.copyWith(
                        color: TulipColors.coralDark,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 2.0,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildStarRatingDisplay(),
                    const SizedBox(height: 16),
                    Text(
                      widget.totalRatings == 1
                          ? 'from 1 shared moment'
                          : 'from ${widget.totalRatings} shared moments',
                      style: TulipTextStyles.bodySmall.copyWith(
                        color: TulipColors.brownLight,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Shimmer overlay on first load
            if (_showShimmer)
              Positioned.fill(
                child: AnimatedBuilder(
                  animation: _shimmerController,
                  builder: (context, child) {
                    return ShaderMask(
                      shaderCallback: (bounds) {
                        final progress = _shimmerController.value;
                        return LinearGradient(
                          begin: Alignment(-1.0 + 3.0 * progress, -0.3),
                          end: Alignment(-0.5 + 3.0 * progress, 0.3),
                          colors: [
                            Colors.white.withValues(alpha: 0.0),
                            Colors.white.withValues(alpha: 0.15),
                            Colors.white.withValues(alpha: 0.0),
                          ],
                          stops: const [0.0, 0.5, 1.0],
                        ).createShader(bounds);
                      },
                      blendMode: BlendMode.srcATop,
                      child: Container(
                        color: Colors.white.withValues(alpha: 0.3),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStarRatingDisplay() {
    final fullStars = widget.rating.floor();
    final hasHalfStar = (widget.rating - fullStars) >= 0.3;
    final emptyStars = 5 - fullStars - (hasHalfStar ? 1 : 0);

    return Column(
      children: [
        Text(
          widget.rating.toStringAsFixed(1),
          style: TulipTextStyles.heading1.copyWith(
            fontSize: 52,
            fontWeight: FontWeight.w700,
            color: TulipColors.coralDark,
            height: 1,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (int i = 0; i < fullStars; i++)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: Icon(
                  Icons.star_rounded,
                  size: 22,
                  color: TulipColors.coral,
                ),
              ),
            if (hasHalfStar)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: Icon(
                  Icons.star_half_rounded,
                  size: 22,
                  color: TulipColors.coral,
                ),
              ),
            for (int i = 0; i < emptyStars; i++)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: Icon(
                  Icons.star_outline_rounded,
                  size: 22,
                  color: TulipColors.coral.withValues(alpha: 0.4),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _LeafIcon extends StatelessWidget {
  final double size;
  final Color color;
  final double rotation;

  const _LeafIcon({
    required this.size,
    required this.color,
    this.rotation = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: rotation,
      child: Icon(Icons.eco_outlined, size: size, color: color),
    );
  }
}

class _BotanicalDivider extends StatelessWidget {
  const _BotanicalDivider();

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
                  TulipColors.sage.withValues(alpha: 0.4),
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Transform.rotate(
                angle: -0.3,
                child: Icon(
                  Icons.eco,
                  size: 14,
                  color: TulipColors.sage.withValues(alpha: 0.5),
                ),
              ),
              const SizedBox(width: 6),
              Text(
                'Individual Reflections',
                style: TulipTextStyles.caption.copyWith(
                  fontStyle: FontStyle.italic,
                  color: TulipColors.brownLighter,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(width: 6),
              Transform.rotate(
                angle: 0.3,
                child: Icon(
                  Icons.eco,
                  size: 14,
                  color: TulipColors.sage.withValues(alpha: 0.5),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  TulipColors.sage.withValues(alpha: 0.4),
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

class _IndividualRatingCard extends StatelessWidget {
  final String name;
  final double rating;
  final int ratingCount;
  final Color accentColor;
  final bool isCurrentUser;
  final String? avatarUrl;

  const _IndividualRatingCard({
    required this.name,
    required this.rating,
    required this.ratingCount,
    required this.accentColor,
    required this.isCurrentUser,
    this.avatarUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: accentColor.withValues(alpha: 0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: accentColor.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildAvatar(),
          const SizedBox(height: 10),
          Text(
            name,
            style: TulipTextStyles.label.copyWith(
              fontWeight: FontWeight.w600,
              color: TulipColors.brown,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            rating.toStringAsFixed(1),
            style: TulipTextStyles.heading2.copyWith(
              color: TulipColors.coral,
              fontWeight: FontWeight.w700,
              fontSize: 26,
            ),
          ),
          const SizedBox(height: 6),
          _buildStarBar(),
          const SizedBox(height: 8),
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

  Widget _buildStarBar() {
    final fullStars = rating.floor();
    final fraction = rating - fullStars;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        Color starColor;
        IconData icon;
        if (index < fullStars) {
          starColor = TulipColors.coral;
          icon = Icons.star_rounded;
        } else if (index == fullStars && fraction >= 0.3) {
          starColor = TulipColors.coral;
          icon = Icons.star_half_rounded;
        } else {
          starColor = TulipColors.coral.withValues(alpha: 0.25);
          icon = Icons.star_outline_rounded;
        }
        return Icon(icon, size: 16, color: starColor);
      }),
    );
  }

  Widget _buildAvatar() {
    if (avatarUrl != null) {
      return Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: accentColor.withValues(alpha: 0.4),
            width: 2,
          ),
        ),
        child: CircleAvatar(
          radius: 20,
          backgroundImage: NetworkImage(avatarUrl!),
          backgroundColor: TulipColors.taupeLight,
        ),
      );
    }

    final avatarGradient = isCurrentUser
        ? [TulipColors.sage, TulipColors.sageDark]
        : [TulipColors.lavender, TulipColors.lavenderDark];

    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: accentColor.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: avatarGradient,
          ),
        ),
        child: Center(
          child: isCurrentUser
              ? const Icon(Icons.person, size: 20, color: Colors.white)
              : Text(
                  name.isNotEmpty ? name[0].toUpperCase() : '?',
                  style: TulipTextStyles.label.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
        ),
      ),
    );
  }
}
