import 'dart:io';

import 'package:cb_logic/cb_logic.dart';
import 'package:cb_models/cb_models.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';
import 'package:riverpod/riverpod.dart';

void main() {
  late Directory tempDir;
  late PersistenceService service;
  late Box<String> activeBox;
  late Box<String> recordsBox;
  late Box<String> sessionsBox;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('hive_test_games_night_');
    Hive.init(tempDir.path);
    activeBox = await Hive.openBox<String>('test_active');
    recordsBox = await Hive.openBox<String>('test_records');
    sessionsBox = await Hive.openBox<String>('test_sessions');
    service = PersistenceService.initWithBoxes(
      activeBox,
      recordsBox,
      sessionsBox,
    );
  });

  tearDown(() async {
    await service.close();
    await Hive.deleteFromDisk();
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  group('GamesNightProvider', () {
    test('refreshSession updates state when session exists', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final notifier = container.read(gamesNightProvider.notifier);

      // Start a session
      await notifier.startSession('Test Session');
      final initialState = container.read(gamesNightProvider);
      expect(initialState, isNotNull);
      final sessionId = initialState!.id;

      // Update session in persistence directly
      final updatedSession = initialState.copyWith(
        playerNames: ['Alice', 'Bob'],
      );
      await service.saveGamesNightRecord(updatedSession);

      // Refresh session
      await notifier.refreshSession();
      final refreshedState = container.read(gamesNightProvider);

      expect(refreshedState!.playerNames, containsAll(['Alice', 'Bob']));
    });

    test('refreshSession handles error when session is missing', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final notifier = container.read(gamesNightProvider.notifier);

      // Start a session
      await notifier.startSession('Test Session');
      final initialState = container.read(gamesNightProvider);
      expect(initialState, isNotNull);
      final sessionId = initialState!.id;

      // Delete session from persistence
      await service.deleteSession(sessionId);

      // Refresh session - should handle the error and set state to null
      await notifier.refreshSession();
      final refreshedState = container.read(gamesNightProvider);

      expect(refreshedState, isNull);
    });
  });
}
