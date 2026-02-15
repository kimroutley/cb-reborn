import 'package:cb_theme/src/layout.dart';
import 'package:cb_theme/src/typography.dart';
import 'package:flutter/material.dart';

/// Compact label chip (e.g., role badge, status tag).
class CBBadge extends StatelessWidget {
  final String text;
  final Color? color;

  const CBBadge({
    super.key,
    required this.text,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final badgeColor = color ?? theme.colorScheme.primary;
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: CBSpace.x3, vertical: CBSpace.x1),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(CBRadius.xs),
        border: Border.all(color: badgeColor.withValues(alpha: 0.5)),
      ),
      child: Text(
        text.toUpperCase(),
        style: CBTypography.micro.copyWith(color: badgeColor),
      ),
    );
  }
}
