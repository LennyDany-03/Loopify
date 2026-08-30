import 'package:flutter/material.dart';

/// The complete Tide palette.
///
/// These eight tokens are the entire colour vocabulary of the app. Nothing
/// outside this file may introduce a colour or a gradient — the spec is
/// explicit that the fix for a flat-looking screen is motion, depth and
/// consistency, never a new hue.
abstract final class TideColors {
  /// Page background.
  static const deepWater = Color(0xFF0E1A1D);

  /// Card / surface background — a visible step lighter than the page.
  static const shallow = Color(0xFF16262B);

  /// The one primary accent: rings, streaks, primary buttons, active states.
  static const tideBlue = Color(0xFF3AA9D6);

  /// Secondary highlight only — badges, "just completed" flashes, motion
  /// trails. Never a second primary.
  static const foamCyan = Color(0xFF7FE0D9);

  /// Completed state.
  static const kelpGreen = Color(0xFF4E9A6E);

  /// Missed / warning / destructive state.
  static const coral = Color(0xFFE0665A);

  /// Primary text.
  static const textPrimary = Color(0xFFE8F1F0);

  /// Secondary / muted / inactive text.
  static const textMuted = Color(0xFF7C9296);

  // ---------------------------------------------------------------------
  // Derived surfaces. All lerps between the tokens above — no new hues.
  // ---------------------------------------------------------------------

  /// A recessed well inside a card (empty heatmap cells, input fields,
  /// inactive segmented-control track).
  static final Color well = Color.lerp(shallow, deepWater, 0.45)!;

  /// A surface that sits one step above a card (context menus, sheets).
  static final Color raised = Color.lerp(shallow, textPrimary, 0.04)!;

  /// Hairline separator inside grouped lists.
  static final Color divider = textMuted.withValues(alpha: 0.14);

  /// The 1px top inner highlight that sits on every card.
  static final Color innerHighlight = Colors.white.withValues(alpha: 0.04);

  /// Backdrop behind modals and the long-press context menu.
  static final Color scrim = deepWater.withValues(alpha: 0.66);

  // ---------------------------------------------------------------------
  // Intensity ramps — the single source of truth for "how full is this".
  // Shared by the habit-detail heatmap, the calendar day cells and the
  // ripple strips so a given completion level always reads the same.
  // ---------------------------------------------------------------------

  /// Tide-blue fill for a completion level [t] in 0..1.
  ///
  /// Zero is a recessed well rather than transparent, so an unlogged day
  /// still reads as a cell rather than a hole.
  static Color intensity(double t) {
    final level = t.clamp(0.0, 1.0);
    if (level <= 0) return well;
    return Color.lerp(
      tideBlue.withValues(alpha: 0.22),
      tideBlue.withValues(alpha: 0.95),
      Curves.easeIn.transform(level),
    )!;
  }

  /// The same ramp in kelp green, for surfaces showing a *completed* state
  /// rather than a partial one.
  static Color completedIntensity(double t) {
    final level = t.clamp(0.0, 1.0);
    if (level <= 0) return well;
    return kelpGreen.withValues(alpha: 0.22 + 0.7 * level);
  }

  /// Desaturated version of [color], used by the "drain" transition when a
  /// habit is paused and by locked milestone badges.
  static Color drained(Color color, double amount) {
    final grey = Color.lerp(textMuted, deepWater, 0.35)!;
    return Color.lerp(color, grey, amount.clamp(0.0, 1.0))!;
  }
}
