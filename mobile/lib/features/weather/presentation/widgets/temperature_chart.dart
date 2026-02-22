import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../shared/constants/tulip_colors.dart';
import '../../../../shared/constants/tulip_text_styles.dart';

/// Line chart showing daily high and low temperatures
class TemperatureChart extends StatelessWidget {
  final List<dynamic> dailyData;

  const TemperatureChart({
    super.key,
    required this.dailyData,
  });

  // Chart colors matching web version
  static const highColor = Color(0xFFC9A4A4);  // rose
  static const lowColor = Color(0xFF8FAE8B);   // sage

  @override
  Widget build(BuildContext context) {
    if (dailyData.isEmpty) {
      return const SizedBox.shrink();
    }

    final spots = _generateSpots();
    if (spots.highSpots.isEmpty) {
      return const SizedBox.shrink();
    }

    final minY = spots.minTemp - 5;
    final maxY = spots.maxTemp + 5;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Temperature Trends',
          style: TulipTextStyles.label,
        ),
        const SizedBox(height: 8),
        // Legend
        Row(
          children: [
            _buildLegendItem('High', highColor),
            const SizedBox(width: 16),
            _buildLegendItem('Low', lowColor),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 200,
          child: LineChart(
            LineChartData(
              minY: minY,
              maxY: maxY,
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: 10,
                getDrawingHorizontalLine: (value) {
                  return FlLine(
                    color: TulipColors.taupeLight,
                    strokeWidth: 1,
                  );
                },
              ),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40,
                    interval: 10,
                    getTitlesWidget: (value, meta) {
                      return Text(
                        '${value.toInt()}\u00B0',
                        style: TulipTextStyles.caption,
                      );
                    },
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 30,
                    interval: _calculateInterval(),
                    getTitlesWidget: (value, meta) {
                      final index = value.toInt();
                      if (index < 0 || index >= dailyData.length) {
                        return const SizedBox.shrink();
                      }
                      final day = dailyData[index] as Map<String, dynamic>;
                      final date = day['date'] as String?;
                      if (date == null) return const SizedBox.shrink();

                      final parsed = DateTime.tryParse(date);
                      if (parsed == null) return const SizedBox.shrink();

                      return Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          '${parsed.month}/${parsed.day}',
                          style: TulipTextStyles.caption,
                        ),
                      );
                    },
                  ),
                ),
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
              ),
              borderData: FlBorderData(show: false),
              lineTouchData: LineTouchData(
                enabled: true,
                touchTooltipData: LineTouchTooltipData(
                  getTooltipColor: (spot) => Colors.white,
                  tooltipBorder: BorderSide(color: TulipColors.taupeLight),
                  tooltipRoundedRadius: 8,
                  getTooltipItems: (touchedSpots) {
                    return touchedSpots.map((spot) {
                      final isHigh = spot.barIndex == 0;
                      return LineTooltipItem(
                        '${isHigh ? 'High' : 'Low'}: ${spot.y.toInt()}\u00B0F',
                        TulipTextStyles.caption.copyWith(
                          color: isHigh ? highColor : lowColor,
                          fontWeight: FontWeight.w600,
                        ),
                      );
                    }).toList();
                  },
                ),
              ),
              lineBarsData: [
                // High temperature line
                LineChartBarData(
                  spots: spots.highSpots,
                  isCurved: true,
                  curveSmoothness: 0.3,
                  color: highColor,
                  barWidth: 3,
                  isStrokeCapRound: true,
                  dotData: FlDotData(
                    show: true,
                    getDotPainter: (spot, percent, barData, index) {
                      return FlDotCirclePainter(
                        radius: 4,
                        color: Colors.white,
                        strokeWidth: 2,
                        strokeColor: highColor,
                      );
                    },
                  ),
                  belowBarData: BarAreaData(
                    show: true,
                    color: highColor.withValues(alpha: 0.1),
                  ),
                ),
                // Low temperature line
                LineChartBarData(
                  spots: spots.lowSpots,
                  isCurved: true,
                  curveSmoothness: 0.3,
                  color: lowColor,
                  barWidth: 3,
                  isStrokeCapRound: true,
                  dotData: FlDotData(
                    show: true,
                    getDotPainter: (spot, percent, barData, index) {
                      return FlDotCirclePainter(
                        radius: 4,
                        color: Colors.white,
                        strokeWidth: 2,
                        strokeColor: lowColor,
                      );
                    },
                  ),
                  belowBarData: BarAreaData(
                    show: true,
                    color: lowColor.withValues(alpha: 0.1),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 3,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TulipTextStyles.caption,
        ),
      ],
    );
  }

  double _calculateInterval() {
    if (dailyData.length <= 7) return 1;
    if (dailyData.length <= 14) return 2;
    return (dailyData.length / 7).ceil().toDouble();
  }

  _ChartSpots _generateSpots() {
    final highSpots = <FlSpot>[];
    final lowSpots = <FlSpot>[];
    double minTemp = double.infinity;
    double maxTemp = double.negativeInfinity;

    for (int i = 0; i < dailyData.length; i++) {
      final day = dailyData[i] as Map<String, dynamic>;
      final high = day['high'];
      final low = day['low'];

      if (high != null) {
        final highVal = (high as num).toDouble();
        highSpots.add(FlSpot(i.toDouble(), highVal));
        if (highVal > maxTemp) maxTemp = highVal;
      }

      if (low != null) {
        final lowVal = (low as num).toDouble();
        lowSpots.add(FlSpot(i.toDouble(), lowVal));
        if (lowVal < minTemp) minTemp = lowVal;
      }
    }

    return _ChartSpots(
      highSpots: highSpots,
      lowSpots: lowSpots,
      minTemp: minTemp.isFinite ? minTemp : 0,
      maxTemp: maxTemp.isFinite ? maxTemp : 100,
    );
  }
}

class _ChartSpots {
  final List<FlSpot> highSpots;
  final List<FlSpot> lowSpots;
  final double minTemp;
  final double maxTemp;

  _ChartSpots({
    required this.highSpots,
    required this.lowSpots,
    required this.minTemp,
    required this.maxTemp,
  });
}
