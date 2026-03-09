import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
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
import '../../../bucket_list/presentation/widgets/add_bucket_list_item_sheet.dart';
import '../../../weather/presentation/widgets/weather_card.dart';
import '../../../comments/presentation/widgets/comment_thread.dart';
import '../../../collaboration/presentation/providers/collaboration_provider.dart';

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
          const SizedBox(height: 8),

          // Collaborator avatar stack
          _buildCollaboratorAvatarStack(stay),
          const SizedBox(height: 16),

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

          // Trip Highlights card
          _buildHighlightsCard(stay),

          // Booking status card
          if (stay.booked && stay.bookingUrl != null)
            GestureDetector(
              onTap: () => _openBookingUrl(stay.bookingUrl!),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  // Use normal card styling for past stays, gradient for upcoming/current
                  gradient: stay.isPast
                      ? null
                      : LinearGradient(
                          colors: [
                            TulipColors.sageLight,
                            TulipColors.sage.withValues(alpha: 0.3),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                  color: stay.isPast ? Colors.white : null,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: stay.isPast
                        ? TulipColors.taupeLight
                        : TulipColors.sage.withValues(alpha: 0.5),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: stay.isPast ? TulipColors.taupeLight : TulipColors.sage,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.check,
                        color: stay.isPast ? TulipColors.brownLight : Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            stay.isPast ? 'Booked' : 'Booked!',
                            style: TulipTextStyles.label.copyWith(
                              color: stay.isPast ? TulipColors.brown : TulipColors.sageDark,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            'View booking on ${_formatStayType(stay.stayType)}',
                            style: TulipTextStyles.caption.copyWith(
                              color: stay.isPast ? TulipColors.brownLight : TulipColors.sageDark,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.open_in_new,
                      color: stay.isPast ? TulipColors.brownLight : TulipColors.sageDark,
                      size: 18,
                    ),
                  ],
                ),
              ),
            )
          else if (stay.bookingUrl != null || stay.priceTotalCents != null)
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
                    if (stay.bookingUrl != null || !stay.booked)
                      const SizedBox(height: 12),
                  ],
                  if (stay.bookingUrl != null)
                    GestureDetector(
                      onTap: () => _openBookingUrl(stay.bookingUrl!),
                      child: Row(
                        children: [
                          Icon(
                            Icons.open_in_new,
                            size: 18,
                            color: TulipColors.sage,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'View Booking',
                            style: TulipTextStyles.body.copyWith(
                              color: TulipColors.sage,
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (!stay.booked) ...[
                    if (stay.bookingUrl != null) const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.schedule,
                          size: 18,
                          color: TulipColors.brownLighter,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Not yet booked',
                          style: TulipTextStyles.bodySmall.copyWith(
                            color: TulipColors.brownLighter,
                          ),
                        ),
                      ],
                    ),
                  ],
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

        return WeatherCard(
          weatherData: weatherData,
          showDailyForecast: !stay.isPast,
          onTap: () => context.push(
            '/stays/${stay.id}/weather?title=${Uri.encodeComponent(stay.title)}',
          ),
        );
      },
    );
  }

  Widget _buildHighlightsCard(Stay stay) {
    final completedCount = stay.bucketListCompletedCount;
    final hasHighlights = completedCount > 0;

    return Column(
      children: [
        GestureDetector(
          onTap: () => context.push(
            '/stays/${stay.id}/highlights?title=${Uri.encodeComponent(stay.title)}',
          ),
          child: CozyCard(
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: TulipColors.coralDark.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.auto_awesome,
                    size: 24,
                    color: TulipColors.coralDark,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Trip Highlights', style: TulipTextStyles.label),
                      const SizedBox(height: 2),
                      Text(
                        hasHighlights
                            ? '$completedCount completed ${completedCount == 1 ? 'item' : 'items'} with ratings'
                            : 'Your trip memories',
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
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildCollaboratorAvatarStack(Stay stay) {
    final collaborationsAsync = ref.watch(collaborationsProvider(stay.id));

    return GestureDetector(
      onTap: () => context.push(
        '/stays/${stay.id}/collaborators?title=${Uri.encodeComponent(stay.title)}&is_owner=${stay.isOwner}',
      ),
      child: collaborationsAsync.when(
        loading: () => const SizedBox.shrink(),
        error: (_, __) => const SizedBox.shrink(),
        data: (response) {
          final accepted = response.accepted;
          // Always show at least the owner, plus any collaborators
          final totalCount = accepted.length + 1; // +1 for owner

          if (totalCount <= 1 && stay.collaboratorCount == 0) {
            // No collaborators, don't show avatar stack
            return const SizedBox.shrink();
          }

          // Calculate stack width: first avatar is 28px, each additional overlaps by 18px
          final displayedCollaborators = accepted.length.clamp(0, 4);
          final hasOverflow = accepted.length > 4;
          final totalAvatars = 1 + displayedCollaborators + (hasOverflow ? 1 : 0); // owner + collaborators + overflow
          final stackWidth = 28.0 + (totalAvatars - 1) * 18.0;

          return Row(
            children: [
              // Overlapping avatar stack
              SizedBox(
                height: 28,
                width: stackWidth,
                child: Stack(
                  children: [
                    // Owner avatar (always first, with sage ring)
                    _buildHeaderAvatar(
                      name: 'Owner',
                      index: 0,
                      offset: 0,
                      ringColor: TulipColors.sage,
                    ),
                    // Collaborator avatars
                    for (int i = 0; i < accepted.length.clamp(0, 4); i++)
                      _buildHeaderAvatar(
                        name: accepted[i].displayName,
                        index: i + 1,
                        offset: (i + 1) * 18.0,
                        ringColor: TulipColors.lavender,
                        avatarUrl: accepted[i].user?.avatarUrl,
                      ),
                    // Overflow indicator
                    if (accepted.length > 4)
                      Positioned(
                        left: 5 * 18.0,
                        child: Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: TulipColors.taupeLight,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: Center(
                            child: Text(
                              '+${accepted.length - 4}',
                              style: TulipTextStyles.caption.copyWith(
                                fontWeight: FontWeight.w600,
                                fontSize: 10,
                                color: TulipColors.brown,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeaderAvatar({
    required String name,
    required int index,
    required double offset,
    required Color ringColor,
    String? avatarUrl,
  }) {
    // Generate initials for fallback
    String initials = '?';
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

    // Consistent color based on name (used for fallback)
    final colors = [
      TulipColors.sage,
      TulipColors.lavender,
      TulipColors.rose,
      TulipColors.coral,
    ];
    final colorIndex = name.hashCode.abs() % colors.length;
    final bgColor = index == 0 ? TulipColors.sage : colors[colorIndex];

    return Positioned(
      left: offset,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: bgColor,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2),
        ),
        child: avatarUrl != null
            ? ClipOval(
                child: CachedNetworkImage(
                  imageUrl: avatarUrl,
                  width: 24,
                  height: 24,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Center(
                    child: Text(
                      initials,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 10,
                      ),
                    ),
                  ),
                  errorWidget: (context, url, error) => Center(
                    child: Text(
                      initials,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ),
              )
            : Center(
                child: Text(
                  initials,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 10,
                  ),
                ),
              ),
      ),
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
    final itemsWithLocation = items.where((i) => i.hasLocation).toList();

    return RefreshIndicator(
      onRefresh: () => ref.read(bucketListProvider(stay.id).notifier).refresh(),
      color: TulipColors.sage,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Progress header
          _buildBucketListProgress(items),
          const SizedBox(height: 16),

          // Highlights CTA for past stays
          if (stay.isPast && completedItems.isNotEmpty) ...[
            _buildHighlightsCTA(stay),
            const SizedBox(height: 16),
          ],

          // View on Map button
          if (itemsWithLocation.isNotEmpty) ...[
            OutlinedButton.icon(
              onPressed: () => context.push(
                '/stays/${stay.id}/bucket_list_map?title=${Uri.encodeComponent(stay.title)}',
              ),
              icon: const Icon(Icons.map_outlined),
              label: const Text('View on Map'),
              style: OutlinedButton.styleFrom(
                foregroundColor: TulipColors.lavenderDark,
                side: const BorderSide(color: TulipColors.lavender),
              ),
            ),
            const SizedBox(height: 12),
          ],

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
                    onUndo: stay.canEdit
                        ? () => ref
                            .read(bucketListProvider(stay.id).notifier)
                            .restoreItem(item)
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
                    onUndo: stay.canEdit
                        ? () => ref
                            .read(bucketListProvider(stay.id).notifier)
                            .restoreItem(item)
                        : null,
                    onRate: (rating) => ref
                        .read(bucketListProvider(stay.id).notifier)
                        .rateItem(item.id, rating),
                  ),
                )),
          ],
        ],
      ),
    );
  }

  Widget _buildHighlightsCTA(Stay stay) {
    final hasCollaborators = stay.collaboratorCount > 0;

    return GestureDetector(
      onTap: () => context.push(
        '/stays/${stay.id}/highlights?title=${Uri.encodeComponent(stay.title)}',
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              TulipColors.coralDark.withValues(alpha: 0.15),
              TulipColors.coral.withValues(alpha: 0.1),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: TulipColors.coral.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: TulipColors.coral,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.auto_awesome,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Rate Your Experiences',
                    style: TulipTextStyles.label.copyWith(
                      color: TulipColors.coralDark,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    hasCollaborators
                        ? 'Rate items and see ratings from your travel companions'
                        : 'Rate your bucket list items and save your memories',
                    style: TulipTextStyles.caption.copyWith(
                      color: TulipColors.brown,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: TulipColors.coralDark,
            ),
          ],
        ),
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
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => AddBucketListItemSheet(stayId: stay.id),
    );
  }

  Widget _buildCommentsTab(Stay stay) {
    return CommentThread(stayId: stay.id);
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
            ListTile(
              leading: const Icon(Icons.auto_awesome),
              title: const Text('Trip Highlights'),
              onTap: () {
                Navigator.pop(context);
                context.push(
                  '/stays/${stay.id}/highlights?title=${Uri.encodeComponent(stay.title)}',
                );
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
            if (stay.bookingUrl != null)
              ListTile(
                leading: const Icon(Icons.open_in_browser),
                title: const Text('Open Booking Link'),
                onTap: () {
                  Navigator.pop(context);
                  _openBookingUrl(stay.bookingUrl!);
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
              if (success && context.mounted) {
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

  Future<void> _openBookingUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  String _formatStayType(String? stayType) {
    if (stayType == null || stayType.isEmpty) return 'website';
    // Capitalize first letter
    return stayType[0].toUpperCase() + stayType.substring(1);
  }
}
