import 'package:flutter/material.dart';

import '../../../theme/tide_colors.dart';
import '../../../theme/tide_typography.dart';
import '../../../widgets/gauge_number.dart';
import '../../../widgets/tide_surface.dart';

/// How the freeze allowance is being used.
///
/// Freezes are the app's forgiveness mechanic, so this reports them plainly
/// rather than framing spent ones as failures — a used freeze did its job.
class FreezeUsageCard extends StatelessWidget {
  const FreezeUsageCard({
    super.key,
    required this.spent,
    required this.remaining,
  });

  final int spent;
  final int remaining;

  @override
  Widget build(BuildContext context) {
    return TideSurface(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Streak freezes', style: TideType.heading),
                const SizedBox(height: 6),
                Text(
                  spent == 0
                      ? 'None spent in the last 30 days.'
                      : '$spent spent in the last 30 days.',
                  style: TideType.labelMuted,
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              GaugeNumber(
                value: remaining,
                style: TideType.gauge(22, color: TideColors.foamCyan),
              ),
              const SizedBox(height: 5),
              Text('left', style: TideType.labelMuted),
            ],
          ),
        ],
      ),
    );
  }
}
