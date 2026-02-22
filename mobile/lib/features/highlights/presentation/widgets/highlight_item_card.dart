import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../shared/constants/tulip_colors.dart';
import '../../../../shared/constants/tulip_text_styles.dart';
import '../../../../shared/widgets/cozy_card.dart';
import '../../../bucket_list/presentation/widgets/rating_stars.dart';
import '../../data/models/highlights_model.dart';

/// Card displaying a completed bucket list item with ratings
class HighlightItemCard extends StatelessWidget {
  final HighlightItem item;

  const HighlightItemCard({
    super.key,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    return CozyCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title and average rating
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
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (item.address != null && item.address!.isNotEmpty) ...[
                      const SizedBox(height: 4),
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
                  size: 14,
                  color: TulipColors.sage,
                ),
                const SizedBox(width: 4),
                Text(
                  'Completed ${_formatDate(item.completedAt!)}',
                  style: TulipTextStyles.caption.copyWith(
                    color: TulipColors.sage,
                  ),
                ),
              ],
            ),
          ],

          // Individual ratings
          if (item.ratings.isNotEmpty) ...[
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 12),
            _buildRatingsList(),
          ],
        ],
      ),
    );
  }

  Widget _buildAverageRatingBadge(double rating) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: TulipColors.coral.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.star,
            size: 16,
            color: TulipColors.coral,
          ),
          const SizedBox(width: 4),
          Text(
            rating.toStringAsFixed(1),
            style: TulipTextStyles.label.copyWith(
              color: TulipColors.coralDark,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingsList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ratings',
          style: TulipTextStyles.caption.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        ...item.ratings.map((rating) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _buildRatingRow(rating),
            )),
      ],
    );
  }

  Widget _buildRatingRow(ItemRating rating) {
    return Row(
      children: [
        // User avatar or icon
        if (rating.avatarUrl != null)
          CircleAvatar(
            radius: 14,
            backgroundImage: NetworkImage(rating.avatarUrl!),
            backgroundColor: TulipColors.taupeLight,
          )
        else
          CircleAvatar(
            radius: 14,
            backgroundColor: TulipColors.lavenderLight,
            child: Text(
              rating.userName.isNotEmpty ? rating.userName[0].toUpperCase() : '?',
              style: TulipTextStyles.caption.copyWith(
                color: TulipColors.lavenderDark,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        const SizedBox(width: 10),
        // User name
        Expanded(
          child: Text(
            rating.userName,
            style: TulipTextStyles.bodySmall,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        // Star rating
        RatingStars(
          rating: rating.rating,
          size: 16,
        ),
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
