import 'package:cb_theme/cb_theme.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../auth/player_auth_screen.dart';
import '../bootstrap/player_bootstrap_gate.dart';
import 'player_home_shell.dart';
import '../widgets/effects_overlay.dart';

class PlayerIntroScreen extends StatefulWidget {
  const PlayerIntroScreen({super.key});

  @override
  State<PlayerIntroScreen> createState() => _PlayerIntroScreenState();
}

class _PlayerIntroScreenState extends State<PlayerIntroScreen> {
  bool _loading = true;
  bool _seen = false;

  @override
  void initState() {
    super.initState();
    _checkIntro();
  }

  Future<void> _checkIntro() async {
    final prefs = await SharedPreferences.getInstance();
    final seen = prefs.getBool('player_intro_seen') ?? false;
    if (mounted) {
      setState(() {
        _seen = seen;
        _loading = false;
      });
    }
  }

  Future<void> _enterClub() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('player_intro_seen', true);
    if (mounted) {
      setState(() {
        _seen = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const CBPrismScaffold(
        title: '',
        showAppBar: false,
        body: Center(child: CBBreathingLoader()),
      );
    }

    if (_seen) {
      // Return the standard bootstrap flow if seen
      return PlayerBootstrapGate(
        child: PlayerAuthScreen(
          child: const EffectsOverlay(child: PlayerHomeShell()),
        ),
      );
    }

    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return CBPrismScaffold(
      title: '',
      showAppBar: false,
      body: CBNeonBackground(
        showOverlay: true,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),
                Icon(
                  Icons.nightlife_rounded,
                  size: 80,
                  color: scheme.secondary,
                  shadows: CBColors.iconGlow(scheme.secondary),
                ),
                const SizedBox(height: 32),
                Text(
                  'SURVIVE THE NIGHT',
                  textAlign: TextAlign.center,
                  style: textTheme.displayMedium!.copyWith(
                    color: scheme.secondary,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2.0,
                    shadows: CBColors.textGlow(scheme.secondary, intensity: 0.8),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'CLUB BLACKOUT REBORN',
                  style: textTheme.labelLarge!.copyWith(
                    color: scheme.onSurface.withValues(alpha: 0.7),
                    letterSpacing: 4.0,
                  ),
                ),
                const SizedBox(height: 48),
                CBPanel(
                  borderColor: scheme.secondary.withValues(alpha: 0.5),
                  child: Column(
                    children: [
                      Text(
                        'TRUST NO ONE. DECEIVE EVERYONE. FIND THE DEALER.',
                        textAlign: TextAlign.center,
                        style: textTheme.bodyLarge!.copyWith(
                          color: scheme.onSurface,
                          fontWeight: FontWeight.bold,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Join the lobby, receive your secret role, and use your abilities to outwit the competition. The party ends when you say it does.',
                        textAlign: TextAlign.center,
                        style: textTheme.bodyMedium!.copyWith(
                          color: scheme.onSurface.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                CBPrimaryButton(
                  label: 'ENTER THE CLUB',
                  icon: Icons.login_rounded,
                  onPressed: _enterClub,
                  backgroundColor: scheme.secondary.withValues(alpha: 0.2),
                  foregroundColor: scheme.secondary,
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
