// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get appTitle => 'Strumento per i personaggi di DnD';

  @override
  String get charListTitle => 'Personaggi di DnD';

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
  String get importErrorInvalidJson => 'Il JSON incollato non è valido.';

  @override
  String get importFieldLockedHint => 'Svuota l\'altro campo per usare questo.';

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
  String get dialogDone => 'Fatto';

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
  String get characterActionRollDice => 'Tirare i dadi';

  @override
  String get characterActionResetLevels => 'Reimposta livelli';

  @override
  String get diceExpressionLabel => 'Espressione';

  @override
  String get diceExpressionHint => 'Esempio: 1d20+5 o 4d6dl1';

  @override
  String get diceExpressionHelpTooltip =>
      'Come funzionano le espressioni dei dadi';

  @override
  String get diceExpressionHelpTitle => 'Espressioni dei dadi';

  @override
  String get diceExpressionHelpBody =>
      'Usa XdY per tirare i dadi: 2d6 tira due dadi a 6 facce.\nAggiungi o sottrai modificatori: 1d20+5 o 2d6 - 1.\nUsa d% o d100 per i dadi percentuali.\nPer vantaggio/svantaggio con d20: 2d20kh1 tiene il più alto, 2d20kl1 tiene il più basso.\nTieni/scarta dadi con kh, kl, dh o dl. Esempio: 4d6dl1 tira quattro d6 e scarta il più basso.\nGli spazi sono opzionali: 2d6+1d8 e 2d6 + 1d8 funzionano entrambi.';

  @override
  String get diceQuantityLabel => 'Quantità';

  @override
  String get diceModifierLabel => 'Modificatore';

  @override
  String get diceRollButton => 'Tira';

  @override
  String get diceRerollButton => 'Tira di nuovo';

  @override
  String get diceModeNormal => 'Normale';

  @override
  String get diceModeAdvantage => 'Vantaggio';

  @override
  String get diceModeDisadvantage => 'Svantaggio';

  @override
  String get diceResultTitle => 'Risultato';

  @override
  String get diceHistoryTitle => 'Tiri recenti';

  @override
  String get diceNoRollsYet => 'Nessun tiro ancora.';

  @override
  String get diceNaturalOne => '1 naturale';

  @override
  String get diceNaturalTwenty => '20 naturale';

  @override
  String diceInvalidExpression(String message) {
    return 'Espressione dei dadi non valida: $message';
  }

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
  String get restPickerTitle => 'Riposo';

  @override
  String get restPickerShort => 'Riposo Breve';

  @override
  String get restPickerShortCaption => 'Spendi Dadi Vita per recuperare PF';

  @override
  String get restPickerLong => 'Riposo Lungo';

  @override
  String get restPickerLongCaption =>
      'Recupera PF massimi e tutti gli slot incantesimo';

  @override
  String get shortRestTitle => 'Riposo Breve';

  @override
  String get shortRestAvailableDice => 'Dadi Vita disponibili';

  @override
  String get shortRestSpend => 'Spendi';

  @override
  String get shortRestRolled => 'PF recuperati';

  @override
  String get shortRestRollButton => 'Tira';

  @override
  String get shortRestButton => 'Riposare';

  @override
  String get shortRestNoDice => 'Nessun Dado Vita rimanente';

  @override
  String get concentrationBannerLabel => 'Concentrazione su:';

  @override
  String get concentrationBreakButton => 'Terminare';

  @override
  String get concentrationReplaceTitle => 'Sostituire la concentrazione?';

  @override
  String concentrationReplaceBody(String current, String next) {
    return 'Ti stai concentrando su $current. Lanciare $next terminerà la tua concentrazione.';
  }

  @override
  String get concentrationReplaceConfirm => 'Sostituire';

  @override
  String get concentrationTooltip => 'Imposta concentrazione';

  @override
  String get sectionIdentity => 'Identità';

  @override
  String get sectionHitPoints => 'Punti ferita';

  @override
  String get sectionCombat => 'Combattere';

  @override
  String get sectionProgression => 'Progressione';

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
  String get tooltipLevelUp => 'Sali di Livello';

  @override
  String get levelUpTitle => 'Salita di livello';

  @override
  String get levelUpStepClassTarget => 'Scegli la classe da aumentare';

  @override
  String get levelUpClassTargetExisting => 'Classi attuali';

  @override
  String get levelUpClassTargetAddClass => 'Aggiungi una nuova classe';

  @override
  String levelUpClassTargetCurrentLevel(int level) {
    return 'Livello attuale $level';
  }

  @override
  String levelUpClassTargetNextClassLevel(int level) {
    return 'Livello di classe $level';
  }

  @override
  String levelUpClassTargetRequirement(String requirement) {
    return 'Richiede $requirement';
  }

  @override
  String levelUpClassTargetRequirementMissing(String requirement) {
    return 'Requisito mancante: $requirement';
  }

  @override
  String get levelUpClassTargetCurrentRequirementsMissing =>
      'La tua classe attuale non soddisfa il requisito di multiclasse.';

  @override
  String get levelUpConfirm => 'Conferma salita';

  @override
  String get levelUpCancel => 'Annulla';

  @override
  String get levelUpStepFeatures => 'Nuove abilità';

  @override
  String levelUpStepSubclass(String feature) {
    return 'Scegli $feature';
  }

  @override
  String get levelUpStepAsi => 'Miglioramento del punteggio';

  @override
  String get levelUpStepHp => 'Punti ferita';

  @override
  String get levelUpStepCantrips => 'Nuovi trucchi';

  @override
  String get levelUpStepSpells => 'Nuovi incantesimi';

  @override
  String get levelUpStepSummary => 'Riepilogo';

  @override
  String get levelUpNoNewFeatures =>
      'Nessuna nuova capacità di classe a questo livello.';

  @override
  String get featureChoicesTitle => 'Scelte dei privilegi';

  @override
  String get featureChoicesPending => 'Scelta in sospeso';

  @override
  String get featureChoicesEdit => 'Modifica scelte';

  @override
  String get featureChoicesChooseDependencyFirst =>
      'Scegli prima l\'opzione richiesta precedente.';

  @override
  String featureChoicesChooseCount(String kind, int count) {
    return 'Scegli $count $kind.';
  }

  @override
  String featureChoicesSelectedCount(int selected, int count) {
    return '$selected/$count selezionate';
  }

  @override
  String get levelUpHpRoll => 'Lancia';

  @override
  String get levelUpHpAverage => 'Media';

  @override
  String levelUpHpGained(int n) {
    return '+$n PF';
  }

  @override
  String levelUpHpFormula(int die, String mod) {
    return 'd$die + COS ($mod)';
  }

  @override
  String get levelUpAsiOption => 'Miglioramento del punteggio';

  @override
  String get levelUpFeatOption => 'Scegli un\'impresa';

  @override
  String levelUpAsiPointsLeft(int n) {
    return '$n punto/i rimanente/i';
  }

  @override
  String levelUpSpellsToLearn(int n) {
    return 'Scegli $n incantesimo/i';
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
    return 'Scegli $n trucco/i';
  }

  @override
  String get levelUpSpellSwap => 'Sostituire un incantesimo noto (opzionale)';

  @override
  String levelUpSpellSwapCurrent(String name) {
    return 'Attuale: $name';
  }

  @override
  String levelUpSummaryLevel(int level) {
    return '→ Livello $level';
  }

  @override
  String levelUpSummaryClassLevel(String className, int level) {
    return '$className livello $level';
  }

  @override
  String levelUpSummaryHp(int n) {
    return 'PF Max +$n';
  }

  @override
  String levelUpSummaryAsi(String changes) {
    return 'MPC: $changes';
  }

  @override
  String levelUpSummaryFeat(String name) {
    return 'Impresa: $name';
  }

  @override
  String levelUpSummarySubclass(String name) {
    return 'Sottoclasse: $name';
  }

  @override
  String levelUpSummarySpellsLearned(int count) {
    return 'Incantesimi appresi: $count';
  }

  @override
  String levelUpSummaryCantripsLearned(int count) {
    return 'Trucchi appresi: $count';
  }

  @override
  String levelUpSubclassAlreadyHas(String name) {
    return 'Sottoclasse attuale: $name';
  }

  @override
  String get levelUpMaxLevel => 'Già al livello massimo (20).';

  @override
  String get levelUpHpReroll => 'Rilancia / cambia';

  @override
  String get levelUpSpellSwapPickReplacement =>
      'Ora scegli un incantesimo sostitutivo';

  @override
  String get levelUpSpellSwapReplaceWith => 'Sostituire con';

  @override
  String get levelUpSpellSwapNone => 'Nessuno';

  @override
  String get levelUpSpellAlreadyKnown => 'Già noto';

  @override
  String levelUpSpellCantripSubtitle(String school) {
    return '$school (trucco)';
  }

  @override
  String levelUpSpellSubtitle(int level, String school) {
    return 'Lv $level $school';
  }

  @override
  String get resetLevelsTitle => 'Reimposta livelli';

  @override
  String get resetLevelsConfirmBody =>
      'Questo reimposterà la progressione di classe al livello 1. Note, inventario, contenitori, valuta, immagine, storia, aspetto, razza, background e punteggi caratteristica saranno mantenuti.\n\nLivelli di classe, incantesimi di classe, scelte di classe/sottoclasse, risorse di progressione e talenti da ASI saranno rimossi o ricalcolati. Esporta prima un backup se vuoi una copia extra.';

  @override
  String resetLevelsCountdown(int seconds) {
    return 'Attendi ${seconds}s';
  }

  @override
  String get resetLevelsIntro =>
      'Scegli i nuovi dati di classe di livello 1. Il reset viene salvato solo quando premi il pulsante finale.';

  @override
  String get resetLevelsSubclassRequired =>
      'Questa classe sceglie una sottoclasse al livello 1.';

  @override
  String resetLevelsInitialHp(int hp) {
    return 'PF iniziali: $hp';
  }

  @override
  String resetLevelsSelectSkills(int count) {
    return 'Scegli $count competenze di classe.';
  }

  @override
  String get resetLevelsFixedTools => 'Concesso automaticamente:';

  @override
  String resetLevelsSelectTools(int count) {
    return 'Scegli $count competenze negli strumenti.';
  }

  @override
  String get resetLevelsApply => 'Reimposta al livello 1';

  @override
  String resetLevelsApplyAndRebuild(int level) {
    return 'Reimposta e ricostruisci fino al livello $level';
  }

  @override
  String get resetLevelsIncomplete => 'Completa le scelte obbligatorie';

  @override
  String get resetLevelsApplied => 'Livelli reimpostati.';

  @override
  String resetLevelsRebuildTitle(int level) {
    return 'Ricostruisci fino al livello $level';
  }

  @override
  String resetLevelsRebuildSubtitle(int level) {
    return 'Dopo aver scelto il livello 1, l\'app aprirà i passaggi di avanzamento di livello fino al livello $level. Se annulli prima della fine, non viene salvato nulla.';
  }

  @override
  String resetLevelsRebuildStep(int level, int targetLevel) {
    return 'Ricostruzione livello $level di $targetLevel';
  }

  @override
  String get resetLevelsRebuildCancelled =>
      'Reset annullato. Nessuna modifica è stata salvata.';

  @override
  String resetLevelsRebuiltApplied(int level) {
    return 'Livelli reimpostati e ricostruiti fino al livello $level.';
  }

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
  String statsTempHpChip(int n) {
    return '+$n temp';
  }

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
  String get featuresTabFeats => 'Talenti';

  @override
  String featPrerequisite(String req) {
    return 'Prerequisito: $req';
  }

  @override
  String get featuresSectionFeats => 'Talenti';

  @override
  String get featuresTabClass => 'Classe';

  @override
  String get featuresTabRacial => 'Razziale';

  @override
  String get featuresTabCustom => 'Personaliz.';

  @override
  String get featuresTabTools => 'Strumenti';

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
  String get notesEmptyTitle => 'Nessuna nota ancora';

  @override
  String get notesEmptyHint => 'Tocca + per creare la tua prima nota.';

  @override
  String get notesUntitled => 'Senza titolo';

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
  String get notesSearchHint => 'Cerca note o tag';

  @override
  String get notesNoResultsTitle => 'Nessuna nota corrispondente';

  @override
  String get notesNoResultsHint =>
      'Prova un\'altra ricerca o cancella il filtro tag.';

  @override
  String get notesReadMore => 'Leggi altro';

  @override
  String get notesTags => 'Tag';

  @override
  String get notesAllTags => 'Tutti';

  @override
  String get notesCustomTag => 'Tag personalizzato';

  @override
  String get notesAddTag => 'Aggiungi tag';

  @override
  String get notesTagColor => 'Colore tag';

  @override
  String get notesChooseTagColor => 'Scegli colore tag';

  @override
  String get notesTooltipPin => 'Fissa nota';

  @override
  String get notesTooltipUnpin => 'Rimuovi fissaggio';

  @override
  String get notesMoveUp => 'Sposta su';

  @override
  String get notesMoveDown => 'Sposta giù';

  @override
  String get notesMoreActions => 'Altre azioni';

  @override
  String get notesPinnedSection => 'Fissate';

  @override
  String get notesOtherSection => 'Note';

  @override
  String get notesDefaultTagSession => 'Sessione';

  @override
  String get notesDefaultTagNpc => 'PNG';

  @override
  String get notesDefaultTagQuest => 'Missione';

  @override
  String get notesDefaultTagPlace => 'Luogo';

  @override
  String get notesDefaultTagLoot => 'Bottino';

  @override
  String get notesDefaultTagRule => 'Regola';

  @override
  String get sectionPersonalityTraits => 'Tratti della personalità';

  @override
  String get sectionPersonality => 'Personalità';

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
  String get inventoryTooltipMove => 'Sposta';

  @override
  String inventoryMoveTitle(String name) {
    return 'Sposta $name';
  }

  @override
  String get inventoryMoveToInventory => 'Inventario';

  @override
  String inventoryContainersSection(int count) {
    return 'Contenitori ($count)';
  }

  @override
  String inventoryContainerContents(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count oggetti',
      one: '1 oggetto',
    );
    return '$_temp0';
  }

  @override
  String get inventoryContainerEmpty => 'Vuoto';

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
  String get inventoryRemoveContainerTitle => 'Rimuovere contenitore?';

  @override
  String inventoryRemoveContainerContent(String name, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count oggetti',
      one: '1 oggetto',
    );
    return '$name contiene $_temp0. Cosa deve succedere a essi?';
  }

  @override
  String get inventoryRemoveContainerMoveContents =>
      'Sposta gli oggetti nell\'inventario';

  @override
  String get inventoryRemoveContainerDeleteContents => 'Rimuovi tutto';

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
  String get inventoryLabelWeight => 'Peso';

  @override
  String get weightCarried => 'Portato';

  @override
  String get weightCapacity => 'Capacità';

  @override
  String get weightEncumbered => 'Appesantito';

  @override
  String get weightHeavilyEncumbered => 'Molto Appesantito';

  @override
  String get weightEnableTooltip => 'Abilita tracciamento peso';

  @override
  String get weightDisableTooltip => 'Disabilita tracciamento peso';

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
  String get inventoryTypeEquippable => 'Equipaggiabile';

  @override
  String get inventoryTypeContainer => 'Contenitore';

  @override
  String get inventoryAddItemError => 'Impossibile aggiungere l\'oggetto.';

  @override
  String inventoryLoadItemsError(String error) {
    return 'Errore nel caricamento degli oggetti:\n$error';
  }

  @override
  String inventoryNoResults(String query) {
    return 'Nessun risultato per \"$query\"';
  }

  @override
  String get inventoryTooltipEquip => 'Equipaggia';

  @override
  String get inventoryTooltipUnequip => 'Rimuovi equipaggiamento';

  @override
  String get inventoryCustomDamageDice => 'Danno (es. 1d8)';

  @override
  String get inventoryCustomDamageType => 'Tipo di danno';

  @override
  String get inventoryCustomWeaponProperties =>
      'Proprietà (separate da virgole)';

  @override
  String get inventoryCustomRangeNormal => 'Gittata normale';

  @override
  String get inventoryCustomRangeLong => 'Gittata lunga';

  @override
  String get inventoryCustomAddDexToAc => 'Aggiungi DES alla CA';

  @override
  String get inventoryCustomEquipSlot => 'Slot (es. anello, collo)';

  @override
  String get inventoryCustomCompatibleWith =>
      'Compatibile con (separato da virgole)';

  @override
  String get inventoryDetailYes => 'Sì';

  @override
  String get inventoryDetailNo => 'No';

  @override
  String get inventoryDetailMaxShort => 'max';

  @override
  String get inventoryDetailDamage => 'Danno';

  @override
  String get inventoryDetailDamageType => 'Tipo di danno';

  @override
  String get inventoryDetailWeaponProperties => 'Proprietà';

  @override
  String get inventoryDetailVersatileDamage => 'Danno versatile';

  @override
  String get inventoryDetailRange => 'Gittata';

  @override
  String get inventoryDetailRangeNormal => 'normale';

  @override
  String get inventoryDetailRangeLong => 'lunga';

  @override
  String get inventoryDetailArmorType => 'Tipo di armatura';

  @override
  String get inventoryDetailShield => 'Scudo';

  @override
  String get inventoryDetailBaseAc => 'CA base';

  @override
  String get inventoryDetailAcBonus => 'Bonus CA';

  @override
  String get inventoryDetailAddDexToAc => 'Aggiunge DES alla CA';

  @override
  String get inventoryDetailMaxDex => 'DES max';

  @override
  String get inventoryDetailStrengthMinimum => 'Forza minima';

  @override
  String get inventoryDetailEquipSlot => 'Slot';

  @override
  String get inventoryDetailRequiresAttunement => 'Richiede sintonia';

  @override
  String get inventoryDetailCapacityWeight => 'Capacità di peso';

  @override
  String get inventoryDetailCapacityVolume => 'Volume';

  @override
  String get inventoryDetailCapacityVolumeUnit => 'Unità di volume';

  @override
  String get inventoryDetailIgnoreContentWeight =>
      'Ignora il peso del contenuto';

  @override
  String get inventoryDetailEffect => 'Effetto';

  @override
  String get inventoryDetailUses => 'Usi';

  @override
  String get inventoryDetailAction => 'Azione';

  @override
  String get inventoryDetailAmmoType => 'Tipo di munizione';

  @override
  String get inventoryDetailCompatibleWith => 'Compatibile con';

  @override
  String get inventoryDetailBonus => 'Bonus';

  @override
  String get inventoryDetailExtraDamage => 'Danno extra';

  @override
  String get inventoryDetailExtraDamageType => 'Tipo di danno extra';

  @override
  String get inventoryDetailSubtype => 'Sottotipo';

  @override
  String get inventoryDetailCost => 'Costo';

  @override
  String get inventoryDetailRarity => 'Rarità';

  @override
  String get inventoryDetailFeatures => 'Caratteristiche';

  @override
  String get inventoryDetailWeightEach => 'Peso per oggetto';

  @override
  String get inventoryDetailWeightTotal => 'Peso totale';

  @override
  String get inventoryDetailState => 'Stato';

  @override
  String get inventoryDetailEquipped => 'Equipaggiato';

  @override
  String get inventoryDetailNotEquipped => 'Non equipaggiato';

  @override
  String get inventoryDetailSummary => 'Riepilogo';

  @override
  String get inventoryDetailDescription => 'Descrizione';

  @override
  String get inventoryDetailAttributes => 'Attributi';

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
  String get inspirationGranted => 'Concessa';

  @override
  String get inspirationNotGranted => 'Non concessa';

  @override
  String statLevel(int level) {
    return 'Livello $level';
  }

  @override
  String get tooltipAddXp => 'Aggiungi XP';

  @override
  String get labelLevelTable => 'Tabella dei Livelli';

  @override
  String get statUnconsciousDying => 'Inconscio / Morente';

  @override
  String get deathSavesTitle => 'Tiri Salvezza Morte';

  @override
  String get deathSavesSuccesses => 'Successi';

  @override
  String get deathSavesFailures => 'Fallimenti';

  @override
  String get deathSavesStabilized => 'Stabilizzato';

  @override
  String get deathSavesDead => 'Morto';

  @override
  String get sectionActiveConditions => 'Condizioni Attive';

  @override
  String get conditionsNone => 'Nessuna attiva';

  @override
  String get conditionsAdd => 'Aggiungi condizione';

  @override
  String get conditionsPickTitle => 'Applica Condizione';

  @override
  String get conditionsRemove => 'Rimuovi condizione';

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
  String get spellsPactMagicSlots => 'Magia del Patto';

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
  String get spellsInnateHeader => 'Incantesimi Razziali';

  @override
  String get spellsDisableTitle => 'Disattivare incantesimo?';

  @override
  String get spellsEnableTitle => 'Riattivare incantesimo?';

  @override
  String spellsDisableContent(String name) {
    return 'Disattivare \"$name\"? Sarà in grigio e non potrà essere preparato.';
  }

  @override
  String spellsEnableContent(String name) {
    return 'Riattivare \"$name\"? Tornerà a essere visualizzato normalmente.';
  }

  @override
  String get spellsDisable => 'Disattiva';

  @override
  String get spellsEnable => 'Riattiva';

  @override
  String get spellsExtrasHeader => 'Incantesimi Extra';

  @override
  String get spellFilterTitle => 'Filtri';

  @override
  String get spellFilterReset => 'Reimposta';

  @override
  String get spellFilterApply => 'Applica filtri';

  @override
  String get spellFilterSectionClasses => 'Classi';

  @override
  String get spellFilterClassesHint =>
      'Nessuna classe = mostra tutte le classi';

  @override
  String get spellFilterSectionLevel => 'Livello incantesimo';

  @override
  String get spellFilterShowAllLevels => 'Mostra tutti i livelli';

  @override
  String spellFilterShowAllLevelsHint(int max) {
    return 'Includi incantesimi oltre il tuo massimo (Lv $max)';
  }

  @override
  String get spellFilterCantrip => 'Trucco';

  @override
  String spellFilterLvl(int n) {
    return 'Lv $n';
  }

  @override
  String get spellFilterSectionCastingTime => 'Tempo di lancio';

  @override
  String get spellFilterCastAction => 'Azione';

  @override
  String get spellFilterCastBonus => 'Azione bonus';

  @override
  String get spellFilterCastReaction => 'Reazione';

  @override
  String get spellFilterCastLonger => 'Lancio lungo (1 min+)';

  @override
  String get spellFilterSectionProperties => 'Proprietà';

  @override
  String get spellFilterConcentration => 'Concentrazione';

  @override
  String get spellFilterConcentrationHint =>
      'Solo incantesimi che richiedono concentrazione';

  @override
  String get spellFilterRitual => 'Rituale';

  @override
  String get spellFilterRitualHint =>
      'Solo incantesimi che possono essere lanciati come rituali';

  @override
  String get spellFilterSectionSchool => 'Scuola di magia';

  @override
  String get spellRemoveTitle => 'Rimuovi incantesimo';

  @override
  String spellRemoveContent(String name) {
    return 'Rimuovere \"$name\" dalla tua lista di incantesimi?';
  }

  @override
  String get spellActionPrepared => 'Preparato — tocca per annullare';

  @override
  String get spellActionPrepare => 'Prepara per oggi';

  @override
  String get spellActionAdd => 'Aggiungi al personaggio';

  @override
  String get spellActionInList => 'Nella tua lista — tocca per rimuovere';

  @override
  String get spellActionAlreadyInList => 'Già nella tua lista di incantesimi';

  @override
  String get spellActionClassSpellInfo =>
      'Questo incantesimo fa già parte della lista della tua classe e non deve essere appreso.';

  @override
  String get inventoryCurrency => 'Valuta';

  @override
  String inventoryCarriedSection(int count) {
    return 'Portato ($count)';
  }

  @override
  String inventoryEquippableSection(int count) {
    return 'Equipaggiabile ($count)';
  }

  @override
  String get inventoryEquipHint =>
      'Tocca l\'icona circolare a sinistra per equipaggiare o rimuovere';

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
  String get spellRangeSelf => 'Su se stesso';

  @override
  String get spellRangeTouch => 'Tocco';

  @override
  String get spellRangeSight => 'Vista';

  @override
  String get spellRangeSpecial => 'Speciale';

  @override
  String get spellRangeUnlimited => 'Illimitato';

  @override
  String get spellAreaSphere => 'sfera';

  @override
  String get spellAreaCone => 'cono';

  @override
  String get spellAreaCube => 'cubo';

  @override
  String get spellAreaCylinder => 'cilindro';

  @override
  String get spellAreaLine => 'linea';

  @override
  String get spellAreaWall => 'muro';

  @override
  String get spellAreaCircle => 'cerchio';

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
  String get exportShowJson => 'Mostra JSON';

  @override
  String get exportCopyJson => 'Copia JSON';

  @override
  String get exportSectionFile => 'File completo';

  @override
  String get exportSectionFileCaption => 'Include la foto del personaggio';

  @override
  String get exportShareFile => 'Condividi .dndchar';

  @override
  String get dialogClose => 'Chiudi';

  @override
  String get importDialogTitle => 'Importa personaggio';

  @override
  String get importUseJson => 'Usa JSON direttamente';

  @override
  String get importJsonHint => 'Incolla JSON qui…';

  @override
  String get importPickFile => 'Scegli file .dndchar';

  @override
  String get importFileError => 'File .dndchar non valido o danneggiato';

  @override
  String get importFileIncoming => 'Importare il personaggio dal file?';

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
  String get avatarSavePhoto => 'Salva foto';

  @override
  String get avatarSaveSuccess => 'Foto salvata nella galleria';

  @override
  String get avatarSaveError => 'Impossibile salvare la foto';

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

  @override
  String get detailSheetInfoTooltip => 'Dettagli';

  @override
  String get detailSheetProficiencies => 'Competenze';

  @override
  String get detailSheetTraits => 'Tratti';

  @override
  String get detailSheetSubclassFeaturePlaceholder => 'Capacità di Sottoclasse';

  @override
  String detailSheetAvailableSubclasses(String feature) {
    return '$feature disponibili';
  }

  @override
  String get detailSheetAvailableSubraces => 'Sottorazze';

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
  String get settingsSectionUnits => 'Unità';

  @override
  String get settingsUnitSystem => 'Sistema di unità';

  @override
  String get settingsUnitImperial => 'Imperiale (ft / lb)';

  @override
  String get settingsUnitMetric => 'Metrico (m / kg)';

  @override
  String get settingsUnitSquares => 'Caselle (sq / kg)';

  @override
  String get settingsChooseUnitSystem => 'Scegli il sistema di unità';

  @override
  String get settingsSectionCharacterSheet => 'Scheda personaggio';

  @override
  String get settingsKeepScreenOnTitle => 'Mantieni lo schermo acceso';

  @override
  String get settingsKeepScreenOnSubtitle =>
      'Impedisce allo schermo di spegnersi mentre visualizzi una scheda personaggio.';

  @override
  String get settingsBackupSection => 'Backup';

  @override
  String get settingsBackupExportTitle => 'Esporta backup';

  @override
  String get settingsBackupExportSubtitle =>
      'Salva tutti i personaggi in un file di backup.';

  @override
  String get settingsBackupExporting => 'Creazione backup...';

  @override
  String get settingsBackupExportSuccess => 'Backup esportato.';

  @override
  String get settingsBackupExportError => 'Impossibile esportare il backup.';

  @override
  String get settingsBackupImportTitle => 'Importa backup';

  @override
  String get settingsBackupImportSubtitle =>
      'Ripristina i personaggi da un file .dndbackup.';

  @override
  String get settingsBackupImporting => 'Importazione backup...';

  @override
  String get settingsBackupImportError => 'Impossibile importare il backup.';

  @override
  String settingsBackupImportSuccess(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count personaggi importati dal backup.',
      one: '1 personaggio importato dal backup.',
    );
    return '$_temp0';
  }

  @override
  String get settingsMaintenanceSection => 'Manutenzione';

  @override
  String get settingsMaintenanceCheckTitle =>
      'Controlla aggiornamenti dei personaggi';

  @override
  String get settingsMaintenanceCheckSubtitle =>
      'Cerca correzioni per i dati salvati.';

  @override
  String get settingsMaintenanceUpdateTitle => 'Aggiorna personaggi';

  @override
  String get settingsMaintenanceWorking => 'Controllo aggiornamenti...';

  @override
  String get settingsMaintenanceNoUpdates =>
      'Tutti i personaggi sono già aggiornati.';

  @override
  String get settingsMaintenanceError => 'Impossibile aggiornare i personaggi.';

  @override
  String get settingsMaintenanceConfirmTitle => 'Aggiornare i personaggi?';

  @override
  String get settingsMaintenanceCompleteTitle => 'Aggiornamento completato';

  @override
  String settingsMaintenanceUpdatesFound(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count personaggi richiedono aggiornamenti.',
      one: '1 personaggio richiede un aggiornamento.',
    );
    return '$_temp0';
  }

  @override
  String settingsMaintenanceConfirmBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count personaggi richiedono aggiornamenti. Il backup verrà aperto per salvarlo o condividerlo prima di applicare le modifiche.',
      one:
          '1 personaggio richiede un aggiornamento. Il backup verrà aperto per salvarlo o condividerlo prima di applicare le modifiche.',
    );
    return '$_temp0';
  }

  @override
  String get characterUpdateRequiredTitle =>
      'Aggiornamento del personaggio richiesto';

  @override
  String get characterUpdateRequiredBody =>
      'Questo personaggio è stato salvato con una vecchia versione dei dati. Aggiorna i personaggi nelle impostazioni prima di modificarlo.';

  @override
  String get characterUpdateRequiredAction => 'Vai agli aggiornamenti';

  @override
  String settingsMaintenanceReportChecked(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count personaggi controllati.',
      one: '1 personaggio controllato.',
    );
    return '$_temp0';
  }

  @override
  String settingsMaintenanceReportUpdated(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count personaggi aggiornati.',
      one: '1 personaggio aggiornato.',
    );
    return '$_temp0';
  }

  @override
  String settingsMaintenanceReportDataChanged(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count personaggi hanno ricevuto correzioni ai dati.',
      one: '1 personaggio ha ricevuto correzioni ai dati.',
    );
    return '$_temp0';
  }

  @override
  String get settingsMaintenanceReportVersionUpdated =>
      'Versione dei dati aggiornata.';

  @override
  String settingsMaintenanceChangeEquipmentWeights(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Peso di $count oggetti corretto.',
      one: 'Peso di 1 oggetto corretto.',
    );
    return '$_temp0';
  }

  @override
  String settingsMaintenanceChangeEquipmentNormalized(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count oggetti di equipaggiamento normalizzati.',
      one: '1 oggetto di equipaggiamento normalizzato.',
    );
    return '$_temp0';
  }

  @override
  String settingsMaintenanceChangeEquipmentPacksExpanded(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pacchetti di equipaggiamento espansi.',
      one: '1 pacchetto di equipaggiamento espanso.',
    );
    return '$_temp0';
  }

  @override
  String settingsMaintenanceChangeEquipmentOrder(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Ordine di $count oggetti dell’inventario normalizzato.',
      one: 'Ordine di 1 oggetto dell’inventario normalizzato.',
    );
    return '$_temp0';
  }

  @override
  String get settingsMaintenanceChangeMulticlassStructure =>
      'Struttura delle classi preparata per il multiclasse.';

  @override
  String get settingsMaintenanceChangeSpellSlots =>
      'Slot incantesimo standard ricalcolati.';

  @override
  String get settingsMaintenanceChangePactMagicSlots =>
      'Slot di Magia del Patto separati.';

  @override
  String get settingsMaintenanceChangeArmorClass =>
      'Classe Armatura ricalcolata.';

  @override
  String settingsMaintenanceChangeGeneric(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count modifiche applicate.',
      one: '1 modifica applicata.',
    );
    return '$_temp0';
  }

  @override
  String get incomingBackupPrompt => 'Importare il backup dal file?';

  @override
  String incomingBackupSuccess(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count personaggi importati dal backup.',
      one: '1 personaggio importato dal backup.',
    );
    return '$_temp0';
  }
}
