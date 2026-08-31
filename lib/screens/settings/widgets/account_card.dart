import 'package:flutter/material.dart';

import '../../../config/app_constants.dart';
import '../../../theme/tide_colors.dart';
import '../../../theme/tide_elevation.dart';
import '../../../theme/tide_typography.dart';
import '../../../widgets/press_scale.dart';
import '../../../widgets/tide_surface.dart';

/// Who is signed in, which plan they are on, and the way to Pro.
class AccountCard extends StatelessWidget {
  const AccountCard({
    super.key,
    required this.name,
    required this.isPro,
    required this.habitCount,
    required this.onUpgrade,
  });

  final String name;
  final bool isPro;
  final int habitCount;
  final VoidCallback onUpgrade;

  String get _initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) return parts.first.characters.first.toUpperCase();
    return (parts.first.characters.first + parts.last.characters.first)
        .toUpperCase();
  }

  String get _plan => isPro
      ? 'Tide Pro · unlimited habits'
      : 'Free plan · $habitCount of ${AppConstants.freeHabitLimit} habits';

  @override
  Widget build(BuildContext context) {
    return TideSurface(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: TideColors.tideBlue.withValues(alpha: 0.18),
              borderRadius: TideElevation.radius12,
            ),
            child: Center(
              child: Text(
                _initials,
                style: TideType.gauge(15, color: TideColors.tideBlue),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  name,
                  style: TideType.heading,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(_plan, style: TideType.labelMuted),
              ],
            ),
          ),
          if (!isPro)
            PressScale(
              onTap: onUpgrade,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 9,
                ),
                decoration: BoxDecoration(
                  color: TideColors.foamCyan.withValues(alpha: 0.14),
                  borderRadius: TideElevation.radius8,
                ),
                child: Text(
                  'Go Pro',
                  style: TideType.label.copyWith(color: TideColors.foamCyan),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
