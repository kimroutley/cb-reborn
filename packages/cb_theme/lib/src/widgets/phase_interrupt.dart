import 'package:flutter/material.dart';

import 'package:cb_theme/src/widgets/cb_fade_slide.dart';

/// A full-screen overlay to announce a new game phase.
class CBPhaseInterrupt extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Color? color;
  final IconData? icon;

  const CBPhaseInterrupt({
    super.key,
    required this.title,
    this.subtitle,
    this.color,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final accentColor = color ?? scheme.primary;

    return Container(
      color: scheme.surface.withValues(alpha: 0.8),
      child: Center(
        child: CBFadeSlide(
          duration: const Duration(milliseconds: 800),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  size: 80,
                  color: accentColor,
                  shadows: [
                    BoxShadow(
                      color: accentColor.withValues(alpha: 0.5),
                      blurRadius: 24,
                      spreadRadius: 12,
                    ),
                  ],
                ),
                const SizedBox(height: 24),
              ],
              Text(
                title.toUpperCase(),
                style: theme.textTheme.displayMedium?.copyWith(
                  color: accentColor,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 4,
                  shadows: [
                    BoxShadow(
                      color: accentColor.withValues(alpha: 0.7),
                      blurRadius: 32,
                      spreadRadius: 16,
                    ),
                  ],
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 12),
                Text(
                  subtitle!,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: scheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
