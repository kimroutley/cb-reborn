import 'package:cb_models/cb_models.dart';
import 'death_handler.dart';
import '../night_resolution_context.dart';

class MinorProtectionHandler implements DeathHandler {
  @override
  bool handle(NightResolutionContext context, Player victim) {
    if (victim.role.id != RoleIds.minor || victim.minorHasBeenIDd) {
      return false;
    }

    final targetedByDealer = context.dealerAttacks.values.contains(victim.id);
    if (!targetedByDealer) {
      return false;
    }

    context.report.add(
      'Minor ${victim.name} was targeted, but their identity shield held.',
    );
    context.teasers.add('A suspiciously young patron slipped away unharmed.');
    return true; // Prevent default death
  }
}
