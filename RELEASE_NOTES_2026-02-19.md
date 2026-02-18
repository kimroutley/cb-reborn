# Release Notes — 2026-02-19

## Highlights

This release improves profile editing reliability, drawer navigation safety, and About/changelog UX consistency across Host and Player.

## Included Changes

### Profile UX hardening (Host + Player)

- Added unsaved-edit guard flow for profile navigation via drawers.
- Added shared profile action-button components for save/discard/reload actions.
- Improved profile screens to track and surface dirty state consistently.

### Hall of Fame access coverage

- Added dedicated access tests for Host and Player Hall of Fame entry points.
- Stabilized test behavior around navigation and drawer interactions.

### About + latest updates UX

- Updated About content to use expandable “View latest updates”.
- Ensured latest updates display is capped to the 3 most recent builds.
- Added widget coverage for required About metadata and changelog behavior.

## Key Commits

- `ee224e6` feat(profile): guard unsaved edits in drawers and add action-button components
- `a8643d1` test(docs): add hall-of-fame access coverage and refresh PR summary
- `8553e0c` feat(theme): make about updates expandable and add widget coverage

## Validation Snapshot

- `apps/host`: analyze ✅, targeted tests ✅
- `apps/player`: analyze ✅, targeted tests ✅
- `packages/cb_theme`: analyze ✅, widget tests ✅

## Notes

- Release date for About screens continues to come from structured recent-build metadata.
- Changelog display remains intentionally constrained to recent builds for readability.
