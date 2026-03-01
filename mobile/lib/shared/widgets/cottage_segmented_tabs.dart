import 'package:flutter/material.dart';
import '../constants/tulip_colors.dart';
import '../constants/tulip_text_styles.dart';

/// A cottagecore-styled segmented tab control with animated sliding indicator.
///
/// Displays tabs as pill-shaped segments with a sliding sage-colored
/// background for the selected tab.
class CottageSegmentedTabs extends StatefulWidget implements PreferredSizeWidget {
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
  State<CottageSegmentedTabs> createState() => _CottageSegmentedTabsState();
}

class _CottageSegmentedTabsState extends State<CottageSegmentedTabs> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.controller.index;
    widget.controller.addListener(_handleTabChange);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_handleTabChange);
    super.dispose();
  }

  void _handleTabChange() {
    if (mounted && widget.controller.index != _selectedIndex) {
      setState(() {
        _selectedIndex = widget.controller.index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final segmentWidth = constraints.maxWidth / widget.labels.length;

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
              clipBehavior: Clip.none,
              children: [
                // Sliding indicator
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeInOut,
                  left: _selectedIndex * segmentWidth + 2,
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
                  children: List.generate(widget.labels.length, (index) {
                    final isSelected = index == _selectedIndex;

                    return Expanded(
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => widget.controller.animateTo(index),
                        child: Center(
                          child: AnimatedDefaultTextStyle(
                            duration: const Duration(milliseconds: 200),
                            style: TulipTextStyles.label.copyWith(
                              color: isSelected ? Colors.white : TulipColors.brown,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                            ),
                            child: Text(widget.labels[index]),
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
      ),
    );
  }
}
