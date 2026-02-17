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
                    'SYNCING INTO THE CLUB... ',
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
                    'Final checks underway. Hold tight while your seat is prepared.',
                    textAlign: TextAlign.center,
                    style: textTheme.bodyMedium,
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
