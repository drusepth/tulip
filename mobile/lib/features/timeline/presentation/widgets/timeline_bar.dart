import 'package:flutter/material.dart';
import '../../../../shared/constants/tulip_colors.dart';
import '../../../../shared/constants/tulip_text_styles.dart';
import '../providers/timeline_provider.dart';

/// Timeline bar representing a stay in the Gantt chart
class TimelineBar extends StatelessWidget {
  final TimelineItem item;
  final VoidCallback? onTap;

  const TimelineBar({
    super.key,
    required this.item,
    this.onTap,
  });

  Color get _backgroundColor {
    if (item.stay == null) return TulipColors.taupe;

    switch (item.stay!.status) {
      case 'upcoming':
        return TulipColors.sage;
      case 'current':
        return TulipColors.rose;
      case 'past':
        return TulipColors.taupe;
      default:
        return TulipColors.taupe;
    }
  }

  @override
  Widget build(BuildContext context) {
    final stay = item.stay;
    if (stay == null) return const SizedBox.shrink();

    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 100;

        return GestureDetector(
          onTap: onTap,
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: isCompact ? 8 : 12,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: _backgroundColor,
              borderRadius: BorderRadius.circular(12),
              border: stay.booked
                  ? null
                  : Border.all(
                      color: TulipColors.lavender,
                      width: 2,
                      style: BorderStyle.solid,
                    ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                // Stay type icon (hide when very compact)
                if (!isCompact) ...[
                  _buildTypeIcon(stay.stayType),
                  const SizedBox(width: 8),
                ],
                // Title and location (or just duration when compact)
                Expanded(
                  child: isCompact
                      ? Center(
                          child: Text(
                            '${item.durationDays}n',
                            style: TulipTextStyles.caption.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Flexible(
                              child: Text(
                                stay.title,
                                style: TulipTextStyles.label.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Flexible(
                              child: Text(
                                stay.city,
                                style: TulipTextStyles.caption.copyWith(
                                  color: Colors.white.withValues(alpha: 0.8),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                ),
                // Duration badge (hide when compact, already shown in center)
                if (!isCompact)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${item.durationDays}n',
                      style: TulipTextStyles.caption.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTypeIcon(String? stayType) {
    IconData icon;
    switch (stayType) {
      case 'airbnb':
        icon = Icons.home_outlined;
        break;
      case 'hotel':
        icon = Icons.hotel_outlined;
        break;
      case 'hostel':
        icon = Icons.bed_outlined;
        break;
      case 'camping':
        icon = Icons.forest_outlined;
        break;
      case 'friends_family':
        icon = Icons.people_outlined;
        break;
      default:
        icon = Icons.location_on_outlined;
    }

    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        icon,
        size: 18,
        color: Colors.white,
      ),
    );
  }
}
