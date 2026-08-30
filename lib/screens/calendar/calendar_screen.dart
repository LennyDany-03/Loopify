import 'package:flutter/material.dart';

import '../../services/tide_scope.dart';
import '../../theme/tide_motion.dart';
import '../../theme/tide_typography.dart';
import 'widgets/day_breakdown_sheet.dart';
import 'widgets/intensity_legend.dart';
import 'widgets/month_grid.dart';
import 'widgets/month_pager_header.dart';

/// History — every habit at once, month by month.
///
/// Where Habit detail answers "how is this one going", this answers "how
/// am I going", which is why its cells are aggregates rather than a single
/// habit's logs.
class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  late DateTime _month = DateTime(DateTime.now().year, DateTime.now().month);
  bool _forward = true;

  bool get _canGoNext {
    final now = DateTime.now();
    return _month.year < now.year ||
        (_month.year == now.year && _month.month < now.month);
  }

  void _page(int delta) {
    setState(() {
      _forward = delta > 0;
      _month = DateTime(_month.year, _month.month + delta);
    });
  }

  @override
  Widget build(BuildContext context) {
    final store = TideScope.of(context);

    return ListView(
      padding: EdgeInsets.fromLTRB(
        20,
        MediaQuery.paddingOf(context).top + 16,
        20,
        130,
      ),
      children: [
        const Text('History', style: TideType.screenTitle),
        const SizedBox(height: 20),
        MonthPagerHeader(
          month: _month,
          forward: _forward,
          canGoNext: _canGoNext,
          onPrevious: () => _page(-1),
          onNext: () => _page(1),
        ),
        const SizedBox(height: 14),

        // Keying by month makes the whole grid a new widget each page, so
        // the cells replay their staggered fill instead of silently swapping
        // values in place.
        AnimatedSwitcher(
          duration: TideMotion.tabSwitch,
          switchInCurve: TideMotion.tabCurve,
          transitionBuilder: (child, animation) => FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: Offset(_forward ? 0.06 : -0.06, 0),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            ),
          ),
          child: MonthGrid(
            key: ValueKey('${_month.year}-${_month.month}'),
            month: _month,
            habits: store.allHabits,
            onDayTapped: (date) => showDayBreakdown(
              context,
              date: date,
              entries: store.breakdownFor(date),
            ),
          ),
        ),
        const SizedBox(height: 18),
        const IntensityLegend(),
      ],
    );
  }
}
