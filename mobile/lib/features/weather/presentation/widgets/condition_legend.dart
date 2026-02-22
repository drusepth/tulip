import 'package:flutter/material.dart';
import '../../../../shared/constants/tulip_text_styles.dart';

/// Color legend for weather conditions
class ConditionLegend extends StatelessWidget {
  const ConditionLegend({super.key});

  static const Map<String, Color> conditionColors = {
    'Sunny': Color(0xFFE8B4A0),    // coral
    'Clear': Color(0xFFE8B4A0),    // coral (alias)
    'Cloudy': Color(0xFFCBD5E1),   // slate-300
    'Foggy': Color(0xFFC9B8A8),    // taupe
    'Rainy': Color(0xFF9BB8C9),    // dusty blue
    'Snowy': Color(0xFFA5F3FC),    // cyan-200
    'Stormy': Color(0xFF9E92B0),   // lavender-dark
  };

  static Color getConditionColor(String condition) {
    return conditionColors[condition] ?? conditionColors['Sunny']!;
  }

  static String getConditionEmoji(String condition) {
    switch (condition.toLowerCase()) {
      case 'sunny':
      case 'clear':
        return '\u2600\uFE0F'; // sun emoji
      case 'cloudy':
        return '\u2601\uFE0F'; // cloud emoji
      case 'foggy':
        return '\uD83C\uDF2B\uFE0F'; // fog emoji
      case 'rainy':
        return '\uD83C\uDF27\uFE0F'; // rain emoji
      case 'snowy':
        return '\u2744\uFE0F'; // snowflake emoji
      case 'stormy':
        return '\u26C8\uFE0F'; // storm emoji
      default:
        return '\u2600\uFE0F';
    }
  }

  @override
  Widget build(BuildContext context) {
    // Only show unique conditions (not Clear since it's an alias for Sunny)
    final displayConditions = ['Sunny', 'Cloudy', 'Foggy', 'Rainy', 'Snowy', 'Stormy'];

    return Wrap(
      spacing: 12,
      runSpacing: 8,
      children: displayConditions.map((condition) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: conditionColors[condition],
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: 4),
            Text(
              condition,
              style: TulipTextStyles.caption,
            ),
          ],
        );
      }).toList(),
    );
  }
}
