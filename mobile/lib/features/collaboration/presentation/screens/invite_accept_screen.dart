import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/api/api_client.dart';
import '../../../../shared/constants/tulip_colors.dart';
import '../../../../shared/constants/tulip_text_styles.dart';
import '../../../../shared/widgets/tulip_button.dart';

/// Provider for invite acceptance
final inviteAcceptProvider = FutureProvider.family<InviteAcceptResult, String>((ref, token) async {
  final client = ref.watch(apiClientProvider);
  final response = await client.post<Map<String, dynamic>>(
    '/api/v1/invites/$token/accept',
  );

  final data = response.data!;
  return InviteAcceptResult(
    message: data['message'] as String,
    stayId: data['stay_id'] as int,
    stayTitle: (data['stay'] as Map<String, dynamic>?)?['title'] as String?,
    stayCity: (data['stay'] as Map<String, dynamic>?)?['city'] as String?,
  );
});

class InviteAcceptResult {
  final String message;
  final int stayId;
  final String? stayTitle;
  final String? stayCity;

  InviteAcceptResult({
    required this.message,
    required this.stayId,
    this.stayTitle,
    this.stayCity,
  });
}

class InviteAcceptScreen extends ConsumerStatefulWidget {
  final String token;

  const InviteAcceptScreen({super.key, required this.token});

  @override
  ConsumerState<InviteAcceptScreen> createState() => _InviteAcceptScreenState();
}

class _InviteAcceptScreenState extends ConsumerState<InviteAcceptScreen> {
  bool _hasAccepted = false;
  bool _isAccepting = false;
  String? _error;
  InviteAcceptResult? _result;

  Future<void> _acceptInvite() async {
    setState(() {
      _isAccepting = true;
      _error = null;
    });

    try {
      final client = ref.read(apiClientProvider);
      final response = await client.post<Map<String, dynamic>>(
        '/api/v1/invites/${widget.token}/accept',
      );

      final data = response.data!;
      _result = InviteAcceptResult(
        message: data['message'] as String,
        stayId: data['stay_id'] as int,
        stayTitle: (data['stay'] as Map<String, dynamic>?)?['title'] as String?,
        stayCity: (data['stay'] as Map<String, dynamic>?)?['city'] as String?,
      );

      setState(() {
        _hasAccepted = true;
        _isAccepting = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isAccepting = false;
      });
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
          child: _hasAccepted
              ? _buildSuccessState()
              : _buildAcceptPrompt(),
        ),
      ),
    );
  }

  Widget _buildAcceptPrompt() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: TulipColors.sageLight,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.group_add_outlined,
            size: 48,
            color: TulipColors.sageDark,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Collaboration Invite',
          style: TulipTextStyles.heading2,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          "You've been invited to collaborate on a travel stay",
          style: TulipTextStyles.bodySmall,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'Accept the invite to view and edit the stay together.',
          style: TulipTextStyles.body,
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
            child: Row(
              children: [
                Icon(
                  Icons.error_outline,
                  size: 20,
                  color: TulipColors.roseDark,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _error!,
                    style: TulipTextStyles.bodySmall.copyWith(
                      color: TulipColors.roseDark,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],

        TulipButton(
          onPressed: _isAccepting ? null : _acceptInvite,
          isLoading: _isAccepting,
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
    );
  }

  Widget _buildSuccessState() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: TulipColors.sageLight,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.check_circle_outline,
            size: 48,
            color: TulipColors.sageDark,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'You\'re In!',
          style: TulipTextStyles.heading2,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        if (_result?.stayTitle != null) ...[
          Text(
            'You now have access to',
            style: TulipTextStyles.bodySmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            _result!.stayTitle!,
            style: TulipTextStyles.heading3,
            textAlign: TextAlign.center,
          ),
          if (_result?.stayCity != null)
            Text(
              _result!.stayCity!,
              style: TulipTextStyles.bodySmall,
              textAlign: TextAlign.center,
            ),
        ] else
          Text(
            _result?.message ?? 'Invite accepted successfully',
            style: TulipTextStyles.body,
            textAlign: TextAlign.center,
          ),
        const SizedBox(height: 32),

        TulipButton(
          onPressed: () {
            if (_result?.stayId != null) {
              context.go('/stays/${_result!.stayId}');
            } else {
              context.go('/');
            }
          },
          label: 'View Stay',
        ),
        const SizedBox(height: 12),
        TextButton(
          onPressed: () => context.go('/'),
          child: Text(
            'Go to Dashboard',
            style: TulipTextStyles.body.copyWith(
              color: TulipColors.brownLight,
            ),
          ),
        ),
      ],
    );
  }
}
