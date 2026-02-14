import 'package:cb_theme/src/colors.dart';
import 'package:cb_theme/src/layout.dart';
import 'package:flutter/material.dart';

/// Report card showing a list of events or results.
class CBReportCard extends StatelessWidget {
  final String title;
  final List<String> lines;
  final Color? color;

  const CBReportCard({
    super.key,
    required this.title,
    required this.lines,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accentColor = color ?? theme.colorScheme.primary;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(CBSpace.x4),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(CBRadius.md),
        border: Border.all(color: accentColor, width: 1),
        boxShadow: CBColors.boxGlow(accentColor, intensity: 0.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title.toUpperCase(),
            style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                  color: accentColor,
                  shadows: CBColors.textGlow(accentColor, intensity: 0.4),
                ),
          ),
          const SizedBox(height: CBSpace.x4),
          ...lines.map(
            (line) => Padding(
              padding: const EdgeInsets.only(bottom: CBSpace.x3),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '// ',
                    style: theme.textTheme.bodySmall!.copyWith(
                      color: accentColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Expanded(
                      child: Text(line, style: theme.textTheme.bodySmall!)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
