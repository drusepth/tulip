import 'package:flutter/material.dart';
import '../../../../shared/constants/tulip_colors.dart';
import '../../../../shared/constants/tulip_text_styles.dart';
import '../providers/timeline_provider.dart';

/// Timeline header showing months
class TimelineHeader extends StatelessWidget {
  final DateRange dateRange;
  final double width;

  const TimelineHeader({
    super.key,
    required this.dateRange,
    required this.width,
  });

  static const _monthNames = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
  ];

  static const _shortMonthNames = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];

  @override
  Widget build(BuildContext context) {
    final months = <_MonthEntry>[];
    var current = DateTime(dateRange.start.year, dateRange.start.month, 1);

    while (current.isBefore(dateRange.end)) {
      final nextMonth = DateTime(current.year, current.month + 1, 1);
      final monthEnd = nextMonth.isBefore(dateRange.end) ? nextMonth : dateRange.end;

      final startPos = dateRange.positionFor(current);
      final endPos = dateRange.positionFor(monthEnd);

      months.add(_MonthEntry(
        month: current.month,
        year: current.year,
        left: startPos * width,
        width: (endPos - startPos) * width,
      ));

      current = nextMonth;
    }

    return Stack(
      children: months.map((entry) {
        final isCurrentMonth = entry.month == DateTime.now().month &&
            entry.year == DateTime.now().year;
        final useShort = entry.width < 80;

        return Positioned(
          left: entry.left,
          top: 0,
          bottom: 0,
          width: entry.width,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: isCurrentMonth
                  ? TulipColors.roseLight.withValues(alpha: 0.3)
                  : Colors.transparent,
              border: Border(
                left: BorderSide(
                  color: TulipColors.taupeLight,
                  width: 1,
                ),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  useShort
                      ? _shortMonthNames[entry.month - 1]
                      : _monthNames[entry.month - 1],
                  style: TulipTextStyles.label.copyWith(
                    color: isCurrentMonth ? TulipColors.roseDark : TulipColors.brown,
                    fontWeight: isCurrentMonth ? FontWeight.w600 : FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (!useShort)
                  Text(
                    '${entry.year}',
                    style: TulipTextStyles.caption.copyWith(
                      color: TulipColors.brownLighter,
                    ),
                  ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _MonthEntry {
  final int month;
  final int year;
  final double left;
  final double width;

  _MonthEntry({
    required this.month,
    required this.year,
    required this.left,
    required this.width,
  });
}
