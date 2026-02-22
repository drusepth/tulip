import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/constants/tulip_colors.dart';
import '../../../../shared/constants/tulip_text_styles.dart';

class TimelineScreen extends ConsumerWidget {
  const TimelineScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Timeline', style: TulipTextStyles.heading3),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.timeline_outlined,
              size: 64,
              color: TulipColors.brownLighter,
            ),
            const SizedBox(height: 16),
            Text(
              'Timeline View',
              style: TulipTextStyles.heading3,
            ),
            const SizedBox(height: 8),
            Text(
              'Gantt-style timeline coming soon',
              style: TulipTextStyles.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
