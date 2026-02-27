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

    // Use darker text on lighter background for better readability
    const textColor = Color(0xFF5D4037); // Warm brown
    const textColorLight = Color(0xFF8D6E63); // Lighter brown

    return GestureDetector(
      onTap: () => context.push('/stays/${widget.nextTrip!.id}'),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFFFDF0E8), // Warm cream
              const Color(0xFFF5E1D8), // Soft peach
            ],
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: TulipColors.coral.withValues(alpha: 0.3),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: TulipColors.coral.withValues(alpha: 0.15),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          children: [
            // Subtle label at top with accent color
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: TulipColors.coral.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Next Trip',
                style: TulipTextStyles.caption.copyWith(
                  color: TulipColors.coralDark,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Prominent destination with icon
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.flight_takeoff,
                  size: 22,
                  color: TulipColors.coral,
                ),
                const SizedBox(width: 10),
                Flexible(
                  child: Text(
                    widget.nextTrip!.location,
                    style: TulipTextStyles.heading1.copyWith(
                      fontSize: 26,
                      color: textColor,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Countdown - days only
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '$days',
                    style: TulipTextStyles.heading2.copyWith(
                      color: textColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    days == 1 ? 'day away' : 'days away',
                    style: TulipTextStyles.body.copyWith(
                      color: textColorLight,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
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

    const textColor = Color(0xFF5D4037);
    const textColorLight = Color(0xFF8D6E63);

    final String motivationalText;
    if (dayNumber == 1) {
      motivationalText = 'Your adventure begins!';
    } else if (dayNumber == totalDays) {
      motivationalText = 'Savor your final day';
    } else if (progress < 0.5) {
      motivationalText = 'Enjoy every moment';
    } else {
      motivationalText = 'Make the most of it';
    }

    return GestureDetector(
      onTap: () => context.push('/stays/${stay.id}'),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFF0E4EF), // Warm lavender cream
              Color(0xFFF0E0E0), // Soft rose
            ],
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: TulipColors.lavender.withValues(alpha: 0.3),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: TulipColors.lavender.withValues(alpha: 0.15),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          children: [
            // "You're Here!" pill badge with sparkle
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: TulipColors.rose.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.auto_awesome,
                    size: 14,
                    color: TulipColors.roseDark,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    "You're here!",
                    style: TulipTextStyles.caption.copyWith(
                      color: TulipColors.roseDark,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Greeting
            Text(
              _getGreeting(),
              style: TulipTextStyles.body.copyWith(
                color: textColorLight,
              ),
            ),
            const SizedBox(height: 8),

            // Location
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.location_on,
                  size: 22,
                  color: TulipColors.rose,
                ),
                const SizedBox(width: 10),
                Flexible(
                  child: Text(
                    stay.location,
                    style: TulipTextStyles.heading1.copyWith(
                      fontSize: 26,
                      color: textColor,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Day progress in frosted pill
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Day $dayNumber',
                        style: TulipTextStyles.heading2.copyWith(
                          color: textColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'of $totalDays',
                        style: TulipTextStyles.body.copyWith(
                          color: textColorLight,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: progress.clamp(0.0, 1.0),
                      backgroundColor: TulipColors.cream,
                      valueColor: AlwaysStoppedAnimation<Color>(TulipColors.rose),
                      minHeight: 10,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Motivational text
            Text(
              motivationalText,
              style: TulipTextStyles.caption.copyWith(
                color: TulipColors.roseDark,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
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
