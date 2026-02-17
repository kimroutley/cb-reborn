import 'package:cb_models/cb_models.dart' hide PlayerSnapshot;
import 'package:cb_player/player_bridge.dart';
import 'package:cb_player/player_bridge_actions.dart';
import 'package:cb_player/screens/player_selection_screen.dart';
import 'package:cb_theme/cb_theme.dart';
import 'package:flutter/material.dart';

class GameActionTile extends StatefulWidget {
  final StepSnapshot step;
  final Color roleColor;
  final PlayerSnapshot player;
  final PlayerGameState gameState;
  final String playerId;
  final PlayerBridgeActions bridge;

  const GameActionTile({
    super.key,
    required this.step,
    required this.roleColor,
    required this.player,
    required this.gameState,
    required this.playerId,
    required this.bridge,
  });

  @override
  State<GameActionTile> createState() => _GameActionTileState();
}

class _GameActionTileState extends State<GameActionTile> {
  void _handleActionTap() {
    final isMultiSelect =
        widget.step.actionType == ScriptActionType.selectTwoPlayers.name;

    if (widget.step.isVote ||
        widget.step.actionType == ScriptActionType.selectPlayer.name ||
        isMultiSelect) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PlayerSelectionScreen(
            players: widget.gameState.players.where((p) => p.isAlive).toList(),
            step: widget.step,
            onPlayerSelected: (targetId) {
              if (widget.step.isVote) {
                widget.bridge
                    .vote(voterId: widget.playerId, targetId: targetId);
              } else {
                widget.bridge
                    .sendAction(stepId: widget.step.id, targetId: targetId);
              }

              // Only pop if it's not a multi-select or if we just sent the combined result
              // (Depending on how onPlayerSelected is implemented for multi-select)
              if (!isMultiSelect || targetId.contains(',')) {
                Navigator.pop(context);
              }
            },
          ),
        ),
      );
    } else if (widget.step.actionType == ScriptActionType.binaryChoice.name) {
      showThemedBottomSheet<void>(
        context: context,
        accentColor: widget.roleColor,
        child: Builder(
          builder: (context) {
            final textTheme = Theme.of(context).textTheme;
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  widget.step.title.toUpperCase(),
                  style: textTheme.headlineSmall!.copyWith(
                    color: widget.roleColor,
                    shadows: [
                      BoxShadow(
                        color: widget.roleColor.withValues(alpha: 0.5),
                        blurRadius: 24,
                        spreadRadius: 12,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                ...widget.step.options.map(
                  (option) => Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: CBPrimaryButton(
                      label: option.toUpperCase(),
                      onPressed: () {
                        widget.bridge.sendAction(
                            stepId: widget.step.id, targetId: option);
                        Navigator.pop(context);
                      },
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    String title;
    IconData icon;

    if (widget.step.isVote) {
      title = "CRITICAL VOTE";
      icon = Icons.how_to_vote_rounded;
    } else if (widget.step.actionType == ScriptActionType.selectPlayer.name ||
        widget.step.actionType == ScriptActionType.selectTwoPlayers.name) {
      title = "SELECT TARGET";
      icon = Icons.gps_fixed_rounded;
    } else if (widget.step.actionType == ScriptActionType.binaryChoice.name) {
      title = "MAKE A CHOICE";
      icon = Icons.alt_route_rounded;
    } else {
      title = "OPERATIVE ACTION";
      icon = Icons.flash_on_rounded;
    }

    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return CBGlassTile(
      borderColor: widget.roleColor,
      onTap: _handleActionTap,
      child: Column(
        children: [
          Text(
            title,
            style: textTheme.headlineSmall!.copyWith(
              color: widget.roleColor,
              shadows: [
                BoxShadow(
                  color: widget.roleColor.withValues(alpha: 0.5),
                  blurRadius: 24,
                  spreadRadius: 12,
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.step.instructionText.isNotEmpty
                ? widget.step.instructionText
                : "INPUT REQUIRED",
            style: textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          Icon(icon, color: scheme.onSurface, size: 20),
          const SizedBox(height: 16),
          Text(
            "WAKE UP, ${widget.player.name.toUpperCase()}. THE CLUB IS WAITING.",
            textAlign: TextAlign.center,
            style: textTheme.labelSmall!.copyWith(
              color: scheme.onSurface.withValues(alpha: 0.4),
              fontSize: 9,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 12),
          Icon(
            Icons.touch_app,
            color: scheme.onSurface.withValues(alpha: 0.24),
            size: 16,
          ),
        ],
      ),
    );
  }
}
