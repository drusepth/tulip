import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../shared/constants/tulip_colors.dart';
import '../../../../shared/constants/tulip_text_styles.dart';
import '../../../../shared/widgets/status_badge.dart';
import '../../../../shared/widgets/loading_shimmer.dart';
import '../../../../shared/widgets/cozy_card.dart';
import '../../../../shared/widgets/cottage_segmented_tabs.dart';
import '../providers/stays_provider.dart';
import '../../data/models/stay_model.dart';
import '../../../bucket_list/presentation/providers/bucket_list_provider.dart';
import '../../../bucket_list/presentation/widgets/bucket_list_item_tile.dart';
import '../../../bucket_list/data/models/bucket_list_item_model.dart';
import '../../../weather/presentation/widgets/weather_card.dart';

class StayDetailScreen extends ConsumerStatefulWidget {
  final int stayId;

  const StayDetailScreen({super.key, required this.stayId});

  @override
  ConsumerState<StayDetailScreen> createState() => _StayDetailScreenState();
}

class _StayDetailScreenState extends ConsumerState<StayDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final stayAsync = ref.watch(stayDetailProvider(widget.stayId));

    return stayAsync.when(
      loading: () => _buildLoadingScaffold(),
      error: (error, stack) => _buildErrorScaffold(error),
      data: (stay) => _buildStayScaffold(stay),
    );
  }

  Widget _buildLoadingScaffold() {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: const Center(
        child: CircularProgressIndicator(color: TulipColors.sage),
      ),
    );
  }

  Widget _buildErrorScaffold(Object error) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: TulipColors.roseDark),
            const SizedBox(height: 16),
            Text('Unable to load stay', style: TulipTextStyles.heading3),
            const SizedBox(height: 8),
            Text(
              error.toString(),
              style: TulipTextStyles.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStayScaffold(Stay stay) {
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: stay.imageUrl != null ? 200 : 0,
              pinned: true,
              leading: IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.9),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.arrow_back, size: 20),
                ),
                onPressed: () => context.pop(),
              ),
              actions: [
                if (stay.canEdit)
                  IconButton(
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.9),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.edit_outlined, size: 20),
                    ),
                    onPressed: () => context.push('/stays/${stay.id}/edit'),
                  ),
                IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.9),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.more_vert, size: 20),
                  ),
                  onPressed: () => _showMoreOptions(stay),
                ),
              ],
              flexibleSpace: stay.imageUrl != null
                  ? FlexibleSpaceBar(
                      background: CachedNetworkImage(
                        imageUrl: stay.imageUrl!,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: TulipColors.taupeLight,
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: TulipColors.taupeLight,
                          child: Icon(
                            Icons.image_outlined,
                            color: TulipColors.brownLighter,
                            size: 48,
                          ),
                        ),
                      ),
                    )
                  : null,
              bottom: CottageSegmentedTabs(
                controller: _tabController,
                labels: const ['Overview', 'Bucket List', 'Comments'],
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildOverviewTab(stay),
            _buildBucketListTab(stay),
            _buildCommentsTab(stay),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewTab(Stay stay) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title and status
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(stay.title, style: TulipTextStyles.heading2),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: 16,
                          color: TulipColors.brownLight,
                        ),
                        const SizedBox(width: 4),
                        Text(stay.location, style: TulipTextStyles.bodySmall),
                      ],
                    ),
                  ],
                ),
              ),
              StatusBadge(status: stay.status),
            ],
          ),
          const SizedBox(height: 20),

          // Date and duration card
          if (stay.checkIn != null && stay.checkOut != null)
            CozyCard(
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildDateColumn(
                          'Check-in',
                          stay.checkIn!,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Icon(
                          Icons.arrow_forward,
                          color: TulipColors.brownLighter,
                        ),
                      ),
                      Expanded(
                        child: _buildDateColumn(
                          'Check-out',
                          stay.checkOut!,
                        ),
                      ),
                    ],
                  ),
                  if (stay.durationDays > 0) ...[
                    const Divider(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.nightlight_outlined,
                          size: 16,
                          color: TulipColors.brownLight,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${stay.durationDays} ${stay.durationDays == 1 ? 'night' : 'nights'}',
                          style: TulipTextStyles.label,
                        ),
                        if (stay.daysUntilCheckIn != null && stay.isUpcoming) ...[
                          const SizedBox(width: 16),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: TulipColors.sageLight,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              stay.daysUntilCheckIn == 0
                                  ? 'Today!'
                                  : 'In ${stay.daysUntilCheckIn} days',
                              style: TulipTextStyles.caption.copyWith(
                                color: TulipColors.sageDark,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ],
              ),
            ),
          const SizedBox(height: 16),

          // Weather section
          _buildWeatherSection(stay),
          const SizedBox(height: 16),

          // Explore nearby places
          if (stay.hasCoordinates)
            GestureDetector(
              onTap: () => context.push('/stays/${stay.id}/gallery?title=${Uri.encodeComponent(stay.title)}'),
              child: CozyCard(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: TulipColors.sageLight,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.explore_outlined,
                        size: 24,
                        color: TulipColors.sageDark,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Explore Nearby', style: TulipTextStyles.label),
                          const SizedBox(height: 2),
                          Text(
                            'Discover restaurants, cafes, and attractions',
                            style: TulipTextStyles.caption,
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.chevron_right,
                      color: TulipColors.brownLight,
                    ),
                  ],
                ),
              ),
            ),
          if (stay.hasCoordinates) const SizedBox(height: 16),

          // Price and booking info
          if (stay.priceTotalCents != null || stay.bookingUrl != null)
            CozyCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (stay.priceTotalCents != null) ...[
                    Row(
                      children: [
                        Icon(
                          Icons.payments_outlined,
                          size: 20,
                          color: TulipColors.brownLight,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          stay.priceFormatted ?? '',
                          style: TulipTextStyles.heading3,
                        ),
                        if (stay.pricePerNight != null) ...[
                          const SizedBox(width: 8),
                          Text(
                            stay.pricePerNight!,
                            style: TulipTextStyles.bodySmall,
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 12),
                  ],
                  if (stay.bookingUrl != null)
                    Row(
                      children: [
                        Icon(
                          Icons.link,
                          size: 20,
                          color: TulipColors.brownLight,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Booking link available',
                            style: TulipTextStyles.bodySmall,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            // TODO: Open booking URL
                          },
                          child: const Text('Open'),
                        ),
                      ],
                    ),
                  Row(
                    children: [
                      Icon(
                        stay.booked ? Icons.check_circle : Icons.schedule,
                        size: 20,
                        color: stay.booked
                            ? TulipColors.sage
                            : TulipColors.brownLight,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        stay.booked ? 'Booked' : 'Not yet booked',
                        style: TulipTextStyles.body.copyWith(
                          color: stay.booked
                              ? TulipColors.sageDark
                              : TulipColors.brownLight,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          const SizedBox(height: 16),

          // Notes
          if (stay.notes != null && stay.notes!.isNotEmpty)
            CozyCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.notes_outlined,
                        size: 20,
                        color: TulipColors.brownLight,
                      ),
                      const SizedBox(width: 8),
                      Text('Notes', style: TulipTextStyles.label),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    stay.notes!,
                    style: TulipTextStyles.body,
                  ),
                ],
              ),
            ),
          const SizedBox(height: 16),

          // Collaboration info
          if (stay.collaboratorCount > 0)
            CozyCard(
              child: Row(
                children: [
                  Icon(
                    Icons.people_outline,
                    size: 20,
                    color: TulipColors.brownLight,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${stay.collaboratorCount} collaborator${stay.collaboratorCount == 1 ? '' : 's'}',
                    style: TulipTextStyles.body,
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () {
                      // TODO: Show collaborators screen
                    },
                    child: const Text('Manage'),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildDateColumn(String label, DateTime date) {
    final weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TulipTextStyles.caption),
        const SizedBox(height: 4),
        Text(
          '${weekdays[date.weekday - 1]}, ${months[date.month - 1]} ${date.day}',
          style: TulipTextStyles.label,
        ),
        Text(
          '${date.year}',
          style: TulipTextStyles.bodySmall,
        ),
      ],
    );
  }

  Widget _buildWeatherSection(Stay stay) {
    final weatherAsync = ref.watch(stayWeatherProvider(stay.id));

    return weatherAsync.when(
      loading: () => CozyCard(
        child: LoadingShimmer(
          child: Container(
            height: 80,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
      error: (error, stack) => const SizedBox.shrink(),
      data: (weatherData) {
        final weather = weatherData['weather'] as Map<String, dynamic>?;
        if (weather == null) return const SizedBox.shrink();

        return WeatherCard(weatherData: weatherData);
      },
    );
  }

  Widget _buildBucketListTab(Stay stay) {
    final bucketListAsync = ref.watch(bucketListProvider(stay.id));

    return bucketListAsync.when(
      loading: () => const Center(
        child: CircularProgressIndicator(color: TulipColors.sage),
      ),
      error: (error, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: TulipColors.roseDark),
            const SizedBox(height: 16),
            Text('Unable to load bucket list', style: TulipTextStyles.body),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => ref.read(bucketListProvider(stay.id).notifier).refresh(),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
      data: (items) {
        if (items.isEmpty) {
          return _buildEmptyBucketList(stay);
        }
        return _buildBucketListContent(stay, items);
      },
    );
  }

  Widget _buildEmptyBucketList(Stay stay) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.checklist_outlined,
            size: 64,
            color: TulipColors.brownLighter,
          ),
          const SizedBox(height: 16),
          Text(
            'No bucket list items yet',
            style: TulipTextStyles.heading3,
          ),
          const SizedBox(height: 8),
          Text(
            'Add things to do during your stay',
            style: TulipTextStyles.bodySmall,
          ),
          const SizedBox(height: 24),
          if (stay.canEdit)
            ElevatedButton.icon(
              onPressed: () => _showAddBucketListItemDialog(stay),
              icon: const Icon(Icons.add),
              label: const Text('Add Item'),
            ),
        ],
      ),
    );
  }

  Widget _buildBucketListContent(Stay stay, List<BucketListItem> items) {
    final incompleteItems = items.where((i) => !i.completed).toList();
    final completedItems = items.where((i) => i.completed).toList();

    return RefreshIndicator(
      onRefresh: () => ref.read(bucketListProvider(stay.id).notifier).refresh(),
      color: TulipColors.sage,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Progress header
          _buildBucketListProgress(items),
          const SizedBox(height: 16),

          // Add item button
          if (stay.canEdit) ...[
            OutlinedButton.icon(
              onPressed: () => _showAddBucketListItemDialog(stay),
              icon: const Icon(Icons.add),
              label: const Text('Add Item'),
              style: OutlinedButton.styleFrom(
                foregroundColor: TulipColors.sage,
                side: const BorderSide(color: TulipColors.sage),
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Incomplete items
          if (incompleteItems.isNotEmpty) ...[
            Text('To Do', style: TulipTextStyles.label),
            const SizedBox(height: 8),
            ...incompleteItems.map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: BucketListItemTile(
                    item: item,
                    onToggle: () => ref
                        .read(bucketListProvider(stay.id).notifier)
                        .toggleItem(item.id),
                    onDelete: stay.canEdit
                        ? () => ref
                            .read(bucketListProvider(stay.id).notifier)
                            .deleteItem(item.id)
                        : null,
                  ),
                )),
            const SizedBox(height: 16),
          ],

          // Completed items
          if (completedItems.isNotEmpty) ...[
            Text('Completed', style: TulipTextStyles.label),
            const SizedBox(height: 8),
            ...completedItems.map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: BucketListItemTile(
                    item: item,
                    onToggle: () => ref
                        .read(bucketListProvider(stay.id).notifier)
                        .toggleItem(item.id),
                    onDelete: stay.canEdit
                        ? () => ref
                            .read(bucketListProvider(stay.id).notifier)
                            .deleteItem(item.id)
                        : null,
                  ),
                )),
          ],
        ],
      ),
    );
  }

  Widget _buildBucketListProgress(List<BucketListItem> items) {
    final completed = items.where((i) => i.completed).length;
    final total = items.length;
    final progress = total > 0 ? completed / total : 0.0;

    return CozyCard(
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                Icons.checklist,
                size: 20,
                color: TulipColors.sage,
              ),
              const SizedBox(width: 8),
              Text(
                '$completed of $total completed',
                style: TulipTextStyles.label,
              ),
              const Spacer(),
              Text(
                '${(progress * 100).round()}%',
                style: TulipTextStyles.body.copyWith(
                  color: TulipColors.sage,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: TulipColors.taupeLight,
              valueColor: const AlwaysStoppedAnimation<Color>(TulipColors.sage),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }

  void _showAddBucketListItemDialog(Stay stay) {
    final titleController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Bucket List Item'),
        content: TextField(
          controller: titleController,
          decoration: const InputDecoration(
            hintText: 'What do you want to do?',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
          textCapitalization: TextCapitalization.sentences,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              if (titleController.text.trim().isEmpty) return;
              Navigator.pop(context);
              await ref.read(bucketListProvider(stay.id).notifier).createItem(
                    BucketListItemRequest(title: titleController.text.trim()),
                  );
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentsTab(Stay stay) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 64,
            color: TulipColors.brownLighter,
          ),
          const SizedBox(height: 16),
          Text(
            'Comments',
            style: TulipTextStyles.heading3,
          ),
          const SizedBox(height: 8),
          Text(
            'Coming soon',
            style: TulipTextStyles.bodySmall,
          ),
        ],
      ),
    );
  }

  void _showMoreOptions(Stay stay) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.map_outlined),
              title: const Text('View on Map'),
              onTap: () {
                Navigator.pop(context);
                context.go('/map');
              },
            ),
            if (stay.bookingUrl != null)
              ListTile(
                leading: const Icon(Icons.open_in_browser),
                title: const Text('Open Booking Link'),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Open URL
                },
              ),
            ListTile(
              leading: const Icon(Icons.share_outlined),
              title: const Text('Share Stay'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Share
              },
            ),
            if (stay.isOwner) ...[
              const Divider(),
              ListTile(
                leading: Icon(Icons.delete_outline, color: TulipColors.roseDark),
                title: Text(
                  'Delete Stay',
                  style: TextStyle(color: TulipColors.roseDark),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _confirmDelete(stay);
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _confirmDelete(Stay stay) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Stay'),
        content: Text('Are you sure you want to delete "${stay.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await ref
                  .read(stayFormProvider.notifier)
                  .deleteStay(stay.id);
              if (success && mounted) {
                context.pop();
              }
            },
            style: TextButton.styleFrom(foregroundColor: TulipColors.roseDark),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
