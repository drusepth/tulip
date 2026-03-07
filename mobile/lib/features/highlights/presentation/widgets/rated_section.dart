import 'package:flutter/material.dart';
import '../../../../shared/constants/tulip_colors.dart';
import '../../../../shared/constants/tulip_text_styles.dart';
import '../../data/models/highlights_model.dart';
import 'highlight_item_card.dart';

/// Section displaying rated highlight items
class RatedSection extends StatelessWidget {
  final List<HighlightItem> items;
  final int currentUserId;
  final void Function(int itemId, int rating) onRate;

  const RatedSection({
    super.key,
    required this.items,
    required this.currentUserId,
    required this.onRate,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();

    final itemCount = items.length;
    final memoryText = itemCount == 1 ? 'memory' : 'memories';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          children: [
            Icon(
              Icons.star,
              size: 20,
              color: TulipColors.coral,
            ),
            const SizedBox(width: 8),
            Text(
              'Rated Experiences',
              style: TulipTextStyles.label.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: TulipColors.coral.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$itemCount $memoryText',
                style: TulipTextStyles.caption.copyWith(
                  color: TulipColors.coralDark,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Item cards
        ...items.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: HighlightItemCard(
                item: item,
                currentUserId: currentUserId,
                onRate: onRate,
              ),
            )),
      ],
    );
  }
}
