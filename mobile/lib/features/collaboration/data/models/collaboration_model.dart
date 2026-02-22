import 'package:freezed_annotation/freezed_annotation.dart';

part 'collaboration_model.freezed.dart';
part 'collaboration_model.g.dart';

@freezed
class Collaboration with _$Collaboration {
  const Collaboration._();

  const factory Collaboration({
    required int id,
    required String role,
    String? invitedEmail,
    @Default(false) bool inviteAccepted,
    String? inviteToken,
    CollaboratorUser? user,
    required DateTime createdAt,
  }) = _Collaboration;

  factory Collaboration.fromJson(Map<String, dynamic> json) =>
      _$CollaborationFromJson(json);

  /// Display name for the collaboration
  String get displayName {
    if (user != null) return user!.name;
    return invitedEmail ?? 'Unknown';
  }

  /// Display email
  String get displayEmail {
    return user?.email ?? invitedEmail ?? '';
  }

  /// Role display name
  String get roleDisplay {
    switch (role) {
      case 'owner':
        return 'Owner';
      case 'editor':
        return 'Editor';
      case 'viewer':
        return 'Viewer';
      default:
        return role;
    }
  }

  /// Check if this is a pending invitation
  bool get isPending => !inviteAccepted;

  /// Check if the collaborator can edit
  bool get canEdit => role == 'owner' || role == 'editor';
}

@freezed
class CollaboratorUser with _$CollaboratorUser {
  const factory CollaboratorUser({
    required int id,
    required String name,
    required String email,
  }) = _CollaboratorUser;

  factory CollaboratorUser.fromJson(Map<String, dynamic> json) =>
      _$CollaboratorUserFromJson(json);
}

/// Response from collaborations API
@freezed
class CollaborationsResponse with _$CollaborationsResponse {
  const factory CollaborationsResponse({
    @Default([]) List<Collaboration> pending,
    @Default([]) List<Collaboration> accepted,
  }) = _CollaborationsResponse;

  factory CollaborationsResponse.fromJson(Map<String, dynamic> json) =>
      _$CollaborationsResponseFromJson(json);
}

/// Request to create a new collaboration
@freezed
class CollaborationRequest with _$CollaborationRequest {
  const factory CollaborationRequest({
    required String invitedEmail,
    @Default('editor') String role,
  }) = _CollaborationRequest;

  factory CollaborationRequest.fromJson(Map<String, dynamic> json) =>
      _$CollaborationRequestFromJson(json);
}
