import 'package:flutter/material.dart';

import 'tide_colors.dart';

/// The restrained elevation system: four radii and exactly two shadow
/// recipes. A surface is either resting or floating — there is no third
/// state, and nothing in the app invents its own shadow.
abstract final class TideElevation {
  // --- Radii ------------------------------------------------------------

  /// Pills, dots, chips.
  static const double r8 = 8;

  /// Buttons, inputs, list rows.
  static const double r12 = 12;

  /// Cards.
  static const double r16 = 16;

  /// Sheets, modals, FAB.
  static const double r24 = 24;

  static const radius8 = BorderRadius.all(Radius.circular(r8));
  static const radius12 = BorderRadius.all(Radius.circular(r12));
  static const radius16 = BorderRadius.all(Radius.circular(r16));
  static const radius24 = BorderRadius.all(Radius.circular(r24));

  /// Sheets are rounded on the top edge only.
  static const sheetRadius = BorderRadius.vertical(top: Radius.circular(r24));

  // --- Shadows ----------------------------------------------------------

  /// A card at rest.
  static const List<BoxShadow> resting = [
    BoxShadow(
      color: Color(0x40000000), // rgba(0,0,0,0.25)
      blurRadius: 2,
      offset: Offset(0, 1),
    ),
    BoxShadow(
      color: Color(0x4D000000), // rgba(0,0,0,0.30)
      blurRadius: 12,
      offset: Offset(0, 4),
    ),
  ];

  /// FABs, modals, sheets and the long-press context menu.
  static const List<BoxShadow> floating = [
    BoxShadow(
      color: Color(0x73000000), // rgba(0,0,0,0.45)
      blurRadius: 24,
      offset: Offset(0, 8),
    ),
  ];

  /// The FAB's soft blurred tide-blue glow — the one object in the app that
  /// reads as genuinely floating above everything else.
  static List<BoxShadow> fabGlow({double intensity = 1}) => [
    BoxShadow(
      color: TideColors.tideBlue.withValues(alpha: 0.34 * intensity),
      blurRadius: 28 * intensity,
      spreadRadius: 2 * intensity,
    ),
    BoxShadow(
      color: TideColors.tideBlue.withValues(alpha: 0.16 * intensity),
      blurRadius: 52 * intensity,
      spreadRadius: 8 * intensity,
    ),
    ...floating,
  ];

  /// The very slow, low-key glow on the paywall CTA.
  static List<BoxShadow> ctaGlow(double pulse) => [
    BoxShadow(
      color: TideColors.tideBlue.withValues(alpha: 0.10 + 0.18 * pulse),
      blurRadius: 20 + 18 * pulse,
      spreadRadius: 1 + 3 * pulse,
    ),
  ];

  // --- Inner highlight --------------------------------------------------

  /// Flutter has no inset box-shadow, so the spec's
  /// `inset 0 1px 0 rgba(255,255,255,0.04)` is drawn by `TideSurface` as a
  /// one-pixel line pinned to the top edge *inside* the clip. Keeping it a
  /// fixed pixel rather than a gradient stop means the highlight reads the
  /// same on a 56px row and a 300px card.
  static const double innerHighlightWidth = 1;

  /// Horizontal falloff for that line — brightest across the middle of the
  /// card, fading out before the rounded corners so it never clips oddly.
  static Gradient get innerHighlightGradient => LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [
      Colors.transparent,
      TideColors.innerHighlight,
      TideColors.innerHighlight,
      Colors.transparent,
    ],
    stops: const [0, 0.12, 0.88, 1],
  );
}
