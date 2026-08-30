import 'package:flutter/material.dart';

import '../../../services/models/milestone.dart';
import '../../../theme/tide_motion.dart';
import '../../../widgets/stagger_list.dart';
import 'badge_tile.dart';

/// The 3×3 wall of badges.
///
/// Staggered by grid position rather than by row, so the wall surfaces
/// diagonally — the same ripple-across-a-grid idea as the heatmap and the
/// calendar, at a different scale.
class BadgeGrid extends StatelessWidget {
  const BadgeGrid({
    super.key,
    required this.statuses,
    required this.onTapBadge,
  });

  final List<MilestoneStatus> statuses;
  final ValueChanged<MilestoneStatus> onTapBadge;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      itemCount: statuses.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 0.92,
      ),
      itemBuilder: (context, index) {
        final status = statuses[index];
        return StaggerIn(
          index: index,
          baseDelay: TideMotion.tabSwitch,
          child: BadgeTile(status: status, onTap: () => onTapBadge(status)),
        );
      },
    );
  }
}
