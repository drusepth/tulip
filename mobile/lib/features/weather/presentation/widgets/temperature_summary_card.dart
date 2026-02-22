import 'package:flutter/material.dart';
import '../../../../shared/constants/tulip_colors.dart';
import '../../../../shared/constants/tulip_text_styles.dart';

/// Displays Low/Average/High temperature summary boxes
class TemperatureSummaryCard extends StatelessWidget {
  final num? low;
  final num? average;
  final num? high;

  const TemperatureSummaryCard({
    super.key,
    this.low,
    this.average,
    this.high,
  });

  @override
  Widget build(BuildContext context) {
    if (low == null && average == null && high == null) {
      return const SizedBox.shrink();
    }

    return Row(
      children: [
        if (low != null)
          Expanded(
            child: _TemperatureBox(
              label: 'Low',
              value: low!.round(),
              color: TulipColors.sage,
              backgroundColor: TulipColors.sageLight,
            ),
          ),
        if (low != null && average != null)
          const SizedBox(width: 12),
        if (average != null)
          Expanded(
            child: _TemperatureBox(
              label: 'Average',
              value: average!.round(),
              color: TulipColors.taupe,
              backgroundColor: TulipColors.taupeLight,
            ),
          ),
        if ((low != null || average != null) && high != null)
          const SizedBox(width: 12),
        if (high != null)
          Expanded(
            child: _TemperatureBox(
              label: 'High',
              value: high!.round(),
              color: TulipColors.rose,
              backgroundColor: TulipColors.roseLight,
            ),
          ),
      ],
    );
  }
}

class _TemperatureBox extends StatelessWidget {
  final String label;
  final int value;
  final Color color;
  final Color backgroundColor;

  const _TemperatureBox({
    required this.label,
    required this.value,
    required this.color,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TulipTextStyles.caption.copyWith(
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$value',
                style: TulipTextStyles.heading1.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  '\u00B0F',
                  style: TulipTextStyles.body.copyWith(
                    color: color,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
