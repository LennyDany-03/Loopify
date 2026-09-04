import 'package:flutter/material.dart';

import '../../../theme/tide_colors.dart';
import '../../../theme/tide_elevation.dart';
import '../../../theme/tide_gradients.dart';
import '../../../theme/tide_motion.dart';
import '../../../theme/tide_typography.dart';
import '../../../widgets/gauge_number.dart';
import '../../../widgets/tide_ring.dart';
import '../../../widgets/tide_surface.dart';

/// The day's headline: how many habits are logged, plus the week's rate and
/// the best running streak.
///
/// Three tiers, largest to smallest, so the card can be read at any depth:
/// the ring answers "am I on track" from across the room, the count answers
/// "how far in" at a glance, and the two wells underneath answer "how is
/// the week going" only if you actually stop to look. Flattening those into
/// one row of equal-weight numbers — the old layout — made every figure
/// compete and none of them land.
///
/// When the last habit lands, [dayComplete] turns on and the card fills
/// top-to-bottom like an incoming tide. That fill is deliberately a bigger,
/// slower gesture than a single habit's ripple — completing the day is a
/// different size of event from completing one habit, and the motion says
/// so without any extra copy.
class HeroStatCard extends StatefulWidget {
  const HeroStatCard({
    super.key,
    required this.completed,
    required this.scheduled,
    required this.weeklyRate,
    required this.bestStreak,
    required this.dayComplete,
  });

  final int completed;
  final int scheduled;
  final double weeklyRate;
  final int bestStreak;
  final bool dayComplete;

  @override
  State<HeroStatCard> createState() => _HeroStatCardState();
}

class _HeroStatCardState extends State<HeroStatCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _tide = AnimationController(
    vsync: this,
    duration: TideMotion.dayComplete,
  );

  double get _dayProgress =>
      widget.scheduled == 0 ? 0 : widget.completed / widget.scheduled;

  @override
  void didUpdateWidget(HeroStatCard old) {
    super.didUpdateWidget(old);
    // Only on the transition into completeness — re-entering the screen
    // with the day already done should not replay the celebration.
    if (!old.dayComplete && widget.dayComplete) {
      _tide
        ..reset()
        ..forward();
    }
  }

  @override
  void dispose() {
    _tide.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final done = widget.dayComplete;

    return AnimatedBuilder(
      animation: _tide,
      builder: (context, child) {
        final t = _tide.value;
        // Rise, hold, then settle back — the tide coming in and going out.
        final level = t < 0.55
            ? Curves.easeOutCubic.transform(t / 0.55)
            : 1 - Curves.easeInCubic.transform((t - 0.55) / 0.45) * 0.85;

        return TideSurface(
          radius: TideElevation.radius24,
          // A completed day swaps the whole ground to kelp rather than
          // badging the corner — same move as a logged habit row.
          gradient: done
              ? TideGradients.completedWash(alpha: 0.16)
              : TideGradients.hero,
          shadows: [
            ...TideElevation.resting,
            BoxShadow(
              color: (done ? TideColors.kelpGreen : TideColors.tideBlue)
                  .withValues(alpha: 0.16),
              blurRadius: 26,
              spreadRadius: -8,
              offset: const Offset(0, 8),
            ),
          ],
          child: Stack(
            children: [
              if (t > 0)
                Positioned.fill(
                  child: IgnorePointer(
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: FractionallySizedBox(
                        heightFactor: level.clamp(0.0, 1.0),
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                TideColors.kelpGreen.withValues(alpha: 0.30),
                                TideColors.foamCyan.withValues(alpha: 0.14),
                              ],
                            ),
                          ),
                          child: const SizedBox.expand(),
                        ),
                      ),
                    ),
                  ),
                ),
              child!,
            ],
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 18, 18, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: _LoggedCount(
                    completed: widget.completed,
                    scheduled: widget.scheduled,
                    done: done,
                  ),
                ),
                _DayRing(progress: _dayProgress, done: done),
              ],
            ),
            const SizedBox(height: 16),
            const _Hairline(),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: _StatWell(
                    value: (widget.weeklyRate * 100).round(),
                    suffix: '%',
                    caption: 'this week',
                    accent: TideColors.tideBlue,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _StatWell(
                    value: widget.bestStreak,
                    caption: 'best streak',
                    accent: TideColors.foamCyan,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _LoggedCount extends StatelessWidget {
  const _LoggedCount({
    required this.completed,
    required this.scheduled,
    required this.done,
  });

  final int completed;
  final int scheduled;
  final bool done;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              // The hero figure is the one place a gradient touches type:
              // it is the number the whole screen exists to show.
              ShaderMask(
                blendMode: BlendMode.srcIn,
                shaderCallback: (bounds) =>
                    (done ? TideGradients.completed : TideGradients.accent)
                        .createShader(bounds),
                child: GaugeNumber(
                  value: completed,
                  style: TideType.gaugeHero(),
                ),
              ),
              const SizedBox(width: 4),
              Text(
                '/ $scheduled',
                style: TideType.gauge(18, color: TideColors.textMuted),
              ),
            ],
          ),
        ),
        const SizedBox(height: 7),
        Text(
          done ? 'all logged today' : 'logged today',
          style: TideType.labelMuted.copyWith(
            color: done ? TideColors.kelpGreen : TideColors.textMuted,
          ),
        ),
      ],
    );
  }
}

