import 'package:cb_models/cb_models.dart' hide PlayerSnapshot;
import 'package:cb_player/player_bridge.dart';
import 'package:cb_player/player_bridge_actions.dart';
import 'package:cb_theme/cb_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../widgets/biometric_identity_header.dart';
import '../widgets/custom_drawer.dart';
import '../widgets/game_action_tile.dart';
import '../widgets/ghost_lounge_content.dart';

class GameScreen extends ConsumerStatefulWidget {
  final PlayerBridgeActions bridge;
  final PlayerGameState gameState;
  final PlayerSnapshot player;
  final String playerId;

  const GameScreen({
    super.key,
    required this.bridge,
    required this.gameState,
    required this.player,
    required this.playerId,
  });

  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen> {
  final ScrollController _scrollController = ScrollController();
  String? _lastStepId;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant GameScreen oldWidget) {
    super.didUpdateWidget(oldWidget);

    final newStep = widget.gameState.currentStep;
    final canAct = newStep != null &&
        (newStep.roleId == widget.player.roleId || newStep.isVote);

    if (newStep != null && newStep.id != _lastStepId && canAct) {
      _lastStepId = newStep.id;
      HapticFeedback.mediumImpact();
      _scrollToBottom();
    } else if (newStep == null) {
      _lastStepId = null;
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOutCubic,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (!widget.player.isAlive) {
      return GhostLoungeContent(
        gameState: widget.gameState,
        player: widget.player,
        playerId: widget.playerId,
        bridge: widget.bridge,
      );
    }

    final step = widget.gameState.currentStep;
    final roleColor =
        Color(int.parse(widget.player.roleColorHex.replaceAll('#', '0xff')));
    final canAct =
        step != null && (step.roleId == widget.player.roleId || step.isVote);
    final isRoleConfirmed = widget.gameState.roleConfirmedPlayerIds
      .contains(widget.playerId);

    // Apply dynamic theme for the role
    return Theme(
      data: CBTheme.buildTheme(CBTheme.buildColorScheme(roleColor)),
      child: Scaffold(
        drawer: const CustomDrawer(),
        body: CBNeonBackground(
          child: Column(
            children: [
              // ── BIOMETRIC IDENTITY HEADER ──
              BiometricIdentityHeader(
                player: widget.player,
                roleColor: roleColor,
                isMyTurn: canAct,
              ),

              // ── CHAT FEED ──
              Expanded(
                child: ListView(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  children: [
                    // 1. Current Phase Header
                    CBMessageBubble(
                      sender: 'SYSTEM',
                      message:
                          "${widget.gameState.phase.toUpperCase()} - DAY ${widget.gameState.dayCount}",
                      isSystemMessage: true,
                    ),

                    if (widget.gameState.phase == 'setup' && !isRoleConfirmed)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                        child: CBPrimaryButton(
                          label: 'CONFIRM ROLE',
                          icon: Icons.verified_user_rounded,
                          onPressed: () {
                            widget.bridge.confirmRole(playerId: widget.playerId);
                            HapticFeedback.selectionClick();
                          },
                        ),
                      ),

                    if (widget.gameState.phase == 'setup' && isRoleConfirmed)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                        child: CBBadge(
                          text: 'ROLE CONFIRMED',
                          color: theme.colorScheme.tertiary,
                        ),
                      ),

                    // 2. Bulletin History (Public events)
                    ...widget.gameState.bulletinBoard.map((entry) {
                      final role =
                          roleCatalogMap[entry.roleId] ?? roleCatalog.first;
                      final color = entry.roleId != null
                          ? CBColors.fromHex(role.colorHex)
                          : theme.colorScheme.primary; // Use theme color
                      final senderName =
                          role.id == 'unassigned' ? entry.title : role.name;

                      return CBMessageBubble(
                        sender: senderName,
                        message: entry.content,
                        isSystemMessage: entry.type == 'system',
                        color: color,
                        avatarAsset: entry.roleId != null ? role.assetPath : null,
                      );
                    }),

                    // 3. Private Intel (The "Secret" Chat)
                    if (widget.gameState.privateMessages
                        .containsKey(widget.playerId))
                      ...widget.gameState.privateMessages[widget.playerId]!
                          .map((msg) => CBMessageBubble(
                                sender: 'PRIVATE',
                                message: msg,
                              )),

                    // 4. Current Directive
                    if (step != null) ...[
                      CBMessageBubble(
                        sender: 'DIRECTIVE',
                        message: step.readAloudText,
                        avatarAsset: 'assets/roles/${widget.player.roleId}.png',
                        color: roleColor,
                      ),

                      // 5. Action Tile (Interactive)
                      if (canAct)
                        GameActionTile(
                          step: step,
                          roleColor: roleColor,
                          player: widget.player,
                          gameState: widget.gameState,
                          playerId: widget.playerId,
                          bridge: widget.bridge,
                        ),
                    ],

                    const SizedBox(height: 120),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
