import 'package:flutter/material.dart';
import '../constants/tulip_colors.dart';
import '../constants/tulip_text_styles.dart';

class TulipButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String label;
  final bool isLoading;
  final bool isOutlined;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? textColor;

  const TulipButton({
    super.key,
    required this.onPressed,
    required this.label,
    this.isLoading = false,
    this.isOutlined = false,
    this.icon,
    this.backgroundColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    if (isOutlined) {
      return OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: textColor ?? TulipColors.sage,
          side: BorderSide(color: backgroundColor ?? TulipColors.sage),
        ),
        child: _buildChild(),
      );
    }

    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor ?? TulipColors.sage,
        foregroundColor: textColor ?? Colors.white,
      ),
      child: _buildChild(),
    );
  }

  Widget _buildChild() {
    final effectiveTextColor = textColor ?? (isOutlined ? TulipColors.sage : Colors.white);

    if (isLoading) {
      return SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(
            isOutlined ? TulipColors.sage : Colors.white,
          ),
        ),
      );
    }

    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20, color: effectiveTextColor),
          const SizedBox(width: 8),
          Text(label, style: TulipTextStyles.button.copyWith(color: effectiveTextColor)),
        ],
      );
    }

    return Text(label, style: TulipTextStyles.button.copyWith(color: effectiveTextColor));
  }
}
