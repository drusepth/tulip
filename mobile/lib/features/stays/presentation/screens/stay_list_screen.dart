import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/constants/tulip_colors.dart';
import '../../../../shared/constants/tulip_text_styles.dart';
import '../../../../shared/widgets/loading_shimmer.dart';
import '../providers/stays_provider.dart';
import '../widgets/stay_card.dart';

class StayListScreen extends ConsumerWidget {
  const StayListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final staysAsync = ref.watch(staysProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Your Stays', style: TulipTextStyles.heading3),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.push('/stays/new'),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(staysProvider.notifier).refresh(),
        color: TulipColors.sage,
        child: staysAsync.when(
          loading: () => _buildLoadingState(),
          error: (error, stack) => _buildErrorState(context, ref, error),
          data: (stays) {
            if (stays.isEmpty) {
              return _buildEmptyState(context);
            }
            return _buildStaysList(context, stays);
          },
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 3,
      itemBuilder: (context, index) => Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: LoadingShimmer(
          child: Container(
            height: 160,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
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
              'Unable to load stays',
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

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.luggage_outlined,
            size: 64,
            color: TulipColors.brownLighter,
          ),
          const SizedBox(height: 16),
          Text(
            'No stays yet',
            style: TulipTextStyles.heading3,
          ),
          const SizedBox(height: 8),
          Text(
            'Add your first travel stay to get started',
            style: TulipTextStyles.bodySmall,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => context.push('/stays/new'),
            icon: const Icon(Icons.add),
            label: const Text('Add Stay'),
          ),
        ],
      ),
    );
  }

  Widget _buildStaysList(BuildContext context, List stays) {
    // Group stays by status
    final currentStays = stays.where((s) => s.isCurrent).toList();
    final upcomingStays = stays.where((s) => s.isUpcoming).toList();
    final pastStays = stays.where((s) => s.isPast).toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Current stays
        if (currentStays.isNotEmpty) ...[
          _buildSectionHeader('Current', currentStays.length),
          const SizedBox(height: 12),
          ...currentStays.map((stay) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: StayCard(
                  stay: stay,
                  onTap: () => context.push('/stays/${stay.id}'),
                ),
              )),
        ],
        // Upcoming stays
        if (upcomingStays.isNotEmpty) ...[
          _buildSectionHeader('Upcoming', upcomingStays.length),
          const SizedBox(height: 12),
          ...upcomingStays.map((stay) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: StayCard(
                  stay: stay,
                  onTap: () => context.push('/stays/${stay.id}'),
                ),
              )),
        ],
        // Past stays
        if (pastStays.isNotEmpty) ...[
          _buildSectionHeader('Past', pastStays.length),
          const SizedBox(height: 12),
          ...pastStays.map((stay) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: StayCardCompact(
                  stay: stay,
                  onTap: () => context.push('/stays/${stay.id}'),
                ),
              )),
        ],
      ],
    );
  }

  Widget _buildSectionHeader(String title, int count) {
    return Row(
      children: [
        Text(
          title,
          style: TulipTextStyles.heading3,
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: TulipColors.taupeLight,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            count.toString(),
            style: TulipTextStyles.caption.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
