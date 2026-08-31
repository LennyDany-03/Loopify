import 'package:flutter/material.dart';

import '../../../theme/tide_colors.dart';
import '../../../theme/tide_elevation.dart';
import '../../../theme/tide_motion.dart';
import '../../../theme/tide_typography.dart';
import '../../../widgets/press_scale.dart';

/// A pricing option.
class PricingTierCard extends StatelessWidget {
  const PricingTierCard({
    super.key,
    required this.title,
    required this.price,
    required this.note,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final String price;
  final String note;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return PressScale(
      onTap: onTap,
      child: AnimatedContainer(
        duration: TideMotion.tabSwitch,
        curve: TideMotion.tabCurve,
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
        decoration: BoxDecoration(
          color: selected
              ? TideColors.tideBlue.withValues(alpha: 0.10)
              : TideColors.well,
          borderRadius: TideElevation.radius12,
          border: Border.all(
            color: selected
                ? TideColors.tideBlue.withValues(alpha: 0.6)
                : Colors.transparent,
            width: 1.4,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(title, style: TideType.labelMuted),
            const SizedBox(height: 8),
            Text(
              price,
              style: TideType.gauge(
                24,
                color: selected ? TideColors.textPrimary : TideColors.textMuted,
              ),
            ),
            const SizedBox(height: 6),
            Text(note, style: TideType.labelMuted.copyWith(fontSize: 11.5)),
          ],
        ),
      ),
    );
  }
}
