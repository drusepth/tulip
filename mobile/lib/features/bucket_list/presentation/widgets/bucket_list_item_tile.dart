import 'package:flutter/material.dart';
import '../../../../shared/constants/tulip_colors.dart';
import '../../../../shared/constants/tulip_text_styles.dart';
import '../../data/models/bucket_list_item_model.dart';
import 'rating_stars.dart';

class BucketListItemTile extends StatelessWidget {
  final BucketListItem item;
  final VoidCallback? onTap;
  final VoidCallback? onToggle;
  final VoidCallback? onDelete;
  final ValueChanged<int>? onRate;

  const BucketListItemTile({
    super.key,
    required this.item,
    this.onTap,
    this.onToggle,
    this.onDelete,
    this.onRate,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key('bucket_item_${item.id}'),
      direction: onDelete != null ? DismissDirection.endToStart : DismissDirection.none,
      onDismissed: (_) => onDelete?.call(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: TulipColors.roseDark,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: TulipColors.taupeLight),
          ),
          child: Row(
            children: [
              // Checkbox
              GestureDetector(
                onTap: onToggle,
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: item.completed ? TulipColors.sage : Colors.transparent,
                    border: Border.all(
                      color: item.completed ? TulipColors.sage : TulipColors.brownLight,
                      width: 2,
                    ),
                  ),
                  child: item.completed
                      ? const Icon(Icons.check, size: 16, color: Colors.white)
                      : null,
                ),
              ),
              const SizedBox(width: 12),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: TulipTextStyles.label.copyWith(
                        decoration: item.completed ? TextDecoration.lineThrough : null,
                        color: item.completed ? TulipColors.brownLighter : TulipColors.brown,
                      ),
                    ),
                    if (item.category != null && item.category!.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        item.categoryDisplay,
                        style: TulipTextStyles.caption,
                      ),
                    ],
                    // Show rating or rate button for completed items
                    if (item.completed) ...[
                      const SizedBox(height: 4),
                      _buildRatingSection(context),
                    ],
                  ],
                ),
              ),
              // Location indicator
              if (item.hasLocation)
                Icon(
                  Icons.location_on_outlined,
                  size: 16,
                  color: TulipColors.brownLight,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRatingSection(BuildContext context) {
    final userRating = item.userRating ?? 0;
    final averageRating = item.averageRating ?? 0;

    if (userRating > 0) {
      // User has already rated - show their rating
      return GestureDetector(
        onTap: () => _showRatingDialog(context),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            RatingStars(
              rating: userRating,
              size: 14,
            ),
            if (averageRating > 0 && averageRating != userRating.toDouble()) ...[
              const SizedBox(width: 8),
              Text(
                'Avg: ${averageRating.toStringAsFixed(1)}',
                style: TulipTextStyles.caption,
              ),
            ],
          ],
        ),
      );
    }

    // User hasn't rated yet - show prompt
    return GestureDetector(
      onTap: () => _showRatingDialog(context),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.star_border,
            size: 14,
            color: TulipColors.coral,
          ),
          const SizedBox(width: 4),
          Text(
            'Rate it',
            style: TulipTextStyles.caption.copyWith(
              color: TulipColors.coral,
            ),
          ),
        ],
      ),
    );
  }

  void _showRatingDialog(BuildContext context) async {
    if (onRate == null) return;

    final rating = await showRatingDialog(
      context,
      title: 'Rate "${item.title}"',
      initialRating: item.userRating ?? 0,
    );

    if (rating != null) {
      onRate!(rating);
    }
  }
}

/// Compact version for inline lists
class BucketListItemCompact extends StatelessWidget {
  final BucketListItem item;
  final VoidCallback? onToggle;

  const BucketListItemCompact({
    super.key,
    required this.item,
    this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onToggle,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: item.completed ? TulipColors.sage : Colors.transparent,
                border: Border.all(
                  color: item.completed ? TulipColors.sage : TulipColors.brownLight,
                  width: 1.5,
                ),
              ),
              child: item.completed
                  ? const Icon(Icons.check, size: 14, color: Colors.white)
                  : null,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                item.title,
                style: TulipTextStyles.bodySmall.copyWith(
                  decoration: item.completed ? TextDecoration.lineThrough : null,
                  color: item.completed ? TulipColors.brownLighter : TulipColors.brown,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
