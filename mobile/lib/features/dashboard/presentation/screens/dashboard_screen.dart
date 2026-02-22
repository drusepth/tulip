import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/constants/tulip_colors.dart';
import '../../../../shared/constants/tulip_text_styles.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tulip', style: TulipTextStyles.heading2),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () => context.push('/notifications'),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome section
              Text(
                'Welcome back!',
                style: TulipTextStyles.heading2,
              ),
              const SizedBox(height: 8),
              Text(
                'Plan your next cozy adventure',
                style: TulipTextStyles.bodySmall,
              ),
              const SizedBox(height: 24),

              // Current/Upcoming stay card placeholder
              _buildPlaceholderCard(
                context,
                title: 'Your Stays',
                subtitle: 'View and manage your travel accommodations',
                icon: Icons.home_outlined,
                onTap: () => context.push('/stays'),
              ),
              const SizedBox(height: 16),

              // Quick actions
              Text(
                'Quick Actions',
                style: TulipTextStyles.heading3,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildActionCard(
                      context,
                      icon: Icons.add_location_alt_outlined,
                      label: 'New Stay',
                      onTap: () => context.push('/stays/new'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildActionCard(
                      context,
                      icon: Icons.map_outlined,
                      label: 'View Map',
                      onTap: () => context.go('/map'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholderCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: TulipColors.taupeLight),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: TulipColors.sageLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: TulipColors.sageDark),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TulipTextStyles.heading3),
                  const SizedBox(height: 4),
                  Text(subtitle, style: TulipTextStyles.bodySmall),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: TulipColors.brownLight),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: TulipColors.taupeLight),
        ),
        child: Column(
          children: [
            Icon(icon, color: TulipColors.sage, size: 32),
            const SizedBox(height: 8),
            Text(label, style: TulipTextStyles.label),
          ],
        ),
      ),
    );
  }
}
