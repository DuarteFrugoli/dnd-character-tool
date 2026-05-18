// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'Outil de personnage D&D';

  @override
  String get charListTitle => 'Personnages D&D';

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
  String get charListImportError =>
      'Erreur inattendue lors de l\'importation. Veuillez réessayer.';

  @override
  String get importErrorInvalidJson =>
      'Le texte collé n\'est pas un JSON valide.';

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
  String get charCardExport => 'Exporter';

  @override
  String get charCardDelete => 'Supprimer';

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
  String get sectionIdentity => 'Identité';

  @override
  String get sectionHitPoints => 'Points de vie';

  @override
  String get sectionCombat => 'Combat';

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
  String get labelSubclass => 'Sous-classe';

  @override
  String get labelLanguages => 'Langues';

  @override
  String get hintAddLanguage => 'Ajouter une langue…';

  @override
  String get labelChoose => 'Choisir';

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
  String get featuresTabClass => 'Classe';

  @override
  String get featuresTabRacial => 'Racial';

  @override
  String get featuresTabCustom => 'Personnalisé';

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
  String get sectionPersonalityTraits => 'Traits de personnalité';

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
  String get statUnconsciousDying => 'Inconscient / Mourant';

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
  String get inventoryCurrency => 'Devise';

  @override
  String inventoryCarriedSection(int count) {
    return 'Adoptée ( $count )';
  }

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
  String get exportLabelToken => 'Jeton';

  @override
  String get exportCopyToken => 'Copier le jeton';

  @override
  String get exportHideQr => 'Masquer le QR code';

  @override
  String get exportShowQr => 'Afficher le QR code';

  @override
  String get exportQrTooLarge =>
      'Personnage trop grand pour le QR code.\nUtilise le jeton ou le JSON pour partager.';

  @override
  String get exportShowJson => 'Afficher le JSON';

  @override
  String get exportCopyJson => 'Copier le JSON';

  @override
  String get dialogClose => 'Fermer';

  @override
  String get importDialogTitle => 'Importer un personnage';

  @override
  String get importTokenHint => 'Colle le jeton ici…';

  @override
  String get importScanQr => 'Scanner le QR code';

  @override
  String get importUseJson => 'Utiliser le JSON directement';

  @override
  String get importJsonHint => 'Colle le JSON ici…';

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
}
