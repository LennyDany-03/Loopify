import 'package:flutter/material.dart';

import '../theme/tide_colors.dart';
import '../theme/tide_elevation.dart';
import '../theme/tide_gradients.dart';
import '../theme/tide_motion.dart';
import '../theme/tide_typography.dart';
import 'press_scale.dart';
import 'tide_ring.dart';

enum TideButtonVariant {
  /// Tide blue fill — the one primary action on a screen.
  primary,

  /// Shallow surface — everything alongside a primary.
  secondary,

  /// Text only, for dismissals and low-stakes navigation.
  ghost,
}

/// The progress a button is reporting about its own action.
enum TideButtonPhase { idle, busy, done }

/// The app's button.
///
/// The [phase] states matter: a saving button collapses into a tide-ring
/// spinner and then a checkmark rather than freezing or showing a separate
/// dialog, which is what lets a save read as one continuous motion.
class TideButton extends StatelessWidget {
  const TideButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = TideButtonVariant.primary,
    this.phase = TideButtonPhase.idle,
    this.expand = true,
    this.icon,
    this.shadows,
    this.enabled = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final TideButtonVariant variant;
  final TideButtonPhase phase;
  final bool expand;
  final Widget? icon;

  /// The paywall CTA passes its glow here.
  final List<BoxShadow>? shadows;

  final bool enabled;

  bool get _interactive => enabled && phase == TideButtonPhase.idle;

  /// Only the primary button is lit; the other two are surfaces, and a
  /// surface that glows is a surface competing with the one action on the
  /// screen that matters.
  Gradient? get _gradient => switch (variant) {
    TideButtonVariant.primary => TideGradients.accent,
    TideButtonVariant.secondary => TideGradients.surface,
    TideButtonVariant.ghost => null,
  };

  Color get _foreground => switch (variant) {
    TideButtonVariant.primary => TideColors.deepWater,
    TideButtonVariant.secondary => TideColors.textPrimary,
    TideButtonVariant.ghost => TideColors.textMuted,
  };

  @override
  Widget build(BuildContext context) {
    final opacity = enabled ? 1.0 : 0.4;

    return PressScale(
      onTap: _interactive ? onPressed : null,
      enabled: _interactive && onPressed != null,
      child: Opacity(
        opacity: opacity,
        child: AnimatedContainer(
          duration: TideMotion.tabSwitch,
          curve: TideMotion.tabCurve,
          width: expand ? double.infinity : null,
          height: 52,
          decoration: BoxDecoration(
            gradient: _gradient,
            borderRadius: TideElevation.radius12,
            boxShadow:
                shadows ??
                (variant == TideButtonVariant.primary
                    ? [
                        ...TideElevation.resting,
                        BoxShadow(
                          color: TideColors.tideBlue.withValues(alpha: 0.28),
                          blurRadius: 22,
                          spreadRadius: -6,
                          offset: const Offset(0, 6),
                        ),
                      ]
                    : null),
            border: variant == TideButtonVariant.secondary
                ? Border.all(color: TideColors.divider)
                : null,
          ),
          alignment: Alignment.center,
          child: AnimatedSwitcher(
            duration: TideMotion.tabSwitch,
            child: switch (phase) {
              TideButtonPhase.busy => TideSpinner(
                key: const ValueKey('busy'),
                color: _foreground,
              ),
              TideButtonPhase.done => Icon(
                Icons.check_rounded,
                key: const ValueKey('done'),
                size: 24,
                color: _foreground,
              ),
              TideButtonPhase.idle => Row(
                key: const ValueKey('idle'),
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[icon!, const SizedBox(width: 8)],
                  Text(
                    label,
                    style: TideType.button.copyWith(color: _foreground),
                  ),
                ],
              ),
            },
          ),
        ),
      ),
    );
  }
}

/// The busy state spins, so the ring reads as working rather than stuck at
/// 28%. Kept separate from [TideButton] so a static button never pays for
/// an animation controller it does not use.
class TideSpinner extends StatefulWidget {
  const TideSpinner({
    super.key,
    this.size = 22,
    this.color,
    this.strokeWidth = 2.5,
  });

  final double size;
  final Color? color;
  final double strokeWidth;

  @override
  State<TideSpinner> createState() => _TideSpinnerState();
}

class _TideSpinnerState extends State<TideSpinner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: _controller,
      child: TideRing(
        progress: 0.28,
        size: widget.size,
        strokeWidth: widget.strokeWidth,
        animate: false,
        showTrack: false,
        color: widget.color ?? TideColors.deepWater,
      ),
    );
  }
}
