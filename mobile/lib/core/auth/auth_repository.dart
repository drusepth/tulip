import '../api/api_client.dart';
import '../api/endpoints.dart';
import 'secure_storage.dart';

class AuthRepository {
  final ApiClient _apiClient;
  final SecureStorage _secureStorage;

  AuthRepository(this._apiClient, this._secureStorage);

  Future<Map<String, dynamic>> signIn({
    required String email,
    required String password,
  }) async {
    final response = await _apiClient.post(
      Endpoints.signIn,
      data: {
        'email': email,
        'password': password,
      },
    );

    final data = response.data;
    await _secureStorage.saveTokens(
      accessToken: data['token'],
      refreshToken: data['refresh_token'],
    );

    return data;
  }

  Future<Map<String, dynamic>> signUp({
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    final response = await _apiClient.post(
      Endpoints.signUp,
      data: {
        'email': email,
        'password': password,
        'password_confirmation': passwordConfirmation,
      },
    );

    final data = response.data;
    await _secureStorage.saveTokens(
      accessToken: data['token'],
      refreshToken: data['refresh_token'],
    );

    return data;
  }

  Future<void> signOut() async {
    try {
      await _apiClient.post(Endpoints.revoke);
    } catch (e) {
      // Continue with local sign out even if server revoke fails
    }
    await _secureStorage.clearTokens();
  }

  Future<bool> isAuthenticated() async {
    return await _secureStorage.hasValidToken();
  }

  Future<String?> getAccessToken() async {
    return await _secureStorage.getAccessToken();
  }
}
