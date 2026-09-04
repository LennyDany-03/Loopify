import 'dart:math' as math;
import 'dart:ui' show PointMode;

import 'package:flutter/material.dart';

/// A 1–2% noise wash over the page background.
///
/// Barely visible on its own, but it stops the large flat deep-water ground
/// from banding on OLED panels and gives the dark surfaces a slight
/// materiality. Painted once and never repainted.
class GrainOverlay extends StatelessWidget {
  const GrainOverlay({super.key, this.opacity = 0.018, this.density = 2600});

  final double opacity;
  final int density;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: CustomPaint(
        painter: _GrainPainter(opacity: opacity, density: density),
        size: Size.infinite,
      ),
    );
  }
}

class _GrainPainter extends CustomPainter {
  _GrainPainter({required this.opacity, required this.density});

  final double opacity;
  final int density;

  /// Fixed seed: the grain must be stable, not crawl between frames.
  static final math.Random _random = math.Random(1401);
  static List<Offset>? _points;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;

    // Generated once in a unit square and scaled, so resizing the window
    // does not reshuffle the grain.
    _points ??= List<Offset>.generate(
      density,
      (_) => Offset(_random.nextDouble(), _random.nextDouble()),
    );

    final paint = Paint()
      ..color = Colors.white.withValues(alpha: opacity)
      ..strokeWidth = 1
      ..strokeCap = StrokeCap.square;

    canvas.drawPoints(PointMode.points, [
      for (final point in _points!)
        Offset(point.dx * size.width, point.dy * size.height),
    ], paint);
  }

  @override
  bool shouldRepaint(_GrainPainter old) => old.opacity != opacity;
}
