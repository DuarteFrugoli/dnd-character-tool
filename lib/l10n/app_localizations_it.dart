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
  String get charListImportTooltip => 'Importa personaggio o backup';

  @override
  String get charListSettingsTooltip => 'Impostazioni';

  @override
  String get charListNewCharacter => 'Nuovo personaggio';

  @override
  String get charListEmpty => 'Ancora nessun personaggio';

  @override
  String get charListEmptyHint => 'Tocca + per creare il tuo primo personaggio';

  @override
  String get whatsNewTitle => 'Novità';

  @override
  String whatsNewVersionSubtitle(String version) {
    return 'Versione $version';
  }

  @override
  String get whatsNewIntro =>
      'Alcuni miglioramenti utili sono pronti per la tua prossima sessione.';

  @override
  String get whatsNewContextualRollsTitle => 'Tiri contestuali';

  @override
  String get whatsNewContextualRollsBody =>
      'Tira caratteristiche, abilità, tiri salvezza, armi e incantesimi semplici direttamente dalla scheda.';

  @override
  String get whatsNewCriticalsTitle => 'Opzioni per i critici';

  @override
  String get whatsNewCriticalsBody =>
      'Scegli come calcolare i danni critici, con opzioni di vantaggio e svantaggio quando servono.';

  @override
  String get whatsNewConfirmationsTitle => 'Conferme più chiare';

  @override
  String get whatsNewConfirmationsBody =>
      'Le azioni sicure e quelle distruttive ora sono più facili da distinguere.';

  @override
  String get whatsNewDone => 'Capito';

  @override
  String get whatsNewSummary =>
      'È arrivato il turco, il catalogo degli oggetti magici dello SRD 5.1 si è ampliato e l\'aggiornamento dei personaggi è più chiaro. Il supporto a D&D 2024 è in fase di sviluppo.';

  @override
  String get whatsNewTurkishTitle => 'Ora in turco';

  @override
  String get whatsNewTurkishBody =>
      'L\'interfaccia dell\'app e i contenuti di gioco dello SRD 5.1 sono ora disponibili in turco.';

  @override
  String get whatsNewMagicItemsTitle => 'Più oggetti magici';

  @override
  String get whatsNewMagicItemsBody =>
      'Scopri altri oggetti magici dello SRD 5.1. Sono state aggiunte anche traduzioni mancanti nelle lingue supportate.';

  @override
  String get whatsNewCharacterUpdatesTitle =>
      'Aggiornamento dei personaggi più chiaro';

  @override
  String get whatsNewCharacterUpdatesBody =>
      'Se un personaggio deve essere aggiornato, puoi creare un backup dei personaggi, aggiornarli tutti o annullare. La scheda resta chiusa finché non viene aggiornata.';

  @override
  String get whatsNew2024Title => 'D&D 2024 è in fase di sviluppo';

  @override
  String get whatsNew2024Body =>
      'Stiamo creando una modalità separata per le regole del 2024, con classi, sottoclassi, specie, incantesimi, equipaggiamento e oggetti magici aggiornati, mantenendo giocabili i personaggi del 2014. È prevista una conversione guidata facoltativa; la creazione e la conversione dei personaggi per il 2024 non sono ancora disponibili.';

  @override
  String get whatsNewSettingsSubtitle => 'Rileggi le ultime novità.';

  @override
  String get whatsNewThanks =>
      'Grazie per giocare e condividere i tuoi commenti. Le tue idee ci aiutano a decidere cosa verrà dopo.';

  @override
  String charListImportedSuccess(String name) {
    return '$name importato con successo!';
  }

  @override
  String charListDuplicatedSuccess(String name) {
    return '$name duplicato con successo!';
  }

  @override
  String get charListImportError =>
      'Errore imprevisto durante l\'importazione. Per favore riprova.';

  @override
  String get charListDuplicateError =>
      'Impossibile duplicare il personaggio. Riprova.';

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
    return 'Livello $level';
  }

  @override
  String get charCardPin => 'Appunta in alto';

  @override
  String get charCardUnpin => 'Rimuovi dai fissati';

  @override
  String get charCardChangePhoto => 'Cambia foto';

  @override
  String get charCardRename => 'Rinomina';

  @override
  String get charCardDuplicate => 'Duplica';

  @override
  String get charCardExport => 'Esporta';

  @override
  String get charCardDelete => 'Elimina';

  @override
  String charDuplicateName(String name) {
    return '$name (copia)';
  }

  @override
  String charDuplicateNameNumbered(String name, int number) {
    return '$name (copia $number)';
  }

  @override
  String get renameDialogTitle => 'Rinomina il personaggio';

  @override
  String get renameDialogLabel => 'Nome';

  @override
  String get dialogCancel => 'Annulla';

  @override
  String get dialogSave => 'Salva';

  @override
  String get deleteDialogTitle => 'Eliminare il personaggio?';

  @override
  String deleteDialogContent(String name) {
    return 'Sei sicuro di voler eliminare $name? Questa operazione non può essere annullata.';
  }

  @override
  String get dialogConfirm => 'Conferma';

  @override
  String get dialogDiscard => 'Scarta';

  @override
  String get dialogContinue => 'Continua';

  @override
  String get dialogKeepEditing => 'Continua a modificare';

  @override
  String get dialogRemove => 'Rimuovi';

  @override
  String get dialogAdd => 'Aggiungi';

  @override
  String get dialogDone => 'Fatto';

  @override
  String get settingsTitle => 'Impostazioni';

  @override
  String get settingsSectionTheme => 'Tema visivo';

  @override
  String get settingsDark => 'Scuro';

  @override
  String get settingsLight => 'Chiaro';

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
      'Procedura guidata passo dopo passo. Scegli classe, razza, background, competenze e caratteristiche una alla volta. Consigliata ai nuovi giocatori.';

  @override
  String get modeManualTitle => 'Manuale';

  @override
  String get modeManualSubtitle =>
      'Compila tutto manualmente. Tutti i campi sono liberi e nessun valore viene calcolato automaticamente. Ideale per i giocatori esperti.';

  @override
  String get modeRandomTitle => 'Casuale';

  @override
  String get modeRandomSubtitle =>
      'Razza, classe, background e caratteristiche vengono scelti per te. Ideale per una sfida o un\'avventura autoconclusiva.';

  @override
  String get modeSemiRandomTitle => 'Semi-casuale';

  @override
  String get modeSemiRandomSubtitle =>
      'Scegli le opzioni principali; tutto il resto viene determinato dai dadi. Ideale se hai già un\'idea per il personaggio ma vuoi qualche sorpresa.';

  @override
  String get modeComingSoon => 'Prossimamente';

  @override
  String get creationStepClass => 'Classe';

  @override
  String get creationStepRace => 'Razza';

  @override
  String get creationStepBackground => 'Background';

  @override
  String get creationStepSkills => 'Competenze';

  @override
  String get creationStepAttributes => 'Caratteristiche';

  @override
  String get creationStepName => 'Nome';

  @override
  String get creationStepReview => 'Riepilogo';

  @override
  String get creationDiscardTitle => 'Scartare il personaggio?';

  @override
  String get creationDiscardContent =>
      'Tutti i progressi andranno persi. Sei sicuro?';

  @override
  String get creationTooltipCancel => 'Annulla';

  @override
  String get creationBack => 'Indietro';

  @override
  String get creationCreateCharacter => 'Crea personaggio';

  @override
  String get detailLeaveWithoutSaving => 'Uscire senza salvare?';

  @override
  String get detailChangesWillBeDiscarded =>
      'Le modifiche verranno scartate. Per salvarle, usa il pulsante ✓ in alto a destra.';

  @override
  String get detailLeaveAndDiscard => 'Lasciare e scartare';

  @override
  String detailErrorLoading(String error) {
    return 'Errore durante il caricamento del personaggio: $error';
  }

  @override
  String get detailTooltipLongRest => 'Riposo lungo';

  @override
  String get characterActionRollDice => 'Tira i dadi';

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
  String get contextualRollCriticalApplied => 'Critico applicato';

  @override
  String get contextualRollVersatileGrip => 'Impugnatura dell\'arma';

  @override
  String get contextualRollVersatileOneHanded => 'Una mano';

  @override
  String get contextualRollVersatileTwoHanded => 'Due mani';

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
  String get skillsOrganizeTooltip => 'Organizza';

  @override
  String get skillsDisplayTitle => 'Visualizzazione delle competenze';

  @override
  String get skillsDisplayModeLabel => 'Modalità di visualizzazione';

  @override
  String get skillsDisplayByAbility => 'Per caratteristica';

  @override
  String get skillsDisplayProficiencyFirst => 'Competenti prima';

  @override
  String get skillsDisplayAlphabetical => 'Alfabetica';

  @override
  String get skillsDisplayAbilityOrder => 'Ordine delle caratteristiche';

  @override
  String get skillsDisplayProficientFirstInsideGroups =>
      'Competenti per primi all\'interno dei gruppi';

  @override
  String get skillsDisplayRestoreDefault => 'Ripristina predefinito';

  @override
  String get skillsDisplayProficientSection => 'Competenti';

  @override
  String get skillsDisplayOtherSection => 'Altre competenze';

  @override
  String get skillsDisplayAllSection => 'Tutte le competenze';

  @override
  String get detailTabStats => 'Statistiche';

  @override
  String get detailTabSkills => 'Competenze';

  @override
  String get detailTabFeatures => 'Privilegi';

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
      'Ripristinare tutti i PF e recuperare tutti gli slot degli incantesimi?';

  @override
  String get longRestButton => 'Riposo';

  @override
  String get restPickerTitle => 'Riposo';

  @override
  String get restPickerShort => 'Riposo breve';

  @override
  String get restPickerShortCaption => 'Spendi Dadi Vita per recuperare PF';

  @override
  String get restPickerLong => 'Riposo lungo';

  @override
  String get restPickerLongCaption =>
      'Recupera tutti i PF e gli slot degli incantesimi';

  @override
  String get shortRestTitle => 'Riposo breve';

  @override
  String get shortRestAvailableDice => 'Dadi Vita disponibili';

  @override
  String get shortRestSpend => 'Spendi';

  @override
  String get shortRestRolled => 'PF recuperati';

  @override
  String get shortRestRollButton => 'Tira';

  @override
  String get shortRestButton => 'Riposa';

  @override
  String get shortRestNoDice => 'Nessun Dado Vita rimasto';

  @override
  String get concentrationBannerLabel => 'Concentrazione su:';

  @override
  String get concentrationBreakButton => 'Termina';

  @override
  String get concentrationReplaceTitle => 'Sostituire la concentrazione?';

  @override
  String concentrationReplaceBody(String current, String next) {
    return 'Ti stai concentrando su $current. Lanciare $next terminerà la tua concentrazione.';
  }

  @override
  String get concentrationReplaceConfirm => 'Sostituisci';

  @override
  String get concentrationTooltip => 'Imposta concentrazione';

  @override
  String get sectionIdentity => 'Identità';

  @override
  String get sectionHitPoints => 'Punti ferita';

  @override
  String get sectionCombat => 'Combattimento';

  @override
  String get sectionProgression => 'Progressione';

  @override
  String get sectionAbilityScores => 'Punteggi di caratteristica';

  @override
  String get sectionSavingThrows => 'Competenze nei tiri salvezza';

  @override
  String get labelName => 'Nome';

  @override
  String get labelBackground => 'Background';

  @override
  String get labelChange => 'Modifica';

  @override
  String get labelAlignment => 'Allineamento';

  @override
  String get labelPlayer => 'Giocatore';

  @override
  String get labelLevel => 'Livello';

  @override
  String get tooltipLevelUp => 'Sali di livello';

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
  String get levelUpConfirm => 'Conferma avanzamento';

  @override
  String get levelUpCancel => 'Annulla';

  @override
  String get levelUpStepFeatures => 'Nuovi privilegi';

  @override
  String levelUpStepSubclass(String feature) {
    return 'Scegli $feature';
  }

  @override
  String get levelUpStepAsi => 'Miglioramento del punteggio';

  @override
  String get levelUpStepHp => 'Punti ferita';

  @override
  String get levelUpStepCantrips => 'Nuovi trucchetti';

  @override
  String get levelUpStepSpells => 'Nuovi incantesimi';

  @override
  String get levelUpStepSummary => 'Riepilogo';

  @override
  String get levelUpNoNewFeatures =>
      'Nessun nuovo privilegio di classe a questo livello.';

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
  String get levelUpFeatOption => 'Scegli un talento';

  @override
  String levelUpAsiPointsLeft(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n punti rimasti',
      one: '1 punto rimasto',
    );
    return '$_temp0';
  }

  @override
  String levelUpSpellsToLearn(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'Scegli $n incantesimi',
      one: 'Scegli 1 incantesimo',
    );
    return '$_temp0';
  }

  @override
  String get levelUpSpellRestrictedSection => 'Scuole richieste';

  @override
  String get levelUpSpellFreeSection => 'Scelta libera';

  @override
  String levelUpSpellRestrictedInstruction(int count, String schools) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Scegli $count incantesimi dalle scuole $schools.',
      one: 'Scegli 1 incantesimo dalle scuole $schools.',
    );
    return '$_temp0';
  }

  @override
  String levelUpSpellFreeInstruction(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Scegli $count incantesimi di qualsiasi scuola.',
      one: 'Scegli 1 incantesimo di qualsiasi scuola.',
    );
    return '$_temp0';
  }

  @override
  String get levelUpSpellFreeLocked =>
      'Completa prima la scelta delle scuole richieste.';

  @override
  String levelUpCantripsToLearn(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'Scegli $n trucchetti',
      one: 'Scegli 1 trucchetto',
    );
    return '$_temp0';
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
    return 'PF massimi +$n';
  }

  @override
  String levelUpSummaryAsi(String changes) {
    return 'Caratteristiche: $changes';
  }

  @override
  String levelUpSummaryFeat(String name) {
    return 'Talento: $name';
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
    return 'Trucchetti appresi: $count';
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
    return 'Trucchetto di $school';
  }

  @override
  String levelUpSpellSubtitle(int level, String school) {
    return 'Liv. $level · $school';
  }

  @override
  String get resetLevelsTitle => 'Reimposta livelli';

  @override
  String get resetLevelsConfirmBody =>
      'Questo reimposterà la progressione di classe al livello 1. Note, inventario, contenitori, valuta, immagine, storia, aspetto, razza, background e punteggi di caratteristica saranno mantenuti.\n\nLivelli di classe, incantesimi di classe, scelte di classe/sottoclasse, risorse di progressione e talenti ottenuti con l\'aumento dei punteggi di caratteristica saranno rimossi o ricalcolati. Esporta prima un backup se vuoi una copia extra.';

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
  String get labelChoose => 'Scegli';

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
  String get labelMaxHP => 'PF massimi';

  @override
  String get labelTempHP => 'PF temporanei';

  @override
  String get labelAmount => 'Quantità';

  @override
  String get labelSpeed => 'Velocità (piedi)';

  @override
  String get detailDamage => 'Danno';

  @override
  String get detailHeal => 'Cura';

  @override
  String get detailNone => 'Nessuno';

  @override
  String get tempHpDialogTitle => 'Aggiungi PF temporanei';

  @override
  String get tempHpDialogTitleReplace => 'PF temporanei';

  @override
  String tempHpCurrent(int n) {
    return 'Attuali: +$n PF temporanei';
  }

  @override
  String get tempHpNoStack =>
      'I PF temporanei non si sommano: un valore più alto sostituisce quello attuale.';

  @override
  String get tempHpReplace => 'Sostituisci';

  @override
  String statsTempHpChip(int n) {
    return '+$n PF temp.';
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
    return 'Hai raggiunto il livello $level. Conferma o modifica $feature.';
  }

  @override
  String subclassChooseBody(int level, String feature) {
    return 'Hai raggiunto il livello $level! Scegli $feature.';
  }

  @override
  String get subclassKeepCurrent => 'Mantieni la scelta attuale';

  @override
  String get subclassChangeTitle => 'Cambia sottoclasse';

  @override
  String get subclassChangeWarning =>
      'Attenzione: gli incantesimi e le competenze concesse dalla sottoclasse precedente non vengono rimossi automaticamente. Dovrai regolarli manualmente.';

  @override
  String get backgroundChooseTitle => 'Scegli un background';

  @override
  String get featuresTooltipAdd => 'Aggiungi privilegio';

  @override
  String get featuresTooltipRemove => 'Rimuovi';

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
  String get featuresRemoveTitle => 'Rimuovere il privilegio?';

  @override
  String featuresRemoveContent(String name) {
    return '\"$name\" verrà rimosso.';
  }

  @override
  String get featuresNoneAvailable => 'Nessun privilegio disponibile.';

  @override
  String get featuresAddLabel => 'Aggiungi privilegio';

  @override
  String get featuresLoadError =>
      'Errore durante il caricamento dei privilegi.';

  @override
  String get hintSearch => 'Cerca...';

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
    return 'Rimuovere \"$name\" dalla tua lista degli incantesimi?';
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
    return '\"$title\" verrà eliminata definitivamente.';
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
      'Prova un\'altra ricerca o rimuovi il filtro per tag.';

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
  String get notesTooltipUnpin => 'Rimuovi dai fissati';

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
  String get sectionBonds => 'Legami';

  @override
  String get sectionFlaws => 'Difetti';

  @override
  String get sectionBackstory => 'Retroscena';

  @override
  String inventoryEquippedSection(int count, int ac) {
    return 'Equipaggiati ($count) · CA $ac';
  }

  @override
  String get inventoryTooltipAdd => 'Aggiungi oggetto';

  @override
  String get inventoryTooltipRemove => 'Rimuovi';

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
  String get inventoryRemoveTitle => 'Rimuovere l\'oggetto?';

  @override
  String inventoryRemoveContent(String name) {
    return 'Rimuovere $name dall\'inventario?';
  }

  @override
  String inventoryRemovePartial(int count, int total) {
    return 'Da rimuovere: $count di $total';
  }

  @override
  String get inventoryRemoveContainerTitle => 'Rimuovere il contenitore?';

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
  String get inventoryAddCustomItem => 'Aggiungi oggetto personalizzato';

  @override
  String get inventoryAddItem => 'Aggiungi oggetto';

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
  String get weightCarried => 'Trasportato';

  @override
  String get weightCapacity => 'Capacità';

  @override
  String get weightEncumbered => 'Appesantito';

  @override
  String get weightHeavilyEncumbered => 'Molto appesantito';

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
  String get inventoryTypeGear => 'Equipaggiamento';

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
  String get inventoryDetailBaseAc => 'CA di base';

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
  String get inventoryTabGear => 'Equipaggiamento';

  @override
  String get inventoryTabMagic => 'Oggetti magici';

  @override
  String get inventoryTabTools => 'Strumenti';

  @override
  String get inventoryTabCustom => 'Personalizzati';

  @override
  String hintSearchCategory(String category) {
    return 'Cerca $category...';
  }

  @override
  String get stepChooseMethod => 'Scegli il tuo metodo:';

  @override
  String get stepStandardArray => 'Serie standard';

  @override
  String get stepPointBuy => 'Acquisto di punti';

  @override
  String get stepRoll4d6 => 'Tira 4d6';

  @override
  String get stepDistributeRacialBonuses =>
      'Distribuisci liberamente i bonus razziali';

  @override
  String get stepAssignRolls => 'Assegna ogni tiro a una caratteristica:';

  @override
  String get stepAssignValues => 'Assegna ogni valore a una caratteristica:';

  @override
  String get stepPointsRemaining => 'Punti rimanenti:';

  @override
  String stepRaceBonus(int n) {
    return 'Bonus razziale: +$n';
  }

  @override
  String get stepChooseSubrace => 'Scegli una sottorazza:';

  @override
  String get stepGrantedByBackground => 'Garantito dal background:';

  @override
  String stepClassSkillChoices(int count) {
    return 'Competenze di classe da scegliere ($count):';
  }

  @override
  String get stepChooseOne => 'Scegline uno';

  @override
  String get stepSelectTool => 'Seleziona uno strumento…';

  @override
  String get statAC => 'CA';

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
  String get statProfBonus => 'Bonus di competenza';

  @override
  String get statPassivePerc => 'Percezione passiva';

  @override
  String get statInspiration => 'Ispirazione';

  @override
  String get statXP => 'PE';

  @override
  String get inspirationGranted => 'Concessa';

  @override
  String get inspirationNotGranted => 'Non concessa';

  @override
  String statLevel(int level) {
    return 'Livello $level';
  }

  @override
  String get tooltipAddXp => 'Aggiungi PE';

  @override
  String get labelLevelTable => 'Tabella dei livelli';

  @override
  String get statUnconsciousDying => 'Privo di sensi / Morente';

  @override
  String get deathSavesTitle => 'Tiri salvezza contro morte';

  @override
  String get deathSavesSuccesses => 'Successi';

  @override
  String get deathSavesFailures => 'Fallimenti';

  @override
  String get deathSavesStabilized => 'Stabilizzato';

  @override
  String get deathSavesDead => 'Morto';

  @override
  String get sectionActiveConditions => 'Condizioni attive';

  @override
  String get conditionsNone => 'Nessuna attiva';

  @override
  String get conditionsAdd => 'Aggiungi condizione';

  @override
  String get conditionsPickTitle => 'Applica condizione';

  @override
  String get conditionsRemove => 'Rimuovi condizione';

  @override
  String get tooltipAddTempHp => 'Aggiungi PF temporanei';

  @override
  String get tooltipChangeTempHp => 'Modifica PF temporanei';

  @override
  String get abilityStr => 'FOR';

  @override
  String get abilityDex => 'DES';

  @override
  String get abilityCon => 'COS';

  @override
  String get abilityInt => 'INT';

  @override
  String get abilityWis => 'SAG';

  @override
  String get abilityCha => 'CAR';

  @override
  String featuresSectionRacialTraits(String name) {
    return 'Tratti razziali - $name';
  }

  @override
  String featuresSectionBackground(String name) {
    return 'Privilegi del background: $name';
  }

  @override
  String featuresSectionClass(String name) {
    return 'Privilegi di classe: $name';
  }

  @override
  String featuresSectionSubclass(String name) {
    return 'Privilegi della sottoclasse: $name';
  }

  @override
  String get featuresSectionTools => 'Competenze negli strumenti';

  @override
  String get featuresSectionExtra => 'Privilegi aggiuntivi';

  @override
  String get spellsNoSpellcasting => 'Nessuna capacità di lanciare incantesimi';

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
  String get spellsSaveDC => 'CD degli incantesimi';

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
    return 'Livello $level';
  }

  @override
  String get spellsInnateHeader => 'Incantesimi razziali';

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
  String get spellsExtrasHeader => 'Incantesimi extra';

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
    return 'Includi incantesimi oltre il tuo livello massimo (liv. $max)';
  }

  @override
  String get spellFilterCantrip => 'Trucchetto';

  @override
  String spellFilterLvl(int n) {
    return 'Liv. $n';
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
  String get inventoryCurrency => 'Monete';

  @override
  String inventoryCarriedSection(int count) {
    return 'Trasportati ($count)';
  }

  @override
  String inventoryEquippableSection(int count) {
    return 'Equipaggiabili ($count)';
  }

  @override
  String get inventoryEquipHint =>
      'Tocca l\'icona circolare a sinistra per equipaggiare o togliere un oggetto';

  @override
  String get inventoryInventory => 'Inventario';

  @override
  String get inventoryEmpty =>
      'Ancora nessun oggetto. Tocca + per aggiungerne uno.';

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
  String get inventoryGroupSimpleMelee => 'Armi semplici da mischia';

  @override
  String get inventoryGroupSimpleRanged => 'Armi semplici a distanza';

  @override
  String get inventoryGroupMartialMelee => 'Armi da guerra da mischia';

  @override
  String get inventoryGroupMartialRanged => 'Armi da guerra a distanza';

  @override
  String get inventoryGroupLightArmor => 'Armatura leggera';

  @override
  String get inventoryGroupMediumArmor => 'Armatura media';

  @override
  String get inventoryGroupHeavyArmor => 'Armatura pesante';

  @override
  String get inventoryGroupShields => 'Scudi';

  @override
  String get inventoryGroupAdventuringGear => 'Equipaggiamento da avventura';

  @override
  String get inventoryGroupAmmunition => 'Munizioni';

  @override
  String get inventoryGroupArcaneFocus => 'Focus arcani';

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
  String get armorStealthDisadvantage => 'Svantaggio alle prove di Furtività';

  @override
  String get spellDetailCastingTime => 'Tempo di lancio';

  @override
  String get spellDetailRange => 'Gittata';

  @override
  String get spellRangeSelf => 'Incantatore';

  @override
  String get spellRangeTouch => 'Tocco';

  @override
  String get spellRangeSight => 'A vista';

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
  String get spellDetailAtHigherLevels => 'Ai livelli superiori';

  @override
  String spellDetailClasses(String classes) {
    return 'Classi: $classes';
  }

  @override
  String spellDetailLevelSchool(String ordinal, String school) {
    return '$school di $ordinal livello';
  }

  @override
  String spellDetailCantrip(String school) {
    return 'Trucchetto di $school';
  }

  @override
  String armorSwapCurrent(String name) {
    return 'Attuale: $name';
  }

  @override
  String armorSwapAcNow(int ac) {
    return 'CA attuale: $ac';
  }

  @override
  String armorSwapAcAfter(int ac) {
    return 'CA dopo: $ac';
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
  String get reviewRowHitDie => 'Dado Vita';

  @override
  String get reviewRowSavingThrows => 'Tiri salvezza';

  @override
  String get reviewRowSubrace => 'Sottorazza';

  @override
  String get reviewRowSpeed => 'Velocità';

  @override
  String get reviewRowLanguages => 'Lingue';

  @override
  String get reviewRowFeature => 'Privilegio';

  @override
  String get reviewRowFromBackground => 'Dal background';

  @override
  String get reviewRowClassChoices => 'Scelte di classe';

  @override
  String get reviewRowMaxHp => 'PF massimi';

  @override
  String get reviewRowAcUnarmored => 'CA (senza armatura)';

  @override
  String reviewRowAcWith(String name) {
    return 'CA con $name';
  }

  @override
  String get reviewRowProficiencyBonus => 'Bonus di competenza';

  @override
  String get reviewStartingGold => 'Oro iniziale';

  @override
  String get reviewStartingEquipment => 'Equipaggiamento iniziale';

  @override
  String get reviewDeselectAll => 'Deseleziona tutto';

  @override
  String get reviewSelectAll => 'Seleziona tutto';

  @override
  String get reviewUncheckHint =>
      'Deseleziona gli oggetti che non vuoi aggiungere all\'inventario.';

  @override
  String get reviewEquipmentChoices => 'Scelte dell\'equipaggiamento';

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
    return 'Scegli $count lingue concesse dalla tua razza o dal tuo background.';
  }

  @override
  String get reviewChooseOne => 'Scegline uno:';

  @override
  String get stepTashaRule =>
      'Regola facoltativa di Tasha: assegna i bonus razziali a qualsiasi caratteristica';

  @override
  String get stepRollDice => 'Lancia i dadi';

  @override
  String get stepReroll => 'Rilancia';

  @override
  String get stepRollHint =>
      'Tira per ottenere 6 valori (4d6, scarta il dado più basso)';

  @override
  String get stepPrimaryAbilities => 'Caratteristiche principali:';

  @override
  String get stepNameTitle => 'Dai un nome al tuo personaggio.';

  @override
  String get stepNameHint => 'Puoi sempre modificarlo in seguito.';

  @override
  String get stepNameCharLabel => 'Nome del personaggio';

  @override
  String get stepNamePlayerLabel => 'Nome del giocatore (facoltativo)';

  @override
  String get stepHitDieLabel => 'Dado Vita';

  @override
  String get stepSavesLabel => 'Tiri salvezza';

  @override
  String get stepSpellcastingLabel => 'Incantesimi';

  @override
  String get stepOptionsLabel => 'opzioni';

  @override
  String stepChooseSubclassPrompt(String feature, int level) {
    return 'Scegli $feature (liv. $level):';
  }

  @override
  String get stepRaceSpeedLabel => 'Velocità';

  @override
  String get stepRaceASILabel => 'Incremento caratteristiche';

  @override
  String stepRaceSubracesAvailable(int count) {
    return '$count sottorazze disponibili';
  }

  @override
  String stepChooseSkillsHint(int count) {
    return 'Scegli $count competenze dall\'elenco della tua classe.';
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
    return 'Bonus razziali: assegna +1 a $total caratteristiche ($remaining rimanenti):';
  }

  @override
  String get stepFreePicksNoStack =>
      'Non puoi scegliere caratteristiche che ricevono già un bonus razziale.';

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
  String get stepToolCategoryArtisanTool => 'Strumento da artigiano';

  @override
  String get stepToolCategoryArtisanOrInstrument =>
      'Strumento da artigiano o strumento musicale';

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
  String get importDialogTitle => 'Importa personaggio o backup';

  @override
  String get importUseJson => 'Usa JSON direttamente';

  @override
  String get importJsonHint => 'Incolla JSON qui…';

  @override
  String get importPickFile => 'Scegli file .dndchar o .dndbackup';

  @override
  String get importFileError =>
      'File .dndchar/.dndbackup non valido o danneggiato';

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
  String get filterClearAll => 'Azzera filtri';

  @override
  String get loadingLabel => 'Caricamento...';

  @override
  String spellBrowserCount(int count, String s) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count incantesimi',
      one: '1 incantesimo',
    );
    return '$_temp0';
  }

  @override
  String get spellBrowserEmpty =>
      'Nessun incantesimo corrisponde ai filtri attuali.';

  @override
  String get spellCantrip => 'Trucchetto';

  @override
  String spellLevelN(int n) {
    return 'Liv. $n';
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
  String get featureAddButton => 'Aggiungi privilegio';

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
  String get detailSheetSubclassFeaturePlaceholder =>
      'Privilegio di sottoclasse';

  @override
  String detailSheetAvailableSubclasses(String feature) {
    return '$feature disponibili';
  }

  @override
  String get detailSheetAvailableSubraces => 'Sottorazze';

  @override
  String get xpTrackingLabel => 'Tieni traccia dei PE';

  @override
  String get xpReadyToLevelUp => 'Pronto per salire di livello!';

  @override
  String get xpLevelUpNowTitle => 'Salire di livello?';

  @override
  String xpLevelUpNowMessage(int level) {
    return 'Hai abbastanza PE per raggiungere il livello $level. Vuoi salire di livello ora?';
  }

  @override
  String get xpLevelUpLater => 'Più tardi';

  @override
  String get settingsSectionUnits => 'Unità';

  @override
  String get settingsUnitSystem => 'Sistema di unità';

  @override
  String get settingsUnitImperial => 'Imperiale (ft / lb)';

  @override
  String get settingsUnitMetric => 'Metrico (m / kg)';

  @override
  String get settingsUnitSquares => 'Caselle (cas. / kg)';

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
  String get settingsContextualRollAskTitle =>
      'Mostra opzioni dei tiri contestuali';

  @override
  String get settingsContextualRollAskSubtitle =>
      'Chiede le opzioni rilevanti, come vantaggio o svantaggio, prima di tirare dalla scheda.';

  @override
  String get settingsContextualCriticalRuleTitle => 'Regola del colpo critico';

  @override
  String get settingsContextualCriticalRuleSubtitle =>
      'Usata automaticamente quando un tiro per colpire ottiene un 20 naturale.';

  @override
  String get settingsContextualCriticalRuleChoose =>
      'Scegli la regola del colpo critico';

  @override
  String get settingsContextualCriticalRuleDoubleDice =>
      'Tira il doppio dei dadi di danno';

  @override
  String get settingsContextualCriticalRuleDoubleDamage =>
      'Raddoppia il totale dei danni';

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
  String get settingsSectionApp => 'App';

  @override
  String get settingsReviewTitle => 'Valuta sul Play Store';

  @override
  String get settingsReviewSubtitle =>
      'Apri la pagina dell\'app per lasciare una valutazione o un commento.';

  @override
  String get settingsReviewOpenError => 'Impossibile aprire il Play Store.';

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
      'Questo personaggio deve essere aggiornato prima di aprirlo. Puoi eseguire un backup oppure aggiornare tutti i personaggi. Prima dell\'aggiornamento si aprirà un backup.';

  @override
  String get characterUpdateRequiredAction => 'Opzioni di aggiornamento';

  @override
  String get characterUpdateBackupAction => 'Esegui backup dei personaggi';

  @override
  String get characterUpdateAllAction => 'Aggiorna tutti i personaggi';

  @override
  String get characterUpdateApplying => 'Aggiornamento dei personaggi...';

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
      other: 'Corretto il peso di $count oggetti.',
      one: 'Corretto il peso di 1 oggetto.',
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
      other: '$count kit di equipaggiamento aperti.',
      one: '1 kit di equipaggiamento aperto.',
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
      'Slot degli incantesimi standard ricalcolati.';

  @override
  String get settingsMaintenanceChangePactMagicSlots =>
      'Slot di Magia del Patto separati.';

  @override
  String get settingsMaintenanceChangeArmorClass =>
      'Classe Armatura ricalcolata.';

  @override
  String get settingsMaintenanceChangeRuleset2014 =>
      'Questo personaggio è stato associato alle regole del 2014 (SRD 5.1).';

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
