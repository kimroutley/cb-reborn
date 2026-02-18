import '../persistence/role_awards.dart';
import '../role.dart';
import '../role_ids.dart';
import 'role_catalog.dart';

/// Canonical role-award definitions (Phase 1).
///
/// Source-of-truth naming/icon metadata is authored in
/// `AWARDS_NAME_ICON_CATALOG.md` at repo root.
final Map<String, List<RoleAwardDefinition>> roleAwardCatalogByRoleId = {
  for (final role in roleCatalog) role.id: _awardDefinitionsForRole(role),
};

List<RoleAwardDefinition> roleAwardsForRoleId(String roleId) {
  return roleAwardCatalogByRoleId[roleId] ?? const <RoleAwardDefinition>[];
}

List<RoleAwardDefinition> allRoleAwardDefinitions() {
  return roleAwardCatalogByRoleId.values
      .expand((definitions) => definitions)
      .toList(growable: false);
}

RoleAwardDefinition? roleAwardDefinitionById(String awardId) {
  for (final definition in allRoleAwardDefinitions()) {
    if (definition.awardId == awardId) {
      return definition;
    }
  }
  return null;
}

bool hasFinalizedRoleAwards(String roleId) {
  return roleAwardsForRoleId(roleId).isNotEmpty;
}

List<String> rolesMissingAwardDefinitions([List<Role>? roles]) {
  final roleList = roles ?? roleCatalog;
  final missing = <String>[];
  for (final role in roleList) {
    if (!hasFinalizedRoleAwards(role.id)) {
      missing.add(role.id);
    }
  }
  return missing;
}

String _sanitizeAwardSlug(String input) {
  return input.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '_');
}

List<RoleAwardDefinition> _awardDefinitionsForRole(Role role) {
  final seeds = _awardSeedsByRoleId[role.id] ?? const <_RoleAwardSeed>[];
  if (seeds.isEmpty) {
    return _defaultRoleAwardLadder(role);
  }

  return List<RoleAwardDefinition>.generate(
    seeds.length,
    (index) {
      final seed = seeds[index];
      return RoleAwardDefinition(
        awardId:
            '${role.id}_${seed.tier.name}_${_sanitizeAwardSlug(seed.title)}',
        roleId: role.id,
        tier: seed.tier,
        title: seed.title,
        description: _defaultDescription(role, seed.tier, index),
        unlockRule: _defaultUnlockRule(seed.tier, index),
        iconKey: seed.iconKey,
        iconSource: seed.iconSource,
        iconLicense: seed.iconLicense,
      );
    },
    growable: false,
  );
}

Map<String, dynamic> _defaultUnlockRule(RoleAwardTier tier, int index) {
  switch (tier) {
    case RoleAwardTier.rookie:
      return const <String, dynamic>{
        'metric': 'gamesPlayed',
        'minimum': 1,
      };
    case RoleAwardTier.pro:
      return const <String, dynamic>{
        'metric': 'gamesPlayed',
        'minimum': 3,
      };
    case RoleAwardTier.legend:
      return const <String, dynamic>{
        'metric': 'wins',
        'minimum': 1,
      };
    case RoleAwardTier.bonus:
      if (index == 3) {
        return const <String, dynamic>{
          'metric': 'gamesPlayed',
          'minimum': 5,
        };
      }
      return const <String, dynamic>{
        'metric': 'survivals',
        'minimum': 3,
      };
  }
}

String _defaultDescription(Role role, RoleAwardTier tier, int index) {
  switch (tier) {
    case RoleAwardTier.rookie:
      return 'Play 1 game as ${role.name}.';
    case RoleAwardTier.pro:
      return 'Play 3 games as ${role.name}.';
    case RoleAwardTier.legend:
      return 'Win 1 game as ${role.name}.';
    case RoleAwardTier.bonus:
      return index == 3
          ? 'Play 5 games as ${role.name}.'
          : 'Survive 3 games as ${role.name}.';
  }
}

