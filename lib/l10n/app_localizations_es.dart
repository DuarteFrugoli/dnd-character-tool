// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get creationRulesetTitle => 'Elige las reglas';

  @override
  String get creationRuleset2014 => 'D&D 5e (2014)';

  @override
  String get creationRuleset2024 => 'D&D 5.5e (2024)';

  @override
  String get rulesetShort2014 => '5e';

  @override
  String get rulesetShort2024 => '5.5e';

  @override
  String get customBackgroundTitle => 'Trasfondo personalizado';

  @override
  String get customBackgroundSubtitle =>
      'Crea tu propio trasfondo con las reglas';

  @override
  String get customBackgroundName => 'Nombre del trasfondo';

  @override
  String get customBackgroundFeature => 'Rasgo del trasfondo';

  @override
  String customBackgroundSkills(int count) {
    return 'Elige $count habilidades';
  }

  @override
  String customBackgroundTools2014(int count) {
    return 'Elige hasta $count herramientas; el resto se convierte en idiomas';
  }

  @override
  String customBackgroundLanguages(int count) {
    return 'Idiomas por elegir después: $count';
  }

  @override
  String get customBackgroundEquipment2014 => 'Paquete de equipo';

  @override
  String customBackgroundAbilities(int count) {
    return 'Elige $count características para los aumentos';
  }

  @override
  String get customBackgroundTool2024 =>
      'Elige una herramienta de cualquier tipo junto con las demás competencias.';

  @override
  String customBackgroundGold2024(int gp) {
    return 'Equipo: $gp po para gastar';
  }

  @override
  String get customBackgroundSave => 'Usar este trasfondo';

  @override
  String get wildShapeTitle => 'Forma Salvaje';

  @override
  String wildShapeUses(int current, int max) {
    return 'Usos: $current/$max';
  }

  @override
  String get wildShapeUsesUnlimited => 'Usos: ilimitados';

  @override
  String wildShapeLimits(String cr) {
    return 'Formas hasta VD $cr';
  }

  @override
  String get wildShapeNoFly => 'sin velocidad de vuelo';

  @override
  String get wildShapeNoSwim => 'sin velocidad de nado';

  @override
  String wildShapeChallengeRating(String cr) {
    return 'VD $cr';
  }

  @override
  String wildShapeKnownForms(int count, int max) {
    return 'Formas conocidas: $count/$max';
  }

  @override
  String get wildShapeChooseForms =>
      'Elige tus formas conocidas en Forma Salvaje, en la pestaña Rasgos.';

  @override
  String get wildShapeAssume => 'Adoptar una forma';

  @override
  String get wildShapeLeave => 'Salir de la forma';

  @override
  String get wildShapeNoUsesLeft =>
      'No quedan usos de Forma Salvaje. Un descanso los recupera.';

  @override
  String get wildShapeSearch => 'Buscar bestias';

  @override
  String get wildShapeSeenNote => 'Elige una bestia que hayas visto antes.';

  @override
  String wildShapeConfirmTitle(String name) {
    return '¿Adoptar la forma de $name?';
  }

  @override
  String wildShapeConfirmUse(int current, int after, int max) {
    return 'Gasta 1 uso de Forma Salvaje: $current → $after de $max.';
  }

  @override
  String get wildShapeConfirmUnlimited =>
      'Forma Salvaje no tiene límite de usos en tu nivel.';

  @override
  String get wildShapeConfirmReplace => 'Esto reemplaza tu forma actual.';

  @override
  String wildShapeConfirmFormHp(int amount) {
    return 'La forma tiene $amount puntos de golpe. Al llegar a 0 vuelves a tu forma normal y el daño sobrante pasa a ti.';
  }

  @override
  String wildShapeConfirmTempHp(int amount) {
    return 'Obtienes $amount puntos de golpe temporales.';
  }

  @override
  String wildShapeConfirmTempHpKept(int current, int gain) {
    return 'Conservas tus $current puntos de golpe temporales; los $gain de la forma no se suman.';
  }

  @override
  String wildShapeConfirmDuration(int hours) {
    String _temp0 = intl.Intl.pluralLogic(
      hours,
      locale: localeName,
      other: '$hours horas',
      one: '1 hora',
    );
    return 'Dura hasta $_temp0 o hasta que termine antes.';
  }

  @override
  String get wildShapeConfirmKeeps2024 =>
      'Conservas tus puntos de golpe, Dados de Golpe, Inteligencia, Sabiduría, Carisma, rasgos de clase, idiomas, dotes y competencias. No puedes lanzar conjuros, pero la Concentración continúa.';

  @override
  String get wildShapeConfirmKeeps2014 =>
      'Conservas tu Inteligencia, Sabiduría, Carisma, alineamiento, personalidad y competencias. No puedes lanzar conjuros, pero la Concentración continúa.';

  @override
  String get wildShapeConfirm => 'Adoptar forma';

  @override
  String wildShapeActive(String name) {
    return 'En forma de $name';
  }

  @override
  String wildShapeFormHp(int current, int max) {
    return 'PG de la forma $current/$max';
  }

  @override
  String get wildShapeScoresNote =>
      'FUE, DES y CON vienen de la forma; INT, SAB y CAR son tuyos.';

  @override
  String get wildShapeAttacks => 'Ataques de la forma';

  @override
  String get wildShapeAttackRoll => 'Tirada de ataque';

  @override
  String get wildShapeStatBlock => 'Bloque de estadísticas';

  @override
  String wildShapeLeaveTitle(String name) {
    return '¿Salir de la forma de $name?';
  }

  @override
  String get wildShapeLeaveBody2024 =>
      'Vuelves a tu forma normal. El uso de Forma Salvaje no se devuelve.';

  @override
  String get wildShapeLeaveBody2014 =>
      'Vuelves a tu forma normal con los puntos de golpe que tenías antes. Se pierden los puntos de golpe restantes de la forma y el uso de Forma Salvaje.';

  @override
  String get wildShapeDamageToForm =>
      'El daño y la curación van primero a tu forma de Forma Salvaje.';

  @override
  String get changesKindWildShapeForms => 'Formas conocidas de Forma Salvaje';

  @override
  String get changesWildShapeEnds => 'La forma activa termina.';

  @override
  String get monsterSizeTiny => 'Diminuto';

  @override
  String get monsterSizeSmall => 'Pequeño';

  @override
  String get monsterSizeMedium => 'Mediano';

  @override
  String get monsterSizeLarge => 'Grande';

  @override
  String get monsterSizeHuge => 'Enorme';

  @override
  String get monsterSizeGargantuan => 'Gargantuesco';

  @override
  String get monsterSizeOr => ' o ';

  @override
  String monsterSizeType(String size, String type) {
    return '$type de tamaño $size';
  }

  @override
  String get monsterTypeBeast => 'Bestia';

  @override
  String monsterSwarmOfBeasts(String size) {
    return 'Enjambre de bestias (tamaño $size)';
  }

  @override
  String get monsterSpeedBurrow => 'Excavar';

  @override
  String get monsterSpeedClimb => 'Trepar';

  @override
  String get monsterSpeedFly => 'Volar';

  @override
  String get monsterSpeedSwim => 'Nadar';

  @override
  String get monsterSpeedHover => '(levitar)';

  @override
  String monsterSpeedChoice(String first, String second, String distance) {
    return '$first o $second $distance (a elección del DM)';
  }

  @override
  String get monsterSavingThrows => 'Tiradas de salvación';

  @override
  String get monsterSkills => 'Habilidades';

  @override
  String get monsterVulnerabilities => 'Vulnerabilidades';

  @override
  String get monsterResistances => 'Resistencias';

  @override
  String get monsterImmunities => 'Inmunidades';

  @override
  String get monsterConditionImmunities => 'Inmunidades a estados';

  @override
  String get monsterSenses => 'Sentidos';

  @override
  String get monsterSenseBlindsight => 'Vista ciega';

  @override
  String get monsterSenseDarkvision => 'Visión en la oscuridad';

  @override
  String get monsterSenseTremorsense => 'Sentido sísmico';

  @override
  String get monsterSenseTruesight => 'Visión verdadera';

  @override
  String get monsterLanguages => 'Idiomas';

  @override
  String get monsterLanguagesNone => 'Ninguno';

  @override
  String get monsterChallenge => 'Valor de desafío';

  @override
  String monsterChallengeValue(String cr, String xp, int pb) {
    return '$cr (PX $xp; BC +$pb)';
  }

  @override
  String get monsterTraits => 'Rasgos';

  @override
  String get monsterActions => 'Acciones';

  @override
  String get monsterBonusActions => 'Acciones adicionales';

  @override
  String get monsterReactions => 'Reacciones';

  @override
  String get monsterLegendaryActions => 'Acciones legendarias';

  @override
  String monsterRecharge(int min) {
    return 'Recarga $min–6';
  }

  @override
  String monsterPerDay(int uses) {
    return '$uses/día';
  }

  @override
  String get creation2024Species => 'Especie';

  @override
  String get creation2024Size => 'Tamaño';

  @override
  String get creation2024SizeSmall => 'Pequeño';

  @override
  String get creation2024SizeMedium => 'Mediano';

  @override
  String get creation2024OriginFeat => 'Dote de origen';

  @override
  String get creation2024StandardArray =>
      'Asigna 15, 14, 13, 12, 10 y 8; usa cada valor una vez.';

  @override
  String get creation2024OriginBonuses =>
      'Mejoras de característica del trasfondo';

  @override
  String get creation2024BonusTwoOne => '+2 y +1';

  @override
  String get creation2024BonusThree => '+1 a las tres';

  @override
  String get creation2024Languages => 'Elige dos idiomas además del común';

  @override
  String get creation2024ClassEquipment => 'Equipo de clase';

  @override
  String get creation2024BackgroundEquipment => 'Equipo del trasfondo';

  @override
  String get creation2024SpecificTool => 'Elige una herramienta';

  @override
  String get creation2024PrepareSpells =>
      'Prepara cuatro conjuros de tu libro de conjuros';

  @override
  String get character2024ReadOnlyNotice =>
      'La ficha de 2024 aún se está integrando. Por ahora puedes consultarla y usar notas, retrato y tiradas de dados básicas.';

  @override
  String get appTitle => 'Herramienta de personajes de DnD';

  @override
  String get charListTitle => 'Personajes de DnD';

  @override
  String get charListImportTooltip => 'Importar personaje o copia de seguridad';

  @override
  String get charListSettingsTooltip => 'Ajustes';

  @override
  String get charListNewCharacter => 'Nuevo personaje';

  @override
  String get charListEmpty => 'Aún no hay personajes';

  @override
  String get charListEmptyHint => 'Toca + para crear tu primer personaje.';

  @override
  String get whatsNewTitle => 'Novedades';

  @override
  String whatsNewVersionSubtitle(String version) {
    return 'Versión $version';
  }

  @override
  String get whatsNewIntro =>
      'Hay algunas mejoras útiles listas para tu próxima sesión.';

  @override
  String get whatsNewContextualRollsTitle => 'Tiradas contextuales';

  @override
  String get whatsNewContextualRollsBody =>
      'Tira atributos, habilidades, salvaciones, armas y conjuros simples directamente desde la ficha.';

  @override
  String get whatsNewCriticalsTitle => 'Opciones de crítico';

  @override
  String get whatsNewCriticalsBody =>
      'Elige cómo se calcula el daño crítico, con opciones de ventaja y desventaja cuando las necesites.';

  @override
  String get whatsNewConfirmationsTitle => 'Confirmaciones más claras';

  @override
  String get whatsNewConfirmationsBody =>
      'Las acciones seguras y destructivas ahora son más fáciles de distinguir.';

  @override
  String get whatsNewDone => 'Entendido';

  @override
  String get whatsNewSummary =>
      'Ya está disponible el turco, se amplió el catálogo de objetos mágicos del SRD 5.1 y ahora es más claro cómo actualizar personajes. El soporte para D&D 2024 está en desarrollo.';

  @override
  String get whatsNewTurkishTitle => 'Ahora en turco';

  @override
  String get whatsNewTurkishBody =>
      'La interfaz de la app y el contenido del SRD 5.1 ya están disponibles en turco.';

  @override
  String get whatsNewMagicItemsTitle => 'Más objetos mágicos';

  @override
  String get whatsNewMagicItemsBody =>
      'Explora más objetos mágicos del SRD 5.1. También se agregaron traducciones que faltaban en los idiomas compatibles.';

  @override
  String get whatsNewCharacterUpdatesTitle =>
      'Actualizaciones de personajes más claras';

  @override
  String get whatsNewCharacterUpdatesBody =>
      'Si un personaje necesita actualizarse, puedes hacer una copia de seguridad de tus personajes, actualizarlos todos o cancelar. La ficha permanecerá cerrada hasta que se actualice.';

  @override
  String get whatsNew2024Title => 'D&D 2024 está en desarrollo';

  @override
  String get whatsNew2024Body =>
      'Estamos creando un modo de reglas de 2024 independiente, con clases, subclases, especies, conjuros, equipo y objetos mágicos actualizados, sin dejar de permitir jugar con personajes de 2014. Planeamos una conversión guiada opcional; todavía no se puede crear ni convertir personajes para 2024.';

  @override
  String get whatsNewSettingsSubtitle =>
      'Volver a leer las novedades más recientes.';

  @override
  String get creditsTitle => 'Créditos y licencias';

  @override
  String get creditsSettingsSubtitle => 'Avisos del SRD 5.1 y del SRD 5.2.1';

  @override
  String get creditsIntro =>
      'Las reglas y el contenido de juego provienen de los System Reference Documents publicados por Wizards of the Coast. Su licencia exige los avisos siguientes, que se mantienen en su inglés original.';

  @override
  String get creditsEdition2014 => 'D&D 5e (2014)';

  @override
  String get creditsEdition2024 => 'D&D 5.5e (2024)';

  @override
  String creditsLicense(String license) {
    return 'Licencia: $license';
  }

  @override
  String get creditsSource => 'Fuente oficial';

  @override
  String get creditsUnavailable => 'No se pudo cargar este aviso.';

  @override
  String get creditsNotAffiliated =>
      'Esta app no está afiliada, respaldada, patrocinada ni aprobada específicamente por Wizards of the Coast LLC.';

  @override
  String get creditsCopyright =>
      '© 2026 Pedro Frugoli. Todos los derechos reservados.';

  @override
  String weaponMasteryNoteTitle(String name) {
    return 'Maestría: $name';
  }

  @override
  String weaponMasteryGrazeValue(int damage, String type) {
    return 'Si fallas: $damage de daño $type.';
  }

  @override
  String weaponMasteryToppleValue(int dc) {
    return 'CD de la salvación $dc.';
  }

  @override
  String weaponMasteryCleaveValue(String bonus, String damage) {
    return 'Segundo ataque: $bonus al ataque, $damage de daño.';
  }

  @override
  String get weaponMasteryTacticalMasterTitle => 'Maestro táctico';

  @override
  String weaponMasteryTacticalMaster(String options) {
    return 'En este ataque puedes usar $options en su lugar.';
  }

  @override
  String agonizingBlastNote(int bonus) {
    return 'Tu modificador de Carisma (+$bonus) se suma al daño.';
  }

  @override
  String get eldritchBlastBeamsTitle => 'Rayos';

  @override
  String eldritchBlastBeams(int count) {
    return '$count rayos: haz una tirada de ataque y una de daño por cada uno.';
  }

  @override
  String get whatsNewThanks =>
      'Gracias por jugar y compartir tus comentarios. Tus ideas nos ayudan a decidir qué viene después.';

  @override
  String get whatsNew3Summary =>
      'D&D 2024 (5.5e) ya está aquí: crea y haz avanzar personajes con las reglas del SRD 5.2.1, junto a tus personajes de 2014.';

  @override
  String get whatsNew3RulesTitle => 'Reglas de D&D 2024';

  @override
  String get whatsNew3RulesBody =>
      'Elige D&D 5e (2014) o 5.5e (2024) al crear un personaje. Los personajes de 2024 avanzan del nivel 1 al 20 con subclases, dotes, Dones épicos, multiclase y Maestría con armas.';

  @override
  String get whatsNew3RestsTitle => 'Descansos y condiciones';

  @override
  String get whatsNew3RestsBody =>
      'En 2024 el descanso largo recupera todos los Dados de Golpe y quita un nivel de Agotamiento, el Agotamiento afecta a las tiradas de d20 y a la velocidad, y el descanso corto ofrece rasgos como Arcane Recovery.';

  @override
  String get whatsNew3ResetTitle => 'Reinicios de nivel más seguros';

  @override
  String get whatsNew3ResetBody =>
      'Una revisión enumera cada cambio antes de guardar. Los reinicios deshacen lo que otorgaban las clases eliminadas y ambas ediciones pueden reconstruir hasta tu nivel anterior.';

  @override
  String get whatsNew3UpdateTitle => 'Actualización única de personajes';

  @override
  String get whatsNew3UpdateBody =>
      'Al abrir un personaje, la app pide actualizarlos todos y abre antes una copia de seguridad. Los personajes de 2014 conservan sus reglas y datos; los de 2024 guardan el historial de niveles usado para subir y reiniciar niveles.';

  @override
  String charListImportedSuccess(String name) {
    return '¡$name se importó correctamente!';
  }

  @override
  String charListDuplicatedSuccess(String name) {
    return '¡$name se duplicó correctamente!';
  }

  @override
  String get charListImportError =>
      'Error inesperado al importar. Por favor inténtalo de nuevo.';

  @override
  String get charListDuplicateError =>
      'No se pudo duplicar el personaje. Inténtalo de nuevo.';

  @override
  String get importErrorInvalidJson => 'El JSON pegado no es válido.';

  @override
  String get importFieldLockedHint => 'Borra el otro campo para usar este.';

  @override
  String get importErrorNotObject =>
      'Formato inválido: se esperaba un objeto JSON.';

  @override
  String get importErrorMissingCharacter =>
      'JSON inválido: campo \"character\" no encontrado.';

  @override
  String get importErrorCorruptedCharacter =>
      'No se pudo leer el personaje. El JSON puede estar incompleto o ser de una versión incompatible.';

  @override
  String charCardLevel(int level) {
    return 'Nivel $level';
  }

  @override
  String get charCardPin => 'Fijar arriba';

  @override
  String get charCardUnpin => 'Desprender';

  @override
  String get charCardChangePhoto => 'Cambiar foto';

  @override
  String get charCardRename => 'Rebautizar';

  @override
  String get charCardDuplicate => 'Duplicar';

  @override
  String get charCardExport => 'Exportar';

  @override
  String get charCardDelete => 'Borrar';

  @override
  String charDuplicateName(String name) {
    return '$name (copia)';
  }

  @override
  String charDuplicateNameNumbered(String name, int number) {
    return '$name (copia $number)';
  }

  @override
  String get renameDialogTitle => 'Cambiar nombre de personaje';

  @override
  String get renameDialogLabel => 'Nombre';

  @override
  String get dialogCancel => 'Cancelar';

  @override
  String get dialogSave => 'Ahorrar';

  @override
  String get deleteDialogTitle => '¿Eliminar personaje?';

  @override
  String deleteDialogContent(String name) {
    return '¿Está seguro de que desea eliminar $name? Esto no se puede deshacer.';
  }

  @override
  String get dialogConfirm => 'Confirmar';

  @override
  String get dialogDiscard => 'Desechar';

  @override
  String get dialogContinue => 'Continuar';

  @override
  String get dialogKeepEditing => 'Sigue editando';

  @override
  String get dialogRemove => 'Eliminar';

  @override
  String get dialogAdd => 'Agregar';

  @override
  String get dialogDone => 'Hecho';

  @override
  String get settingsTitle => 'Ajustes';

  @override
  String get settingsSectionTheme => 'Tema visual';

  @override
  String get settingsDark => 'Oscuro';

  @override
  String get settingsLight => 'Luz';

  @override
  String get settingsChooseTheme => 'Elige un tema';

  @override
  String get settingsSectionLanguage => 'Idioma';

  @override
  String get settingsAppLanguage => 'Idioma de la aplicación';

  @override
  String get settingsChooseLanguage => 'Elige un idioma';

  @override
  String get settingsSystemDefault => 'Valor predeterminado del sistema';

  @override
  String get modeSelectionTitle => 'Nuevo personaje';

  @override
  String get modeSelectionQuestion => '¿Cómo quieres crear tu personaje?';

  @override
  String get modeGuidedTitle => 'Guiado';

  @override
  String get modeGuidedSubtitle =>
      'Asistente paso a paso. Elija clase, raza, antecedentes, habilidades y atributos uno a la vez. Recomendado para nuevos jugadores.';

  @override
  String get modeManualTitle => 'Manual';

  @override
  String get modeManualSubtitle =>
      'Complete todo usted mismo. Todos los campos son gratuitos y no se calculan valores para usted. Lo mejor para jugadores experimentados.';

  @override
  String get modeRandomTitle => 'Aleatorio';

  @override
  String get modeRandomSubtitle =>
      'Todo está preparado para usted: raza, clase, antecedentes y atributos. Genial para un desafío o one-shots.';

  @override
  String get modeSemiRandomTitle => 'Semi-aleatorio';

  @override
  String get modeSemiRandomSubtitle =>
      'Tú eliges las opciones importantes; todo lo demás está rodado. Bueno para cuando tienes un concepto pero quieres sorpresas.';

  @override
  String get modeComingSoon => 'Pronto';

  @override
  String get creationStepClass => 'Clase';

  @override
  String get creationStepRace => 'Carrera';

  @override
  String get creationStepBackground => 'Fondo';

  @override
  String get creationStepSkills => 'Habilidades';

  @override
  String get creationStepAttributes => 'Atributos';

  @override
  String get creationStepName => 'Nombre';

  @override
  String get creationStepReview => 'Revisar';

  @override
  String get creationDiscardTitle => '¿Descartar personaje?';

  @override
  String get creationDiscardContent =>
      'Todo el progreso se perderá. ¿Está seguro?';

  @override
  String get creationTooltipCancel => 'Cancelar';

  @override
  String get creationBack => 'Atrás';

  @override
  String get creationCreateCharacter => 'Crear personaje';

  @override
  String get detailLeaveWithoutSaving => '¿Salir sin ahorrar?';

  @override
  String get detailChangesWillBeDiscarded =>
      'Los cambios serán descartados. Para guardar, use el botón ✓ en la parte superior derecha.';

  @override
  String get detailLeaveAndDiscard => 'Dejar y descartar';

  @override
  String detailErrorLoading(String error) {
    return 'Error al cargar el carácter: $error';
  }

  @override
  String get detailTooltipLongRest => 'Descanso largo';

  @override
  String get characterActionRollDice => 'Tirar dados';

  @override
  String get characterActionResetLevels => 'Reiniciar niveles';

  @override
  String get diceExpressionLabel => 'Expresión';

  @override
  String get diceExpressionHint => 'Ejemplo: 1d20+5 o 4d6dl1';

  @override
  String get diceExpressionHelpTooltip =>
      'Cómo funcionan las expresiones de dados';

  @override
  String get diceExpressionHelpTitle => 'Expresiones de dados';

  @override
  String get diceExpressionHelpBody =>
      'Usa XdY para tirar dados: 2d6 tira dos dados de 6 caras.\nSuma o resta modificadores: 1d20+5 o 2d6 - 1.\nUsa d% o d100 para dados percentiles.\nPara ventaja/desventaja con d20: 2d20kh1 conserva el mayor, 2d20kl1 conserva el menor.\nConserva/descarta dados con kh, kl, dh o dl. Ejemplo: 4d6dl1 tira cuatro d6 y descarta el menor.\nLos espacios son opcionales: 2d6+1d8 y 2d6 + 1d8 funcionan.';

  @override
  String get diceQuantityLabel => 'Cantidad';

  @override
  String get diceModifierLabel => 'Modificador';

  @override
  String get diceRollButton => 'Tirar';

  @override
  String get diceRerollButton => 'Tirar de nuevo';

  @override
  String get diceModeNormal => 'Normal';

  @override
  String get diceModeAdvantage => 'Ventaja';

  @override
  String get diceModeDisadvantage => 'Desventaja';

  @override
  String get diceResultTitle => 'Resultado';

  @override
  String get diceHistoryTitle => 'Tiradas recientes';

  @override
  String get diceNoRollsYet => 'Aún no hay tiradas.';

  @override
  String get diceNaturalOne => '1 natural';

  @override
  String get diceNaturalTwenty => '20 natural';

  @override
  String get contextualRollCriticalApplied => 'Crítico aplicado';

  @override
  String get contextualRollVersatileGrip => 'Empuñadura del arma';

  @override
  String get contextualRollVersatileOneHanded => 'Una mano';

  @override
  String get contextualRollVersatileTwoHanded => 'Dos manos';

  @override
  String diceInvalidExpression(String message) {
    return 'Expresión de dados inválida: $message';
  }

  @override
  String get detailTooltipCancelEdit => 'Cancelar edición';

  @override
  String get detailTooltipDoneEditing => 'Edición terminada';

  @override
  String get detailTooltipEditCharacter => 'Editar personaje';

  @override
  String get detailCancelEditTitle => '¿Cancelar la edición?';

  @override
  String get detailCancelEditContent => 'Todos los cambios serán descartados.';

  @override
  String get detailFinishEditTitle => '¿Terminar de editar?';

  @override
  String get detailFinishEditContent => 'Los cambios se guardarán.';

  @override
  String get detailTabIdentity => 'Identidad';

  @override
  String get detailEditButton => 'Editar';

  @override
  String get skillsEditHint =>
      'Mantén para alternar: ninguno → competente → experto';

  @override
  String get skillsOrganizeTooltip => 'Organizar';

  @override
  String get skillsDisplayTitle => 'Vista de habilidades';

  @override
  String get skillsDisplayModeLabel => 'Diseño';

  @override
  String get skillsDisplayByAbility => 'Por característica';

  @override
  String get skillsDisplayProficiencyFirst => 'Competentes primero';

  @override
  String get skillsDisplayAlphabetical => 'Alfabética';

  @override
  String get skillsDisplayAbilityOrder => 'Orden de características';

  @override
  String get skillsDisplayProficientFirstInsideGroups =>
      'Competentes primero dentro de los grupos';

  @override
  String get skillsDisplayRestoreDefault => 'Restaurar predeterminado';

  @override
  String get skillsDisplayProficientSection => 'Competentes';

  @override
  String get skillsDisplayOtherSection => 'Otras habilidades';

  @override
  String get skillsDisplayAllSection => 'Todas las habilidades';

  @override
  String get detailTabStats => 'Estadísticas';

  @override
  String get detailTabSkills => 'Habilidades';

  @override
  String get detailTabFeatures => 'Características';

  @override
  String get detailTabSpells => 'Hechizos';

  @override
  String get detailTabInventory => 'Inventario';

  @override
  String get detailTabNotes => 'Notas';

  @override
  String get longRestTitle => 'Descanso largo';

  @override
  String get longRestContent =>
      '¿Restaurar HP al máximo y recuperar todos los espacios para hechizos?';

  @override
  String get longRestButton => 'Descansar';

  @override
  String get restPickerTitle => 'Descanso';

  @override
  String get restPickerShort => 'Descanso Corto';

  @override
  String get restPickerShortCaption => 'Gasta Dados de Golpe para recuperar PG';

  @override
  String get restPickerLong => 'Descanso Largo';

  @override
  String get restPickerLongCaption =>
      'Recupera PG máximos y todos los espacios de hechizos';

  @override
  String get shortRestTitle => 'Descanso Corto';

  @override
  String get shortRestAvailableDice => 'Dados de Golpe disponibles';

  @override
  String get shortRestSpend => 'Gastar';

  @override
  String get shortRestRolled => 'PG recuperados';

  @override
  String get shortRestRollButton => 'Tirar';

  @override
  String get shortRestButton => 'Descansar';

  @override
  String get shortRestNoDice => 'Sin Dados de Golpe restantes';

  @override
  String get shortRestRecoveryTitle => 'Rasgos de recuperación';

  @override
  String shortRestRecoverySlotsHint(int levels) {
    return 'Recupera espacios gastados que sumen hasta $levels niveles (ninguno por encima del nivel 5).';
  }

  @override
  String shortRestRecoveryPointsHint(int points) {
    return 'Recupera hasta $points puntos.';
  }

  @override
  String get exhaustionLevelTitle => 'Nivel de agotamiento';

  @override
  String exhaustionEffects(String penalty, String distance) {
    return '$penalty a las pruebas de d20 · Velocidad −$distance';
  }

  @override
  String get exhaustionLethal => 'En el nivel 6, el personaje muere.';

  @override
  String rollExhaustionApplied(String modifier) {
    return 'Agotamiento $modifier aplicado al d20.';
  }

  @override
  String levelUp2024AsiHint(int max) {
    return '+2 a una característica o +1 a dos características (máximo $max).';
  }

  @override
  String levelUp2024AbilityHint(int increase, int max) {
    return '+$increase a una característica (máximo $max).';
  }

  @override
  String levelUp2024SpellLimits(
    String className,
    int cantrips,
    int prepared,
    int level,
  ) {
    return '$className: $cantrips trucos y $prepared conjuros preparados hasta el nivel $level. Elígelos en la pestaña de Conjuros.';
  }

  @override
  String resetLevels2024Body(String className) {
    return '¿Volver al nivel 1? Después podrás mantener $className o elegir otra clase. Los niveles, la subclase, las dotes, las elecciones y los conjuros obtenidos de las clases se deshacen con el historial de niveles guardado. Se conservan el origen, los cambios manuales de características, el inventario, las notas y la historia.';
  }

  @override
  String spells2024Cantrips(int count, int max) {
    return 'Trucos: $count / $max';
  }

  @override
  String spells2024Spellbook(int count, int max) {
    return 'Libro de conjuros: $count / $max';
  }

  @override
  String get spells2024ChooseClass => 'Elige la clase de este conjuro';

  @override
  String get featureChoicesChooseTarget => 'Elige un objetivo';

  @override
  String get featureChoicesNoTargets => 'Aún no hay objetivos válidos.';

  @override
  String get levelUp2024SwapTitle => 'Reemplazar conjuros (opcional)';

  @override
  String get levelUp2024SwapCantrip => 'Truco a reemplazar';

  @override
  String get levelUp2024SwapSpell => 'Conjuro preparado a reemplazar';

  @override
  String get levelUp2024SwapLearn => 'Reemplazo';

  @override
  String get resetLevels2024ClassTitle => 'Clase en nivel 1';

  @override
  String get changesReviewTitle => 'Revisar cambios';

  @override
  String get changesReviewIntro => 'Al guardar cambiará:';

  @override
  String get changesReviewNone => 'No cambiará nada.';

  @override
  String get changesReviewApply => 'Guardar cambios';

  @override
  String get changesKindClasses => 'Clases';

  @override
  String get changesKindExpertise => 'Pericia';

  @override
  String get changesKindProficiencies => 'Competencias';

  @override
  String get changesKindExperience => 'Puntos de experiencia';

  @override
  String get changesAdded => 'Añadidos';

  @override
  String get changesRemoved => 'Eliminados';

  @override
  String get changesKeptTitle => 'Se mantiene igual';

  @override
  String get resetLimitAbilityIncreases =>
      'Esta hoja no tiene el historial completo de niveles, así que los aumentos de característica de niveles anteriores se mantienen.';

  @override
  String get resetLimitClassSkills =>
      'Esta hoja no registró qué habilidades vinieron de la clase, así que se mantienen.';

  @override
  String get concentrationBannerLabel => 'Concentrado en:';

  @override
  String get concentrationBreakButton => 'Terminar';

  @override
  String get concentrationReplaceTitle => '¿Reemplazar Concentración?';

  @override
  String concentrationReplaceBody(String current, String next) {
    return 'Estás concentrado en $current. Lanzar $next terminará tu concentración.';
  }

  @override
  String get concentrationReplaceConfirm => 'Reemplazar';

  @override
  String get concentrationTooltip => 'Establecer concentración';

  @override
  String get sectionIdentity => 'Identidad';

  @override
  String get sectionHitPoints => 'Puntos de vida';

  @override
  String get sectionCombat => 'Combatir';

  @override
  String get sectionProgression => 'Progresión';

  @override
  String get sectionAbilityScores => 'Puntuaciones de habilidad';

  @override
  String get sectionSavingThrows => 'Competencias en tiradas de salvación';

  @override
  String get labelName => 'Nombre';

  @override
  String get labelBackground => 'Fondo';

  @override
  String get labelChange => 'Cambiar';

  @override
  String get labelAlignment => 'Alineación';

  @override
  String get labelPlayer => 'Jugador';

  @override
  String get labelLevel => 'Nivel';

  @override
  String get tooltipLevelUp => 'Subir Nivel';

  @override
  String get levelUpTitle => 'Subir de Nivel';

  @override
  String get levelUpStepClassTarget => 'Elegir clase para subir';

  @override
  String get levelUpClassTargetExisting => 'Clases actuales';

  @override
  String get levelUpClassTargetAddClass => 'Añadir una nueva clase';

  @override
  String levelUpClassTargetCurrentLevel(int level) {
    return 'Nivel actual $level';
  }

  @override
  String levelUpClassTargetNextClassLevel(int level) {
    return 'Nivel de clase $level';
  }

  @override
  String levelUpClassTargetRequirement(String requirement) {
    return 'Requiere $requirement';
  }

  @override
  String levelUpClassTargetRequirementMissing(String requirement) {
    return 'Requisito faltante: $requirement';
  }

  @override
  String get levelUpClassTargetCurrentRequirementsMissing =>
      'Tu clase actual no cumple su requisito de multiclase.';

  @override
  String get levelUpConfirm => 'Confirmar Subida';

  @override
  String get levelUpCancel => 'Cancelar';

  @override
  String get levelUpStepFeatures => 'Nuevas Habilidades';

  @override
  String levelUpStepSubclass(String feature) {
    return 'Elegir $feature';
  }

  @override
  String get levelUpStepAsi => 'Mejora de Puntuación';

  @override
  String get levelUpStepHp => 'Puntos de Golpe';

  @override
  String get levelUpStepCantrips => 'Nuevos Trucos';

  @override
  String get levelUpStepSpells => 'Nuevos Conjuros';

  @override
  String get levelUpStepSummary => 'Resumen';

  @override
  String get levelUpNoNewFeatures =>
      'Sin nuevas características de clase en este nivel.';

  @override
  String get featureChoicesTitle => 'Elecciones de rasgos';

  @override
  String get featureChoicesPending => 'Eleccion pendiente';

  @override
  String get featureChoicesEdit => 'Editar elecciones';

  @override
  String get featureChoicesChooseDependencyFirst =>
      'Elige primero la opcion requerida anterior.';

  @override
  String featureChoicesChooseCount(String kind, int count) {
    return 'Elige $count $kind.';
  }

  @override
  String featureChoicesSelectedCount(int selected, int count) {
    return '$selected/$count seleccionadas';
  }

  @override
  String get levelUpHpRoll => 'Tirar';

  @override
  String get levelUpHpAverage => 'Promedio';

  @override
  String levelUpHpGained(int n) {
    return '+$n PG';
  }

  @override
  String levelUpHpFormula(int die, String mod) {
    return 'd$die + CON ($mod)';
  }

  @override
  String get levelUpAsiOption => 'Mejora de Puntuación';

  @override
  String get levelUpFeatOption => 'Elegir un Don';

  @override
  String levelUpAsiPointsLeft(int n) {
    return '$n punto(s) restante(s)';
  }

  @override
  String levelUpSpellsToLearn(int n) {
    return 'Elegir $n conjuro(s)';
  }

  @override
  String get levelUpSpellRestrictedSection => 'Escuelas obligatorias';

  @override
  String get levelUpSpellFreeSection => 'Elección libre';

  @override
  String levelUpSpellRestrictedInstruction(int count, String schools) {
    return 'Conjuros por elegir: $count. Escuelas permitidas: $schools.';
  }

  @override
  String levelUpSpellFreeInstruction(int count) {
    return 'Conjuros por elegir: $count. Puedes elegir de cualquier escuela.';
  }

  @override
  String get levelUpSpellFreeLocked =>
      'Completa primero la elección de las escuelas obligatorias.';

  @override
  String levelUpCantripsToLearn(int n) {
    return 'Elegir $n truco(s)';
  }

  @override
  String get levelUpSpellSwap => 'Reemplazar un conjuro conocido (opcional)';

  @override
  String levelUpSpellSwapCurrent(String name) {
    return 'Actual: $name';
  }

  @override
  String levelUpSummaryLevel(int level) {
    return '→ Nivel $level';
  }

  @override
  String levelUpSummaryClassLevel(String className, int level) {
    return '$className nivel $level';
  }

  @override
  String levelUpSummaryHp(int n) {
    return 'PG Máx +$n';
  }

  @override
  String levelUpSummaryAsi(String changes) {
    return 'MPP: $changes';
  }

  @override
  String levelUpSummaryFeat(String name) {
    return 'Don: $name';
  }

  @override
  String levelUpSummarySubclass(String name) {
    return 'Subclase: $name';
  }

  @override
  String levelUpSummarySpellsLearned(int count) {
    return 'Conjuros aprendidos: $count';
  }

  @override
  String levelUpSummaryCantripsLearned(int count) {
    return 'Trucos aprendidos: $count';
  }

  @override
  String levelUpSubclassAlreadyHas(String name) {
    return 'Subclase actual: $name';
  }

  @override
  String get levelUpMaxLevel => 'Ya está en el nivel máximo (20).';

  @override
  String get levelUpHpReroll => 'Volver a tirar / cambiar';

  @override
  String get levelUpSpellSwapPickReplacement =>
      'Ahora elige un hechizo de reemplazo';

  @override
  String get levelUpSpellSwapReplaceWith => 'Reemplazar con';

  @override
  String get levelUpSpellSwapNone => 'Ninguno';

  @override
  String get levelUpSpellAlreadyKnown => 'Ya conocido';

  @override
  String levelUpSpellCantripSubtitle(String school) {
    return '$school (truco)';
  }

  @override
  String levelUpSpellSubtitle(int level, String school) {
    return 'Nv $level $school';
  }

  @override
  String get resetLevelsTitle => 'Reiniciar niveles';

  @override
  String get resetLevelsConfirmBody =>
      'Esto devuelve la progresión de clase al nivel 1. Se conservan notas, inventario, contenedores, monedas, imagen, historia, apariencia, raza y trasfondo.\n\nSe eliminan los niveles de clase, los conjuros de clase, las elecciones de clase y subclase con lo que otorgaban, los recursos de progresión y las dotes de nivel. Los aumentos de característica por nivel se deshacen cuando la hoja tiene el historial completo de niveles. Revisarás cada cambio antes de que se guarde nada.';

  @override
  String resetLevelsCountdown(int seconds) {
    return 'Espera ${seconds}s';
  }

  @override
  String get resetLevelsIntro =>
      'Elige los nuevos datos de clase de nivel 1. El reinicio solo se guarda cuando presionas el botón final.';

  @override
  String get resetLevelsSubclassRequired =>
      'Esta clase elige una subclase en nivel 1.';

  @override
  String resetLevelsInitialHp(int hp) {
    return 'PG iniciales: $hp';
  }

  @override
  String resetLevelsSelectSkills(int count) {
    return 'Elige $count habilidades de clase.';
  }

  @override
  String get resetLevelsFixedTools => 'Concedido automáticamente:';

  @override
  String resetLevelsSelectTools(int count) {
    return 'Elige $count competencias con herramientas.';
  }

  @override
  String get resetLevelsApply => 'Reiniciar a nivel 1';

  @override
  String resetLevelsApplyAndRebuild(int level) {
    return 'Reiniciar y reconstruir hasta nivel $level';
  }

  @override
  String get resetLevelsIncomplete => 'Completa las elecciones obligatorias';

  @override
  String get resetLevelsApplied => 'Niveles reiniciados.';

  @override
  String resetLevelsRebuildTitle(int level) {
    return 'Reconstruir hasta nivel $level';
  }

  @override
  String resetLevelsRebuildSubtitle(int level) {
    return 'Después de elegir el nivel 1, la app abrirá los pasos de subida de nivel hasta el nivel $level. Si cancelas antes del final, no se guarda nada.';
  }

  @override
  String resetLevelsRebuildStep(int level, int targetLevel) {
    return 'Reconstruyendo nivel $level de $targetLevel';
  }

  @override
  String get resetLevelsRebuildCancelled =>
      'Reinicio cancelado. No se guardó ningún cambio.';

  @override
  String resetLevelsRebuiltApplied(int level) {
    return 'Niveles reiniciados y reconstruidos hasta nivel $level.';
  }

  @override
  String get labelSubclass => 'Subclase';

  @override
  String get labelLanguages => 'Idiomas';

  @override
  String get hintAddLanguage => 'Agregar idioma…';

  @override
  String get labelChoose => 'Elegir';

  @override
  String get sectionAppearance => 'Apariencia';

  @override
  String get labelAge => 'Edad';

  @override
  String get labelHeight => 'Altura';

  @override
  String get labelWeight => 'Peso';

  @override
  String get labelEyes => 'Ojos';

  @override
  String get labelSkin => 'Piel';

  @override
  String get labelHair => 'Cabello';

  @override
  String get labelMaxHP => 'HP máx.';

  @override
  String get labelTempHP => 'HP temporal';

  @override
  String get labelAmount => 'Cantidad';

  @override
  String get labelSpeed => 'Velocidad (pies)';

  @override
  String get detailDamage => 'Daño';

  @override
  String get detailHeal => 'Sanar';

  @override
  String get detailNone => 'Ninguno';

  @override
  String get tempHpDialogTitle => 'Agregar HP temporal';

  @override
  String get tempHpDialogTitleReplace => 'HP temporal';

  @override
  String tempHpCurrent(int n) {
    return 'Actual: + $n temperatura HP';
  }

  @override
  String get tempHpNoStack =>
      'Temp HP no se acumula: solo los valores más altos reemplazan al actual.';

  @override
  String get tempHpReplace => 'Reemplazar';

  @override
  String statsTempHpChip(int n) {
    return '+$n temp';
  }

  @override
  String subclassConfirmTitle(String feature) {
    return 'Confirmar $feature';
  }

  @override
  String subclassChooseTitle(String feature) {
    return 'Elija $feature';
  }

  @override
  String subclassConfirmBody(int level, String feature) {
    return 'Has alcanzado el nivel $level. Confirma o cambia tu $feature.';
  }

  @override
  String subclassChooseBody(int level, String feature) {
    return '¡Has alcanzado el nivel $level! Elige tu $feature.';
  }

  @override
  String get subclassKeepCurrent => 'Mantenerse actualizado';

  @override
  String get subclassChangeTitle => 'Cambiar subclase';

  @override
  String get subclassChangeWarning =>
      'Advertencia: los hechizos y competencias otorgados por la subclase anterior no se eliminan automáticamente. Deberá ajustarlos manualmente.';

  @override
  String get backgroundChooseTitle => 'Elija fondo';

  @override
  String get featuresTooltipAdd => 'Agregar característica';

  @override
  String get featuresTooltipRemove => 'Eliminar';

  @override
  String get featuresTooltipEnable => 'Activar';

  @override
  String get featuresTooltipDisable => 'Desactivar';

  @override
  String get featuresTabFeats => 'Dotes';

  @override
  String featPrerequisite(String req) {
    return 'Prerrequisito: $req';
  }

  @override
  String get featuresSectionFeats => 'Dotes';

  @override
  String get featuresTabClass => 'Clase';

  @override
  String get featuresTabRacial => 'Racial';

  @override
  String get featuresTabCustom => 'Personaliz.';

  @override
  String get featuresTabTools => 'Herramientas';

  @override
  String get featuresRemoveTitle => '¿Eliminar función?';

  @override
  String featuresRemoveContent(String name) {
    return 'Se eliminará \" $name \".';
  }

  @override
  String get featuresNoneAvailable => 'No hay funciones disponibles.';

  @override
  String get featuresAddLabel => 'Agregar función';

  @override
  String get featuresLoadError => 'Error al cargar funciones.';

  @override
  String get hintSearch => 'Buscar...';

  @override
  String get labelFeatureName => 'Nombre';

  @override
  String get labelFeatureDescription => 'Descripción (opcional)';

  @override
  String get labelFeatureType => 'Tipo:';

  @override
  String get labelPassive => 'Pasivo';

  @override
  String get labelActive => 'Activo';

  @override
  String get spellsTooltipAdd => 'Agregar hechizo';

  @override
  String get spellsRemoveTitle => '¿Quitar hechizo?';

  @override
  String spellsRemoveContent(String name) {
    return '¿Eliminar \"$name\" de tu lista de hechizos?';
  }

  @override
  String get spellsAtWill => 'a voluntad';

  @override
  String get notesTooltipAdd => 'Agregar nota';

  @override
  String get notesTooltipEdit => 'Editar nota';

  @override
  String get notesTooltipDelete => 'Eliminar nota';

  @override
  String get notesEmptyTitle => 'Aún no hay notas';

  @override
  String get notesEmptyHint => 'Toca + para crear tu primera nota.';

  @override
  String get notesUntitled => 'Sin título';

  @override
  String get notesDeleteTitle => '¿Eliminar nota?';

  @override
  String notesDeleteContentNamed(String title) {
    return '\" $title \" se eliminará permanentemente.';
  }

  @override
  String get notesDeleteContent => 'Esta nota será eliminada permanentemente.';

  @override
  String get notesLabelTitle => 'Título';

  @override
  String get notesLabelContent => 'Contenido';

  @override
  String get notesSearchHint => 'Buscar notas o etiquetas';

  @override
  String get notesNoResultsTitle => 'No hay notas coincidentes';

  @override
  String get notesNoResultsHint =>
      'Prueba otra búsqueda o borra el filtro de etiquetas.';

  @override
  String get notesReadMore => 'Leer más';

  @override
  String get notesTags => 'Etiquetas';

  @override
  String get notesAllTags => 'Todas';

  @override
  String get notesCustomTag => 'Etiqueta personalizada';

  @override
  String get notesAddTag => 'Agregar etiqueta';

  @override
  String get notesTagColor => 'Color de etiqueta';

  @override
  String get notesChooseTagColor => 'Elegir color de etiqueta';

  @override
  String get notesTooltipPin => 'Fijar nota';

  @override
  String get notesTooltipUnpin => 'Desfijar nota';

  @override
  String get notesMoveUp => 'Mover arriba';

  @override
  String get notesMoveDown => 'Mover abajo';

  @override
  String get notesMoreActions => 'Más acciones';

  @override
  String get notesPinnedSection => 'Fijadas';

  @override
  String get notesOtherSection => 'Notas';

  @override
  String get notesDefaultTagSession => 'Sesión';

  @override
  String get notesDefaultTagNpc => 'PNJ';

  @override
  String get notesDefaultTagQuest => 'Misión';

  @override
  String get notesDefaultTagPlace => 'Lugar';

  @override
  String get notesDefaultTagLoot => 'Botín';

  @override
  String get notesDefaultTagRule => 'Regla';

  @override
  String get sectionPersonalityTraits => 'Rasgos de personalidad';

  @override
  String get sectionPersonality => 'Personalidad';

  @override
  String get sectionIdeals => 'Ideales';

  @override
  String get sectionBonds => 'Cautiverio';

  @override
  String get sectionFlaws => 'Defectos';

  @override
  String get sectionBackstory => 'Historia de fondo';

  @override
  String inventoryEquippedSection(int count, int ac) {
    return 'Equipado ( $count ) · CA $ac';
  }

  @override
  String get inventoryTooltipAdd => 'Agregar artículo';

  @override
  String get inventoryTooltipRemove => 'Eliminar';

  @override
  String get inventoryTooltipMove => 'Mover';

  @override
  String inventoryMoveTitle(String name) {
    return 'Mover $name';
  }

  @override
  String get inventoryMoveToInventory => 'Inventario';

  @override
  String inventoryContainersSection(int count) {
    return 'Contenedores ($count)';
  }

  @override
  String inventoryContainerContents(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count objetos',
      one: '1 objeto',
    );
    return '$_temp0';
  }

  @override
  String get inventoryContainerEmpty => 'Vacío';

  @override
  String get inventoryRemoveTitle => '¿Quitar artículo?';

  @override
  String inventoryRemoveContent(String name) {
    return '¿Eliminar $name del inventario?';
  }

  @override
  String inventoryRemovePartial(int count, int total) {
    return 'Eliminará: $count de $total';
  }

  @override
  String get inventoryRemoveContainerTitle => '¿Eliminar contenedor?';

  @override
  String inventoryRemoveContainerContent(String name, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count objetos',
      one: '1 objeto',
    );
    return '$name contiene $_temp0. ¿Qué debe pasar con ellos?';
  }

  @override
  String get inventoryRemoveContainerMoveContents =>
      'Mover objetos al inventario';

  @override
  String get inventoryRemoveContainerDeleteContents => 'Eliminar todo';

  @override
  String get inventoryLabelQuantity => 'Cantidad:';

  @override
  String get inventoryLabelQuantityToRemove => 'Cantidad a eliminar';

  @override
  String get inventoryAddCustomItem => 'Agregar artículo personalizado';

  @override
  String get inventoryAddItem => 'Agregar artículo';

  @override
  String get inventoryLabelItemName => 'Nombre *';

  @override
  String get inventoryLabelType => 'Tipo';

  @override
  String get inventoryLabelCategory => 'Categoría';

  @override
  String get inventoryLabelItemQuantity => 'Cantidad';

  @override
  String get inventoryLabelWeight => 'Peso';

  @override
  String get weightCarried => 'Llevando';

  @override
  String get weightCapacity => 'Capacidad';

  @override
  String get weightEncumbered => 'Sobrecargado';

  @override
  String get weightHeavilyEncumbered => 'Muy Sobrecargado';

  @override
  String get weightEnableTooltip => 'Activar seguimiento de peso';

  @override
  String get weightDisableTooltip => 'Desactivar seguimiento de peso';

  @override
  String get inventoryLabelDescription => 'Descripción (opcional)';

  @override
  String get inventoryTypeWeapon => 'Arma';

  @override
  String get inventoryTypeArmor => 'Armadura';

  @override
  String get inventoryTypeConsumable => 'Consumible';

  @override
  String get inventoryTypeGear => 'Equipo';

  @override
  String get inventoryTypeEquippable => 'Equipable';

  @override
  String get inventoryTypeContainer => 'Contenedor';

  @override
  String get inventoryAddItemError => 'No se pudo agregar el objeto.';

  @override
  String inventoryLoadItemsError(String error) {
    return 'Error al cargar objetos:\n$error';
  }

  @override
  String inventoryNoResults(String query) {
    return 'Sin resultados para \"$query\"';
  }

  @override
  String get inventoryTooltipEquip => 'Equipar';

  @override
  String get inventoryTooltipUnequip => 'Desequipar';

  @override
  String get inventoryCustomDamageDice => 'Daño (ej.: 1d8)';

  @override
  String get inventoryCustomDamageType => 'Tipo de daño';

  @override
  String get inventoryCustomWeaponProperties =>
      'Propiedades (separadas por comas)';

  @override
  String get inventoryCustomRangeNormal => 'Alcance normal';

  @override
  String get inventoryCustomRangeLong => 'Alcance largo';

  @override
  String get inventoryCustomAddDexToAc => 'Agregar DES a CA';

  @override
  String get inventoryCustomEquipSlot => 'Ranura (ej.: anillo, cuello)';

  @override
  String get inventoryCustomCompatibleWith =>
      'Compatible con (separado por comas)';

  @override
  String get inventoryDetailYes => 'Sí';

  @override
  String get inventoryDetailNo => 'No';

  @override
  String get inventoryDetailMaxShort => 'máx.';

  @override
  String get inventoryDetailDamage => 'Daño';

  @override
  String get inventoryDetailDamageType => 'Tipo de daño';

  @override
  String get inventoryDetailWeaponProperties => 'Propiedades';

  @override
  String get inventoryDetailVersatileDamage => 'Daño versátil';

  @override
  String get inventoryDetailRange => 'Alcance';

  @override
  String get inventoryDetailRangeNormal => 'normal';

  @override
  String get inventoryDetailRangeLong => 'largo';

  @override
  String get inventoryDetailArmorType => 'Tipo de armadura';

  @override
  String get inventoryDetailShield => 'Escudo';

  @override
  String get inventoryDetailBaseAc => 'CA base';

  @override
  String get inventoryDetailAcBonus => 'Bonificador de CA';

  @override
  String get inventoryDetailAddDexToAc => 'Suma DES a CA';

  @override
  String get inventoryDetailMaxDex => 'DES máx.';

  @override
  String get inventoryDetailStrengthMinimum => 'Fuerza mínima';

  @override
  String get inventoryDetailEquipSlot => 'Ranura';

  @override
  String get inventoryDetailRequiresAttunement => 'Requiere sintonía';

  @override
  String get inventoryDetailCapacityWeight => 'Capacidad de peso';

  @override
  String get inventoryDetailCapacityVolume => 'Volumen';

  @override
  String get inventoryDetailCapacityVolumeUnit => 'Unidad de volumen';

  @override
  String get inventoryDetailIgnoreContentWeight =>
      'Ignora el peso del contenido';

  @override
  String get inventoryDetailEffect => 'Efecto';

  @override
  String get inventoryDetailUses => 'Usos';

  @override
  String get inventoryDetailAction => 'Acción';

  @override
  String get inventoryDetailAmmoType => 'Tipo de munición';

  @override
  String get inventoryDetailCompatibleWith => 'Compatible con';

  @override
  String get inventoryDetailBonus => 'Bonificador';

  @override
  String get inventoryDetailExtraDamage => 'Daño extra';

  @override
  String get inventoryDetailExtraDamageType => 'Tipo de daño extra';

  @override
  String get inventoryDetailSubtype => 'Subtipo';

  @override
  String get inventoryDetailCost => 'Coste';

  @override
  String get inventoryDetailRarity => 'Rareza';

  @override
  String get inventoryDetailFeatures => 'Características';

  @override
  String get inventoryDetailWeightEach => 'Peso por objeto';

  @override
  String get inventoryDetailWeightTotal => 'Peso total';

  @override
  String get inventoryDetailState => 'Estado';

  @override
  String get inventoryDetailEquipped => 'Equipado';

  @override
  String get inventoryDetailNotEquipped => 'No equipado';

  @override
  String get inventoryDetailSummary => 'Resumen';

  @override
  String get inventoryDetailDescription => 'Descripción';

  @override
  String get inventoryDetailAttributes => 'Atributos';

  @override
  String get inventoryReplaceArmorTitle => '¿Reemplazar la armadura equipada?';

  @override
  String get inventoryTabWeapons => 'Armas';

  @override
  String get inventoryTabArmor => 'Armadura';

  @override
  String get inventoryTabGear => 'Engranaje';

  @override
  String get inventoryTabMagic => 'Magia';

  @override
  String get inventoryTabTools => 'Herramientas';

  @override
  String get inventoryTabCustom => 'Costumbre';

  @override
  String hintSearchCategory(String category) {
    return 'Buscar $category...';
  }

  @override
  String get stepChooseMethod => 'Elige tu método:';

  @override
  String get stepStandardArray => 'Matriz estándar';

  @override
  String get stepPointBuy => 'Compra puntual';

  @override
  String get stepRoll4d6 => 'Tira 4d6';

  @override
  String get stepDistributeRacialBonuses =>
      'Distribuye bonificaciones raciales libremente';

  @override
  String get stepAssignRolls => 'Asigna cada tirada a un atributo:';

  @override
  String get stepAssignValues => 'Asigne cada valor a un atributo:';

  @override
  String get stepPointsRemaining => 'Puntos restantes:';

  @override
  String stepRaceBonus(int n) {
    return 'Bonificación racial +$n';
  }

  @override
  String get stepChooseSubrace => 'Elige una subraza:';

  @override
  String get stepGrantedByBackground => 'Concedido por antecedentes:';

  @override
  String stepClassSkillChoices(int count) {
    return 'Opciones de habilidades de clase ( $count ):';
  }

  @override
  String get stepChooseOne => 'Elige uno';

  @override
  String get stepSelectTool => 'Seleccione una herramienta...';

  @override
  String get statAC => 'C.A.';

  @override
  String get statArmor => 'Armadura';

  @override
  String get statNoArmor => 'Sin armadura';

  @override
  String get statNoArmorShield => 'Sin armadura + Escudo';

  @override
  String get statShieldSuffix => '+ Escudo';

  @override
  String get statSpeed => 'Velocidad';

  @override
  String get statInitiative => 'Iniciativa';

  @override
  String get statProfBonus => 'Bono de profesor';

  @override
  String get statPassivePerc => 'Percepción pasiva';

  @override
  String get statInspiration => 'Inspiración';

  @override
  String get statXP => 'XP';

  @override
  String get inspirationGranted => 'Concedida';

  @override
  String get inspirationNotGranted => 'No concedida';

  @override
  String statLevel(int level) {
    return 'Nivel $level';
  }

  @override
  String get tooltipAddXp => 'Añadir XP';

  @override
  String get labelLevelTable => 'Tabla de Niveles';

  @override
  String get statUnconsciousDying => 'Inconsciente / Muriéndose';

  @override
  String get deathSavesTitle => 'Tiradas de Muerte';

  @override
  String get deathSavesSuccesses => 'Éxitos';

  @override
  String get deathSavesFailures => 'Fracasos';

  @override
  String get deathSavesStabilized => 'Estabilizado';

  @override
  String get deathSavesDead => 'Muerto';

  @override
  String get sectionActiveConditions => 'Condiciones Activas';

  @override
  String get conditionsNone => 'Ninguna activa';

  @override
  String get conditionsAdd => 'Agregar condición';

  @override
  String get conditionsPickTitle => 'Aplicar Condición';

  @override
  String get conditionsRemove => 'Remover condición';

  @override
  String get tooltipAddTempHp => 'Agregar HP temporal';

  @override
  String get tooltipChangeTempHp => 'Cambiar temperatura HP';

  @override
  String get abilityStr => 'FUE';

  @override
  String get abilityDex => 'DES';

  @override
  String get abilityCon => 'CON';

  @override
  String get abilityInt => 'INT';

  @override
  String get abilityWis => 'SAB';

  @override
  String get abilityCha => 'CAR';

  @override
  String featuresSectionRacialTraits(String name) {
    return 'Rasgos raciales - $name';
  }

  @override
  String featuresSectionBackground(String name) {
    return 'Función de fondo: $name';
  }

  @override
  String featuresSectionClass(String name) {
    return 'Características de clase: $name';
  }

  @override
  String featuresSectionSubclass(String name) {
    return 'Funciones de subclase: $name';
  }

  @override
  String get featuresSectionTools => 'Competencias en herramientas';

  @override
  String get featuresSectionExtra => 'Funciones adicionales';

  @override
  String get spellsNoSpellcasting => 'Sin hechizos';

  @override
  String get spellsNoSpellcastingDesc =>
      'Esta clase no tiene funciones de lanzamiento de hechizos.';

  @override
  String get spellsSlots => 'Ranuras para hechizos';

  @override
  String get spellsPactMagicSlots => 'Magia de Pacto';

  @override
  String get spellsSpellcasting => 'Lanzamiento de hechizos';

  @override
  String get spellsAttack => 'Ataque';

  @override
  String get spellsSaveDC => 'CD de salvación';

  @override
  String get spellsCantrips => 'Trucos';

  @override
  String get spellsPrepared => 'Preparado';

  @override
  String get spellsKnown => 'Conocido';

  @override
  String get spellsEmpty =>
      'Aún no se han añadido hechizos.\nToca + para buscar hechizos.';

  @override
  String spellsSlotLevel(int level) {
    return 'Nivel $level';
  }

  @override
  String spellsLevelN(int level) {
    return 'Nivel $level';
  }

  @override
  String get spellsInnateHeader => 'Hechizos Raciales';

  @override
  String get spellsDisableTitle => '¿Desactivar hechizo?';

  @override
  String get spellsEnableTitle => '¿Reactivar hechizo?';

  @override
  String spellsDisableContent(String name) {
    return '¿Desactivar \"$name\"? Aparecerá en gris y no podrá ser preparado.';
  }

  @override
  String spellsEnableContent(String name) {
    return '¿Reactivar \"$name\"? Volverá a aparecer normalmente.';
  }

  @override
  String get spellsDisable => 'Desactivar';

  @override
  String get spellsEnable => 'Reactivar';

  @override
  String get spellsExtrasHeader => 'Hechizos Extra';

  @override
  String get spellFilterTitle => 'Filtros';

  @override
  String get spellFilterReset => 'Restablecer';

  @override
  String get spellFilterApply => 'Aplicar filtros';

  @override
  String get spellFilterSectionClasses => 'Clases';

  @override
  String get spellFilterClassesHint => 'Sin clase = mostrar todas las clases';

  @override
  String get spellFilterSectionLevel => 'Nivel de conjuro';

  @override
  String get spellFilterShowAllLevels => 'Mostrar todos los niveles';

  @override
  String spellFilterShowAllLevelsHint(int max) {
    return 'Incluir conjuros sobre tu máximo actual (Niv $max)';
  }

  @override
  String get spellFilterCantrip => 'Truco';

  @override
  String spellFilterLvl(int n) {
    return 'Niv $n';
  }

  @override
  String get spellFilterSectionCastingTime => 'Tiempo de lanzamiento';

  @override
  String get spellFilterCastAction => 'Acción';

  @override
  String get spellFilterCastBonus => 'Acción adicional';

  @override
  String get spellFilterCastReaction => 'Reacción';

  @override
  String get spellFilterCastLonger => 'Lanzamiento largo (1 min+)';

  @override
  String get spellFilterSectionProperties => 'Propiedades';

  @override
  String get spellFilterConcentration => 'Concentración';

  @override
  String get spellFilterConcentrationHint =>
      'Solo conjuros que requieren concentración';

  @override
  String get spellFilterRitual => 'Ritual';

  @override
  String get spellFilterRitualHint =>
      'Solo conjuros que se pueden lanzar como rituales';

  @override
  String get spellFilterSectionSchool => 'Escuela de magia';

  @override
  String get spellRemoveTitle => 'Eliminar conjuro';

  @override
  String spellRemoveContent(String name) {
    return '¿Eliminar \"$name\" de tu lista de conjuros?';
  }

  @override
  String get spellActionPrepared => 'Preparado — toca para despreparar';

  @override
  String get spellActionPrepare => 'Preparar para hoy';

  @override
  String get spellActionAdd => 'Añadir al personaje';

  @override
  String get spellActionInList => 'En tu lista — toca para eliminar';

  @override
  String get spellActionAlreadyInList => 'Ya está en tu lista de conjuros';

  @override
  String get spellActionClassSpellInfo =>
      'Este conjuro ya es parte de la lista de tu clase y no necesita aprenderse.';

  @override
  String get inventoryCurrency => 'Divisa';

  @override
  String inventoryCarriedSection(int count) {
    return 'Llevado ( $count )';
  }

  @override
  String inventoryEquippableSection(int count) {
    return 'Equipable ($count)';
  }

  @override
  String get inventoryEquipHint =>
      'Toca el ícono circular a la izquierda para equipar o desequipar';

  @override
  String get inventoryInventory => 'Inventario';

  @override
  String get inventoryEmpty => 'Aún no hay artículos. Toque + para agregar.';

  @override
  String get inventoryAmmunition => 'Munición';

  @override
  String get coinCopper => 'Cobre';

  @override
  String get coinSilver => 'Plata';

  @override
  String get coinElectrum => 'electro';

  @override
  String get coinGold => 'Oro';

  @override
  String get coinPlatinum => 'Platino';

  @override
  String get inventoryGroupSimpleMelee => 'Cuerpo a cuerpo simple';

  @override
  String get inventoryGroupSimpleRanged => 'A distancia simple';

  @override
  String get inventoryGroupMartialMelee => 'Cuerpo a cuerpo marcial';

  @override
  String get inventoryGroupMartialRanged => 'Marcial a distancia';

  @override
  String get inventoryGroupLightArmor => 'Armadura ligera';

  @override
  String get inventoryGroupMediumArmor => 'Armadura media';

  @override
  String get inventoryGroupHeavyArmor => 'Armadura pesada';

  @override
  String get inventoryGroupShields => 'Escudos';

  @override
  String get inventoryGroupAdventuringGear => 'Equipo de aventuras';

  @override
  String get inventoryGroupAmmunition => 'Munición';

  @override
  String get inventoryGroupArcaneFocus => 'Enfoque arcano';

  @override
  String get inventoryGroupClothing => 'Ropa';

  @override
  String get inventoryGroupContainer => 'Recipiente';

  @override
  String get inventoryGroupPoison => 'Veneno';

  @override
  String get inventoryGroupPotions => 'Pociones';

  @override
  String get inventoryGroupRings => 'Anillos';

  @override
  String get inventoryGroupWands => 'varitas';

  @override
  String get inventoryGroupWeapons => 'Armas';

  @override
  String get inventoryGroupArmor => 'Armadura';

  @override
  String get inventoryGroupWondrousItems => 'Objetos maravillosos';

  @override
  String get inventoryGroupArtisansTools => 'Herramientas del artesano';

  @override
  String get inventoryGroupGamingSets => 'Conjuntos de juego';

  @override
  String get inventoryGroupMusicalInstruments => 'Instrumentos musicales';

  @override
  String get inventoryGroupOtherTools => 'Otras herramientas';

  @override
  String get armorStealthDisadvantage => 'Desventaja del sigilo';

  @override
  String get spellDetailCastingTime => 'tiempo de lanzamiento';

  @override
  String get spellDetailRange => 'Rango';

  @override
  String get spellRangeSelf => 'A uno mismo';

  @override
  String get spellRangeTouch => 'Toque';

  @override
  String get spellRangeSight => 'Vista';

  @override
  String get spellRangeSpecial => 'Especial';

  @override
  String get spellRangeUnlimited => 'Ilimitado';

  @override
  String get spellAreaSphere => 'esfera';

  @override
  String get spellAreaCone => 'cono';

  @override
  String get spellAreaCube => 'cubo';

  @override
  String get spellAreaCylinder => 'cilindro';

  @override
  String get spellAreaLine => 'línea';

  @override
  String get spellAreaWall => 'muro';

  @override
  String get spellAreaCircle => 'círculo';

  @override
  String get spellDetailDuration => 'Duración';

  @override
  String get spellDetailComponents => 'Componentes';

  @override
  String get spellDetailConcentration => 'Requiere concentración';

  @override
  String get spellDetailRitual => 'Puede ser lanzado como un ritual.';

  @override
  String get spellDetailAtHigherLevels => 'En niveles superiores.';

  @override
  String spellDetailClasses(String classes) {
    return 'Clases: $classes';
  }

  @override
  String spellDetailLevelSchool(String ordinal, String school) {
    return '$ordinal -nivel $school';
  }

  @override
  String spellDetailCantrip(String school) {
    return 'truco $school';
  }

  @override
  String armorSwapCurrent(String name) {
    return 'Actual: $name';
  }

  @override
  String armorSwapAcNow(int ac) {
    return 'AC ahora: $ac';
  }

  @override
  String armorSwapAcAfter(int ac) {
    return 'CA después: $ac';
  }

  @override
  String get armorSwapButton => 'intercambiar armadura';

  @override
  String get reviewRowName => 'Nombre';

  @override
  String get reviewUnnamedHero => 'Héroe sin nombre';

  @override
  String get reviewRowPlayer => 'Jugador';

  @override
  String get reviewRowSubclass => 'Subclase';

  @override
  String get reviewRowHitDie => 'Dado de Golpe';

  @override
  String get reviewRowSavingThrows => 'Tiradas de salvación';

  @override
  String get reviewRowSubrace => 'Subraza';

  @override
  String get reviewRowSpeed => 'Velocidad';

  @override
  String get reviewRowLanguages => 'Idiomas';

  @override
  String get reviewRowFeature => 'Característica';

  @override
  String get reviewRowFromBackground => 'Desde el fondo';

  @override
  String get reviewRowClassChoices => 'Opciones de clase';

  @override
  String get reviewRowMaxHp => 'HP máx.';

  @override
  String get reviewRowAcUnarmored => 'CA (sin armadura)';

  @override
  String reviewRowAcWith(String name) {
    return 'CA con $name';
  }

  @override
  String get reviewRowProficiencyBonus => 'Bonificación de competencia';

  @override
  String get reviewStartingGold => 'Oro inicial';

  @override
  String get reviewStartingEquipment => 'Equipo de arranque';

  @override
  String get reviewDeselectAll => 'Deseleccionar todo';

  @override
  String get reviewSelectAll => 'Seleccionar todo';

  @override
  String get reviewUncheckHint =>
      'Desmarque los artículos que no desea agregar a su inventario.';

  @override
  String get reviewEquipmentChoices => 'Opciones de equipo';

  @override
  String get reviewEquipmentChoicesHint =>
      'Elija el artículo específico para cada espacio.';

  @override
  String get reviewToolProficiencies => 'Competencias en herramientas';

  @override
  String get reviewChooseToolProficiency =>
      'Elija su dominio de la herramienta:';

  @override
  String reviewChooseLanguages(int count) {
    return 'Elija los idiomas $count otorgados por su raza o antecedentes.';
  }

  @override
  String get reviewChooseOne => 'Elige uno:';

  @override
  String get stepTashaRule =>
      'Regla opcional de Tasha: asignar puntos ASI a cualquier atributo';

  @override
  String get stepRollDice => 'tirar los dados';

  @override
  String get stepReroll => 'Volver a tirar';

  @override
  String get stepRollHint =>
      'Tira para generar 6 valores (4d6, caída más baja)';

  @override
  String get stepPrimaryAbilities => 'habilidades primarias:';

  @override
  String get stepNameTitle => 'Ponle nombre a tu personaje.';

  @override
  String get stepNameHint => 'Puedes cambiarlo más adelante.';

  @override
  String get stepNameCharLabel => 'Nombre del personaje';

  @override
  String get stepNamePlayerLabel => 'Nombre del jugador (opcional)';

  @override
  String get stepHitDieLabel => 'Dado de Golpe';

  @override
  String get stepSavesLabel => 'Tiradas de salvación';

  @override
  String get stepSpellcastingLabel => 'Lanzamiento de conjuros';

  @override
  String get stepOptionsLabel => 'opciones';

  @override
  String stepChooseSubclassPrompt(String feature, int level) {
    return 'Elige $feature (nivel $level):';
  }

  @override
  String get stepRaceSpeedLabel => 'Velocidad';

  @override
  String get stepRaceASILabel => 'Mejora de característica';

  @override
  String stepRaceSubracesAvailable(int count) {
    return 'Subrazas disponibles: $count';
  }

  @override
  String stepChooseSkillsHint(int count) {
    return 'Elige $count habilidades de la lista de tu clase.';
  }

  @override
  String get abilityStrength => 'Fuerza';

  @override
  String get abilityDexterity => 'Destreza';

  @override
  String get abilityConstitution => 'Constitución';

  @override
  String get abilityIntelligence => 'Inteligencia';

  @override
  String get abilityWisdom => 'Sabiduría';

  @override
  String get abilityCharisma => 'Carisma';

  @override
  String stepFreeAsiRemaining(int remaining) {
    return 'Distribuye libremente los puntos de mejora racial (quedan $remaining):';
  }

  @override
  String stepFreePicksRemaining(int total, int remaining) {
    return 'Asigna +1 a $total características (quedan $remaining):';
  }

  @override
  String get stepFreePicksNoStack =>
      'No puedes elegir características que ya tengan una bonificación racial.';

  @override
  String reviewClassEquipmentTitle(String name) {
    return 'Equipo de clase — $name';
  }

  @override
  String get reviewEquipmentIncluded => 'Incluido:';

  @override
  String get stepToolCategoryGamingSet => 'Kit de juego';

  @override
  String get stepToolCategoryInstrument => 'Instrumento musical';

  @override
  String get stepToolCategoryArtisanTool => 'Herramienta artesanal';

  @override
  String get stepToolCategoryArtisanOrInstrument =>
      'Herramienta artesanal o instrumento';

  @override
  String exportCopied(String label) {
    return '¡$label copiado!';
  }

  @override
  String exportDialogTitle(String name) {
    return 'Exportar $name';
  }

  @override
  String get exportShowJson => 'Mostrar JSON';

  @override
  String get exportCopyJson => 'Copiar JSON';

  @override
  String get exportSectionFile => 'Archivo completo';

  @override
  String get exportSectionFileCaption => 'Incluye la foto del personaje';

  @override
  String get exportShareFile => 'Compartir .dndchar';

  @override
  String get dialogClose => 'Cerrar';

  @override
  String get importDialogTitle => 'Importar personaje o copia de seguridad';

  @override
  String get importUseJson => 'Usar JSON directamente';

  @override
  String get importJsonHint => 'Pega el JSON aquí…';

  @override
  String get importPickFile => 'Elegir archivo .dndchar o .dndbackup';

  @override
  String get importFileError =>
      'Archivo .dndchar/.dndbackup inválido o corrupto';

  @override
  String get importFileIncoming => '¿Importar personaje del archivo?';

  @override
  String get dialogImport => 'Importar';

  @override
  String get spellBrowserTitle => 'Explorar conjuros';

  @override
  String get spellBrowserFilters => 'Filtros';

  @override
  String get spellBrowserSearchHint => 'Buscar conjuros...';

  @override
  String get filterClearAll => 'Borrar todo';

  @override
  String get loadingLabel => 'Cargando...';

  @override
  String spellBrowserCount(int count, String s) {
    return '$count conjuro$s';
  }

  @override
  String get spellBrowserEmpty =>
      'Ningún conjuro coincide con los filtros actuales.';

  @override
  String get spellCantrip => 'Truco';

  @override
  String spellLevelN(int n) {
    return 'Niv $n';
  }

  @override
  String get castingTimeAction => 'Acción';

  @override
  String get castingTimeBonusAction => 'Acción adicional';

  @override
  String get castingTimeReaction => 'Reacción';

  @override
  String get castingTimeLonger => 'Lanzamiento largo';

  @override
  String get filterConcentration => 'Concentración';

  @override
  String get filterRitual => 'Ritual';

  @override
  String get filterAllLevels => 'Todos los niveles';

  @override
  String get avatarChoosePhoto => 'Elegir foto';

  @override
  String get avatarRemovePhoto => 'Eliminar foto';

  @override
  String get avatarCropPhoto => 'Recortar foto';

  @override
  String get avatarChangePhoto => 'Cambiar foto';

  @override
  String get avatarSavePhoto => 'Guardar foto';

  @override
  String get avatarSaveSuccess => 'Foto guardada en la galería';

  @override
  String get avatarSaveError => 'No se pudo guardar la foto';

  @override
  String featureAddedSnackbar(String name) {
    return '¡$name añadido!';
  }

  @override
  String get featureAddButton => 'Añadir característica';

  @override
  String get reviewLanguageChoices => 'Opciones de idioma';

  @override
  String get reviewLanguageTypeHint => 'Escribe un idioma…';

  @override
  String get avatarRemoveConfirmTitle => '¿Eliminar foto?';

  @override
  String get avatarRemoveConfirmBody => 'Esta acción no se puede deshacer.';

  @override
  String get editModeBanner => 'Editando';

  @override
  String get detailSheetInfoTooltip => 'Detalles';

  @override
  String get detailSheetProficiencies => 'Competencias';

  @override
  String get detailSheetTraits => 'Rasgos';

  @override
  String get detailSheetSubclassFeaturePlaceholder => 'Rasgo de Subclase';

  @override
  String detailSheetAvailableSubclasses(String feature) {
    return '$feature disponibles';
  }

  @override
  String get detailSheetAvailableSubraces => 'Subrazas';

  @override
  String get xpTrackingLabel => 'Registrar experiencia';

  @override
  String get xpReadyToLevelUp => '¡Ya puedes subir de nivel!';

  @override
  String get xpLevelUpNowTitle => '¿Subir de nivel?';

  @override
  String xpLevelUpNowMessage(int level) {
    return 'Tienes suficiente experiencia para alcanzar el nivel $level. ¿Quieres subir ahora?';
  }

  @override
  String get xpLevelUpLater => 'Más tarde';

  @override
  String get settingsSectionUnits => 'Unidades';

  @override
  String get settingsUnitSystem => 'Sistema de unidades';

  @override
  String get settingsUnitImperial => 'Imperial (pies / lb)';

  @override
  String get settingsUnitMetric => 'Métrico (m / kg)';

  @override
  String get settingsUnitSquares => 'Cuadrados (sq / kg)';

  @override
  String get settingsChooseUnitSystem => 'Elegir sistema de unidades';

  @override
  String get settingsSectionCharacterSheet => 'Hoja de personaje';

  @override
  String get settingsKeepScreenOnTitle => 'Mantener pantalla encendida';

  @override
  String get settingsKeepScreenOnSubtitle =>
      'Evita que la pantalla se apague mientras ves una hoja de personaje.';

  @override
  String get settingsContextualRollAskTitle =>
      'Mostrar opciones de tirada contextual';

  @override
  String get settingsContextualRollAskSubtitle =>
      'Pregunta por opciones relevantes, como ventaja o desventaja, antes de tirar desde la hoja.';

  @override
  String get settingsContextualCriticalRuleTitle => 'Regla de golpe crítico';

  @override
  String get settingsContextualCriticalRuleSubtitle =>
      'Se usa automáticamente cuando una tirada de ataque obtiene un 20 natural.';

  @override
  String get settingsContextualCriticalRuleChoose =>
      'Elige la regla de golpe crítico';

  @override
  String get settingsContextualCriticalRuleDoubleDice =>
      'Tirar el doble de dados de daño';

  @override
  String get settingsContextualCriticalRuleDoubleDamage =>
      'Duplicar el total de daño';

  @override
  String get settingsBackupSection => 'Copia de seguridad';

  @override
  String get settingsBackupExportTitle => 'Exportar copia de seguridad';

  @override
  String get settingsBackupExportSubtitle =>
      'Guarda todos los personajes en un archivo de copia de seguridad.';

  @override
  String get settingsBackupExporting => 'Creando copia de seguridad...';

  @override
  String get settingsBackupExportSuccess => 'Copia de seguridad exportada.';

  @override
  String get settingsBackupExportError =>
      'No se pudo exportar la copia de seguridad.';

  @override
  String get settingsBackupImportTitle => 'Importar copia de seguridad';

  @override
  String get settingsBackupImportSubtitle =>
      'Restaura personajes desde un archivo .dndbackup.';

  @override
  String get settingsBackupImporting => 'Importando copia de seguridad...';

  @override
  String get settingsBackupImportError =>
      'No se pudo importar la copia de seguridad.';

  @override
  String settingsBackupImportSuccess(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count personajes importados desde la copia de seguridad.',
      one: '1 personaje importado desde la copia de seguridad.',
    );
    return '$_temp0';
  }

  @override
  String get settingsSectionApp => 'Aplicación';

  @override
  String get settingsReviewTitle => 'Valorar en Play Store';

  @override
  String get settingsReviewSubtitle =>
      'Abre la página de la app para dejar una valoración o comentario.';

  @override
  String get settingsReviewOpenError => 'No se pudo abrir Play Store.';

  @override
  String get settingsMaintenanceSection => 'Mantenimiento';

  @override
  String get settingsMaintenanceCheckTitle =>
      'Buscar actualizaciones de personajes';

  @override
  String get settingsMaintenanceCheckSubtitle =>
      'Busca correcciones para datos guardados.';

  @override
  String get settingsMaintenanceUpdateTitle => 'Actualizar personajes';

  @override
  String get settingsMaintenanceWorking => 'Buscando actualizaciones...';

  @override
  String get settingsMaintenanceNoUpdates =>
      'Todos los personajes ya están actualizados.';

  @override
  String get settingsMaintenanceError =>
      'No se pudieron actualizar los personajes.';

  @override
  String get settingsMaintenanceConfirmTitle => '¿Actualizar personajes?';

  @override
  String get settingsMaintenanceCompleteTitle => 'Actualización completada';

  @override
  String settingsMaintenanceUpdatesFound(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count personajes necesitan actualizaciones.',
      one: '1 personaje necesita una actualización.',
    );
    return '$_temp0';
  }

  @override
  String settingsMaintenanceConfirmBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count personajes necesitan actualizaciones. La app abrirá una copia de seguridad para que la guardes o compartas antes de aplicar los cambios.',
      one:
          '1 personaje necesita una actualización. La app abrirá una copia de seguridad para que la guardes o compartas antes de aplicar los cambios.',
    );
    return '$_temp0';
  }

  @override
  String get characterUpdateRequiredTitle =>
      'Actualización de personaje necesaria';

  @override
  String get characterUpdateRequiredBody =>
      'Este personaje debe actualizarse antes de abrirlo. Puedes hacer una copia de seguridad o actualizar todos los personajes ahora. Se abrirá una copia de seguridad antes de aplicar los cambios.';

  @override
  String get characterUpdateRequiredAction => 'Opciones de actualización';

  @override
  String get characterUpdateBackupAction => 'Hacer copia de seguridad';

  @override
  String get characterUpdateAllAction => 'Actualizar todos los personajes';

  @override
  String get characterUpdateApplying => 'Actualizando personajes...';

  @override
  String settingsMaintenanceReportChecked(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count personajes revisados.',
      one: '1 personaje revisado.',
    );
    return '$_temp0';
  }

  @override
  String settingsMaintenanceReportUpdated(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count personajes actualizados.',
      one: '1 personaje actualizado.',
    );
    return '$_temp0';
  }

  @override
  String settingsMaintenanceReportDataChanged(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count personajes recibieron correcciones de datos.',
      one: '1 personaje recibió correcciones de datos.',
    );
    return '$_temp0';
  }

  @override
  String get settingsMaintenanceReportVersionUpdated =>
      'Versión de datos actualizada.';

  @override
  String settingsMaintenanceChangeEquipmentWeights(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Se corrigió el peso de $count objetos.',
      one: 'Se corrigió el peso de 1 objeto.',
    );
    return '$_temp0';
  }

  @override
  String settingsMaintenanceChangeEquipmentNormalized(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count objetos de equipo normalizados.',
      one: '1 objeto de equipo normalizado.',
    );
    return '$_temp0';
  }

  @override
  String settingsMaintenanceChangeEquipmentPacksExpanded(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count paquetes de equipo expandidos.',
      one: '1 paquete de equipo expandido.',
    );
    return '$_temp0';
  }

  @override
  String settingsMaintenanceChangeEquipmentOrder(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Orden de $count objetos del inventario normalizado.',
      one: 'Orden de 1 objeto del inventario normalizado.',
    );
    return '$_temp0';
  }

  @override
  String get settingsMaintenanceChangeMulticlassStructure =>
      'Estructura de clases preparada para multiclase.';

  @override
  String get settingsMaintenanceChangeSpellSlots =>
      'Ranuras de hechizo estándar recalculadas.';

  @override
  String get settingsMaintenanceChangePactMagicSlots =>
      'Ranuras de Magia de Pacto separadas.';

  @override
  String get settingsMaintenanceChangeArmorClass =>
      'Clase de Armadura recalculada.';

  @override
  String get settingsMaintenanceChangeRuleset2014 =>
      'Se asignaron a este personaje las reglas de 2014 (SRD 5.1).';

  @override
  String get settingsMaintenanceChangeLevelHistory =>
      'Se guardó el historial de nivel 1 usado para subir y reiniciar niveles.';

  @override
  String get settingsMaintenanceChangeClassSkills =>
      'Se guardó qué habilidades vinieron de la clase en el nivel 1.';

  @override
  String settingsMaintenanceChangeGeneric(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count cambios aplicados.',
      one: '1 cambio aplicado.',
    );
    return '$_temp0';
  }

  @override
  String get incomingBackupPrompt =>
      '¿Importar copia de seguridad desde el archivo?';

  @override
  String incomingBackupSuccess(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count personajes importados desde la copia de seguridad.',
      one: '1 personaje importado desde la copia de seguridad.',
    );
    return '$_temp0';
  }
}
