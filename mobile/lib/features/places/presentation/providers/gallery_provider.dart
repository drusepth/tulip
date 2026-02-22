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

  const GalleryState({
    this.items = const [],
    this.currentPage = 0,
    this.totalPages = 1,
    this.totalCount = 0,
    this.hasMore = true,
    this.isLoadingMore = false,
  });

  GalleryState copyWith({
    List<GalleryItem>? items,
    int? currentPage,
    int? totalPages,
    int? totalCount,
    bool? hasMore,
    bool? isLoadingMore,
  }) {
    return GalleryState(
      items: items ?? this.items,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      totalCount: totalCount ?? this.totalCount,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
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
}
