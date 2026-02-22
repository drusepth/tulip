import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/constants/tulip_colors.dart';
import '../../../../shared/constants/tulip_text_styles.dart';
import '../../../../shared/widgets/loading_shimmer.dart';
import '../../../../shared/widgets/cozy_card.dart';
import '../../../../shared/widgets/countdown_hero.dart';
import '../../../stays/presentation/providers/stays_provider.dart';
import '../../../stays/presentation/widgets/stay_card.dart';
import '../../../stays/data/models/stay_model.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final staysAsync = ref.watch(staysProvider);
    final currentStay = ref.watch(currentStayProvider);
    final upcomingStays = ref.watch(upcomingStaysProvider);

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
      body: RefreshIndicator(
        onRefresh: () => ref.read(staysProvider.notifier).refresh(),
        color: TulipColors.sage,
        child: staysAsync.when(
          loading: () => _buildLoadingState(),
          error: (error, stack) => _buildErrorState(context, ref, error),
          data: (stays) => _buildContent(context, stays, currentStay, upcomingStays),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LoadingShimmer(
            child: Container(
              height: 100,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
          const SizedBox(height: 24),
          LoadingShimmer(
            child: Container(
              height: 200,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, WidgetRef ref, Object error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: TulipColors.roseDark,
            ),
            const SizedBox(height: 16),
            Text(
              'Unable to load your stays',
              style: TulipTextStyles.heading3,
            ),
            const SizedBox(height: 8),
            Text(
              error.toString(),
              style: TulipTextStyles.bodySmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => ref.read(staysProvider.notifier).refresh(),
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    List<Stay> allStays,
    Stay? currentStay,
    List<Stay> upcomingStays,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Countdown hero section
          CountdownHero(
            nextTrip: upcomingStays.firstOrNull,
            currentStay: currentStay,
            onAddStay: () => context.push('/stays/new'),
          ),
          const SizedBox(height: 24),

          // Current stay (if any)
          if (currentStay != null) ...[
            Text('Currently Staying', style: TulipTextStyles.heading3),
            const SizedBox(height: 12),
            StayCard(
              stay: currentStay,
              onTap: () => context.push('/stays/${currentStay.id}'),
            ),
            const SizedBox(height: 24),
          ],

          // Upcoming stays
          if (upcomingStays.isNotEmpty) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Upcoming', style: TulipTextStyles.heading3),
                TextButton(
                  onPressed: () => context.push('/stays'),
                  child: Text(
                    'See all',
                    style: TulipTextStyles.label.copyWith(
                      color: TulipColors.sage,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...upcomingStays.take(3).map((stay) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: StayCardCompact(
                    stay: stay,
                    onTap: () => context.push('/stays/${stay.id}'),
                  ),
                )),
            const SizedBox(height: 12),
          ],

          // Empty state / Quick actions
          if (allStays.isEmpty) ...[
            _buildEmptyState(context),
          ] else if (currentStay == null && upcomingStays.isEmpty) ...[
            _buildNoUpcomingState(context),
          ],

          // Quick actions
          const SizedBox(height: 8),
          Text('Quick Actions', style: TulipTextStyles.heading3),
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
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildActionCard(
                  context,
                  icon: Icons.timeline_outlined,
                  label: 'Timeline',
                  onTap: () => context.go('/timeline'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionCard(
                  context,
                  icon: Icons.list_alt_outlined,
                  label: 'All Stays',
                  onTap: () => context.push('/stays'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Stats summary
          if (allStays.isNotEmpty) _buildStatsSummary(allStays),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return CozyCard(
      child: Column(
        children: [
          Icon(
            Icons.luggage_outlined,
            size: 48,
            color: TulipColors.sage,
          ),
          const SizedBox(height: 16),
          Text(
            'Start Your Journey',
            style: TulipTextStyles.heading3,
          ),
          const SizedBox(height: 8),
          Text(
            'Add your first travel stay to begin planning your cozy adventures.',
            style: TulipTextStyles.bodySmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => context.push('/stays/new'),
            icon: const Icon(Icons.add),
            label: const Text('Add Your First Stay'),
          ),
        ],
      ),
    );
  }

  Widget _buildNoUpcomingState(BuildContext context) {
    return CozyCard(
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: TulipColors.lavenderLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.flight_takeoff,
              color: TulipColors.lavenderDark,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'No upcoming trips',
                  style: TulipTextStyles.label,
                ),
                Text(
                  'Time to plan your next adventure?',
                  style: TulipTextStyles.caption,
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            color: TulipColors.sage,
            onPressed: () => context.push('/stays/new'),
          ),
        ],
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

  Widget _buildStatsSummary(List<Stay> stays) {
    final totalStays = stays.length;
    final upcomingCount = stays.where((s) => s.isUpcoming).length;
    final pastCount = stays.where((s) => s.isPast).length;
    final totalNights = stays.fold(0, (sum, s) => sum + s.durationDays);

    return CozyCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Your Travel Stats', style: TulipTextStyles.label),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  icon: Icons.home_outlined,
                  value: totalStays.toString(),
                  label: 'Total Stays',
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  icon: Icons.nightlight_outlined,
                  value: totalNights.toString(),
                  label: 'Nights',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  icon: Icons.schedule,
                  value: upcomingCount.toString(),
                  label: 'Upcoming',
                  color: TulipColors.sage,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  icon: Icons.check_circle_outline,
                  value: pastCount.toString(),
                  label: 'Completed',
                  color: TulipColors.taupe,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required String label,
    Color? color,
  }) {
    return Row(
      children: [
        Icon(icon, size: 20, color: color ?? TulipColors.brownLight),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: TulipTextStyles.heading3.copyWith(
                color: color ?? TulipColors.brown,
              ),
            ),
            Text(label, style: TulipTextStyles.caption),
          ],
        ),
      ],
    );
  }
}
