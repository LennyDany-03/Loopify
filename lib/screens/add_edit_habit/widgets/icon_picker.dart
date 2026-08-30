import 'package:flutter/material.dart';

import '../../../services/models/tide_glyph.dart';
import '../../../theme/tide_colors.dart';
import '../../../theme/tide_elevation.dart';
import '../../../theme/tide_motion.dart';
import '../../../widgets/habit_glyph.dart';
import '../../../widgets/press_scale.dart';
import '../../../widgets/ripple_burst.dart';

/// The glyph row.
///
/// Selecting an icon ripples exactly the way picking an onboarding template
/// does, and the way logging a habit does — the app has one "claimed"
/// animation and this is another place it applies.
class IconPicker extends StatefulWidget {
  const IconPicker({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  final TideGlyph selected;
  final ValueChanged<TideGlyph> onChanged;

  @override
  State<IconPicker> createState() => _IconPickerState();
}

class _IconPickerState extends State<IconPicker> {
  /// One tick per glyph, so a ripple plays on the tile that was tapped
  /// rather than across the whole row.
  final Map<TideGlyph, int> _ticks = {};

  void _select(TideGlyph glyph) {
    setState(() => _ticks[glyph] = (_ticks[glyph] ?? 0) + 1);
    widget.onChanged(glyph);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (final glyph in TideGlyph.pickable) ...[
          if (glyph != TideGlyph.pickable.first) const SizedBox(width: 8),
          Expanded(
            child: AspectRatio(
              aspectRatio: 1,
              child: PressScale(
                onTap: () => _select(glyph),
                child: ClipRRect(
                  borderRadius: TideElevation.radius12,
                  child: RippleBurst(
                    trigger: _ticks[glyph] ?? 0,
                    color: TideColors.tideBlue,
                    accent: TideColors.foamCyan,
                    child: _Tile(
                      glyph: glyph,
                      selected: glyph == widget.selected,
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

class _Tile extends StatelessWidget {
  const _Tile({required this.glyph, required this.selected});

  final TideGlyph glyph;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: TideMotion.tabSwitch,
      curve: TideMotion.tabCurve,
      decoration: BoxDecoration(
        color: selected
            ? TideColors.tideBlue.withValues(alpha: 0.18)
            : TideColors.well,
        borderRadius: TideElevation.radius12,
        border: Border.all(
          color: selected
              ? TideColors.tideBlue.withValues(alpha: 0.6)
              : Colors.transparent,
        ),
      ),
      child: Center(
        child: HabitGlyph(
          glyph: glyph,
          size: 17,
          color: selected ? TideColors.tideBlue : TideColors.textMuted,
        ),
      ),
    );
  }
}
