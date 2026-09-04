import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/tide_colors.dart';
import '../theme/tide_elevation.dart';
import '../theme/tide_motion.dart';
import '../theme/tide_typography.dart';

/// The hold gesture, which carries two meanings in Tide and exactly one
/// piece of behaviour.
///
/// * **Logging** a quantity or duration habit — the fill rises in real time
///   the longer it is held, like the tide coming in, and releasing logs the
///   amount actually reached ([commitOnRelease] true).
/// * **Destroying** something — the same fill recoloured coral, where
///   releasing early cancels and only holding through commits
///   ([commitOnRelease] false).
///
/// Both are the same gesture with the same feedback, which is what makes
/// the destructive version feel safe rather than novel.
class HoldToFill extends StatefulWidget {
  const HoldToFill({
    super.key,
    required this.builder,
    this.onCommit,
    this.onCancel,
    this.onTap,
    this.commitOnRelease = false,
    this.sweep = TideMotion.holdToCommit,
    this.startProgress = 0,
    this.minCommit = 0.04,
    this.enabled = true,
  });

  /// Rebuilt as the hold progresses. [progress] is 0..1.
  final Widget Function(BuildContext context, double progress, bool holding)
  builder;

  /// Receives the fraction reached. For [commitOnRelease] false this is
  /// always 1.0.
  final ValueChanged<double>? onCommit;

  final VoidCallback? onCancel;

  /// A quick tap, distinct from a hold — used by cards where tapping opens
  /// detail but holding logs.
  final VoidCallback? onTap;

  /// True logs whatever was reached; false requires a full sweep.
  final bool commitOnRelease;

  final Duration sweep;

  /// Quantity habits resume from what is already logged today rather than
  /// starting the tide from zero every time.
  final double startProgress;

  /// Below this, a release counts as a tap rather than a tiny log.
  final double minCommit;

  final bool enabled;

  @override
  State<HoldToFill> createState() => _HoldToFillState();
}

class _HoldToFillState extends State<HoldToFill>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: widget.sweep,
    value: widget.startProgress,
  );

  bool _holding = false;
  bool _committed = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onTick);
  }

  @override
  void didUpdateWidget(HoldToFill old) {
    super.didUpdateWidget(old);
    if (!_holding && old.startProgress != widget.startProgress) {
      _controller.value = widget.startProgress;
    }
  }

  @override
  void dispose() {
    _controller
      ..removeListener(_onTick)
      ..dispose();
    super.dispose();
  }

  void _onTick() {
    setState(() {});
    // A destructive hold commits the instant the ring closes, so the user
    // is never left holding a full ring wondering whether it worked.
    if (!widget.commitOnRelease &&
        _holding &&
        !_committed &&
        _controller.value >= 1) {
      _committed = true;
      HapticFeedback.heavyImpact();
      widget.onCommit?.call(1);
    }
  }

  void _start() {
    if (!widget.enabled) return;
    _committed = false;
    setState(() => _holding = true);
    HapticFeedback.selectionClick();
    _controller.forward();
  }

  void _end() {
    if (!_holding) return;
    final reached = _controller.value;
    setState(() => _holding = false);
    _controller.stop();

    if (_committed) {
      _controller.value = widget.startProgress;
      return;
    }

    if (widget.commitOnRelease &&
        reached > widget.startProgress + widget.minCommit) {
      HapticFeedback.mediumImpact();
      widget.onCommit?.call(reached);
      return;
    }

    // Released early: drain back to where it started. Nothing logged.
    widget.onCancel?.call();
    _controller.animateTo(
      widget.startProgress,
      duration: TideMotion.swipeSettle,
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => _start(),
      onTapUp: (_) {
        final wasQuick =
            _controller.value <= widget.startProgress + widget.minCommit;
        _end();
        if (wasQuick) widget.onTap?.call();
      },
      onTapCancel: _end,
      child: widget.builder(context, _controller.value, _holding),
    );
  }
}

/// A destructive action behind a coral hold-to-fill ring.
///
/// Used identically by Habit detail's delete, the add/edit sheet's delete,
/// and "Delete all data" in Settings — so the gesture that destroys things
/// is learned once.
class HoldToConfirmButton extends StatelessWidget {
  const HoldToConfirmButton({
    super.key,
    required this.label,
    required this.onConfirm,
    this.holdingLabel,
    this.color = TideColors.coral,
    this.expand = true,
  });

  final String label;

  /// Shown while the ring is filling — "Keep holding".
  final String? holdingLabel;

  final VoidCallback onConfirm;
  final Color color;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    return HoldToFill(
      onCommit: (_) => onConfirm(),
      builder: (context, progress, holding) {
        return Stack(
          children: [
            Container(
              width: expand ? double.infinity : null,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12 + 0.18 * progress),
                borderRadius: TideElevation.radius12,
                border: Border.all(
                  color: color.withValues(alpha: 0.3 + 0.5 * progress),
                ),
              ),
              child: Center(
                child: Text(
                  holding && holdingLabel != null ? holdingLabel! : label,
                  style: TideType.button.copyWith(color: color),
                ),
              ),
            ),
            // The fill itself, clipped to the button's own shape.
            Positioned.fill(
              child: IgnorePointer(
                child: ClipRRect(
                  borderRadius: TideElevation.radius12,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: FractionallySizedBox(
                      widthFactor: progress,
                      child: ColoredBox(
                        color: color.withValues(alpha: 0.22),
                        child: const SizedBox.expand(),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
