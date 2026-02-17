import 'package:cb_models/cb_models.dart';
import 'package:cb_theme/cb_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../host_bridge.dart';

class LobbyAccessCodeTile extends ConsumerWidget {
  final HostBridge bridge;
  final bool isCloud;
  final SessionState session;
  final Color primaryColor;

  const LobbyAccessCodeTile({
    super.key,
    required this.bridge,
    required this.isCloud,
    required this.session,
    required this.primaryColor,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final port = bridge.port;

    return CBPanel(
      borderColor: primaryColor.withValues(alpha: 0.4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isCloud
                    ? Icons.cloud_done_outlined
                    : Icons.wifi_tethering_rounded,
                color: primaryColor,
              ),
              const SizedBox(width: CBSpace.x3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "ACCESS CODE",
                      style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                            color: primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      isCloud ? "CLOUD SYNC ENABLED" : "LOCAL BROADCAST ACTIVE",
                      style: Theme.of(context).textTheme.bodySmall!.copyWith(
                            color: primaryColor.withValues(alpha: 0.7),
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "PATRONS ENTER THIS CODE TO CONNECT",
                      style: CBTypography.labelSmall.copyWith(
                          color: scheme.onSurface.withValues(alpha: 0.5),
                          fontSize: 8,
                          letterSpacing: 2.0),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: scheme.surfaceContainerHighest.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: primaryColor.withValues(alpha: 0.3)),
                      ),
                      child: Text(
                        session.joinCode,
                        style: CBTypography.code.copyWith(
                          color: primaryColor,
                          fontSize: 32,
                          letterSpacing: 12,
                          shadows: CBColors.textGlow(primaryColor),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              _buildJoinQrCode(context, ref, session, isCloud, port),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildJoinQrCode(
    BuildContext context,
    WidgetRef ref,
    SessionState session,
    bool isCloud,
    int port,
  ) {
    if (isCloud) {
      final cloudJoinUrl =
          'https://cb-reborn.web.app/join?mode=cloud&sid=${session.sessionId}&code=${session.joinCode}';
      return _buildQrWidget(context, cloudJoinUrl, 'SCAN CLOUD LINK');
    }

    final ipsAsync = ref.watch(localIpsProvider);
    return ipsAsync.when(
      data: (ips) {
        if (ips.isEmpty) {
          return const SizedBox.shrink();
        }
        final ip = ips.first;
        final host = Uri.encodeComponent('ws://$ip:$port');
        final joinUrl =
          'https://cb-reborn.web.app/join?mode=local&sid=${session.sessionId}&host=$host&code=${session.joinCode}';
        return _buildQrWidget(context, joinUrl, 'SCAN LOCAL LINK');
      },
      loading: () => const SizedBox.shrink(),
      error: (err, stack) => const SizedBox.shrink(),
    );
  }

  Widget _buildQrWidget(BuildContext context, String url, String caption) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: scheme.onSurface,
            borderRadius: BorderRadius.circular(12),
            boxShadow: CBColors.boxGlow(scheme.onSurface, intensity: 0.3),
          ),
          child: QrImageView(
            data: url,
            version: QrVersions.auto,
            size: 90,
            gapless: false,
            eyeStyle: const QrEyeStyle(
              eyeShape: QrEyeShape.square,
              color: CBColors.voidBlack,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          caption,
          style: CBTypography.labelSmall.copyWith(
            color: scheme.onSurface.withValues(alpha: 0.4),
            fontSize: 7,
            letterSpacing: 1.0,
          ),
        ),
      ],
    );
  }
}
