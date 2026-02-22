import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../shared/constants/tulip_colors.dart';
import '../../../../shared/constants/tulip_text_styles.dart';
import '../../../../shared/widgets/status_badge.dart';
import '../../data/models/stay_model.dart';

class StayCard extends StatelessWidget {
  final Stay stay;
  final VoidCallback? onTap;
  final bool showImage;

  const StayCard({
    super.key,
    required this.stay,
    this.onTap,
    this.showImage = true,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: TulipColors.taupeLight),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (showImage && stay.imageUrl != null) _buildImage(),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          stay.title,
                          style: TulipTextStyles.heading3,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      StatusBadge(status: stay.status),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: 16,
                        color: TulipColors.brownLight,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          stay.location,
                          style: TulipTextStyles.bodySmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  if (stay.dateRange != null) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today_outlined,
                          size: 16,
                          color: TulipColors.brownLight,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          stay.dateRange!,
                          style: TulipTextStyles.bodySmall,
                        ),
                        if (stay.durationDays > 0) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: TulipColors.sageLight,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${stay.durationDays} nights',
                              style: TulipTextStyles.caption.copyWith(
                                color: TulipColors.sageDark,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                  if (stay.daysUntilCheckIn != null && stay.isUpcoming) ...[
                    const SizedBox(height: 8),
                    _buildCountdown(),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage() {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: CachedNetworkImage(
        imageUrl: stay.imageUrl!,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          color: TulipColors.taupeLight,
          child: const Center(
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: TulipColors.sage,
            ),
          ),
        ),
        errorWidget: (context, url, error) => Container(
          color: TulipColors.taupeLight,
          child: Icon(
            Icons.image_outlined,
            color: TulipColors.brownLighter,
            size: 48,
          ),
        ),
      ),
    );
  }

  Widget _buildCountdown() {
    final days = stay.daysUntilCheckIn!;
    final color = days <= 7
        ? TulipColors.coral
        : days <= 30
            ? TulipColors.lavender
            : TulipColors.sage;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.schedule,
            size: 14,
            color: TulipColors.brown,
          ),
          const SizedBox(width: 4),
          Text(
            days == 0
                ? 'Today!'
                : days == 1
                    ? 'Tomorrow!'
                    : 'In $days days',
            style: TulipTextStyles.caption.copyWith(
              color: TulipColors.brown,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// Compact version of stay card for lists
class StayCardCompact extends StatelessWidget {
  final Stay stay;
  final VoidCallback? onTap;

  const StayCardCompact({
    super.key,
    required this.stay,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: TulipColors.taupeLight),
        ),
        child: Row(
          children: [
            // Thumbnail
            if (stay.imageUrl != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: CachedNetworkImage(
                  imageUrl: stay.imageUrl!,
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    width: 60,
                    height: 60,
                    color: TulipColors.taupeLight,
                  ),
                  errorWidget: (context, url, error) => Container(
                    width: 60,
                    height: 60,
                    color: TulipColors.taupeLight,
                    child: Icon(
                      Icons.home_outlined,
                      color: TulipColors.brownLighter,
                    ),
                  ),
                ),
              )
            else
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: TulipColors.sageLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.home_outlined,
                  color: TulipColors.sageDark,
                ),
              ),
            const SizedBox(width: 12),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    stay.title,
                    style: TulipTextStyles.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    stay.location,
                    style: TulipTextStyles.caption,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (stay.dateRange != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      stay.dateRange!,
                      style: TulipTextStyles.caption,
                    ),
                  ],
                ],
              ),
            ),
            // Status indicator
            StatusBadge(status: stay.status, small: true),
          ],
        ),
      ),
    );
  }
}
