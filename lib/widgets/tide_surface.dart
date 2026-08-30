import 'package:flutter/material.dart';

import '../theme/tide_colors.dart';
import '../theme/tide_elevation.dart';

/// A card, sheet, row or chip — anything that sits above the page.
///
/// Carries the whole elevation recipe: the shallow fill, the radius, one of
/// the two shadow sets, and the 1px inner highlight along the top edge that
/// keeps a flat surface from looking like a hole.
class TideSurface extends StatelessWidget {
  const TideSurface({
    super.key,
    required this.child,
    this.radius = TideElevation.radius16,
    this.color,
    this.floating = false,
    this.padding,
    this.margin,
    this.border,
    this.highlight = true,
    this.shadows,
    this.width,
    this.height,
  });

  final Widget child;
  final BorderRadius radius;
  final Color? color;

  /// Floating surfaces (FAB, sheets, context menus) take the deeper shadow.
  final bool floating;

  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BoxBorder? border;

  /// The top inner highlight. Off for recessed wells, which should read as
  /// carved *into* the surface rather than raised off it.
  final bool highlight;

  /// Escape hatch for the FAB's glow. Everything else should use [floating].
  final List<BoxShadow>? shadows;

  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        color: color ?? TideColors.shallow,
        borderRadius: radius,
        border: border,
        boxShadow:
            shadows ??
            (floating ? TideElevation.floating : TideElevation.resting),
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: Stack(
          // Hand the surface's own constraints to the content rather than
          // loosening them, so a card never shrinks to fit its text.
          fit: StackFit.passthrough,
          children: [
            if (padding != null)
              Padding(padding: padding!, child: child)
            else
              child,
            if (highlight)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: TideElevation.innerHighlightWidth,
                child: IgnorePointer(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: TideElevation.innerHighlightGradient,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// A recessed well: the inverse of [TideSurface]. Used for empty heatmap
/// cells, text inputs and the inactive track behind a sliding pill.
class TideWell extends StatelessWidget {
  const TideWell({
    super.key,
    required this.child,
    this.radius = TideElevation.radius12,
    this.padding,
    this.color,
    this.border,
  });

  final Widget child;
  final BorderRadius radius;
  final EdgeInsetsGeometry? padding;
  final Color? color;
  final BoxBorder? border;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color ?? TideColors.well,
        borderRadius: radius,
        border: border,
      ),
      child: child,
    );
  }
}
