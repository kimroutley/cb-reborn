import 'package:cb_models/cb_models.dart';
import 'death_handler.dart';
import '../night_resolution_context.dart';

class SecondWindHandler implements DeathHandler {
  @override
  bool handle(NightResolutionContext context, Player victim) {
    final targetedByDealer = context.dealerAttacks.values.contains(victim.id);
    if (victim.role.id == RoleIds.secondWind &&
        !victim.secondWindConverted &&
        targetedByDealer) {
      context.updatePlayer(victim.copyWith(secondWindPendingConversion: true));
      context.report.add('Second Wind triggered for ${victim.name}.');
      context.teasers.add('Someone survived a lethal encounter.');
      return true; // Prevent default death
    }
    return false;
  }
}
