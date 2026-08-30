import 'package:flutter/material.dart';

import '../../../theme/tide_colors.dart';
import '../../../theme/tide_elevation.dart';
import '../../../theme/tide_motion.dart';
import '../../../theme/tide_typography.dart';
import '../../../widgets/press_scale.dart';

/// One day in the month grid.
///
/// The fill rises from the bottom in proportion to how much of that day was
/// completed — a water level, not a colour code. A day at 40% looks half
/// full, which is a more honest reading than a single "partial" tint.
class DayCell extends StatelessWidget {
  const DayCell({
    super.key,
    required this.day,
    required this.ratio,
    required this.delay,
    required this.onTap,
    this.outsideMonth = false,
    this.isToday = false,
    this.isFuture = false,
  });

  final int day;

  /// 0..1 aggregate completion for the day.
  final double ratio;

  final Duration delay;
  final VoidCallback onTap;
  final bool outsideMonth;
  final bool isToday;
  final bool isFuture;

  @override
  Widget build(BuildContext context) {
    return PressScale(
      onTap: isFuture ? null : onTap,
      enabled: !isFuture,
      scale: 0.94,
      child: AspectRatio(
        aspectRatio: 1,
        child: TweenAnimationBuilder<double>(
          tween: Tween<double>(end: 1),
          duration: TideMotion.cellFill + delay,
          curve: Interval(
            (delay.inMilliseconds /
                    (TideMotion.cellFill.inMilliseconds + delay.inMilliseconds))
                .clamp(0.0, 0.85),
            1,
            curve: Curves.easeOutCubic,
          ),
          builder: (context, t, _) {
            return Container(
              decoration: BoxDecoration(
                color: TideColors.well.withValues(
                  alpha: outsideMonth ? 0.35 : 1,
                ),
                borderRadius: TideElevation.radius8,
                border: isToday
                    ? Border.all(
                        color: TideColors.foamCyan.withValues(alpha: 0.75),
                        width: 1.4,
                      )
                    : null,
              ),
              child: ClipRRect(
                borderRadius: TideElevation.radius8,
                child: Stack(
                  children: [
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: FractionallySizedBox(
                        heightFactor: (ratio * t).clamp(0.0, 1.0),
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: TideColors.intensity(
                              ratio,
                            ).withValues(alpha: outsideMonth ? 0.3 : 1),
                          ),
                          // Without a child, DecoratedBox collapses to the
                          // smallest allowed size — zero width here — and
                          // the fill silently never paints.
                          child: const SizedBox.expand(),
                        ),
                      ),
                    ),
                    Center(
                      child: Text(
                        '$day',
                        style: TideType.gauge(
                          12.5,
                          color: outsideMonth || isFuture
                              ? TideColors.textMuted
                              : TideColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
