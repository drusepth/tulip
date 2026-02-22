import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../constants/tulip_colors.dart';
import '../constants/tulip_text_styles.dart';
import 'cozy_card.dart';
import '../../features/stays/data/models/stay_model.dart';

class CountdownHero extends StatefulWidget {
  final Stay? nextTrip;
  final Stay? currentStay;
  final VoidCallback? onAddStay;

  const CountdownHero({
    super.key,
    this.nextTrip,
    this.currentStay,
    this.onAddStay,
  });

  @override
  State<CountdownHero> createState() => _CountdownHeroState();
}

class _CountdownHeroState extends State<CountdownHero> {
  Timer? _timer;
  Duration _timeUntilTrip = Duration.zero;

  @override
  void initState() {
    super.initState();
    _updateCountdown();
    // Update every minute since we no longer display seconds
    _timer = Timer.periodic(const Duration(minutes: 1), (_) {
      _updateCountdown();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _updateCountdown() {
    if (widget.nextTrip?.checkIn != null) {
      final now = DateTime.now();
      final checkIn = widget.nextTrip!.checkIn!;
      if (checkIn.isAfter(now)) {
        setState(() {
          _timeUntilTrip = checkIn.difference(now);
        });
      }
    }
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good morning';
    } else if (hour < 17) {
      return 'Good afternoon';
    } else {
      return 'Good evening';
    }
  }

  @override
  Widget build(BuildContext context) {
    // Currently on a trip
    if (widget.currentStay != null) {
      return _buildCurrentStayHero();
    }

    // Upcoming trip exists
    if (widget.nextTrip != null && widget.nextTrip!.checkIn != null) {
      return _buildCountdownHero();
    }

    // No upcoming trips
    return _buildNoTripsHero();
  }

  Widget _buildCountdownHero() {
    final days = _timeUntilTrip.inDays;
    final hours = _timeUntilTrip.inHours.remainder(24);
    final minutes = _timeUntilTrip.inMinutes.remainder(60);

    return CozyCard(
      backgroundColor: TulipColors.cream,
      onTap: () => context.push('/stays/${widget.nextTrip!.id}'),
      child: Column(
        children: [
          // Subtle label at top
          Text(
            'Next Trip',
            style: TulipTextStyles.caption.copyWith(
              color: TulipColors.brownLight,
            ),
          ),
          const SizedBox(height: 12),

          // Prominent destination with icon
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.flight_takeoff,
                size: 20,
                color: TulipColors.sage,
              ),
              const SizedBox(width: 8),
              Text(
                widget.nextTrip!.location,
                style: TulipTextStyles.heading1.copyWith(
                  fontSize: 28,
                  color: TulipColors.brown,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Clean inline countdown without boxes
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '$days',
                style: TulipTextStyles.body.copyWith(
                  fontWeight: FontWeight.bold,
                  color: TulipColors.brown,
                ),
              ),
              Text(
                ' days',
                style: TulipTextStyles.body.copyWith(
                  color: TulipColors.brownLight,
                ),
              ),
              Text(
                ' · ',
                style: TulipTextStyles.body.copyWith(
                  color: TulipColors.brownLighter,
                ),
              ),
              Text(
                '$hours',
                style: TulipTextStyles.body.copyWith(
                  fontWeight: FontWeight.bold,
                  color: TulipColors.brown,
                ),
              ),
              Text(
                ' hrs',
                style: TulipTextStyles.body.copyWith(
                  color: TulipColors.brownLight,
                ),
              ),
              Text(
                ' · ',
                style: TulipTextStyles.body.copyWith(
                  color: TulipColors.brownLighter,
                ),
              ),
              Text(
                '$minutes',
                style: TulipTextStyles.body.copyWith(
                  fontWeight: FontWeight.bold,
                  color: TulipColors.brown,
                ),
              ),
              Text(
                ' min',
                style: TulipTextStyles.body.copyWith(
                  color: TulipColors.brownLight,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentStayHero() {
    final stay = widget.currentStay!;
    final now = DateTime.now();

    int dayNumber = 1;
    int totalDays = stay.durationDays;

    if (stay.checkIn != null) {
      dayNumber = now.difference(stay.checkIn!).inDays + 1;
    }

    final progress = totalDays > 0 ? dayNumber / totalDays : 0.0;

    return CozyCard(
      backgroundColor: TulipColors.cream,
      onTap: () => context.push('/stays/${stay.id}'),
      child: Column(
        children: [
          Text(
            _getGreeting(),
            style: TulipTextStyles.heading2,
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.location_on,
                color: TulipColors.rose,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                stay.location,
                style: TulipTextStyles.heading3.copyWith(
                  color: TulipColors.roseDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: BoxDecoration(
              color: TulipColors.roseLight,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: TulipColors.rose),
            ),
            child: Column(
              children: [
                Text(
                  'Day $dayNumber of $totalDays',
                  style: TulipTextStyles.heading2.copyWith(
                    color: TulipColors.roseDark,
                  ),
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress.clamp(0.0, 1.0),
                    backgroundColor: TulipColors.cream,
                    valueColor: AlwaysStoppedAnimation<Color>(TulipColors.rose),
                    minHeight: 8,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoTripsHero() {
    return CozyCard(
      backgroundColor: TulipColors.cream,
      onTap: widget.onAddStay,
      child: Column(
        children: [
          Text(
            _getGreeting(),
            style: TulipTextStyles.heading2,
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: TulipColors.lavenderLight,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.flight_takeoff,
              size: 40,
              color: TulipColors.lavenderDark,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Plan your next adventure',
            style: TulipTextStyles.heading3.copyWith(
              color: TulipColors.lavenderDark,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Where will your travels take you?',
            style: TulipTextStyles.bodySmall,
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: TulipColors.lavender,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.add,
                  size: 18,
                  color: Colors.white,
                ),
                const SizedBox(width: 6),
                Text(
                  'Add a stay',
                  style: TulipTextStyles.label.copyWith(
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
