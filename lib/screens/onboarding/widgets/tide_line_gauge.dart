import 'package:flutter/material.dart';

import '../../../theme/tide_colors.dart';
import '../../../theme/tide_motion.dart';

/// Onboarding progress, as a water level rather than dots.
///
/// Dots would say "five things to get through". A rising line says "this is
/// filling up", which is both more honest about a short flow and the same
/// metaphor the rest of the app runs on.
class TideLineGauge extends StatelessWidget {
  const TideLineGauge({super.key, required this.progress, this.height = 2.5});

  /// 0..1.
  final double progress;

  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: TideColors.textMuted.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(height),
              ),
            ),
          ),
          TweenAnimationBuilder<double>(
            tween: Tween<double>(end: progress.clamp(0.0, 1.0)),
            duration: TideMotion.sheetIn,
            curve: TideMotion.sheetCurve,
            builder: (context, t, _) {
              return FractionallySizedBox(
                widthFactor: t,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        TideColors.tideBlue,
                        TideColors.foamCyan.withValues(alpha: 0.9),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(height),
                  ),
                  // As in the calendar day cell: a childless DecoratedBox
                  // collapses on the unconstrained axis, which would leave
                  // the gauge zero pixels tall.
                  child: const SizedBox.expand(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

/// The very slow ambient drift behind onboarding.
///
/// This is the one screen in Tide allowed a looping background. Everywhere
/// else, motion has to be caused by something the user did — but a
/// first-run screen has no history to show yet, and stillness here would
/// read as an unloaded page.
class AmbientDrift extends StatefulWidget {
  const AmbientDrift({super.key});

  @override
  State<AmbientDrift> createState() => _AmbientDriftState();
}

class _AmbientDriftState extends State<AmbientDrift>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: TideMotion.ambientDrift,
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final t = Curves.easeInOut.transform(_controller.value);
          return DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(-0.4 + 0.8 * t, -0.7 + 0.3 * t),
                radius: 1.1 + 0.2 * t,
                colors: [
                  TideColors.tideBlue.withValues(alpha: 0.07),
                  TideColors.deepWater.withValues(alpha: 0),
                ],
              ),
            ),
            child: const SizedBox.expand(),
          );
        },
      ),
    );
  }
}
