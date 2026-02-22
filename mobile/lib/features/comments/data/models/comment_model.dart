import 'package:freezed_annotation/freezed_annotation.dart';

part 'comment_model.freezed.dart';
part 'comment_model.g.dart';

@freezed
class Comment with _$Comment {
  const Comment._();

  const factory Comment({
    required int id,
    required String body,
    int? parentId,
    required int userId,
    required String userName,
    required String userEmail,
    @Default(false) bool editable,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _Comment;

  factory Comment.fromJson(Map<String, dynamic> json) => _$CommentFromJson(json);

  /// Get the user's initials for avatar
  String get userInitials {
    final parts = userName.split(' ');
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return userName.isNotEmpty ? userName[0].toUpperCase() : '?';
  }

  /// Check if this is a reply to another comment
  bool get isReply => parentId != null;

  /// Format the created date
  String get timeAgo {
    final now = DateTime.now();
    final diff = now.difference(createdAt);

    if (diff.inDays > 365) {
      final years = (diff.inDays / 365).floor();
      return '${years}y ago';
    } else if (diff.inDays > 30) {
      final months = (diff.inDays / 30).floor();
      return '${months}mo ago';
    } else if (diff.inDays > 0) {
      return '${diff.inDays}d ago';
    } else if (diff.inHours > 0) {
      return '${diff.inHours}h ago';
    } else if (diff.inMinutes > 0) {
      return '${diff.inMinutes}m ago';
    } else {
      return 'just now';
    }
  }
}

/// Request model for creating/updating a comment
@freezed
class CommentRequest with _$CommentRequest {
  const factory CommentRequest({
    required String body,
    int? parentId,
  }) = _CommentRequest;

  factory CommentRequest.fromJson(Map<String, dynamic> json) =>
      _$CommentRequestFromJson(json);
}
