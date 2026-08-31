import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../services/models/milestone.dart';
import '../../services/tide_scope.dart';
import '../../theme/tide_colors.dart';
import '../../theme/tide_elevation.dart';
import '../../theme/tide_typography.dart';
import '../../widgets/tide_backdrop.dart';
import '../../widgets/press_scale.dart';
import 'widgets/badge_grid.dart';
import 'widgets/share_card_view.dart';
import 'widgets/unlock_celebration.dart';

/// Milestones.
///
/// A full-screen destination rather than a tab: you come here when
/// something has happened, not to browse. The unlock celebration is the
/// rarest and biggest animation in the app, and this is the only place it
/// plays.
class AchievementsScreen extends StatefulWidget {
  const AchievementsScreen({super.key});

  @override
  State<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen> {
  Milestone? _celebrating;

  @override
  void initState() {
    super.initState();
    // Anything unlocked while the user was elsewhere gets its moment on
    // arrival rather than being silently already-on.
    WidgetsBinding.instance.addPostFrameCallback((_) => _playPending());
  }

  void _playPending() {
    if (!mounted || _celebrating != null) return;
    final pending = TideScope.read(context).pendingCelebration;
    if (pending != null) setState(() => _celebrating = pending);
  }

  void _finishCelebration() {
    final milestone = _celebrating;
    if (milestone == null) return;
    TideScope.read(context).acknowledgeCelebration(milestone);
    setState(() => _celebrating = null);
    // More than one may have surfaced at once; play them in turn.
    WidgetsBinding.instance.addPostFrameCallback((_) => _playPending());
  }

  void _simulate() {
    TideScope.read(context).simulateNextUnlock();
    WidgetsBinding.instance.addPostFrameCallback((_) => _playPending());
  }

  @override
  Widget build(BuildContext context) {
    final store = TideScope.of(context);
    final statuses = store.milestones;
    final unlocked = statuses.where((s) => s.unlocked).length;

    return Scaffold(
      backgroundColor: TideColors.deepWater,
      body: Stack(
        children: [
          const Positioned.fill(child: TideBackdrop()),
          ListView(
            padding: EdgeInsets.fromLTRB(
              20,
              MediaQuery.paddingOf(context).top + 16,
              20,
              40 + MediaQuery.paddingOf(context).bottom,
            ),
            children: [
              Row(
                children: [
                  PressScale(
                    onTap: () => context.pop(),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: TideColors.shallow,
                        borderRadius: TideElevation.radius12,
                      ),
                      child: const Icon(
                        Icons.arrow_back_rounded,
                        size: 18,
                        color: TideColors.textPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Text('Milestones', style: TideType.screenTitle),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Padding(
                padding: const EdgeInsets.only(left: 50),
                child: Text(
                  '$unlocked of ${statuses.length} surfaced',
                  style: TideType.labelMuted,
                ),
              ),
              const SizedBox(height: 22),

              BadgeGrid(
                statuses: statuses,
                onTapBadge: (status) => showShareCard(
                  context,
                  milestone: status.milestone,
                  streak: store.allTimeBestStreak,
                  accountName: store.accountName,
                ),
              ),
              const SizedBox(height: 16),

              // A demo affordance, kept deliberately: the unlock burst is
              // the best animation in the app and would otherwise be
              // unreachable without waiting sixty days for it.
              PressScale(
                onTap: _simulate,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: TideColors.tideBlue.withValues(alpha: 0.10),
                    borderRadius: TideElevation.radius12,
                    border: Border.all(
                      color: TideColors.tideBlue.withValues(alpha: 0.25),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      'Simulate next unlock',
                      style: TideType.button.copyWith(
                        color: TideColors.tideBlue,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: TideTopScrim(),
          ),
          if (_celebrating != null)
            Positioned.fill(
              child: UnlockCelebration(
                milestone: _celebrating!,
                onDismiss: _finishCelebration,
              ),
            ),
        ],
      ),
    );
  }
}
