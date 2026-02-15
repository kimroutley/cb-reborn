import 'package:flutter/material.dart';

/// High-density technical status rail.
class CBStatusRail extends StatelessWidget {
  final List<({String label, String value, Color color})> stats;

  const CBStatusRail({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: 24,
      width: double.infinity,
      color: theme.scaffoldBackgroundColor,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: stats.length,
        separatorBuilder: (_, __) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            '|',
            style: theme.textTheme.bodySmall!.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
            ),
          ),
        ),
        itemBuilder: (context, index) {
          final s = stats[index];
          return Row(
            children: [
              Text(
                '${s.label}: ',
                style: theme.textTheme.bodySmall!.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
                ),
              ),
              Text(
                s.value.toUpperCase(),
                style: theme.textTheme.bodySmall!.copyWith(
                  color: s.color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
