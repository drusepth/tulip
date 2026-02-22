import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider for connectivity state
final connectivityProvider = StreamNotifierProvider<ConnectivityNotifier, ConnectivityState>(() {
  return ConnectivityNotifier();
});

/// Connectivity state
enum ConnectivityState {
  online,
  offline,
  unknown,
}

/// Notifier for connectivity changes
class ConnectivityNotifier extends StreamNotifier<ConnectivityState> {
  @override
  Stream<ConnectivityState> build() {
    // Initial check
    _checkConnectivity();

    // Listen for changes
    return Connectivity().onConnectivityChanged.map((result) {
      return _mapConnectivityResult(result);
    });
  }

  Future<void> _checkConnectivity() async {
    final result = await Connectivity().checkConnectivity();
    state = AsyncData(_mapConnectivityResult(result));
  }

  ConnectivityState _mapConnectivityResult(ConnectivityResult result) {
    switch (result) {
      case ConnectivityResult.wifi:
      case ConnectivityResult.mobile:
      case ConnectivityResult.ethernet:
        return ConnectivityState.online;
      case ConnectivityResult.none:
        return ConnectivityState.offline;
      default:
        return ConnectivityState.unknown;
    }
  }
}

/// Simple provider for checking if currently online
final isOnlineProvider = Provider<bool>((ref) {
  final connectivity = ref.watch(connectivityProvider);
  return connectivity.maybeWhen(
    data: (state) => state == ConnectivityState.online,
    orElse: () => true, // Assume online if unknown
  );
});
