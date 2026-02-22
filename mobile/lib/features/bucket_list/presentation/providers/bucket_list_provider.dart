import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/bucket_list_item_model.dart';
import '../../data/repositories/bucket_list_repository.dart';

/// Provider for bucket list items for a specific stay
final bucketListProvider = AsyncNotifierProvider.family<BucketListNotifier, List<BucketListItem>, int>(() {
  return BucketListNotifier();
});

class BucketListNotifier extends FamilyAsyncNotifier<List<BucketListItem>, int> {
  @override
  Future<List<BucketListItem>> build(int stayId) async {
    return _fetchItems(stayId);
  }

  Future<List<BucketListItem>> _fetchItems(int stayId) async {
    final repository = ref.read(bucketListRepositoryProvider);
    return repository.getItemsForStay(stayId);
  }

  /// Refresh the bucket list
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchItems(arg));
  }

  /// Toggle an item's completed status
  Future<void> toggleItem(int itemId) async {
    final repository = ref.read(bucketListRepositoryProvider);
    final updatedItem = await repository.toggleItem(itemId);

    // Update local state
    final items = state.valueOrNull ?? [];
    state = AsyncValue.data(
      items.map((item) => item.id == itemId ? updatedItem : item).toList(),
    );
  }

  /// Add a new item
  Future<BucketListItem?> createItem(BucketListItemRequest request) async {
    final repository = ref.read(bucketListRepositoryProvider);
    try {
      final newItem = await repository.createItem(arg, request);
      final items = state.valueOrNull ?? [];
      state = AsyncValue.data([...items, newItem]);
      return newItem;
    } catch (e) {
      return null;
    }
  }

  /// Delete an item
  Future<bool> deleteItem(int itemId) async {
    final repository = ref.read(bucketListRepositoryProvider);
    try {
      await repository.deleteItem(itemId);
      final items = state.valueOrNull ?? [];
      state = AsyncValue.data(items.where((item) => item.id != itemId).toList());
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Rate an item
  Future<void> rateItem(int itemId, int rating) async {
    final repository = ref.read(bucketListRepositoryProvider);
    final result = await repository.rateItem(itemId, rating);

    // Update local state with new rating
    final items = state.valueOrNull ?? [];
    state = AsyncValue.data(
      items.map((item) {
        if (item.id == itemId) {
          return item.copyWith(
            userRating: result['user_rating'] as int?,
            averageRating: (result['average_rating'] as num?)?.toDouble(),
          );
        }
        return item;
      }).toList(),
    );
  }
}

/// Computed provider for completed items count
final bucketListCompletedCountProvider = Provider.family<int, int>((ref, stayId) {
  final itemsAsync = ref.watch(bucketListProvider(stayId));
  return itemsAsync.whenOrNull(
    data: (items) => items.where((item) => item.completed).length,
  ) ?? 0;
});

/// Computed provider for total items count
final bucketListTotalCountProvider = Provider.family<int, int>((ref, stayId) {
  final itemsAsync = ref.watch(bucketListProvider(stayId));
  return itemsAsync.whenOrNull(
    data: (items) => items.length,
  ) ?? 0;
});
