import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/constants/tulip_colors.dart';
import '../../../../shared/constants/tulip_text_styles.dart';
import '../../data/models/collaboration_model.dart';
import '../providers/collaboration_provider.dart';

class CollaboratorsScreen extends ConsumerStatefulWidget {
  final int stayId;
  final String stayTitle;
  final bool isOwner;

  const CollaboratorsScreen({
    super.key,
    required this.stayId,
    required this.stayTitle,
    required this.isOwner,
  });

  @override
  ConsumerState<CollaboratorsScreen> createState() => _CollaboratorsScreenState();
}

class _CollaboratorsScreenState extends ConsumerState<CollaboratorsScreen> {
  @override
  Widget build(BuildContext context) {
    final collaborationsAsync = ref.watch(collaborationsProvider(widget.stayId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Collaborators'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          if (widget.isOwner)
            IconButton(
              icon: const Icon(Icons.person_add_outlined),
              onPressed: _showInviteDialog,
              tooltip: 'Invite',
            ),
        ],
      ),
      body: collaborationsAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: TulipColors.sage),
        ),
        error: (error, stack) => _buildErrorState(error),
        data: (response) => _buildCollaboratorList(response),
      ),
    );
  }

  Widget _buildErrorState(Object error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 48, color: TulipColors.roseDark),
          const SizedBox(height: 16),
          Text('Unable to load collaborators', style: TulipTextStyles.body),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => ref.read(collaborationsProvider(widget.stayId).notifier).refresh(),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildCollaboratorList(CollaborationsResponse response) {
    final all = [...response.accepted, ...response.pending];

    if (all.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(collaborationsProvider(widget.stayId).notifier).refresh(),
      color: TulipColors.sage,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Accepted collaborators
          if (response.accepted.isNotEmpty) ...[
            Text('Team', style: TulipTextStyles.label),
            const SizedBox(height: 8),
            ...response.accepted.map((c) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _CollaboratorTile(
                collaboration: c,
                isOwner: widget.isOwner,
                onRemove: widget.isOwner && c.role != 'owner'
                    ? () => _confirmRemove(c)
                    : null,
              ),
            )),
          ],

          // Pending invitations
          if (response.pending.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text('Pending Invitations', style: TulipTextStyles.label),
            const SizedBox(height: 8),
            ...response.pending.map((c) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _CollaboratorTile(
                collaboration: c,
                isOwner: widget.isOwner,
                isPending: true,
                onRemove: widget.isOwner
                    ? () => _confirmRemove(c)
                    : null,
                onCopyLink: () => _copyInviteLink(c),
              ),
            )),
          ],

          // Leave button for non-owners
          if (!widget.isOwner) ...[
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: _confirmLeave,
              icon: Icon(Icons.exit_to_app, color: TulipColors.roseDark),
              label: Text(
                'Leave Stay',
                style: TextStyle(color: TulipColors.roseDark),
              ),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: TulipColors.roseDark),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.people_outline,
            size: 64,
            color: TulipColors.brownLighter,
          ),
          const SizedBox(height: 16),
          Text(
            'No collaborators yet',
            style: TulipTextStyles.heading3,
          ),
          const SizedBox(height: 8),
          Text(
            'Invite others to plan together',
            style: TulipTextStyles.bodySmall,
          ),
          if (widget.isOwner) ...[
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _showInviteDialog,
              icon: const Icon(Icons.person_add),
              label: const Text('Invite'),
            ),
          ],
        ],
      ),
    );
  }

  void _showInviteDialog() {
    final emailController = TextEditingController();
    String selectedRole = 'editor';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Invite Collaborator'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email address',
                  hintText: 'friend@example.com',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              Text('Role', style: TulipTextStyles.label),
              const SizedBox(height: 8),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(
                    value: 'editor',
                    label: Text('Editor'),
                    icon: Icon(Icons.edit, size: 18),
                  ),
                  ButtonSegment(
                    value: 'viewer',
                    label: Text('Viewer'),
                    icon: Icon(Icons.visibility, size: 18),
                  ),
                ],
                selected: {selectedRole},
                onSelectionChanged: (roles) {
                  setState(() => selectedRole = roles.first);
                },
              ),
              const SizedBox(height: 8),
              Text(
                selectedRole == 'editor'
                    ? 'Can edit stays, bucket list, and comments'
                    : 'Can only view the stay',
                style: TulipTextStyles.caption,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                final email = emailController.text.trim();
                if (email.isEmpty || !email.contains('@')) return;

                Navigator.pop(context);
                await _invite(email, selectedRole);
              },
              child: const Text('Send Invite'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _invite(String email, String role) async {
    try {
      final inviteUrl = await ref.read(collaborationsProvider(widget.stayId).notifier).invite(
        CollaborationRequest(invitedEmail: email, role: role),
      );

      if (mounted && inviteUrl != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Invitation sent to $email'),
            backgroundColor: TulipColors.sage,
            action: SnackBarAction(
              label: 'Copy Link',
              textColor: Colors.white,
              onPressed: () {
                Clipboard.setData(ClipboardData(text: inviteUrl));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Link copied!')),
                );
              },
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send invitation: $e'),
            backgroundColor: TulipColors.roseDark,
          ),
        );
      }
    }
  }

  void _copyInviteLink(Collaboration collaboration) {
    // Construct the invite URL (would need to match your web app's URL pattern)
    final inviteUrl = 'https://tulip.app/invites/${collaboration.inviteToken}';
    Clipboard.setData(ClipboardData(text: inviteUrl));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Invite link copied!')),
    );
  }

  void _confirmRemove(Collaboration collaboration) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Collaborator'),
        content: Text(
          'Are you sure you want to remove ${collaboration.displayName} from this stay?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await ref.read(collaborationsProvider(widget.stayId).notifier).remove(
                  collaboration.id,
                );
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to remove: $e'),
                      backgroundColor: TulipColors.roseDark,
                    ),
                  );
                }
              }
            },
            style: TextButton.styleFrom(foregroundColor: TulipColors.roseDark),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }

  void _confirmLeave() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Leave Stay'),
        content: Text(
          'Are you sure you want to leave "${widget.stayTitle}"? You will no longer have access to this stay.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await ref.read(collaborationsProvider(widget.stayId).notifier).leave();
                if (mounted) {
                  context.pop(); // Go back from collaborators screen
                  context.pop(); // Go back from stay detail
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to leave: $e'),
                      backgroundColor: TulipColors.roseDark,
                    ),
                  );
                }
              }
            },
            style: TextButton.styleFrom(foregroundColor: TulipColors.roseDark),
            child: const Text('Leave'),
          ),
        ],
      ),
    );
  }
}

