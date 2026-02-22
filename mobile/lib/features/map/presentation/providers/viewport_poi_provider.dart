import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import '../../data/models/viewport_poi_state.dart';
import '../../utils/grid_cell_helper.dart';
import '../../../places/data/models/poi_model.dart';
import '../../../places/data/repositories/poi_repository.dart';
import '../../../stays/data/models/stay_model.dart';

/// Provider for viewport-based POI state
final viewportPoiProvider =
    StateNotifierProvider<ViewportPoiNotifier, ViewportPoiState>((ref) {
  final repository = ref.watch(poiRepositoryProvider);
  return ViewportPoiNotifier(repository);
});

/// Minimum zoom level required to fetch POIs
const double minZoomForPois = 13.0;

/// Maximum concurrent requests per batch
const int maxConcurrentRequests = 2;

/// Debounce duration for viewport changes
const Duration debounceDuration = Duration(milliseconds: 300);

class ViewportPoiNotifier extends StateNotifier<ViewportPoiState> {
  final PoiRepository _repository;
  Timer? _debounceTimer;
  final Map<String, CancelToken> _cancelTokens = {};

  ViewportPoiNotifier(this._repository) : super(const ViewportPoiState());

  /// Called when the map viewport changes
  void onViewportChanged({
    required LatLng center,
    required double zoom,
    required Set<String> enabledCategories,
    required List<Stay> stays,
  }) {
    // Cancel previous debounce timer
    _debounceTimer?.cancel();

    // Don't fetch if zoom is too low
    if (zoom < minZoomForPois) {
      return;
    }

    // Debounce to avoid excessive API calls during panning
    _debounceTimer = Timer(debounceDuration, () {
      _fetchPoisForViewport(center, enabledCategories);
    });
  }

  Future<void> _fetchPoisForViewport(
    LatLng center,
    Set<String> enabledCategories,
  ) async {
    for (final category in enabledCategories) {
      // Get all visible grid cells for this category
      final gridCells = GridCellHelper.getVisibleGridCells(center, category);

      // Filter to only unsearched cells
      final unsearchedCells = gridCells
          .where((cell) => !state.searchedGridCells.contains(cell.key))
          .toList();

      if (unsearchedCells.isEmpty) continue;

      // Mark cells as being searched (optimistically)
      final newSearchedCells = Set<String>.from(state.searchedGridCells)
        ..addAll(unsearchedCells.map((c) => c.key));
      state = state.copyWith(searchedGridCells: newSearchedCells);

      // Fetch POIs for unsearched cells (limited concurrency)
      await _fetchCellsBatch(unsearchedCells, category);
    }
  }

  Future<void> _fetchCellsBatch(List<GridCell> cells, String category) async {
    // Cancel any existing request for this category
    _cancelTokens[category]?.cancel();
    final cancelToken = CancelToken();
    _cancelTokens[category] = cancelToken;

    // Mark category as loading
    state = state.copyWith(
      loadingCategories: {...state.loadingCategories, category},
    );

    try {
      // Process cells in batches
      for (int i = 0; i < cells.length; i += maxConcurrentRequests) {
        if (cancelToken.isCancelled) break;

        final batch = cells.skip(i).take(maxConcurrentRequests).toList();
        final futures = batch.map((cell) => _fetchCell(cell, cancelToken));
        final results = await Future.wait(futures, eagerError: false);

        // Merge results
        final allPois = <Poi>[];
        final failedCells = <String>[];

        for (int j = 0; j < results.length; j++) {
          final result = results[j];
          if (result != null) {
            allPois.addAll(result);
          } else {
            // Rate limited or error - remove from searched so it can be retried
            failedCells.add(batch[j].key);
          }
        }

        if (allPois.isNotEmpty || failedCells.isNotEmpty) {
          _mergePois(category, allPois, failedCells);
        }
      }
    } finally {
      // Remove loading state
      state = state.copyWith(
        loadingCategories: state.loadingCategories
            .where((c) => c != category)
            .toSet(),
      );
      _cancelTokens.remove(category);
    }
  }

  Future<List<Poi>?> _fetchCell(GridCell cell, CancelToken cancelToken) async {
    try {
      return await _repository.searchPois(
        lat: cell.center.latitude,
        lng: cell.center.longitude,
        category: cell.category,
        cancelToken: cancelToken,
      );
    } on DioException catch (e) {
      if (e.type == DioExceptionType.cancel) {
        return null;
      }
      // Rate limit or other error
      if (e.response?.statusCode == 429) {
        return null;
      }
      rethrow;
    } catch (e) {
      // Return null to indicate failure (will be retried)
      return null;
    }
  }

  void _mergePois(String category, List<Poi> newPois, List<String> failedCells) {
    final updatedPoisByCategory = Map<String, List<Poi>>.from(state.poisByCategory);
    final existingPois = updatedPoisByCategory[category] ?? [];

    // Merge new POIs, avoiding duplicates by ID
    final existingIds = existingPois.map((p) => p.id).toSet();
    final uniqueNewPois = newPois.where((p) => !existingIds.contains(p.id)).toList();
    updatedPoisByCategory[category] = [...existingPois, ...uniqueNewPois];

    // Remove failed cells from searched set so they can be retried
    final updatedSearchedCells = Set<String>.from(state.searchedGridCells)
      ..removeAll(failedCells);

    state = state.copyWith(
      poisByCategory: updatedPoisByCategory,
      searchedGridCells: updatedSearchedCells,
    );
  }

  /// Select a POI to show its popup
  void selectPoi(Poi poi) {
    state = state.copyWith(selectedPoi: poi);
  }

  /// Clear the current POI selection
  void clearSelection() {
    state = state.copyWith(clearSelectedPoi: true);
  }

  /// Called when a category is disabled - clears its POIs and cancels requests
  void onCategoryDisabled(String category) {
    // Cancel any pending request
    _cancelTokens[category]?.cancel();
    _cancelTokens.remove(category);

    // Remove POIs for this category
    final updatedPoisByCategory = Map<String, List<Poi>>.from(state.poisByCategory)
      ..remove(category);

    // Remove searched cells for this category
    final updatedSearchedCells = state.searchedGridCells
        .where((key) => !key.startsWith('$category:'))
        .toSet();

    // Clear selection if the selected POI was in this category
    final shouldClearSelection =
        state.selectedPoi != null && state.selectedPoi!.category == category;

    state = state.copyWith(
      poisByCategory: updatedPoisByCategory,
      searchedGridCells: updatedSearchedCells,
      loadingCategories: state.loadingCategories
          .where((c) => c != category)
          .toSet(),
      clearSelectedPoi: shouldClearSelection,
    );
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    for (final token in _cancelTokens.values) {
      token.cancel();
    }
    super.dispose();
  }
}
