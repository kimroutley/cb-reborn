# cb_theme

A comprehensive theme and widget library for the CyberBlood game, featuring a neon synthwave aesthetic. This package provides the core design system, reusable UI components, and shared assets for both the Host and Player applications.

## Features

### Core Design System
The visual language of CyberBlood is built on a "Neon Synthwave" foundation, defined by:
- **Color Palette (`CBColors`)**: A rich collection of high-contrast colors including `electricCyan`, `magentaShift`, `voidBlack`, and semantic role colors.
- **Typography (`CBTypography`)**: Custom text styles optimized for legibility and atmosphere, including specialized styles for headers, timers, and code.
- **Layout & Spacing (`CBLayout`)**: Standardized spacing (`CBSpace`) and corner radii (`CBRadius`) ensuring consistency across all screens.
- **Theme Data**: Pre-configured `ThemeData` for dark and light modes, ready for application-wide use.

### Reusable Widgets
A library of over 20 polished, high-fidelity widgets:

#### Layout & Containers
- **`CBNeonBackground`**: Atmospheric background with animated radiance, blur effects, and solid overlays.
- **`CBPanel`**: A glowing, glassmorphic panel for grouping related content.
- **`CBPrismScaffold`**: A specialized scaffold implementing the signature neon background and layout structure.
- **`GlassTile`**: A high-impact, interactive tile with oil-slick shimmer effects and glassmorphism.

#### Inputs & Controls
- **`CBPrimaryButton` & `CBGhostButton`**: Standardized action buttons with haptic feedback integration.
- **`CBTextField`**: Styled input fields supporting monospace and capitalization options.
- **`CBSwitch` & `CBSlider`**: Custom form controls matching the neon aesthetic.
- **`CBFilterChip`**: Lightweight toggles for filtering lists or selecting options.

#### Indicators & Status
- **`CBBadge`**: Compact label chips for roles and status tags.
- **`CBConnectionDot`**: visual indicator for network connectivity status.
- **`CBStatusOverlay`**: Large overlay cards for major status changes (e.g., Eliminated, Silenced).
- **`CBCountdownTimer`**: specialized timer widget with critical state coloring and haptic ticks.
- **`CBBreathingLoader`**: A pulsing loading indicator.

#### Game Components
- **`CBRoleAvatar`**: Unified avatar component with glowing borders and breathing animations for roles.
- **`CBPlayerStatusTile`**: Comprehensive list tile for the Host feed, displaying name, role, life status, and active effects.
- **`ChatBubble`**: Versatile message bubbles supporting narrative, directive, system, and result variants.
- **`CBAllianceGraph`**: Visual representation of player alliances and relationships.
- **`CBPhaseTimeline`**: Timeline widget for tracking game phases.
- **`CBRoleIdCard`**: Detailed card display for role information.
- **`GhostLoungeView`**: Dedicated UI for eliminated players.

### Services & Utilities
- **Haptics (`HapticService`)**: Centralized service for consistent tactile feedback (light, heavy, selection, etc.).
- **Audio (`SoundService` & `MusicService`)**: Managers for playing sound effects and background music tracks.
- **Transitions (`PageTransitions`)**: Custom page transition builders for smooth navigation.
- **Overlays (`Overlays`)**: Utilities for displaying dialogs, toasts, and other floating elements.

### Screens
- **`GuideScreen`**: A complete, ready-to-use screen for displaying game guides and instructions.

## Getting Started

Add `cb_theme` to your `pubspec.yaml` dependencies:

```yaml
dependencies:
  cb_theme:
    path: packages/cb_theme
```

Ensure you have the required fonts and assets configured in your application to fully utilize the theme.

## Usage

Import the package and use the `CBTheme` to access colors and styles, or use the widgets directly:

```dart
import 'package:cb_theme/cb_theme.dart';

// Use a primary button
CBPrimaryButton(
  label: 'START GAME',
  onPressed: () {
    // Action
  },
);

// Access theme colors
Container(
  color: CBColors.electricCyan,
  child: Text('Neon Text', style: CBTypography.h1),
);
```
