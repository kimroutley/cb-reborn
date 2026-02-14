import 'package:cb_logic/src/game_resolution_logic.dart';
import 'package:cb_models/cb_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // Helper to create a player with minimal required fields
  Player createPlayer({
    required String id,
    required String roleId,
    Team alliance = Team.partyAnimals,
    int lives = 1,
    bool isAlive = true,
    String? medicChoice,
    bool secondWindConverted = false,
  }) {
    return Player(
      id: id,
      name: 'Player $id',
      role: Role(
        id: roleId,
        name: roleId,
        type: 'test_type',
        description: 'test description',
        nightPriority: 0,
        assetPath: 'assets/test.png',
        colorHex: '#000000',
        alliance: alliance,
      ),
      alliance: alliance,
      lives: lives,
      isAlive: isAlive,
      medicChoice: medicChoice,
      secondWindConverted: secondWindConverted,
    );
  }

  group('GameResolutionLogic.resolveNightActions', () {
    test('Sober blocks a target from acting', () {
      final sober = createPlayer(id: 'sober', roleId: RoleIds.sober);
      final dealer = createPlayer(id: 'dealer', roleId: RoleIds.dealer, alliance: Team.clubStaff);
      final victim = createPlayer(id: 'victim', roleId: RoleIds.partyAnimal);

      final players = [sober, dealer, victim];
      final log = {
        'sober_act_sober': 'dealer',
        'dealer_act_dealer': 'victim',
      };
      final dayCount = 1;
      final currentPrivateMessages = <String, List<String>>{};

      final result = GameResolutionLogic.resolveNightActions(
        players,
        log,
        dayCount,
        currentPrivateMessages,
      );

      final updatedVictim = result.players.firstWhere((p) => p.id == 'victim');
      // Dealer was blocked, so victim should be alive
      expect(updatedVictim.isAlive, isTrue);
      expect(result.report, contains(contains('sent Player dealer home')));

      final updatedDealer = result.players.firstWhere((p) => p.id == 'dealer');
      // Sober does NOT silence, just blocks (which is internal logic) and reports "sent home"
    });

    test('Roofi silences a target', () {
      final roofi = createPlayer(id: 'roofi', roleId: RoleIds.roofi);
      final victim = createPlayer(id: 'victim', roleId: RoleIds.partyAnimal);

      final players = [roofi, victim];
      final log = {
        'roofi_act_roofi': 'victim',
      };
      final dayCount = 1;
      final currentPrivateMessages = <String, List<String>>{};

      final result = GameResolutionLogic.resolveNightActions(
        players,
        log,
        dayCount,
        currentPrivateMessages,
      );

      final updatedVictim = result.players.firstWhere((p) => p.id == 'victim');
      expect(updatedVictim.silencedDay, equals(dayCount));
      expect(result.report, contains(contains('drugged Player victim')));
    });

    test('Roofi blocks the only active dealer', () {
      final roofi = createPlayer(id: 'roofi', roleId: RoleIds.roofi);
      final dealer = createPlayer(id: 'dealer', roleId: RoleIds.dealer, alliance: Team.clubStaff);
      final victim = createPlayer(id: 'victim', roleId: RoleIds.partyAnimal);

      final players = [roofi, dealer, victim];
      final log = {
        'roofi_act_roofi': 'dealer',
        'dealer_act_dealer': 'victim',
      };

      final result = GameResolutionLogic.resolveNightActions(
        players,
        log,
        1,
        {},
      );

      final updatedVictim = result.players.firstWhere((p) => p.id == 'victim');
      // Only dealer was drugged -> blocked -> victim lives
      expect(updatedVictim.isAlive, isTrue);

      final updatedDealer = result.players.firstWhere((p) => p.id == 'dealer');
      expect(updatedDealer.silencedDay, equals(1)); // Also silenced
    });

    test('Roofi does NOT block if multiple dealers exist', () {
      final roofi = createPlayer(id: 'roofi', roleId: RoleIds.roofi);
      final dealer1 = createPlayer(id: 'dealer1', roleId: RoleIds.dealer, alliance: Team.clubStaff);
      final dealer2 = createPlayer(id: 'dealer2', roleId: RoleIds.dealer, alliance: Team.clubStaff);
      final victim = createPlayer(id: 'victim', roleId: RoleIds.partyAnimal);

      final players = [roofi, dealer1, dealer2, victim];
      final log = {
        'roofi_act_roofi': 'dealer1',
        'dealer_act_dealer1': 'victim',
      };

      final result = GameResolutionLogic.resolveNightActions(
        players,
        log,
        1,
        {},
      );

      final updatedVictim = result.players.firstWhere((p) => p.id == 'victim');
      // Not blocked because another dealer exists
      expect(updatedVictim.isAlive, isFalse);
      expect(updatedVictim.deathReason, equals('murder'));

      final updatedDealer1 = result.players.firstWhere((p) => p.id == 'dealer1');
      expect(updatedDealer1.silencedDay, equals(1)); // Still silenced though
    });

    test('Bouncer checks Staff ID', () {
      final bouncer = createPlayer(id: 'bouncer', roleId: RoleIds.bouncer);
      final staff = createPlayer(id: 'staff', roleId: RoleIds.dealer, alliance: Team.clubStaff);

      final players = [bouncer, staff];
      final log = {
        'bouncer_act_bouncer': 'staff',
      };

      final result = GameResolutionLogic.resolveNightActions(players, log, 1, {});

      expect(result.privateMessages['bouncer'], contains(contains('is STAFF')));
    });

    test('Bouncer checks Non-Staff ID', () {
      final bouncer = createPlayer(id: 'bouncer', roleId: RoleIds.bouncer);
      final innocent = createPlayer(id: 'innocent', roleId: RoleIds.partyAnimal, alliance: Team.partyAnimals);

      final players = [bouncer, innocent];
      final log = {
        'bouncer_act_bouncer': 'innocent',
      };

      final result = GameResolutionLogic.resolveNightActions(players, log, 1, {});

      expect(result.privateMessages['bouncer'], contains(contains('is NOT STAFF')));
    });

    test('Dealer kills a victim', () {
      final dealer = createPlayer(id: 'dealer', roleId: RoleIds.dealer, alliance: Team.clubStaff);
      final victim = createPlayer(id: 'victim', roleId: RoleIds.partyAnimal);

      final players = [dealer, victim];
      final log = {
        'dealer_act_dealer': 'victim',
      };

      final result = GameResolutionLogic.resolveNightActions(players, log, 1, {});

      final updatedVictim = result.players.firstWhere((p) => p.id == 'victim');
      expect(updatedVictim.isAlive, isFalse);
      expect(updatedVictim.deathReason, equals('murder'));
      expect(updatedVictim.deathDay, equals(1));
    });

    test('Medic protects a victim', () {
      final medic = createPlayer(id: 'medic', roleId: RoleIds.medic, medicChoice: 'PROTECT_DAILY');
      final dealer = createPlayer(id: 'dealer', roleId: RoleIds.dealer, alliance: Team.clubStaff);
      final victim = createPlayer(id: 'victim', roleId: RoleIds.partyAnimal);

      final players = [medic, dealer, victim];
      final log = {
        'medic_act_medic': 'victim',
        'dealer_act_dealer': 'victim',
      };

      final result = GameResolutionLogic.resolveNightActions(players, log, 1, {});

      final updatedVictim = result.players.firstWhere((p) => p.id == 'victim');
      expect(updatedVictim.isAlive, isTrue);
      expect(result.report, contains(contains('thwarted')));
    });

    test('Medic does not protect if not choosing PROTECT_DAILY', () {
      final medic = createPlayer(id: 'medic', roleId: RoleIds.medic, medicChoice: 'SELF_CARE');
      final dealer = createPlayer(id: 'dealer', roleId: RoleIds.dealer, alliance: Team.clubStaff);
      final victim = createPlayer(id: 'victim', roleId: RoleIds.partyAnimal);

      final players = [medic, dealer, victim];
      final log = {
        'medic_act_medic': 'victim',
        'dealer_act_dealer': 'victim',
      };

      final result = GameResolutionLogic.resolveNightActions(players, log, 1, {});

      final updatedVictim = result.players.firstWhere((p) => p.id == 'victim');
      expect(updatedVictim.isAlive, isFalse);
    });

    test('Second Wind survives first kill', () {
      final dealer = createPlayer(id: 'dealer', roleId: RoleIds.dealer, alliance: Team.clubStaff);
      final sw = createPlayer(id: 'sw', roleId: RoleIds.secondWind);

      final players = [dealer, sw];
      final log = {
        'dealer_act_dealer': 'sw',
      };

      final result = GameResolutionLogic.resolveNightActions(players, log, 1, {});

      final updatedSw = result.players.firstWhere((p) => p.id == 'sw');
      expect(updatedSw.isAlive, isTrue);
      expect(updatedSw.secondWindPendingConversion, isTrue);
      expect(result.report, contains(contains('Second Wind triggered')));
    });

    test('Second Wind dies if already converted', () {
      final dealer = createPlayer(id: 'dealer', roleId: RoleIds.dealer, alliance: Team.clubStaff);
      final sw = createPlayer(id: 'sw', roleId: RoleIds.secondWind, secondWindConverted: true);

      final players = [dealer, sw];
      final log = {
        'dealer_act_dealer': 'sw',
      };

      final result = GameResolutionLogic.resolveNightActions(players, log, 1, {});

      final updatedSw = result.players.firstWhere((p) => p.id == 'sw');
      expect(updatedSw.isAlive, isFalse);
      expect(updatedSw.deathReason, equals('murder'));
    });

    test('Seasoned Drinker loses a life but survives', () {
      final dealer = createPlayer(id: 'dealer', roleId: RoleIds.dealer, alliance: Team.clubStaff);
      final sd = createPlayer(id: 'sd', roleId: RoleIds.seasonedDrinker, lives: 2);

      final players = [dealer, sd];
      final log = {
        'dealer_act_dealer': 'sd',
      };

      final result = GameResolutionLogic.resolveNightActions(players, log, 1, {});

      final updatedSd = result.players.firstWhere((p) => p.id == 'sd');
      expect(updatedSd.isAlive, isTrue);
      expect(updatedSd.lives, equals(1));
      expect(result.report, contains(contains('lost a life but survived')));
    });

    test('Seasoned Drinker dies when out of lives', () {
      final dealer = createPlayer(id: 'dealer', roleId: RoleIds.dealer, alliance: Team.clubStaff);
      final sd = createPlayer(id: 'sd', roleId: RoleIds.seasonedDrinker, lives: 1);

      final players = [dealer, sd];
      final log = {
        'dealer_act_dealer': 'sd',
      };

      final result = GameResolutionLogic.resolveNightActions(players, log, 1, {});

      final updatedSd = result.players.firstWhere((p) => p.id == 'sd');
      expect(updatedSd.isAlive, isFalse);
      expect(updatedSd.deathReason, equals('murder'));
    });
  });
}
