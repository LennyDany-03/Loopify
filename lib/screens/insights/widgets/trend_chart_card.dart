import 'package:flutter/material.dart';

import '../../../theme/tide_typography.dart';
import '../../../widgets/tide_surface.dart';
import '../../../widgets/trend_chart.dart';

/// Eight weeks of completion.
///
/// [onFinished] is the sequencing hook for the screen: the callouts below
/// stay hidden until this line has finished drawing, so the recap resolves
/// in order instead of arriving all at once.
class TrendChartCard extends StatelessWidget {
  const TrendChartCard({
    super.key,
    required this.values,
    required this.onFinished,
  });

  final List<double> values;
  final VoidCallback onFinished;

  @override
  Widget build(BuildContext context) {
    return TideSurface(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Eight weeks', style: TideType.heading),
          const SizedBox(height: 22),
          TrendChart(
            values: values,
            height: 92,
            showPoints: true,
            delay: const Duration(milliseconds: 340),
            onFinished: onFinished,
          ),
        ],
      ),
    );
  }
}
