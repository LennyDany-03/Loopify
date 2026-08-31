import 'package:flutter/material.dart';

import '../theme/tide_gradients.dart';
import '../theme/tide_motion.dart';
import 'grain_overlay.dart';

/// The page ground for every screen.
///
/// Four layers, painted bottom up:
///
/// 1. the vertical page gradient,
/// 2. three edgeless blooms of light in the water,
/// 3. a top vignette that keeps the status bar legible over the crown,
/// 4. the grain wash.
///
/// The blooms are the reason this exists. The old background put a single
/// two-stop radial gradient over a flat fill, and a two-stop radial fades
/// linearly — which draws a findable circle exactly where the ramp hits
/// zero. That circle is what made the screen look printed rather than lit.
/// [TideGradients.bloom] front-loads the falloff so there is no rim left to
/// find, and three overlapping blooms at different sizes give the ground a
/// direction instead of a centre.
class TideBackdrop extends StatefulWidget {
  const TideBackdrop({super.key, this.drift = false, this.grain = true});

  /// Whether the blooms drift.
  ///
  /// Off almost everywhere: the app's rule is that motion has to be caused
  /// by something the user did. Onboarding is the exception — it has no
  /// history to show yet, so stillness there reads as an unloaded page.
  final bool drift;

  final bool grain;

  @override
  State<TideBackdrop> createState() => _TideBackdropState();
}

class _TideBackdropState extends State<TideBackdrop>
    with SingleTickerProviderStateMixin {
  AnimationController? _controller;

  @override
  void initState() {
    super.initState();
    if (widget.drift) _start();
  }

  @override
  void didUpdateWidget(TideBackdrop old) {
    super.didUpdateWidget(old);
    if (widget.drift == old.drift) return;
    if (widget.drift) {
      _start();
    } else {
      _controller?.dispose();
      _controller = null;
    }
  }

  void _start() {
    _controller = AnimationController(
      vsync: this,
      duration: TideMotion.ambientDrift,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;

    // A still backdrop paints once and is cached; only the drifting one
    // rebuilds per frame, and even then it is a handful of gradient rects.
    final ground = controller == null
        ? const _Ground(phase: 0.42)
        : AnimatedBuilder(
            animation: controller,
            builder: (context, _) => _Ground(phase: controller.value),
          );

    return IgnorePointer(
      child: RepaintBoundary(
        child: Stack(
          fit: StackFit.expand,
          children: [
            ground,
            if (widget.grain) const GrainOverlay(),
          ],
        ),
      ),
    );
  }
}

class _Ground extends StatelessWidget {
  const _Ground({required this.phase});

  final double phase;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _GroundPainter(phase), size: Size.infinite);
  }
}

class _GroundPainter extends CustomPainter {
  const _GroundPainter(this.phase);

  final double phase;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;
    final rect = Offset.zero & size;

    void wash(Gradient gradient) {
      canvas.drawRect(rect, Paint()..shader = gradient.createShader(rect));
    }

    wash(TideGradients.page);
    // The blooms are laid in the same rect rather than their own bounds, so
    // an alignment past ±1 genuinely parks the core off-screen.
    TideGradients.pageBlooms(phase).forEach(wash);
  }

  @override
  bool shouldRepaint(_GroundPainter old) => old.phase != phase;
}

/// The dissolve under the status bar.
///
/// Every screen in Tide is edge-to-edge and scrolls its own header, so
/// without this a title travels straight up into the system clock and the
/// two render on top of each other. The fix is not a solid bar — that would
/// cut the page in half and undo the ground — but a short fade in the page
/// ground's own top colour, so content thins out as it leaves rather than
/// colliding with the OS.
class TideTopScrim extends StatelessWidget {
  const TideTopScrim({super.key});

  @override
  Widget build(BuildContext context) {
    final inset = MediaQuery.viewPaddingOf(context).top;
    // Matches the first stop of the page gradient, which is what the top
    // few pixels of the backdrop actually are.
    final ground = TideGradients.page.colors.first;

    return IgnorePointer(
      child: SizedBox(
        height: inset + 14,
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [ground, ground, ground.withValues(alpha: 0)],
              // Solid across the inset itself, then a short tail — long
              // enough to read as a fade, short enough that it never eats
              // into a header sitting at its resting position.
              stops: const [0, 0.62, 1],
            ),
          ),
          child: const SizedBox.expand(),
        ),
      ),
    );
  }
}
