// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get appTitle => 'Strumento per i personaggi di D&D';

  @override
  String get charListTitle => 'Personaggi di D&D';

  @override
  String get charListImportTooltip => 'Importa JSON';

  @override
  String get charListSettingsTooltip => 'Impostazioni';

  @override
  String get charListNewCharacter => 'Nuovo personaggio';

  @override
  String get charListEmpty => 'Nessun personaggio ancora';

  @override
  String get charListEmptyHint => 'Tocca + per creare il tuo primo personaggio';

  @override
  String charListImportedSuccess(String name) {
    return '$name importato con successo!';
  }

  @override
  String get charListImportError =>
      'Errore imprevisto durante l\'importazione. Per favore riprova.';

  @override
  String get importErrorInvalidJson =>
      'Il testo incollato non è un JSON valido.';

  @override
  String get importErrorNotObject =>
      'Formato non valido: era atteso un oggetto JSON.';

  @override
  String get importErrorMissingCharacter =>
      'JSON non valido: campo \"character\" non trovato.';

  @override
  String get importErrorCorruptedCharacter =>
      'Impossibile leggere il personaggio. Il JSON potrebbe essere incompleto o di una versione incompatibile.';

  @override
  String charCardLevel(int level) {
    return 'Livello XARBPPHX0X';
  }

  @override
  String get charCardPin => 'Appunta in alto';

  @override
  String get charCardUnpin => 'Sblocca';

  @override
  String get charCardChangePhoto => 'Cambia foto';

  @override
  String get charCardRename => 'Rinominare';

  @override
  String get charCardExport => 'Esportare';

  @override
  String get charCardDelete => 'Eliminare';

  @override
  String get renameDialogTitle => 'Rinominare il personaggio';

  @override
  String get renameDialogLabel => 'Nome';

  @override
  String get dialogCancel => 'Cancellare';

  @override
  String get dialogSave => 'Salva';

  @override
  String get deleteDialogTitle => 'Eliminare il carattere?';

  @override
  String deleteDialogContent(String name) {
    return 'Sei sicuro di voler eliminare $name? Questa operazione non può essere annullata.';
  }

  @override
  String get dialogConfirm => 'Confermare';

  @override
  String get dialogDiscard => 'Scartare';

  @override
  String get dialogContinue => 'Continuare';

  @override
  String get dialogKeepEditing => 'Continua a modificare';

  @override
  String get dialogRemove => 'Rimuovere';

  @override
  String get dialogAdd => 'Aggiungere';

  @override
  String get settingsTitle => 'Impostazioni';

  @override
  String get settingsSectionTheme => 'Tema visivo';

  @override
  String get settingsDark => 'Buio';

  @override
  String get settingsLight => 'Leggero';

  @override
  String get settingsChooseTheme => 'Scegli un tema';

  @override
  String get settingsSectionLanguage => 'Lingua';

  @override
  String get settingsAppLanguage => 'Lingua dell\'app';

  @override
  String get settingsChooseLanguage => 'Scegli una lingua';

  @override
  String get settingsSystemDefault => 'Predefinito del sistema';

  @override
  String get modeSelectionTitle => 'Nuovo personaggio';

  @override
  String get modeSelectionQuestion => 'Come vuoi creare il tuo personaggio?';

  @override
  String get modeGuidedTitle => 'Guidato';

  @override
  String get modeGuidedSubtitle =>
      'Procedura guidata passo dopo passo. Scegli classe, razza, background, abilità e attributi uno alla volta. Consigliato per i nuovi giocatori.';

  @override
  String get modeManualTitle => 'Manuale';

  @override
  String get modeManualSubtitle =>
      'Compila tutto da solo. Tutti i campi sono gratuiti e nessun valore viene calcolato per te. Ideale per giocatori esperti.';

  @override
  String get modeRandomTitle => 'Casuale';

  @override
  String get modeRandomSubtitle =>
      'Tutto è pensato per te: razza, classe, background e attributi. Ottimo per una sfida o un colpo singolo.';

  @override
  String get modeSemiRandomTitle => 'Semi-casuale';

  @override
  String get modeSemiRandomSubtitle =>
      'Scegli tu le scelte importanti; tutto il resto viene arrotolato. Buono per quando hai un\'idea ma vuoi sorprese.';

  @override
  String get modeComingSoon => 'Presto';

  @override
  String get creationStepClass => 'Classe';

  @override
  String get creationStepRace => 'Gara';

  @override
  String get creationStepBackground => 'Sfondo';

  @override
  String get creationStepSkills => 'Competenze';

  @override
  String get creationStepAttributes => 'Attributi';

  @override
  String get creationStepName => 'Nome';

  @override
  String get creationStepReview => 'Revisione';

  @override
  String get creationDiscardTitle => 'Scartare il personaggio?';

  @override
  String get creationDiscardContent =>
      'Tutti i progressi andranno persi. Sei sicuro?';

  @override
  String get creationTooltipCancel => 'Cancellare';

  @override
  String get creationBack => 'Indietro';

  @override
  String get creationCreateCharacter => 'Crea personaggio';

  @override
  String get detailLeaveWithoutSaving => 'Uscire senza salvare?';

  @override
  String get detailChangesWillBeDiscarded =>
      'Le modifiche verranno ignorate. Per salvare utilizzare il pulsante ✓ in alto a destra.';

  @override
  String get detailLeaveAndDiscard => 'Lasciare e scartare';

  @override
  String detailErrorLoading(String error) {
    return 'Errore durante il caricamento del carattere: $error';
  }

  @override
  String get detailTooltipLongRest => 'Riposo lungo';

  @override
  String get detailTooltipCancelEdit => 'Annulla la modifica';

  @override
  String get detailTooltipDoneEditing => 'Modifica completata';

  @override
  String get detailTooltipEditCharacter => 'Modifica personaggio';

  @override
  String get detailCancelEditTitle => 'Annullare la modifica?';

  @override
  String get detailCancelEditContent =>
      'Tutte le modifiche verranno annullate.';

  @override
  String get detailFinishEditTitle => 'Terminare la modifica?';

  @override
  String get detailFinishEditContent => 'Le modifiche verranno salvate.';

  @override
  String get detailTabIdentity => 'Identità';

  @override
  String get detailEditButton => 'Modifica';

  @override
  String get skillsEditHint =>
      'Tieni premuto per alternare: nessuno → competente → esperto';

  @override
  String get detailTabStats => 'Statistiche';

  @override
  String get detailTabSkills => 'Competenze';

  @override
  String get detailTabFeatures => 'Caratteristiche';

  @override
  String get detailTabSpells => 'Incantesimi';

  @override
  String get detailTabInventory => 'Inventario';

  @override
  String get detailTabNotes => 'Note';

  @override
  String get longRestTitle => 'Riposo lungo';

  @override
  String get longRestContent =>
      'Ripristina gli HP al massimo e recupera tutti gli slot degli incantesimi?';

  @override
  String get longRestButton => 'Riposo';

  @override
  String get sectionIdentity => 'Identità';

  @override
  String get sectionHitPoints => 'Punti ferita';

  @override
  String get sectionCombat => 'Combattere';

  @override
  String get sectionAbilityScores => 'Punteggi di abilità';

  @override
  String get sectionSavingThrows => 'Competenze nei tiri salvezza';

  @override
  String get labelName => 'Nome';

  @override
  String get labelBackground => 'Sfondo';

  @override
  String get labelChange => 'Modifica';

  @override
  String get labelAlignment => 'Allineamento';

  @override
  String get labelPlayer => 'Giocatore';

  @override
  String get labelLevel => 'Livello';

  @override
  String get labelSubclass => 'Sottoclasse';

  @override
  String get labelLanguages => 'Lingue';

  @override
  String get hintAddLanguage => 'Aggiungi lingua...';

  @override
  String get labelChoose => 'Scegliere';

  @override
  String get sectionAppearance => 'Aspetto';

  @override
  String get labelAge => 'Età';

  @override
  String get labelHeight => 'Altezza';

  @override
  String get labelWeight => 'Peso';

  @override
  String get labelEyes => 'Occhi';

  @override
  String get labelSkin => 'Pelle';

  @override
  String get labelHair => 'Capelli';

  @override
  String get labelMaxHP => 'HP massimi';

  @override
  String get labelTempHP => 'HP temporanei';

  @override
  String get labelAmount => 'Quantità';

  @override
  String get labelSpeed => 'Velocità (piedi)';

  @override
  String get detailDamage => 'Danno';

  @override
  String get detailHeal => 'Guarire';

  @override
  String get detailNone => 'Nessuno';

  @override
  String get tempHpDialogTitle => 'Aggiungi HP temporanei';

  @override
  String get tempHpDialogTitleReplace => 'HP temporanei';

  @override
  String tempHpCurrent(int n) {
    return 'Corrente: + $n temp HP';
  }

  @override
  String get tempHpNoStack =>
      'Temp HP non si accumula: solo i valori più alti sostituiscono la corrente.';

  @override
  String get tempHpReplace => 'Sostituire';

  @override
  String subclassConfirmTitle(String feature) {
    return 'Conferma $feature';
  }

  @override
  String subclassChooseTitle(String feature) {
    return 'Scegli $feature';
  }

  @override
  String subclassConfirmBody(int level, String feature) {
    return 'Hai raggiunto il livello $level . Conferma o modifica il tuo $feature .';
  }

  @override
  String subclassChooseBody(int level, String feature) {
    return 'Hai raggiunto il livello $level! Scegli il tuo $feature .';
  }

  @override
  String get subclassKeepCurrent => 'Tieniti aggiornato';

  @override
  String get subclassChangeTitle => 'Cambia sottoclasse';

  @override
  String get subclassChangeWarning =>
      'Attenzione: gli incantesimi e le competenze concesse dalla sottoclasse precedente non vengono rimossi automaticamente. Dovrai regolarli manualmente.';

  @override
  String get backgroundChooseTitle => 'Scegli Sfondo';

  @override
  String get featuresTooltipAdd => 'Aggiungi funzionalità';

  @override
  String get featuresTooltipRemove => 'Rimuovere';

  @override
  String get featuresTooltipEnable => 'Attiva';

  @override
  String get featuresTooltipDisable => 'Disattiva';

  @override
  String get featuresTabClass => 'Classe';

  @override
  String get featuresTabRacial => 'Razziale';

  @override
  String get featuresTabCustom => 'Personaliz.';

  @override
  String get featuresRemoveTitle => 'Rimuovere la funzione?';

  @override
  String featuresRemoveContent(String name) {
    return '\" $name \" verrà rimosso.';
  }

  @override
  String get featuresNoneAvailable => 'Nessuna funzionalità disponibile.';

  @override
  String get featuresAddLabel => 'Aggiungi funzionalità';

  @override
  String get featuresLoadError =>
      'Errore durante il caricamento delle funzionalità.';

  @override
  String get hintSearch => 'Ricerca...';

  @override
  String get labelFeatureName => 'Nome';

  @override
  String get labelFeatureDescription => 'Descrizione (facoltativa)';

  @override
  String get labelFeatureType => 'Tipo:';

  @override
  String get labelPassive => 'Passivo';

  @override
  String get labelActive => 'Attivo';

  @override
  String get spellsTooltipAdd => 'Aggiungi incantesimo';

  @override
  String get spellsRemoveTitle => 'Rimuovere l\'incantesimo?';

  @override
  String spellsRemoveContent(String name) {
    return 'Rimuovere \" $name \" dalla tua lista degli incantesimi?';
  }

  @override
  String get spellsAtWill => 'A volontà';

  @override
  String get notesTooltipAdd => 'Aggiungi nota';

  @override
  String get notesTooltipEdit => 'Modifica nota';

  @override
  String get notesTooltipDelete => 'Elimina nota';

  @override
  String get notesDeleteTitle => 'Eliminare la nota?';

  @override
  String notesDeleteContentNamed(String title) {
    return '\" $title \" verrà eliminato definitivamente.';
  }

  @override
  String get notesDeleteContent =>
      'Questa nota verrà eliminata definitivamente.';

  @override
  String get notesLabelTitle => 'Titolo';

  @override
  String get notesLabelContent => 'Contenuto';

  @override
  String get sectionPersonality => 'Personalità';

  @override
  String get sectionPersonalityTraits => 'Tratti della personalità';

  @override
  String get sectionIdeals => 'Ideali';

  @override
  String get sectionBonds => 'Obbligazioni';

  @override
  String get sectionFlaws => 'Screpolatura';

  @override
  String get sectionBackstory => 'Retroscena';

  @override
  String inventoryEquippedSection(int count, int ac) {
    return 'Dotato ($count) · AC $ac';
  }

  @override
  String get inventoryTooltipAdd => 'Aggiungi elemento';

  @override
  String get inventoryTooltipRemove => 'Rimuovere';

  @override
  String get inventoryRemoveTitle => 'Rimuovere l\'articolo?';

  @override
  String inventoryRemoveContent(String name) {
    return 'Rimuovere $name dall\'inventario?';
  }

  @override
  String inventoryRemovePartial(int count, int total) {
    return 'Rimuoverà: $count di $total';
  }

  @override
  String get inventoryLabelQuantity => 'Quantità:';

  @override
  String get inventoryLabelQuantityToRemove => 'Quantità da rimuovere';

  @override
  String get inventoryAddCustomItem => 'Aggiungi articolo personalizzato';

  @override
  String get inventoryAddItem => 'Aggiungi articolo';

  @override
  String get inventoryLabelItemName => 'Nome *';

  @override
  String get inventoryLabelType => 'Tipo';

  @override
  String get inventoryLabelCategory => 'Categoria';

  @override
  String get inventoryLabelItemQuantity => 'Quantità';

  @override
  String get inventoryLabelDescription => 'Descrizione (facoltativa)';

  @override
  String get inventoryTypeWeapon => 'Arma';

  @override
  String get inventoryTypeArmor => 'Armatura';

  @override
  String get inventoryTypeConsumable => 'Consumabile';

  @override
  String get inventoryTypeGear => 'Ingranaggio';

  @override
  String get inventoryReplaceArmorTitle =>
      'Sostituire l\'armatura equipaggiata?';

  @override
  String get inventoryTabWeapons => 'Armi';

  @override
  String get inventoryTabArmor => 'Armatura';

  @override
  String get inventoryTabGear => 'Ingranaggio';

  @override
  String get inventoryTabMagic => 'Magia';

  @override
  String get inventoryTabTools => 'Utensili';

  @override
  String get inventoryTabCustom => 'Costume';

  @override
  String hintSearchCategory(String category) {
    return 'Cerca XARBPPHX0X ...';
  }

  @override
  String get stepChooseMethod => 'Scegli il tuo metodo:';

  @override
  String get stepStandardArray => 'Matrice standard';

  @override
  String get stepPointBuy => 'Punto Acquista';

  @override
  String get stepRoll4d6 => 'Tira 4d6';

  @override
  String get stepDistributeRacialBonuses =>
      'Distribuisci liberamente i bonus razziali';

  @override
  String get stepAssignRolls => 'Assegna ogni tiro a un attributo:';

  @override
  String get stepAssignValues => 'Assegna ciascun valore a un attributo:';

  @override
  String get stepPointsRemaining => 'Punti rimanenti:';

  @override
  String stepRaceBonus(int n) {
    return '+ Gara $n';
  }

  @override
  String get stepChooseSubrace => 'Scegli una sottorazza:';

  @override
  String get stepGrantedByBackground => 'Garantito dal background:';

  @override
  String stepClassSkillChoices(int count) {
    return 'Scelte delle abilità di classe ($count):';
  }

  @override
  String get stepChooseOne => 'Scegline uno';

  @override
  String get stepSelectTool => 'Seleziona uno strumento…';

  @override
  String get statAC => 'AC';

  @override
  String get statArmor => 'Armatura';

  @override
  String get statNoArmor => 'Nessuna armatura';

  @override
  String get statNoArmorShield => 'Nessuna armatura + scudo';

  @override
  String get statShieldSuffix => '+ Scudo';

  @override
  String get statSpeed => 'Velocità';

  @override
  String get statInitiative => 'Iniziativa';

  @override
  String get statProfBonus => 'Il prof Bonus';

  @override
  String get statPassivePerc => 'Percentuale passiva';

  @override
  String get statInspiration => 'Ispirazione';

  @override
  String get statXP => 'XP';

  @override
  String get statUnconsciousDying => 'Inconscio / Morente';

  @override
  String get tooltipAddTempHp => 'Aggiungi HP temporanei';

  @override
  String get tooltipChangeTempHp => 'Modifica HP temperatura';

  @override
  String get abilityStr => 'STR';

  @override
  String get abilityDex => 'DES';

  @override
  String get abilityCon => 'CON';

  @override
  String get abilityInt => 'INT';

  @override
  String get abilityWis => 'SAGGIO';

  @override
  String get abilityCha => 'CA';

  @override
  String featuresSectionRacialTraits(String name) {
    return 'Tratti razziali - $name';
  }

  @override
  String featuresSectionBackground(String name) {
    return 'Funzionalità di sfondo: $name';
  }

  @override
  String featuresSectionClass(String name) {
    return 'Privilegi di classe: $name';
  }

  @override
  String featuresSectionSubclass(String name) {
    return 'Caratteristiche della sottoclasse: $name';
  }

  @override
  String get featuresSectionTools => 'Competenze negli strumenti';

  @override
  String get featuresSectionExtra => 'Funzionalità aggiuntive';

  @override
  String get spellsNoSpellcasting => 'Nessun lancio di incantesimi';

  @override
  String get spellsNoSpellcastingDesc =>
      'Questa classe non ha capacità di lanciare incantesimi.';

  @override
  String get spellsSlots => 'Slot per incantesimi';

  @override
  String get spellsSpellcasting => 'Incantesimi';

  @override
  String get spellsAttack => 'Attacco';

  @override
  String get spellsSaveDC => 'Salva DC';

  @override
  String get spellsCantrips => 'Trucchetti';

  @override
  String get spellsPrepared => 'Preparato';

  @override
  String get spellsKnown => 'Conosciuto';

  @override
  String get spellsEmpty =>
      'Nessun incantesimo ancora aggiunto.\nTocca + per sfogliare gli incantesimi.';

  @override
  String spellsSlotLevel(int level) {
    return 'Livello $level';
  }

  @override
  String spellsLevelN(int level) {
    return 'Livello XARBPPHX0X';
  }

  @override
  String get inventoryCurrency => 'Valuta';

  @override
  String inventoryCarriedSection(int count) {
    return 'Portato ($count)';
  }

  @override
  String get inventoryInventory => 'Inventario';

  @override
  String get inventoryEmpty => 'Nessun articolo ancora Tocca + per aggiungere.';

  @override
  String get inventoryAmmunition => 'Munizioni';

  @override
  String get coinCopper => 'Rame';

  @override
  String get coinSilver => 'Argento';

  @override
  String get coinElectrum => 'Elettro';

  @override
  String get coinGold => 'Oro';

  @override
  String get coinPlatinum => 'Platino';

  @override
  String get inventoryGroupSimpleMelee => 'Mischia semplice';

  @override
  String get inventoryGroupSimpleRanged => 'A distanza semplice';

  @override
  String get inventoryGroupMartialMelee => 'Mischia Marziale';

  @override
  String get inventoryGroupMartialRanged => 'Marziale a distanza';

  @override
  String get inventoryGroupLightArmor => 'Armatura leggera';

  @override
  String get inventoryGroupMediumArmor => 'Armatura media';

  @override
  String get inventoryGroupHeavyArmor => 'Armatura pesante';

  @override
  String get inventoryGroupShields => 'Scudi';

  @override
  String get inventoryGroupAdventuringGear => 'Attrezzatura da avventura';

  @override
  String get inventoryGroupAmmunition => 'Munizioni';

  @override
  String get inventoryGroupArcaneFocus => 'Focalizzazione arcana';

  @override
  String get inventoryGroupClothing => 'Vestiario';

  @override
  String get inventoryGroupContainer => 'Contenitore';

  @override
  String get inventoryGroupPoison => 'Veleno';

  @override
  String get inventoryGroupPotions => 'Pozioni';

  @override
  String get inventoryGroupRings => 'Anelli';

  @override
  String get inventoryGroupWands => 'Bacchette';

  @override
  String get inventoryGroupWeapons => 'Armi';

  @override
  String get inventoryGroupArmor => 'Armatura';

  @override
  String get inventoryGroupWondrousItems => 'Oggetti meravigliosi';

  @override
  String get inventoryGroupArtisansTools => 'Strumenti dell\'artigiano';

  @override
  String get inventoryGroupGamingSets => 'Set da gioco';

  @override
  String get inventoryGroupMusicalInstruments => 'Strumenti musicali';

  @override
  String get inventoryGroupOtherTools => 'Altri strumenti';

  @override
  String get armorStealthDisadvantage => 'Svantaggio della furtività';

  @override
  String get spellDetailCastingTime => 'Tempo di casting';

  @override
  String get spellDetailRange => 'Allineare';

  @override
  String get spellDetailDuration => 'Durata';

  @override
  String get spellDetailComponents => 'Componenti';

  @override
  String get spellDetailConcentration => 'Richiede concentrazione';

  @override
  String get spellDetailRitual => 'Può essere lanciato come rituale';

  @override
  String get spellDetailAtHigherLevels => 'A livelli più alti.';

  @override
  String spellDetailClasses(String classes) {
    return 'Classi: $classes';
  }

  @override
  String spellDetailLevelSchool(String ordinal, String school) {
    return '$ordinal -livello $school';
  }

  @override
  String spellDetailCantrip(String school) {
    return '$school trucchetto';
  }

  @override
  String armorSwapCurrent(String name) {
    return 'Corrente: $name';
  }

  @override
  String armorSwapAcNow(int ac) {
    return 'AC adesso: $ac';
  }

  @override
  String armorSwapAcAfter(int ac) {
    return 'AC dopo: $ac';
  }

  @override
  String get armorSwapButton => 'Scambia l\'armatura';

  @override
  String get reviewRowName => 'Nome';

  @override
  String get reviewUnnamedHero => 'Eroe senza nome';

  @override
  String get reviewRowPlayer => 'Giocatore';

  @override
  String get reviewRowSubclass => 'Sottoclasse';

  @override
  String get reviewRowHitDie => 'Colpisci morire';

  @override
  String get reviewRowSavingThrows => 'Tiri Salvezza';

  @override
  String get reviewRowSubrace => 'Sottorazza';

  @override
  String get reviewRowSpeed => 'Velocità';

  @override
  String get reviewRowLanguages => 'Lingue';

  @override
  String get reviewRowFeature => 'Caratteristica';

  @override
  String get reviewRowFromBackground => 'Dallo sfondo';

  @override
  String get reviewRowClassChoices => 'Scelte di classe';

  @override
  String get reviewRowMaxHp => 'HP massimi';

  @override
  String get reviewRowAcUnarmored => 'AC (Non armato)';

  @override
  String reviewRowAcWith(String name) {
    return 'CA con $name';
  }

  @override
  String get reviewRowProficiencyBonus => 'Bonus di competenza';

  @override
  String get reviewStartingGold => 'Inizio Oro';

  @override
  String get reviewStartingEquipment => 'Attrezzatura di partenza';

  @override
  String get reviewDeselectAll => 'Deseleziona tutto';

  @override
  String get reviewSelectAll => 'Seleziona tutto';

  @override
  String get reviewUncheckHint =>
      'Deseleziona gli articoli che non desideri aggiungere al tuo inventario.';

  @override
  String get reviewEquipmentChoices => 'Scelte dell\'attrezzatura';

  @override
  String get reviewEquipmentChoicesHint =>
      'Scegli l\'oggetto specifico per ogni slot.';

  @override
  String get reviewToolProficiencies => 'Competenze negli strumenti';

  @override
  String get reviewChooseToolProficiency =>
      'Scegli la tua competenza nello strumento:';

  @override
  String reviewChooseLanguages(int count) {
    return 'Scegli le lingue $count concesse dalla tua razza o dal tuo background.';
  }

  @override
  String get reviewChooseOne => 'Scegline uno:';

  @override
  String get stepTashaRule =>
      'Regola facoltativa di Tasha: assegna punti ASI a qualsiasi attributo';

  @override
  String get stepRollDice => 'Lancia i dadi';

  @override
  String get stepReroll => 'Rilancio';

  @override
  String get stepRollHint =>
      'Tira per generare 6 valori (4d6, lascia cadere il più basso)';

  @override
  String get stepPrimaryAbilities => 'abilità primarie:';

  @override
  String get stepNameTitle => 'Dai un nome al tuo personaggio.';

  @override
  String get stepNameHint => 'Puoi sempre modificarlo in seguito.';

  @override
  String get stepNameCharLabel => 'Nome del personaggio';

  @override
  String get stepNamePlayerLabel => 'Nome del giocatore (facoltativo)';

  @override
  String get stepHitDieLabel => 'Colpisci morire';

  @override
  String get stepSavesLabel => 'Salva';

  @override
  String get stepSpellcastingLabel => 'Incantesimi';

  @override
  String get stepOptionsLabel => 'opzioni';

  @override
  String stepChooseSubclassPrompt(String feature, int level) {
    return 'Scegli una $feature (Lv $level):';
  }

  @override
  String get stepRaceSpeedLabel => 'Velocità';

  @override
  String get stepRaceASILabel => 'ASI';

  @override
  String stepRaceSubracesAvailable(int count) {
    return '$count sottorazze disponibili';
  }

  @override
  String stepChooseSkillsHint(int count) {
    return 'Scegli $count abilità dall\'elenco delle tue lezioni.';
  }

  @override
  String get abilityStrength => 'Forza';

  @override
  String get abilityDexterity => 'Destrezza';

  @override
  String get abilityConstitution => 'Costituzione';

  @override
  String get abilityIntelligence => 'Intelligenza';

  @override
  String get abilityWisdom => 'Saggezza';

  @override
  String get abilityCharisma => 'Carisma';

  @override
  String stepFreeAsiRemaining(int remaining) {
    return 'Distribuisci liberamente i punti ASI razziali ($remaining rimanenti):';
  }

  @override
  String stepFreePicksRemaining(int total, int remaining) {
    return 'ASI senza razza: assegna +1 a $total attributi ($remaining rimanenti):';
  }

  @override
  String get stepFreePicksNoStack =>
      'Non è possibile assegnare attributi che già ricevono un bonus razziale.';

  @override
  String reviewClassEquipmentTitle(String name) {
    return 'Equipaggiamento di classe — $name';
  }

  @override
  String get reviewEquipmentIncluded => 'Incluso:';

  @override
  String get stepToolCategoryGamingSet => 'Set da gioco';

  @override
  String get stepToolCategoryInstrument => 'Strumento musicale';

  @override
  String get stepToolCategoryArtisanTool => 'Lo strumento dell\'artigiano';

  @override
  String get stepToolCategoryArtisanOrInstrument =>
      'Attrezzo o strumento dell\'artigiano';

  @override
  String exportCopied(String label) {
    return '$label copiato!';
  }

  @override
  String exportDialogTitle(String name) {
    return 'Esporta $name';
  }

  @override
  String get exportLabelToken => 'Token';

  @override
  String get exportCopyToken => 'Copia token';

  @override
  String get exportHideQr => 'Nascondi QR Code';

  @override
  String get exportShowQr => 'Mostra QR Code';

  @override
  String get exportQrTooLarge =>
      'Personaggio troppo grande per il QR code.\nUsa il token o il JSON per condividere.';

  @override
  String get exportShowJson => 'Mostra JSON';

  @override
  String get exportCopyJson => 'Copia JSON';

  @override
  String get dialogClose => 'Chiudi';

  @override
  String get importDialogTitle => 'Importa personaggio';

  @override
  String get importTokenHint => 'Incolla il token qui…';

  @override
  String get importScanQr => 'Scansiona QR Code';

  @override
  String get importUseJson => 'Usa JSON direttamente';

  @override
  String get importJsonHint => 'Incolla JSON qui…';

  @override
  String get dialogImport => 'Importa';

  @override
  String get spellBrowserTitle => 'Sfoglia incantesimi';

  @override
  String get spellBrowserFilters => 'Filtri';

  @override
  String get spellBrowserSearchHint => 'Cerca incantesimi...';

  @override
  String get filterClearAll => 'Cancella tutto';

  @override
  String get loadingLabel => 'Caricamento...';

  @override
  String spellBrowserCount(int count, String s) {
    return '$count incantesimo$s';
  }

  @override
  String get spellBrowserEmpty =>
      'Nessun incantesimo corrisponde ai filtri attuali.';

  @override
  String get spellCantrip => 'Trucchetto';

  @override
  String spellLevelN(int n) {
    return 'Liv $n';
  }

  @override
  String get castingTimeAction => 'Azione';

  @override
  String get castingTimeBonusAction => 'Azione bonus';

  @override
  String get castingTimeReaction => 'Reazione';

  @override
  String get castingTimeLonger => 'Lancio lungo';

  @override
  String get filterConcentration => 'Concentrazione';

  @override
  String get filterRitual => 'Rituale';

  @override
  String get filterAllLevels => 'Tutti i livelli';

  @override
  String get avatarChoosePhoto => 'Scegli foto';

  @override
  String get avatarRemovePhoto => 'Rimuovi foto';

  @override
  String get avatarCropPhoto => 'Ritaglia foto';

  @override
  String get avatarChangePhoto => 'Cambia foto';

  @override
  String featureAddedSnackbar(String name) {
    return '$name aggiunto!';
  }

  @override
  String get featureAddButton => 'Aggiungi caratteristica';

  @override
  String get reviewLanguageChoices => 'Scelte linguistiche';

  @override
  String get reviewLanguageTypeHint => 'Digita una lingua…';

  @override
  String get avatarRemoveConfirmTitle => 'Rimuovere la foto?';

  @override
  String get avatarRemoveConfirmBody =>
      'Questa azione non può essere annullata.';

  @override
  String get editModeBanner => 'Modifica in corso';
}
