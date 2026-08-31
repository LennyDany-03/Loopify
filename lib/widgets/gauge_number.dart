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
          _DigitWheel(
            value: magnitudeValue,
            place: place,
            style: style,
            // The slot count comes from the target so the readout never
            // changes width mid-count, but a place the value has not
            // reached yet holds an empty column rather than a zero —
            // otherwise a rate counting up to 100% reads "084%" the whole
            // way there. [minDigits] is the opt-out, for 08:00.
            blank:
                place + 1 > minDigits &&
                place > 0 &&
                magnitudeValue < math.pow(10, place),
          ),
      ],
    );
  }
}

/// One digit column.
///
/// The change from one digit to the next is a short rise plus a crossfade,
/// not a full-height wheel. A full-height wheel is the honest mechanical
/// model, but it puts the bottom half of the outgoing digit and the top
/// half of the incoming one in the window at the same time, for the whole
/// length of the roll — and two half-glyphs stacked do not read as a number
/// turning over, they read as a rendering fault sitting in the middle of
/// the card. Moving a third of the height and letting opacity carry the
/// rest keeps the motion without ever showing a shape that is not a digit.
///
/// The column is a fixed box that never changes size, so nothing around it
/// — the caption under it, the suffix beside it, the card behind it —
/// moves while a number is animating.
class _DigitWheel extends StatelessWidget {
  const _DigitWheel({
    required this.value,
    required this.place,
    required this.style,
    this.blank = false,
  });

  final double value;
  final int place;
  final TextStyle style;

  /// Holds the column's width without drawing anything in it.
  final bool blank;

  /// Fraction of the box a digit travels as it hands over.
  static const double _travel = 0.34;

  @override
  Widget build(BuildContext context) {
    final size = _measureDigit(style, MediaQuery.textScalerOf(context));
    if (blank) return SizedBox(width: size.width, height: size.height);

    final divisor = math.pow(10, place).toDouble();
    final scaled = value / divisor;
    final digit = scaled.floor() % 10;
    final fraction = scaled - scaled.floorToDouble();

    // Only the last tenth of a place's travel actually turns the wheel;
    // below that the digit sits still while the wheels beneath it spin.
    final roll = ((fraction * 10) - 9).clamp(0.0, 1.0);

    Widget face(int shown, double offset, double opacity) {
      if (opacity <= 0.01) return const SizedBox.shrink();
      return Positioned(
        left: 0,
        right: 0,
        top: offset,
        height: size.height,
        child: Opacity(
          opacity: opacity.clamp(0.0, 1.0),
          child: Text('$shown', style: style, textAlign: TextAlign.center),
        ),
      );
    }

    return SizedBox(
      width: size.width,
      height: size.height,
      child: ClipRect(
        child: Stack(
          children: [
            face(digit, -roll * size.height * _travel, 1 - roll),
            face((digit + 1) % 10, (1 - roll) * size.height * _travel, roll),
          ],
        ),
      ),
    );
  }
}

/// Cache of the box one digit occupies, keyed by the style and the ambient
/// text scale.
///
/// Measuring is a full `TextPainter` layout, and it used to run once per
/// digit per frame — four gauges animating at once meant dozens of layouts
/// a frame, which is enough dropped frames to make the card they sit in
/// stutter. The metrics only depend on the style and the scale, so they are
/// measured once.
final Map<String, Size> _digitSizes = {};

Size _measureDigit(TextStyle style, TextScaler scaler) {
  final key =
      '${style.fontFamily}|${style.fontSize}|${style.fontWeight}'
      '|${style.height}|${style.letterSpacing}|${scaler.scale(1000)}';

  return _digitSizes.putIfAbsent(key, () {
    final painter = TextPainter(
      text: TextSpan(text: '0', style: style),
      textDirection: TextDirection.ltr,
      // Honouring the ambient scale matters: without it the box is measured
      // at 1.0 while the glyph renders larger, and the clip crops the digit.
      textScaler: scaler,
    )..layout();
    final size = painter.size;
    painter.dispose();
    return size;
  });
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
