import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/constants/tulip_colors.dart';
import '../../../../shared/constants/tulip_text_styles.dart';

class MapScreen extends ConsumerWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Map', style: TulipTextStyles.heading3),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.map_outlined,
              size: 64,
              color: TulipColors.brownLighter,
            ),
            const SizedBox(height: 16),
            Text(
              'Map View',
              style: TulipTextStyles.heading3,
            ),
            const SizedBox(height: 8),
            Text(
              'Interactive map coming soon',
              style: TulipTextStyles.bodySmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Using flutter_map with OpenStreetMap',
              style: TulipTextStyles.caption,
            ),
          ],
        ),
      ),
    );
  }
}
