import 'package:flutter/material.dart';

import '../../../theme/tide_colors.dart';
import '../../../theme/tide_typography.dart';

/// The key for the grid's fill levels.
///
/// Drawn from the same [TideColors.intensity] ramp the cells use, so the
/// legend cannot drift out of step with what it is explaining.
class IntensityLegend extends StatelessWidget {
  const IntensityLegend({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text('less', style: TideType.labelMuted.copyWith(fontSize: 11)),
        const SizedBox(width: 10),
        Expanded(
          child: Container(
            height: 3,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(3),
              gradient: LinearGradient(
                colors: [
                  TideColors.intensity(0.05),
                  TideColors.intensity(0.4),
                  TideColors.intensity(0.75),
                  TideColors.intensity(1),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Text('all logged', style: TideType.labelMuted.copyWith(fontSize: 11)),
      ],
    );
  }
}
