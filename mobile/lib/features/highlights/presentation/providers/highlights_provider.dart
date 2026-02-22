import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/highlights_model.dart';
import '../../data/repositories/highlights_repository.dart';
import '../../../bucket_list/data/repositories/bucket_list_repository.dart';

/// Provider for highlights data for a specific stay
final highlightsProvider = FutureProvider.family<HighlightsData, int>((ref, stayId) async {
  final repository = ref.read(highlightsRepositoryProvider);
  return repository.getHighlights(stayId);
});

/// Rate a highlight item and refresh highlights data
Future<void> rateHighlightItem(WidgetRef ref, int stayId, int itemId, int rating) async {
  final bucketListRepository = ref.read(bucketListRepositoryProvider);
  await bucketListRepository.rateItem(itemId, rating);
  // Invalidate to refresh data with new rating
  ref.invalidate(highlightsProvider(stayId));
}

/// Provider for the selected category filter
final highlightsCategoryFilterProvider = StateProvider.family<String?, int>((ref, stayId) => null);

/// Computed provider for filtered items
final filteredHighlightsProvider = Provider.family<Map<String, List<HighlightItem>>, int>((ref, stayId) {
  final highlightsAsync = ref.watch(highlightsProvider(stayId));
  final selectedCategory = ref.watch(highlightsCategoryFilterProvider(stayId));

  return highlightsAsync.whenOrNull(
    data: (highlights) {
      if (selectedCategory == null) {
        return highlights.itemsByCategory;
      }
      final filtered = highlights.itemsByCategory[selectedCategory];
      if (filtered != null) {
        return {selectedCategory: filtered};
      }
      return {};
    },
  ) ?? {};
});
