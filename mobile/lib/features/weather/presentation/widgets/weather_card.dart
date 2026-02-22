import 'package:flutter/material.dart';
import '../../../../shared/constants/tulip_colors.dart';
import '../../../../shared/constants/tulip_text_styles.dart';
import '../../../../shared/widgets/cozy_card.dart';

/// Enhanced weather display widget with daily breakdown
class WeatherCard extends StatelessWidget {
  final Map<String, dynamic> weatherData;

  const WeatherCard({super.key, required this.weatherData});

  @override
  Widget build(BuildContext context) {
    final weather = weatherData['weather'] as Map<String, dynamic>?;
    final dailyData = weatherData['daily_data'] as List<dynamic>? ?? [];

    if (weather == null) return const SizedBox.shrink();

    final low = weather['low'];
    final high = weather['high'];
    final average = weather['average'];
    final conditions = weather['conditions'] as Map<String, dynamic>?;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Summary card
        CozyCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.thermostat_outlined,
                    size: 20,
                    color: TulipColors.brownLight,
                  ),
                  const SizedBox(width: 8),
                  Text('Expected Weather', style: TulipTextStyles.label),
                  const Spacer(),
                  if (dailyData.isNotEmpty)
                    Text(
                      '${dailyData.length} days',
                      style: TulipTextStyles.caption,
                    ),
                ],
              ),
              const SizedBox(height: 16),

              // Temperature summary
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (low != null && high != null) ...[
                    _buildTempDisplay(
                      low.toString(),
                      'Low',
                      TulipColors.lavender,
                    ),
                    const SizedBox(width: 24),
                    _buildTempDisplay(
                      high.toString(),
                      'High',
                      TulipColors.coral,
                    ),
                    if (average != null) ...[
                      const SizedBox(width: 24),
                      _buildTempDisplay(
                        average.toString(),
                        'Avg',
                        TulipColors.sage,
                      ),
                    ],
                  ],
                  const Spacer(),
                  // Weather conditions summary
                  if (conditions != null && conditions.isNotEmpty)
                    _buildConditionsSummary(conditions),
                ],
              ),
            ],
          ),
        ),

        // Daily forecast
        if (dailyData.isNotEmpty) ...[
          const SizedBox(height: 12),
          SizedBox(
            height: 130,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: dailyData.length,
              itemBuilder: (context, index) {
                final day = dailyData[index] as Map<String, dynamic>;
                return _DailyWeatherTile(day: day, isFirst: index == 0);
              },
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildTempDisplay(String temp, String label, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TulipTextStyles.caption,
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              temp,
              style: TulipTextStyles.heading2.copyWith(
                color: color,
              ),
            ),
            Text(
              '\u00B0F',
              style: TulipTextStyles.bodySmall.copyWith(
                color: color,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildConditionsSummary(Map<String, dynamic> conditions) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: conditions.entries.take(2).map((entry) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _getConditionIcon(entry.key),
              size: 14,
              color: _getConditionColor(entry.key),
            ),
            const SizedBox(width: 4),
            Text(
              '${entry.key} ${entry.value}d',
              style: TulipTextStyles.caption.copyWith(
                color: TulipColors.brownLight,
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  IconData _getConditionIcon(String condition) {
    switch (condition.toLowerCase()) {
      case 'sunny':
        return Icons.wb_sunny;
      case 'cloudy':
        return Icons.cloud;
      case 'rainy':
        return Icons.water_drop;
      case 'snowy':
        return Icons.ac_unit;
      case 'stormy':
        return Icons.thunderstorm;
      case 'foggy':
        return Icons.foggy;
      default:
        return Icons.wb_sunny;
    }
  }

  Color _getConditionColor(String condition) {
    switch (condition.toLowerCase()) {
      case 'sunny':
        return TulipColors.coral;
      case 'cloudy':
        return TulipColors.brownLight;
      case 'rainy':
        return TulipColors.lavender;
      case 'snowy':
        return TulipColors.sage;
      case 'stormy':
        return TulipColors.roseDark;
      case 'foggy':
        return TulipColors.taupe;
      default:
        return TulipColors.brownLight;
    }
  }
}

class _DailyWeatherTile extends StatelessWidget {
  final Map<String, dynamic> day;
  final bool isFirst;

  const _DailyWeatherTile({required this.day, required this.isFirst});

  @override
  Widget build(BuildContext context) {
    final date = day['date'] as String?;
    final high = day['high'];
    final low = day['low'];
    final condition = day['condition'] as String? ?? 'Sunny';
    final precipMm = day['precipitation_mm'];
    final windSpeed = day['wind_speed'];

    // Parse date to get day name
    String dayLabel = '';
    String dateLabel = '';
    if (date != null) {
      final parsed = DateTime.tryParse(date);
      if (parsed != null) {
        final weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
        dayLabel = weekdays[parsed.weekday - 1];
        dateLabel = '${parsed.month}/${parsed.day}';
      }
    }

    return Container(
      width: 80,
      margin: EdgeInsets.only(left: isFirst ? 0 : 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: TulipColors.taupeLight),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Day name
            Text(
              dayLabel,
              style: TulipTextStyles.label.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              dateLabel,
              style: TulipTextStyles.caption,
            ),

            // Weather icon
            Icon(
              _getConditionIcon(condition),
              size: 28,
              color: _getConditionColor(condition),
            ),

            // Temperature
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${high ?? '--'}\u00B0',
                  style: TulipTextStyles.body.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  '${low ?? '--'}\u00B0',
                  style: TulipTextStyles.caption,
                ),
              ],
            ),

            // Extra info (precipitation or wind)
            if (precipMm != null && precipMm > 0)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.water_drop,
                    size: 10,
                    color: TulipColors.lavender,
                  ),
                  const SizedBox(width: 2),
                  Text(
                    '${precipMm}mm',
                    style: TulipTextStyles.caption.copyWith(
                      fontSize: 10,
                    ),
                  ),
                ],
              )
            else if (windSpeed != null && windSpeed > 15)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.air,
                    size: 10,
                    color: TulipColors.sage,
                  ),
                  const SizedBox(width: 2),
                  Text(
                    '${windSpeed}mph',
                    style: TulipTextStyles.caption.copyWith(
                      fontSize: 10,
                    ),
                  ),
                ],
              )
            else
              const SizedBox(height: 14),
          ],
        ),
      ),
    );
  }

  IconData _getConditionIcon(String condition) {
    switch (condition.toLowerCase()) {
      case 'sunny':
        return Icons.wb_sunny;
      case 'cloudy':
        return Icons.cloud;
      case 'rainy':
        return Icons.water_drop;
      case 'snowy':
        return Icons.ac_unit;
      case 'stormy':
        return Icons.thunderstorm;
      case 'foggy':
        return Icons.foggy;
      default:
        return Icons.wb_sunny;
    }
  }

  Color _getConditionColor(String condition) {
    switch (condition.toLowerCase()) {
      case 'sunny':
        return TulipColors.coral;
      case 'cloudy':
        return TulipColors.brownLight;
      case 'rainy':
        return TulipColors.lavender;
      case 'snowy':
        return TulipColors.sage;
      case 'stormy':
        return TulipColors.roseDark;
      case 'foggy':
        return TulipColors.taupe;
      default:
        return TulipColors.brownLight;
    }
  }
}
