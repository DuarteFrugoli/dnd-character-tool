// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appTitle => 'D&D-Charakter-Tool';

  @override
  String get charListTitle => 'D&D-Charaktere';

  @override
  String get charListImportTooltip => 'JSON importieren';

  @override
  String get charListSettingsTooltip => 'Einstellungen';

  @override
  String get charListNewCharacter => 'Neuer Charakter';

  @override
  String get charListEmpty => 'Noch keine Charaktere';

  @override
  String get charListEmptyHint =>
      'Tippen Sie auf +, um Ihren ersten Charakter zu erstellen';

  @override
  String charListImportedSuccess(String name) {
    return '$name erfolgreich importiert!';
  }

  @override
  String get charListImportError =>
      'Unerwarteter Fehler beim Importieren. Bitte versuchen Sie es erneut.';

  @override
  String get importErrorInvalidJson =>
      'Der eingefügte Text ist kein gültiges JSON.';

  @override
  String get importErrorNotObject => 'Ungültiges Format: JSON-Objekt erwartet.';

  @override
  String get importErrorMissingCharacter =>
      'Ungültiges JSON: Feld \"character\" nicht gefunden.';

  @override
  String get importErrorCorruptedCharacter =>
      'Charakter konnte nicht gelesen werden. Das JSON ist möglicherweise unvollständig oder von einer inkompatiblen Version.';

  @override
  String charCardLevel(int level) {
    return 'Ebene $level';
  }

  @override
  String get charCardPin => 'Oben feststecken';

  @override
  String get charCardUnpin => 'Lösen';

  @override
  String get charCardChangePhoto => 'Foto ändern';

  @override
  String get charCardRename => 'Umbenennen';

  @override
  String get charCardExport => 'Export';

  @override
  String get charCardDelete => 'Löschen';

  @override
  String get renameDialogTitle => 'Charakter umbenennen';

  @override
  String get renameDialogLabel => 'Name';

  @override
  String get dialogCancel => 'Stornieren';

  @override
  String get dialogSave => 'Speichern';

  @override
  String get deleteDialogTitle => 'Charakter löschen?';

  @override
  String deleteDialogContent(String name) {
    return 'Sind Sie sicher, dass Sie $name löschen möchten? Dies kann nicht rückgängig gemacht werden.';
  }

  @override
  String get dialogConfirm => 'Bestätigen';

  @override
  String get dialogDiscard => 'Verwerfen';

  @override
  String get dialogContinue => 'Weitermachen';

  @override
  String get dialogKeepEditing => 'Bearbeiten Sie weiter';

  @override
  String get dialogRemove => 'Entfernen';

  @override
  String get dialogAdd => 'Hinzufügen';

  @override
  String get settingsTitle => 'Einstellungen';

  @override
  String get settingsSectionTheme => 'Visuelles Thema';

  @override
  String get settingsDark => 'Dunkel';

  @override
  String get settingsLight => 'Licht';

  @override
  String get settingsChooseTheme => 'Wählen Sie ein Thema';

  @override
  String get settingsSectionLanguage => 'Sprache';

  @override
  String get settingsAppLanguage => 'App-Sprache';

  @override
  String get settingsChooseLanguage => 'Wählen Sie eine Sprache';

  @override
  String get settingsSystemDefault => 'Systemstandard';

  @override
  String get modeSelectionTitle => 'Neuer Charakter';

  @override
  String get modeSelectionQuestion =>
      'Wie möchtest du deinen Charakter erschaffen?';

  @override
  String get modeGuidedTitle => 'Geführt';

  @override
  String get modeGuidedSubtitle =>
      'Schritt-für-Schritt-Assistent. Wählen Sie nacheinander Klasse, Rasse, Hintergrund, Fähigkeiten und Attribute aus. Empfohlen für neue Spieler.';

  @override
  String get modeManualTitle => 'Handbuch';

  @override
  String get modeManualSubtitle =>
      'Füllen Sie alles selbst aus. Alle Felder sind frei und es werden keine Werte für Sie berechnet. Am besten für erfahrene Spieler.';

  @override
  String get modeRandomTitle => 'Zufällig';

  @override
  String get modeRandomSubtitle =>
      'Alles wird für Sie gewürfelt – Rasse, Klasse, Hintergrund und Attribute. Ideal für eine Herausforderung oder One-Shots.';

  @override
  String get modeSemiRandomTitle => 'Halbzufällig';

  @override
  String get modeSemiRandomSubtitle =>
      'Sie treffen die wichtigen Entscheidungen; alles andere ist gerollt. Gut, wenn Sie ein Konzept haben, aber Überraschungen wünschen.';

  @override
  String get modeComingSoon => 'Bald';

  @override
  String get creationStepClass => 'Klasse';

  @override
  String get creationStepRace => 'Wettrennen';

  @override
  String get creationStepBackground => 'Hintergrund';

  @override
  String get creationStepSkills => 'Fähigkeiten';

  @override
  String get creationStepAttributes => 'Attribute';

  @override
  String get creationStepName => 'Name';

  @override
  String get creationStepReview => 'Rezension';

  @override
  String get creationDiscardTitle => 'Charakter verwerfen?';

  @override
  String get creationDiscardContent =>
      'Sämtliche Fortschritte gehen verloren. Bist du sicher?';

  @override
  String get creationTooltipCancel => 'Stornieren';

  @override
  String get creationBack => 'Zurück';

  @override
  String get creationCreateCharacter => 'Charakter erstellen';

  @override
  String get detailLeaveWithoutSaving => 'Ohne zu sparen gehen?';

  @override
  String get detailChangesWillBeDiscarded =>
      'Änderungen werden verworfen. Zum Speichern nutzen Sie den ✓-Button oben rechts.';

  @override
  String get detailLeaveAndDiscard => 'Verlassen und entsorgen';

  @override
  String detailErrorLoading(String error) {
    return 'Fehler beim Laden des Zeichens: $error';
  }

  @override
  String get detailTooltipLongRest => 'Lange Pause';

  @override
  String get detailTooltipCancelEdit => 'Bearbeitung abbrechen';

  @override
  String get detailTooltipDoneEditing => 'Bearbeitung abgeschlossen';

  @override
  String get detailTooltipEditCharacter => 'Charakter bearbeiten';

  @override
  String get detailCancelEditTitle => 'Bearbeitung abbrechen?';

  @override
  String get detailCancelEditContent => 'Alle Änderungen werden verworfen.';

  @override
  String get detailFinishEditTitle => 'Bearbeitung abschließen?';

  @override
  String get detailFinishEditContent => 'Änderungen werden gespeichert.';

  @override
  String get detailTabIdentity => 'Identität';

  @override
  String get detailEditButton => 'Bearbeiten';

  @override
  String get skillsEditHint => 'Halten zum Wechseln: kein → geübt → Experte';

  @override
  String get detailTabStats => 'Statistiken';

  @override
  String get detailTabSkills => 'Fähigkeiten';

  @override
  String get detailTabFeatures => 'Merkmale';

  @override
  String get detailTabSpells => 'Zauber';

  @override
  String get detailTabInventory => 'Inventar';

  @override
  String get detailTabNotes => 'Notizen';

  @override
  String get longRestTitle => 'Lange Pause';

  @override
  String get longRestContent =>
      'HP auf Maximum wiederherstellen und alle Zauberslots wiederherstellen?';

  @override
  String get longRestButton => 'Ausruhen';

  @override
  String get sectionIdentity => 'Identität';

  @override
  String get sectionHitPoints => 'Trefferpunkte';

  @override
  String get sectionCombat => 'Kampf';

  @override
  String get sectionProgression => 'Fortschritt';

  @override
  String get sectionAbilityScores => 'Fähigkeitswerte';

  @override
  String get sectionSavingThrows => 'Wurffähigkeiten sparen';

  @override
  String get labelName => 'Name';

  @override
  String get labelBackground => 'Hintergrund';

  @override
  String get labelChange => 'Ändern';

  @override
  String get labelAlignment => 'Ausrichtung';

  @override
  String get labelPlayer => 'Spieler';

  @override
  String get labelLevel => 'Ebene';

  @override
  String get labelSubclass => 'Unterklasse';

  @override
  String get labelLanguages => 'Sprachen';

  @override
  String get hintAddLanguage => 'Sprache hinzufügen…';

  @override
  String get labelChoose => 'Wählen';

  @override
  String get sectionAppearance => 'Erscheinung';

  @override
  String get labelAge => 'Alter';

  @override
  String get labelHeight => 'Größe';

  @override
  String get labelWeight => 'Gewicht';

  @override
  String get labelEyes => 'Augen';

  @override
  String get labelSkin => 'Haut';

  @override
  String get labelHair => 'Haare';

  @override
  String get labelMaxHP => 'Maximale HP';

  @override
  String get labelTempHP => 'Temp. HP';

  @override
  String get labelAmount => 'Menge';

  @override
  String get labelSpeed => 'Geschwindigkeit (ft)';

  @override
  String get detailDamage => 'Schaden';

  @override
  String get detailHeal => 'Heilen';

  @override
  String get detailNone => 'Keiner';

  @override
  String get tempHpDialogTitle => 'Fügen Sie temporäre HP hinzu';

  @override
  String get tempHpDialogTitleReplace => 'Temporäre HP';

  @override
  String tempHpCurrent(int n) {
    return 'Aktuell: + $n temp HP';
  }

  @override
  String get tempHpNoStack =>
      'Temporäre HP werden nicht gestapelt – nur höhere Werte ersetzen die aktuellen.';

  @override
  String get tempHpReplace => 'Ersetzen';

  @override
  String subclassConfirmTitle(String feature) {
    return 'Bestätigen Sie $feature';
  }

  @override
  String subclassChooseTitle(String feature) {
    return 'Wählen Sie $feature';
  }

  @override
  String subclassConfirmBody(int level, String feature) {
    return 'Sie haben Level $level erreicht. Bestätigen oder ändern Sie Ihr $feature.';
  }

  @override
  String subclassChooseBody(int level, String feature) {
    return 'Du hast Level $level erreicht! Wählen Sie Ihr $feature.';
  }

  @override
  String get subclassKeepCurrent => 'Bleiben Sie auf dem Laufenden';

  @override
  String get subclassChangeTitle => 'Unterklasse ändern';

  @override
  String get subclassChangeWarning =>
      'Warnung: Von der vorherigen Unterklasse gewährte Zauber und Fertigkeiten werden nicht automatisch entfernt. Sie müssen sie manuell anpassen.';

  @override
  String get backgroundChooseTitle => 'Wählen Sie Hintergrund';

  @override
  String get featuresTooltipAdd => 'Funktion hinzufügen';

  @override
  String get featuresTooltipRemove => 'Entfernen';

  @override
  String get featuresTooltipEnable => 'Aktivieren';

  @override
  String get featuresTooltipDisable => 'Deaktivieren';

  @override
  String get featuresTabClass => 'Klasse';

  @override
  String get featuresTabRacial => 'Rasse';

  @override
  String get featuresTabCustom => 'Benutzerd.';

  @override
  String get featuresRemoveTitle => 'Funktion entfernen?';

  @override
  String featuresRemoveContent(String name) {
    return '„$name“ wird entfernt.';
  }

  @override
  String get featuresNoneAvailable => 'Keine Funktionen verfügbar.';

  @override
  String get featuresAddLabel => 'Funktion hinzufügen';

  @override
  String get featuresLoadError => 'Fehler beim Laden der Funktionen.';

  @override
  String get hintSearch => 'Suchen...';

  @override
  String get labelFeatureName => 'Name';

  @override
  String get labelFeatureDescription => 'Beschreibung (optional)';

  @override
  String get labelFeatureType => 'Typ:';

  @override
  String get labelPassive => 'Passiv';

  @override
  String get labelActive => 'Aktiv';

  @override
  String get spellsTooltipAdd => 'Zauber hinzufügen';

  @override
  String get spellsRemoveTitle => 'Zauber entfernen?';

  @override
  String spellsRemoveContent(String name) {
    return '„$name“ aus Ihrer Zauberliste entfernen?';
  }

  @override
  String get spellsAtWill => 'Nach Belieben';

  @override
  String get notesTooltipAdd => 'Notiz hinzufügen';

  @override
  String get notesTooltipEdit => 'Notiz bearbeiten';

  @override
  String get notesTooltipDelete => 'Notiz löschen';

  @override
  String get notesDeleteTitle => 'Notiz löschen?';

  @override
  String notesDeleteContentNamed(String title) {
    return '„$title“ wird dauerhaft gelöscht.';
  }

  @override
  String get notesDeleteContent => 'Diese Notiz wird dauerhaft gelöscht.';

  @override
  String get notesLabelTitle => 'Titel';

  @override
  String get notesLabelContent => 'Inhalt';

  @override
  String get sectionPersonalityTraits => 'Persönlichkeitsmerkmale';

  @override
  String get sectionPersonality => 'Persönlichkeit';

  @override
  String get sectionIdeals => 'Ideale';

  @override
  String get sectionBonds => 'Anleihen';

  @override
  String get sectionFlaws => 'Mängel';

  @override
  String get sectionBackstory => 'Hintergrundgeschichte';

  @override
  String inventoryEquippedSection(int count, int ac) {
    return 'Ausgestattet ($count) · AC $ac';
  }

  @override
  String get inventoryTooltipAdd => 'Artikel hinzufügen';

  @override
  String get inventoryTooltipRemove => 'Entfernen';

  @override
  String get inventoryRemoveTitle => 'Artikel entfernen?';

  @override
  String inventoryRemoveContent(String name) {
    return '$name aus dem Inventar entfernen?';
  }

  @override
  String inventoryRemovePartial(int count, int total) {
    return 'Entfernt: $count von $total';
  }

  @override
  String get inventoryLabelQuantity => 'Menge:';

  @override
  String get inventoryLabelQuantityToRemove => 'Zu entfernende Menge';

  @override
  String get inventoryAddCustomItem => 'Benutzerdefiniertes Element hinzufügen';

  @override
  String get inventoryAddItem => 'Artikel hinzufügen';

  @override
  String get inventoryLabelItemName => 'Name *';

  @override
  String get inventoryLabelType => 'Typ';

  @override
  String get inventoryLabelCategory => 'Kategorie';

  @override
  String get inventoryLabelItemQuantity => 'Menge';

  @override
  String get inventoryLabelDescription => 'Beschreibung (optional)';

  @override
  String get inventoryTypeWeapon => 'Waffe';

  @override
  String get inventoryTypeArmor => 'Rüstung';

  @override
  String get inventoryTypeConsumable => 'Verbrauchsmaterial';

  @override
  String get inventoryTypeGear => 'Gang';

  @override
  String get inventoryReplaceArmorTitle => 'Ausgerüstete Rüstung ersetzen?';

  @override
  String get inventoryTabWeapons => 'Waffen';

  @override
  String get inventoryTabArmor => 'Rüstung';

  @override
  String get inventoryTabGear => 'Gang';

  @override
  String get inventoryTabMagic => 'Magie';

  @override
  String get inventoryTabTools => 'Werkzeuge';

  @override
  String get inventoryTabCustom => 'Brauch';

  @override
  String hintSearchCategory(String category) {
    return 'Suche $category ...';
  }

  @override
  String get stepChooseMethod => 'Wählen Sie Ihre Methode:';

  @override
  String get stepStandardArray => 'Standard-Array';

  @override
  String get stepPointBuy => 'Punktkauf';

  @override
  String get stepRoll4d6 => 'Wirf 4W6';

  @override
  String get stepDistributeRacialBonuses => 'Verteilen Sie Rassenboni frei';

  @override
  String get stepAssignRolls => 'Weisen Sie jede Rolle einem Attribut zu:';

  @override
  String get stepAssignValues => 'Weisen Sie jeden Wert einem Attribut zu:';

  @override
  String get stepPointsRemaining => 'Verbleibende Punkte:';

  @override
  String stepRaceBonus(int n) {
    return '+ $n-Rennen';
  }

  @override
  String get stepChooseSubrace => 'Wählen Sie eine Unterrasse:';

  @override
  String get stepGrantedByBackground => 'Aufgrund des Hintergrunds gewährt:';

  @override
  String stepClassSkillChoices(int count) {
    return 'Klassenfähigkeitsauswahl ( $count ):';
  }

  @override
  String get stepChooseOne => 'Wählen Sie eine aus';

  @override
  String get stepSelectTool => 'Wählen Sie ein Werkzeug aus…';

  @override
  String get statAC => 'Wechselstrom';

  @override
  String get statArmor => 'Rüstung';

  @override
  String get statNoArmor => 'Keine Rüstung';

  @override
  String get statNoArmorShield => 'Keine Rüstung + Schild';

  @override
  String get statShieldSuffix => '+ Schild';

  @override
  String get statSpeed => 'Geschwindigkeit';

  @override
  String get statInitiative => 'Initiative';

  @override
  String get statProfBonus => 'Prof. Bonus';

  @override
  String get statPassivePerc => 'Passiver Perc';

  @override
  String get statInspiration => 'Inspiration';

  @override
  String get statXP => 'EP';

  @override
  String get inspirationGranted => 'Gewährt';

  @override
  String get inspirationNotGranted => 'Nicht gewährt';

  @override
  String statLevel(int level) {
    return 'Stufe $level';
  }

  @override
  String get tooltipAddXp => 'EP hinzufügen';

  @override
  String get labelLevelTable => 'Stufentabelle';

  @override
  String get statUnconsciousDying => 'Bewusstlos / Sterbend';

  @override
  String get tooltipAddTempHp => 'Fügen Sie temporäre HP hinzu';

  @override
  String get tooltipChangeTempHp => 'Temperatur-HP ändern';

  @override
  String get abilityStr => 'STR';

  @override
  String get abilityDex => 'DEX';

  @override
  String get abilityCon => 'CON';

  @override
  String get abilityInt => 'INT';

  @override
  String get abilityWis => 'WIS';

  @override
  String get abilityCha => 'CHA';

  @override
  String featuresSectionRacialTraits(String name) {
    return 'Rassenmerkmale – $name';
  }

  @override
  String featuresSectionBackground(String name) {
    return 'Hintergrundfunktion – $name';
  }

  @override
  String featuresSectionClass(String name) {
    return 'Klassenmerkmale – $name';
  }

  @override
  String featuresSectionSubclass(String name) {
    return 'Unterklassenfunktionen – $name';
  }

  @override
  String get featuresSectionTools => 'Werkzeugkenntnisse';

  @override
  String get featuresSectionExtra => 'Zusätzliche Funktionen';

  @override
  String get spellsNoSpellcasting => 'Kein Zaubern';

  @override
  String get spellsNoSpellcastingDesc =>
      'Diese Klasse verfügt über keine Zauberfunktionen.';

  @override
  String get spellsSlots => 'Zauberslots';

  @override
  String get spellsSpellcasting => 'Zauberei';

  @override
  String get spellsAttack => 'Angriff';

  @override
  String get spellsSaveDC => 'Speichern Sie DC';

  @override
  String get spellsCantrips => 'Cantrips';

  @override
  String get spellsPrepared => 'Vorbereitet';

  @override
  String get spellsKnown => 'Bekannt';

  @override
  String get spellsEmpty =>
      'Noch keine Zauber hinzugefügt.\nTippen Sie auf +, um Zaubersprüche zu durchsuchen.';

  @override
  String spellsSlotLevel(int level) {
    return 'Stufe $level';
  }

  @override
  String spellsLevelN(int level) {
    return 'Ebene $level';
  }

  @override
  String get spellsInnateHeader => 'Rassenzauber';

  @override
  String get spellsDisableTitle => 'Zauber deaktivieren?';

  @override
  String get spellsEnableTitle => 'Zauber aktivieren?';

  @override
  String spellsDisableContent(String name) {
    return '\"$name\" deaktivieren? Er wird ausgegraut und kann nicht vorbereitet werden.';
  }

  @override
  String spellsEnableContent(String name) {
    return '\"$name\" aktivieren? Er wird wieder normal angezeigt.';
  }

  @override
  String get spellsDisable => 'Deaktivieren';

  @override
  String get spellsEnable => 'Aktivieren';

  @override
  String get spellsExtrasHeader => 'Zusatzzauber';

  @override
  String get inventoryCurrency => 'Währung';

  @override
  String inventoryCarriedSection(int count) {
    return 'Getragen ( $count )';
  }

  @override
  String get inventoryInventory => 'Inventar';

  @override
  String get inventoryEmpty =>
      'Noch keine Artikel. Tippen Sie zum Hinzufügen auf +.';

  @override
  String get inventoryAmmunition => 'Munition';

  @override
  String get coinCopper => 'Kupfer';

  @override
  String get coinSilver => 'Silber';

  @override
  String get coinElectrum => 'Elektrum';

  @override
  String get coinGold => 'Gold';

  @override
  String get coinPlatinum => 'Platin';

  @override
  String get inventoryGroupSimpleMelee => 'Einfacher Nahkampf';

  @override
  String get inventoryGroupSimpleRanged => 'Einfacher Fernkampf';

  @override
  String get inventoryGroupMartialMelee => 'Kampfsportlicher Nahkampf';

  @override
  String get inventoryGroupMartialRanged => 'Kampfkunst im Fernkampf';

  @override
  String get inventoryGroupLightArmor => 'Leichte Rüstung';

  @override
  String get inventoryGroupMediumArmor => 'Mittlere Rüstung';

  @override
  String get inventoryGroupHeavyArmor => 'Schwere Rüstung';

  @override
  String get inventoryGroupShields => 'Schilde';

  @override
  String get inventoryGroupAdventuringGear => 'Abenteuerausrüstung';

  @override
  String get inventoryGroupAmmunition => 'Munition';

  @override
  String get inventoryGroupArcaneFocus => 'Arkaner Fokus';

  @override
  String get inventoryGroupClothing => 'Kleidung';

  @override
  String get inventoryGroupContainer => 'Container';

  @override
  String get inventoryGroupPoison => 'Gift';

  @override
  String get inventoryGroupPotions => 'Zaubertränke';

  @override
  String get inventoryGroupRings => 'Ringe';

  @override
  String get inventoryGroupWands => 'Zauberstäbe';

  @override
  String get inventoryGroupWeapons => 'Waffen';

  @override
  String get inventoryGroupArmor => 'Rüstung';

  @override
  String get inventoryGroupWondrousItems => 'Wundersame Gegenstände';

  @override
  String get inventoryGroupArtisansTools => 'Handwerkerwerkzeuge';

  @override
  String get inventoryGroupGamingSets => 'Gaming-Sets';

  @override
  String get inventoryGroupMusicalInstruments => 'Musikinstrumente';

  @override
  String get inventoryGroupOtherTools => 'Andere Tools';

  @override
  String get armorStealthDisadvantage => 'Stealth-Nachteil';

  @override
  String get spellDetailCastingTime => 'Gießzeit';

  @override
  String get spellDetailRange => 'Reichweite';

  @override
  String get spellDetailDuration => 'Dauer';

  @override
  String get spellDetailComponents => 'Komponenten';

  @override
  String get spellDetailConcentration => 'Erfordert Konzentration';

  @override
  String get spellDetailRitual => 'Kann als Ritual gewirkt werden';

  @override
  String get spellDetailAtHigherLevels => 'Auf höheren Ebenen.';

  @override
  String spellDetailClasses(String classes) {
    return 'Klassen: $classes';
  }

  @override
  String spellDetailLevelSchool(String ordinal, String school) {
    return '$ordinal -Ebene $school';
  }

  @override
  String spellDetailCantrip(String school) {
    return '$school Cantrip';
  }

  @override
  String armorSwapCurrent(String name) {
    return 'Aktuell: $name';
  }

  @override
  String armorSwapAcNow(int ac) {
    return 'AC jetzt: $ac';
  }

  @override
  String armorSwapAcAfter(int ac) {
    return 'AC nach: $ac';
  }

  @override
  String get armorSwapButton => 'Rüstung tauschen';

  @override
  String get reviewRowName => 'Name';

  @override
  String get reviewUnnamedHero => 'Unbenannter Held';

  @override
  String get reviewRowPlayer => 'Spieler';

  @override
  String get reviewRowSubclass => 'Unterklasse';

  @override
  String get reviewRowHitDie => 'Klicken Sie auf „Sterben“.';

  @override
  String get reviewRowSavingThrows => 'Rettungswürfe';

  @override
  String get reviewRowSubrace => 'Unterrasse';

  @override
  String get reviewRowSpeed => 'Geschwindigkeit';

  @override
  String get reviewRowLanguages => 'Sprachen';

  @override
  String get reviewRowFeature => 'Besonderheit';

  @override
  String get reviewRowFromBackground => 'Aus dem Hintergrund';

  @override
  String get reviewRowClassChoices => 'Klassenauswahl';

  @override
  String get reviewRowMaxHp => 'Maximale HP';

  @override
  String get reviewRowAcUnarmored => 'AC (ungepanzert)';

  @override
  String reviewRowAcWith(String name) {
    return 'Wechselstrom mit $name';
  }

  @override
  String get reviewRowProficiencyBonus => 'Kompetenzbonus';

  @override
  String get reviewStartingGold => 'Startgold';

  @override
  String get reviewStartingEquipment => 'Startausrüstung';

  @override
  String get reviewDeselectAll => 'Alle abwählen';

  @override
  String get reviewSelectAll => 'Alles auswählen';

  @override
  String get reviewUncheckHint =>
      'Deaktivieren Sie die Artikel, die Sie nicht zu Ihrem Inventar hinzufügen möchten.';

  @override
  String get reviewEquipmentChoices => 'Ausrüstungsauswahl';

  @override
  String get reviewEquipmentChoicesHint =>
      'Wählen Sie den spezifischen Artikel für jeden Slot aus.';

  @override
  String get reviewToolProficiencies => 'Werkzeugkenntnisse';

  @override
  String get reviewChooseToolProficiency =>
      'Wählen Sie Ihre Werkzeugkompetenz:';

  @override
  String reviewChooseLanguages(int count) {
    return 'Wählen Sie die $count-Sprache(n), die Ihrer Rasse oder Ihrem Hintergrund entspricht.';
  }

  @override
  String get reviewChooseOne => 'Wählen Sie eines aus:';

  @override
  String get stepTashaRule =>
      'Tashas optionale Regel: Weisen Sie jedem Attribut ASI-Punkte zu';

  @override
  String get stepRollDice => 'Würfeln';

  @override
  String get stepReroll => 'Wiederholen';

  @override
  String get stepRollHint =>
      'Würfeln, um 6 Werte zu erzeugen (4W6, niedrigster Wert)';

  @override
  String get stepPrimaryAbilities => 'Hauptfähigkeiten:';

  @override
  String get stepNameTitle => 'Geben Sie Ihrem Charakter einen Namen.';

  @override
  String get stepNameHint => 'Sie können dies später jederzeit ändern.';

  @override
  String get stepNameCharLabel => 'Charaktername';

  @override
  String get stepNamePlayerLabel => 'Spielername (optional)';

  @override
  String get stepHitDieLabel => 'Hit sterben';

  @override
  String get stepSavesLabel => 'Spart';

  @override
  String get stepSpellcastingLabel => 'Zauberei';

  @override
  String get stepOptionsLabel => 'Optionen';

  @override
  String stepChooseSubclassPrompt(String feature, int level) {
    return 'Wählen Sie ein $feature (Lv $level):';
  }

  @override
  String get stepRaceSpeedLabel => 'Geschwindigkeit';

  @override
  String get stepRaceASILabel => 'DA ICH';

  @override
  String stepRaceSubracesAvailable(int count) {
    return '$count Unterrassen verfügbar';
  }

  @override
  String stepChooseSkillsHint(int count) {
    return 'Wählen Sie $count Fertigkeiten aus Ihrer Klassenliste aus.';
  }

  @override
  String get abilityStrength => 'Stärke';

  @override
  String get abilityDexterity => 'Geschicklichkeit';

  @override
  String get abilityConstitution => 'Verfassung';

  @override
  String get abilityIntelligence => 'Intelligenz';

  @override
  String get abilityWisdom => 'Weisheit';

  @override
  String get abilityCharisma => 'Charisma';

  @override
  String stepFreeAsiRemaining(int remaining) {
    return 'Verteilen Sie rassistische ASI-Punkte frei ($remaining verbleibend):';
  }

  @override
  String stepFreePicksRemaining(int total, int remaining) {
    return 'Rassenfreier ASI: Weisen Sie $total Attributen +1 zu ($remaining verbleibend):';
  }

  @override
  String get stepFreePicksNoStack =>
      'Kann nicht Attributen zugewiesen werden, die bereits einen Volksbonus erhalten.';

  @override
  String reviewClassEquipmentTitle(String name) {
    return 'Klassenausrüstung – $name';
  }

  @override
  String get reviewEquipmentIncluded => 'Im Lieferumfang enthalten:';

  @override
  String get stepToolCategoryGamingSet => 'Gaming-Set';

  @override
  String get stepToolCategoryInstrument => 'Musikinstrument';

  @override
  String get stepToolCategoryArtisanTool => 'Handwerkerwerkzeug';

  @override
  String get stepToolCategoryArtisanOrInstrument =>
      'Handwerkliches Werkzeug oder Instrument';

  @override
  String exportCopied(String label) {
    return '$label kopiert!';
  }

  @override
  String exportDialogTitle(String name) {
    return '$name exportieren';
  }

  @override
  String get exportLabelToken => 'Token';

  @override
  String get exportCopyToken => 'Token kopieren';

  @override
  String get exportHideQr => 'QR-Code ausblenden';

  @override
  String get exportShowQr => 'QR-Code anzeigen';

  @override
  String get exportQrTooLarge =>
      'Charakter zu groß für QR-Code.\nVerwende den Token oder JSON zum Teilen.';

  @override
  String get exportShowJson => 'JSON anzeigen';

  @override
  String get exportCopyJson => 'JSON kopieren';

  @override
  String get dialogClose => 'Schließen';

  @override
  String get importDialogTitle => 'Charakter importieren';

  @override
  String get importTokenHint => 'Token hier einfügen…';

  @override
  String get importScanQr => 'QR-Code scannen';

  @override
  String get importUseJson => 'JSON direkt verwenden';

  @override
  String get importJsonHint => 'JSON hier einfügen…';

  @override
  String get dialogImport => 'Importieren';

  @override
  String get spellBrowserTitle => 'Zauber durchsuchen';

  @override
  String get spellBrowserFilters => 'Filter';

  @override
  String get spellBrowserSearchHint => 'Zauber suchen...';

  @override
  String get filterClearAll => 'Alle löschen';

  @override
  String get loadingLabel => 'Laden...';

  @override
  String spellBrowserCount(int count, String s) {
    return '$count Zauber$s';
  }

  @override
  String get spellBrowserEmpty =>
      'Keine Zauber entsprechen den aktuellen Filtern.';

  @override
  String get spellCantrip => 'Zaubertrick';

  @override
  String spellLevelN(int n) {
    return 'Grad $n';
  }

  @override
  String get castingTimeAction => 'Aktion';

  @override
  String get castingTimeBonusAction => 'Bonusaktion';

  @override
  String get castingTimeReaction => 'Reaktion';

  @override
  String get castingTimeLonger => 'Längere Wirkzeit';

  @override
  String get filterConcentration => 'Konzentration';

  @override
  String get filterRitual => 'Ritual';

  @override
  String get filterAllLevels => 'Alle Grade';

  @override
  String get avatarChoosePhoto => 'Foto auswählen';

  @override
  String get avatarRemovePhoto => 'Foto entfernen';

  @override
  String get avatarCropPhoto => 'Foto zuschneiden';

  @override
  String get avatarChangePhoto => 'Foto ändern';

  @override
  String featureAddedSnackbar(String name) {
    return '$name hinzugefügt!';
  }

  @override
  String get featureAddButton => 'Merkmal hinzufügen';

  @override
  String get reviewLanguageChoices => 'Sprachauswahl';

  @override
  String get reviewLanguageTypeHint => 'Sprache eingeben…';

  @override
  String get avatarRemoveConfirmTitle => 'Foto entfernen?';

  @override
  String get avatarRemoveConfirmBody =>
      'Diese Aktion kann nicht rückgängig gemacht werden.';

  @override
  String get editModeBanner => 'Bearbeitung läuft';
}
