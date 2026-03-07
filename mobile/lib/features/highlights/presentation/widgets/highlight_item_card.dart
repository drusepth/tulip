import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../shared/constants/tulip_colors.dart';
import '../../../../shared/constants/tulip_text_styles.dart';
import '../../../bucket_list/presentation/widgets/rating_stars.dart';
import '../../data/models/highlights_model.dart';

/// Card displaying a completed bucket list item with ratings
class HighlightItemCard extends StatelessWidget {
  final HighlightItem item;
  final int? currentUserId;
  final void Function(int itemId, int rating)? onRate;

  const HighlightItemCard({
    super.key,
    required this.item,
    this.currentUserId,
    this.onRate,
  });

  Color get _accentColor {
    if (item.averageRating == null) return TulipColors.taupe;
    if (item.averageRating! >= 4.5) return TulipColors.coral;
    if (item.averageRating! >= 3.5) return TulipColors.sage;
    if (item.averageRating! >= 2.5) return TulipColors.lavender;
    return TulipColors.taupe;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: TulipColors.taupeLight),
        boxShadow: [
          BoxShadow(
            color: _accentColor.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Colored accent bar
              Container(
                width: 4,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      _accentColor,
                      _accentColor.withValues(alpha: 0.4),
                    ],
                  ),
                ),
              ),
              // Content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title row with average rating
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.title,
                                  style: TulipTextStyles.label.copyWith(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 15,
                                  ),
                                ),
                                if (item.address != null &&
                                    item.address!.isNotEmpty) ...[
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.location_on_outlined,
                                        size: 13,
                                        color: TulipColors.brownLighter,
                                      ),
                                      const SizedBox(width: 3),
                                      Expanded(
                                        child: Text(
                                          item.address!,
                                          style: TulipTextStyles.caption
                                              .copyWith(fontSize: 12),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ],
                            ),
                          ),
                          if (item.averageRating != null) ...[
                            const SizedBox(width: 12),
                            _buildAverageRatingBadge(item.averageRating!),
                          ],
                        ],
                      ),

                      // Completion date
                      if (item.completedAt != null) ...[
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              Icons.check_circle_outline,
                              size: 13,
                              color: TulipColors.sage,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Completed ${_formatDate(item.completedAt!)}',
                              style: TulipTextStyles.caption.copyWith(
                                color: TulipColors.sage,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],

                      // Individual ratings
                      if (item.ratings.isNotEmpty || currentUserId != null) ...[
                        const SizedBox(height: 12),
                        Container(
                          height: 1,
                          color: TulipColors.taupeLight.withValues(alpha: 0.6),
                        ),
                        const SizedBox(height: 12),
                        _buildRatingsList(context),
                      ],
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

  Widget _buildAverageRatingBadge(double rating) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _accentColor.withValues(alpha: 0.15),
            _accentColor.withValues(alpha: 0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: _accentColor.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.star_rounded,
            size: 16,
            color: _accentColor,
          ),
          const SizedBox(width: 3),
          Text(
            rating.toStringAsFixed(1),
            style: TulipTextStyles.label.copyWith(
              color: TulipColors.brown,
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingsList(BuildContext context) {
    final currentUserRating = currentUserId != null
        ? item.ratings.where((r) => r.userId == currentUserId).firstOrNull
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Current user rating row first
        if (currentUserId != null) ...[
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _buildCurrentUserRatingRow(context, currentUserRating),
          ),
        ],
        // Other users' ratings
        ...item.ratings
            .where((rating) => rating.userId != currentUserId)
            .map((rating) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _buildRatingRow(rating),
                )),
      ],
    );
  }

  Widget _buildCurrentUserRatingRow(
      BuildContext context, ItemRating? existingRating) {
    final hasRated = existingRating != null;

    return GestureDetector(
      onTap: () => _showRatingDialog(context, existingRating?.rating ?? 0),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [TulipColors.sage, TulipColors.sageDark],
              ),
            ),
            child: const Icon(Icons.person, size: 16, color: Colors.white),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'You',
              style: TulipTextStyles.bodySmall.copyWith(
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (hasRated)
            RatingStars(rating: existingRating.rating, size: 16)
          else
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: TulipColors.coral.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.star_border, size: 14, color: TulipColors.coral),
                  const SizedBox(width: 3),
                  Text(
                    'Rate',
                    style: TulipTextStyles.caption.copyWith(
                      color: TulipColors.coral,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  void _showRatingDialog(BuildContext context, int initialRating) async {
    if (onRate == null) return;

    final rating = await showRatingDialog(
      context,
      title: 'Rate "${item.title}"',
      initialRating: initialRating,
    );

    if (rating != null) {
      onRate!(item.id, rating);
    }
  }

  Widget _buildRatingRow(ItemRating rating) {
    return Row(
      children: [
        if (rating.avatarUrl != null)
          CircleAvatar(
            radius: 14,
            backgroundImage: NetworkImage(rating.avatarUrl!),
            backgroundColor: TulipColors.taupeLight,
          )
        else
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [TulipColors.lavender, TulipColors.lavenderDark],
              ),
            ),
            child: Center(
              child: Text(
                rating.userName.isNotEmpty
                    ? rating.userName[0].toUpperCase()
                    : '?',
                style: TulipTextStyles.caption.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            rating.userName,
            style: TulipTextStyles.bodySmall,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        RatingStars(rating: rating.rating, size: 16),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'today';
    } else if (difference.inDays == 1) {
      return 'yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return DateFormat('MMM d, y').format(date);
    }
  }
}
