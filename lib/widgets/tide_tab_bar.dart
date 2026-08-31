import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';

import '../config/app_constants.dart';
import '../services/models/tide_glyph.dart';
import '../theme/tide_colors.dart';
import '../theme/tide_gradients.dart';
import '../theme/tide_motion.dart';
import '../theme/tide_typography.dart';
import 'habit_glyph.dart';
import 'press_scale.dart';

/// The bottom bar: a frosted pill floating clear of the screen edge.
///
/// It is glass rather than a solid bar because the page keeps scrolling
/// underneath it — you can see the habit rows blur as they pass behind,
/// which is what tells you the list continues rather than ending at the
/// bar. That only works if the body extends behind it, so [TideShell] sets
/// `extendBody: true` and every scrolling tab pads its content by
/// [reservedHeight].
///
/// The active indicator is still a pill that travels rather than a state
/// that blinks on — same mechanic as [SegmentedPill], at a different scale.
class TideTabBar extends StatelessWidget {
  const TideTabBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.tabs = TideTab.all,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<TideTab> tabs;

  /// The glass panel itself.
  static const double barHeight = 64;

  static const double sideMargin = 16;

  /// Between the panel and the safe area below it.
  static const double bottomGap = 12;

  static const BorderRadius _radius = BorderRadius.all(Radius.circular(24));

  /// Everything the bar occupies at the bottom of the screen, including the
  /// system gesture inset.
  ///
  /// Read from `viewPadding` rather than `padding`, so it returns the same
  /// number in the bar's own slot and inside the body — where `extendBody`
  /// has already rewritten `padding.bottom` to mean something else.
  static double reservedHeight(BuildContext context) =>
      barHeight + bottomGap + MediaQuery.viewPaddingOf(context).bottom;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        sideMargin,
        0,
        sideMargin,
        bottomGap + MediaQuery.viewPaddingOf(context).bottom,
      ),
      child: SizedBox(
        height: barHeight,
        child: DecoratedBox(
          // Cast onto the page beneath, so the panel reads as lifted off it
          // rather than cut into it.
          decoration: const BoxDecoration(
            borderRadius: _radius,
            boxShadow: [
              BoxShadow(
                color: Color(0x66000000),
                blurRadius: 24,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: _radius,
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
              child: _GlassPanel(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final tabWidth = constraints.maxWidth / tabs.length;

                    return Stack(
                      children: [
                        AnimatedPositioned(
                          duration: TideMotion.pillSlide,
                          curve: TideMotion.pillCurve,
                          left: tabWidth * currentIndex + 6,
                          top: 6,
                          width: tabWidth - 12,
                          bottom: 6,
                          child: const _ActivePill(),
                        ),
                        Row(
                          children: [
                            for (var i = 0; i < tabs.length; i++)
                              Expanded(
                                child: _Tab(
                                  tab: tabs[i],
                                  active: i == currentIndex,
                                  onTap: () => onTap(i),
                                ),
                              ),
                          ],
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The frosted sheet: a one-pixel gradient rim around a gradient fill.
///
/// Flutter has no gradient `Border`, so the rim is drawn as a gradient
/// container the fill is inset into by exactly a pixel. That gets the edge
/// bright at the top-left and gone by the bottom-right — the same light
/// direction as the inner highlight on every card.
class _GlassPanel extends StatelessWidget {
  const _GlassPanel({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: TideGradients.glassStroke,
        borderRadius: TideTabBar._radius,
      ),
      padding: const EdgeInsets.all(1),
      child: ClipRRect(
        borderRadius: const BorderRadius.all(Radius.circular(23)),
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: TideGradients.glass,
            // A floor under the blur. Without it the glass goes muddy over
            // a bright card and unreadable over deep water.
            color: TideColors.deepWater.withValues(alpha: 0.55),
          ),
          child: child,
        ),
      ),
    );
  }
}

/// The travelling indicator: an accent-washed pane with its own lit edge
/// and a capsule of full-strength gradient across the top.
class _ActivePill extends StatelessWidget {
  const _ActivePill();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(17)),
        gradient: TideGradients.accentWash(alpha: 0.16),
        border: Border.all(
          color: TideColors.tideBlue.withValues(alpha: 0.22),
        ),
        boxShadow: [
          BoxShadow(
            color: TideColors.tideBlue.withValues(alpha: 0.18),
            blurRadius: 16,
            spreadRadius: -4,
          ),
        ],
      ),
      child: Align(
        alignment: Alignment.topCenter,
        child: Container(
          margin: const EdgeInsets.only(top: 4),
          width: 22,
          height: 2.5,
          decoration: const BoxDecoration(
            gradient: TideGradients.accent,
            borderRadius: BorderRadius.all(Radius.circular(2)),
          ),
        ),
      ),
    );
  }
}

class _Tab extends StatelessWidget {
  const _Tab({required this.tab, required this.active, required this.onTap});

  final TideTab tab;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return PressScale(
      onTap: onTap,
      child: SizedBox.expand(
        child: TweenAnimationBuilder<double>(
          tween: Tween<double>(end: active ? 1 : 0),
          duration: TideMotion.tabSwitch,
          curve: TideMotion.tabCurve,
          builder: (context, t, _) {
            final tint = Color.lerp(
              TideColors.textMuted,
              TideColors.foamCyan,
              t,
            )!;

            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Clears the capsule riding the top edge of the active
                // pill: the column centres inside the bar, so this spacer
                // is the room the indicator sits in. Nine is what it takes
                // for the tallest glyph to stay clear of it.
                const SizedBox(height: 9),
                Transform.translate(
                  // The 2px lift that pairs with the crossfade on the page
                  // behind it, so the whole tab switch moves together.
                  offset: Offset(0, -TideMotion.tabSlide * 0.5 * t),
                  child: _GradientGlyph(glyph: tab.glyph, tint: tint, t: t),
                ),
                const SizedBox(height: 7),
                Text(
                  tab.label,
                  style: TideType.labelMuted.copyWith(
                    fontSize: 10.5,
                    letterSpacing: 0.2,
                    color: tint,
                    fontWeight: t > 0.5 ? FontWeight.w700 : FontWeight.w400,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// The glyph, tinted flat when idle and carrying the accent ramp when
/// active — so the selected tab is lit by the same gradient as the pill
/// under it rather than by a second, unrelated highlight colour.
///
/// The gradient copy crossfades in *over* the tinted one rather than
/// replacing it, so the glyph never dims part-way through the switch.
class _GradientGlyph extends StatelessWidget {
  const _GradientGlyph({
    required this.glyph,
    required this.tint,
    required this.t,
  });

  final TideGlyph glyph;
  final Color tint;
  final double t;

  @override
  Widget build(BuildContext context) {
    final flat = HabitGlyph(glyph: glyph, size: 16, color: tint);
    if (t <= 0.01) return flat;

    return Stack(
      alignment: Alignment.center,
      children: [
        flat,
        Opacity(
          opacity: t,
          child: ShaderMask(
            blendMode: BlendMode.srcIn,
            shaderCallback: (bounds) =>
                TideGradients.accent.createShader(bounds),
            child: HabitGlyph(
              glyph: glyph,
              size: 16,
              color: TideColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}
