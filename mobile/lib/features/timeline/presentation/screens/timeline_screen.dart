import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/constants/tulip_colors.dart';
import '../../../../shared/constants/tulip_text_styles.dart';
import '../../../stays/presentation/providers/stays_provider.dart';
import '../providers/timeline_provider.dart';
import '../widgets/timeline_bar.dart';
import '../widgets/timeline_header.dart';

class TimelineScreen extends ConsumerStatefulWidget {
  const TimelineScreen({super.key});

  @override
  ConsumerState<TimelineScreen> createState() => _TimelineScreenState();
}

class _TimelineScreenState extends ConsumerState<TimelineScreen> {
  final ScrollController _scrollController = ScrollController();
  final ScrollController _headerScrollController = ScrollController();
  static const double _timelineWidth = 2000.0;
  static const double _barHeight = 56.0;
  static const double _rowSpacing = 66.0;
  static const double _headerHeight = 50.0;

  @override
  void initState() {
    super.initState();
    // Sync header scroll with main scroll
    _scrollController.addListener(_syncScroll);
    // Scroll to today after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToToday();
    });
  }

  void _syncScroll() {
    if (_headerScrollController.hasClients) {
      _headerScrollController.jumpTo(_scrollController.offset);
    }
  }

  void _scrollToToday() {
    final dateRange = ref.read(timelineDateRangeProvider);
    if (dateRange == null) return;

    final today = DateTime.now();
    final position = dateRange.positionFor(today);
    final scrollPosition = position * _timelineWidth - MediaQuery.of(context).size.width / 2;

    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        scrollPosition.clamp(0, _scrollController.position.maxScrollExtent),
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_syncScroll);
    _scrollController.dispose();
    _headerScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final staysAsync = ref.watch(staysProvider);
    final items = ref.watch(timelineItemsProvider);
    final dateRange = ref.watch(timelineDateRangeProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Timeline', style: TulipTextStyles.heading2),
        actions: [
          IconButton(
            icon: const Icon(Icons.today),
            tooltip: 'Go to today',
            onPressed: _scrollToToday,
          ),
        ],
      ),
      body: staysAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: TulipColors.sage),
        ),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 48, color: TulipColors.roseDark),
              const SizedBox(height: 16),
              Text('Unable to load timeline', style: TulipTextStyles.heading3),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () => ref.read(staysProvider.notifier).refresh(),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (_) {
          if (items.isEmpty || dateRange == null) {
            return _buildEmptyState();
          }
          return _buildTimeline(items, dateRange);
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.view_timeline_outlined,
            size: 64,
            color: TulipColors.brownLighter,
          ),
          const SizedBox(height: 16),
          Text(
            'No stays to show',
            style: TulipTextStyles.heading3,
          ),
          const SizedBox(height: 8),
          Text(
            'Add stays with dates to see them on the timeline',
            style: TulipTextStyles.bodySmall,
            textAlign: TextAlign.center,
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

  Widget _buildTimeline(List<TimelineItem> items, DateRange dateRange) {
    final stayItems = items.where((i) => i.isStay).toList();
    final gapItems = items.where((i) => i.isGap).toList();
    final today = DateTime.now();
    final todayPosition = dateRange.positionFor(today);
    final showTodayMarker = todayPosition > 0 && todayPosition < 1;

    return Column(
      children: [
        // Month headers
        SizedBox(
          height: _headerHeight,
          child: SingleChildScrollView(
            controller: _headerScrollController,
            scrollDirection: Axis.horizontal,
            physics: const NeverScrollableScrollPhysics(),
            child: SizedBox(
              width: _timelineWidth,
              child: TimelineHeader(
                dateRange: dateRange,
                width: _timelineWidth,
              ),
            ),
          ),
        ),
        const Divider(height: 1),
        // Timeline content
        Expanded(
          child: SingleChildScrollView(
            controller: _scrollController,
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: _timelineWidth,
              child: Stack(
                children: [
                  // Grid lines (month dividers)
                  _buildMonthDividers(dateRange),
                  // Gap bars
                  ...gapItems.map((item) => _buildGapBar(item, dateRange)),
                  // Stay bars
                  ...stayItems.asMap().entries.map((entry) {
                    return _buildStayBar(entry.value, dateRange, entry.key);
                  }),
                  // Today marker
                  if (showTodayMarker)
                    Positioned(
                      left: todayPosition * _timelineWidth - 1,
                      top: 0,
                      bottom: 0,
                      child: Container(
                        width: 2,
                        color: TulipColors.roseDark,
                      ),
                    ),
                  // Today label
                  if (showTodayMarker)
                    Positioned(
                      left: todayPosition * _timelineWidth - 20,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: TulipColors.roseDark,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Today',
                          style: TulipTextStyles.caption.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
        // Legend
        _buildLegend(),
      ],
    );
  }

  Widget _buildMonthDividers(DateRange dateRange) {
    final dividers = <Widget>[];
    var current = DateTime(dateRange.start.year, dateRange.start.month, 1);

    while (current.isBefore(dateRange.end)) {
      final position = dateRange.positionFor(current);
      dividers.add(
        Positioned(
          left: position * _timelineWidth,
          top: 0,
          bottom: 0,
          child: Container(
            width: 1,
            color: TulipColors.taupeLight.withValues(alpha: 0.5),
          ),
        ),
      );
      current = DateTime(current.year, current.month + 1, 1);
    }

    return Stack(children: dividers);
  }

  Widget _buildStayBar(TimelineItem item, DateRange dateRange, int index) {
    final left = dateRange.positionFor(item.startDate) * _timelineWidth;
    final width = dateRange.widthFor(item.startDate, item.endDate) * _timelineWidth;
    final top = 40.0 + (index % 3) * _rowSpacing;

    return Positioned(
      left: left,
      top: top,
      width: width.clamp(80.0, double.infinity),
      height: _barHeight,
      child: TimelineBar(
        item: item,
        onTap: () {
          if (item.stay != null) {
            context.push('/stays/${item.stay!.id}');
          }
        },
      ),
    );
  }

  Widget _buildGapBar(TimelineItem item, DateRange dateRange) {
    final left = dateRange.positionFor(item.startDate) * _timelineWidth;
    final width = dateRange.widthFor(item.startDate, item.endDate) * _timelineWidth;

    if (width < 10) return const SizedBox.shrink();

    return Positioned(
      left: left,
      top: 40.0 + _rowSpacing,
      width: width,
      height: 24,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: TulipColors.coral,
            style: BorderStyle.solid,
          ),
          borderRadius: BorderRadius.circular(4),
        ),
        child: CustomPaint(
          painter: DiagonalStripesPainter(
            color: TulipColors.coral.withValues(alpha: 0.3),
          ),
          child: Center(
            child: Text(
              '${item.durationDays}d',
              style: TulipTextStyles.caption.copyWith(
                color: TulipColors.coralDark,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLegend() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: TulipColors.taupeLight),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildLegendItem('Upcoming', TulipColors.sage),
            const SizedBox(width: 16),
            _buildLegendItem('Current', TulipColors.rose),
            const SizedBox(width: 16),
            _buildLegendItem('Past', TulipColors.taupe),
            const SizedBox(width: 16),
            _buildLegendItem('Gap', TulipColors.coral),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 4),
        Text(label, style: TulipTextStyles.caption),
      ],
    );
  }
}

/// Custom painter for diagonal stripes (gap bars)
class DiagonalStripesPainter extends CustomPainter {
  final Color color;

  DiagonalStripesPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke;

    for (double i = -size.height; i < size.width; i += 8) {
      canvas.drawLine(
        Offset(i, size.height),
        Offset(i + size.height, 0),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
