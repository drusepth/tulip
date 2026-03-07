import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../shared/constants/tulip_colors.dart';
import '../../../../shared/constants/tulip_text_styles.dart';
import '../../../../shared/widgets/animated_widgets.dart';

/// Horizontal scrollable category filter chips with cottagecore styling
class CategoryFilter extends StatelessWidget {
  final List<String> categories;
  final String? selectedCategory;
  final ValueChanged<String?> onCategorySelected;

  const CategoryFilter({
    super.key,
    required this.categories,
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    if (categories.isEmpty) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        children: [
          _FilterChip(
            label: 'All',
            icon: Icons.auto_awesome,
            isSelected: selectedCategory == null,
            accentColor: TulipColors.coral,
            onTap: () {
              HapticFeedback.lightImpact();
              onCategorySelected(null);
            },
          ),
          const SizedBox(width: 10),
          ...categories.map((category) {
            final icon = _getCategoryIcon(category);
            final color = _getCategoryColor(category);
            return Padding(
              padding: const EdgeInsets.only(right: 10),
              child: _FilterChip(
                label: _formatCategory(category),
                icon: icon,
                isSelected: selectedCategory == category,
                accentColor: color,
                onTap: () {
                  HapticFeedback.lightImpact();
                  onCategorySelected(category);
                },
              ),
            );
          }),
        ],
      ),
    );
  }

  String _formatCategory(String category) {
    if (category.isEmpty) return 'Other';
    return category
        .replaceAll('_', ' ')
        .split(' ')
        .map((word) =>
            word.isNotEmpty ? '${word[0].toUpperCase()}${word.substring(1)}' : '')
        .join(' ');
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'restaurant':
      case 'restaurants':
      case 'food':
        return TulipColors.coral;
      case 'cafe':
      case 'cafes':
      case 'coffee':
        return TulipColors.taupe;
      case 'bar':
      case 'bars':
      case 'nightlife':
        return TulipColors.lavender;
      case 'attraction':
      case 'attractions':
      case 'sightseeing':
        return TulipColors.rose;
      case 'park':
      case 'parks':
      case 'nature':
        return TulipColors.sage;
      case 'museum':
      case 'museums':
        return TulipColors.lavender;
      case 'shopping':
        return TulipColors.rose;
      default:
        return TulipColors.taupe;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'restaurant':
      case 'restaurants':
        return Icons.restaurant;
      case 'cafe':
      case 'cafes':
      case 'coffee':
        return Icons.coffee;
      case 'bar':
      case 'bars':
        return Icons.local_bar;
      case 'attraction':
      case 'attractions':
      case 'sightseeing':
        return Icons.attractions;
      case 'museum':
      case 'museums':
        return Icons.museum;
      case 'park':
      case 'parks':
      case 'nature':
        return Icons.park;
      case 'shopping':
        return Icons.shopping_bag;
      case 'entertainment':
        return Icons.theater_comedy;
      case 'activity':
      case 'activities':
        return Icons.directions_run;
      case 'hotel':
      case 'accommodation':
        return Icons.hotel;
      case 'transport':
      case 'transportation':
        return Icons.directions_transit;
      default:
        return Icons.place;
    }
  }
}

/// Individual filter chip with accent color, shadow, and scale animation
class _FilterChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final Color accentColor;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.accentColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ScaleOnTap(
      onTap: onTap,
      scale: 0.95,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? accentColor : Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: isSelected
                ? accentColor
                : TulipColors.taupeLight,
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: accentColor.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? Colors.white : accentColor,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TulipTextStyles.caption.copyWith(
                color: isSelected ? Colors.white : TulipColors.brown,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
