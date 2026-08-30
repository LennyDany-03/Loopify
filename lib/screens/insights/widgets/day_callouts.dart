import 'package:flutter/material.dart';

import '../../../config/app_constants.dart';
import '../../../theme/tide_colors.dart';
import '../../../theme/tide_typography.dart';
import '../../../widgets/tide_surface.dart';

/// Best and worst weekday, side by side.
///
/// Worst day is coral but the copy is neutral — this is a pattern worth
/// noticing, not a telling-off, and the colour is doing enough already.
class DayCallouts extends StatelessWidget {
  const DayCallouts({super.key, required this.weekdayRates});

  /// Seven rates, Monday first.
  final List<double> weekdayRates;

  int get _best {
    var index = 0;
    for (var i = 1; i < weekdayRates.length; i++) {
      if (weekdayRates[i] > weekdayRates[index]) index = i;
    }
    return index;
  }

  int get _worst {
    var index = 0;
    for (var i = 1; i < weekdayRates.length; i++) {
      if (weekdayRates[i] < weekdayRates[index]) index = i;
    }
    return index;
  }

  @override
  Widget build(BuildContext context) {
    // Both callouts match heights even when one weekday name wraps.
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: _Callout(
              caption: 'strongest day',
              day: AppConstants.weekdayNames[_best],
              rate: weekdayRates[_best],
              color: TideColors.kelpGreen,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _Callout(
              caption: 'weakest day',
              day: AppConstants.weekdayNames[_worst],
              rate: weekdayRates[_worst],
              color: TideColors.coral,
            ),
          ),
        ],
      ),
    );
  }
}

class _Callout extends StatelessWidget {
  const _Callout({
    required this.caption,
    required this.day,
    required this.rate,
    required this.color,
  });

  final String caption;
  final String day;
  final double rate;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return TideSurface(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(caption, style: TideType.labelMuted),
          const SizedBox(height: 10),
          Text(
            day,
            style: TideType.heading.copyWith(color: color),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 6),
          // Only the number is a gauge readout; the word beside it is UI
          // text. Setting the whole string in mono makes the label look
          // like data.
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '${(rate * 100).round()}%',
                style: TideType.gauge(12.5, color: TideColors.textMuted),
              ),
              Text(
                ' logged',
                style: TideType.labelMuted.copyWith(fontSize: 11.5),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
