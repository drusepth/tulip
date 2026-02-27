import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../api/api_client.dart';
import '../api/endpoints.dart';

/// Handles background FCM messages (must be top-level function)
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  // Background messages are handled by the system notification tray automatically
}

final pushNotificationServiceProvider = Provider<PushNotificationService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return PushNotificationService(apiClient);
});

class PushNotificationService {
  final ApiClient _apiClient;
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  PushNotificationService(this._apiClient);

  /// Initialize push notifications: request permissions, get token, set up listeners
  Future<void> initialize({required void Function(String path) onNotificationTap}) async {
    // Request notification permissions (required for iOS, good practice for Android 13+)
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.denied) {
      return;
    }

    // Register the background handler
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    // Get and register the FCM token
    final token = await _messaging.getToken();
    if (token != null) {
      await _registerDeviceToken(token);
    }

    // Listen for token refreshes
    _messaging.onTokenRefresh.listen(_registerDeviceToken);

    // Handle foreground messages (show a local notification or in-app banner)
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      // Foreground notifications are handled by the notification badge refresh
      // The in-app notification list will update on next fetch
    });

    // Handle notification tap when app is in background (not terminated)
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      final targetPath = message.data['target_path'];
      if (targetPath != null) {
        onNotificationTap(targetPath);
      }
    });

    // Handle notification tap that launched the app from terminated state
    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      final targetPath = initialMessage.data['target_path'];
      if (targetPath != null) {
        // Small delay to ensure router is ready
        Future.delayed(const Duration(milliseconds: 500), () {
          onNotificationTap(targetPath);
        });
      }
    }
  }

  /// Register FCM device token with the backend
  Future<void> _registerDeviceToken(String token) async {
    try {
      final platform = Platform.isIOS ? 'ios' : 'android';
      await _apiClient.post(
        Endpoints.deviceTokens,
        data: {
          'token': token,
          'platform': platform,
        },
      );
    } catch (e) {
      // Silently fail - token registration will be retried on next app launch
    }
  }

  /// Unregister the current device token (e.g., on logout)
  Future<void> unregisterToken() async {
    try {
      final token = await _messaging.getToken();
      if (token != null) {
        await _apiClient.delete(
          Endpoints.deviceTokens,
          data: {'token': token},
        );
      }
    } catch (e) {
      // Silently fail
    }
  }
}
