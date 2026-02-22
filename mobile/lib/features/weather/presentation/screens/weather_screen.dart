import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/constants/tulip_colors.dart';
import '../../../../shared/constants/tulip_text_styles.dart';
import '../../../../shared/widgets/cozy_card.dart';
import '../../../stays/presentation/providers/stays_provider.dart';
import '../widgets/temperature_summary_card.dart';
import '../widgets/temperature_chart.dart';
import '../widgets/conditions_grid.dart';
import '../widgets/day_forecast_card.dart';

/// Dedicated weather screen showing detailed forecast
class WeatherScreen extends ConsumerWidget {
  final int stayId;
  final String? stayTitle;

  const WeatherScreen({
    super.key,
    required this.stayId,
    this.stayTitle,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weatherAsync = ref.watch(stayWeatherProvider(stayId));
    final stayAsync = ref.watch(stayDetailProvider(stayId));

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Weather Forecast',
          style: TulipTextStyles.heading3,
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      backgroundColor: TulipColors.cream,
      body: weatherAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: TulipColors.sage),
        ),
        error: (error, stack) => _buildError(context, ref, error),
        data: (weatherData) => _buildContent(context, ref, weatherData, stayAsync),
      ),
    );
  }

  Widget _buildError(BuildContext context, WidgetRef ref, Object error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.cloud_off_outlined,
              size: 64,
              color: TulipColors.brownLighter,
            ),
            const SizedBox(height: 16),
            Text(
              'Unable to load weather data',
              style: TulipTextStyles.heading3,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              error.toString(),
              style: TulipTextStyles.bodySmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => ref.invalidate(stayWeatherProvider(stayId)),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    Map<String, dynamic> weatherData,
    AsyncValue<dynamic> stayAsync,
  ) {
    final weather = weatherData['weather'] as Map<String, dynamic>?;
    final dailyData = weatherData['daily_data'] as List<dynamic>? ?? [];

    if (weather == null) {
      return _buildNoWeatherData(context);
    }

    final low = weather['low'];
    final high = weather['high'];
    final average = weather['average'];

    // Get stay info for header
    String title = stayTitle ?? 'Your Trip';
    String? dateRange;
    stayAsync.whenData((stay) {
      if (stay != null) {
        title = stay.title;
        dateRange = stay.dateRange;
      }
    });

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(stayWeatherProvider(stayId));
      },
      color: TulipColors.sage,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with stay info
            _buildHeader(title, dateRange, dailyData.length),
            const SizedBox(height: 20),

            // Temperature summary card
            TemperatureSummaryCard(
              low: low,
              average: average,
              high: high,
            ),
            const SizedBox(height: 24),

            // Temperature chart
            CozyCard(
              child: TemperatureChart(dailyData: dailyData),
            ),
            const SizedBox(height: 24),

            // Conditions grid
            CozyCard(
              child: ConditionsGrid(dailyData: dailyData),
            ),
            const SizedBox(height: 24),

            // Day-by-day forecast
            Text(
              'Day-by-Day Forecast',
              style: TulipTextStyles.label,
            ),
            const SizedBox(height: 12),
            ...dailyData.map((day) => DayForecastCard(
              dayData: day as Map<String, dynamic>,
            )),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(String title, String? dateRange, int dayCount) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TulipTextStyles.heading2,
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            if (dateRange != null) ...[
              Icon(
                Icons.calendar_today_outlined,
                size: 14,
                color: TulipColors.brownLight,
              ),
              const SizedBox(width: 4),
              Text(
                dateRange,
                style: TulipTextStyles.bodySmall,
              ),
              const SizedBox(width: 12),
            ],
            Text(
              '$dayCount days',
              style: TulipTextStyles.bodySmall,
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: TulipColors.lavenderLight,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.history,
                size: 14,
                color: TulipColors.lavenderDark,
              ),
              const SizedBox(width: 6),
              Text(
                'Based on historical weather data',
                style: TulipTextStyles.caption.copyWith(
                  color: TulipColors.lavenderDark,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNoWeatherData(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.wb_cloudy_outlined,
              size: 64,
              color: TulipColors.brownLighter,
            ),
            const SizedBox(height: 16),
            Text(
              'No weather data available',
              style: TulipTextStyles.heading3,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Weather information will be available once the stay has valid dates and location.',
              style: TulipTextStyles.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
