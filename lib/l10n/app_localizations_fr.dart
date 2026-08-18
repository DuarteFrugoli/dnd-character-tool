// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'Outil de personnage DnD';

  @override
  String get charListTitle => 'Personnages DnD';

  @override
  String get charListImportTooltip => 'Importer du JSON';

  @override
  String get charListSettingsTooltip => 'Paramètres';

  @override
  String get charListNewCharacter => 'Nouveau personnage';

  @override
  String get charListEmpty => 'Aucun personnage pour l\'instant';

  @override
  String get charListEmptyHint =>
      'Appuyez sur + pour créer votre premier personnage';

  @override
  String charListImportedSuccess(String name) {
    return '$name importé avec succès !';
  }

  @override
  String charListDuplicatedSuccess(String name) {
    return '$name dupliqué avec succès !';
  }

  @override
  String get charListImportError =>
      'Erreur inattendue lors de l\'importation. Veuillez réessayer.';

  @override
  String get charListDuplicateError =>
      'Impossible de dupliquer le personnage. Veuillez réessayer.';

  @override
  String get importErrorInvalidJson => 'Le JSON collé n\'est pas valide.';

  @override
  String get importFieldLockedHint =>
      'Effacez l\'autre champ pour utiliser celui-ci.';

  @override
  String get importErrorNotObject =>
      'Format invalide : un objet JSON était attendu.';

  @override
  String get importErrorMissingCharacter =>
      'JSON invalide : champ \"character\" introuvable.';

  @override
  String get importErrorCorruptedCharacter =>
      'Impossible de lire le personnage. Le JSON est peut-être incomplet ou d\'une version incompatible.';

  @override
  String charCardLevel(int level) {
    return 'Niveau $level';
  }

  @override
  String get charCardPin => 'Épingler en haut';

  @override
  String get charCardUnpin => 'Détacher';

  @override
  String get charCardChangePhoto => 'Changer de photo';

  @override
  String get charCardRename => 'Rebaptiser';

  @override
  String get charCardDuplicate => 'Dupliquer';

  @override
  String get charCardExport => 'Exporter';

  @override
  String get charCardDelete => 'Supprimer';

  @override
  String charDuplicateName(String name) {
    return '$name (copie)';
  }

  @override
  String charDuplicateNameNumbered(String name, int number) {
    return '$name (copie $number)';
  }

  @override
  String get renameDialogTitle => 'Renommer le personnage';

  @override
  String get renameDialogLabel => 'Nom';

  @override
  String get dialogCancel => 'Annuler';

  @override
  String get dialogSave => 'Sauvegarder';

  @override
  String get deleteDialogTitle => 'Supprimer un personnage ?';

  @override
  String deleteDialogContent(String name) {
    return 'Etes-vous sûr de vouloir supprimer $name ? Cela ne peut pas être annulé.';
  }

  @override
  String get dialogConfirm => 'Confirmer';

  @override
  String get dialogDiscard => 'Jeter';

  @override
  String get dialogContinue => 'Continuer';

  @override
  String get dialogKeepEditing => 'Continuer à éditer';

  @override
  String get dialogRemove => 'Retirer';

  @override
  String get dialogAdd => 'Ajouter';

  @override
  String get dialogDone => 'Terminé';

  @override
  String get settingsTitle => 'Paramètres';

  @override
  String get settingsSectionTheme => 'Thème visuel';

  @override
  String get settingsDark => 'Sombre';

  @override
  String get settingsLight => 'Lumière';

  @override
  String get settingsChooseTheme => 'Choisissez un thème';

  @override
  String get settingsSectionLanguage => 'Langue';

  @override
  String get settingsAppLanguage => 'Langue de l\'application';

  @override
  String get settingsChooseLanguage => 'Choisissez une langue';

  @override
  String get settingsSystemDefault => 'Valeur par défaut du système';

  @override
  String get modeSelectionTitle => 'Nouveau personnage';

  @override
  String get modeSelectionQuestion =>
      'Comment voulez-vous créer votre personnage ?';

  @override
  String get modeGuidedTitle => 'Guidé';

  @override
  String get modeGuidedSubtitle =>
      'Assistant étape par étape. Choisissez la classe, la race, l\'origine, les compétences et les attributs un par un. Recommandé pour les nouveaux joueurs.';

  @override
  String get modeManualTitle => 'Manuel';

  @override
  String get modeManualSubtitle =>
      'Remplissez tout vous-même. Tous les champs sont gratuits et aucune valeur n\'est calculée pour vous. Idéal pour les joueurs expérimentés.';

  @override
  String get modeRandomTitle => 'Aléatoire';

  @override
  String get modeRandomSubtitle =>
      'Tout est déterminé pour vous : race, classe, parcours et attributs. Idéal pour un défi ou un one-shot.';

  @override
  String get modeSemiRandomTitle => 'Semi-aléatoire';

  @override
  String get modeSemiRandomSubtitle =>
      'Vous choisissez les choix importants ; tout le reste est roulé. Idéal lorsque vous avez un concept mais que vous voulez des surprises.';

  @override
  String get modeComingSoon => 'Bientôt';

  @override
  String get creationStepClass => 'Classe';

  @override
  String get creationStepRace => 'Course';

  @override
  String get creationStepBackground => 'Arrière-plan';

  @override
  String get creationStepSkills => 'Compétences';

  @override
  String get creationStepAttributes => 'Attributs';

  @override
  String get creationStepName => 'Nom';

  @override
  String get creationStepReview => 'Revoir';

  @override
  String get creationDiscardTitle => 'Supprimer le personnage ?';

  @override
  String get creationDiscardContent => 'Tout progrès sera perdu. Es-tu sûr?';

  @override
  String get creationTooltipCancel => 'Annuler';

  @override
  String get creationBack => 'Dos';

  @override
  String get creationCreateCharacter => 'Créer un personnage';

  @override
  String get detailLeaveWithoutSaving => 'Partir sans économiser ?';

  @override
  String get detailChangesWillBeDiscarded =>
      'Les modifications seront rejetées. Pour enregistrer, utilisez le bouton ✓ en haut à droite.';

  @override
  String get detailLeaveAndDiscard => 'Laisser et jeter';

  @override
  String detailErrorLoading(String error) {
    return 'Erreur de chargement du caractère : $error';
  }

  @override
  String get detailTooltipLongRest => 'Long repos';

  @override
  String get characterActionRollDice => 'Lancer les dés';

  @override
  String get characterActionResetLevels => 'Réinitialiser les niveaux';

  @override
  String get diceExpressionLabel => 'Expression';

  @override
  String get diceExpressionHint => 'Exemple : 1d20+5 ou 4d6dl1';

  @override
  String get diceExpressionHelpTooltip =>
      'Fonctionnement des expressions de dés';

  @override
  String get diceExpressionHelpTitle => 'Expressions de dés';

  @override
  String get diceExpressionHelpBody =>
      'Utilisez XdY pour lancer des dés : 2d6 lance deux dés à 6 faces.\nAjoutez ou soustrayez des modificateurs : 1d20+5 ou 2d6 - 1.\nUtilisez d% ou d100 pour un dé de pourcentage.\nPour avantage/désavantage au d20 : 2d20kh1 garde le plus haut, 2d20kl1 garde le plus bas.\nGardez/retirez des dés avec kh, kl, dh ou dl. Exemple : 4d6dl1 lance quatre d6 et retire le plus bas.\nLes espaces sont facultatifs : 2d6+1d8 et 2d6 + 1d8 fonctionnent.';

  @override
  String get diceQuantityLabel => 'Quantité';

  @override
  String get diceModifierLabel => 'Modificateur';

  @override
  String get diceRollButton => 'Lancer';

  @override
  String get diceRerollButton => 'Relancer';

  @override
  String get diceModeNormal => 'Normal';

  @override
  String get diceModeAdvantage => 'Avantage';

  @override
  String get diceModeDisadvantage => 'Désavantage';

  @override
  String get diceResultTitle => 'Résultat';

  @override
  String get diceHistoryTitle => 'Lancers récents';

  @override
  String get diceNoRollsYet => 'Aucun lancer pour le moment.';

  @override
  String get diceNaturalOne => '1 naturel';

  @override
  String get diceNaturalTwenty => '20 naturel';

  @override
  String diceInvalidExpression(String message) {
    return 'Expression de dés invalide : $message';
  }

  @override
  String get detailTooltipCancelEdit => 'Annuler la modification';

  @override
  String get detailTooltipDoneEditing => 'Modification terminée';

  @override
  String get detailTooltipEditCharacter => 'Modifier le personnage';

  @override
  String get detailCancelEditTitle => 'Annuler la modification ?';

  @override
  String get detailCancelEditContent =>
      'Toutes les modifications seront rejetées.';

  @override
  String get detailFinishEditTitle => 'Terminer la modification ?';

  @override
  String get detailFinishEditContent =>
      'Les modifications seront enregistrées.';

  @override
  String get detailTabIdentity => 'Identité';

  @override
  String get detailEditButton => 'Modifier';

  @override
  String get skillsEditHint =>
      'Maintenez pour alterner: aucun → compétent → expert';

  @override
  String get detailTabStats => 'Statistiques';

  @override
  String get detailTabSkills => 'Compétences';

  @override
  String get detailTabFeatures => 'Caractéristiques';

  @override
  String get detailTabSpells => 'Sorts';

  @override
  String get detailTabInventory => 'Inventaire';

  @override
  String get detailTabNotes => 'Remarques';

  @override
  String get longRestTitle => 'Long repos';

  @override
  String get longRestContent =>
      'Restaurer les HP au maximum et récupérer tous les emplacements de sorts ?';

  @override
  String get longRestButton => 'Repos';

  @override
  String get restPickerTitle => 'Repos';

  @override
  String get restPickerShort => 'Repos Court';

  @override
  String get restPickerShortCaption =>
      'Dépenser des dés de vie pour récupérer des PV';

  @override
  String get restPickerLong => 'Long Repos';

  @override
  String get restPickerLongCaption =>
      'Récupère tous les PV et emplacements de sorts';

  @override
  String get shortRestTitle => 'Repos Court';

  @override
  String get shortRestAvailableDice => 'Dés de vie disponibles';

  @override
  String get shortRestSpend => 'Dépenser';

  @override
  String get shortRestRolled => 'PV récupérés';

  @override
  String get shortRestRollButton => 'Lancer';

  @override
  String get shortRestButton => 'Se reposer';

  @override
  String get shortRestNoDice => 'Plus de dés de vie disponibles';

  @override
  String get concentrationBannerLabel => 'Concentration sur :';

  @override
  String get concentrationBreakButton => 'Terminer';

  @override
  String get concentrationReplaceTitle => 'Remplacer la concentration ?';

  @override
  String concentrationReplaceBody(String current, String next) {
    return 'Vous vous concentrez sur $current. Lancer $next mettra fin à votre concentration.';
  }

  @override
  String get concentrationReplaceConfirm => 'Remplacer';

  @override
  String get concentrationTooltip => 'Définir la concentration';

  @override
  String get sectionIdentity => 'Identité';

  @override
  String get sectionHitPoints => 'Points de vie';

  @override
  String get sectionCombat => 'Combat';

  @override
  String get sectionProgression => 'Progression';

  @override
  String get sectionAbilityScores => 'Scores de capacité';

  @override
  String get sectionSavingThrows =>
      'Compétences en matière de jet de sauvegarde';

  @override
  String get labelName => 'Nom';

  @override
  String get labelBackground => 'Arrière-plan';

  @override
  String get labelChange => 'Changement';

  @override
  String get labelAlignment => 'Alignement';

  @override
  String get labelPlayer => 'Joueur';

  @override
  String get labelLevel => 'Niveau';

  @override
  String get tooltipLevelUp => 'Niveau Sup.';

  @override
  String get levelUpTitle => 'Montée de niveau';

  @override
  String get levelUpStepClassTarget => 'Choisir la classe à améliorer';

  @override
  String get levelUpClassTargetExisting => 'Classes actuelles';

  @override
  String get levelUpClassTargetAddClass => 'Ajouter une nouvelle classe';

  @override
  String levelUpClassTargetCurrentLevel(int level) {
    return 'Niveau actuel $level';
  }

  @override
  String levelUpClassTargetNextClassLevel(int level) {
    return 'Niveau de classe $level';
  }

  @override
  String levelUpClassTargetRequirement(String requirement) {
    return 'Requiert $requirement';
  }

  @override
  String levelUpClassTargetRequirementMissing(String requirement) {
    return 'Prérequis manquant : $requirement';
  }

  @override
  String get levelUpClassTargetCurrentRequirementsMissing =>
      'Votre classe actuelle ne remplit pas son prérequis de multiclasse.';

  @override
  String get levelUpConfirm => 'Confirmer la montée';

  @override
  String get levelUpCancel => 'Annuler';

  @override
  String get levelUpStepFeatures => 'Nouvelles aptitudes';

  @override
  String levelUpStepSubclass(String feature) {
    return 'Choisir $feature';
  }

  @override
  String get levelUpStepAsi => 'Amélioration de caractéristique';

  @override
  String get levelUpStepHp => 'Points de vie';

  @override
  String get levelUpStepCantrips => 'Nouveaux tours de magie';

  @override
  String get levelUpStepSpells => 'Nouveaux sorts';

  @override
  String get levelUpStepSummary => 'Résumé';

  @override
  String get levelUpNoNewFeatures =>
      'Aucune nouvelle aptitude de classe à ce niveau.';

  @override
  String get featureChoicesTitle => 'Choix de capacites';

  @override
  String get featureChoicesPending => 'Choix en attente';

  @override
  String get featureChoicesEdit => 'Modifier les choix';

  @override
  String get featureChoicesChooseDependencyFirst =>
      'Choisis d\'abord l\'option precedente requise.';

  @override
  String featureChoicesChooseCount(String kind, int count) {
    return 'Choisis $count $kind.';
  }

  @override
  String featureChoicesSelectedCount(int selected, int count) {
    return '$selected/$count selectionnes';
  }

  @override
  String get levelUpHpRoll => 'Lancer';

  @override
  String get levelUpHpAverage => 'Moyenne';

  @override
  String levelUpHpGained(int n) {
    return '+$n PV';
  }

  @override
  String levelUpHpFormula(int die, String mod) {
    return 'd$die + CON ($mod)';
  }

  @override
  String get levelUpAsiOption => 'Amélioration de caractéristique';

  @override
  String get levelUpFeatOption => 'Choisir un don';

  @override
  String levelUpAsiPointsLeft(int n) {
    return '$n point(s) restant(s)';
  }

  @override
  String levelUpSpellsToLearn(int n) {
    return 'Choisir $n sort(s)';
  }

  @override
  String get levelUpSpellRestrictedSection => 'School requirement';

  @override
  String get levelUpSpellFreeSection => 'Free choice';

  @override
  String levelUpSpellRestrictedInstruction(int count, String schools) {
    return 'Choose $count spell(s) from $schools.';
  }

  @override
  String levelUpSpellFreeInstruction(int count) {
    return 'Choose $count spell(s) from any school.';
  }

  @override
  String get levelUpSpellFreeLocked => 'Complete the school requirement first.';

  @override
  String levelUpCantripsToLearn(int n) {
    return 'Choisir $n tour(s) de magie';
  }

  @override
  String get levelUpSpellSwap => 'Remplacer un sort connu (facultatif)';

  @override
  String levelUpSpellSwapCurrent(String name) {
    return 'Actuel : $name';
  }

  @override
  String levelUpSummaryLevel(int level) {
    return '→ Niveau $level';
  }

  @override
  String levelUpSummaryClassLevel(String className, int level) {
    return '$className niveau $level';
  }

  @override
  String levelUpSummaryHp(int n) {
    return 'PV Max +$n';
  }

  @override
  String levelUpSummaryAsi(String changes) {
    return 'AC : $changes';
  }

  @override
  String levelUpSummaryFeat(String name) {
    return 'Don : $name';
  }

  @override
  String levelUpSummarySubclass(String name) {
    return 'Sous-classe : $name';
  }

  @override
  String levelUpSummarySpellsLearned(int count) {
    return 'Sorts appris : $count';
  }

  @override
  String levelUpSummaryCantripsLearned(int count) {
    return 'Tours de magie appris : $count';
  }

  @override
  String levelUpSubclassAlreadyHas(String name) {
    return 'Sous-classe actuelle : $name';
  }

  @override
  String get levelUpMaxLevel => 'Déjà au niveau maximum (20).';

  @override
  String get levelUpHpReroll => 'Relancer / modifier';

  @override
  String get levelUpSpellSwapPickReplacement =>
      'Choisissez maintenant un sort de remplacement';

  @override
  String get levelUpSpellSwapReplaceWith => 'Remplacer par';

  @override
  String get levelUpSpellSwapNone => 'Aucun';

  @override
  String get levelUpSpellAlreadyKnown => 'Déjà connu';

  @override
  String levelUpSpellCantripSubtitle(String school) {
    return '$school (tour de magie)';
  }

  @override
  String levelUpSpellSubtitle(int level, String school) {
    return 'Niv $level $school';
  }

  @override
  String get resetLevelsTitle => 'Réinitialiser les niveaux';

  @override
  String get resetLevelsConfirmBody =>
      'Cela réinitialisera la progression de classe au niveau 1. Vos notes, inventaire, conteneurs, monnaie, image, histoire, apparence, race, historique et caractéristiques seront conservés.\n\nLes niveaux de classe, sorts de classe, choix de classe/sous-classe, ressources de progression et dons d\'ASI seront supprimés ou recalculés. Exportez une sauvegarde avant si vous voulez une copie supplémentaire.';

  @override
  String resetLevelsCountdown(int seconds) {
    return 'Attendez ${seconds}s';
  }

  @override
  String get resetLevelsIntro =>
      'Choisissez les nouvelles données de classe du niveau 1. La réinitialisation n\'est enregistrée que lorsque vous appuyez sur le bouton final.';

  @override
  String get resetLevelsSubclassRequired =>
      'Cette classe choisit une sous-classe au niveau 1.';

  @override
  String resetLevelsInitialHp(int hp) {
    return 'PV initiaux : $hp';
  }

  @override
  String resetLevelsSelectSkills(int count) {
    return 'Choisissez $count compétences de classe.';
  }

  @override
  String get resetLevelsFixedTools => 'Accordé automatiquement :';

  @override
  String resetLevelsSelectTools(int count) {
    return 'Choisissez $count maîtrises d\'outils.';
  }

  @override
  String get resetLevelsApply => 'Réinitialiser au niveau 1';

  @override
  String resetLevelsApplyAndRebuild(int level) {
    return 'Réinitialiser et reconstruire jusqu\'au niveau $level';
  }

  @override
  String get resetLevelsIncomplete => 'Complétez les choix obligatoires';

  @override
  String get resetLevelsApplied => 'Niveaux réinitialisés.';

  @override
  String resetLevelsRebuildTitle(int level) {
    return 'Reconstruire jusqu\'au niveau $level';
  }

  @override
  String resetLevelsRebuildSubtitle(int level) {
    return 'Après le choix du niveau 1, l\'app ouvrira les étapes de montée de niveau jusqu\'au niveau $level. Si vous annulez avant la fin, rien n\'est enregistré.';
  }

  @override
  String resetLevelsRebuildStep(int level, int targetLevel) {
    return 'Reconstruction du niveau $level sur $targetLevel';
  }

  @override
  String get resetLevelsRebuildCancelled =>
      'Réinitialisation annulée. Aucun changement n\'a été enregistré.';

  @override
  String resetLevelsRebuiltApplied(int level) {
    return 'Niveaux réinitialisés et reconstruits jusqu\'au niveau $level.';
  }

  @override
  String get labelSubclass => 'Sous-classe';

  @override
  String get labelLanguages => 'Langues';

  @override
  String get hintAddLanguage => 'Ajouter une langue…';

  @override
  String get labelChoose => 'Choisir';

  @override
  String get sectionAppearance => 'Apparence';

  @override
  String get labelAge => 'Âge';

  @override
  String get labelHeight => 'Taille';

  @override
  String get labelWeight => 'Poids';

  @override
  String get labelEyes => 'Yeux';

  @override
  String get labelSkin => 'Peau';

  @override
  String get labelHair => 'Cheveux';

  @override
  String get labelMaxHP => 'PV maximum';

  @override
  String get labelTempHP => 'HP temporaire';

  @override
  String get labelAmount => 'Montant';

  @override
  String get labelSpeed => 'Vitesse (pieds)';

  @override
  String get detailDamage => 'Dommage';

  @override
  String get detailHeal => 'Guérir';

  @override
  String get detailNone => 'Aucun';

  @override
  String get tempHpDialogTitle => 'Ajouter des HP temporaires';

  @override
  String get tempHpDialogTitleReplace => 'HP temporaire';

  @override
  String tempHpCurrent(int n) {
    return 'Courant : + $n temp HP';
  }

  @override
  String get tempHpNoStack =>
      'Temp HP ne se cumule pas – seules les valeurs plus élevées remplacent le courant.';

  @override
  String get tempHpReplace => 'Remplacer';

  @override
  String statsTempHpChip(int n) {
    return '+$n temp';
  }

  @override
  String subclassConfirmTitle(String feature) {
    return 'Confirmer $feature';
  }

  @override
  String subclassChooseTitle(String feature) {
    return 'Choisissez $feature';
  }

  @override
  String subclassConfirmBody(int level, String feature) {
    return 'Vous avez atteint le niveau $level . Confirmez ou modifiez votre $feature .';
  }

  @override
  String subclassChooseBody(int level, String feature) {
    return 'Vous avez atteint le niveau $level ! Choisissez votre $feature .';
  }

  @override
  String get subclassKeepCurrent => 'Restez à jour';

  @override
  String get subclassChangeTitle => 'Changer de sous-classe';

  @override
  String get subclassChangeWarning =>
      'Attention : les sorts et compétences accordés par la sous-classe précédente ne sont pas supprimés automatiquement. Vous devrez les ajuster manuellement.';

  @override
  String get backgroundChooseTitle => 'Choisir l\'arrière-plan';

  @override
  String get featuresTooltipAdd => 'Ajouter une fonctionnalité';

  @override
  String get featuresTooltipRemove => 'Retirer';

  @override
  String get featuresTooltipEnable => 'Activer';

  @override
  String get featuresTooltipDisable => 'Désactiver';

  @override
  String get featuresTabFeats => 'Dons';

  @override
  String featPrerequisite(String req) {
    return 'Prérequis : $req';
  }

  @override
  String get featuresSectionFeats => 'Dons';

  @override
  String get featuresTabClass => 'Classe';

  @override
  String get featuresTabRacial => 'Racial';

  @override
  String get featuresTabCustom => 'Personnalisé';

  @override
  String get featuresTabTools => 'Outils';

  @override
  String get featuresRemoveTitle => 'Supprimer la fonctionnalité ?';

  @override
  String featuresRemoveContent(String name) {
    return '\" $name \" sera supprimé.';
  }

  @override
  String get featuresNoneAvailable => 'Aucune fonctionnalité disponible.';

  @override
  String get featuresAddLabel => 'Ajouter une fonctionnalité';

  @override
  String get featuresLoadError => 'Erreur de chargement des fonctionnalités.';

  @override
  String get hintSearch => 'Recherche...';

  @override
  String get labelFeatureName => 'Nom';

  @override
  String get labelFeatureDescription => 'Description (facultatif)';

  @override
  String get labelFeatureType => 'Taper:';

  @override
  String get labelPassive => 'Passif';

  @override
  String get labelActive => 'Actif';

  @override
  String get spellsTooltipAdd => 'Ajouter un sort';

  @override
  String get spellsRemoveTitle => 'Supprimer le sort ?';

  @override
  String spellsRemoveContent(String name) {
    return 'Supprimer « $name » de votre liste de sorts ?';
  }

  @override
  String get spellsAtWill => 'À volonté';

  @override
  String get notesTooltipAdd => 'Ajouter une note';

  @override
  String get notesTooltipEdit => 'Modifier la note';

  @override
  String get notesTooltipDelete => 'Supprimer la note';

  @override
  String get notesEmptyTitle => 'Aucune note pour l\'instant';

  @override
  String get notesEmptyHint => 'Appuyez sur + pour créer votre première note.';

  @override
  String get notesUntitled => 'Sans titre';

  @override
  String get notesDeleteTitle => 'Supprimer la note ?';

  @override
  String notesDeleteContentNamed(String title) {
    return '\" $title \" sera définitivement supprimé.';
  }

  @override
  String get notesDeleteContent => 'Cette note sera définitivement supprimée.';

  @override
  String get notesLabelTitle => 'Titre';

  @override
  String get notesLabelContent => 'Contenu';

  @override
  String get notesSearchHint => 'Rechercher des notes ou étiquettes';

  @override
  String get notesNoResultsTitle => 'Aucune note correspondante';

  @override
  String get notesNoResultsHint =>
      'Essayez une autre recherche ou effacez le filtre d\'étiquette.';

  @override
  String get notesReadMore => 'Lire la suite';

  @override
  String get notesTags => 'Étiquettes';

  @override
  String get notesAllTags => 'Toutes';

  @override
  String get notesCustomTag => 'Étiquette personnalisée';

  @override
  String get notesAddTag => 'Ajouter une étiquette';

  @override
  String get notesTagColor => 'Couleur de l\'étiquette';

  @override
  String get notesChooseTagColor => 'Choisir la couleur de l\'étiquette';

  @override
  String get notesTooltipPin => 'Épingler la note';

  @override
  String get notesTooltipUnpin => 'Désépingler la note';

  @override
  String get notesMoveUp => 'Déplacer vers le haut';

  @override
  String get notesMoveDown => 'Déplacer vers le bas';

  @override
  String get notesMoreActions => 'Plus d\'actions';

  @override
  String get notesPinnedSection => 'Épinglées';

  @override
  String get notesOtherSection => 'Notes';

  @override
  String get notesDefaultTagSession => 'Session';

  @override
  String get notesDefaultTagNpc => 'PNJ';

  @override
  String get notesDefaultTagQuest => 'Quête';

  @override
  String get notesDefaultTagPlace => 'Lieu';

  @override
  String get notesDefaultTagLoot => 'Butin';

  @override
  String get notesDefaultTagRule => 'Règle';

  @override
  String get sectionPersonalityTraits => 'Traits de personnalité';

  @override
  String get sectionPersonality => 'Personnalité';

  @override
  String get sectionIdeals => 'Idéaux';

  @override
  String get sectionBonds => 'Obligations';

  @override
  String get sectionFlaws => 'Défauts';

  @override
  String get sectionBackstory => 'Histoire';

  @override
  String inventoryEquippedSection(int count, int ac) {
    return 'Équipé ( $count ) · CA $ac';
  }

  @override
  String get inventoryTooltipAdd => 'Ajouter un article';

  @override
  String get inventoryTooltipRemove => 'Retirer';

  @override
  String get inventoryTooltipMove => 'Déplacer';

  @override
  String inventoryMoveTitle(String name) {
    return 'Déplacer $name';
  }

  @override
  String get inventoryMoveToInventory => 'Inventaire';

  @override
  String inventoryContainersSection(int count) {
    return 'Conteneurs ($count)';
  }

  @override
  String inventoryContainerContents(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count objets',
      one: '1 objet',
    );
    return '$_temp0';
  }

  @override
  String get inventoryContainerEmpty => 'Vide';

  @override
  String get inventoryRemoveTitle => 'Supprimer l\'élément ?';

  @override
  String inventoryRemoveContent(String name) {
    return 'Supprimer $name de l\'inventaire ?';
  }

  @override
  String inventoryRemovePartial(int count, int total) {
    return 'Supprime : $count de $total';
  }

  @override
  String get inventoryRemoveContainerTitle => 'Supprimer le conteneur ?';

  @override
  String inventoryRemoveContainerContent(String name, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count objets',
      one: '1 objet',
    );
    return '$name contient $_temp0. Que doit-il leur arriver ?';
  }

  @override
  String get inventoryRemoveContainerMoveContents =>
      'Déplacer les objets vers l\'inventaire';

  @override
  String get inventoryRemoveContainerDeleteContents => 'Tout supprimer';

  @override
  String get inventoryLabelQuantity => 'Quantité:';

  @override
  String get inventoryLabelQuantityToRemove => 'Quantité à retirer';

  @override
  String get inventoryAddCustomItem => 'Ajouter un article personnalisé';

  @override
  String get inventoryAddItem => 'Ajouter un article';

  @override
  String get inventoryLabelItemName => 'Nom *';

  @override
  String get inventoryLabelType => 'Taper';

  @override
  String get inventoryLabelCategory => 'Catégorie';

  @override
  String get inventoryLabelItemQuantity => 'Quantité';

  @override
  String get inventoryLabelWeight => 'Poids';

  @override
  String get weightCarried => 'Porté';

  @override
  String get weightCapacity => 'Capacité';

  @override
  String get weightEncumbered => 'Encombré';

  @override
  String get weightHeavilyEncumbered => 'Lourdement Encombré';

  @override
  String get weightEnableTooltip => 'Activer le suivi du poids';

  @override
  String get weightDisableTooltip => 'Désactiver le suivi du poids';

  @override
  String get inventoryLabelDescription => 'Description (facultatif)';

  @override
  String get inventoryTypeWeapon => 'Arme';

  @override
  String get inventoryTypeArmor => 'Armure';

  @override
  String get inventoryTypeConsumable => 'Consommable';

  @override
  String get inventoryTypeGear => 'Engrenage';

  @override
  String get inventoryTypeEquippable => 'Équipable';

  @override
  String get inventoryTypeContainer => 'Contenant';

  @override
  String get inventoryAddItemError => 'Impossible d\'ajouter l\'objet.';

  @override
  String inventoryLoadItemsError(String error) {
    return 'Erreur de chargement des objets :\n$error';
  }

  @override
  String inventoryNoResults(String query) {
    return 'Aucun résultat pour \"$query\"';
  }

  @override
  String get inventoryTooltipEquip => 'Équiper';

  @override
  String get inventoryTooltipUnequip => 'Déséquiper';

  @override
  String get inventoryCustomDamageDice => 'Dégâts (ex. : 1d8)';

  @override
  String get inventoryCustomDamageType => 'Type de dégâts';

  @override
  String get inventoryCustomWeaponProperties =>
      'Propriétés (séparées par des virgules)';

  @override
  String get inventoryCustomRangeNormal => 'Portée normale';

  @override
  String get inventoryCustomRangeLong => 'Portée longue';

  @override
  String get inventoryCustomAddDexToAc => 'Ajouter DEX à la CA';

  @override
  String get inventoryCustomEquipSlot => 'Emplacement (ex. : anneau, cou)';

  @override
  String get inventoryCustomCompatibleWith =>
      'Compatible avec (séparé par des virgules)';

  @override
  String get inventoryDetailYes => 'Oui';

  @override
  String get inventoryDetailNo => 'Non';

  @override
  String get inventoryDetailMaxShort => 'max';

  @override
  String get inventoryDetailDamage => 'Dégâts';

  @override
  String get inventoryDetailDamageType => 'Type de dégâts';

  @override
  String get inventoryDetailWeaponProperties => 'Propriétés';

  @override
  String get inventoryDetailVersatileDamage => 'Dégâts polyvalents';

  @override
  String get inventoryDetailRange => 'Portée';

  @override
  String get inventoryDetailRangeNormal => 'normale';

  @override
  String get inventoryDetailRangeLong => 'longue';

  @override
  String get inventoryDetailArmorType => 'Type d\'armure';

  @override
  String get inventoryDetailShield => 'Bouclier';

  @override
  String get inventoryDetailBaseAc => 'CA de base';

  @override
  String get inventoryDetailAcBonus => 'Bonus de CA';

  @override
  String get inventoryDetailAddDexToAc => 'Ajoute DEX à la CA';

  @override
  String get inventoryDetailMaxDex => 'DEX max.';

  @override
  String get inventoryDetailStrengthMinimum => 'Force minimale';

  @override
  String get inventoryDetailEquipSlot => 'Emplacement';

  @override
  String get inventoryDetailRequiresAttunement => 'Nécessite l\'harmonisation';

  @override
  String get inventoryDetailCapacityWeight => 'Capacité de poids';

  @override
  String get inventoryDetailCapacityVolume => 'Volume';

  @override
  String get inventoryDetailCapacityVolumeUnit => 'Unité de volume';

  @override
  String get inventoryDetailIgnoreContentWeight => 'Ignore le poids du contenu';

  @override
  String get inventoryDetailEffect => 'Effet';

  @override
  String get inventoryDetailUses => 'Utilisations';

  @override
  String get inventoryDetailAction => 'Action';

  @override
  String get inventoryDetailAmmoType => 'Type de munition';

  @override
  String get inventoryDetailCompatibleWith => 'Compatible avec';

  @override
  String get inventoryDetailBonus => 'Bonus';

  @override
  String get inventoryDetailExtraDamage => 'Dégâts supplémentaires';

  @override
  String get inventoryDetailExtraDamageType => 'Type de dégâts supplémentaires';

  @override
  String get inventoryDetailSubtype => 'Sous-type';

  @override
  String get inventoryDetailCost => 'Coût';

  @override
  String get inventoryDetailRarity => 'Rareté';

  @override
  String get inventoryDetailFeatures => 'Caractéristiques';

  @override
  String get inventoryDetailWeightEach => 'Poids par objet';

  @override
  String get inventoryDetailWeightTotal => 'Poids total';

  @override
  String get inventoryDetailState => 'État';

  @override
  String get inventoryDetailEquipped => 'Équipé';

  @override
  String get inventoryDetailNotEquipped => 'Non équipé';

  @override
  String get inventoryDetailSummary => 'Résumé';

  @override
  String get inventoryDetailDescription => 'Description';

  @override
  String get inventoryDetailAttributes => 'Attributs';

  @override
  String get inventoryReplaceArmorTitle => 'Remplacer l\'armure équipée ?';

  @override
  String get inventoryTabWeapons => 'Armes';

  @override
  String get inventoryTabArmor => 'Armure';

  @override
  String get inventoryTabGear => 'Engrenage';

  @override
  String get inventoryTabMagic => 'Magie';

  @override
  String get inventoryTabTools => 'Outils';

  @override
  String get inventoryTabCustom => 'Coutume';

  @override
  String hintSearchCategory(String category) {
    return 'Rechercher $category ...';
  }

  @override
  String get stepChooseMethod => 'Choisissez votre méthode :';

  @override
  String get stepStandardArray => 'Tableau standard';

  @override
  String get stepPointBuy => 'Achat ponctuel';

  @override
  String get stepRoll4d6 => 'Lancez 4d6';

  @override
  String get stepDistributeRacialBonuses =>
      'Distribuez librement des bonus raciaux';

  @override
  String get stepAssignRolls => 'Attribuez chaque lancer à un attribut :';

  @override
  String get stepAssignValues => 'Attribuez chaque valeur à un attribut :';

  @override
  String get stepPointsRemaining => 'Points restants :';

  @override
  String stepRaceBonus(int n) {
    return '+ Course $n';
  }

  @override
  String get stepChooseSubrace => 'Choisissez une sous-race :';

  @override
  String get stepGrantedByBackground => 'Accordé par expérience :';

  @override
  String stepClassSkillChoices(int count) {
    return 'Choix de compétences de classe ( $count ) :';
  }

  @override
  String get stepChooseOne => 'Choisissez-en un';

  @override
  String get stepSelectTool => 'Sélectionnez un outil…';

  @override
  String get statAC => 'CA';

  @override
  String get statArmor => 'Armure';

  @override
  String get statNoArmor => 'Pas d\'armure';

  @override
  String get statNoArmorShield => 'Pas d\'armure + Bouclier';

  @override
  String get statShieldSuffix => '+ Bouclier';

  @override
  String get statSpeed => 'Vitesse';

  @override
  String get statInitiative => 'Initiative';

  @override
  String get statProfBonus => 'Bonus Prof';

  @override
  String get statPassivePerc => 'Perc. passif';

  @override
  String get statInspiration => 'Inspiration';

  @override
  String get statXP => 'XP';

  @override
  String get inspirationGranted => 'Accordée';

  @override
  String get inspirationNotGranted => 'Non accordée';

  @override
  String statLevel(int level) {
    return 'Niveau $level';
  }

  @override
  String get tooltipAddXp => 'Ajouter XP';

  @override
  String get labelLevelTable => 'Tableau des Niveaux';

  @override
  String get statUnconsciousDying => 'Inconscient / Mourant';

  @override
  String get deathSavesTitle => 'Jets de Mort';

  @override
  String get deathSavesSuccesses => 'Succès';

  @override
  String get deathSavesFailures => 'Échecs';

  @override
  String get deathSavesStabilized => 'Stabilisé';

  @override
  String get deathSavesDead => 'Mort';

  @override
  String get sectionActiveConditions => 'Conditions Actives';

  @override
  String get conditionsNone => 'Aucune active';

  @override
  String get conditionsAdd => 'Ajouter condition';

  @override
  String get conditionsPickTitle => 'Appliquer Condition';

  @override
  String get conditionsRemove => 'Retirer condition';

  @override
  String get tooltipAddTempHp => 'Ajouter du HP temporaire';

  @override
  String get tooltipChangeTempHp => 'Changer la température HP';

  @override
  String get abilityStr => 'STR';

  @override
  String get abilityDex => 'DEX';

  @override
  String get abilityCon => 'ESCROQUER';

  @override
  String get abilityInt => 'INT';

  @override
  String get abilityWis => 'SIE';

  @override
  String get abilityCha => 'CHA';

  @override
  String featuresSectionRacialTraits(String name) {
    return 'Traits raciaux — $name';
  }

  @override
  String featuresSectionBackground(String name) {
    return 'Fonctionnalité d\'arrière-plan — $name';
  }

  @override
  String featuresSectionClass(String name) {
    return 'Caractéristiques de classe — $name';
  }

  @override
  String featuresSectionSubclass(String name) {
    return 'Fonctionnalités de sous-classe – $name';
  }

  @override
  String get featuresSectionTools => 'Maîtrise des outils';

  @override
  String get featuresSectionExtra => 'Fonctionnalités supplémentaires';

  @override
  String get spellsNoSpellcasting => 'Pas de lancement de sorts';

  @override
  String get spellsNoSpellcastingDesc =>
      'Cette classe n\'a pas de fonctionnalités de lancement de sorts.';

  @override
  String get spellsSlots => 'Emplacements de sorts';

  @override
  String get spellsPactMagicSlots => 'Magie de pacte';

  @override
  String get spellsSpellcasting => 'Lancement de sorts';

  @override
  String get spellsAttack => 'Attaque';

  @override
  String get spellsSaveDC => 'Enregistrer DC';

  @override
  String get spellsCantrips => 'Cantrips';

  @override
  String get spellsPrepared => 'Préparé';

  @override
  String get spellsKnown => 'Connu';

  @override
  String get spellsEmpty =>
      'Aucun sort ajouté pour l\'instant.\nAppuyez sur + pour parcourir les sorts.';

  @override
  String spellsSlotLevel(int level) {
    return 'Niv $level';
  }

  @override
  String spellsLevelN(int level) {
    return 'Niveau $level';
  }

  @override
  String get spellsInnateHeader => 'Sorts Raciaux';

  @override
  String get spellsDisableTitle => 'Désactiver le sort ?';

  @override
  String get spellsEnableTitle => 'Réactiver le sort ?';

  @override
  String spellsDisableContent(String name) {
    return 'Désactiver \"$name\" ? Il sera grisé et ne pourra pas être préparé.';
  }

  @override
  String spellsEnableContent(String name) {
    return 'Réactiver \"$name\" ? Il réapparaîtra normalement.';
  }

  @override
  String get spellsDisable => 'Désactiver';

  @override
  String get spellsEnable => 'Réactiver';

  @override
  String get spellsExtrasHeader => 'Sorts Supplémentaires';

  @override
  String get spellFilterTitle => 'Filtres';

  @override
  String get spellFilterReset => 'Réinitialiser';

  @override
  String get spellFilterApply => 'Appliquer les filtres';

  @override
  String get spellFilterSectionClasses => 'Classes';

  @override
  String get spellFilterClassesHint =>
      'Aucune classe sélectionnée = afficher toutes les classes';

  @override
  String get spellFilterSectionLevel => 'Niveau de sort';

  @override
  String get spellFilterShowAllLevels => 'Afficher tous les niveaux';

  @override
  String spellFilterShowAllLevelsHint(int max) {
    return 'Inclure les sorts au-delà de votre maximum (Niv $max)';
  }

  @override
  String get spellFilterCantrip => 'Tour de magie';

  @override
  String spellFilterLvl(int n) {
    return 'Niv $n';
  }

  @override
  String get spellFilterSectionCastingTime => 'Temps d\'incantation';

  @override
  String get spellFilterCastAction => 'Action';

  @override
  String get spellFilterCastBonus => 'Action bonus';

  @override
  String get spellFilterCastReaction => 'Réaction';

  @override
  String get spellFilterCastLonger => 'Incantation longue (1 min+)';

  @override
  String get spellFilterSectionProperties => 'Propriétés';

  @override
  String get spellFilterConcentration => 'Concentration';

  @override
  String get spellFilterConcentrationHint =>
      'Seulement les sorts nécessitant une concentration';

  @override
  String get spellFilterRitual => 'Rituel';

  @override
  String get spellFilterRitualHint =>
      'Seulement les sorts pouvant être lancés en tant que rituels';

  @override
  String get spellFilterSectionSchool => 'École de magie';

  @override
  String get spellRemoveTitle => 'Supprimer le sort';

  @override
  String spellRemoveContent(String name) {
    return 'Supprimer \"$name\" de votre liste de sorts ?';
  }

  @override
  String get spellActionPrepared => 'Préparé — appuyez pour annuler';

  @override
  String get spellActionPrepare => 'Préparer pour aujourd\'hui';

  @override
  String get spellActionAdd => 'Ajouter au personnage';

  @override
  String get spellActionInList => 'Dans votre liste — appuyez pour supprimer';

  @override
  String get spellActionAlreadyInList => 'Déjà dans votre liste de sorts';

  @override
  String get spellActionClassSpellInfo =>
      'Ce sort fait déjà partie de la liste de votre classe et n\'a pas besoin d\'être appris.';

  @override
  String get inventoryCurrency => 'Devise';

  @override
  String inventoryCarriedSection(int count) {
    return 'Adoptée ( $count )';
  }

  @override
  String inventoryEquippableSection(int count) {
    return 'Équipable ($count)';
  }

  @override
  String get inventoryEquipHint =>
      'Appuyez sur l\'icône circulaire à gauche pour équiper ou déséquiper';

  @override
  String get inventoryInventory => 'Inventaire';

  @override
  String get inventoryEmpty =>
      'Aucun article pour l\'instant. Appuyez sur + pour ajouter.';

  @override
  String get inventoryAmmunition => 'Munitions';

  @override
  String get coinCopper => 'Cuivre';

  @override
  String get coinSilver => 'Argent';

  @override
  String get coinElectrum => 'Électrum';

  @override
  String get coinGold => 'Or';

  @override
  String get coinPlatinum => 'Platine';

  @override
  String get inventoryGroupSimpleMelee => 'Mêlée simple';

  @override
  String get inventoryGroupSimpleRanged => 'Simple à distance';

  @override
  String get inventoryGroupMartialMelee => 'Mêlée martiale';

  @override
  String get inventoryGroupMartialRanged => 'Martial à distance';

  @override
  String get inventoryGroupLightArmor => 'Armure légère';

  @override
  String get inventoryGroupMediumArmor => 'Armure moyenne';

  @override
  String get inventoryGroupHeavyArmor => 'Armure lourde';

  @override
  String get inventoryGroupShields => 'Boucliers';

  @override
  String get inventoryGroupAdventuringGear => 'Équipement d\'aventure';

  @override
  String get inventoryGroupAmmunition => 'Munitions';

  @override
  String get inventoryGroupArcaneFocus => 'Concentration arcanique';

  @override
  String get inventoryGroupClothing => 'Vêtements';

  @override
  String get inventoryGroupContainer => 'Récipient';

  @override
  String get inventoryGroupPoison => 'Poison';

  @override
  String get inventoryGroupPotions => 'Potions';

  @override
  String get inventoryGroupRings => 'Anneaux';

  @override
  String get inventoryGroupWands => 'Baguettes';

  @override
  String get inventoryGroupWeapons => 'Armes';

  @override
  String get inventoryGroupArmor => 'Armure';

  @override
  String get inventoryGroupWondrousItems => 'Objets merveilleux';

  @override
  String get inventoryGroupArtisansTools => 'Outils d\'artisan';

  @override
  String get inventoryGroupGamingSets => 'Ensembles de jeu';

  @override
  String get inventoryGroupMusicalInstruments => 'Instruments de musique';

  @override
  String get inventoryGroupOtherTools => 'Autres outils';

  @override
  String get armorStealthDisadvantage => 'Désavantage furtif';

  @override
  String get spellDetailCastingTime => 'Temps de coulée';

  @override
  String get spellDetailRange => 'Gamme';

  @override
  String get spellRangeSelf => 'Personnelle';

  @override
  String get spellRangeTouch => 'Contact';

  @override
  String get spellRangeSight => 'Ligne de mire';

  @override
  String get spellRangeSpecial => 'Spéciale';

  @override
  String get spellRangeUnlimited => 'Illimitée';

  @override
  String get spellAreaSphere => 'sphère';

  @override
  String get spellAreaCone => 'cône';

  @override
  String get spellAreaCube => 'cube';

  @override
  String get spellAreaCylinder => 'cylindre';

  @override
  String get spellAreaLine => 'ligne';

  @override
  String get spellAreaWall => 'mur';

  @override
  String get spellAreaCircle => 'cercle';

  @override
  String get spellDetailDuration => 'Durée';

  @override
  String get spellDetailComponents => 'Composants';

  @override
  String get spellDetailConcentration => 'Nécessite de la concentration';

  @override
  String get spellDetailRitual => 'Peut être lancé comme un rituel';

  @override
  String get spellDetailAtHigherLevels => 'Aux niveaux supérieurs.';

  @override
  String spellDetailClasses(String classes) {
    return 'Classes : $classes';
  }

  @override
  String spellDetailLevelSchool(String ordinal, String school) {
    return '$ordinal -niveau $school';
  }

  @override
  String spellDetailCantrip(String school) {
    return 'Déclencheur $school';
  }

  @override
  String armorSwapCurrent(String name) {
    return 'Actuel : $name';
  }

  @override
  String armorSwapAcNow(int ac) {
    return 'CA actuel : $ac';
  }

  @override
  String armorSwapAcAfter(int ac) {
    return 'CA après : $ac';
  }

  @override
  String get armorSwapButton => 'Changer d\'armure';

  @override
  String get reviewRowName => 'Nom';

  @override
  String get reviewUnnamedHero => 'Héros sans nom';

  @override
  String get reviewRowPlayer => 'Joueur';

  @override
  String get reviewRowSubclass => 'Sous-classe';

  @override
  String get reviewRowHitDie => 'Toucher le dé';

  @override
  String get reviewRowSavingThrows => 'Jets de sauvegarde';

  @override
  String get reviewRowSubrace => 'Sous-race';

  @override
  String get reviewRowSpeed => 'Vitesse';

  @override
  String get reviewRowLanguages => 'Langues';

  @override
  String get reviewRowFeature => 'Fonctionnalité';

  @override
  String get reviewRowFromBackground => 'Depuis l\'arrière-plan';

  @override
  String get reviewRowClassChoices => 'Choix de classe';

  @override
  String get reviewRowMaxHp => 'PV maximum';

  @override
  String get reviewRowAcUnarmored => 'AC (sans armure)';

  @override
  String reviewRowAcWith(String name) {
    return 'CA avec $name';
  }

  @override
  String get reviewRowProficiencyBonus => 'Bonus de compétence';

  @override
  String get reviewStartingGold => 'Commencer l\'or';

  @override
  String get reviewStartingEquipment => 'Équipement de départ';

  @override
  String get reviewDeselectAll => 'Tout désélectionner';

  @override
  String get reviewSelectAll => 'Tout sélectionner';

  @override
  String get reviewUncheckHint =>
      'Décochez les articles que vous ne souhaitez pas ajouter à votre inventaire.';

  @override
  String get reviewEquipmentChoices => 'Choix d\'équipement';

  @override
  String get reviewEquipmentChoicesHint =>
      'Choisissez l\'élément spécifique pour chaque emplacement.';

  @override
  String get reviewToolProficiencies => 'Maîtrise des outils';

  @override
  String get reviewChooseToolProficiency =>
      'Choisissez votre maîtrise de l\'outil :';

  @override
  String reviewChooseLanguages(int count) {
    return 'Choisissez la ou les langues $count accordées en fonction de votre race ou de vos origines.';
  }

  @override
  String get reviewChooseOne => 'Choisissez-en un :';

  @override
  String get stepTashaRule =>
      'Règle facultative de Tasha : attribuez des points ASI à n\'importe quel attribut';

  @override
  String get stepRollDice => 'Lancer les dés';

  @override
  String get stepReroll => 'Relancer';

  @override
  String get stepRollHint =>
      'Lancez pour générer 6 valeurs (4d6, descendez le plus bas)';

  @override
  String get stepPrimaryAbilities => 'capacités principales :';

  @override
  String get stepNameTitle => 'Give your character a name.';

  @override
  String get stepNameHint => 'You can always change this later.';

  @override
  String get stepNameCharLabel => 'Character name';

  @override
  String get stepNamePlayerLabel => 'Player name (optional)';

  @override
  String get stepHitDieLabel => 'Hit die';

  @override
  String get stepSavesLabel => 'Saves';

  @override
  String get stepSpellcastingLabel => 'Spellcasting';

  @override
  String get stepOptionsLabel => 'options';

  @override
  String stepChooseSubclassPrompt(String feature, int level) {
    return 'Choose a $feature (Lv $level):';
  }

  @override
  String get stepRaceSpeedLabel => 'Speed';

  @override
  String get stepRaceASILabel => 'ASI';

  @override
  String stepRaceSubracesAvailable(int count) {
    return '$count subraces available';
  }

  @override
  String stepChooseSkillsHint(int count) {
    return 'Choose $count skills from your class list.';
  }

  @override
  String get abilityStrength => 'Strength';

  @override
  String get abilityDexterity => 'Dexterity';

  @override
  String get abilityConstitution => 'Constitution';

  @override
  String get abilityIntelligence => 'Intelligence';

  @override
  String get abilityWisdom => 'Wisdom';

  @override
  String get abilityCharisma => 'Charisma';

  @override
  String stepFreeAsiRemaining(int remaining) {
    return 'Distribute racial ASI points freely ($remaining remaining):';
  }

  @override
  String stepFreePicksRemaining(int total, int remaining) {
    return 'Racial free ASI: assign +1 to $total attributes ($remaining remaining):';
  }

  @override
  String get stepFreePicksNoStack =>
      'Cannot assign to attributes already receiving a racial bonus.';

  @override
  String reviewClassEquipmentTitle(String name) {
    return 'Équipement de classe — $name';
  }

  @override
  String get reviewEquipmentIncluded => 'Inclus :';

  @override
  String get stepToolCategoryGamingSet => 'Kit de jeu';

  @override
  String get stepToolCategoryInstrument => 'Instrument de musique';

  @override
  String get stepToolCategoryArtisanTool => 'Outil d\'artisan';

  @override
  String get stepToolCategoryArtisanOrInstrument =>
      'Outil d\'artisan ou instrument';

  @override
  String exportCopied(String label) {
    return '$label copié !';
  }

  @override
  String exportDialogTitle(String name) {
    return 'Exporter $name';
  }

  @override
  String get exportShowJson => 'Afficher le JSON';

  @override
  String get exportCopyJson => 'Copier le JSON';

  @override
  String get exportSectionFile => 'Fichier complet';

  @override
  String get exportSectionFileCaption => 'Inclut la photo du personnage';

  @override
  String get exportShareFile => 'Partager .dndchar';

  @override
  String get dialogClose => 'Fermer';

  @override
  String get importDialogTitle => 'Importer un personnage';

  @override
  String get importUseJson => 'Utiliser le JSON directement';

  @override
  String get importJsonHint => 'Colle le JSON ici…';

  @override
  String get importPickFile => 'Choisir un fichier .dndchar';

  @override
  String get importFileError => 'Fichier .dndchar invalide ou corrompu';

  @override
  String get importFileIncoming => 'Importer le personnage depuis ce fichier ?';

  @override
  String get dialogImport => 'Importer';

  @override
  String get spellBrowserTitle => 'Parcourir les sorts';

  @override
  String get spellBrowserFilters => 'Filtres';

  @override
  String get spellBrowserSearchHint => 'Rechercher des sorts...';

  @override
  String get filterClearAll => 'Tout effacer';

  @override
  String get loadingLabel => 'Chargement...';

  @override
  String spellBrowserCount(int count, String s) {
    return '$count sort$s';
  }

  @override
  String get spellBrowserEmpty =>
      'Aucun sort ne correspond aux filtres actuels.';

  @override
  String get spellCantrip => 'Tour de magie';

  @override
  String spellLevelN(int n) {
    return 'Niv $n';
  }

  @override
  String get castingTimeAction => 'Action';

  @override
  String get castingTimeBonusAction => 'Action bonus';

  @override
  String get castingTimeReaction => 'Réaction';

  @override
  String get castingTimeLonger => 'Incantation longue';

  @override
  String get filterConcentration => 'Concentration';

  @override
  String get filterRitual => 'Rituel';

  @override
  String get filterAllLevels => 'Tous les niveaux';

  @override
  String get avatarChoosePhoto => 'Choisir une photo';

  @override
  String get avatarRemovePhoto => 'Supprimer la photo';

  @override
  String get avatarCropPhoto => 'Recadrer la photo';

  @override
  String get avatarChangePhoto => 'Modifier la photo';

  @override
  String get avatarSavePhoto => 'Enregistrer la photo';

  @override
  String get avatarSaveSuccess => 'Photo enregistrée dans la galerie';

  @override
  String get avatarSaveError => 'Impossible d\'enregistrer la photo';

  @override
  String featureAddedSnackbar(String name) {
    return '$name ajouté !';
  }

  @override
  String get featureAddButton => 'Ajouter une caractéristique';

  @override
  String get reviewLanguageChoices => 'Choix de langues';

  @override
  String get reviewLanguageTypeHint => 'Saisissez une langue…';

  @override
  String get avatarRemoveConfirmTitle => 'Supprimer la photo ?';

  @override
  String get avatarRemoveConfirmBody => 'Cette action est irréversible.';

  @override
  String get editModeBanner => 'Modification en cours';

  @override
  String get detailSheetInfoTooltip => 'Détails';

  @override
  String get detailSheetProficiencies => 'Maîtrises';

  @override
  String get detailSheetTraits => 'Traits';

  @override
  String get detailSheetSubclassFeaturePlaceholder => 'Trait de Sous-classe';

  @override
  String detailSheetAvailableSubclasses(String feature) {
    return '$feature disponibles';
  }

  @override
  String get detailSheetAvailableSubraces => 'Sous-races';

  @override
  String get xpTrackingLabel => 'Track XP';

  @override
  String get xpReadyToLevelUp => 'Ready to level up!';

  @override
  String get xpLevelUpNowTitle => 'Level Up?';

  @override
  String xpLevelUpNowMessage(int level) {
    return 'You have enough XP to reach Level $level. Level up now?';
  }

  @override
  String get xpLevelUpLater => 'Later';

  @override
  String get settingsSectionUnits => 'Unités';

  @override
  String get settingsUnitSystem => 'Système d\'unités';

  @override
  String get settingsUnitImperial => 'Impérial (ft / lb)';

  @override
  String get settingsUnitMetric => 'Métrique (m / kg)';

  @override
  String get settingsUnitSquares => 'Cases (sq / kg)';

  @override
  String get settingsChooseUnitSystem => 'Choisir le système d\'unités';

  @override
  String get settingsSectionCharacterSheet => 'Fiche de personnage';

  @override
  String get settingsKeepScreenOnTitle => 'Garder l\'écran allumé';

  @override
  String get settingsKeepScreenOnSubtitle =>
      'Empêche l\'écran de se mettre en veille pendant la consultation d\'une fiche de personnage.';

  @override
  String get settingsBackupSection => 'Sauvegarde';

  @override
  String get settingsBackupExportTitle => 'Exporter la sauvegarde';

  @override
  String get settingsBackupExportSubtitle =>
      'Enregistre tous les personnages dans un fichier de sauvegarde.';

  @override
  String get settingsBackupExporting => 'Création de la sauvegarde...';

  @override
  String get settingsBackupExportSuccess => 'Sauvegarde exportée.';

  @override
  String get settingsBackupExportError =>
      'Impossible d’exporter la sauvegarde.';

  @override
  String get settingsBackupImportTitle => 'Importer une sauvegarde';

  @override
  String get settingsBackupImportSubtitle =>
      'Restaure les personnages depuis un fichier .dndbackup.';

  @override
  String get settingsBackupImporting => 'Importation de la sauvegarde...';

  @override
  String get settingsBackupImportError =>
      'Impossible d’importer la sauvegarde.';

  @override
  String settingsBackupImportSuccess(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count personnages importés depuis la sauvegarde.',
      one: '1 personnage importé depuis la sauvegarde.',
    );
    return '$_temp0';
  }

  @override
  String get settingsSectionApp => 'Application';

  @override
  String get settingsReviewTitle => 'Noter sur le Play Store';

  @override
  String get settingsReviewSubtitle =>
      'Ouvrez la page de l\'application pour laisser une note ou un commentaire.';

  @override
  String get settingsReviewOpenError => 'Impossible d’ouvrir le Play Store.';

  @override
  String get settingsMaintenanceSection => 'Maintenance';

  @override
  String get settingsMaintenanceCheckTitle =>
      'Vérifier les mises à jour des personnages';

  @override
  String get settingsMaintenanceCheckSubtitle =>
      'Recherche des corrections pour les données enregistrées.';

  @override
  String get settingsMaintenanceUpdateTitle => 'Mettre à jour les personnages';

  @override
  String get settingsMaintenanceWorking => 'Recherche des mises à jour...';

  @override
  String get settingsMaintenanceNoUpdates =>
      'Tous les personnages sont déjà à jour.';

  @override
  String get settingsMaintenanceError =>
      'Impossible de mettre à jour les personnages.';

  @override
  String get settingsMaintenanceConfirmTitle =>
      'Mettre à jour les personnages ?';

  @override
  String get settingsMaintenanceCompleteTitle => 'Mise à jour terminée';

  @override
  String settingsMaintenanceUpdatesFound(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count personnages nécessitent une mise à jour.',
      one: '1 personnage nécessite une mise à jour.',
    );
    return '$_temp0';
  }

  @override
  String settingsMaintenanceConfirmBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count personnages nécessitent une mise à jour. Une sauvegarde sera ouverte pour être enregistrée ou partagée avant application des changements.',
      one:
          '1 personnage nécessite une mise à jour. Une sauvegarde sera ouverte pour être enregistrée ou partagée avant application des changements.',
    );
    return '$_temp0';
  }

  @override
  String get characterUpdateRequiredTitle =>
      'Mise à jour du personnage requise';

  @override
  String get characterUpdateRequiredBody =>
      'Ce personnage a été enregistré avec une ancienne version des données. Mettez à jour vos personnages dans les paramètres avant de le modifier.';

  @override
  String get characterUpdateRequiredAction => 'Aller aux mises à jour';

  @override
  String settingsMaintenanceReportChecked(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count personnages vérifiés.',
      one: '1 personnage vérifié.',
    );
    return '$_temp0';
  }

  @override
  String settingsMaintenanceReportUpdated(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count personnages mis à jour.',
      one: '1 personnage mis à jour.',
    );
    return '$_temp0';
  }

  @override
  String settingsMaintenanceReportDataChanged(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count personnages ont reçu des corrections de données.',
      one: '1 personnage a reçu des corrections de données.',
    );
    return '$_temp0';
  }

  @override
  String get settingsMaintenanceReportVersionUpdated =>
      'Version des données mise à jour.';

  @override
  String settingsMaintenanceChangeEquipmentWeights(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Poids de $count objets corrigé.',
      one: 'Poids de 1 objet corrigé.',
    );
    return '$_temp0';
  }

  @override
  String settingsMaintenanceChangeEquipmentNormalized(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count objets d’équipement normalisés.',
      one: '1 objet d’équipement normalisé.',
    );
    return '$_temp0';
  }

  @override
  String settingsMaintenanceChangeEquipmentPacksExpanded(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count paquets d’équipement développés.',
      one: '1 paquet d’équipement développé.',
    );
    return '$_temp0';
  }

  @override
  String settingsMaintenanceChangeEquipmentOrder(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Ordre de $count objets d’inventaire normalisé.',
      one: 'Ordre de 1 objet d’inventaire normalisé.',
    );
    return '$_temp0';
  }

  @override
  String get settingsMaintenanceChangeMulticlassStructure =>
      'Structure de classes préparée pour le multiclassage.';

  @override
  String get settingsMaintenanceChangeSpellSlots =>
      'Emplacements de sorts standards recalculés.';

  @override
  String get settingsMaintenanceChangePactMagicSlots =>
      'Emplacements de Magie de pacte séparés.';

  @override
  String get settingsMaintenanceChangeArmorClass =>
      'Classe d’armure recalculée.';

  @override
  String settingsMaintenanceChangeGeneric(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count modifications appliquées.',
      one: '1 modification appliquée.',
    );
    return '$_temp0';
  }

  @override
  String get incomingBackupPrompt =>
      'Importer la sauvegarde depuis le fichier ?';

  @override
  String incomingBackupSuccess(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count personnages importés depuis la sauvegarde.',
      one: '1 personnage importé depuis la sauvegarde.',
    );
    return '$_temp0';
  }
}
