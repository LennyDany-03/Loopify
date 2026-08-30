import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/tide_motion.dart';
import '../theme/tide_typography.dart';

/// An odometer.
///
/// Numbers in Tide never plain-swap — a streak going from 12 to 13 rolls,
/// with the lower digits spinning faster than the higher ones, exactly like
/// a mechanical counter. Every streak, count and percentage on screen goes
/// through this widget or [GaugeCountUp].
class GaugeNumber extends StatelessWidget {
  const GaugeNumber({
    super.key,
    required this.value,
    required this.style,
    this.minDigits = 1,
    this.duration = TideMotion.digitRoll,
  });

  final int value;
  final TextStyle style;

  /// Pads with leading zeros — used by the reminder time readout (08:00).
  final int minDigits;

  final Duration duration;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(end: value.toDouble()),
      duration: duration,
      curve: TideMotion.digitRollCurve,
      builder: (context, animated, _) {
        return _Odometer(
          value: animated,
          target: value,
          style: style,
          minDigits: minDigits,
        );
      },
    );
  }
}

class _Odometer extends StatelessWidget {
  const _Odometer({
    required this.value,
    required this.target,
    required this.style,
    required this.minDigits,
  });

  final double value;
  final int target;
  final TextStyle style;
  final int minDigits;

  @override
  Widget build(BuildContext context) {
    final magnitude = math.max(target.abs(), value.abs().floor());
    final digits = math.max(minDigits, magnitude.toString().length);
    final negative = target < 0;
    final magnitudeValue = value.abs();

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        if (negative) Text('-', style: style),
        for (var place = digits - 1; place >= 0; place--)
          _DigitWheel(value: magnitudeValue, place: place, style: style),
      ],
    );
  }
}

/// One digit column. Shows the current digit and the next one stacked, and
/// slides between them only while the place below is wrapping — which is
/// what gives the staggered mechanical feel rather than every digit
/// spinning at once.
class _DigitWheel extends StatelessWidget {
  const _DigitWheel({
    required this.value,
    required this.place,
    required this.style,
  });

  final double value;
  final int place;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    final divisor = math.pow(10, place).toDouble();
    final scaled = value / divisor;
    final digit = scaled.floor() % 10;
    final fraction = scaled - scaled.floorToDouble();

    // Only the last tenth of a place's travel actually turns the wheel;
    // below that the digit sits still while the wheels beneath it spin.
    final roll = ((fraction * 10) - 9).clamp(0.0, 1.0);

    final size = _measure('0', style);

    return SizedBox(
      width: size.width,
      height: size.height,
      child: ClipRect(
        child: Stack(
          children: [
            Positioned(
              top: -roll * size.height,
              child: SizedBox(
                width: size.width,
                height: size.height,
                child: Text(
                  '$digit',
                  style: style,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            Positioned(
              top: (1 - roll) * size.height,
              child: SizedBox(
                width: size.width,
                height: size.height,
                child: Text(
                  '${(digit + 1) % 10}',
                  style: style,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Size _measure(String text, TextStyle style) {
    final painter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
    )..layout();
    return painter.size;
  }
}

/// A number that counts up from zero when it first appears — the entrance
/// treatment for stat chips and the Insights hero, where the reveal *is*
/// the moment rather than an update to something already on screen.
class GaugeCountUp extends StatefulWidget {
  const GaugeCountUp({
    super.key,
    required this.value,
    required this.style,
    this.duration = TideMotion.countUp,
    this.delay = Duration.zero,
    this.suffix,
    this.suffixStyle,
  });

  final int value;
  final TextStyle style;
  final Duration duration;
  final Duration delay;

  /// Rendered immediately after the digits — the % on Insights, the "min"
  /// on a duration habit.
  final String? suffix;
  final TextStyle? suffixStyle;

  @override
  State<GaugeCountUp> createState() => _GaugeCountUpState();
}

class _GaugeCountUpState extends State<GaugeCountUp>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: widget.duration,
  );

  @override
  void initState() {
    super.initState();
    Future<void>.delayed(widget.delay, () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void didUpdateWidget(GaugeCountUp old) {
    super.didUpdateWidget(old);
    // A changed target re-runs the roll from where it is, rather than
    // restarting the count from zero.
    if (old.value != widget.value && _controller.isCompleted) {
      _controller
        ..reset()
        ..forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final eased = Curves.easeOutCubic.transform(_controller.value);
        final current = widget.value * eased;
        return Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            _Odometer(
              value: current,
              target: widget.value,
              style: widget.style,
              minDigits: 1,
            ),
            if (widget.suffix != null)
              Text(
                widget.suffix!,
                style:
                    widget.suffixStyle ??
                    TideType.gauge(
                      (widget.style.fontSize ?? 16) * 0.45,
                      color: widget.style.color ?? TideType.body.color!,
                    ),
              ),
          ],
        );
      },
    );
  }
}
