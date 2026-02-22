import 'package:flutter/material.dart';
import '../../../../shared/constants/tulip_text_styles.dart';
import 'condition_legend.dart';

/// Colored grid showing daily weather conditions
class ConditionsGrid extends StatelessWidget {
  final List<dynamic> dailyData;

  const ConditionsGrid({
    super.key,
    required this.dailyData,
  });

  @override
  Widget build(BuildContext context) {
    if (dailyData.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Conditions Overview',
          style: TulipTextStyles.label,
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 4,
          runSpacing: 4,
          children: dailyData.map((day) {
            final dayMap = day as Map<String, dynamic>;
            final condition = dayMap['condition'] as String? ?? 'Sunny';
            final date = dayMap['date'] as String?;

            String dayLabel = '';
            if (date != null) {
              final parsed = DateTime.tryParse(date);
              if (parsed != null) {
                dayLabel = '${parsed.month}/${parsed.day}';
              }
            }

            return Tooltip(
              message: '$dayLabel: $condition',
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: ConditionLegend.getConditionColor(condition),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Center(
                  child: Text(
                    ConditionLegend.getConditionEmoji(condition),
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
        const ConditionLegend(),
      ],
    );
  }
}
