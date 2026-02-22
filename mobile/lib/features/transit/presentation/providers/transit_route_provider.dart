import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/transit_route_model.dart';
import '../../data/repositories/transit_route_repository.dart';

/// Provider for transit routes by stay and route type
final transitRoutesProvider = FutureProvider.family<List<TransitRoute>, TransitRouteQuery>(
  (ref, query) async {
    final repository = ref.watch(transitRouteRepositoryProvider);

    // First try to get cached routes
    var routes = await repository.getTransitRoutes(
      query.stayId,
      routeType: query.routeType,
    );

    // If no routes and we have a specific type, fetch from Overpass
    if (routes.isEmpty && query.routeType != null) {
      routes = await repository.fetchTransitRoutes(
        query.stayId,
        query.routeType!,
      );
    }

    return routes;
  },
);

/// Query parameters for transit routes
class TransitRouteQuery {
  final int stayId;
  final TransitRouteType? routeType;

  const TransitRouteQuery({
    required this.stayId,
    this.routeType,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TransitRouteQuery &&
        other.stayId == stayId &&
        other.routeType == routeType;
  }

  @override
  int get hashCode => Object.hash(stayId, routeType);
}

/// Provider for enabled transit layers on the map
final enabledTransitLayersProvider = StateProvider<Set<TransitRouteType>>((ref) {
  return {};
});

/// Toggle a transit layer on/off
void toggleTransitLayer(WidgetRef ref, TransitRouteType type) {
  final current = ref.read(enabledTransitLayersProvider);
  if (current.contains(type)) {
    ref.read(enabledTransitLayersProvider.notifier).state =
        Set.from(current)..remove(type);
  } else {
    ref.read(enabledTransitLayersProvider.notifier).state =
        Set.from(current)..add(type);
  }
}
