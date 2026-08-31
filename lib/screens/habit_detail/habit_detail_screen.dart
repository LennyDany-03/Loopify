import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../config/app_routes.dart';
import '../../services/streak_calculator.dart';
import '../../services/tide_scope.dart';
import '../../theme/tide_colors.dart';
import '../../theme/tide_motion.dart';
import '../../theme/tide_typography.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/tide_surface.dart';
import '../../widgets/trend_chart.dart';
import 'widgets/detail_actions.dart';
import 'widgets/detail_header.dart';
import 'widgets/month_heatmap.dart';
import 'widgets/streak_stat_row.dart';

/// Everything about one habit: its history, its numbers, and the controls
/// for changing or ending it.
class HabitDetailScreen extends StatefulWidget {
  const HabitDetailScreen({super.key, required this.habitId});

  final String habitId;

  @override
  State<HabitDetailScreen> createState() => _HabitDetailScreenState();
}

class _HabitDetailScreenState extends State<HabitDetailScreen>
    with SingleTickerProviderStateMixin {
  /// Drives the "drain" — pausing a habit desaturates it over 400ms rather
  /// than flipping to a grey state, so the habit reads as going quiet
  /// instead of being switched off.
  late final AnimationController _drain = AnimationController(
    vsync: this,
    duration: TideMotion.drain,
  );

  @override
  void initState() {
    super.initState();
    final habit = TideScope.read(context).habitById(widget.habitId);
    if (habit?.paused ?? false) _drain.value = 1;
  }

  @override
  void dispose() {
    _drain.dispose();
    super.dispose();
  }

  void _togglePause() {
    final store = TideScope.read(context);
    final habit = store.habitById(widget.habitId);
    if (habit == null) return;

    store.togglePause(habit.id);
    habit.paused ? _drain.reverse() : _drain.forward();
  }

  void _delete() {
    TideScope.read(context).deleteHabit(widget.habitId);
    if (mounted) context.go(Routes.today);
  }

  @override
  Widget build(BuildContext context) {
    final store = TideScope.of(context);
    final habit = store.habitById(widget.habitId);

    if (habit == null) {
      return Center(
        child: TideEmptyNote(message: 'This habit is no longer here.'),
      );
    }

    return AnimatedBuilder(
      animation: _drain,
      builder: (context, child) {
        // Desaturating the whole screen at once is what makes "drain" read
        // as one action rather than several widgets changing colour.
        return Opacity(
          opacity: 1 - 0.25 * _drain.value,
          child: ColorFiltered(
            colorFilter: ColorFilter.mode(
              TideColors.textMuted.withValues(alpha: 0.3 * _drain.value),
              BlendMode.saturation,
            ),
            child: child,
          ),
        );
      },
      child: ListView(
        padding: EdgeInsets.fromLTRB(
          20,
          MediaQuery.paddingOf(context).top + 16,
          20,
          130,
        ),
        children: [
          DetailHeader(
            habit: habit,
            onBack: () => context.pop(),
            drain: _drain.value,
          ),
          const SizedBox(height: 20),
          StreakStatRow(
            currentStreak: StreakCalculator.currentStreak(habit),
            bestStreak: StreakCalculator.bestStreak(habit),
            rate: StreakCalculator.completionRate(habit),
          ),
          const SizedBox(height: 12),
          MonthHeatmap(habit: habit, month: DateTime.now()),
          const SizedBox(height: 12),
          TideSurface(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Completion trend', style: TideType.heading),
                const SizedBox(height: 20),
                TrendChart(
                  values: StreakCalculator.habitTrend(habit),
                  delay: const Duration(milliseconds: 260),
                ),
                const SizedBox(height: 6),
                Text(
                  'Rolling two-week rate, eight weeks',
                  style: TideType.labelMuted.copyWith(fontSize: 11.5),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          DetailActions(
            paused: habit.paused,
            onEdit: () => context.push(Routes.editHabit(habit.id)),
            onPause: _togglePause,
            onDelete: _delete,
          ),
        ],
      ),
    );
  }
}
