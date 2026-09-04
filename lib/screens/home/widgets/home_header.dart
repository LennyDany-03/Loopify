import 'package:flutter/material.dart';

import '../../../config/app_constants.dart';
import '../../../services/models/tide_glyph.dart';
import '../../../theme/tide_colors.dart';
import '../../../theme/tide_elevation.dart';
import '../../../theme/tide_gradients.dart';
import '../../../theme/tide_typography.dart';
import '../../../widgets/habit_glyph.dart';
import '../../../widgets/press_scale.dart';

/// Date line, screen title, and the way through to milestones.
class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key, required this.date, required this.onMilestones});

  final DateTime date;
  final VoidCallback onMilestones;

  String get _dateLine {
    final weekday = AppConstants.weekdayNames[date.weekday - 1]
        .substring(0, 3)
        .toUpperCase();
    final month = AppConstants.monthNames[date.month - 1]
        .substring(0, 3)
        .toUpperCase();
    return '$weekday · ${date.day} $month';
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // A lit tick in front of the date, so the eye finds the
                  // top-left of the screen before anything else on it.
                  Container(
                    width: 4,
                    height: 4,
                    margin: const EdgeInsets.only(right: 8, bottom: 1),
                    decoration: const BoxDecoration(
                      gradient: TideGradients.accent,
                      shape: BoxShape.circle,
                    ),
                  ),
                  Text(_dateLine, style: TideType.sectionHeader),
                ],
              ),
              const SizedBox(height: 6),
              // The screen title carries the accent ramp rather than flat
              // text: it and the hero figure below it are the two things on
              // Home lit from the same source as the background crown.
              ShaderMask(
                blendMode: BlendMode.srcIn,
                shaderCallback: (bounds) => const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    TideColors.textPrimary,
                    TideColors.textPrimary,
                    TideColors.foamCyan,
                  ],
                  stops: [0, 0.45, 1],
                ).createShader(bounds),
                child: const Text('Today', style: TideType.screenTitle),
              ),
            ],
          ),
        ),
        _MilestoneButton(onTap: onMilestones),
      ],
    );
  }
}

/// The way through to milestones: a small pane of the same glass the tab
/// bar is made of, so the two floating controls on Home are the same
/// material.
class _MilestoneButton extends StatelessWidget {
  const _MilestoneButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return PressScale(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          gradient: TideGradients.glassStroke,
          borderRadius: TideElevation.radius12,
          boxShadow: [
            ...TideElevation.resting,
            BoxShadow(
              color: TideColors.foamCyan.withValues(alpha: 0.14),
              blurRadius: 16,
              spreadRadius: -6,
            ),
          ],
        ),
        padding: const EdgeInsets.all(1),
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: TideGradients.surface,
            borderRadius: BorderRadius.circular(TideElevation.r12 - 1),
          ),
          child: const Center(
            child: HabitGlyph(
              glyph: TideGlyph.sparkle,
              size: 15,
              color: TideColors.foamCyan,
            ),
          ),
        ),
      ),
    );
  }
}
