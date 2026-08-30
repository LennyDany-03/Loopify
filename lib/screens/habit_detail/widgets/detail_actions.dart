import 'package:flutter/material.dart';

import '../../../theme/tide_colors.dart';
import '../../../theme/tide_typography.dart';
import '../../../widgets/hold_to_fill.dart';
import '../../../widgets/tide_button.dart';

/// Edit, pause and delete.
///
/// Edit and pause are ordinary taps. Delete is the coral hold-to-fill —
/// identical to the one in the context menu and in Settings, so the weight
/// of the action is communicated by the gesture rather than by a
/// confirmation dialog.
class DetailActions extends StatelessWidget {
  const DetailActions({
    super.key,
    required this.paused,
    required this.onEdit,
    required this.onPause,
    required this.onDelete,
  });

  final bool paused;
  final VoidCallback onEdit;
  final VoidCallback onPause;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: TideButton(
                label: 'Edit',
                variant: TideButtonVariant.secondary,
                onPressed: onEdit,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TideButton(
                label: paused ? 'Resume' : 'Pause',
                variant: TideButtonVariant.secondary,
                onPressed: onPause,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        HoldToConfirmButton(
          label: 'Hold to delete',
          holdingLabel: 'Keep holding…',
          onConfirm: onDelete,
        ),
        const SizedBox(height: 10),
        Text(
          'Deleting removes every log for this habit.',
          style: TideType.labelMuted.copyWith(
            color: TideColors.textMuted,
            fontSize: 11.5,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
