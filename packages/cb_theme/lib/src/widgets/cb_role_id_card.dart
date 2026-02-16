import 'package:cb_models/cb_models.dart';
import 'package:flutter/material.dart';
import '../colors.dart';
import 'cb_panel.dart';
import 'cb_role_avatar.dart';
import 'cb_badge.dart';

/// A high-fidelity, interactive role ID card.
class CBRoleIDCard extends StatelessWidget {
  final Role role;
  final VoidCallback? onTap;

  const CBRoleIDCard({
    super.key,
    required this.role,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = CBColors.fromHex(role.colorHex);

    return CBPanel(
      borderColor: color,
      child: InkWell(
        onTap: onTap,
        child: Row(
          children: [
            CBRoleAvatar(
              assetPath: role.assetPath,
              color: color,
              size: 48,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    role.name.toUpperCase(),
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: color,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  CBBadge(
                    text: "CLASS: ${role.type}",
                    color: color,
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: color.withValues(alpha: 0.7),
            ),
          ],
        ),
      ),
    );
  }
}
