import 'dart:async';

import 'package:cb_theme/src/colors.dart';
import 'package:cb_theme/src/haptic_service.dart';
import 'package:cb_theme/src/layout.dart';
import 'package:cb_theme/src/typography.dart';
import 'package:flutter/material.dart';

/// Countdown timer widget for timed phases.
class CBCountdownTimer extends StatefulWidget {
  final int seconds;
  final VoidCallback? onComplete;
  final Color? color;

  const CBCountdownTimer({
    super.key,
    required this.seconds,
    this.onComplete,
    this.color, // Allow overriding base color
  });

  @override
  State<CBCountdownTimer> createState() => _CBCountdownTimerState();
}

class _CBCountdownTimerState extends State<CBCountdownTimer> {
  late int _remaining;
  late final Stream<int> _timerStream;

  @override
  void initState() {
    super.initState();
    _remaining = widget.seconds;
    _timerStream = Stream.periodic(
      const Duration(seconds: 1),
      (tick) => widget.seconds - tick - 1,
    ).take(widget.seconds);

    _timerStream.listen((seconds) {
      if (mounted) {
        setState(() => _remaining = seconds);
        if (_remaining <= 5) {
          HapticService.light();
        }
      }
      if (seconds == 0) {
        HapticService.heavy();
        widget.onComplete?.call();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final minutes = _remaining ~/ 60;
    final seconds = _remaining % 60;
    final timeStr =
        '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    final isCritical = _remaining <= 30;
    final displayColor = widget.color ??
        (isCritical ? CBColors.warning : theme.colorScheme.primary);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(CBSpace.x8),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(CBRadius.md),
        border: Border.all(color: displayColor, width: 2),
        boxShadow: CBColors.boxGlow(displayColor, intensity: 0.3),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            timeStr,
            style: CBTypography.timer.copyWith(color: displayColor),
          ),
          const SizedBox(height: CBSpace.x2),
          Text(
            (isCritical ? 'TIME RUNNING OUT' : 'TIME REMAINING').toUpperCase(),
            style: theme.textTheme.labelMedium!.copyWith(color: displayColor),
          ),
        ],
      ),
    );
  }
}
