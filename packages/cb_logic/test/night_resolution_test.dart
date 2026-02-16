import 'package:cb_logic/src/game_resolution_logic.dart';
import 'package:cb_models/cb_models.dart';
import 'package:flutter_test/flutter_test.dart';

// Helpers
Role _role(
  String id, {
  Team alliance = Team.partyAnimals,
  int priority = 100,
}) =>
    Role(
      id: id,
      name: id.toUpperCase(),
      alliance: alliance,
      type: 'Test',
      description: 'Test role',
      nightPriority: priority,
      assetPath: '',
      colorHex: '#FF0000',
    );

Player _player(String name, Role role, {Team? alliance}) => Player(
      id: name.toLowerCase(),
      name: name,
      role: role,
      alliance: alliance ?? role.alliance,
    );

void main() {
  group('NightResolutionLogic', () {
    test('Dealer kills target', () {
      final dealer = _player('Dealer', _role(RoleIds.dealer, alliance: Team.clubStaff));
      final victim = _player('Victim', _role(RoleIds.partyAnimal));
      final players = [dealer, victim];

      final log = {
        'dealer_act_${dealer.id}_1': victim.id,
      };

      final result = GameResolutionLogic.resolveNightActions(
        players,
        log,
        1,
        {},
      );

      final updatedVictim = result.players.firstWhere((p) => p.id == victim.id);
      expect(updatedVictim.isAlive, false);
      expect(updatedVictim.deathReason, 'murder');
      expect(result.report.any((s) => s.contains('butchered')), true);
    });

    test('Medic protects target', () {
      final dealer = _player('Dealer', _role(RoleIds.dealer, alliance: Team.clubStaff));
      final medic = _player('Medic', _role(RoleIds.medic)).copyWith(medicChoice: 'PROTECT_DAILY');
      final victim = _player('Victim', _role(RoleIds.partyAnimal));
      final players = [dealer, medic, victim];

      final log = {
        'dealer_act_${dealer.id}_1': victim.id,
        'medic_act_${medic.id}_1': victim.id,
      };

      final result = GameResolutionLogic.resolveNightActions(
        players,
        log,
        1,
        {},
      );

      final updatedVictim = result.players.firstWhere((p) => p.id == victim.id);
      expect(updatedVictim.isAlive, true);
      expect(result.report.any((s) => s.contains('thwarted')), true);
    });

    test('Sober blocks action', () {
      final dealer = _player('Dealer', _role(RoleIds.dealer, alliance: Team.clubStaff));
      final sober = _player('Sober', _role(RoleIds.sober));
      final victim = _player('Victim', _role(RoleIds.partyAnimal));
      final players = [dealer, sober, victim];

      final log = {
        'dealer_act_${dealer.id}_1': victim.id,
        'sober_act_${sober.id}_1': dealer.id,
      };

      final result = GameResolutionLogic.resolveNightActions(
        players,
        log,
        1,
        {},
      );

      final updatedVictim = result.players.firstWhere((p) => p.id == victim.id);
      expect(updatedVictim.isAlive, true); // Dealer blocked
      expect(result.report.any((s) => s.contains('Sober blocked Dealer')), true);
    });

    test('Roofi blocks single dealer', () {
      final dealer = _player('Dealer', _role(RoleIds.dealer, alliance: Team.clubStaff));
      final roofi = _player('Roofi', _role(RoleIds.roofi));
      final victim = _player('Victim', _role(RoleIds.partyAnimal));
      final players = [dealer, roofi, victim];

      final log = {
        'dealer_act_${dealer.id}_1': victim.id,
        'roofi_act_${roofi.id}_1': dealer.id,
      };

      final result = GameResolutionLogic.resolveNightActions(
        players,
        log,
        1,
        {},
      );

      final updatedVictim = result.players.firstWhere((p) => p.id == victim.id);
      expect(updatedVictim.isAlive, false); // Roofi now silences, not blocks kill
      expect(result.report.any((s) => s.contains('silenced Dealer')), true);

      final updatedDealer = result.players.firstWhere((p) => p.id == dealer.id);
      expect(updatedDealer.silencedDay, 1);
    });

    test('Roofi does NOT block if multiple dealers', () {
      final dealer1 = _player('Dealer1', _role(RoleIds.dealer, alliance: Team.clubStaff));
      final dealer2 = _player('Dealer2', _role(RoleIds.dealer, alliance: Team.clubStaff));
      final roofi = _player('Roofi', _role(RoleIds.roofi));
      final victim = _player('Victim', _role(RoleIds.partyAnimal));
      final players = [dealer1, dealer2, roofi, victim];

      final log = {
        'dealer_act_${dealer1.id}_1': victim.id,
        'roofi_act_${roofi.id}_1': dealer1.id,
      };

      final result = GameResolutionLogic.resolveNightActions(
        players,
        log,
        1,
        {},
      );

      final updatedVictim = result.players.firstWhere((p) => p.id == victim.id);
      expect(updatedVictim.isAlive, false); // Not blocked because another dealer exists

      final updatedDealer1 = result.players.firstWhere((p) => p.id == dealer1.id);
      expect(updatedDealer1.silencedDay, 1);
    });

    test('Bouncer checks ID', () {
      final bouncer = _player('Bouncer', _role(RoleIds.bouncer));
      final dealer = _player('Dealer', _role(RoleIds.dealer, alliance: Team.clubStaff));
      final players = [bouncer, dealer];

      final log = {
        'bouncer_act_${bouncer.id}_1': dealer.id,
      };

      final result = GameResolutionLogic.resolveNightActions(
        players,
        log,
        1,
        {},
      );

      expect(result.privateMessages[bouncer.id]!.first, contains('STAFF'));
      expect(result.report.any((s) => s.contains('Bouncer checked Dealer')), true);
    });

    test('Club Manager reveals role and marks target as sighted', () {
      final manager = _player('Manager', _role(RoleIds.clubManager));
      final target = _player('Target', _role(RoleIds.partyAnimal));
      final players = [manager, target];

      final log = {
        'club_manager_act_${manager.id}_1': target.id,
      };

      final result = GameResolutionLogic.resolveNightActions(
        players,
        log,
        1,
        {},
      );

      final updatedTarget = result.players.firstWhere((p) => p.id == target.id);
      expect(updatedTarget.sightedByClubManager, true);
      expect(result.privateMessages[manager.id]!.first, contains(target.role.name));
      expect(result.report.any((s) => s.contains('Manager file-checked Target')), true);
    });

    test('Lightweight applies taboo name to all alive players', () {
      final lightweight = _player('Lightweight', _role(RoleIds.lightweight));
      final target = _player('Target', _role(RoleIds.partyAnimal));
      final bystander = _player('Bystander', _role(RoleIds.partyAnimal));
      final deadPlayer =
          _player('Dead', _role(RoleIds.partyAnimal)).copyWith(isAlive: false);
      final players = [lightweight, target, bystander, deadPlayer];

      final log = {
        'lightweight_act_${lightweight.id}_1': target.id,
      };

      final result = GameResolutionLogic.resolveNightActions(
        players,
        log,
        1,
        {},
      );

      final updatedLightweight =
          result.players.firstWhere((p) => p.id == lightweight.id);
      final updatedTarget = result.players.firstWhere((p) => p.id == target.id);
      final updatedBystander =
          result.players.firstWhere((p) => p.id == bystander.id);
      final updatedDead = result.players.firstWhere((p) => p.id == deadPlayer.id);

      expect(updatedLightweight.tabooNames, contains(target.name));
      expect(updatedTarget.tabooNames, contains(target.name));
      expect(updatedBystander.tabooNames, contains(target.name));
      expect(updatedDead.tabooNames, isNot(contains(target.name)));

      expect(result.privateMessages[lightweight.id]!.first,
          contains('banned ${target.name}\'s name'));
      expect(result.report.any((s) => s.contains('LW banned ${target.name}\'s name')),
          true);
      expect(result.teasers, contains('A name is now FORBIDDEN.'));
    });

    test('Second Wind survives once', () {
       final dealer = _player('Dealer', _role(RoleIds.dealer, alliance: Team.clubStaff));
       final sw = _player('SW', _role(RoleIds.secondWind));
       final players = [dealer, sw];

       final log = {
         'dealer_act_${dealer.id}_1': sw.id,
       };

       final result = GameResolutionLogic.resolveNightActions(
         players,
         log,
         1,
         {},
       );

       final updatedSW = result.players.firstWhere((p) => p.id == sw.id);
       expect(updatedSW.isAlive, true);
       expect(updatedSW.secondWindPendingConversion, true);
       expect(result.report.any((s) => s.contains('Second Wind triggered')), true);
    });

    test('Seasoned Drinker loses life', () {
       final dealer = _player('Dealer', _role(RoleIds.dealer, alliance: Team.clubStaff));
       final sd = _player('SD', _role(RoleIds.seasonedDrinker)).copyWith(lives: 2);
       final players = [dealer, sd];

       final log = {
         'dealer_act_${dealer.id}_1': sd.id,
       };

       final result = GameResolutionLogic.resolveNightActions(
         players,
         log,
         1,
         {},
       );

       final updatedSD = result.players.firstWhere((p) => p.id == sd.id);
       expect(updatedSD.isAlive, true);
       expect(updatedSD.lives, 1);
       expect(result.report.any((s) => s.contains('lost a life')), true);
    });

    test('Seasoned Drinker dies if 1 life', () {
       final dealer = _player('Dealer', _role(RoleIds.dealer, alliance: Team.clubStaff));
       final sd = _player('SD', _role(RoleIds.seasonedDrinker)).copyWith(lives: 1);
       final players = [dealer, sd];

       final log = {
         'dealer_act_${dealer.id}_1': sd.id,
       };

       final result = GameResolutionLogic.resolveNightActions(
         players,
         log,
         1,
         {},
       );

       final updatedSD = result.players.firstWhere((p) => p.id == sd.id);
       expect(updatedSD.isAlive, false);
    });
  });
}
