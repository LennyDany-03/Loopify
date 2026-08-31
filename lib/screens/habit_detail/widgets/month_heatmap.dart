import 'package:flutter/material.dart';

import '../../../config/app_constants.dart';
import '../../../services/models/habit.dart';
import '../../../theme/tide_colors.dart';
import '../../../theme/tide_elevation.dart';
import '../../../theme/tide_motion.dart';
import '../../../theme/tide_typography.dart';
import '../../../widgets/tide_surface.dart';

/// One month of a single habit, as intensity of tide blue.
///
/// Cells fill in staggered by day rather than all at once, so the month
/// reads as filling the way it was actually lived — a ripple spreading
/// across the grid rather than a table being painted.
class MonthHeatmap extends StatelessWidget {
  const MonthHeatmap({super.key, required this.habit, required this.month});

  final Habit habit;
  final DateTime month;

  int get _daysInMonth => DateUtils.getDaysInMonth(month.year, month.month);

  /// Share of *scheduled* days in this month that were completed — the
  /// figure quoted in the card header.
  double get _rate {
    var scheduled = 0;
    var done = 0;
    final today = DateUtils.dateOnly(DateTime.now());

    for (var day = 1; day <= _daysInMonth; day++) {
      final date = DateTime(month.year, month.month, day);
      if (date.isAfter(today)) break;
      if (!habit.isScheduledOn(date)) continue;
      scheduled++;
      if (habit.countsTowardStreak(date)) done++;
    }
    return scheduled == 0 ? 0 : done / scheduled;
  }

  @override
  Widget build(BuildContext context) {
    final today = DateUtils.dateOnly(DateTime.now());
    final first = DateTime(month.year, month.month);

    // Monday-first leading blanks, so a month always lines up under the
    // same weekday columns as the calendar screen.
    final leading = first.weekday - 1;
    final cellCount = leading + _daysInMonth;
    final rows = (cellCount / 7).ceil();

    return TideSurface(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                AppConstants.monthNames[month.month - 1],
                style: TideType.heading,
              ),
              const Spacer(),
              Text(
                '${(_rate * 100).round()}% of days logged',
                style: TideType.labelMuted,
              ),
            ],
          ),
          const SizedBox(height: 16),
          for (var row = 0; row < rows; row++) ...[
            if (row > 0) const SizedBox(height: 6),
            Row(
              children: [
                for (var col = 0; col < 7; col++) ...[
                  if (col > 0) const SizedBox(width: 6),
                  Expanded(
                    child: _cell(
                      index: row * 7 + col,
                      leading: leading,
                      today: today,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _cell({
    required int index,
    required int leading,
    required DateTime today,
  }) {
    final dayNumber = index - leading + 1;

    if (dayNumber < 1 || dayNumber > _daysInMonth) {
      return const AspectRatio(aspectRatio: 1, child: SizedBox.shrink());
    }

    final date = DateTime(month.year, month.month, dayNumber);
    final future = date.isAfter(today);
    final scheduled = habit.isScheduledOn(date);

    final level = future || !scheduled
        ? 0.0
        : habit.isFrozenOn(date)
        ? 0.45
        : habit.progressOn(date);

    return _HeatCell(
      level: level,
      // Staggering by day index is what makes the fill sweep across the
      // month instead of appearing all at once.
      delay: TideMotion.cellStep * index,
      dimmed: future,
      isToday: DateUtils.isSameDay(date, today),
    );
  }
}

class _HeatCell extends StatelessWidget {
  const _HeatCell({
    required this.level,
    required this.delay,
    required this.dimmed,
    required this.isToday,
  });

  final double level;
  final Duration delay;
  final bool dimmed;
  final bool isToday;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(end: 1),
        duration: TideMotion.cellFill + delay,
        curve: Interval(
          // Converting the delay into a curve interval keeps every cell on
          // one animation clock rather than scheduling dozens of timers.
          (delay.inMilliseconds /
                  (TideMotion.cellFill.inMilliseconds + delay.inMilliseconds))
              .clamp(0.0, 0.85),
          1,
          curve: Curves.easeOutCubic,
        ),
        builder: (context, t, _) {
          final target = dimmed
              ? TideColors.well.withValues(alpha: 0.5)
              : TideColors.intensity(level);

          return Transform.scale(
            scale: 0.82 + 0.18 * t,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Color.lerp(TideColors.well, target, t),
                borderRadius: TideElevation.radius8,
                border: isToday
                    ? Border.all(
                        color: TideColors.foamCyan.withValues(alpha: 0.7),
                        width: 1.4,
                      )
                    : null,
              ),
            ),
          );
        },
      ),
    );
  }
}
