import 'package:flutter_test/flutter_test.dart';
import 'package:cb_models/cb_models.dart';
import 'package:cb_logic/src/game_resolution_logic.dart';

void main() {
  // Helper to create a dummy role
  Role createRole({
    String id = 'test_role',
    String name = 'Test Role',
    Team alliance = Team.partyAnimals,
    String type = 'Test Type',
    String description = 'Test Description',
    int nightPriority = 0,
    String assetPath = 'assets/roles/test.png',
    String colorHex = '#FFFFFF',
  }) {
    return Role(
      id: id,
      name: name,
      alliance: alliance,
      type: type,
      description: description,
      nightPriority: nightPriority,
      assetPath: assetPath,
      colorHex: colorHex,
    );
  }

  // Helper to create a dummy player
  Player createPlayer({
    required String id,
    String name = 'Test Player',
    bool isAlive = true,
    int lives = 1,
  }) {
    return Player(
      id: id,
      name: name,
      role: createRole(),
      alliance: Team.partyAnimals,
      isAlive: isAlive,
      lives: lives,
    );
  }

  group('GameResolutionLogic.resolveDayVote', () {
    test('returns original players and "No votes were cast" report if tally is empty', () {
      final players = [
        createPlayer(id: 'p1'),
        createPlayer(id: 'p2'),
      ];
      final tally = <String, int>{};
      const dayCount = 1;

      final resolution = GameResolutionLogic.resolveDayVote(players, tally, dayCount);

      expect(resolution.players, equals(players));
      expect(resolution.report, contains('No votes were cast.'));
    });

    test('returns original players and "abstain" report if abstain wins', () {
      final players = [
        createPlayer(id: 'p1'),
        createPlayer(id: 'p2'),
      ];
      final tally = {'abstain': 5, 'p1': 2, 'p2': 1};
      const dayCount = 1;

      final resolution = GameResolutionLogic.resolveDayVote(players, tally, dayCount);

      expect(resolution.players, equals(players));
      expect(resolution.report, contains('The club decided to abstain from exiling anyone.'));
    });

    test('returns original players and "tie" report if there is a tie for first place', () {
      final players = [
        createPlayer(id: 'p1'),
        createPlayer(id: 'p2'),
      ];
      final tally = {'p1': 3, 'p2': 3};
      const dayCount = 1;

      final resolution = GameResolutionLogic.resolveDayVote(players, tally, dayCount);

      expect(resolution.players, equals(players));
      expect(resolution.report, contains('The vote ended in a tie. No one was exiled.'));
    });

    test('returns updated players and "exile" report if there is a clear winner', () {
      final p1 = createPlayer(id: 'p1', name: 'Alice');
      final p2 = createPlayer(id: 'p2', name: 'Bob');
      final players = [p1, p2];
      final tally = {'p1': 5, 'p2': 2};
      const dayCount = 1;

      final resolution = GameResolutionLogic.resolveDayVote(players, tally, dayCount);

      final exiledPlayer = resolution.players.firstWhere((p) => p.id == 'p1');
      expect(exiledPlayer.isAlive, isFalse);
      expect(exiledPlayer.deathDay, equals(dayCount));
      expect(exiledPlayer.deathReason, equals('exile'));

      expect(resolution.report.first, contains('Alice was exiled from the club by popular vote.'));
    });

    test('returns updated players if there is a clear winner but a tie for lower places', () {
      final p1 = createPlayer(id: 'p1', name: 'Alice');
      final p2 = createPlayer(id: 'p2', name: 'Bob');
      final p3 = createPlayer(id: 'p3', name: 'Charlie');
      final players = [p1, p2, p3];
      final tally = {'p1': 5, 'p2': 2, 'p3': 2};
      const dayCount = 1;

      final resolution = GameResolutionLogic.resolveDayVote(players, tally, dayCount);

      final exiledPlayer = resolution.players.firstWhere((p) => p.id == 'p1');
      expect(exiledPlayer.isAlive, isFalse);
      expect(exiledPlayer.deathDay, equals(dayCount));
      expect(exiledPlayer.deathReason, equals('exile'));

      expect(resolution.report.first, contains('Alice was exiled from the club by popular vote.'));
    });
  });
}
