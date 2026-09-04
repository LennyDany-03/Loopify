import 'package:flutter/material.dart';

import 'tide_colors.dart';

/// Three families, three jobs:
///
/// * **Space Grotesk** — display and headings.
/// * **Manrope** — body and UI.
/// * **JetBrains Mono** — every numeric readout, with tabular figures so a
///   rolling digit never shifts the ones beside it.
abstract final class TideType {
  static const displayFamily = 'Space Grotesk';
  static const bodyFamily = 'Manrope';
  static const gaugeFamily = 'JetBrains Mono';

  /// Tabular figures — mandatory on gauge text. Without this a digit-roll
  /// from 9 to 10 would jitter the whole readout.
  static const _tabular = <FontFeature>[FontFeature.tabularFigures()];

  // --- Display / headings (Space Grotesk) -------------------------------

  /// Screen titles: "Today", "History", "Insights".
  static const screenTitle = TextStyle(
    fontFamily: displayFamily,
    fontWeight: FontWeight.w700,
    fontSize: 30,
    height: 1.1,
    letterSpacing: -0.6,
    color: TideColors.textPrimary,
  );

  /// The onboarding hero and paywall headline.
  static const hero = TextStyle(
    fontFamily: displayFamily,
    fontWeight: FontWeight.w700,
    fontSize: 26,
    height: 1.18,
    letterSpacing: -0.4,
    color: TideColors.textPrimary,
  );

  /// Card headings and habit names.
  static const heading = TextStyle(
    fontFamily: displayFamily,
    fontWeight: FontWeight.w500,
    fontSize: 17,
    height: 1.25,
    letterSpacing: -0.2,
    color: TideColors.textPrimary,
  );

  // --- Body / UI (Manrope) ----------------------------------------------

  static const body = TextStyle(
    fontFamily: bodyFamily,
    fontWeight: FontWeight.w400,
    fontSize: 14.5,
    height: 1.45,
    color: TideColors.textPrimary,
  );

  static const bodyMuted = TextStyle(
    fontFamily: bodyFamily,
    fontWeight: FontWeight.w400,
    fontSize: 14.5,
    height: 1.45,
    color: TideColors.textMuted,
  );

  static const label = TextStyle(
    fontFamily: bodyFamily,
    fontWeight: FontWeight.w500,
    fontSize: 13.5,
    height: 1.3,
    color: TideColors.textPrimary,
  );

  static const labelMuted = TextStyle(
    fontFamily: bodyFamily,
    fontWeight: FontWeight.w400,
    fontSize: 12.5,
    height: 1.3,
    color: TideColors.textMuted,
  );

  /// The all-caps section headers: "HABITS", "NOTIFICATIONS", "SYNC & DATA".
  static const sectionHeader = TextStyle(
    fontFamily: bodyFamily,
    fontWeight: FontWeight.w500,
    fontSize: 11,
    height: 1.2,
    letterSpacing: 1.4,
    color: TideColors.textMuted,
  );

  static const button = TextStyle(
    fontFamily: bodyFamily,
    fontWeight: FontWeight.w700,
    fontSize: 15,
    height: 1.2,
    letterSpacing: 0.1,
    color: TideColors.textPrimary,
  );

  // --- Numeric readouts (JetBrains Mono) --------------------------------

  /// Every streak, percentage and count goes through here.
  static TextStyle gauge(
    double size, {
    Color color = TideColors.textPrimary,
    FontWeight weight = FontWeight.w500,
    double? height,
    double letterSpacing = -0.5,
  }) {
    return TextStyle(
      fontFamily: gaugeFamily,
      fontWeight: weight,
      fontSize: size,
      height: height ?? 1.0,
      letterSpacing: letterSpacing,
      color: color,
      fontFeatures: _tabular,
    );
  }

  /// The big hero number on Home and Insights.
  static TextStyle gaugeHero({Color color = TideColors.textPrimary}) =>
      gauge(42, color: color, weight: FontWeight.w500, letterSpacing: -2);

  /// Stat-chip numbers on Habit detail.
  static TextStyle gaugeStat({Color color = TideColors.tideBlue}) =>
      gauge(26, color: color, letterSpacing: -1);

  /// Small inline counters — streak pills, "5/8", freeze counts.
  static TextStyle gaugeSmall({Color color = TideColors.tideBlue}) =>
      gauge(13, color: color, letterSpacing: -0.2);

  /// Assembles the Material [TextTheme] so stray Material widgets that read
  /// from the theme still land inside the type system.
  static TextTheme get textTheme => const TextTheme(
    displayLarge: screenTitle,
    displayMedium: hero,
    titleLarge: heading,
    titleMedium: label,
    bodyLarge: body,
    bodyMedium: body,
    bodySmall: labelMuted,
    labelLarge: button,
    labelSmall: sectionHeader,
  );
}
