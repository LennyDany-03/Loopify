import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../services/models/habit.dart';
import '../../../theme/tide_colors.dart';
import '../../../theme/tide_elevation.dart';
import '../../../theme/tide_motion.dart';
import '../../../theme/tide_typography.dart';
import '../../../widgets/habit_glyph.dart';
import '../../../widgets/hold_to_fill.dart';
import '../../../widgets/press_scale.dart';
import '../../../widgets/ripple_burst.dart';
import '../../../widgets/ripple_strip.dart';
import '../../../widgets/tide_ring.dart';
import '../../../widgets/tide_surface.dart';
import 'swipe_log_background.dart';

/// One habit on Home, and the gesture surface for logging it.
///
/// The card divides into two handles, and the division is the same on every
/// card in the app:
///
/// * **The glyph** manages the habit — tap opens detail, long-press raises
///   the context menu.
/// * **The body** logs it — binary habits are swiped, quantity and duration
///   habits are held.
///
/// That split is what lets held habits keep a long-press menu without the
/// two gestures fighting each other for the same pixels.
class HabitCard extends StatefulWidget {
  const HabitCard({
    super.key,
    required this.habit,
    required this.streak,
    required this.weekLevels,
    required this.onOpen,
    required this.onMenu,
    required this.onLog,
    required this.onFreeze,
  });

  final Habit habit;
  final int streak;

  /// Seven completion levels, oldest first.
  final List<double> weekLevels;

  final VoidCallback onOpen;
  final VoidCallback onMenu;

  /// Called with the amount to log — the full target for a swipe, the held
  /// fraction of it for a hold.
  final ValueChanged<num> onLog;

  final VoidCallback onFreeze;

  static const double height = 78;

  @override
  State<HabitCard> createState() => _HabitCardState();
}

