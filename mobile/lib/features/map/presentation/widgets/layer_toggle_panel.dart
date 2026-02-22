import 'package:flutter/material.dart';
import '../../../../shared/constants/tulip_colors.dart';
import '../../../../shared/constants/tulip_text_styles.dart';
import '../providers/map_provider.dart';

class LayerTogglePanel extends StatelessWidget {
  final Set<String> enabledCategories;
  final void Function(String category) onCategoryToggled;
  final VoidCallback onClose;

  const LayerTogglePanel({
    super.key,
    required this.enabledCategories,
    required this.onCategoryToggled,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 8, 8),
            child: Row(
              children: [
                Text(
                  'Map Layers',
                  style: TulipTextStyles.label,
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close, size: 18),
                  onPressed: onClose,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  color: TulipColors.brownLight,
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // Categories
          ...PoiCategory.all.map((category) => _buildCategoryToggle(category)),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildCategoryToggle(PoiCategory category) {
    final isEnabled = enabledCategories.contains(category.id);

    return InkWell(
      onTap: () => onCategoryToggled(category.id),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            Icon(
              _getIconData(category.icon),
              size: 20,
              color: isEnabled ? TulipColors.sage : TulipColors.brownLighter,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                category.label,
                style: TulipTextStyles.body.copyWith(
                  color: isEnabled ? TulipColors.brown : TulipColors.brownLighter,
                ),
              ),
            ),
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isEnabled ? TulipColors.sage : Colors.transparent,
                border: Border.all(
                  color: isEnabled ? TulipColors.sage : TulipColors.brownLighter,
                  width: 2,
                ),
              ),
              child: isEnabled
                  ? const Icon(Icons.check, size: 14, color: Colors.white)
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'coffee':
        return Icons.coffee;
      case 'restaurant':
        return Icons.restaurant;
      case 'shopping_cart':
        return Icons.shopping_cart;
      case 'local_bar':
        return Icons.local_bar;
      case 'fitness_center':
        return Icons.fitness_center;
      case 'park':
        return Icons.park;
      case 'directions_transit':
        return Icons.directions_transit;
      case 'museum':
        return Icons.museum;
      default:
        return Icons.place;
    }
  }
}
