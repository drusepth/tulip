import 'package:flutter/material.dart';
import '../../../../shared/constants/tulip_colors.dart';
import '../../../../shared/constants/tulip_text_styles.dart';

/// Category definition for filter chips
class FilterCategory {
  final String? id;
  final String label;
  final IconData icon;

  const FilterCategory({
    required this.id,
    required this.label,
    required this.icon,
  });
}

/// Available categories for filtering
const List<FilterCategory> galleryCategories = [
  FilterCategory(id: null, label: 'All', icon: Icons.grid_view),
  FilterCategory(id: 'coffee', label: 'Coffee', icon: Icons.coffee),
  FilterCategory(id: 'grocery', label: 'Grocery', icon: Icons.shopping_cart),
  FilterCategory(id: 'food', label: 'Food', icon: Icons.restaurant),
  FilterCategory(id: 'gym', label: 'Gym', icon: Icons.fitness_center),
  FilterCategory(id: 'coworking', label: 'Coworking', icon: Icons.work_outline),
  FilterCategory(id: 'library', label: 'Library', icon: Icons.local_library),
  FilterCategory(id: 'parks', label: 'Parks', icon: Icons.park),
];

/// Horizontal scrollable filter chips for gallery categories
class CategoryFilterChips extends StatelessWidget {
  final String? selectedCategory;
  final ValueChanged<String?> onCategorySelected;

  const CategoryFilterChips({
    super.key,
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: galleryCategories.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final category = galleryCategories[index];
          final isSelected = selectedCategory == category.id;

          return _FilterChip(
            category: category,
            isSelected: isSelected,
            onTap: () => onCategorySelected(category.id),
          );
        },
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final FilterCategory category;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.category,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        height: 36,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: isSelected ? TulipColors.sage : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? TulipColors.sage : TulipColors.taupeLight,
            width: 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: TulipColors.sage.withValues(alpha: 0.3),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              category.icon,
              size: 16,
              color: isSelected ? Colors.white : TulipColors.brown,
            ),
            const SizedBox(width: 6),
            Text(
              category.label,
              style: TulipTextStyles.label.copyWith(
                color: isSelected ? Colors.white : TulipColors.brown,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
