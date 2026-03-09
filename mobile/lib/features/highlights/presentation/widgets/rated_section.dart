import 'package:flutter/material.dart';
import '../../../../shared/constants/tulip_colors.dart';
import '../../../../shared/constants/tulip_text_styles.dart';
import '../../../../shared/widgets/animated_widgets.dart';
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

    return SlideUp(
      duration: const Duration(milliseconds: 500),
      delay: const Duration(milliseconds: 400),
      offset: 24,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: TulipColors.sage.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.star_rounded,
                    size: 20,
                    color: TulipColors.sageDark,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Rated Experiences',
                        style: TulipTextStyles.label.copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '$itemCount $memoryText',
                        style: TulipTextStyles.caption.copyWith(
                          color: TulipColors.brownLight,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Item cards with staggered animation
          ...items.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            return SlideUp(
              duration: const Duration(milliseconds: 400),
              delay: Duration(milliseconds: 500 + (index * 80)),
              offset: 16,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: HighlightItemCard(
                  item: item,
                  currentUserId: currentUserId,
                  onRate: onRate,
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
