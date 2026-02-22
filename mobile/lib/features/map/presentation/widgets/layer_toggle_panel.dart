import 'package:flutter/material.dart';
import '../../../../shared/constants/tulip_colors.dart';
import '../../../../shared/constants/tulip_text_styles.dart';
import '../providers/map_provider.dart';
import '../../../transit/data/models/transit_route_model.dart';

class LayerTogglePanel extends StatelessWidget {
  final Set<String> enabledCategories;
  final Set<TransitRouteType> enabledTransitLayers;
  final void Function(String category) onCategoryToggled;
  final void Function(TransitRouteType type) onTransitLayerToggled;
  final VoidCallback onClose;

  const LayerTogglePanel({
    super.key,
    required this.enabledCategories,
    required this.enabledTransitLayers,
    required this.onCategoryToggled,
    required this.onTransitLayerToggled,
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
          // POI Categories section
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: Text(
              'Places',
              style: TulipTextStyles.caption.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ...PoiCategory.all.map((category) => _buildCategoryToggle(category)),
          const SizedBox(height: 8),
          const Divider(height: 1),
          // Transit Layers section
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: Text(
              'Transit',
              style: TulipTextStyles.caption.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ...TransitRouteType.values.map((type) => _buildTransitToggle(type)),
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

  Widget _buildTransitToggle(TransitRouteType type) {
    final isEnabled = enabledTransitLayers.contains(type);
    final color = _getTransitColor(type);

    return InkWell(
      onTap: () => onTransitLayerToggled(type),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            Icon(
              _getTransitIconData(type),
              size: 20,
              color: isEnabled ? color : TulipColors.brownLighter,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                type.displayName,
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
                color: isEnabled ? color : Colors.transparent,
                border: Border.all(
                  color: isEnabled ? color : TulipColors.brownLighter,
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

  IconData _getTransitIconData(TransitRouteType type) {
    switch (type) {
      case TransitRouteType.rails:
        return Icons.subway;
      case TransitRouteType.train:
        return Icons.train;
      case TransitRouteType.ferry:
        return Icons.directions_boat;
      case TransitRouteType.bus:
        return Icons.directions_bus;
    }
  }

  Color _getTransitColor(TransitRouteType type) {
    switch (type) {
      case TransitRouteType.rails:
        return const Color(0xFFe11d48); // Rose
      case TransitRouteType.train:
        return const Color(0xFF1d4ed8); // Blue
      case TransitRouteType.ferry:
        return const Color(0xFF0284c7); // Cyan
      case TransitRouteType.bus:
        return const Color(0xFF65a30d); // Lime
    }
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
