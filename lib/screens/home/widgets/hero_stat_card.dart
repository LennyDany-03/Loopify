import 'package:flutter/material.dart';

import '../../../theme/tide_colors.dart';
import '../../../theme/tide_motion.dart';
import '../../../theme/tide_typography.dart';
import '../../../widgets/gauge_number.dart';
import '../../../widgets/tide_surface.dart';

/// The day's headline: how many habits are logged, plus the week's rate and
/// the best running streak.
///
/// When the last habit lands, [dayComplete] turns on and the card fills
/// top-to-bottom like an incoming tide. That fill is deliberately a bigger,
/// slower gesture than a single habit's ripple — completing the day is a
/// different size of event from completing one habit, and the motion says so
/// without any extra copy.
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
    return AnimatedBuilder(
      animation: _tide,
      builder: (context, child) {
        final t = _tide.value;
        // Rise, hold, then settle back — the tide coming in and going out.
        final level = t < 0.55
            ? Curves.easeOutCubic.transform(t / 0.55)
            : 1 - Curves.easeInCubic.transform((t - 0.55) / 0.45) * 0.85;

        return TideSurface(
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
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _LoggedCount(
                completed: widget.completed,
                scheduled: widget.scheduled,
              ),
            ),
            _SideStat(
              value: (widget.weeklyRate * 100).round(),
              suffix: '%',
              caption: 'this week',
              color: TideColors.tideBlue,
            ),
            const SizedBox(width: 18),
            _SideStat(
              value: widget.bestStreak,
              caption: 'best streak',
              color: TideColors.textPrimary,
            ),
          ],
        ),
      ),
    );
  }
}

class _LoggedCount extends StatelessWidget {
  const _LoggedCount({required this.completed, required this.scheduled});

  final int completed;
  final int scheduled;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            GaugeNumber(value: completed, style: TideType.gaugeHero()),
            const SizedBox(width: 3),
            Text(
              '/ $scheduled',
              style: TideType.gauge(17, color: TideColors.textMuted),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text('logged today', style: TideType.labelMuted),
      ],
    );
  }
}

class _SideStat extends StatelessWidget {
  const _SideStat({
    required this.value,
    required this.caption,
    required this.color,
    this.suffix,
  });

  final int value;
  final String caption;
  final Color color;
  final String? suffix;

  @override
  Widget build(BuildContext context) {
    // Bounded rather than natural width: left to size themselves, the two
    // captions squeeze the hero number down to nothing on a narrow phone.
    return SizedBox(
      width: 74,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              GaugeNumber(
                value: value,
                style: TideType.gauge(20, color: color),
              ),
              if (suffix != null)
                Text(suffix!, style: TideType.gauge(13, color: color)),
            ],
          ),
          const SizedBox(height: 7),
          Text(
            caption,
            style: TideType.labelMuted.copyWith(fontSize: 11.5),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.end,
          ),
        ],
      ),
    );
  }
}
