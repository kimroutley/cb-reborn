import 'package:cb_logic/cb_logic.dart';
import 'package:cb_theme/cb_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../common_dialogs.dart';

class LobbyGamesNightBanner extends ConsumerWidget {
  const LobbyGamesNightBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final session = ref.watch(gamesNightProvider);
    if (session == null || !session.isActive) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CBMessageBubble(
            sender: "PROMOTER",
            message:
                "Hosting a full session? Start a Games Night to track multiple rounds and get a recap.",
            color: theme.colorScheme.tertiary,
            avatarAsset: 'assets/roles/promoter.png',
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: CBCompactPlayerChip(
              name: "START GAMES NIGHT",
              color: theme.colorScheme.tertiary,
              onTap: () async {
                final name = await showStartSessionDialog(context);
                if (name == null || name.trim().isEmpty) return;

                await ref
                    .read(gamesNightProvider.notifier)
                    .startSession(name.trim());

                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Games Night started.'),
                    backgroundColor: theme.colorScheme.tertiary,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
            ),
          ),
        ],
      );
    }

    return CBMessageBubble(
      isSystemMessage: true,
      sender: 'System',
      message:
          "GAMES NIGHT ACTIVE: ${session.sessionName} (GAME #${session.gameIds.length + 1})",
      color: theme.colorScheme.tertiary,
    );
  }
}
