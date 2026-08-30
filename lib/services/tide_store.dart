import 'package:flutter/material.dart';

import '../config/app_constants.dart';
import '../config/milestone_catalog.dart';
import '../config/seed_data.dart';
import 'models/day_summary.dart';
import 'models/habit.dart';
import 'models/milestone.dart';
import 'streak_calculator.dart';
import 'tide_scope.dart';

/// The single source of truth for the running app.
///
/// State lives in memory only: the store opens on [SeedData] every launch
/// and never writes anything back. Actions taken during a session are real —
/// logging a habit genuinely moves the streak, the hero stat and the
/// heatmap — they simply do not outlive the process.
class TideStore extends ChangeNotifier {
  TideStore() : _habits = SeedData.habits() {
    _acknowledgedMilestones = _unlockedIds().toSet();
  }

  List<Habit> _habits;
  late Set<String> _acknowledgedMilestones;

  // --- Profile / preferences -------------------------------------------

  String accountName = 'Jules Ramirez';
  bool isPro = false;
  bool dailyReminders = true;
  bool quietHours = false;
  bool weeklyRecap = false;
  bool haptics = true;
  bool onboardingComplete = false;
  DateTime lastSync = DateTime.now().subtract(const Duration(minutes: 2));

  /// Added to the computed best streak by the milestones screen's
  /// "simulate next unlock" control, so the celebration can be seen without
  /// waiting sixty days for it.
  int _simulatedBonus = 0;

  // --- Reads ------------------------------------------------------------

  /// Active habits, unfinished ones first.
  ///
  /// Home relies on this ordering: a completed habit sinks toward the
  /// bottom, which is what the FLIP-style reorder animates between.
  List<Habit> get habits {
    final active = _habits.where((h) => !h.paused).toList();
    final today = DateUtils.dateOnly(DateTime.now());
    active.sort((a, b) {
      final aDone = a.isCompleteOn(today) || a.isFrozenOn(today);
      final bDone = b.isCompleteOn(today) || b.isFrozenOn(today);
      if (aDone == bDone) return 0;
      return aDone ? 1 : -1;
    });
    return List.unmodifiable(active);
  }

  /// Everything, including paused habits — used by history and settings.
  List<Habit> get allHabits => List.unmodifiable(_habits);

  Habit? habitById(String id) {
    for (final habit in _habits) {
      if (habit.id == id) return habit;
    }
    return null;
  }

  bool get canAddHabit =>
      isPro ||
      _habits.where((h) => !h.paused).length < AppConstants.freeHabitLimit;

  int get activeHabitCount => _habits.where((h) => !h.paused).length;

  DaySummary summaryFor(DateTime date) =>
      StreakCalculator.daySummary(_habits, date);

  DaySummary get today => summaryFor(DateTime.now());

  List<HabitDayEntry> breakdownFor(DateTime date) =>
      StreakCalculator.dayBreakdown(_habits, date);

  double get weeklyRate => StreakCalculator.weeklyRate(_habits);

  double get lastWeeklyRate {
    final lastWeek = DateTime.now().subtract(const Duration(days: 7));
    return StreakCalculator.weeklyRate(_habits, asOf: lastWeek);
  }

  List<double> weeklySeries({int weeks = 8}) =>
      StreakCalculator.weeklySeries(_habits, weeks: weeks);

  List<double> get weekdayRates => StreakCalculator.weekdayRates(_habits);

  int freezesSpent({int days = 30}) =>
      StreakCalculator.freezesSpent(_habits, days: days);

  int get freezesRemaining =>
      _habits.fold(0, (sum, h) => sum + h.freezesRemaining);

  /// The longest streak currently running — the figure Home reports beside
  /// the weekly rate. Distinct from [allTimeBestStreak], which is what
  /// milestones are measured against.
  int get bestActiveStreak {
    var best = 0;
    for (final habit in _habits) {
      if (habit.paused) continue;
      final streak = StreakCalculator.currentStreak(habit);
      if (streak > best) best = streak;
    }
    return best;
  }

  int get allTimeBestStreak =>
      StreakCalculator.bestStreakAcross(_habits) + _simulatedBonus;

  int get cleanStreak => StreakCalculator.cleanStreak(_habits);

  int currentStreakOf(Habit habit) => StreakCalculator.currentStreak(habit);

  int bestStreakOf(Habit habit) => StreakCalculator.bestStreak(habit);

  double rateOf(Habit habit, {int days = 30}) =>
      StreakCalculator.completionRate(habit, days: days);

  // --- Milestones -------------------------------------------------------

  List<MilestoneStatus> get milestones {
    final best = allTimeBestStreak;
    final clean = cleanStreak;

    return MilestoneCatalog.all.map((milestone) {
      final value = milestone.kind == MilestoneKind.streak ? best : clean;
      return MilestoneStatus(
        milestone: milestone,
        unlocked: value >= milestone.threshold,
        progress: (value / milestone.threshold).clamp(0.0, 1.0),
      );
    }).toList();
  }

  int get unlockedMilestoneCount => milestones.where((m) => m.unlocked).length;

  Iterable<String> _unlockedIds() =>
      milestones.where((m) => m.unlocked).map((m) => m.milestone.id);

