import 'package:dnd_character_tool/l10n/app_localizations.dart';

import '../../../../data/datasources/srd/srd_i18n_service.dart';
import '../../../../data/dice/contextual_roll.dart';
import '../../../../data/feature_choice_engine.dart';
import '../../../../data/rulesets/fighting_style_rules.dart';
import '../../../../data/rulesets/spell_roll_rules.dart';
import '../../../../data/rulesets/weapon_mastery_rules.dart';

String _signed(int value) => value >= 0 ? '+$value' : '$value';

String _masteryName(SrdI18nService i18n, String mastery) =>
    i18n.weaponMasteryName(mastery) ??
    (mastery.isEmpty ? mastery : '${mastery[0].toUpperCase()}${mastery.substring(1)}');

/// The mastery property of a weapon attack, with its computed values, and
/// the Tactical Master alternatives.
List<ContextualRollNote> weaponMasteryNotes({
  required AppLocalizations l10n,
  required SrdI18nService i18n,
  required WeaponMasteryEffect effect,
  required Map<String, String> descriptions,
  required String? damageType,
}) {
  final mastery = effect.mastery;
  final description =
      i18n.weaponMasteryDescription(mastery) ?? descriptions[mastery] ?? '';
  final value = switch (mastery) {
    'graze' => l10n.weaponMasteryGrazeValue(
      effect.grazeDamage ?? 0,
      damageType == null ? '' : i18n.damageType(damageType.toLowerCase()),
    ),
    'topple' => l10n.weaponMasteryToppleValue(effect.toppleDc ?? 0),
    'cleave' => l10n.weaponMasteryCleaveValue(
      _signed(effect.cleaveAttackBonus ?? 0),
      effect.cleaveDamage ?? '',
    ),
    _ => null,
  };
  return [
    ContextualRollNote(
      title: l10n.weaponMasteryNoteTitle(_masteryName(i18n, mastery)),
      text: [description, ?value].where((part) => part.isNotEmpty).join(' '),
    ),
    if (effect.alternatives.isNotEmpty)
      ContextualRollNote(
        title: l10n.weaponMasteryTacticalMasterTitle,
        text: l10n.weaponMasteryTacticalMaster(
          effect.alternatives.map((option) => _masteryName(i18n, option)).join(', '),
        ),
      ),
  ];
}

/// Fighting Style bonuses included in a weapon roll.
List<ContextualRollNote> fightingStyleNotes({
  required AppLocalizations l10n,
  required FightingStyleWeaponEffect effect,
}) => [
  if (effect.archeryAttackBonus > 0)
    ContextualRollNote(
      title: l10n.fightingStyleArchery,
      text: l10n.fightingStyleArcheryNote(effect.archeryAttackBonus),
    ),
  if (effect.duelingDamageBonus > 0)
    ContextualRollNote(
      title: l10n.fightingStyleDueling,
      text: l10n.fightingStyleDuelingNote(effect.duelingDamageBonus),
    ),
  if (effect.thrownDamageBonus > 0)
    ContextualRollNote(
      title: l10n.fightingStyleThrownWeaponFighting,
      text: l10n.fightingStyleThrownNote(effect.thrownDamageBonus),
    ),
];

/// Agonizing Blast damage and Eldritch Blast beams of a spell roll.
List<ContextualRollNote> spellRollNotes({
  required AppLocalizations l10n,
  required SrdI18nService i18n,
  required int damageBonus,
  required int beams,
}) => [
  if (damageBonus > 0)
    ContextualRollNote(
      title: i18n.featureChoiceOptionName(
            sourceType: FeatureChoiceSourceType.classFeature,
            sourceClass: 'Warlock',
            featureName: SpellRollRules.invocationsFeature,
            choiceId: 'invocations',
            optionId: SpellRollRules.agonizingBlast,
            optionsSource: 'eldritch_invocations_2024',
          ) ??
          'Agonizing Blast',
      text: l10n.agonizingBlastNote(damageBonus),
    ),
  if (beams > 1)
    ContextualRollNote(
      title: l10n.eldritchBlastBeamsTitle,
      text: l10n.eldritchBlastBeams(beams),
    ),
];
