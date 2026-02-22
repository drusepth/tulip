import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/constants/tulip_colors.dart';
import '../../../../shared/constants/tulip_text_styles.dart';
import '../../data/models/comment_model.dart';
import '../providers/comments_provider.dart';
import 'comment_tile.dart';
import 'comment_form.dart';

/// Complete comment thread widget for stay detail
class CommentThread extends ConsumerStatefulWidget {
  final int stayId;

  const CommentThread({
    super.key,
    required this.stayId,
  });

  @override
  ConsumerState<CommentThread> createState() => _CommentThreadState();
}

class _CommentThreadState extends ConsumerState<CommentThread> {
  int? _replyingToId;

  @override
  Widget build(BuildContext context) {
    final commentsAsync = ref.watch(commentsProvider(widget.stayId));

    return commentsAsync.when(
      loading: () => const Center(
        child: CircularProgressIndicator(color: TulipColors.sage),
      ),
      error: (error, stack) => _buildErrorState(error),
      data: (comments) => _buildCommentList(comments),
    );
  }

  Widget _buildErrorState(Object error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 48, color: TulipColors.roseDark),
          const SizedBox(height: 16),
          Text('Unable to load comments', style: TulipTextStyles.body),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              error.toString(),
              style: TulipTextStyles.caption,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => ref.read(commentsProvider(widget.stayId).notifier).refresh(),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentList(List<Comment> comments) {
    final topLevelComments = ref.watch(topLevelCommentsProvider(widget.stayId));

    return RefreshIndicator(
      onRefresh: () => ref.read(commentsProvider(widget.stayId).notifier).refresh(),
      color: TulipColors.sage,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Comment form at top
          CommentForm(
            placeholder: 'Share your thoughts...',
            onSubmit: _addComment,
          ),
          const SizedBox(height: 20),

          // Comment count
          if (comments.isNotEmpty) ...[
            Row(
              children: [
                Icon(
                  Icons.forum_outlined,
                  size: 18,
                  color: TulipColors.brownLight,
                ),
                const SizedBox(width: 8),
                Text(
                  '${comments.length} ${comments.length == 1 ? 'comment' : 'comments'}',
                  style: TulipTextStyles.label.copyWith(
                    color: TulipColors.brownLight,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],

          // Comments
          if (topLevelComments.isEmpty)
            _buildEmptyState()
          else
            ...topLevelComments.map((comment) {
              final replies = ref.watch(commentRepliesProvider((
                stayId: widget.stayId,
                commentId: comment.id,
              )));

              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Column(
                  children: [
                    CommentTile(
                      comment: comment,
                      replies: replies,
                      onReply: () => setState(() => _replyingToId = comment.id),
                      onEdit: comment.editable
                          ? () => _showEditDialog(comment)
                          : null,
                      onDelete: comment.editable
                          ? () => _confirmDelete(comment)
                          : null,
                    ),
                    if (_replyingToId == comment.id)
                      ReplyForm(
                        replyingToName: comment.userName,
                        onSubmit: (text) => _replyToComment(comment.id, text),
                        onCancel: () => setState(() => _replyingToId = null),
                      ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          children: [
            Icon(
              Icons.chat_bubble_outline,
              size: 48,
              color: TulipColors.brownLighter,
            ),
            const SizedBox(height: 16),
            Text(
              'No comments yet',
              style: TulipTextStyles.heading3,
            ),
            const SizedBox(height: 8),
            Text(
              'Be the first to share your thoughts!',
              style: TulipTextStyles.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _addComment(String text) async {
    try {
      await ref.read(commentsProvider(widget.stayId).notifier).addComment(
        CommentRequest(body: text),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add comment: $e'),
            backgroundColor: TulipColors.roseDark,
          ),
        );
      }
    }
  }

  Future<void> _replyToComment(int parentId, String text) async {
    try {
      await ref.read(commentsProvider(widget.stayId).notifier).replyToComment(
        parentId,
        text,
      );
      setState(() => _replyingToId = null);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add reply: $e'),
            backgroundColor: TulipColors.roseDark,
          ),
        );
      }
    }
  }

  void _showEditDialog(Comment comment) {
    final controller = TextEditingController(text: comment.body);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Comment'),
        content: TextField(
          controller: controller,
          maxLines: 4,
          minLines: 2,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
          ),
          textCapitalization: TextCapitalization.sentences,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final text = controller.text.trim();
              if (text.isEmpty) return;

              Navigator.pop(context);
              try {
                await ref.read(commentsProvider(widget.stayId).notifier).updateComment(
                  comment.id,
                  text,
                );
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to update comment: $e'),
                      backgroundColor: TulipColors.roseDark,
                    ),
                  );
                }
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(Comment comment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Comment'),
        content: const Text('Are you sure you want to delete this comment?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await ref.read(commentsProvider(widget.stayId).notifier).deleteComment(
                  comment.id,
                );
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to delete comment: $e'),
                      backgroundColor: TulipColors.roseDark,
                    ),
                  );
                }
              }
            },
            style: TextButton.styleFrom(foregroundColor: TulipColors.roseDark),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
