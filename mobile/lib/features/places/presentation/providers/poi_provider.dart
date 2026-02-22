import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/poi_model.dart';
import '../../data/repositories/poi_repository.dart';

/// Provider for POIs associated with a specific stay
final stayPoisProvider = AsyncNotifierProvider.family<StayPoisNotifier, List<Poi>, int>(() {
  return StayPoisNotifier();
});

class StayPoisNotifier extends FamilyAsyncNotifier<List<Poi>, int> {
  @override
  Future<List<Poi>> build(int stayId) async {
    return _fetchPois(stayId);
  }

  Future<List<Poi>> _fetchPois(int stayId) async {
    final repository = ref.read(poiRepositoryProvider);
    return repository.getPoisForStay(stayId);
  }

  /// Refresh POIs from server
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchPois(arg));
  }

  /// Fetch POIs for a specific category
  Future<void> fetchCategory(String category) async {
    final repository = ref.read(poiRepositoryProvider);
    try {
      final newPois = await repository.fetchPoisForStay(arg, category: category);
      final currentPois = state.valueOrNull ?? [];

      // Merge new POIs with existing ones (avoiding duplicates)
      final existingIds = currentPois.map((p) => p.id).toSet();
      final mergedPois = [
        ...currentPois,
        ...newPois.where((p) => !existingIds.contains(p.id)),
      ];

      state = AsyncValue.data(mergedPois);
    } catch (e) {
      // Don't update state on error, keep existing POIs
    }
  }

  /// Toggle favorite status
  Future<void> toggleFavorite(int poiId) async {
    final repository = ref.read(poiRepositoryProvider);
    try {
      final updatedPoi = await repository.toggleFavorite(arg, poiId);
      final pois = state.valueOrNull ?? [];
      state = AsyncValue.data(
        pois.map((p) => p.id == poiId ? updatedPoi : p).toList(),
      );
    } catch (e) {
      // Handle error
    }
  }
}

/// Provider for POIs filtered by enabled categories
final filteredPoisProvider = Provider.family<List<Poi>, ({int stayId, Set<String> categories})>((ref, params) {
  final poisAsync = ref.watch(stayPoisProvider(params.stayId));
  return poisAsync.whenOrNull(
    data: (pois) => pois.where((p) => params.categories.contains(p.category)).toList(),
  ) ?? [];
});

/// Provider for place details
final placeDetailProvider = FutureProvider.family<Place, int>((ref, placeId) async {
  final repository = ref.read(poiRepositoryProvider);
  return repository.getPlace(placeId);
});

/// Provider for favorite POIs for a stay
final favoritePoisProvider = Provider.family<List<Poi>, int>((ref, stayId) {
  final poisAsync = ref.watch(stayPoisProvider(stayId));
  return poisAsync.whenOrNull(
    data: (pois) => pois.where((p) => p.favorite).toList(),
  ) ?? [];
});
