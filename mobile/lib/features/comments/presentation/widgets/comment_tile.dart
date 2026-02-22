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
      padding: EdgeInsets.all(isCompact ? 12 : 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: isCompact
            ? null
            : [
                BoxShadow(
                  color: TulipColors.taupe.withValues(alpha: 0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: avatar, name, time, menu
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildAvatar(),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          comment.userName,
                          style: TulipTextStyles.label.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          comment.timeAgo,
                          style: TulipTextStyles.caption.copyWith(
                            color: TulipColors.brownLighter,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    // Body
                    Text(
                      comment.body,
                      style: isCompact
                          ? TulipTextStyles.bodySmall
                          : TulipTextStyles.body,
                    ),
                  ],
                ),
              ),
              if (comment.editable)
                PopupMenuButton<String>(
                  icon: Icon(
                    Icons.more_horiz_rounded,
                    size: 20,
                    color: TulipColors.brownLighter,
                  ),
                  padding: EdgeInsets.zero,
                  splashRadius: 20,
                  onSelected: (value) {
                    if (value == 'edit') onEdit?.call();
                    if (value == 'delete') onDelete?.call();
                  },
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit_outlined, size: 18, color: TulipColors.brownLight),
                          const SizedBox(width: 10),
                          Text('Edit', style: TulipTextStyles.body),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete_outline, size: 18, color: TulipColors.roseDark),
                          const SizedBox(width: 10),
                          Text('Delete', style: TulipTextStyles.body.copyWith(color: TulipColors.roseDark)),
                        ],
                      ),
                    ),
                  ],
                ),
            ],
          ),

          // Actions: reply
          if (!isCompact && onReply != null) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                const SizedBox(width: 48), // Align with text content
                InkWell(
                  onTap: onReply,
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.reply_rounded,
                          size: 16,
                          color: TulipColors.sage,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Reply',
                          style: TulipTextStyles.bodySmall.copyWith(
                            color: TulipColors.sage,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (replies.isNotEmpty) ...[
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: TulipColors.lavenderLight,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${replies.length} ${replies.length == 1 ? 'reply' : 'replies'}',
                      style: TulipTextStyles.caption.copyWith(
                        color: TulipColors.lavenderDark,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],

          // Inline replies (for non-compact view)
          if (!isCompact && replies.isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(
              margin: const EdgeInsets.only(left: 24),
              padding: const EdgeInsets.only(left: 16),
              decoration: BoxDecoration(
                border: Border(
                  left: BorderSide(
                    color: TulipColors.sageLight,
                    width: 2,
                  ),
                ),
              ),
              child: Column(
                children: replies.map((reply) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: CommentTile(
                    comment: reply,
                    isCompact: true,
                    onEdit: reply.editable ? onEdit : null,
                    onDelete: reply.editable ? onDelete : null,
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
      width: isCompact ? 32 : 40,
      height: isCompact ? 32 : 40,
      decoration: BoxDecoration(
        color: colors[colorIndex],
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          comment.userInitials,
          style: TextStyle(
            color: Colors.white,
            fontSize: isCompact ? 11 : 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
