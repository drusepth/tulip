import 'package:flutter/material.dart';
import '../../../../shared/constants/tulip_colors.dart';
import '../../../../shared/constants/tulip_text_styles.dart';
import '../../data/models/comment_model.dart';

/// A single comment tile
class CommentTile extends StatelessWidget {
  final Comment comment;
  final List<Comment> replies;
  final VoidCallback? onReply;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final ValueChanged<int>? onViewReplies;
  final bool isCompact;

  const CommentTile({
    super.key,
    required this.comment,
    this.replies = const [],
    this.onReply,
    this.onEdit,
    this.onDelete,
    this.onViewReplies,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(isCompact ? 8 : 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: TulipColors.taupeLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: avatar, name, time
          Row(
            children: [
              _buildAvatar(),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      comment.userName,
                      style: TulipTextStyles.label,
                    ),
                    Text(
                      comment.timeAgo,
                      style: TulipTextStyles.caption,
                    ),
                  ],
                ),
              ),
              if (comment.editable)
                PopupMenuButton<String>(
                  icon: Icon(
                    Icons.more_vert,
                    size: 18,
                    color: TulipColors.brownLight,
                  ),
                  onSelected: (value) {
                    if (value == 'edit') onEdit?.call();
                    if (value == 'delete') onDelete?.call();
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, size: 18),
                          SizedBox(width: 8),
                          Text('Edit'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, size: 18, color: TulipColors.roseDark),
                          const SizedBox(width: 8),
                          Text('Delete', style: TextStyle(color: TulipColors.roseDark)),
                        ],
                      ),
                    ),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 8),

          // Body
          Text(
            comment.body,
            style: TulipTextStyles.body,
          ),
          const SizedBox(height: 8),

          // Actions: reply, view replies
          Row(
            children: [
              if (onReply != null)
                GestureDetector(
                  onTap: onReply,
                  child: Row(
                    children: [
                      Icon(
                        Icons.reply,
                        size: 16,
                        color: TulipColors.sage,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Reply',
                        style: TulipTextStyles.caption.copyWith(
                          color: TulipColors.sage,
                        ),
                      ),
                    ],
                  ),
                ),
              if (replies.isNotEmpty) ...[
                const SizedBox(width: 16),
                GestureDetector(
                  onTap: () => onViewReplies?.call(comment.id),
                  child: Text(
                    '${replies.length} ${replies.length == 1 ? 'reply' : 'replies'}',
                    style: TulipTextStyles.caption.copyWith(
                      color: TulipColors.lavenderDark,
                    ),
                  ),
                ),
              ],
            ],
          ),

          // Inline replies (for non-compact view)
          if (!isCompact && replies.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              margin: const EdgeInsets.only(left: 24),
              padding: const EdgeInsets.only(left: 12),
              decoration: BoxDecoration(
                border: Border(
                  left: BorderSide(
                    color: TulipColors.taupeLight,
                    width: 2,
                  ),
                ),
              ),
              child: Column(
                children: replies.map((reply) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: CommentTile(
                    comment: reply,
                    isCompact: true,
                    onEdit: onEdit,
                    onDelete: onDelete,
                  ),
                )).toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    // Generate a consistent color based on user name
    final colors = [
      TulipColors.sage,
      TulipColors.rose,
      TulipColors.lavender,
      TulipColors.coral,
      TulipColors.taupe,
    ];
    final colorIndex = comment.userName.hashCode.abs() % colors.length;

    return Container(
      width: isCompact ? 28 : 36,
      height: isCompact ? 28 : 36,
      decoration: BoxDecoration(
        color: colors[colorIndex],
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          comment.userInitials,
          style: TextStyle(
            color: Colors.white,
            fontSize: isCompact ? 10 : 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
