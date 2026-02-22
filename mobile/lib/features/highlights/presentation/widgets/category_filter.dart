import 'package:flutter/material.dart';
import '../../../../shared/constants/tulip_colors.dart';
import '../../../../shared/constants/tulip_text_styles.dart';

/// Horizontal scrollable category filter chips
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

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildChip(
            label: 'All',
            isSelected: selectedCategory == null,
            onTap: () => onCategorySelected(null),
            icon: Icons.auto_awesome,
          ),
          const SizedBox(width: 8),
          ...categories.map((category) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: _buildChip(
                  label: _formatCategory(category),
                  isSelected: selectedCategory == category,
                  onTap: () => onCategorySelected(category),
                  icon: _getCategoryIcon(category),
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    required IconData icon,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? TulipColors.sage : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? TulipColors.sage : TulipColors.taupeLight,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? Colors.white : TulipColors.brownLight,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TulipTextStyles.caption.copyWith(
                color: isSelected ? Colors.white : TulipColors.brown,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
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
