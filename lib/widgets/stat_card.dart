import 'package:flutter/material.dart';

import '../theme/tide_colors.dart';
import '../theme/tide_typography.dart';
import 'gauge_number.dart';
import 'tide_surface.dart';

/// A gauge readout with a caption — the three chips across the top of Habit
/// detail, and the smaller figures beside Home's hero stat.
///
/// The number counts up from zero on entrance rather than appearing at full
/// value, which is what makes a stat feel measured rather than printed.
class StatCard extends StatelessWidget {
  const StatCard({
    super.key,
    required this.value,
    required this.caption,
    this.suffix,
    this.color = TideColors.tideBlue,
    this.delay = Duration.zero,
    this.compact = false,
  });

  final int value;
  final String caption;

  /// The % on a rate, the "d" on a day count.
  final String? suffix;

  final Color color;
  final Duration delay;

  /// Compact drops the surface, for stats that sit inside another card.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Three chips share the row, so a three-digit rate and its suffix
        // can want more width than one chip has. Scaling down keeps the
        // readout on one line instead of letting the Row spill.
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: GaugeCountUp(
            value: value,
            style: compact
                ? TideType.gauge(17, color: color)
                : TideType.gaugeStat(color: color),
            suffix: suffix,
            delay: delay,
          ),
        ),
        SizedBox(height: compact ? 3 : 6),
        Text(
          caption,
          // One line: three chips side by side on a narrow phone leave
          // barely enough room for "current streak", and a single wrapped
          // caption makes the row look accidental.
          style: TideType.labelMuted.copyWith(fontSize: 11.5),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );

    if (compact) return content;

    return TideSurface(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      child: content,
    );
  }
}
