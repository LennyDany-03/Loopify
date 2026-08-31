import 'package:flutter/material.dart';

import '../../../theme/tide_motion.dart';
import '../../../widgets/stagger_list.dart';

/// A list whose rows *move* when the order changes.
///
/// When a habit is logged it sinks toward the bottom of the list. Rebuilding
/// a Column would make it teleport; this lays the rows out in a Stack at
/// computed offsets and animates the offsets instead, so a completed habit
/// visibly slides past the ones still waiting — the FLIP-style transition
/// the design calls for.
///
/// Rows are a fixed height, which is what makes the offsets computable
/// without a measurement pass.
class ReorderingHabitList extends StatelessWidget {
  const ReorderingHabitList({
    super.key,
    required this.itemKeys,
    required this.itemBuilder,
    required this.itemHeight,
    this.spacing = 10,
    this.stagger = true,
  });

  /// Stable identity per row, in display order. Reordering this list is what
  /// drives the animation.
  final List<String> itemKeys;

  final Widget Function(BuildContext context, String key) itemBuilder;
  final double itemHeight;
  final double spacing;

  /// The first appearance staggers in; later reorders just move.
  final bool stagger;

  @override
  Widget build(BuildContext context) {
    final step = itemHeight + spacing;

    return SizedBox(
      height: itemKeys.isEmpty ? 0 : itemKeys.length * step - spacing,
      child: Stack(
        children: [
          for (var i = 0; i < itemKeys.length; i++)
            AnimatedPositioned(
              // Keyed by identity, not by index, so Flutter carries the same
              // element through the reorder rather than swapping contents.
              key: ValueKey(itemKeys[i]),
              duration: TideMotion.sheetIn,
              curve: TideMotion.morphCurve,
              top: i * step,
              left: 0,
              right: 0,
              height: itemHeight,
              child: stagger
                  ? StaggerIn(
                      index: i,
                      child: itemBuilder(context, itemKeys[i]),
                    )
                  : itemBuilder(context, itemKeys[i]),
            ),
        ],
      ),
    );
  }
}
