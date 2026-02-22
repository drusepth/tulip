import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/comment_model.dart';
import '../../data/repositories/comment_repository.dart';

/// Provider for comments on a stay
final commentsProvider = AsyncNotifierProvider.family<CommentsNotifier, List<Comment>, int>(() {
  return CommentsNotifier();
});

class CommentsNotifier extends FamilyAsyncNotifier<List<Comment>, int> {
  @override
  Future<List<Comment>> build(int stayId) async {
    return _fetchComments(stayId);
  }

  Future<List<Comment>> _fetchComments(int stayId) async {
    final repository = ref.read(commentRepositoryProvider);
    return repository.getCommentsForStay(stayId);
  }

  /// Refresh comments from server
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchComments(arg));
  }

  /// Add a new comment
  Future<void> addComment(CommentRequest request) async {
    final repository = ref.read(commentRepositoryProvider);
    try {
      final newComment = await repository.createComment(arg, request);
      final currentComments = state.valueOrNull ?? [];
      state = AsyncValue.data([...currentComments, newComment]);
    } catch (e) {
      // Rethrow so the UI can handle it
      rethrow;
    }
  }

  /// Reply to a comment
  Future<void> replyToComment(int parentId, String body) async {
    final request = CommentRequest(body: body, parentId: parentId);
    await addComment(request);
  }

  /// Update a comment
  Future<void> updateComment(int commentId, String body) async {
    final repository = ref.read(commentRepositoryProvider);
    try {
      final request = CommentRequest(body: body);
      final updatedComment = await repository.updateComment(commentId, request);
      final currentComments = state.valueOrNull ?? [];
      state = AsyncValue.data(
        currentComments.map((c) => c.id == commentId ? updatedComment : c).toList(),
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Delete a comment
  Future<void> deleteComment(int commentId) async {
    final repository = ref.read(commentRepositoryProvider);
    try {
      await repository.deleteComment(commentId);
      final currentComments = state.valueOrNull ?? [];
      state = AsyncValue.data(
        currentComments.where((c) => c.id != commentId).toList(),
      );
    } catch (e) {
      rethrow;
    }
  }
}

/// Provider for grouped comments (top-level and replies)
final groupedCommentsProvider = Provider.family<Map<int?, List<Comment>>, int>((ref, stayId) {
  final commentsAsync = ref.watch(commentsProvider(stayId));
  final comments = commentsAsync.valueOrNull ?? [];

  // Group comments by parent_id
  final grouped = <int?, List<Comment>>{};
  for (final comment in comments) {
    final parentId = comment.parentId;
    grouped.putIfAbsent(parentId, () => []).add(comment);
  }

  return grouped;
});

/// Provider for top-level comments
final topLevelCommentsProvider = Provider.family<List<Comment>, int>((ref, stayId) {
  final grouped = ref.watch(groupedCommentsProvider(stayId));
  return grouped[null] ?? [];
});

/// Provider for replies to a specific comment
final commentRepliesProvider = Provider.family<List<Comment>, ({int stayId, int commentId})>((ref, params) {
  final grouped = ref.watch(groupedCommentsProvider(params.stayId));
  return grouped[params.commentId] ?? [];
});
