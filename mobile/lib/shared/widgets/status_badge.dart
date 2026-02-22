import 'package:flutter/material.dart';
import '../constants/tulip_colors.dart';
import '../constants/tulip_text_styles.dart';

class StatusBadge extends StatelessWidget {
  final String status;
  final bool small;

  const StatusBadge({
    super.key,
    required this.status,
    this.small = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = _getColors();

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: small ? 8 : 12,
        vertical: small ? 4 : 6,
      ),
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(9999),
      ),
      child: Text(
        _getLabel(),
        style: (small ? TulipTextStyles.caption : TulipTextStyles.bodySmall)
            .copyWith(
          color: colors.foreground,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  String _getLabel() {
    switch (status.toLowerCase()) {
      case 'upcoming':
        return 'Upcoming';
      case 'current':
        return 'Current';
      case 'past':
        return 'Past';
      default:
        return status;
    }
  }

  ({Color background, Color foreground}) _getColors() {
    switch (status.toLowerCase()) {
      case 'upcoming':
        return (
          background: TulipColors.sageLight,
          foreground: TulipColors.sageDark,
        );
      case 'current':
        return (
          background: TulipColors.lavenderLight,
          foreground: TulipColors.lavenderDark,
        );
      case 'past':
        return (
          background: TulipColors.taupeLight,
          foreground: TulipColors.taupeDark,
        );
      default:
        return (
          background: TulipColors.taupeLight,
          foreground: TulipColors.taupeDark,
        );
    }
  }
}
