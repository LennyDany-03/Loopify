import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../config/app_constants.dart';
import '../../config/app_routes.dart';
import '../../services/tide_scope.dart';
import '../../theme/tide_colors.dart';
import '../../theme/tide_motion.dart';
import '../../widgets/tide_backdrop.dart';
import '../../widgets/tide_fab.dart';
import '../../widgets/tide_tab_bar.dart';

/// The frame around the four tabs.
///
/// Holds the page ground, the tab bar and the floating add action. The tab
/// bodies stay alive in a stack rather than being rebuilt, so switching
/// away from a half-scrolled Insights and back does not lose the position —
/// and the crossfade has something real to fade between.
///
/// The backdrop is mounted once here rather than per screen, so all four
/// tabs share a single continuous ground: switching tabs moves the content
/// across a background that never moves, which is what makes the four feel
/// like rooms in one app instead of four separate pages.
class TideShell extends StatelessWidget {
  const TideShell({
    super.key,
    required this.navigationShell,
    required this.branches,
  });

  final StatefulNavigationShell navigationShell;
  final List<Widget> branches;

  /// Settings has no add action; everywhere else the FAB is the primary way
  /// a habit gets created.
  bool get _showFab => navigationShell.currentIndex != 3;

  void _onTap(int index) {
    navigationShell.goBranch(
      index,
      // Tapping the tab you are already on pops back to its root — the
      // standard escape hatch out of a pushed detail screen.
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  void _onAdd(BuildContext context) {
    final store = TideScope.read(context);
    // The paywall is contextual: it appears at the moment the free ceiling
    // actually blocks something, never as a nag.
    context.push(store.canAddHabit ? Routes.newHabit : Routes.upgrade);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TideColors.deepWater,
      // The tab bar is frosted glass, so the page has to keep going behind
      // it — there is nothing for a blur to sample otherwise. Scrolling
      // screens buy that space back with `TideTabBar.reservedHeight`.
      extendBody: true,
      body: Stack(
        children: [
          const Positioned.fill(child: TideBackdrop()),
          Positioned.fill(
            child: _BranchStack(
              currentIndex: navigationShell.currentIndex,
              branches: branches,
            ),
          ),
          Positioned(
            right: 20,
            bottom: TideTabBar.reservedHeight(context) + 14,
            child: TideFabSlot(
              visible: _showFab,
              child: TideFab(onPressed: () => _onAdd(context)),
            ),
          ),
        ],
      ),
      bottomNavigationBar: TideTabBar(
        currentIndex: navigationShell.currentIndex,
        onTap: _onTap,
        tabs: TideTab.all,
      ),
    );
  }
}

/// Crossfade plus a 4px slide between tabs, with every branch kept mounted.
class _BranchStack extends StatelessWidget {
  const _BranchStack({required this.currentIndex, required this.branches});

  final int currentIndex;
  final List<Widget> branches;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        for (var i = 0; i < branches.length; i++)
          _Branch(active: i == currentIndex, child: branches[i]),
      ],
    );
  }
}

class _Branch extends StatelessWidget {
  const _Branch({required this.active, required this.child});

  final bool active;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: active ? 1 : 0,
      duration: TideMotion.tabSwitch,
      curve: TideMotion.tabCurve,
      child: AnimatedSlide(
        offset: active ? Offset.zero : const Offset(0, 0.012),
        duration: TideMotion.tabSwitch,
        curve: TideMotion.tabCurve,
        child: IgnorePointer(
          ignoring: !active,
          // Pausing tickers on hidden branches keeps four screens' worth of
          // ambient animation from running at once.
          child: TickerMode(enabled: active, child: child),
        ),
      ),
    );
  }
}
