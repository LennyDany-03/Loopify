import 'package:flutter/material.dart';

import '../../../config/app_constants.dart';
import '../../../services/models/tide_glyph.dart';
import '../../../theme/tide_colors.dart';
import '../../../theme/tide_elevation.dart';
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
              Text(_dateLine, style: TideType.sectionHeader),
              const SizedBox(height: 6),
              const Text('Today', style: TideType.screenTitle),
            ],
          ),
        ),
        PressScale(
          onTap: onMilestones,
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: TideColors.shallow,
              borderRadius: TideElevation.radius12,
              boxShadow: TideElevation.resting,
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
      ],
    );
  }
}
