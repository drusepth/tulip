import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  static const _accessTokenKey = 'access_token';
  static const _refreshTokenKey = 'refresh_token';
  static const _tokenExpiresAtKey = 'token_expires_at';

  final FlutterSecureStorage _storage;

  SecureStorage({FlutterSecureStorage? storage})
      : _storage = storage ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(encryptedSharedPreferences: true),
              iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
            );

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
    DateTime? expiresAt,
  }) async {
    await Future.wait([
      _storage.write(key: _accessTokenKey, value: accessToken),
      _storage.write(key: _refreshTokenKey, value: refreshToken),
      if (expiresAt != null)
        _storage.write(
          key: _tokenExpiresAtKey,
          value: expiresAt.toIso8601String(),
        ),
    ]);
  }

  Future<String?> getAccessToken() async {
    return _storage.read(key: _accessTokenKey);
  }

  Future<String?> getRefreshToken() async {
    return _storage.read(key: _refreshTokenKey);
  }

  Future<DateTime?> getTokenExpiresAt() async {
    final expiresAtString = await _storage.read(key: _tokenExpiresAtKey);
    if (expiresAtString == null) return null;
    return DateTime.tryParse(expiresAtString);
  }

  Future<bool> hasValidToken() async {
    final accessToken = await getAccessToken();
    if (accessToken == null) return false;

    final expiresAt = await getTokenExpiresAt();
    if (expiresAt == null) return true; // Assume valid if no expiry set

    return DateTime.now().isBefore(expiresAt);
  }

  Future<void> clearTokens() async {
    await Future.wait([
      _storage.delete(key: _accessTokenKey),
      _storage.delete(key: _refreshTokenKey),
      _storage.delete(key: _tokenExpiresAtKey),
    ]);
  }

  Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}
