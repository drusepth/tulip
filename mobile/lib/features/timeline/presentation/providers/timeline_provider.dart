import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../stays/data/models/stay_model.dart';
import '../../../stays/presentation/providers/stays_provider.dart';

/// Timeline item representing either a stay or a gap between stays
class TimelineItem {
  final Stay? stay;
  final DateTime startDate;
  final DateTime endDate;
  final bool isGap;
  final int row;

  const TimelineItem({
    this.stay,
    required this.startDate,
    required this.endDate,
    this.isGap = false,
    this.row = 0,
  });

  int get durationDays => endDate.difference(startDate).inDays;

  bool get isStay => stay != null;
}

/// Provider for timeline items (stays + gaps)
final timelineItemsProvider = Provider<List<TimelineItem>>((ref) {
  final staysAsync = ref.watch(staysProvider);

  return staysAsync.when(
    data: (stays) => _buildTimelineItems(stays),
    loading: () => [],
    error: (_, __) => [],
  );
});

/// Build timeline items from stays, inserting gaps where appropriate
List<TimelineItem> _buildTimelineItems(List<Stay> stays) {
  // Filter stays with dates and sort by check-in
  final validStays = stays
      .where((s) => s.checkIn != null && s.checkOut != null)
      .toList()
    ..sort((a, b) => a.checkIn!.compareTo(b.checkIn!));

  if (validStays.isEmpty) return [];

  final items = <TimelineItem>[];

  for (int i = 0; i < validStays.length; i++) {
    final stay = validStays[i];

    // Add gap before this stay if there's one
    if (i > 0) {
      final prevStay = validStays[i - 1];
      final gapStart = prevStay.checkOut!;
      final gapEnd = stay.checkIn!;

      if (gapEnd.isAfter(gapStart)) {
        final gapDays = gapEnd.difference(gapStart).inDays;
        if (gapDays > 0) {
          items.add(TimelineItem(
            startDate: gapStart,
            endDate: gapEnd,
            isGap: true,
          ));
        }
      }
    }

    // Add the stay
    items.add(TimelineItem(
      stay: stay,
      startDate: stay.checkIn!,
      endDate: stay.checkOut!,
    ));
  }

  return items;
}

/// Provider for timeline date range
final timelineDateRangeProvider = Provider<DateRange?>((ref) {
  final items = ref.watch(timelineItemsProvider);
  if (items.isEmpty) return null;

  final stayItems = items.where((i) => i.isStay).toList();
  if (stayItems.isEmpty) return null;

  // Get min and max dates with padding
  final minDate = stayItems.map((i) => i.startDate).reduce((a, b) => a.isBefore(b) ? a : b);
  final maxDate = stayItems.map((i) => i.endDate).reduce((a, b) => a.isAfter(b) ? a : b);

  // Add 1 month padding on each side
  return DateRange(
    start: DateTime(minDate.year, minDate.month - 1, 1),
    end: DateTime(maxDate.year, maxDate.month + 2, 0),
  );
});

class DateRange {
  final DateTime start;
  final DateTime end;

  const DateRange({required this.start, required this.end});

  int get totalDays => end.difference(start).inDays;

  /// Calculate percentage position for a date
  double positionFor(DateTime date) {
    final days = date.difference(start).inDays;
    return (days / totalDays).clamp(0.0, 1.0);
  }

  /// Calculate percentage width for a duration
  double widthFor(DateTime start, DateTime end) {
    final days = end.difference(start).inDays;
    return (days / totalDays).clamp(0.0, 1.0);
  }
}
