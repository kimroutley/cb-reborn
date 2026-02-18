import 'package:cb_theme/cb_theme.dart';
import 'package:flutter/material.dart';

class StartTransitionScreen extends StatelessWidget {
  const StartTransitionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return CBNeonBackground(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: CBPanel(
              borderColor: scheme.primary.withValues(alpha: 0.55),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CBBreathingLoader(size: 62),
                  const SizedBox(height: 20),
                  Text(
                    'SYNCING INTO THE CLUB...',
                    textAlign: TextAlign.center,
                    style: textTheme.titleLarge?.copyWith(
                      color: scheme.primary,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.4,
                      shadows: CBColors.textGlow(scheme.primary),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Final checks underway. Lights up, sound check, then you are in.',
                    textAlign: TextAlign.center,
                    style: textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 18),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: LinearProgressIndicator(
                      minHeight: 6,
                      backgroundColor: scheme.surfaceContainerHighest
                          .withValues(alpha: 0.45),
                      valueColor: AlwaysStoppedAnimation<Color>(scheme.primary),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Club vibes loading...',
                    textAlign: TextAlign.center,
                    style: textTheme.labelSmall?.copyWith(
                      color: scheme.onSurface.withValues(alpha: 0.65),
                      letterSpacing: 1.1,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
