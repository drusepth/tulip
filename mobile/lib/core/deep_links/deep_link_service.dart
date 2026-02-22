import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final deepLinkServiceProvider = Provider<DeepLinkService>((ref) {
  return DeepLinkService();
});

class DeepLinkService {
  final AppLinks _appLinks = AppLinks();

  /// Get the initial deep link if app was launched via a link
  Future<Uri?> getInitialLink() => _appLinks.getInitialAppLink();

  /// Stream of deep links received while the app is running
  Stream<Uri> get linkStream => _appLinks.uriLinkStream;
}
