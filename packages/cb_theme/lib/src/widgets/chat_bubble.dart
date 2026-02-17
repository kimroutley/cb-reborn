import 'package:flutter/material.dart';

import 'package:cb_theme/src/widgets/cb_role_avatar.dart';

/// A chat bubble for displaying messages in the game feed.
class CBMessageBubble extends StatelessWidget {
  final String sender;
  final String message;
  final String? avatarAsset;
  final Color? color;
  final bool isSystemMessage;
  final bool isSender;

  const CBMessageBubble({
    super.key,
    required this.sender,
    required this.message,
    this.avatarAsset,
    this.color,
    this.isSystemMessage = false,
    this.isSender = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final accentColor = color ?? scheme.primary;

    if (isSystemMessage) {
      return Container(
        padding: const EdgeInsets.symmetric(
            horizontal: 16, vertical: 12),
        margin: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: accentColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: accentColor.withValues(alpha: 0.3)),
        ),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodySmall?.copyWith(color: accentColor),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment:
            isSender ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isSender) ...[
            CBRoleAvatar(
              assetPath: avatarAsset,
              color: color,
              size: 32,
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSender
                    ? accentColor.withValues(alpha: 0.2)
                    : scheme.surfaceContainer,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: accentColor.withValues(alpha: isSender ? 0.5 : 0.2),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    sender.toUpperCase(),
                    style: theme.textTheme.labelSmall
                        ?.copyWith(color: accentColor, letterSpacing: 1.1),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    message,
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ),
          if (isSender) ...[
            const SizedBox(width: 8),
            CBRoleAvatar(
              assetPath: avatarAsset,
              color: color,
              size: 32,
            ),
          ],
        ],
      ),
    );
  }
}
