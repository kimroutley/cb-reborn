import 'package:cb_theme/src/colors.dart';
import 'package:cb_theme/src/layout.dart';
import 'package:flutter/material.dart';

/// Status overlay card (ELIMINATED, SILENCED, etc.).
class CBStatusOverlay extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;
  final String detail;

  const CBStatusOverlay({
    super.key,
    required this.icon,
    required this.label,
    this.color,
    required this.detail,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accentColor = color ?? theme.colorScheme.error;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(CBSpace.x8),
      margin: const EdgeInsets.symmetric(vertical: CBSpace.x4),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(CBRadius.md),
        border: Border.all(color: accentColor, width: 2),
        boxShadow: CBColors.boxGlow(accentColor, intensity: 0.3),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 64, color: accentColor),
          const SizedBox(height: CBSpace.x4),
          Text(
            label.toUpperCase(),
            style: theme.textTheme.displaySmall!.copyWith(color: accentColor),
          ),
          const SizedBox(height: CBSpace.x3),
          Text(
            detail,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium!,
          ),
        ],
      ),
    );
  }
}
