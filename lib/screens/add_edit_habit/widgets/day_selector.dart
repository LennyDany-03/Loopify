import 'package:flutter/material.dart';

import '../../../config/app_constants.dart';
import '../../../theme/tide_colors.dart';
import '../../../theme/tide_elevation.dart';
import '../../../theme/tide_motion.dart';
import '../../../theme/tide_typography.dart';
import '../../../widgets/press_scale.dart';
import '../../../widgets/ripple_burst.dart';

/// The M T W T F S S toggles.
///
/// Switching a day on ripples in tide blue, reusing the ripple-strip
/// language from the habit cards — turning a day on is the same kind of act
/// as filling one in.
class DaySelector extends StatefulWidget {
  const DaySelector({super.key, required this.days, required this.onChanged});

  /// Weekday numbers, [DateTime.monday]..[DateTime.sunday].
  final Set<int> days;

  final ValueChanged<Set<int>> onChanged;

  @override
  State<DaySelector> createState() => _DaySelectorState();
}

class _DaySelectorState extends State<DaySelector> {
  final Map<int, int> _ticks = {};

  void _toggle(int weekday) {
    final next = Set<int>.from(widget.days);
    if (next.contains(weekday)) {
      next.remove(weekday);
    } else {
      next.add(weekday);
      // Only turning a day *on* is a claim, so only that direction ripples.
      setState(() => _ticks[weekday] = (_ticks[weekday] ?? 0) + 1);
    }
    widget.onChanged(next);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var weekday = 1; weekday <= 7; weekday++) ...[
          if (weekday > 1) const SizedBox(width: 8),
          Expanded(
            child: AspectRatio(
              aspectRatio: 1,
              child: PressScale(
                onTap: () => _toggle(weekday),
                child: ClipRRect(
                  borderRadius: TideElevation.radius12,
                  child: RippleBurst(
                    trigger: _ticks[weekday] ?? 0,
                    color: TideColors.tideBlue,
                    child: _DayTile(
                      label: AppConstants.weekdayInitials[weekday - 1],
                      active: widget.days.contains(weekday),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _DayTile extends StatelessWidget {
  const _DayTile({required this.label, required this.active});

  final String label;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: TideMotion.tabSwitch,
      curve: TideMotion.tabCurve,
      decoration: BoxDecoration(
        color: active
            ? TideColors.tideBlue.withValues(alpha: 0.16)
            : TideColors.well,
        borderRadius: TideElevation.radius12,
        border: Border.all(
          color: active
              ? TideColors.tideBlue.withValues(alpha: 0.55)
              : Colors.transparent,
        ),
      ),
      child: Center(
        child: Text(
          label,
          style: TideType.label.copyWith(
            color: active ? TideColors.textPrimary : TideColors.textMuted,
          ),
        ),
      ),
    );
  }
}
