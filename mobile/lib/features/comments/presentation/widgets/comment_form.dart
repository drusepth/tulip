import 'package:flutter/material.dart';
import '../../../../shared/constants/tulip_colors.dart';
import '../../../../shared/constants/tulip_text_styles.dart';

/// Comment input form
class CommentForm extends StatefulWidget {
  final String? placeholder;
  final String? initialText;
  final bool autofocus;
  final ValueChanged<String> onSubmit;
  final VoidCallback? onCancel;

  const CommentForm({
    super.key,
    this.placeholder,
    this.initialText,
    this.autofocus = false,
    required this.onSubmit,
    this.onCancel,
  });

  @override
  State<CommentForm> createState() => _CommentFormState();
}

class _CommentFormState extends State<CommentForm> {
  late TextEditingController _controller;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialText);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() => _isSubmitting = true);
    widget.onSubmit(text);
    _controller.clear();
    setState(() => _isSubmitting = false);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: TulipColors.taupeLight),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              autofocus: widget.autofocus,
              maxLines: 4,
              minLines: 1,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                hintText: widget.placeholder ?? 'Write a comment...',
                hintStyle: TulipTextStyles.bodySmall.copyWith(
                  color: TulipColors.brownLighter,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                isDense: true,
              ),
              style: TulipTextStyles.body,
            ),
          ),
          const SizedBox(width: 8),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.onCancel != null)
                IconButton(
                  icon: Icon(
                    Icons.close,
                    color: TulipColors.brownLight,
                    size: 20,
                  ),
                  onPressed: widget.onCancel,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 32,
                    minHeight: 32,
                  ),
                ),
              IconButton(
                icon: _isSubmitting
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: TulipColors.sage,
                        ),
                      )
                    : Icon(
                        Icons.send,
                        color: TulipColors.sage,
                        size: 20,
                      ),
                onPressed: _isSubmitting ? null : _submit,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(
                  minWidth: 32,
                  minHeight: 32,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Inline reply form that appears under a comment
class ReplyForm extends StatefulWidget {
  final String replyingToName;
  final ValueChanged<String> onSubmit;
  final VoidCallback onCancel;

  const ReplyForm({
    super.key,
    required this.replyingToName,
    required this.onSubmit,
    required this.onCancel,
  });

  @override
  State<ReplyForm> createState() => _ReplyFormState();
}

class _ReplyFormState extends State<ReplyForm> {
  final _controller = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() => _isSubmitting = true);
    widget.onSubmit(text);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 24, top: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: TulipColors.cream,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: TulipColors.taupeLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.reply,
                size: 14,
                color: TulipColors.brownLight,
              ),
              const SizedBox(width: 4),
              Text(
                'Replying to ${widget.replyingToName}',
                style: TulipTextStyles.caption,
              ),
              const Spacer(),
              GestureDetector(
                onTap: widget.onCancel,
                child: Icon(
                  Icons.close,
                  size: 16,
                  color: TulipColors.brownLight,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  autofocus: true,
                  maxLines: 3,
                  minLines: 1,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(
                    hintText: 'Write a reply...',
                    hintStyle: TulipTextStyles.bodySmall.copyWith(
                      color: TulipColors.brownLighter,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                    isDense: true,
                  ),
                  style: TulipTextStyles.bodySmall,
                ),
              ),
              IconButton(
                icon: _isSubmitting
                    ? SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: TulipColors.sage,
                        ),
                      )
                    : Icon(
                        Icons.send,
                        color: TulipColors.sage,
                        size: 18,
                      ),
                onPressed: _isSubmitting ? null : _submit,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(
                  minWidth: 28,
                  minHeight: 28,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
