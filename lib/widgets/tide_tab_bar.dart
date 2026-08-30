import 'package:flutter/material.dart';

import '../config/app_constants.dart';
import '../theme/tide_colors.dart';
import '../theme/tide_motion.dart';
import '../theme/tide_typography.dart';
import 'habit_glyph.dart';
import 'press_scale.dart';

/// The bottom bar.
///
/// The active indicator is a pill that slides along the top edge — the same
/// mechanic as [SegmentedPill], at a different scale. Nothing here jumps:
/// the pill travels, the glyph tints, the label tints.
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

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return Container(
      padding: EdgeInsets.only(bottom: bottomInset),
      decoration: BoxDecoration(
        color: TideColors.deepWater,
        border: Border(top: BorderSide(color: TideColors.divider)),
      ),
      child: SizedBox(
        height: 60,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final tabWidth = constraints.maxWidth / tabs.length;

            return Stack(
              children: [
                AnimatedPositioned(
                  duration: TideMotion.pillSlide,
                  curve: TideMotion.pillCurve,
                  left: tabWidth * currentIndex + tabWidth / 2 - 16,
                  top: 0,
                  width: 32,
                  height: 2.5,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: TideColors.tideBlue,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween<double>(end: active ? 1 : 0),
              duration: TideMotion.tabSwitch,
              curve: TideMotion.tabCurve,
              builder: (context, t, _) {
                return Transform.translate(
                  // The 4px lift that pairs with the crossfade on the page
                  // behind it, so the whole tab switch moves together.
                  offset: Offset(0, -TideMotion.tabSlide * t),
                  child: HabitGlyph(
                    glyph: tab.glyph,
                    size: 16,
                    color: Color.lerp(
                      TideColors.textMuted,
                      TideColors.tideBlue,
                      t,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 6),
            AnimatedDefaultTextStyle(
              duration: TideMotion.tabSwitch,
              style: TideType.labelMuted.copyWith(
                fontSize: 11,
                color: active ? TideColors.tideBlue : TideColors.textMuted,
                fontWeight: active ? FontWeight.w700 : FontWeight.w400,
              ),
              child: Text(tab.label),
            ),
          ],
        ),
      ),
    );
  }
}
