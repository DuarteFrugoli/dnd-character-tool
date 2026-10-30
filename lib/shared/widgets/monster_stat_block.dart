import '../../core/units/rules_text_provider.dart';
import 'package:dnd_character_tool/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/units/unit_formatter.dart';
import '../../core/units/unit_system_provider.dart';
import '../../data/datasources/srd/srd_i18n_service.dart';
import '../../data/datasources/srd/srd_monster.dart';

void showMonsterStatBlockSheet(
  BuildContext context,
  SrdMonster monster,
  SrdI18nService i18n,
) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    builder: (_) => DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.85,
      minChildSize: 0.4,
      maxChildSize: 1,
      builder: (_, controller) => SingleChildScrollView(
        controller: controller,
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        child: MonsterStatBlock(monster: monster, i18n: i18n),
      ),
    ),
  );
}

/// "Medium Beast, Unaligned" or "Medium Swarm of Tiny Beasts, Unaligned".
String monsterSizeTypeLine(AppLocalizations l10n, SrdMonster monster) {
  final size = monster.sizes.map((s) => monsterSizeName(l10n, s)).join(l10n.monsterSizeOr);
  final type = monster.isSwarm
      ? l10n.monsterSwarmOfBeasts(monsterSizeName(l10n, monster.swarmMemberSize!))
      : monster.isBeast
      ? l10n.monsterTypeBeast
      : monster.type;
  return l10n.monsterSizeType(size, type);
}

String monsterSizeName(AppLocalizations l10n, String size) => switch (size) {
  'tiny' => l10n.monsterSizeTiny,
  'small' => l10n.monsterSizeSmall,
  'medium' => l10n.monsterSizeMedium,
  'large' => l10n.monsterSizeLarge,
  'huge' => l10n.monsterSizeHuge,
  'gargantuan' => l10n.monsterSizeGargantuan,
  _ => size,
};

/// "30 ft, Climb 30 ft, Fly 60 ft (hover)".
String monsterSpeedLine(
  AppLocalizations l10n,
  SrdMonsterSpeed speed,
  UnitSystem units,
) {
  String mode(String key) => switch (key) {
    'burrow' => l10n.monsterSpeedBurrow,
    'climb' => l10n.monsterSpeedClimb,
    'fly' => l10n.monsterSpeedFly,
    'swim' => l10n.monsterSpeedSwim,
    _ => key,
  };
  final parts = [formatDistance(speed.walk, units)];
  for (final entry in speed.modes.entries) {
    if (entry.key == 'walk' || speed.oneOf.contains(entry.key)) continue;
    final hover = entry.key == 'fly' && speed.hover ? ' ${l10n.monsterSpeedHover}' : '';
    parts.add('${mode(entry.key)} ${formatDistance(entry.value, units)}$hover');
  }
  if (speed.oneOf.length == 2) {
    parts.add(
      l10n.monsterSpeedChoice(
        mode(speed.oneOf.first),
        mode(speed.oneOf.last),
        formatDistance(speed.modes[speed.oneOf.first] ?? 0, units),
      ),
    );
  }
  return parts.join(', ');
}

String _signed(int value) => value >= 0 ? '+$value' : '$value';

String _title(String value) =>
    value.isEmpty ? value : '${value[0].toUpperCase()}${value.substring(1)}';

String monsterAbilityShort(AppLocalizations l10n, String ability) => switch (ability) {
  'strength' => l10n.abilityStr,
  'dexterity' => l10n.abilityDex,
  'constitution' => l10n.abilityCon,
  'intelligence' => l10n.abilityInt,
  'wisdom' => l10n.abilityWis,
  'charisma' => l10n.abilityCha,
  _ => ability,
};

/// Translated name of a trait or action, falling back to English.
String monsterEntryName(
  SrdI18nService i18n,
  SrdMonster monster,
  String section,
  SrdMonsterEntry entry,
) => i18n.monsterEntryName(monster.name, section, entry.id) ?? entry.name;

const monsterAbilities = [
  'strength',
  'dexterity',
  'constitution',
  'intelligence',
  'wisdom',
  'charisma',
];

class MonsterStatBlock extends ConsumerWidget {
  const MonsterStatBlock({super.key, required this.monster, required this.i18n});

