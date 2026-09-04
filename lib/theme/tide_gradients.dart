import 'package:flutter/material.dart';

import 'tide_colors.dart';

/// The gradient layer of the design system.
///
/// [TideColors] holds the flat tokens; this file holds every *ramp* built
/// from them, and the palette rule carries over unchanged — nothing here
/// introduces a hue that is not already one of the eight tokens.
///
/// A gradient in Tide is depth, never decoration. Its job is to say "light
/// falls on this from up there", which is also why every ramp in this file
/// runs top-left to bottom-right or top to bottom: one light source, one
/// direction, on every surface in the app.
abstract final class TideGradients {
  // --- The page ground --------------------------------------------------

  /// The wash behind every screen.
  ///
  /// A cool crown, deep water through the middle where the content sits,
  /// and a darker floor. Replacing the flat fill with this is what stops
  /// the background reading as a solid swatch with objects pasted onto it.
  static LinearGradient get page => LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color.lerp(TideColors.deepWater, TideColors.tideBlue, 0.06)!,
      Color.lerp(TideColors.deepWater, TideColors.tideBlue, 0.02)!,
      TideColors.deepWater,
      Color.lerp(TideColors.deepWater, Colors.black, 0.45)!,
    ],
    stops: const [0, 0.22, 0.58, 1],
  );

  // --- Blooms -----------------------------------------------------------

  /// Seven-stop falloff approximating a gaussian.
  ///
  /// This is the whole fix for a background that looks artificial. A
  /// two-stop radial gradient fades its alpha *linearly*, and the eye finds
  /// the exact circle where that ramp reaches zero — you read a disc pasted
  /// on the page rather than light in water. Front-loading the falloff puts
  /// most of the alpha in the middle and leaves almost nothing to terminate
  /// at the rim, so the bloom has no findable edge.
  static const List<double> _bloomStops = [0, 0.12, 0.26, 0.42, 0.6, 0.8, 1];

  static const List<double> _bloomFalloff = [
    1,
    0.86,
    0.66,
    0.44,
    0.24,
    0.09,
    0,
  ];

  /// One soft light in the water.
  static RadialGradient bloom({
    required Color color,
    required double alpha,
    required Alignment center,
    required double radius,
  }) {
    return RadialGradient(
      center: center,
      radius: radius,
      stops: _bloomStops,
      colors: [
        for (final falloff in _bloomFalloff)
          color.withValues(alpha: alpha * falloff),
      ],
    );
  }

  /// The three lights on the page ground, at drift phase [t] in 0..1.
  ///
  /// Two of them are anchored past the edge of the screen so their bright
  /// core is never on canvas — what shows is the outer half of the falloff,
  /// which is the part with no structure in it.
  static List<RadialGradient> pageBlooms(double t) {
    final drift = Curves.easeInOut.transform(t.clamp(0.0, 1.0));
    return [
      // Cool crown, top-left, mostly off-canvas.
      bloom(
        color: TideColors.tideBlue,
        alpha: 0.16,
        center: Alignment(-0.85 + 0.22 * drift, -1.05 + 0.14 * drift),
        radius: 1.25 + 0.14 * drift,
      ),
      // Foam highlight opposite it, so the crown is not symmetrical.
      bloom(
        color: TideColors.foamCyan,
        alpha: 0.075,
        center: Alignment(1.05 - 0.18 * drift, -0.45 - 0.12 * drift),
        radius: 1.0 + 0.1 * (1 - drift),
      ),
      // A cold weight at the bottom, so the floor is not simply black.
      bloom(
        color: TideColors.kelpGreen,
        alpha: 0.06,
        center: Alignment(-0.5 + 0.3 * drift, 1.1),
        radius: 1.15,
      ),
    ];
  }

  // --- Frosted glass ----------------------------------------------------

  /// Fill for a frosted panel sitting over the page — the tab bar, the pill
  /// behind the active tab, the wells on the hero card.
  ///
  /// Designed to be painted over a [BackdropFilter]: the blur supplies the
  /// colour, this supplies the sheen.
  static LinearGradient get glass => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Colors.white.withValues(alpha: 0.10),
      Colors.white.withValues(alpha: 0.035),
      TideColors.tideBlue.withValues(alpha: 0.05),
    ],
    stops: const [0, 0.55, 1],
  );

  /// The lit edge of a frosted panel: bright along the top-left, gone by the
  /// bottom-right, catching light from the same direction as the inner
  /// highlight on every card.
  static LinearGradient get glassStroke => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Colors.white.withValues(alpha: 0.20),
      Colors.white.withValues(alpha: 0.06),
      Colors.white.withValues(alpha: 0.015),
    ],
    stops: const [0, 0.45, 1],
  );

  // --- Accent -----------------------------------------------------------

  /// The primary ramp: tide blue into foam cyan. Progress fills, the active
  /// tab indicator, the gradient on a screen title.
  static const LinearGradient accent = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [TideColors.tideBlue, TideColors.foamCyan],
  );

  /// The accent ramp's completed twin: kelp green into foam. Used wherever
  /// [accent] would be, on a habit or a day that is already done.
  static const LinearGradient completed = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [TideColors.kelpGreen, TideColors.foamCyan],
  );

  /// [accent] at low opacity, for a tinted fill behind live content.
  static LinearGradient accentWash({double alpha = 0.18}) => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      TideColors.tideBlue.withValues(alpha: alpha),
      TideColors.foamCyan.withValues(alpha: alpha * 0.55),
    ],
  );

  /// The completed ramp, in kelp green rather than tide blue.
  static LinearGradient completedWash({double alpha = 0.18}) => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      TideColors.kelpGreen.withValues(alpha: alpha),
      TideColors.foamCyan.withValues(alpha: alpha * 0.5),
    ],
  );

  // --- Surfaces ---------------------------------------------------------

  /// A card at rest: the shallow fill, lifted at the top-left corner and
  /// falling toward deep water at the bottom-right.
  ///
  /// The dark end stops well short of [TideColors.well]. It has to: a well
  /// is a recess *cut into* a card, and the two are only 0.03 of a lerp
  /// apart at full depth — carry the ramp that far and every empty heatmap
  /// cell in the bottom-right of a card dissolves into the card behind it.
  /// The lift at the top-left does the work of making this read as a ramp
  /// instead.
  static LinearGradient get surface => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color.lerp(TideColors.shallow, TideColors.textPrimary, 0.07)!,
      TideColors.shallow,
      Color.lerp(TideColors.shallow, TideColors.deepWater, 0.18)!,
    ],
    stops: const [0, 0.5, 1],
  );

  /// The hero card on Home — the same recipe with the accent bled into the
  /// top-left, so the one card carrying the day's headline reads warmer than
  /// the habit rows beneath it.
  static LinearGradient get hero => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color.lerp(TideColors.shallow, TideColors.tideBlue, 0.26)!,
      Color.lerp(TideColors.shallow, TideColors.tideBlue, 0.10)!,
      Color.lerp(TideColors.shallow, TideColors.deepWater, 0.24)!,
      Color.lerp(TideColors.shallow, TideColors.deepWater, 0.42)!,
    ],
    stops: const [0, 0.34, 0.72, 1],
  );

  /// A habit row: the same light, at a fraction of the hero's strength.
  /// [tint] washes the whole row toward a state colour — kelp for logged,
  /// foam for frozen.
  static LinearGradient habitRow({Color? tint, double amount = 0.10}) {
    final base = tint == null
        ? TideColors.shallow
        : Color.lerp(TideColors.shallow, tint, amount)!;
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color.lerp(base, TideColors.textPrimary, 0.05)!,
        base,
        Color.lerp(base, TideColors.deepWater, 0.20)!,
      ],
      stops: const [0, 0.5, 1],
    );
  }

  /// A recessed well, lit from below rather than above — the inverted ramp
  /// is what makes it read as carved into the card.
  static LinearGradient get well => LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color.lerp(TideColors.well, Colors.black, 0.22)!, TideColors.well],
  );

  // --- Hairlines --------------------------------------------------------

  /// A separator that fades out at both ends instead of butting into the
  /// card's rounded corners.
  static LinearGradient get hairline => LinearGradient(
    colors: [
      Colors.transparent,
      TideColors.divider,
      TideColors.divider,
      Colors.transparent,
    ],
    stops: const [0, 0.08, 0.92, 1],
  );
}
