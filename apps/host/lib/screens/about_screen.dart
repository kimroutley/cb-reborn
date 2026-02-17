import 'package:cb_theme/cb_theme.dart';
import 'package:flutter/material.dart';

import '../host_destinations.dart';
import '../widgets/custom_drawer.dart';
import '../widgets/simulation_mode_badge_action.dart';
import 'privacy_policy_screen.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('ABOUT'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: const [SimulationModeBadgeAction()],
      ),
      drawer: const CustomDrawer(currentDestination: HostDestination.about),
      body: CBNeonBackground(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
          children: [
            CBSectionHeader(
              title: 'CLUB BLACKOUT: REBORN',
              icon: Icons.info_outline,
              color: scheme.primary,
            ),
            const SizedBox(height: 12),
            CBPanel(
              borderColor: scheme.primary.withValues(alpha: 0.35),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'HOST CONTROL APP',
                    style: textTheme.headlineSmall?.copyWith(
                      letterSpacing: 2.0,
                      color: scheme.secondary,
                      shadows:
                          CBColors.textGlow(scheme.secondary, intensity: 0.6),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Version 1.0.0+1',
                    style: textTheme.bodyMedium?.copyWith(
                      color: CBColors.textDim,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Runs the lobby, scripting engine, tactical dashboard, and session recaps.',
                    style: textTheme.bodyMedium?.copyWith(height: 1.4),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            CBSectionHeader(
              title: 'PRIVACY',
              icon: Icons.privacy_tip_outlined,
              color: scheme.tertiary,
            ),
            const SizedBox(height: 12),
            CBPanel(
              borderColor: scheme.tertiary.withValues(alpha: 0.35),
              child: InkWell(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (_) => const PrivacyPolicyScreen()),
                  );
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'PRIVACY POLICY',
                                style: textTheme.headlineSmall?.copyWith(
                                  letterSpacing: 2.0,
                                  color: scheme.tertiary,
                                  shadows: CBColors.textGlow(scheme.tertiary,
                                      intensity: 0.6),
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                'DATA COLLECTION + CLOUD SYNC DETAILS',
                                style: textTheme.bodyMedium?.copyWith(
                                  color: CBColors.textDim,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.chevron_right, size: 28),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'Club Blackout is an in-person social deduction game. All data is handled as per the privacy policy.',
              textAlign: TextAlign.center,
              style: textTheme.bodySmall
                  ?.copyWith(color: scheme.onSurface.withValues(alpha: 0.5)),
            )
          ],
        ),
      ),
    );
  }
}
