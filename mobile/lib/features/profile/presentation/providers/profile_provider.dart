import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/user_profile_model.dart';
import '../../data/repositories/profile_repository.dart';

/// Provider for the user's profile data
final profileProvider = AsyncNotifierProvider<ProfileNotifier, UserProfile>(() {
  return ProfileNotifier();
});

class ProfileNotifier extends AsyncNotifier<UserProfile> {
  @override
  Future<UserProfile> build() async {
    return _fetchProfile();
  }

  Future<UserProfile> _fetchProfile() async {
    final repository = ref.read(profileRepositoryProvider);
    return repository.getProfile();
  }

  /// Refresh the profile data
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchProfile());
  }

  /// Update the profile and refresh local state
  Future<void> updateProfile(UserProfile updatedProfile) async {
    state = AsyncValue.data(updatedProfile);
  }
}

/// State for profile form operations
class ProfileFormState {
  final bool isLoading;
  final String? error;
  final String? successMessage;

  const ProfileFormState({
    this.isLoading = false,
    this.error,
    this.successMessage,
  });

  ProfileFormState copyWith({
    bool? isLoading,
    String? error,
    String? successMessage,
  }) {
    return ProfileFormState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      successMessage: successMessage,
    );
  }
}

/// Provider for profile form submission state
final profileFormProvider = StateNotifierProvider<ProfileFormNotifier, ProfileFormState>((ref) {
  final repository = ref.read(profileRepositoryProvider);
  final profileNotifier = ref.read(profileProvider.notifier);
  return ProfileFormNotifier(repository, profileNotifier);
});

class ProfileFormNotifier extends StateNotifier<ProfileFormState> {
  final ProfileRepository _repository;
  final ProfileNotifier _profileNotifier;

  ProfileFormNotifier(this._repository, this._profileNotifier) : super(const ProfileFormState());

  /// Update the user's profile
  Future<bool> updateProfile(UpdateProfileRequest request) async {
    state = state.copyWith(isLoading: true, error: null, successMessage: null);
    try {
      final updatedProfile = await _repository.updateProfile(request);
      _profileNotifier.updateProfile(updatedProfile);
      state = state.copyWith(isLoading: false, successMessage: 'Profile updated successfully');
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  /// Change the user's password
  Future<bool> changePassword(ChangePasswordRequest request) async {
    state = state.copyWith(isLoading: true, error: null, successMessage: null);
    try {
      await _repository.changePassword(request);
      state = state.copyWith(isLoading: false, successMessage: 'Password changed successfully');
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  /// Delete the user's account
  Future<bool> deleteAccount(String currentPassword) async {
    state = state.copyWith(isLoading: true, error: null, successMessage: null);
    try {
      await _repository.deleteAccount(currentPassword);
      state = state.copyWith(isLoading: false, successMessage: 'Account deleted successfully');
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  void clearMessages() {
    state = state.copyWith(error: null, successMessage: null);
  }

  void reset() {
    state = const ProfileFormState();
  }
}