  final SrdMonster monster;
  final SrdI18nService i18n;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final units = ref.watch(unitSystemProvider);
    final rules = ref.watch(rulesTextProvider);
    final senses = [
      for (final entry in monster.senses.entries)
        '${_senseName(l10n, entry.key)} ${formatDistance(entry.value, units)}',
      '${l10n.statPassivePerc} ${monster.passivePerception}',
    ];
    final languages = [
      for (var i = 0; i < monster.languages.length; i++)
        i18n.monsterLanguage(monster.name, i) ?? monster.languages[i],
    ];
    final properties = <(String, String)>[
      (l10n.statAC, '${monster.armorClass}'),
      (l10n.sectionHitPoints, '${monster.hitPoints} (${monster.hitPointsFormula})'),
      (l10n.statSpeed, monsterSpeedLine(l10n, monster.speed, units)),
      if (monster.initiativeModifier != null)
        (l10n.statInitiative, _signed(monster.initiativeModifier!)),
      if (monster.savingThrows.isNotEmpty)
        (
          l10n.monsterSavingThrows,
          [
            for (final entry in monster.savingThrows.entries)
              '${monsterAbilityShort(l10n, entry.key)} ${_signed(entry.value)}',
          ].join(', '),
        ),
      if (monster.skills.isNotEmpty)
        (
          l10n.monsterSkills,
          [
            for (final entry in monster.skills.entries)
              '${_title(i18n.skillName(_title(entry.key)))} ${_signed(entry.value)}',
          ].join(', '),
        ),
      if (monster.damageVulnerabilities.isNotEmpty)
        (l10n.monsterVulnerabilities, _damageTypes(monster.damageVulnerabilities)),
      if (monster.damageResistances.isNotEmpty)
        (l10n.monsterResistances, _damageTypes(monster.damageResistances)),
      if (monster.damageImmunities.isNotEmpty)
        (l10n.monsterImmunities, _damageTypes(monster.damageImmunities)),
      if (monster.conditionImmunities.isNotEmpty)
        (
          l10n.monsterConditionImmunities,
          [
            for (final condition in monster.conditionImmunities)
              i18n.conditionName(_title(condition)),
          ].join(', '),
        ),
      (l10n.monsterSenses, senses.join(', ')),
      (l10n.monsterLanguages, languages.isEmpty ? l10n.monsterLanguagesNone : languages.join(', ')),
      (
        l10n.monsterChallenge,
        l10n.monsterChallengeValue(
          monster.challengeRating,
          '${monster.experience}',
          monster.proficiencyBonus,
        ),
      ),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          i18n.monsterName(monster.name),
          style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        Text(
          monsterSizeTypeLine(l10n, monster),
          style: theme.textTheme.bodyMedium?.copyWith(fontStyle: FontStyle.italic),
        ),
        const Divider(height: 24),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final ability in monsterAbilities)
              _AbilityBox(
                label: monsterAbilityShort(l10n, ability),
                score: monster.score(ability),
                modifier: monster.modifier(ability),
              ),
          ],
        ),
        const Divider(height: 24),
        for (final (label, value) in properties)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: '$label ',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(text: value),
                ],
              ),
            ),
          ),
        for (final (section, title, entries) in [
          ('traits', l10n.monsterTraits, monster.traits),
          ('actions', l10n.monsterActions, monster.actions),
          ('bonusActions', l10n.monsterBonusActions, monster.bonusActions),
          ('reactions', l10n.monsterReactions, monster.reactions),
          ('legendaryActions', l10n.monsterLegendaryActions, monster.legendaryActions),
        ])
          if (entries.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(title, style: theme.textTheme.titleMedium),
            const Divider(height: 8),
            for (final entry in entries)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: '${monsterEntryName(i18n, monster, section, entry)}'
                            '${_usage(l10n, entry.usage)}. ',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      TextSpan(
                        text: rules(
                          i18n.monsterEntryDescription(monster.name, section, entry.id) ??
                              entry.description,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
      ],
    );
  }

  String _damageTypes(List<String> types) =>
      types.map((type) => i18n.damageType(type)).join(', ');

  static String _senseName(AppLocalizations l10n, String sense) => switch (sense) {
    'blindsight' => l10n.monsterSenseBlindsight,
    'darkvision' => l10n.monsterSenseDarkvision,
    'tremorsense' => l10n.monsterSenseTremorsense,
    'truesight' => l10n.monsterSenseTruesight,
    _ => sense,
  };

  static String _usage(AppLocalizations l10n, SrdMonsterUsage? usage) {
    if (usage == null) return '';
    return switch (usage.type) {
      'recharge' => ' (${l10n.monsterRecharge(usage.rechargeMin ?? 6)})',
      'per_day' => ' (${l10n.monsterPerDay(usage.uses ?? 1)})',
      _ => '',
    };
  }
}

class _AbilityBox extends StatelessWidget {
  const _AbilityBox({required this.label, required this.score, required this.modifier});

  final String label;
  final int score;
  final int modifier;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: 64,
      padding: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        children: [
          Text(label, style: theme.textTheme.labelSmall),
          Text('$score', style: theme.textTheme.titleMedium),
          Text(_signed(modifier), style: theme.textTheme.bodySmall),
        ],
      ),
    );
  }
}
