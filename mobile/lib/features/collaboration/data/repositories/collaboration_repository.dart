import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/api/api_client.dart';
import '../models/collaboration_model.dart';

final collaborationRepositoryProvider = Provider<CollaborationRepository>((ref) {
  return CollaborationRepository(ref.watch(apiClientProvider));
});

class CollaborationRepository {
  final ApiClient _client;

  CollaborationRepository(this._client);

  /// Fetch all collaborations for a stay
  Future<CollaborationsResponse> getCollaborations(int stayId) async {
    final response = await _client.get<Map<String, dynamic>>(
      '/api/v1/stays/$stayId/collaborations',
    );
    return CollaborationsResponse.fromJson(_convertKeys(response.data!));
  }

  /// Create a new collaboration (invite)
  Future<({Collaboration collaboration, String inviteUrl})> createCollaboration(
    int stayId,
    CollaborationRequest request,
  ) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/api/v1/stays/$stayId/collaborations',
      data: _toSnakeCase(request.toJson()),
    );

    final data = response.data!;
    return (
      collaboration: Collaboration.fromJson(_convertKeys(data['collaboration'] as Map<String, dynamic>)),
      inviteUrl: data['invite_url'] as String,
    );
  }

  /// Remove a collaboration
  Future<void> removeCollaboration(int stayId, int collaborationId) async {
    await _client.delete('/api/v1/stays/$stayId/collaborations/$collaborationId');
  }

  /// Leave a stay (for collaborators)
  Future<void> leaveStay(int stayId) async {
    await _client.delete('/api/v1/stays/$stayId/collaborations/leave');
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

  /// Convert camelCase to snake_case for API requests
  Map<String, dynamic> _toSnakeCase(Map<String, dynamic> json) {
    return json.map((key, value) {
      final newKey = _toSnakeCaseString(key);
      final newValue = value is Map<String, dynamic>
          ? _toSnakeCase(value)
          : value;
      return MapEntry(newKey, newValue);
    })..removeWhere((key, value) => value == null);
  }

  String _toCamelCase(String str) {
    final parts = str.split('_');
    if (parts.length == 1) return str;
    return parts.first +
        parts.skip(1).map((p) => p.isEmpty ? '' : '${p[0].toUpperCase()}${p.substring(1)}').join();
  }

  String _toSnakeCaseString(String str) {
    return str.replaceAllMapped(
      RegExp(r'[A-Z]'),
      (match) => '_${match.group(0)!.toLowerCase()}',
    );
  }
}
