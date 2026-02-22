import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/collaboration_model.dart';
import '../../data/repositories/collaboration_repository.dart';

/// Provider for collaborations on a stay
final collaborationsProvider = AsyncNotifierProvider.family<CollaborationsNotifier, CollaborationsResponse, int>(() {
  return CollaborationsNotifier();
});

class CollaborationsNotifier extends FamilyAsyncNotifier<CollaborationsResponse, int> {
  @override
  Future<CollaborationsResponse> build(int stayId) async {
    return _fetchCollaborations(stayId);
  }

  Future<CollaborationsResponse> _fetchCollaborations(int stayId) async {
    final repository = ref.read(collaborationRepositoryProvider);
    return repository.getCollaborations(stayId);
  }

  /// Refresh collaborations from server
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchCollaborations(arg));
  }

  /// Invite a new collaborator
  Future<String?> invite(CollaborationRequest request) async {
    final repository = ref.read(collaborationRepositoryProvider);
    try {
      final result = await repository.createCollaboration(arg, request);
      final current = state.valueOrNull;
      if (current != null) {
        state = AsyncValue.data(CollaborationsResponse(
          pending: [...current.pending, result.collaboration],
          accepted: current.accepted,
        ));
      }
      return result.inviteUrl;
    } catch (e) {
      rethrow;
    }
  }

  /// Remove a collaborator
  Future<void> remove(int collaborationId) async {
    final repository = ref.read(collaborationRepositoryProvider);
    try {
      await repository.removeCollaboration(arg, collaborationId);
      final current = state.valueOrNull;
      if (current != null) {
        state = AsyncValue.data(CollaborationsResponse(
          pending: current.pending.where((c) => c.id != collaborationId).toList(),
          accepted: current.accepted.where((c) => c.id != collaborationId).toList(),
        ));
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Leave the stay (for collaborators)
  Future<void> leave() async {
    final repository = ref.read(collaborationRepositoryProvider);
    await repository.leaveStay(arg);
  }
}

/// Provider for all collaborators (pending + accepted)
final allCollaboratorsProvider = Provider.family<List<Collaboration>, int>((ref, stayId) {
  final response = ref.watch(collaborationsProvider(stayId));
  return response.whenOrNull(
    data: (data) => [...data.accepted, ...data.pending],
  ) ?? [];
});

/// Provider for collaborator count
final collaboratorCountProvider = Provider.family<int, int>((ref, stayId) {
  final collaborators = ref.watch(allCollaboratorsProvider(stayId));
  return collaborators.length;
});
