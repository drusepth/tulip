import 'package:flutter/material.dart';
import '../../../../shared/constants/tulip_colors.dart';

/// Interactive star rating widget
class RatingStars extends StatelessWidget {
  final int rating;
  final int maxRating;
  final double size;
  final ValueChanged<int>? onRatingChanged;
  final bool showLabel;

  const RatingStars({
    super.key,
    required this.rating,
    this.maxRating = 5,
    this.size = 24,
    this.onRatingChanged,
    this.showLabel = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ...List.generate(maxRating, (index) {
          final starValue = index + 1;
          final filled = starValue <= rating;
          return GestureDetector(
            onTap: onRatingChanged != null ? () => onRatingChanged!(starValue) : null,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: Icon(
                filled ? Icons.star : Icons.star_border,
                size: size,
                color: filled ? TulipColors.coral : TulipColors.brownLighter,
              ),
            ),
          );
        }),
        if (showLabel && rating > 0) ...[
          const SizedBox(width: 8),
          Text(
            '$rating/$maxRating',
            style: TextStyle(
              color: TulipColors.brownLight,
              fontSize: size * 0.6,
            ),
          ),
        ],
      ],
    );
  }
}

/// Rating dialog for selecting a star rating
class RatingDialog extends StatefulWidget {
  final String title;
  final int initialRating;
  final ValueChanged<int> onRatingSelected;

  const RatingDialog({
    super.key,
    required this.title,
    this.initialRating = 0,
    required this.onRatingSelected,
  });

  @override
  State<RatingDialog> createState() => _RatingDialogState();
}

class _RatingDialogState extends State<RatingDialog> {
  late int _selectedRating;

  @override
  void initState() {
    super.initState();
    _selectedRating = widget.initialRating;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 8),
          RatingStars(
            rating: _selectedRating,
            size: 40,
            onRatingChanged: (rating) {
              setState(() => _selectedRating = rating);
            },
          ),
          const SizedBox(height: 16),
          Text(
            _getRatingLabel(_selectedRating),
            style: TextStyle(
              color: TulipColors.brownLight,
              fontSize: 14,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: _selectedRating > 0
              ? () {
                  widget.onRatingSelected(_selectedRating);
                  Navigator.pop(context);
                }
              : null,
          child: const Text('Rate'),
        ),
      ],
    );
  }

  String _getRatingLabel(int rating) {
    switch (rating) {
      case 1:
        return 'Not great';
      case 2:
        return 'Okay';
      case 3:
        return 'Good';
      case 4:
        return 'Very good';
      case 5:
        return 'Amazing!';
      default:
        return 'Tap a star to rate';
    }
  }
}

/// Show a rating dialog and return the selected rating
Future<int?> showRatingDialog(
  BuildContext context, {
  required String title,
  int initialRating = 0,
}) async {
  int? result;
  await showDialog(
    context: context,
    builder: (context) => RatingDialog(
      title: title,
      initialRating: initialRating,
      onRatingSelected: (rating) => result = rating,
    ),
  );
  return result;
}
