import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'config/routes.dart';
import 'config/theme.dart';
import 'core/auth/auth_provider.dart';
import 'core/deep_links/deep_link_service.dart';
import 'core/push_notifications/push_notification_service.dart';

class TulipApp extends ConsumerStatefulWidget {
  const TulipApp({super.key});

  @override
  ConsumerState<TulipApp> createState() => _TulipAppState();
}

class _TulipAppState extends ConsumerState<TulipApp> {
  StreamSubscription<Uri>? _linkSubscription;
  bool _pushInitialized = false;

  @override
  void initState() {
    super.initState();
    _initDeepLinks();
  }

  Future<void> _initDeepLinks() async {
    final deepLinkService = ref.read(deepLinkServiceProvider);

    // Handle app launched via deep link
    final initialLink = await deepLinkService.getInitialLink();
    if (initialLink != null) {
      _handleDeepLink(initialLink);
    }

    // Handle deep links received while app is running
    _linkSubscription = deepLinkService.linkStream.listen(_handleDeepLink);
  }

  void _initPushNotifications() {
    if (_pushInitialized) return;
    _pushInitialized = true;

    final pushService = ref.read(pushNotificationServiceProvider);
    pushService.initialize(
      onNotificationTap: (path) {
        final router = ref.read(routerProvider);
        router.push(path);
      },
    );
  }

  void _handleDeepLink(Uri uri) {
    final router = ref.read(routerProvider);

    // Handle both https://tulip.app/invites/token and tulip://invites/token
    String path = uri.path;

    // For custom scheme tulip://invites/token, the path might be different
    if (uri.scheme == 'tulip' && uri.host == 'invites') {
      // tulip://invites/token -> /invites/token
      path = '/invites/${uri.pathSegments.isNotEmpty ? uri.pathSegments.first : uri.path}';
      if (path == '/invites/') {
        // Handle tulip://invites/token where token is in pathSegments
        final segments = uri.pathSegments;
        if (segments.isNotEmpty) {
          path = '/invites/${segments.first}';
        }
      }
    }

    // Route to invite acceptance screen
    if (path.startsWith('/invites/')) {
      router.go(path);
    }
  }

  @override
  void dispose() {
    _linkSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);
    final authState = ref.watch(authStateProvider);

    // Initialize push notifications once the user is authenticated
    if (authState.status == AuthStatus.authenticated) {
      _initPushNotifications();
    }

    return MaterialApp.router(
      title: 'Tulip',
      theme: tulipTheme(),
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
