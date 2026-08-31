import 'package:flutter_test/flutter_test.dart';
import 'package:tide/main.dart';
import 'package:tide/widgets/tide_tab_bar.dart';

/// The tab bar is the shell's own readout of which branch is selected, so
/// reading it is the same as asking the shell.
int selectedTab(WidgetTester tester) =>
    tester.widget<TideTabBar>(find.byType(TideTabBar)).currentIndex;

/// Starts the drag high on the page, clear of the habit rows — those carry
/// their own horizontal gesture, which the conflict test below covers
/// deliberately rather than by accident.
Future<void> swipePage(WidgetTester tester, double dx) async {
  await tester.flingFrom(const Offset(400, 120), Offset(dx, 0), 900);
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 500));
}

void main() {
  Future<void> openShell(WidgetTester tester) async {
    await tester.pumpWidget(const TideApp(startOnboarded: true));
    // Fixed pumps rather than pumpAndSettle: several screens carry
    // deliberate ambient loops that never settle by design.
    await tester.pump(const Duration(milliseconds: 900));
  }

  testWidgets('swiping left walks forward through the tabs', (tester) async {
    await openShell(tester);
    expect(selectedTab(tester), 0);

    for (final expected in [1, 2, 3]) {
      await swipePage(tester, -320);
      expect(selectedTab(tester), expected);
    }

    // Landing on a tab arms its entrance staggers; let them run out so the
    // test does not end with timers still pending.
    await tester.pump(const Duration(seconds: 2));
  });

  testWidgets('swiping right walks back through the tabs', (tester) async {
    await openShell(tester);
    for (var i = 0; i < 3; i++) {
      await swipePage(tester, -320);
    }
    expect(selectedTab(tester), 3);

    for (final expected in [2, 1, 0]) {
      await swipePage(tester, 320);
      expect(selectedTab(tester), expected);
    }
  });

  testWidgets('the ends of the row hold', (tester) async {
    await openShell(tester);

    // Nothing sits before Today...
    await swipePage(tester, 320);
    expect(selectedTab(tester), 0);

    for (var i = 0; i < 3; i++) {
      await swipePage(tester, -320);
    }
    // ...or after Settings.
    await swipePage(tester, -320);
    expect(selectedTab(tester), 3);
  });

  testWidgets('a short drag springs back instead of changing tab', (
    tester,
  ) async {
    await openShell(tester);

    // Well under the commit threshold, and slow enough not to read as a
    // fling — the page should give and come back.
    await tester.dragFrom(const Offset(400, 120), const Offset(-40, 0));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(selectedTab(tester), 0);
  });

  testWidgets('a habit row keeps its own swipe', (tester) async {
    await openShell(tester);

    // The row's swipe-to-log recogniser sits deeper than the shell's, so it
    // should win the arena and the tab should not move underneath it.
    await tester.fling(
      find.text('No screens after 10'),
      const Offset(-320, 0),
      900,
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(selectedTab(tester), 0);
  });
}
