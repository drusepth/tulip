import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/constants/tulip_colors.dart';
import '../../../../shared/constants/tulip_text_styles.dart';
import '../../../../shared/widgets/tulip_button.dart';

class InviteAcceptScreen extends ConsumerStatefulWidget {
  final String token;

  const InviteAcceptScreen({super.key, required this.token});

  @override
  ConsumerState<InviteAcceptScreen> createState() => _InviteAcceptScreenState();
}

class _InviteAcceptScreenState extends ConsumerState<InviteAcceptScreen> {
  bool _isLoading = false;
  String? _error;

  Future<void> _acceptInvite() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    // TODO: Call API to accept invite
    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      _isLoading = false;
    });

    if (mounted) {
      // Navigate to the stay
      context.go('/');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.go('/'),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.group_add_outlined,
                size: 64,
                color: TulipColors.sage,
              ),
              const SizedBox(height: 24),
              Text(
                'Collaboration Invite',
                style: TulipTextStyles.heading2,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                "You've been invited to collaborate on a stay",
                style: TulipTextStyles.bodySmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              if (_error != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: TulipColors.roseLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _error!,
                    style: TulipTextStyles.bodySmall
                        .copyWith(color: TulipColors.roseDark),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 16),
              ],

              TulipButton(
                onPressed: _isLoading ? null : _acceptInvite,
                isLoading: _isLoading,
                label: 'Accept Invite',
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => context.go('/'),
                child: Text(
                  'Decline',
                  style: TulipTextStyles.body.copyWith(
                    color: TulipColors.brownLight,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
