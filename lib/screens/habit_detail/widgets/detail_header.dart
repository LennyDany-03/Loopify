import 'package:flutter/material.dart';

import '../../../services/models/habit.dart';
import '../../../theme/tide_colors.dart';
import '../../../theme/tide_elevation.dart';
import '../../../theme/tide_typography.dart';
import '../../../widgets/habit_glyph.dart';
import '../../../widgets/press_scale.dart';

/// Back control, glyph and habit name.
class DetailHeader extends StatelessWidget {
  const DetailHeader({
    super.key,
    required this.habit,
    required this.onBack,
    this.drain = 0,
  });

  final Habit habit;
  final VoidCallback onBack;

  /// 0..1 desaturation applied while a habit is being paused.
  final double drain;

  @override
  Widget build(BuildContext context) {
    final accent = TideColors.drained(TideColors.tideBlue, drain);

    return Row(
      children: [
        PressScale(
          onTap: onBack,
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: TideColors.shallow,
              borderRadius: TideElevation.radius12,
            ),
            child: const Icon(
              Icons.arrow_back_rounded,
              size: 18,
              color: TideColors.textPrimary,
            ),
          ),
        ),
        const SizedBox(width: 14),
        HabitGlyph(glyph: habit.glyph, size: 17, color: accent),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            habit.name,
            style: TideType.hero.copyWith(fontSize: 21),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (habit.paused)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: TideColors.textMuted.withValues(alpha: 0.14),
              borderRadius: TideElevation.radius8,
            ),
            child: Text(
              'PAUSED',
              style: TideType.sectionHeader.copyWith(fontSize: 9.5),
            ),
          ),
      ],
    );
  }
}
