import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../config/app_routes.dart';
import '../../services/tide_scope.dart';
import '../../theme/tide_colors.dart';
import '../../theme/tide_typography.dart';
import '../../widgets/press_scale.dart';
import '../../widgets/tide_tab_bar.dart';
import '../../widgets/stagger_list.dart';
import 'widgets/day_callouts.dart';
import 'widgets/freeze_usage_card.dart';
import 'widgets/trend_chart_card.dart';
import 'widgets/weekly_hero_card.dart';

/// The weekly recap.
///
/// Sequenced rather than simultaneous: the hero number rolls up, the trend
/// line draws, and only once the line finishes do the callouts fade in.
/// Everything arriving together would read as a dashboard; arriving in
/// order reads as a report being delivered.
class InsightsScreen extends StatefulWidget {
  const InsightsScreen({super.key});

  @override
  State<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends State<InsightsScreen> {
  bool _chartDrawn = false;

  int get _weekNumber {
    final now = DateTime.now();
    final firstDay = DateTime(now.year);
    return ((now.difference(firstDay).inDays + firstDay.weekday) / 7).ceil();
  }

  @override
  Widget build(BuildContext context) {
    final store = TideScope.of(context);

    return ListView(
      padding: EdgeInsets.fromLTRB(
        20,
        MediaQuery.paddingOf(context).top + 16,
        20,
        TideTabBar.reservedHeight(context) + 28,
      ),
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Expanded(
              child: Text('Insights', style: TideType.screenTitle),
            ),
            PressScale(
              onTap: () => context.push(Routes.milestones),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                child: Text('WEEK $_weekNumber', style: TideType.sectionHeader),
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),

        WeeklyHeroCard(
          rate: store.weeklyRate,
          previousRate: store.lastWeeklyRate,
        ),
        const SizedBox(height: 12),

        TrendChartCard(
          values: store.weeklySeries(),
          onFinished: () {
            if (mounted && !_chartDrawn) {
              setState(() => _chartDrawn = true);
            }
          },
        ),
        const SizedBox(height: 12),

        // Held back until the line lands.
        AnimatedOpacity(
          opacity: _chartDrawn ? 1 : 0,
          duration: const Duration(milliseconds: 420),
          child: _chartDrawn
              ? StaggerColumn(
                  spacing: 12,
                  children: [
                    DayCallouts(weekdayRates: store.weekdayRates),
                    FreezeUsageCard(
                      spent: store.freezesSpent(),
                      remaining: store.freezesRemaining,
                    ),
                    _MilestonesLink(
                      unlocked: store.unlockedMilestoneCount,
                      total: store.milestones.length,
                      onTap: () => context.push(Routes.milestones),
                    ),
                  ],
                )
              : const SizedBox(height: 240, width: double.infinity),
        ),
      ],
    );
  }
}

class _MilestonesLink extends StatelessWidget {
  const _MilestonesLink({
    required this.unlocked,
    required this.total,
    required this.onTap,
  });

  final int unlocked;
  final int total;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return PressScale(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
        decoration: BoxDecoration(
          color: TideColors.foamCyan.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: TideColors.foamCyan.withValues(alpha: 0.25),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Milestones',
                    style: TideType.heading.copyWith(
                      color: TideColors.foamCyan,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    '$unlocked of $total surfaced',
                    style: TideType.labelMuted,
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: TideColors.foamCyan,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}
