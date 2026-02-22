import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/stay_model.dart';
import '../../data/repositories/stay_repository.dart';

/// Provider for the list of all stays
final staysProvider = AsyncNotifierProvider<StaysNotifier, List<Stay>>(() {
  return StaysNotifier();
});

class StaysNotifier extends AsyncNotifier<List<Stay>> {
  @override
  Future<List<Stay>> build() async {
    return _fetchStays();
  }

  Future<List<Stay>> _fetchStays() async {
    final repository = ref.read(stayRepositoryProvider);
    return repository.getStays();
  }

  /// Refresh the stays list
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchStays());
  }

  /// Add a new stay to the list (after creation)
  void addStay(Stay stay) {
    final currentStays = state.valueOrNull ?? [];
    state = AsyncValue.data([...currentStays, stay]);
  }

  /// Update a stay in the list
  void updateStay(Stay updatedStay) {
    final currentStays = state.valueOrNull ?? [];
    state = AsyncValue.data(
      currentStays.map((s) => s.id == updatedStay.id ? updatedStay : s).toList(),
    );
  }

  /// Remove a stay from the list
  void removeStay(int stayId) {
    final currentStays = state.valueOrNull ?? [];
    state = AsyncValue.data(
      currentStays.where((s) => s.id != stayId).toList(),
    );
  }
}

/// Provider for a single stay detail
final stayDetailProvider = FutureProvider.family<Stay, int>((ref, stayId) async {
  final repository = ref.read(stayRepositoryProvider);
  return repository.getStay(stayId);
});

/// Provider for weather data
final stayWeatherProvider = FutureProvider.family<Map<String, dynamic>, int>((ref, stayId) async {
  final repository = ref.read(stayRepositoryProvider);
  return repository.getWeather(stayId);
});

/// Computed provider for current stay
final currentStayProvider = Provider<Stay?>((ref) {
  final staysAsync = ref.watch(staysProvider);
  return staysAsync.whenOrNull(
    data: (stays) => stays.where((s) => s.isCurrent).firstOrNull,
  );
});

/// Computed provider for upcoming stays
final upcomingStaysProvider = Provider<List<Stay>>((ref) {
  final staysAsync = ref.watch(staysProvider);
  return staysAsync.whenOrNull(
    data: (stays) => stays.where((s) => s.isUpcoming).toList(),
  ) ?? [];
});

/// Computed provider for past stays
final pastStaysProvider = Provider<List<Stay>>((ref) {
  final staysAsync = ref.watch(staysProvider);
  return staysAsync.whenOrNull(
    data: (stays) => stays.where((s) => s.isPast).toList(),
  ) ?? [];
});

/// Provider for stay form operations
final stayFormProvider = StateNotifierProvider<StayFormNotifier, StayFormState>((ref) {
  final repository = ref.read(stayRepositoryProvider);
  final staysNotifier = ref.read(staysProvider.notifier);
  return StayFormNotifier(repository, staysNotifier);
});

class StayFormState {
  final bool isLoading;
  final String? error;
  final Stay? savedStay;

  const StayFormState({
    this.isLoading = false,
    this.error,
    this.savedStay,
  });

  StayFormState copyWith({
    bool? isLoading,
    String? error,
    Stay? savedStay,
  }) {
    return StayFormState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      savedStay: savedStay ?? this.savedStay,
    );
  }
}

class StayFormNotifier extends StateNotifier<StayFormState> {
  final StayRepository _repository;
  final StaysNotifier _staysNotifier;

  StayFormNotifier(this._repository, this._staysNotifier) : super(const StayFormState());

  Future<bool> createStay(StayRequest request) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final stay = await _repository.createStay(request);
      _staysNotifier.addStay(stay);
      state = state.copyWith(isLoading: false, savedStay: stay);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> updateStay(int id, StayRequest request) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final stay = await _repository.updateStay(id, request);
      _staysNotifier.updateStay(stay);
      state = state.copyWith(isLoading: false, savedStay: stay);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> deleteStay(int id) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _repository.deleteStay(id);
      _staysNotifier.removeStay(id);
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  void reset() {
    state = const StayFormState();
  }
}
