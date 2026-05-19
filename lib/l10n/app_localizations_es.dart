// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Herramienta de personajes de D&D';

  @override
  String get charListTitle => 'Personajes de D&D';

  @override
  String get charListImportTooltip => 'Importar JSON';

  @override
  String get charListSettingsTooltip => 'Ajustes';

  @override
  String get charListNewCharacter => 'Nuevo personaje';

  @override
  String get charListEmpty => 'Aún no hay personajes';

  @override
  String get charListEmptyHint => 'Toca + para crear tu primer personaje.';

  @override
  String charListImportedSuccess(String name) {
    return '¡$name se importó correctamente!';
  }

  @override
  String get charListImportError =>
      'Error inesperado al importar. Por favor inténtalo de nuevo.';

  @override
  String get importErrorInvalidJson => 'El texto pegado no es un JSON válido.';

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
  String get charCardExport => 'Exportar';

  @override
  String get charCardDelete => 'Borrar';

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
  String get sectionSavingThrows => 'Competencias en tiros de salvación';

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
  String get featuresTabClass => 'Clase';

  @override
  String get featuresTabRacial => 'Racial';

  @override
  String get featuresTabCustom => 'Personaliz.';

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
  String get inventoryLabelDescription => 'Descripción (opcional)';

  @override
  String get inventoryTypeWeapon => 'Arma';

  @override
  String get inventoryTypeArmor => 'Armadura';

  @override
  String get inventoryTypeConsumable => 'Consumible';

  @override
  String get inventoryTypeGear => 'Engranaje';

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
    return '+ carrera $n';
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
  String get statPassivePerc => 'Perc Pasivo';

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
  String get statUnconsciousDying => 'Unconscious / Dying';

  @override
  String get tooltipAddTempHp => 'Agregar HP temporal';

  @override
  String get tooltipChangeTempHp => 'Cambiar temperatura HP';

  @override
  String get abilityStr => 'FUE';

  @override
  String get abilityDex => 'DEX';

  @override
  String get abilityCon => 'ESTAFA';

  @override
  String get abilityInt => 'ENT';

  @override
  String get abilityWis => 'SIO';

  @override
  String get abilityCha => 'CHA';

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
  String get spellsSpellcasting => 'Lanzamiento de hechizos';

  @override
  String get spellsAttack => 'Ataque';

  @override
  String get spellsSaveDC => 'Salvar DC';

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
  String get inventoryCurrency => 'Divisa';

  @override
  String inventoryCarriedSection(int count) {
    return 'Llevado ( $count )';
  }

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
  String get reviewRowHitDie => 'Golpear morir';

  @override
  String get reviewRowSavingThrows => 'Tiros de salvación';

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
  String get exportLabelToken => 'Token';

  @override
  String get exportCopyToken => 'Copiar token';

  @override
  String get exportHideQr => 'Ocultar código QR';

  @override
  String get exportShowQr => 'Mostrar código QR';

  @override
  String get exportQrTooLarge =>
      'El personaje es demasiado grande para el código QR.\nUsa el token o JSON para compartir.';

  @override
  String get exportShowJson => 'Mostrar JSON';

  @override
  String get exportCopyJson => 'Copiar JSON';

  @override
  String get dialogClose => 'Cerrar';

  @override
  String get importDialogTitle => 'Importar personaje';

  @override
  String get importTokenHint => 'Pega el token aquí…';

  @override
  String get importScanQr => 'Escanear código QR';

  @override
  String get importUseJson => 'Usar JSON directamente';

  @override
  String get importJsonHint => 'Pega el JSON aquí…';

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
}
