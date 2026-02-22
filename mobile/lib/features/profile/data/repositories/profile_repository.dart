import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/api/endpoints.dart';
import '../models/user_profile_model.dart';

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return ProfileRepository(apiClient);
});

class ProfileRepository {
  final ApiClient _apiClient;

  ProfileRepository(this._apiClient);

  /// Fetch the current user's profile
  Future<UserProfile> getProfile() async {
    final response = await _apiClient.get<Map<String, dynamic>>(Endpoints.profile);
    final data = response.data ?? {};
    return UserProfile.fromJson(_convertKeys(data));
  }

  /// Update the user's profile (display name, email)
  Future<UserProfile> updateProfile(UpdateProfileRequest request) async {
    final response = await _apiClient.patch<Map<String, dynamic>>(
      Endpoints.profile,
      data: _toSnakeCase({
        if (request.displayName != null) 'displayName': request.displayName,
        if (request.email != null) 'email': request.email,
      }),
    );
    final data = response.data ?? {};
    return UserProfile.fromJson(_convertKeys(data));
  }

  /// Change the user's password
  Future<void> changePassword(ChangePasswordRequest request) async {
    await _apiClient.patch(
      Endpoints.profilePassword,
      data: _toSnakeCase({
        'currentPassword': request.currentPassword,
        'password': request.password,
        'passwordConfirmation': request.passwordConfirmation,
      }),
    );
  }

  /// Delete the user's account
  Future<void> deleteAccount(String currentPassword) async {
    await _apiClient.delete(
      Endpoints.profile,
      data: {'current_password': currentPassword},
    );
  }

  /// Convert snake_case keys to camelCase
  Map<String, dynamic> _convertKeys(Map<String, dynamic> json) {
    return json.map((key, value) {
      final newKey = _toCamelCase(key);
      final newValue = value is Map<String, dynamic>
          ? _convertKeys(value)
          : value is List
              ? value.map((e) => e is Map<String, dynamic> ? _convertKeys(e) : e).toList()
              : value;
      return MapEntry(newKey, newValue);
    });
  }

  String _toCamelCase(String str) {
    final parts = str.split('_');
    if (parts.length == 1) return str;
    return parts.first +
        parts.skip(1).map((p) => p.isEmpty ? '' : '${p[0].toUpperCase()}${p.substring(1)}').join();
  }

  /// Convert camelCase map to snake_case for API requests
  Map<String, dynamic> _toSnakeCase(Map<String, dynamic> map) {
    return map.map((key, value) {
      final snakeKey = key.replaceAllMapped(
        RegExp(r'[A-Z]'),
        (match) => '_${match.group(0)!.toLowerCase()}',
      );
      return MapEntry(snakeKey, value);
    });
  }
}
