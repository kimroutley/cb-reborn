import 'package:flutter/material.dart';

import 'package:cb_theme/src/widgets/cb_fade_slide.dart';

/// A view for dead players, allowing them to participate in the "Dead Pool".
class GhostLoungeView extends StatelessWidget {
  const GhostLoungeView({super.key});

  @override
  Widget build(BuildContext context) {
    // This is a placeholder and will be implemented with the full Ghost Lounge UI.
    return Center(
      child: CBFadeSlide(
        child: Text(
          'Welcome to the Ghost Lounge',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
    );
  }
}
