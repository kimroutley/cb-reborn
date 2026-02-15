# cb_models

The core domain models and data structures for the **Club Baikal** party game ecosystem.

This package provides the shared types used by both the **Host** application (`apps/host`) and the **Player** application (`apps/player`), ensuring consistency across the platform. It leverages `freezed` for immutable state management and `json_serializable` for robust data interchange.

## Features

This package exports a comprehensive set of models covering:

*   **Core Entities**
    *   `Role`: Rich definitions for game roles including metadata like complexity, team, night priority, and tactical tips.
    *   `Player`: Represents a participant in the game, tracking their role, life status, and deep game-specific flags (e.g., `medicProtected`, `silenced`, `drunk`).
    *   `Team` & `GamePhase`: Enums defining the factions (The Dealers, Party Animals, Wildcards) and game flow (Lobby, Night, Day, Resolution).

*   **Game State Management**
    *   `GameState`: A `Freezed` immutable state object tracking the entire game context, including player lists, current script step, vote tallies, and action logs.
    *   `SessionState`: Manages session-specific data.

*   **Scripting & Narrative Flow**
    *   `ScriptStep` & `ScriptActionType`: Models for the dynamic scripting engine that drives the Host's narrative flow.
    *   `GameStyle`: Configuration for different game modes (Blood Bath, Last Stand, Whodunit, Chaos).

*   **Communication**
    *   `ChatMessage`: Structure for player-to-player and system-to-player messaging.
    *   `BulletinEntry`: Models for public game announcements and events.
    *   `FeedEvent`: Structures for the Host's live game feed.

*   **Data Catalogs**
    *   `RoleCatalog`: Central registry of all available roles.
    *   `RumourCatalog`: Pre-defined rumours for game mechanics.

*   **Persistence & Statistics**
    *   `GameRecord` & `GamesNightRecord`: Models for storing game history and session data.
    *   `GameStats`: Structures for tracking player and role performance statistics.

*   **Configuration**
    *   `HostPersonality`: Configuration for the AI/Host persona.
    *   `GodModeConstants`: Debug and testing configurations.

## Getting started

This package is intended for use within the Club Baikal monorepo.

Depend on it in your `pubspec.yaml`:

```yaml
dependencies:
  cb_models:
    path: ../../packages/cb_models
```

## Usage

Import the package to access the shared models:

```dart
import 'package:cb_models/cb_models.dart';

void main() {
  // Access the role catalog
  final dealerRole = roleCatalogMap[RoleIds.dealer]!;

  // Create a new player state
  final player = Player(
    id: 'p1',
    name: 'Alice',
    role: dealerRole,
    alliance: Team.clubStaff,
  );

  print('Player ${player.name} is a ${player.role.name}');
}
```

## Additional information

This package is a fundamental dependency for:
*   `packages/cb_logic`: Contains the game rules and engine logic.
*   `apps/host`: The game host application.
*   `apps/player`: The player client application.