class _HabitCardState extends State<HabitCard>
    with SingleTickerProviderStateMixin {
  // Built eagerly in initState rather than lazily: a card that is disposed
  // without ever being dragged would otherwise construct its controller
  // inside dispose(), which is too late to look up a TickerMode.
  late final AnimationController _settle;

  double _drag = 0;
  double _phase = 0;
  double _cardWidth = 0;
  int _rippleTick = 0;

  bool get _done =>
      widget.habit.isCompleteOn(DateTime.now()) ||
      widget.habit.isFrozenOn(DateTime.now());

  bool get _frozen => widget.habit.isFrozenOn(DateTime.now());

  double get _progress => widget.habit.progressOn(DateTime.now());

  @override
  void initState() {
    super.initState();
    _settle = AnimationController(
      vsync: this,
      duration: TideMotion.swipeCancel,
    );
  }

  @override
  void dispose() {
    _settle.dispose();
    super.dispose();
  }

  // --- Swipe (binary habits) -------------------------------------------

  void _onDragUpdate(DragUpdateDetails details) {
    setState(() {
      _drag += details.delta.dx;
      // Resistance past the commit point, so the card never slides right
      // off the screen and the threshold stays findable by feel.
      final limit = _cardWidth * 0.62;
      _drag = _drag.clamp(-limit, limit);
      _phase += details.delta.dx * 0.03;
    });
  }

  void _onDragEnd(DragEndDetails details) {
    final fraction = _cardWidth == 0 ? 0.0 : _drag.abs() / _cardWidth;

    if (fraction >= TideMotion.swipeThreshold) {
      if (_drag > 0) {
        _commitLog();
      } else {
        _commitFreeze();
      }
      return;
    }
    _springBack();
  }

  void _springBack() {
    final from = _drag;
    _settle
      ..reset()
      ..duration = TideMotion.swipeCancel;

    final animation = _settle.drive(
      Tween<double>(
        begin: from,
        end: 0,
      ).chain(CurveTween(curve: TideMotion.swipeCancelCurve)),
    );

    void tick() => setState(() => _drag = animation.value);
    animation.addListener(tick);
    _settle.forward().whenComplete(() {
      animation.removeListener(tick);
      if (mounted) setState(() => _drag = 0);
    });
  }

  /// Snap into place, then hand off to the store. The ripple fires here so
  /// the reward starts before the list has finished reordering.
  void _commitLog() {
    HapticFeedback.mediumImpact();
    setState(() => _rippleTick++);
    _snapHome();
    widget.onLog(widget.habit.target);
  }

  void _commitFreeze() {
    HapticFeedback.mediumImpact();
    _snapHome();
    widget.onFreeze();
  }

  void _snapHome() {
    final from = _drag;
    _settle
      ..reset()
      ..duration = TideMotion.swipeSettle;

    final animation = _settle.drive(
      Tween<double>(
        begin: from,
        end: 0,
      ).chain(CurveTween(curve: Curves.easeOutCubic)),
    );

    void tick() => setState(() => _drag = animation.value);
    animation.addListener(tick);
    _settle.forward().whenComplete(() {
      animation.removeListener(tick);
      if (mounted) setState(() => _drag = 0);
    });
  }

  // --- Hold (quantity / duration habits) --------------------------------

  void _commitHold(double fraction) {
    final amount = (widget.habit.target * fraction).ceil();
    setState(() => _rippleTick++);
    widget.onLog(amount.clamp(0, widget.habit.target));
  }

  // --- Copy -------------------------------------------------------------

  String get _hint {
    if (_frozen) return 'frozen · streak held';
    if (_done) return 'logged';

    return switch (widget.habit.type) {
      HabitType.binary => 'swipe right to log',
      HabitType.quantity ||
      HabitType.duration => 'hold to log · ${_amountLabel()}',
    };
  }

  String _amountLabel() {
    final amount = widget.habit.amountOn(DateTime.now());
    final shown = amount == amount.roundToDouble() ? amount.round() : amount;
    return '$shown/${widget.habit.target}';
  }

  /// The trailing pill: the streak, unless a quantity habit is part-way
  /// through today, in which case the amount is the more useful number.
  String get _pillLabel {
    final partial = widget.habit.type != HabitType.binary && !_done;
    return partial ? _amountLabel() : '${widget.streak}';
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        _cardWidth = constraints.maxWidth;

        return SizedBox(
          height: HabitCard.height,
          child: Stack(
            children: [
              Positioned.fill(
                child: SwipeLogBackground(
                  offset: _drag,
                  width: _cardWidth,
                  phase: _phase,
                  freezeAvailable: widget.habit.freezesRemaining > 0,
                ),
              ),
              Transform.translate(
                offset: Offset(_drag, 0),
                child: RippleBurst(
                  trigger: _rippleTick,
                  color: TideColors.kelpGreen,
                  child: _body(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _body() {
    final surface = TideSurface(
      radius: TideElevation.radius12,
      height: HabitCard.height,
      // Completed cards wash kelp green — the state is carried by the
      // surface itself, not by a badge bolted onto it.
      color: _done
          ? Color.lerp(TideColors.shallow, TideColors.kelpGreen, 0.10)
          : TideColors.shallow,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Row(
        children: [
          _glyphHandle(),
          const SizedBox(width: 14),
          Expanded(child: _details()),
          const SizedBox(width: 12),
          _streakPill(),
        ],
      ),
    );

    // Binary habits swipe; held habits hold. One gesture per card body.
    if (widget.habit.type == HabitType.binary) {
      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onHorizontalDragUpdate: _onDragUpdate,
        onHorizontalDragEnd: _onDragEnd,
        onTap: widget.onOpen,
        child: surface,
      );
    }

    return HoldToFill(
      commitOnRelease: true,
      sweep: TideMotion.holdToLogSweep,
      startProgress: _progress,
      onCommit: _commitHold,
      onTap: widget.onOpen,
      builder: (context, progress, holding) {
        return Stack(
          children: [
            surface,
            if (holding)
              Positioned.fill(
                child: IgnorePointer(
                  child: ClipRRect(
                    borderRadius: TideElevation.radius12,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: FractionallySizedBox(
                        widthFactor: progress,
                        child: ColoredBox(
                          color: TideColors.tideBlue.withValues(alpha: 0.12),
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

  /// The management handle. Deliberately its own hit target so a long-press
  /// here never competes with the hold-to-log gesture on the body.
  Widget _glyphHandle() {
    final ringColor = _frozen
        ? TideColors.foamCyan
        : _done
        ? TideColors.kelpGreen
        : TideColors.tideBlue;

    return PressScale(
      onTap: widget.onOpen,
      onLongPress: widget.onMenu,
      child: TideRing(
        progress: _done ? 1 : _progress,
        size: 34,
        strokeWidth: 2.5,
        color: ringColor,
        child: HabitGlyph(
          glyph: widget.habit.glyph,
          size: 14,
          color: ringColor,
        ),
      ),
    );
  }

  Widget _details() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          widget.habit.name,
          style: TideType.heading,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 9),
        Row(
          children: [
            SizedBox(
              width: 66,
              child: RippleStrip(
                levels: widget.weekLevels,
                color: _done ? TideColors.kelpGreen : null,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                _hint,
                style: TideType.labelMuted.copyWith(
                  color: _done ? TideColors.kelpGreen : TideColors.textMuted,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _streakPill() {
    final color = _done ? TideColors.kelpGreen : TideColors.tideBlue;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: TideElevation.radius8,
      ),
      child: Text(_pillLabel, style: TideType.gaugeSmall(color: color)),
    );
  }
}
