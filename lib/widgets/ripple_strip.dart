import 'package:flutter/material.dart';

import '../theme/tide_colors.dart';
import '../theme/tide_motion.dart';

/// The seven-dash week strip under a habit name.
///
/// A compressed heatmap: one dash per day, oldest on the left, today on the
/// right. It uses the same intensity ramp as the habit-detail heatmap and
/// the calendar grid, so a half-filled dash and a half-filled calendar cell
/// mean exactly the same thing.
class RippleStrip extends StatelessWidget {
  const RippleStrip({
    super.key,
    required this.levels,
    this.height = 3,
    this.spacing = 4,
    this.color,
    this.animate = true,
  });

  /// Seven values in 0..1, oldest first.
  final List<double> levels;

  final double height;
  final double spacing;

  /// Overridden to kelp green while a card is washing after a log.
  final Color? color;

  final bool animate;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < levels.length; i++) ...[
          if (i > 0) SizedBox(width: spacing),
          Expanded(
            child: _Dash(
              level: levels[i],
              height: height,
              color: color,
              animate: animate,
              // Filling left to right, the way the week actually ran.
              delay: TideMotion.cellStep * i * 2,
            ),
          ),
        ],
      ],
    );
  }
}

class _Dash extends StatelessWidget {
  const _Dash({
    required this.level,
    required this.height,
    required this.color,
    required this.animate,
    required this.delay,
  });

  final double level;
  final double height;
  final Color? color;
  final bool animate;
  final Duration delay;

  @override
  Widget build(BuildContext context) {
    final target = color == null
        ? TideColors.intensity(level)
        : Color.lerp(TideColors.well, color, level.clamp(0.0, 1.0))!;

    if (!animate) return _bar(target);

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(end: 1),
      duration: TideMotion.cellFill,
      curve: Curves.easeOutCubic,
      builder: (context, t, _) {
        return Opacity(
          opacity: t,
          child: _bar(Color.lerp(TideColors.well, target, t)!),
        );
      },
    );
  }

  Widget _bar(Color fill) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: fill,
        borderRadius: BorderRadius.circular(height),
      ),
    );
  }
}