  /// A milestone that has become unlocked but has not yet been celebrated.
  /// The achievements screen reads this, plays the burst, then acknowledges.
  Milestone? get pendingCelebration {
    for (final status in milestones) {
      if (status.unlocked &&
          !_acknowledgedMilestones.contains(status.milestone.id)) {
        return status.milestone;
      }
    }
    return null;
  }

  void acknowledgeCelebration(Milestone milestone) {
    _acknowledgedMilestones.add(milestone.id);
    notifyListeners();
  }

  /// Pushes the best streak far enough to cross the next locked threshold.
  /// A demo affordance, kept because the unlock burst is the biggest moment
  /// in the app and otherwise unreachable.
  void simulateNextUnlock() {
    final locked = milestones.where(
      (m) => !m.unlocked && m.milestone.kind == MilestoneKind.streak,
    );
    if (locked.isEmpty) return;
    final next = locked.first.milestone;
    _simulatedBonus += next.threshold - allTimeBestStreak;
    notifyListeners();
  }

  // --- Mutations --------------------------------------------------------

  /// Logs [amount] against [habitId] for [date], replacing whatever was
  /// there. Passing null logs the habit's full target.
  void log(String habitId, {num? amount, DateTime? date}) {
    _mutate(habitId, (habit) {
      final day = DateUtils.dateOnly(date ?? DateTime.now());
      final logs = Map<DateTime, num>.from(habit.logs);
      logs[day] = amount ?? habit.target;
      final frozen = Set<DateTime>.from(habit.frozenDays)..remove(day);
      return habit.copyWith(logs: logs, frozenDays: frozen);
    });
  }

  /// Clears a day's log — used by the context menu and by tapping an
  /// already-logged day.
  void unlog(String habitId, {DateTime? date}) {
    _mutate(habitId, (habit) {
      final day = DateUtils.dateOnly(date ?? DateTime.now());
      final logs = Map<DateTime, num>.from(habit.logs)..remove(day);
      return habit.copyWith(logs: logs);
    });
  }

  /// Spends one freeze token so a missed day does not break the loop.
  /// Returns false when the habit has no freezes left.
  bool freeze(String habitId, {DateTime? date}) {
    final habit = habitById(habitId);
    if (habit == null || habit.freezesRemaining <= 0) return false;

    _mutate(habitId, (h) {
      final day = DateUtils.dateOnly(date ?? DateTime.now());
      return h.copyWith(
        frozenDays: Set<DateTime>.from(h.frozenDays)..add(day),
        freezesRemaining: h.freezesRemaining - 1,
      );
    });
    return true;
  }

  void addHabit(Habit habit) {
    _habits = [..._habits, habit];
    notifyListeners();
  }

  void updateHabit(Habit habit) {
    _habits = [
      for (final existing in _habits)
        if (existing.id == habit.id) habit else existing,
    ];
    notifyListeners();
  }

  void deleteHabit(String habitId) {
    _habits = _habits.where((h) => h.id != habitId).toList();
    notifyListeners();
  }

  void togglePause(String habitId) {
    _mutate(habitId, (habit) => habit.copyWith(paused: !habit.paused));
  }

  void deleteAllData() {
    _habits = [];
    _acknowledgedMilestones = {};
    _simulatedBonus = 0;
    notifyListeners();
  }

  /// Restores the demo history — the counterpart to [deleteAllData], so a
  /// curious tap on a destructive row is not a dead end.
  void restoreSeed() {
    _habits = SeedData.habits();
    _simulatedBonus = 0;
    _acknowledgedMilestones = _unlockedIds().toSet();
    notifyListeners();
  }

  void completeOnboarding(List<Habit> chosen) {
    if (chosen.isNotEmpty) _habits = chosen;
    onboardingComplete = true;
    notifyListeners();
  }

  void skipOnboarding() {
    onboardingComplete = true;
    notifyListeners();
  }

  void sync() {
    lastSync = DateTime.now();
    notifyListeners();
  }

  void setPreference({
    bool? dailyReminders,
    bool? quietHours,
    bool? weeklyRecap,
    bool? haptics,
    bool? isPro,
  }) {
    this.dailyReminders = dailyReminders ?? this.dailyReminders;
    this.quietHours = quietHours ?? this.quietHours;
    this.weeklyRecap = weeklyRecap ?? this.weeklyRecap;
    this.haptics = haptics ?? this.haptics;
    this.isPro = isPro ?? this.isPro;
    notifyListeners();
  }

  /// Ids are only ever generated here, so a habit created in the add sheet
  /// and one restored from seed can never collide.
  String newHabitId() =>
      'habit-${DateTime.now().microsecondsSinceEpoch.toRadixString(36)}';

  void _mutate(String habitId, Habit Function(Habit) transform) {
    _habits = [
      for (final habit in _habits)
        if (habit.id == habitId) transform(habit) else habit,
    ];
    notifyListeners();
  }
}

/// Convenience so screens can read `context.tide` rather than spelling out
/// the scope lookup on every line.
extension TideStoreContext on BuildContext {
  TideStore get tide => TideScope.of(this);
}