List<RoleAwardDefinition> _defaultRoleAwardLadder(Role role) {
  return <RoleAwardDefinition>[
    RoleAwardDefinition(
      awardId: '${role.id}_rookie_first_shift',
      roleId: role.id,
      tier: RoleAwardTier.rookie,
      title: '${role.name}: First Shift',
      description: 'Play 1 game as ${role.name}.',
      unlockRule: const <String, dynamic>{
        'metric': 'gamesPlayed',
        'minimum': 1,
      },
    ),
    RoleAwardDefinition(
      awardId: '${role.id}_pro_clocked_in',
      roleId: role.id,
      tier: RoleAwardTier.pro,
      title: '${role.name}: Clocked In',
      description: 'Play 3 games as ${role.name}.',
      unlockRule: const <String, dynamic>{
        'metric': 'gamesPlayed',
        'minimum': 3,
      },
    ),
    RoleAwardDefinition(
      awardId: '${role.id}_legend_house_legend',
      roleId: role.id,
      tier: RoleAwardTier.legend,
      title: '${role.name}: House Legend',
      description: 'Win 1 game as ${role.name}.',
      unlockRule: const <String, dynamic>{
        'metric': 'wins',
        'minimum': 1,
      },
    ),
    RoleAwardDefinition(
      awardId: '${role.id}_bonus_overtime',
      roleId: role.id,
      tier: RoleAwardTier.bonus,
      title: '${role.name}: Overtime',
      description: 'Play 5 games as ${role.name}.',
      unlockRule: const <String, dynamic>{
        'metric': 'gamesPlayed',
        'minimum': 5,
      },
    ),
    RoleAwardDefinition(
      awardId: '${role.id}_bonus_after_hours',
      roleId: role.id,
      tier: RoleAwardTier.bonus,
      title: '${role.name}: After Hours',
      description: 'Survive 3 games as ${role.name}.',
      unlockRule: const <String, dynamic>{
        'metric': 'survivals',
        'minimum': 3,
      },
    ),
  ];
}

class _RoleAwardSeed {
  const _RoleAwardSeed({
    required this.tier,
    required this.title,
    required this.iconKey,
    required this.iconSource,
    required this.iconLicense,
  });

  final RoleAwardTier tier;
  final String title;
  final String iconKey;
  final String iconSource;
  final String iconLicense;
}

