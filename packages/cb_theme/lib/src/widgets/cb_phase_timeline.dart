import 'package:flutter/material.dart';
import 'package:cb_models/cb_models.dart';
import 'cb_panel.dart';
import 'cb_section_header.dart';

/// A widget to display the phase timeline.
class CBPhaseTimeline extends StatelessWidget {
  final GamePhase currentPhase;

  const CBPhaseTimeline({super.key, required this.currentPhase});

  @override
  Widget build(BuildContext context) {
    // This is a placeholder and will be implemented with the full Phase Timeline UI.
    return CBPanel(
      child: Column(
        children: [
          const CBSectionHeader(title: 'Phase Timeline'),
          Text('Current Phase: ${currentPhase.name}'),
        ],
      ),
    );
  }
}
