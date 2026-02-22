import '../../../places/data/models/poi_model.dart';

/// State model for viewport-based POI loading on the map.
class ViewportPoiState {
  /// POIs organized by category
  final Map<String, List<Poi>> poisByCategory;

  /// Grid cells that have already been searched (to avoid duplicate requests)
  final Set<String> searchedGridCells;

  /// Categories currently being fetched
  final Set<String> loadingCategories;

  /// Currently selected POI (for showing popup)
  final Poi? selectedPoi;

  const ViewportPoiState({
    this.poisByCategory = const {},
    this.searchedGridCells = const {},
    this.loadingCategories = const {},
    this.selectedPoi,
  });

  /// Get all POIs for the given enabled categories
  List<Poi> poisForCategories(Set<String> categories) {
    final result = <Poi>[];
    for (final category in categories) {
      final pois = poisByCategory[category];
      if (pois != null) {
        result.addAll(pois);
      }
    }
    return result;
  }

  /// Check if any category is currently loading
  bool get isLoading => loadingCategories.isNotEmpty;

  /// Check if a specific category is loading
  bool isCategoryLoading(String category) => loadingCategories.contains(category);

  ViewportPoiState copyWith({
    Map<String, List<Poi>>? poisByCategory,
    Set<String>? searchedGridCells,
    Set<String>? loadingCategories,
    Poi? selectedPoi,
    bool clearSelectedPoi = false,
  }) {
    return ViewportPoiState(
      poisByCategory: poisByCategory ?? this.poisByCategory,
      searchedGridCells: searchedGridCells ?? this.searchedGridCells,
      loadingCategories: loadingCategories ?? this.loadingCategories,
      selectedPoi: clearSelectedPoi ? null : (selectedPoi ?? this.selectedPoi),
    );
  }
}
