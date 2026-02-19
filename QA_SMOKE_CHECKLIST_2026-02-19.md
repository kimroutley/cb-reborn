# QA Smoke Checklist — 2026-02-19

## Latest execution notes (2026-02-19)

- [x] First manual pass executed.
- [ ] Local/cloud mode switching remains unstable in runtime validation (mitigation applied; re-test pending).
- [ ] Cloud connectivity/reconnect behavior reported as glitchy (re-test pending after mode-switch hardening).
- [ ] Cloud connectivity/reconnect behavior reported as glitchy (additional mitigation applied: cloud join now waits for first snapshot with timeout/error handling; re-test pending).
- [ ] Host iOS email-link flow reported as hanging after login screen (mitigation applied; re-test pending).
- [x] GitHub release-signing secrets verified: none exist currently (deployment blocked until provisioned).

## Host app

- [ ] Open `Profile` from drawer.
- [ ] Edit username/public ID/avatar/style.
- [ ] Try leaving profile via drawer without saving and verify discard prompt appears.
- [ ] Cancel prompt and confirm you remain on profile with edits preserved.
- [ ] Repeat and choose discard; confirm navigation proceeds and changes reset.
- [ ] Save profile; confirm success feedback and dirty state clears.
- [ ] Re-open profile and verify saved values persisted.

## Player app

- [ ] Open `Profile` from drawer.
- [ ] Make profile edits (username/public ID/avatar/style).
- [ ] Navigate away through drawer and verify discard confirmation appears.
- [ ] Cancel once (stay on profile), then discard once (leave profile).
- [ ] Use Reload From Cloud and confirm values rehydrate correctly.

## About / changelog

- [ ] Open About in Host and Player.
- [ ] Verify About includes:
  - [ ] “A game by Kyrian Co.”
  - [ ] Version/build label
  - [ ] Release date
  - [ ] Credits
  - [ ] Copyright line
- [ ] Expand “View latest updates”.
- [ ] Confirm only the 3 latest builds are shown.

## Hall of Fame navigation

- [ ] Host Home quick action opens Hall of Fame.
- [ ] Player Stats action opens Hall of Fame.

## Regression sanity

- [ ] Host drawer remains responsive after profile discard/cancel cycles.
- [ ] Player drawer shows no layout overflow on common screen sizes.
- [ ] No stuck overlays/dialogs after cancelling discard prompts.

## Real-device multiplayer validation (local + cloud)

### Setup

- [ ] Device A: Host build installed and launched.
- [ ] Device B: Player build installed and launched.
- [ ] Both devices on same network for local-mode checks.
- [ ] Test account(s) available for cloud-mode checks.

### Local mode flow

- [ ] Host creates a local lobby.
- [ ] Player joins via code entry.
- [ ] Player join appears on Host roster within expected latency.
- [ ] Host starts game; Player transitions into active game screen.
- [ ] At least one night + day cycle completes with state sync preserved.
- [ ] Host can end/leave lobby and Player receives disconnect/exit state cleanly.

### Cloud mode flow

- [ ] Host signs in and creates cloud lobby.
- [ ] Player signs in and joins same lobby from a second network profile (if possible).
- [ ] Lobby/player list sync remains stable through phase transitions.
- [ ] Reconnect test: temporarily disable Player network, then re-enable and confirm recovery.

### Mode switching

- [ ] Exit local session and start cloud session in same app runtime.
- [ ] Exit cloud session and start local session in same app runtime.
- [ ] Confirm no stale roster/join-code/session leakage between modes.

## Deep-link and QR validation

### Deep-link cold start

- [ ] Fully terminate Player app.
- [ ] Open a valid join deep-link (`code` + `session`) from outside app.
- [ ] Verify app launches directly into join/connect flow with prefilled payload.

### Deep-link warm start

- [ ] Keep Player app in background.
- [ ] Open a valid join deep-link.
- [ ] Verify app foregrounds and applies latest link payload once (no duplicate joins).

### Negative deep-link cases

- [ ] Invalid/malformed link shows recoverable error state.
- [ ] Expired/unknown session link prompts safe retry path.

### QR scan

- [ ] Scan a valid Host QR code from Player device.
- [ ] Verify parsed join payload matches Host session and proceeds to join.
- [ ] Scan an invalid QR and verify graceful error handling.

## Host iOS email-link auth (E2E)

- [ ] Host iOS build installed from release candidate.
- [ ] Request email sign-in link from Host auth screen.
- [ ] Open link from iOS Mail and confirm app deep-links back correctly.
- [ ] Verify signed-in state persists after app restart.
- [ ] Sign out and repeat once to confirm no stale token/session anomalies.

## Release-signing secret provisioning (GitHub)

- [ ] Confirm required secrets exist in GitHub environment for `main` deployment path.
- [ ] Confirm secret names match workflow expectations exactly.
- [ ] Trigger a dry-run or non-prod workflow path that consumes signing config.
- [ ] Verify no missing-secret or empty-variable warnings in workflow logs.
