import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/auth/auth_provider.dart';
import '../../../../shared/constants/tulip_colors.dart';
import '../../../../shared/constants/tulip_text_styles.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile', style: TulipTextStyles.heading3),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Profile avatar
              CircleAvatar(
                radius: 48,
                backgroundColor: TulipColors.sageLight,
                child: Icon(
                  Icons.person,
                  size: 48,
                  color: TulipColors.sageDark,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Your Profile',
                style: TulipTextStyles.heading2,
              ),
              const SizedBox(height: 8),
              Text(
                'Profile settings coming soon',
                style: TulipTextStyles.bodySmall,
              ),
              const Spacer(),

              // Sign out button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    await ref.read(authStateProvider.notifier).signOut();
                    if (context.mounted) {
                      context.go('/login');
                    }
                  },
                  icon: const Icon(Icons.logout),
                  label: const Text('Sign Out'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: TulipColors.roseDark,
                    side: BorderSide(color: TulipColors.roseDark),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
