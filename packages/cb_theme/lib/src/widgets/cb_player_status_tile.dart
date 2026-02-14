import 'package:cb_theme/src/colors.dart';
import 'package:flutter/material.dart';

import 'cb_badge.dart';
import 'cb_role_avatar.dart';

/// Unified player status tile for the host feed.
class CBPlayerStatusTile extends StatelessWidget {
  final String playerName;
  final String roleName;
  final String? assetPath;
  final Color? roleColor;
  final bool isAlive;
  final List<String> statusEffects;

  const CBPlayerStatusTile({
    super.key,
    required this.playerName,
    required this.roleName,
    this.assetPath,
    this.roleColor,
    this.isAlive = true,
    this.statusEffects = const [],
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accentColor = roleColor ?? theme.colorScheme.primary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(12),
        border:
            Border.all(color: accentColor.withValues(alpha: 0.2), width: 0.5),
      ),
      child: Row(
        children: [
          // Avatar
          CBRoleAvatar(assetPath: assetPath, color: accentColor, size: 32),
          const SizedBox(width: 10),

          // Name + role
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  playerName.toUpperCase(),
                  style: theme.textTheme.bodyMedium!.copyWith(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                    shadows: CBColors.textGlow(accentColor, intensity: 0.4),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  roleName.toUpperCase(),
                  style: theme.textTheme.labelSmall!.copyWith(
                    color: accentColor,
                    fontSize: 9,
                  ),
                ),
              ],
            ),
          ),

          // Status chips
          if (!isAlive) CBBadge(text: 'DEAD', color: CBColors.dead),
          if (isAlive && statusEffects.isNotEmpty)
            ...statusEffects.map(
              (effect) => Padding(
                padding: const EdgeInsets.only(left: 4),
                child: CBBadge(
                  text: effect.toUpperCase(),
                  color: _statusColor(effect),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Color _statusColor(String effect) {
    return switch (effect.toLowerCase()) {
      'protected' => CBColors.fromHex('#FF0000'), // Medic (red)
      'silenced' => CBColors.fromHex('#00C853'), // Roofi (green)
      'id checked' => CBColors.fromHex('#4169E1'), // Bouncer (royal blue)
      'sighted' => CBColors.fromHex('#483C32'), // Club Manager (dark brown)
      'alibi' => CBColors.fromHex('#808000'), // Silver Fox (olive)
      'sent home' => CBColors.fromHex('#32CD32'), // Sober (lime green)
      'clinging' => CBColors.fromHex('#FFFF00'), // Clinger (yellow)
      'paralysed' || 'paralyzed' => CBColors.purple,
      _ => CBColors.dead,
    };
  }
}
