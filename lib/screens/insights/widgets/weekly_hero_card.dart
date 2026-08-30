import 'package:flutter/material.dart';

import '../../../theme/tide_colors.dart';
import '../../../theme/tide_typography.dart';
import '../../../widgets/gauge_number.dart';
import '../../../widgets/tide_surface.dart';

/// The recap headline: this week's completion, rolling up from zero.
///
/// This is the reveal the whole screen is built around, so it counts rather
/// than appearing — and the comparison line underneath waits for the count
/// to land before it says whether the week was up or down.
class WeeklyHeroCard extends StatelessWidget {
  const WeeklyHeroCard({
    super.key,
    required this.rate,
    required this.previousRate,
  });

  final double rate;
  final double previousRate;

  int get _percent => (rate * 100).round();
  int get _delta => ((rate - previousRate) * 100).round();

  String get _comparison {
    if (previousRate == 0) return 'completed this week';
    if (_delta == 0) return 'completed this week · level with last';
    final direction = _delta > 0 ? 'up' : 'down';
    return 'completed this week · $direction ${_delta.abs()} '
        'point${_delta.abs() == 1 ? '' : 's'} on last';
  }

  @override
  Widget build(BuildContext context) {
    return TideSurface(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GaugeCountUp(
            value: _percent,
            style: TideType.gaugeHero().copyWith(fontSize: 48),
            suffix: '%',
            suffixStyle: TideType.gauge(20, color: TideColors.textMuted),
          ),
          const SizedBox(height: 10),
          Text(_comparison, style: TideType.labelMuted),
        ],
      ),
    );
  }
}
