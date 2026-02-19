import 'package:cb_models/cb_models.dart';

typedef AsyncOp = Future<void> Function();

Future<void> syncHostBridgesForMode({
  required SyncMode mode,
  required AsyncOp stopLocal,
  required AsyncOp startLocal,
  required AsyncOp stopCloud,
  required AsyncOp startCloud,
}) async {
  // Defensive reset: always stop both transports before activating the
  // selected one. This avoids stale runtime state when users toggle modes
  // rapidly (e.g., LOCAL -> CLOUD -> LOCAL in the same session).
  await stopLocal();
  await stopCloud();

  if (mode == SyncMode.cloud) {
    await startCloud();
    return;
  }

  await startLocal();
}
