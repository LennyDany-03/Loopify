import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'tide_colors.dart';
import 'tide_elevation.dart';
import 'tide_typography.dart';

/// Assembles the Material theme from the Tide tokens.
///
/// Note the transparent splash and highlight: press feedback in this app is
/// always `PressScale`, never a Material ink ripple. Leaving ink enabled
/// would put two different press languages on screen at once.
abstract final class TideTheme {
  static ThemeData get dark {
    const scheme = ColorScheme.dark(
      primary: TideColors.tideBlue,
      onPrimary: TideColors.deepWater,
      secondary: TideColors.foamCyan,
      onSecondary: TideColors.deepWater,
      tertiary: TideColors.kelpGreen,
      error: TideColors.coral,
      onError: TideColors.textPrimary,
      surface: TideColors.shallow,
      onSurface: TideColors.textPrimary,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: scheme,
      scaffoldBackgroundColor: TideColors.deepWater,
      canvasColor: TideColors.deepWater,
      fontFamily: TideType.bodyFamily,
      textTheme: TideType.textTheme,

      // Press feedback is PressScale everywhere — kill Material ink.
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      hoverColor: Colors.transparent,
      splashFactory: NoSplash.splashFactory,

      textSelectionTheme: TextSelectionThemeData(
        cursorColor: TideColors.tideBlue,
        selectionColor: TideColors.tideBlue.withValues(alpha: 0.3),
        selectionHandleColor: TideColors.tideBlue,
      ),
      dividerTheme: DividerThemeData(
        color: TideColors.divider,
        thickness: 1,
        space: 1,
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: Colors.transparent,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: TideColors.raised,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: TideElevation.radius24,
        ),
      ),
      // One transition family on every platform. go_router supplies the
      // screen-specific transitions; this is only the fallback.
      pageTransitionsTheme: PageTransitionsTheme(
        builders: {
          for (final platform in TargetPlatform.values)
            platform: const FadeForwardsPageTransitionsBuilder(),
        },
      ),
    );
  }

  /// Light status-bar icons on the deep-water ground, edge-to-edge.
  static const SystemUiOverlayStyle overlayStyle = SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    statusBarBrightness: Brightness.dark,
    systemNavigationBarColor: TideColors.deepWater,
    systemNavigationBarIconBrightness: Brightness.light,
  );
}
