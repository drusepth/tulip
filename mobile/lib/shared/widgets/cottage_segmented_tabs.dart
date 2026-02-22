import 'package:flutter/material.dart';
import '../constants/tulip_colors.dart';
import '../constants/tulip_text_styles.dart';

/// A cottagecore-styled segmented tab control with animated sliding indicator.
///
/// Displays tabs as pill-shaped segments with a sliding sage-colored
/// background for the selected tab.
class CottageSegmentedTabs extends StatelessWidget implements PreferredSizeWidget {
  final TabController controller;
  final List<String> labels;

  const CottageSegmentedTabs({
    super.key,
    required this.controller,
    required this.labels,
  });

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: AnimatedBuilder(
        animation: controller.animation!,
        builder: (context, child) {
          return LayoutBuilder(
            builder: (context, constraints) {
              final segmentWidth = constraints.maxWidth / labels.length;
              final animationValue = controller.animation!.value;

              return Container(
                height: 40,
                decoration: BoxDecoration(
                  color: TulipColors.cream,
                  borderRadius: BorderRadius.circular(9999),
                  border: Border.all(
                    color: TulipColors.taupeLight,
                    width: 1,
                  ),
                ),
                child: Stack(
                  children: [
                    // Sliding indicator
                    AnimatedPositioned(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeInOut,
                      left: animationValue * segmentWidth + 2,
                      top: 2,
                      bottom: 2,
                      width: segmentWidth - 4,
                      child: Container(
                        decoration: BoxDecoration(
                          color: TulipColors.sage,
                          borderRadius: BorderRadius.circular(9999),
                        ),
                      ),
                    ),
                    // Tab labels
                    Row(
                      children: List.generate(labels.length, (index) {
                        // Calculate selection state for smooth color transition
                        final isSelected = index == controller.index;
                        final distance = (animationValue - index).abs();
                        final selectionAmount = (1 - distance).clamp(0.0, 1.0);

                        return Expanded(
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () => controller.animateTo(index),
                            child: Center(
                              child: Text(
                                labels[index],
                                style: TulipTextStyles.label.copyWith(
                                  color: Color.lerp(
                                    TulipColors.brown,
                                    Colors.white,
                                    selectionAmount,
                                  ),
                                  fontWeight: isSelected
                                      ? FontWeight.w600
                                      : FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
