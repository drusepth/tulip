import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/explored_repository.dart';

final exploredDataProvider = FutureProvider<ExploredData>((ref) async {
  final repository = ref.watch(exploredRepositoryProvider);
  return repository.getScratchMapData();
});
