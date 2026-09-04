import 'package:flutter/material.dart';

import '../../../theme/tide_elevation.dart';
import '../../../theme/tide_motion.dart';
import '../../../widgets/tide_button.dart';

/// The paywall's call to action.
///
/// The glow is very slow and very low-key on purpose: it should draw the
/// eye without applying pressure. A fast pulse would read as a countdown,
/// which is not the relationship this screen is trying to have.
class GlowCta extends StatefulWidget {
  const GlowCta({
    super.key,
    required this.label,
    required this.onPressed,
    this.phase = TideButtonPhase.idle,
  });

  final String label;
  final VoidCallback onPressed;
  final TideButtonPhase phase;

  @override
  State<GlowCta> createState() => _GlowCtaState();
}

class _GlowCtaState extends State<GlowCta> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: TideMotion.ctaGlow,
  )..repeat(reverse: true);

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
        final pulse = Curves.easeInOut.transform(_controller.value);
        return TideButton(
          label: widget.label,
          onPressed: widget.onPressed,
          phase: widget.phase,
          shadows: TideElevation.ctaGlow(pulse),
        );
      },
    );
  }
}
