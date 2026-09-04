import 'package:flutter/material.dart';

import '../../../theme/tide_colors.dart';
import '../../../widgets/stat_card.dart';

/// Current streak, best streak and 30-day rate, side by side.
///
/// Each counts up from zero, staggered, so the row resolves left to right
/// rather than three numbers snapping in together.
class StreakStatRow extends StatelessWidget {
  const StreakStatRow({
    super.key,
    required this.currentStreak,
    required this.bestStreak,
    required this.rate,
  });

  final int currentStreak;
  final int bestStreak;
  final double rate;

  @override
  Widget build(BuildContext context) {
    // IntrinsicHeight so all three chips match the tallest, rather than
    // each sizing to its own caption. Stretch alone cannot do it inside a
    // ListView, where the available height is unbounded.
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: StatCard(
              value: currentStreak,
              caption: 'current streak',
              color: TideColors.tideBlue,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: StatCard(
              value: bestStreak,
              caption: 'best streak',
              color: TideColors.textPrimary,
              delay: const Duration(milliseconds: 90),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: StatCard(
              value: (rate * 100).round(),
              suffix: '%',
              caption: '30-day rate',
              color: TideColors.textPrimary,
              delay: const Duration(milliseconds: 180),
            ),
          ),
        ],
      ),
    );
  }
}
