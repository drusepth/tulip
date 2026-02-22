import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/gallery_item_model.dart';
import '../../data/repositories/gallery_repository.dart';

/// Provider for gallery state
final galleryProvider = AsyncNotifierProvider.family<GalleryNotifier, GalleryState, int>(() {
  return GalleryNotifier();
});

class GalleryState {
  final List<GalleryItem> items;
  final int currentPage;
  final int totalPages;
  final int totalCount;
  final bool hasMore;
  final bool isLoadingMore;
  final String? selectedCategory;

  const GalleryState({
    this.items = const [],
    this.currentPage = 0,
    this.totalPages = 1,
    this.totalCount = 0,
    this.hasMore = true,
    this.isLoadingMore = false,
    this.selectedCategory,
  });

  /// Returns items filtered by selected category (null = all)
  List<GalleryItem> get filteredItems {
    if (selectedCategory == null) return items;
    return items.where((item) => _matchesCategory(item.category, selectedCategory!)).toList();
  }

  /// Returns count of filtered items
  int get filteredCount => filteredItems.length;

  /// Check if a filter is currently active
  bool get hasActiveFilter => selectedCategory != null;

  /// Helper to match category with some flexibility for plurals/variants
  static bool _matchesCategory(String itemCategory, String filterCategory) {
    final normalized = itemCategory.toLowerCase();
    final filter = filterCategory.toLowerCase();

    // Handle common category variations
    if (filter == 'food') {
      return normalized == 'food' ||
             normalized == 'restaurant' ||
             normalized == 'restaurants';
    }
    if (filter == 'gym') {
      return normalized == 'gym' || normalized == 'gyms';
    }
    if (filter == 'parks') {
      return normalized == 'park' || normalized == 'parks';
    }

    return normalized == filter || normalized == '${filter}s';
  }

  GalleryState copyWith({
    List<GalleryItem>? items,
    int? currentPage,
    int? totalPages,
    int? totalCount,
    bool? hasMore,
    bool? isLoadingMore,
    String? selectedCategory,
    bool clearCategory = false,
  }) {
    return GalleryState(
      items: items ?? this.items,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      totalCount: totalCount ?? this.totalCount,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      selectedCategory: clearCategory ? null : (selectedCategory ?? this.selectedCategory),
    );
  }
}

class GalleryNotifier extends FamilyAsyncNotifier<GalleryState, int> {
  @override
  Future<GalleryState> build(int stayId) async {
    return _fetchPage(stayId, 1);
  }

  Future<GalleryState> _fetchPage(int stayId, int page) async {
    final repository = ref.read(galleryRepositoryProvider);
    final response = await repository.getGallery(stayId, page: page);

    return GalleryState(
      items: response.places,
      currentPage: response.page,
      totalPages: response.totalPages,
      totalCount: response.totalCount,
      hasMore: response.hasMore,
    );
  }

  /// Load more items (infinite scroll)
  Future<void> loadMore() async {
    final current = state.valueOrNull;
    if (current == null || !current.hasMore || current.isLoadingMore) return;

    state = AsyncValue.data(current.copyWith(isLoadingMore: true));

    try {
      final repository = ref.read(galleryRepositoryProvider);
      final response = await repository.getGallery(arg, page: current.currentPage + 1);

      state = AsyncValue.data(current.copyWith(
        items: [...current.items, ...response.places],
        currentPage: response.page,
        totalPages: response.totalPages,
        totalCount: response.totalCount,
        hasMore: response.hasMore,
        isLoadingMore: false,
      ));
    } catch (e) {
      state = AsyncValue.data(current.copyWith(isLoadingMore: false));
    }
  }

  /// Refresh gallery
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchPage(arg, 1));
  }

  /// Update item favorite status locally
  void updateItemFavorite(int placeId, bool favorite) {
    final current = state.valueOrNull;
    if (current == null) return;

    final updatedItems = current.items.map((item) {
      if (item.id == placeId) {
        return GalleryItem(
          id: item.id,
          name: item.name,
          category: item.category,
          latitude: item.latitude,
          longitude: item.longitude,
          address: item.address,
          distanceMeters: item.distanceMeters,
          favorite: favorite,
          inBucketList: item.inBucketList,
          foursquarePhotoUrl: item.foursquarePhotoUrl,
          foursquareRating: item.foursquareRating,
          foursquarePrice: item.foursquarePrice,
        );
      }
      return item;
    }).toList();

    state = AsyncValue.data(current.copyWith(items: updatedItems));
  }

  /// Update item bucket list status locally
  void updateItemBucketList(int placeId, bool inBucketList) {
    final current = state.valueOrNull;
    if (current == null) return;

    final updatedItems = current.items.map((item) {
      if (item.id == placeId) {
        return GalleryItem(
          id: item.id,
          name: item.name,
          category: item.category,
          latitude: item.latitude,
          longitude: item.longitude,
          address: item.address,
          distanceMeters: item.distanceMeters,
          favorite: item.favorite,
          inBucketList: inBucketList,
          foursquarePhotoUrl: item.foursquarePhotoUrl,
          foursquareRating: item.foursquareRating,
          foursquarePrice: item.foursquarePrice,
        );
      }
      return item;
    }).toList();

    state = AsyncValue.data(current.copyWith(items: updatedItems));
  }

  /// Select a category filter (null = show all)
  void selectCategory(String? category) {
    final current = state.valueOrNull;
    if (current == null) return;

    state = AsyncValue.data(current.copyWith(
      selectedCategory: category,
      clearCategory: category == null,
    ));
  }
}
