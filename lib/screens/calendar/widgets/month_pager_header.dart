import 'package:flutter/material.dart';

import '../../../config/app_constants.dart';
import '../../../theme/tide_colors.dart';
import '../../../theme/tide_elevation.dart';
import '../../../theme/tide_motion.dart';
import '../../../theme/tide_typography.dart';
import '../../../widgets/press_scale.dart';

/// Month title with previous/next controls.
///
/// The title crossfades and slides in the direction of travel, the same
/// 200ms family as a tab switch — paging a month and switching a tab are
/// the same size of move, so they read the same.
class MonthPagerHeader extends StatelessWidget {
  const MonthPagerHeader({
    super.key,
    required this.month,
    required this.onPrevious,
    required this.onNext,
    required this.forward,
    this.canGoNext = true,
  });

  final DateTime month;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  /// Direction of the last change, so the title slides the right way.
  final bool forward;

  final bool canGoNext;

  @override
  Widget build(BuildContext context) {
    final label = '${AppConstants.monthNames[month.month - 1]} ${month.year}';

    return Row(
      children: [
        _Arrow(icon: Icons.chevron_left_rounded, onTap: onPrevious),
        Expanded(
          child: AnimatedSwitcher(
            duration: TideMotion.tabSwitch,
            switchInCurve: TideMotion.tabCurve,
            transitionBuilder: (child, animation) {
              return FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: Offset(forward ? 0.12 : -0.12, 0),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                ),
              );
            },
            child: Text(
              label,
              key: ValueKey(label),
              textAlign: TextAlign.center,
              style: TideType.heading,
            ),
          ),
        ),
        _Arrow(
          icon: Icons.chevron_right_rounded,
          onTap: onNext,
          enabled: canGoNext,
        ),
      ],
    );
  }
}

class _Arrow extends StatelessWidget {
  const _Arrow({required this.icon, required this.onTap, this.enabled = true});

  final IconData icon;
  final VoidCallback onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return PressScale(
      onTap: enabled ? onTap : null,
      enabled: enabled,
      child: Opacity(
        opacity: enabled ? 1 : 0.3,
        child: Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: TideColors.shallow,
            borderRadius: TideElevation.radius8,
          ),
          child: Icon(icon, size: 20, color: TideColors.textPrimary),
        ),
      ),
    );
  }
}
