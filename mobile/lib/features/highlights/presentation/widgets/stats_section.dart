import 'package:flutter/material.dart';
import '../../../../shared/constants/tulip_colors.dart';
import '../../../../shared/constants/tulip_text_styles.dart';
import '../../../../shared/widgets/cozy_card.dart';
import '../../data/models/highlights_model.dart';

/// Displays rating statistics in a grid of cards
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Rating Overview', style: TulipTextStyles.label),
        const SizedBox(height: 12),
        _buildStatsGrid(),
      ],
    );
  }

  Widget _buildStatsGrid() {
    final cards = <Widget>[];

    // Trip average card
    if (stats.tripAverage != null) {
      cards.add(_StatCard(
        title: 'Trip Average',
        rating: stats.tripAverage!,
        icon: Icons.auto_awesome,
        iconColor: TulipColors.coral,
        subtitle: 'All ratings',
      ));
    }

    // User stats card
    if (stats.userStats != null) {
      cards.add(_StatCard(
        title: 'Your Average',
        rating: stats.userStats!.average,
        icon: Icons.person,
        iconColor: TulipColors.sage,
        subtitle: '${stats.userStats!.count} ratings',
      ));
    }

    // Collaborator stats cards
    for (final collab in stats.collaboratorStats) {
      if (collab.stats != null) {
        cards.add(_StatCard(
          title: collab.user.name,
          rating: collab.stats!.average,
          icon: Icons.person_outline,
          iconColor: TulipColors.lavender,
          subtitle: '${collab.stats!.count} ratings',
          avatarUrl: collab.user.avatarUrl,
        ));
      }
    }

    if (cards.isEmpty) {
      return const SizedBox.shrink();
    }

    // Display in a grid layout
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.5,
      children: cards,
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final double rating;
  final IconData icon;
  final Color iconColor;
  final String subtitle;
  final String? avatarUrl;

  const _StatCard({
    required this.title,
    required this.rating,
    required this.icon,
    required this.iconColor,
    required this.subtitle,
    this.avatarUrl,
  });

  @override
  Widget build(BuildContext context) {
    return CozyCard(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              if (avatarUrl != null)
                CircleAvatar(
                  radius: 12,
                  backgroundImage: NetworkImage(avatarUrl!),
                  backgroundColor: TulipColors.taupeLight,
                )
              else
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, size: 16, color: iconColor),
                ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TulipTextStyles.caption.copyWith(
                    fontWeight: FontWeight.w500,
                    color: TulipColors.brown,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const Spacer(),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                rating.toStringAsFixed(1),
                style: TulipTextStyles.heading2.copyWith(
                  color: TulipColors.coral,
                ),
              ),
              const SizedBox(width: 4),
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Icon(
                  Icons.star,
                  size: 18,
                  color: TulipColors.coral,
                ),
              ),
            ],
          ),
          Text(
            subtitle,
            style: TulipTextStyles.caption,
          ),
        ],
      ),
    );
  }
}
