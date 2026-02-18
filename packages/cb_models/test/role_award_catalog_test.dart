import 'package:cb_models/cb_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('every canonical role has a full baseline award ladder', () {
    final missing = rolesMissingAwardDefinitions();
    expect(missing, isEmpty);

    for (final role in roleCatalog) {
      final definitions = roleAwardsForRoleId(role.id);
      expect(definitions.length, 5);
      expect(definitions.any((d) => d.tier == RoleAwardTier.rookie), true);
      expect(definitions.any((d) => d.tier == RoleAwardTier.pro), true);
      expect(definitions.any((d) => d.tier == RoleAwardTier.legend), true);
      expect(
        definitions.where((d) => d.tier == RoleAwardTier.bonus).length,
        2,
      );
      expect(definitions.every((d) => d.roleId == role.id), true);
    }
  });

  test('award id lookup resolves generated definitions', () {
    final sampleRole = roleCatalog.first;
    final definition = roleAwardsForRoleId(sampleRole.id).first;
    final lookedUp = roleAwardDefinitionById(definition.awardId);

    expect(lookedUp, isNotNull);
    expect(lookedUp!.awardId, definition.awardId);
    expect(lookedUp.roleId, sampleRole.id);
  });
}