const Map<String, List<_RoleAwardSeed>> _awardSeedsByRoleId = {
  RoleIds.dealer: <_RoleAwardSeed>[
    _RoleAwardSeed(
      tier: RoleAwardTier.rookie,
      title: 'First Pour',
      iconKey: 'knife',
      iconSource: 'Phosphor',
      iconLicense: 'MIT',
    ),
    _RoleAwardSeed(
      tier: RoleAwardTier.pro,
      title: 'Last Call Hitman',
      iconKey: 'target',
      iconSource: 'Tabler',
      iconLicense: 'MIT',
    ),
    _RoleAwardSeed(
      tier: RoleAwardTier.legend,
      title: 'Velvet Guillotine',
      iconKey: 'swords',
      iconSource: 'Heroicons',
      iconLicense: 'MIT',
    ),
    _RoleAwardSeed(
      tier: RoleAwardTier.bonus,
      title: 'Clean Exit',
      iconKey: 'door-open',
      iconSource: 'Tabler',
      iconLicense: 'MIT',
    ),
    _RoleAwardSeed(
      tier: RoleAwardTier.bonus,
      title: "Dealer's Choice",
      iconKey: 'cards',
      iconSource: 'Phosphor',
      iconLicense: 'MIT',
    ),
  ],
  RoleIds.whore: <_RoleAwardSeed>[
    _RoleAwardSeed(
      tier: RoleAwardTier.rookie,
      title: 'Scapegoat Starter',
      iconKey: 'users-three',
      iconSource: 'Phosphor',
      iconLicense: 'MIT',
    ),
    _RoleAwardSeed(
      tier: RoleAwardTier.pro,
      title: 'Deflection Specialist',
      iconKey: 'arrow-bend-up-left',
      iconSource: 'Tabler',
      iconLicense: 'MIT',
    ),
    _RoleAwardSeed(
      tier: RoleAwardTier.legend,
      title: 'Vote Houdini',
      iconKey: 'sparkles',
      iconSource: 'Heroicons',
      iconLicense: 'MIT',
    ),
    _RoleAwardSeed(
      tier: RoleAwardTier.bonus,
      title: 'One-Time Miracle',
      iconKey: 'hourglass-high',
      iconSource: 'Phosphor',
      iconLicense: 'MIT',
    ),
    _RoleAwardSeed(
      tier: RoleAwardTier.bonus,
      title: 'Puppet Strings',
      iconKey: 'gesture-click',
      iconSource: 'Material Symbols',
      iconLicense: 'Apache-2.0',
    ),
  ],
  RoleIds.silverFox: <_RoleAwardSeed>[
    _RoleAwardSeed(
      tier: RoleAwardTier.rookie,
      title: 'Paper Alibi',
      iconKey: 'badge-check',
      iconSource: 'Heroicons',
      iconLicense: 'MIT',
    ),
    _RoleAwardSeed(
      tier: RoleAwardTier.pro,
      title: 'Untouchable Noon',
      iconKey: 'shield-check',
      iconSource: 'Tabler',
      iconLicense: 'MIT',
    ),
    _RoleAwardSeed(
      tier: RoleAwardTier.legend,
      title: 'Golden Cover Story',
      iconKey: 'star',
      iconSource: 'Phosphor',
      iconLicense: 'MIT',
    ),
    _RoleAwardSeed(
      tier: RoleAwardTier.bonus,
      title: 'Foxfire',
      iconKey: 'flame',
      iconSource: 'Heroicons',
      iconLicense: 'MIT',
    ),
    _RoleAwardSeed(
      tier: RoleAwardTier.bonus,
      title: 'Daylight Immunity',
      iconKey: 'wb-sunny',
      iconSource: 'Material Symbols',
      iconLicense: 'Apache-2.0',
    ),
  ],
  RoleIds.partyAnimal: <_RoleAwardSeed>[
    _RoleAwardSeed(
      tier: RoleAwardTier.rookie,
      title: 'Still Standing',
      iconKey: 'person-simple-run',
      iconSource: 'Phosphor',
      iconLicense: 'MIT',
    ),
    _RoleAwardSeed(
      tier: RoleAwardTier.pro,
      title: 'Crowd Favorite',
      iconKey: 'users',
      iconSource: 'Heroicons',
      iconLicense: 'MIT',
    ),
    _RoleAwardSeed(
      tier: RoleAwardTier.legend,
      title: 'Neon Survivor',
      iconKey: 'bolt',
      iconSource: 'Tabler',
      iconLicense: 'MIT',
    ),
    _RoleAwardSeed(
      tier: RoleAwardTier.bonus,
      title: 'No Ability, No Problem',
      iconKey: 'smiley',
      iconSource: 'Phosphor',
      iconLicense: 'MIT',
    ),
    _RoleAwardSeed(
      tier: RoleAwardTier.bonus,
      title: 'Dance Floor General',
      iconKey: 'music-note',
      iconSource: 'Material Symbols',
      iconLicense: 'Apache-2.0',
    ),
  ],
  RoleIds.medic: <_RoleAwardSeed>[
    _RoleAwardSeed(
      tier: RoleAwardTier.rookie,
      title: 'Pulse Check',
      iconKey: 'heartbeat',
      iconSource: 'Phosphor',
      iconLicense: 'MIT',
    ),
    _RoleAwardSeed(
      tier: RoleAwardTier.pro,
      title: 'Night Shift Nurse',
      iconKey: 'medical-cross',
      iconSource: 'Tabler',
      iconLicense: 'MIT',
    ),
    _RoleAwardSeed(
      tier: RoleAwardTier.legend,
      title: 'Defibrillator Deity',
      iconKey: 'heart-plus',
      iconSource: 'Heroicons',
      iconLicense: 'MIT',
    ),
    _RoleAwardSeed(
      tier: RoleAwardTier.bonus,
      title: 'Surgical Save',
      iconKey: 'bandage',
      iconSource: 'Phosphor',
      iconLicense: 'MIT',
    ),
    _RoleAwardSeed(
      tier: RoleAwardTier.bonus,
      title: 'Miracle Worker',
      iconKey: 'ecg-heart',
      iconSource: 'Tabler',
      iconLicense: 'MIT',
    ),
  ],
  RoleIds.bouncer: <_RoleAwardSeed>[
    _RoleAwardSeed(
      tier: RoleAwardTier.rookie,
      title: 'ID Please',
      iconKey: 'identification',
      iconSource: 'Heroicons',
      iconLicense: 'MIT',
    ),
    _RoleAwardSeed(
      tier: RoleAwardTier.pro,
      title: 'Door Policy',
      iconKey: 'shield',
      iconSource: 'Phosphor',
      iconLicense: 'MIT',
    ),
    _RoleAwardSeed(
      tier: RoleAwardTier.legend,
      title: 'Human Lie Detector',
      iconKey: 'scan-eye',
      iconSource: 'Material Symbols',
      iconLicense: 'Apache-2.0',
    ),
    _RoleAwardSeed(
      tier: RoleAwardTier.bonus,
      title: 'Wristband Authority',
      iconKey: 'ticket',
      iconSource: 'Tabler',
      iconLicense: 'MIT',
    ),
    _RoleAwardSeed(
      tier: RoleAwardTier.bonus,
      title: 'Backroom Intel',
      iconKey: 'binoculars',
      iconSource: 'Tabler',
      iconLicense: 'MIT',
    ),
  ],
  RoleIds.roofi: <_RoleAwardSeed>[
    _RoleAwardSeed(
      tier: RoleAwardTier.rookie,
      title: 'Silent Sip',
      iconKey: 'glass-water',
      iconSource: 'Material Symbols',
      iconLicense: 'Apache-2.0',
    ),
    _RoleAwardSeed(
      tier: RoleAwardTier.pro,
      title: 'Mute Button',
      iconKey: 'microphone-slash',
      iconSource: 'Heroicons',
      iconLicense: 'MIT',
    ),
    _RoleAwardSeed(
      tier: RoleAwardTier.legend,
      title: 'Paralysis Protocol',
      iconKey: 'hand-stop',
      iconSource: 'Tabler',
      iconLicense: 'MIT',
    ),
    _RoleAwardSeed(
      tier: RoleAwardTier.bonus,
      title: 'Kill Switch',
      iconKey: 'toggle-left',
      iconSource: 'Phosphor',
      iconLicense: 'MIT',
    ),
    _RoleAwardSeed(
      tier: RoleAwardTier.bonus,
      title: 'Quiet Riot',
      iconKey: 'bell-slash',
      iconSource: 'Heroicons',
      iconLicense: 'MIT',
    ),
  ],
  RoleIds.sober: <_RoleAwardSeed>[
    _RoleAwardSeed(
      tier: RoleAwardTier.rookie,
      title: 'Cut Off',
      iconKey: 'wine',
      iconSource: 'Material Symbols',
      iconLicense: 'Apache-2.0',
    ),
    _RoleAwardSeed(
      tier: RoleAwardTier.pro,
      title: 'Safe Ride Home',
      iconKey: 'car',
      iconSource: 'Phosphor',
      iconLicense: 'MIT',
    ),
    _RoleAwardSeed(
      tier: RoleAwardTier.legend,
      title: 'Designated Savior',
      iconKey: 'shield-half',
      iconSource: 'Tabler',
      iconLicense: 'MIT',
    ),
    _RoleAwardSeed(
      tier: RoleAwardTier.bonus,
      title: 'Dry Night',
      iconKey: 'moon-stars',
      iconSource: 'Phosphor',
      iconLicense: 'MIT',
    ),
    _RoleAwardSeed(
      tier: RoleAwardTier.bonus,
      title: 'Hard Stop',
      iconKey: 'do-not-disturb-on',
      iconSource: 'Material Symbols',
      iconLicense: 'Apache-2.0',
    ),
  ],
  RoleIds.wallflower: <_RoleAwardSeed>[
    _RoleAwardSeed(
      tier: RoleAwardTier.rookie,
      title: 'Nosy Neighbor',
      iconKey: 'eye',
      iconSource: 'Phosphor',
      iconLicense: 'MIT',
    ),
    _RoleAwardSeed(
      tier: RoleAwardTier.pro,
      title: 'Professional Snitch',
      iconKey: 'binoculars',
      iconSource: 'Tabler',
      iconLicense: 'MIT',
    ),
    _RoleAwardSeed(
      tier: RoleAwardTier.legend,
      title: 'Night Shift Manager',
      iconKey: 'visibility',
      iconSource: 'Material Symbols',
      iconLicense: 'Apache-2.0',
    ),
    _RoleAwardSeed(
      tier: RoleAwardTier.bonus,
      title: 'Wrong Place, Right Time',
      iconKey: 'shield-check',
      iconSource: 'Heroicons',
      iconLicense: 'MIT',
    ),
    _RoleAwardSeed(
      tier: RoleAwardTier.bonus,
      title: 'Receipts',
      iconKey: 'clipboard-list',
      iconSource: 'Tabler',
      iconLicense: 'MIT',
    ),
  ],
  RoleIds.allyCat: <_RoleAwardSeed>[
    _RoleAwardSeed(
      tier: RoleAwardTier.rookie,
      title: 'Nine Lives, One Braincell',
      iconKey: 'cat',
      iconSource: 'Material Symbols',
      iconLicense: 'Apache-2.0',
    ),
    _RoleAwardSeed(
      tier: RoleAwardTier.pro,
      title: 'Meow Intelligence',
      iconKey: 'chat-bubble-left-right',
      iconSource: 'Heroicons',
      iconLicense: 'MIT',
    ),
    _RoleAwardSeed(
      tier: RoleAwardTier.legend,
      title: 'Feline Informant',
      iconKey: 'paw-print',
      iconSource: 'Phosphor',
      iconLicense: 'MIT',
    ),
    _RoleAwardSeed(
      tier: RoleAwardTier.bonus,
      title: 'Landed on Feet',
      iconKey: 'arrow-down-circle',
      iconSource: 'Tabler',
      iconLicense: 'MIT',
    ),
    _RoleAwardSeed(
      tier: RoleAwardTier.bonus,
      title: 'Purrfect Read',
      iconKey: 'eye-check',
      iconSource: 'Tabler',
      iconLicense: 'MIT',
    ),
  ],
  RoleIds.minor: <_RoleAwardSeed>[
    _RoleAwardSeed(
      tier: RoleAwardTier.rookie,
      title: 'Fake ID Energy',
      iconKey: 'id-card',
      iconSource: 'Tabler',
      iconLicense: 'MIT',
    ),
    _RoleAwardSeed(
      tier: RoleAwardTier.pro,
      title: 'Protected by Policy',
      iconKey: 'shield-lock',
      iconSource: 'Heroicons',
      iconLicense: 'MIT',
    ),
    _RoleAwardSeed(
      tier: RoleAwardTier.legend,
      title: 'Untouchable Until Checked',
      iconKey: 'verified-user',
      iconSource: 'Material Symbols',
      iconLicense: 'Apache-2.0',
    ),
    _RoleAwardSeed(
      tier: RoleAwardTier.bonus,
      title: 'Too Young to Die',
      iconKey: 'baby',
      iconSource: 'Phosphor',
      iconLicense: 'MIT',
    ),
    _RoleAwardSeed(
      tier: RoleAwardTier.bonus,
      title: 'Plot Armor',
      iconKey: 'shield-star',
      iconSource: 'Tabler',
      iconLicense: 'MIT',
    ),
  ],
  RoleIds.seasonedDrinker: <_RoleAwardSeed>[
    _RoleAwardSeed(
      tier: RoleAwardTier.rookie,
      title: 'First Hangover',
      iconKey: 'beer-bottle',
      iconSource: 'Phosphor',
      iconLicense: 'MIT',
    ),
    _RoleAwardSeed(
      tier: RoleAwardTier.pro,
      title: 'Built Different',
      iconKey: 'biceps-flexed',
      iconSource: 'Material Symbols',
      iconLicense: 'Apache-2.0',
    ),
    _RoleAwardSeed(
      tier: RoleAwardTier.legend,
      title: 'Bottomless Constitution',
      iconKey: 'battery-full',
      iconSource: 'Heroicons',
      iconLicense: 'MIT',
    ),
    _RoleAwardSeed(
      tier: RoleAwardTier.bonus,
      title: 'Last One Upright',
      iconKey: 'person-standing',
      iconSource: 'Material Symbols',
      iconLicense: 'Apache-2.0',
    ),
    _RoleAwardSeed(
      tier: RoleAwardTier.bonus,
      title: 'Iron Liver',
      iconKey: 'shield-plus',
      iconSource: 'Tabler',
      iconLicense: 'MIT',
    ),
  ],
  RoleIds.lightweight: <_RoleAwardSeed>[
    _RoleAwardSeed(
      tier: RoleAwardTier.rookie,
      title: 'Taboo Trouble',
      iconKey: 'warning',
      iconSource: 'Material Symbols',
      iconLicense: 'Apache-2.0',
    ),
    _RoleAwardSeed(
      tier: RoleAwardTier.pro,
      title: 'Name Minefield',
      iconKey: 'bomb',
      iconSource: 'Tabler',
      iconLicense: 'MIT',
    ),
    _RoleAwardSeed(
      tier: RoleAwardTier.legend,
      title: 'Verbal Tightrope',
      iconKey: 'wave-sine',
      iconSource: 'Phosphor',
      iconLicense: 'MIT',
    ),
    _RoleAwardSeed(
      tier: RoleAwardTier.bonus,
      title: 'Lips Sealed',
      iconKey: 'mouth',
      iconSource: 'Material Symbols',
      iconLicense: 'Apache-2.0',
    ),
    _RoleAwardSeed(
      tier: RoleAwardTier.bonus,
      title: 'One Wrong Name',
      iconKey: 'x-circle',
      iconSource: 'Heroicons',
      iconLicense: 'MIT',
    ),
  ],
  RoleIds.teaSpiller: <_RoleAwardSeed>[
    _RoleAwardSeed(
      tier: RoleAwardTier.rookie,
      title: 'Hot Gossip',
      iconKey: 'teapot',
      iconSource: 'Material Symbols',
      iconLicense: 'Apache-2.0',
    ),
    _RoleAwardSeed(
      tier: RoleAwardTier.pro,
      title: 'Final Sip Reveal',
      iconKey: 'eye-search',
      iconSource: 'Tabler',
      iconLicense: 'MIT',
    ),
    _RoleAwardSeed(
      tier: RoleAwardTier.legend,
      title: 'Scalding Truth',
      iconKey: 'fire',
      iconSource: 'Heroicons',
      iconLicense: 'MIT',
    ),
    _RoleAwardSeed(
      tier: RoleAwardTier.bonus,
      title: 'Spill on Exit',
      iconKey: 'door-exit',
      iconSource: 'Tabler',
      iconLicense: 'MIT',
    ),
    _RoleAwardSeed(
      tier: RoleAwardTier.bonus,
      title: 'Receipt Queen',
      iconKey: 'receipt',
      iconSource: 'Material Symbols',
      iconLicense: 'Apache-2.0',
    ),
  ],
  RoleIds.predator: <_RoleAwardSeed>[
    _RoleAwardSeed(
      tier: RoleAwardTier.rookie,
      title: 'Cornered Bite',
      iconKey: 'teeth',
      iconSource: 'Material Symbols',
      iconLicense: 'Apache-2.0',
    ),
    _RoleAwardSeed(
      tier: RoleAwardTier.pro,
      title: 'Retaliation Ready',
      iconKey: 'crosshair',
      iconSource: 'Phosphor',
      iconLicense: 'MIT',
    ),
    _RoleAwardSeed(
      tier: RoleAwardTier.legend,
      title: 'Deadly Last Word',
      iconKey: 'skull',
      iconSource: 'Heroicons',
      iconLicense: 'MIT',
    ),
    _RoleAwardSeed(
      tier: RoleAwardTier.bonus,
      title: 'If I Go, You Go',
      iconKey: 'arrows-exchange',
      iconSource: 'Tabler',
      iconLicense: 'MIT',
    ),
    _RoleAwardSeed(
      tier: RoleAwardTier.bonus,
      title: 'Apex on Exile',
      iconKey: 'mountain',
      iconSource: 'Phosphor',
      iconLicense: 'MIT',
    ),
  ],
  RoleIds.dramaQueen: <_RoleAwardSeed>[
    _RoleAwardSeed(
      tier: RoleAwardTier.rookie,
      title: 'Scene Starter',
      iconKey: 'masks-theater',
      iconSource: 'Phosphor',
      iconLicense: 'MIT',
    ),
    _RoleAwardSeed(
      tier: RoleAwardTier.pro,
      title: 'Role Swap Scandal',
      iconKey: 'switch-horizontal',
      iconSource: 'Heroicons',
      iconLicense: 'MIT',
    ),
    _RoleAwardSeed(
      tier: RoleAwardTier.legend,
      title: 'Curtain Call Chaos',
      iconKey: 'theaters',
      iconSource: 'Material Symbols',
      iconLicense: 'Apache-2.0',
    ),
    _RoleAwardSeed(
      tier: RoleAwardTier.bonus,
      title: 'Vendetta Vogue',
      iconKey: 'sparkles',
      iconSource: 'Heroicons',
      iconLicense: 'MIT',
    ),
    _RoleAwardSeed(
      tier: RoleAwardTier.bonus,
      title: 'Encore Betrayal',
      iconKey: 'repeat',
      iconSource: 'Tabler',
      iconLicense: 'MIT',
    ),
  ],
  RoleIds.bartender: <_RoleAwardSeed>[
    _RoleAwardSeed(
      tier: RoleAwardTier.rookie,
      title: 'First Mix',
      iconKey: 'martini',
      iconSource: 'Tabler',
      iconLicense: 'MIT',
    ),
    _RoleAwardSeed(
      tier: RoleAwardTier.pro,
      title: 'Alignment on the Rocks',
      iconKey: 'balance-scale',
      iconSource: 'Heroicons',
      iconLicense: 'MIT',
    ),
    _RoleAwardSeed(
      tier: RoleAwardTier.legend,
      title: 'Master of Pairings',
      iconKey: 'glass-cocktail',
      iconSource: 'Phosphor',
      iconLicense: 'MIT',
    ),
    _RoleAwardSeed(
      tier: RoleAwardTier.bonus,
      title: 'Shaken, Not Fooled',
      iconKey: 'shake',
      iconSource: 'Material Symbols',
      iconLicense: 'Apache-2.0',
    ),
    _RoleAwardSeed(
      tier: RoleAwardTier.bonus,
      title: 'House Special Intel',
      iconKey: 'flask-conical',
      iconSource: 'Material Symbols',
      iconLicense: 'Apache-2.0',
    ),
  ],
  RoleIds.messyBitch: <_RoleAwardSeed>[
    _RoleAwardSeed(
      tier: RoleAwardTier.rookie,
      title: 'Rumour Starter Pack',
      iconKey: 'megaphone',
      iconSource: 'Phosphor',
      iconLicense: 'MIT',
    ),
    _RoleAwardSeed(
      tier: RoleAwardTier.pro,
      title: 'Whisper Network',
      iconKey: 'messages',
      iconSource: 'Tabler',
      iconLicense: 'MIT',
    ),
    _RoleAwardSeed(
      tier: RoleAwardTier.legend,
      title: 'Chaos Curator',
      iconKey: 'storm',
      iconSource: 'Heroicons',
      iconLicense: 'MIT',
    ),
    _RoleAwardSeed(
      tier: RoleAwardTier.bonus,
      title: 'Everybody Heard',
      iconKey: 'volume-2',
      iconSource: 'Heroicons',
      iconLicense: 'MIT',
    ),
    _RoleAwardSeed(
      tier: RoleAwardTier.bonus,
      title: 'Rumour Mill Maxed',
      iconKey: 'hub',
      iconSource: 'Material Symbols',
      iconLicense: 'Apache-2.0',
    ),
  ],
  RoleIds.clubManager: <_RoleAwardSeed>[
    _RoleAwardSeed(
      tier: RoleAwardTier.rookie,
      title: 'Floor Check',
      iconKey: 'clipboard-check',
      iconSource: 'Tabler',
      iconLicense: 'MIT',
    ),
    _RoleAwardSeed(
      tier: RoleAwardTier.pro,
      title: 'Eyes Everywhere',
      iconKey: 'eye',
      iconSource: 'Phosphor',
      iconLicense: 'MIT',
    ),
    _RoleAwardSeed(
      tier: RoleAwardTier.legend,
      title: "Owner's Ledger",
      iconKey: 'book-open',
      iconSource: 'Heroicons',
      iconLicense: 'MIT',
    ),
    _RoleAwardSeed(
      tier: RoleAwardTier.bonus,
      title: 'Self-Preservation',
      iconKey: 'life-buoy',
      iconSource: 'Phosphor',
      iconLicense: 'MIT',
    ),
    _RoleAwardSeed(
      tier: RoleAwardTier.bonus,
      title: 'After-Hours Audit',
      iconKey: 'schedule',
      iconSource: 'Material Symbols',
      iconLicense: 'Apache-2.0',
    ),
  ],
  RoleIds.clinger: <_RoleAwardSeed>[
    _RoleAwardSeed(
      tier: RoleAwardTier.rookie,
      title: 'Velcro Soul',
      iconKey: 'link',
      iconSource: 'Heroicons',
      iconLicense: 'MIT',
    ),
    _RoleAwardSeed(
      tier: RoleAwardTier.pro,
      title: 'Ride or Die',
      iconKey: 'heart-handshake',
      iconSource: 'Material Symbols',
      iconLicense: 'Apache-2.0',
    ),
    _RoleAwardSeed(
      tier: RoleAwardTier.legend,
      title: 'Attack Dog Unleashed',
      iconKey: 'dog',
      iconSource: 'Material Symbols',
      iconLicense: 'Apache-2.0',
    ),
    _RoleAwardSeed(
      tier: RoleAwardTier.bonus,
      title: 'Bonded Fate',
      iconKey: 'infinity',
      iconSource: 'Tabler',
      iconLicense: 'MIT',
    ),
    _RoleAwardSeed(
      tier: RoleAwardTier.bonus,
      title: 'Breakup Violence',
      iconKey: 'heart-break',
      iconSource: 'Tabler',
      iconLicense: 'MIT',
    ),
  ],
  RoleIds.secondWind: <_RoleAwardSeed>[
    _RoleAwardSeed(
      tier: RoleAwardTier.rookie,
      title: 'Not Dead Yet',
      iconKey: 'heartbeat',
      iconSource: 'Phosphor',
      iconLicense: 'MIT',
    ),
    _RoleAwardSeed(
      tier: RoleAwardTier.pro,
      title: 'Conversion Pending',
      iconKey: 'refresh',
      iconSource: 'Heroicons',
      iconLicense: 'MIT',
    ),
    _RoleAwardSeed(
      tier: RoleAwardTier.legend,
      title: 'Twice-Born Menace',
      iconKey: 'autorenew',
      iconSource: 'Material Symbols',
      iconLicense: 'Apache-2.0',
    ),
    _RoleAwardSeed(
      tier: RoleAwardTier.bonus,
      title: 'Refused the Offer',
      iconKey: 'hand-raised',
      iconSource: 'Heroicons',
      iconLicense: 'MIT',
    ),
    _RoleAwardSeed(
      tier: RoleAwardTier.bonus,
      title: 'Back from Blackout',
      iconKey: 'sunrise',
      iconSource: 'Tabler',
      iconLicense: 'MIT',
    ),
  ],
  RoleIds.creep: <_RoleAwardSeed>[
    _RoleAwardSeed(
      tier: RoleAwardTier.rookie,
      title: 'Shadow Copy',
      iconKey: 'copy',
      iconSource: 'Heroicons',
      iconLicense: 'MIT',
    ),
    _RoleAwardSeed(
      tier: RoleAwardTier.pro,
      title: 'Mimic Mode',
      iconKey: 'user-circle',
      iconSource: 'Phosphor',
      iconLicense: 'MIT',
    ),
    _RoleAwardSeed(
      tier: RoleAwardTier.legend,
      title: 'Inheritance Predator',
      iconKey: 'dna',
      iconSource: 'Tabler',
      iconLicense: 'MIT',
    ),
    _RoleAwardSeed(
      tier: RoleAwardTier.bonus,
      title: 'Night Zero Stalker',
      iconKey: 'moon',
      iconSource: 'Heroicons',
      iconLicense: 'MIT',
    ),
    _RoleAwardSeed(
      tier: RoleAwardTier.bonus,
      title: 'Identity Thief',
      iconKey: 'person-swap',
      iconSource: 'Material Symbols',
      iconLicense: 'Apache-2.0',
    ),
  ],
};