/// The day as a ring — the app's identity object, at the one size where it
/// is a headline rather than a row ornament.
class _DayRing extends StatelessWidget {
  const _DayRing({required this.progress, required this.done});

  final double progress;
  final bool done;

  @override
  Widget build(BuildContext context) {
    final accent = done ? TideColors.kelpGreen : TideColors.tideBlue;

    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: accent.withValues(alpha: progress > 0 ? 0.22 : 0),
            blurRadius: 20,
            spreadRadius: -6,
          ),
        ],
      ),
      child: TideRing(
        progress: progress,
        size: 68,
        strokeWidth: 5,
        color: accent,
        // Lighter than the default track: at this size an empty ring with
        // the standard track reads as a grey donut competing with the
        // count, rather than as a gauge waiting to fill.
        trackColor: TideColors.textMuted.withValues(alpha: 0.10),
        child: Text(
          '${(progress * 100).round()}%',
          style: TideType.gaugeSmall(
            color: progress > 0 ? TideColors.textPrimary : TideColors.textMuted,
          ),
        ),
      ),
    );
  }
}

/// A separator that fades out before it reaches the card's rounded corners.
class _Hairline extends StatelessWidget {
  const _Hairline();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1,
      decoration: BoxDecoration(gradient: TideGradients.hairline),
    );
  }
}

/// A secondary figure, recessed into the card.
///
/// Sinking these rather than floating them is what keeps them a tier below
/// the count and the ring: they are lit from below, everything above them
/// is lit from above.
class _StatWell extends StatelessWidget {
  const _StatWell({
    required this.value,
    required this.caption,
    required this.accent,
    this.suffix,
  });

  final int value;
  final String caption;
  final Color accent;
  final String? suffix;

  @override
  Widget build(BuildContext context) {
    return TideWell(
      radius: TideElevation.radius12,
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 11),
      border: Border.all(color: Colors.white.withValues(alpha: 0.03)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Two wells share the row; a three-digit figure with a suffix
          // scales down rather than spilling past the well's edge.
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Container(
                  width: 3,
                  height: 15,
                  margin: const EdgeInsets.only(right: 9),
                  decoration: BoxDecoration(
                    color: accent,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                GaugeNumber(value: value, style: TideType.gauge(19)),
                if (suffix != null) Text(suffix!, style: TideType.gauge(12.5)),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Text(
            caption,
            style: TideType.labelMuted.copyWith(fontSize: 11.5),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