class _CollaboratorTile extends StatelessWidget {
  final Collaboration collaboration;
  final bool isOwner;
  final bool isPending;
  final VoidCallback? onRemove;
  final VoidCallback? onCopyLink;

  const _CollaboratorTile({
    required this.collaboration,
    required this.isOwner,
    this.isPending = false,
    this.onRemove,
    this.onCopyLink,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isPending ? TulipColors.lavenderLight : TulipColors.taupeLight,
        ),
      ),
      child: Row(
        children: [
          // Avatar
          _buildAvatar(),
          const SizedBox(width: 12),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      collaboration.displayName,
                      style: TulipTextStyles.label,
                    ),
                    if (isPending) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: TulipColors.lavenderLight,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'Pending',
                          style: TulipTextStyles.caption.copyWith(
                            color: TulipColors.lavenderDark,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '${collaboration.displayEmail} \u2022 ${collaboration.roleDisplay}',
                  style: TulipTextStyles.caption,
                ),
              ],
            ),
          ),

          // Actions
          if (isPending && onCopyLink != null)
            IconButton(
              icon: Icon(
                Icons.link,
                size: 20,
                color: TulipColors.brownLight,
              ),
              onPressed: onCopyLink,
              tooltip: 'Copy invite link',
            ),
          if (onRemove != null)
            IconButton(
              icon: Icon(
                Icons.close,
                size: 20,
                color: TulipColors.brownLight,
              ),
              onPressed: onRemove,
              tooltip: 'Remove',
            ),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    // Generate a consistent color based on name
    final colors = [
      TulipColors.sage,
      TulipColors.rose,
      TulipColors.lavender,
      TulipColors.coral,
      TulipColors.taupe,
    ];
    final colorIndex = collaboration.displayName.hashCode.abs() % colors.length;

    String initials = '?';
    final name = collaboration.displayName;
    if (name.contains('@')) {
      initials = name[0].toUpperCase();
    } else {
      final parts = name.split(' ');
      if (parts.length >= 2) {
        initials = '${parts.first[0]}${parts.last[0]}'.toUpperCase();
      } else if (name.isNotEmpty) {
        initials = name[0].toUpperCase();
      }
    }

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: isPending ? TulipColors.lavenderLight : colors[colorIndex],
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          initials,
          style: TextStyle(
            color: isPending ? TulipColors.lavenderDark : Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
