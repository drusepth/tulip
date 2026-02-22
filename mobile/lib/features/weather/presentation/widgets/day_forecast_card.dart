import 'package:flutter/material.dart';
import '../../../../shared/constants/tulip_colors.dart';
import '../../../../shared/constants/tulip_text_styles.dart';
import 'condition_legend.dart';

/// Individual day forecast card for the day-by-day list
class DayForecastCard extends StatelessWidget {
  final Map<String, dynamic> dayData;

  const DayForecastCard({
    super.key,
    required this.dayData,
  });

  static const Map<String, Color> cardBackgrounds = {
    'Sunny': Color(0xFFFDF0E8),   // coral-light
    'Clear': Color(0xFFFDF0E8),   // coral-light (alias)
    'Cloudy': Color(0xFFEDEAEA),  // gray
    'Foggy': Color(0xFFEBE6E0),   // taupe-light
    'Rainy': Color(0xFFE6EDF2),   // blue-light
    'Snowy': Color(0xFFE8E4EF),   // lavender-light
    'Stormy': Color(0xFFEAE2E8),  // mauve
  };

  static Color getCardBackground(String condition) {
    return cardBackgrounds[condition] ?? cardBackgrounds['Sunny']!;
  }

  @override
  Widget build(BuildContext context) {
    final date = dayData['date'] as String?;
    final high = dayData['high'];
    final low = dayData['low'];
    final condition = dayData['condition'] as String? ?? 'Sunny';
    final feelsLikeHigh = dayData['feels_like_high'];
    final feelsLikeLow = dayData['feels_like_low'];
    final precipMm = dayData['precipitation_mm'];
    final precipHours = dayData['precipitation_hours'];
    final windSpeed = dayData['wind_speed'];
    final windGusts = dayData['wind_gusts'];
    final sunrise = dayData['sunrise'] as String?;
    final sunset = dayData['sunset'] as String?;

    // Parse date
    String dayName = '';
    String dateLabel = '';
    if (date != null) {
      final parsed = DateTime.tryParse(date);
      if (parsed != null) {
        final weekdays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
        final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
        dayName = weekdays[parsed.weekday - 1];
        dateLabel = '${months[parsed.month - 1]} ${parsed.day}';
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: getCardBackground(condition),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: ConditionLegend.getConditionColor(condition).withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Day header row
          Row(
            children: [
              // Day name and date
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      dayName,
                      style: TulipTextStyles.label.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      dateLabel,
                      style: TulipTextStyles.caption,
                    ),
                  ],
                ),
              ),
              // Condition emoji bubble
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: ConditionLegend.getConditionColor(condition),
                  shape: BoxShape.circle,
                ),
                child: Text(
                  ConditionLegend.getConditionEmoji(condition),
                  style: const TextStyle(fontSize: 20),
                ),
              ),
              const SizedBox(width: 12),
              // Temperatures
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      Text(
                        '${high ?? '--'}\u00B0',
                        style: TulipTextStyles.heading3.copyWith(
                          color: TulipColors.rose,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        ' / ',
                        style: TulipTextStyles.body.copyWith(
                          color: TulipColors.brownLighter,
                        ),
                      ),
                      Text(
                        '${low ?? '--'}\u00B0',
                        style: TulipTextStyles.heading3.copyWith(
                          color: TulipColors.sage,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    condition,
                    style: TulipTextStyles.caption,
                  ),
                ],
              ),
            ],
          ),

          // Additional details
          if (_hasAdditionalDetails())
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Wrap(
                spacing: 16,
                runSpacing: 8,
                children: [
                  // Feels like
                  if (feelsLikeHigh != null && feelsLikeLow != null &&
                      (feelsLikeHigh != high || feelsLikeLow != low))
                    _buildDetailChip(
                      icon: Icons.thermostat_outlined,
                      label: 'Feels like $feelsLikeHigh\u00B0/$feelsLikeLow\u00B0',
                      color: TulipColors.taupe,
                    ),

                  // Precipitation
                  if (precipMm != null && precipMm > 0)
                    _buildDetailChip(
                      icon: Icons.water_drop_outlined,
                      label: '${precipMm}mm${precipHours != null && precipHours > 0 ? ' over ${precipHours}h' : ''}',
                      color: TulipColors.lavender,
                    ),

                  // Wind
                  if (windSpeed != null && windSpeed > 10)
                    _buildDetailChip(
                      icon: Icons.air,
                      label: '${windSpeed}mph${windGusts != null && windGusts > windSpeed ? ' (gusts $windGusts)' : ''}',
                      color: TulipColors.sage,
                    ),

                  // Sunrise/Sunset
                  if (sunrise != null)
                    _buildDetailChip(
                      icon: Icons.wb_sunny_outlined,
                      label: _formatTime(sunrise),
                      color: TulipColors.coral,
                    ),
                  if (sunset != null)
                    _buildDetailChip(
                      icon: Icons.nightlight_outlined,
                      label: _formatTime(sunset),
                      color: TulipColors.lavenderDark,
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  bool _hasAdditionalDetails() {
    final feelsLikeHigh = dayData['feels_like_high'];
    final feelsLikeLow = dayData['feels_like_low'];
    final high = dayData['high'];
    final low = dayData['low'];
    final precipMm = dayData['precipitation_mm'];
    final windSpeed = dayData['wind_speed'];
    final sunrise = dayData['sunrise'];
    final sunset = dayData['sunset'];

    return (feelsLikeHigh != null && feelsLikeLow != null &&
            (feelsLikeHigh != high || feelsLikeLow != low)) ||
        (precipMm != null && precipMm > 0) ||
        (windSpeed != null && windSpeed > 10) ||
        sunrise != null ||
        sunset != null;
  }

  Widget _buildDetailChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 14,
          color: color,
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TulipTextStyles.caption.copyWith(
            color: TulipColors.brownLight,
          ),
        ),
      ],
    );
  }

  String _formatTime(String timeString) {
    // Try to parse ISO format and convert to readable time
    final parsed = DateTime.tryParse(timeString);
    if (parsed != null) {
      final hour = parsed.hour;
      final minute = parsed.minute.toString().padLeft(2, '0');
      final period = hour >= 12 ? 'PM' : 'AM';
      final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
      return '$displayHour:$minute $period';
    }
    return timeString;
  }
}
