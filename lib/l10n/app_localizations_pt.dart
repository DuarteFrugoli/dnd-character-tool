// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appTitle => 'D&D Character Tool';

  @override
  String get charListTitle => 'Personagens D&D';

  @override
  String get charListImportTooltip => 'Importar JSON';

  @override
  String get charListSettingsTooltip => 'Configurações';

  @override
  String get charListNewCharacter => 'Novo Personagem';

  @override
  String get charListEmpty => 'Nenhum personagem ainda';

  @override
  String get charListEmptyHint => 'Toque em + para criar seu primeiro personagem';

  @override
  String charListImportedSuccess(String name) {
    return '$name importado com sucesso!';
  }

  @override
  String get charListImportError => 'Erro inesperado ao importar. Tente novamente.';

  @override
  String charCardLevel(int level) {
    return 'Nível $level';
  }

  @override
  String get charCardPin => 'Fixar no topo';

  @override
  String get charCardUnpin => 'Desafixar';

  @override
  String get charCardChangePhoto => 'Alterar foto';

  @override
  String get charCardRename => 'Renomear';

  @override
  String get charCardExport => 'Exportar';

  @override
  String get charCardDelete => 'Excluir';

  @override
  String get renameDialogTitle => 'Renomear personagem';

  @override
  String get renameDialogLabel => 'Nome';

  @override
  String get dialogCancel => 'Cancelar';

  @override
  String get dialogSave => 'Salvar';

  @override
  String get deleteDialogTitle => 'Excluir personagem?';

  @override
  String deleteDialogContent(String name) {
    return 'Tem certeza que deseja excluir $name? Esta ação não pode ser desfeita.';
  }

  @override
  String get dialogConfirm => 'Confirmar';

  @override
  String get dialogDiscard => 'Descartar';

  @override
  String get dialogContinue => 'Continuar';

  @override
  String get dialogKeepEditing => 'Continuar editando';

  @override
  String get dialogRemove => 'Remover';

  @override
  String get dialogAdd => 'Adicionar';

  @override
  String get settingsTitle => 'Configurações';

  @override
  String get settingsSectionTheme => 'Tema Visual';

  @override
  String get settingsDark => 'Escuro';

  @override
  String get settingsLight => 'Claro';

  @override
  String get settingsChooseTheme => 'Escolher Tema';

  @override
  String get settingsSectionLanguage => 'Idioma';

  @override
  String get settingsAppLanguage => 'Idioma do app';

  @override
  String get settingsChooseLanguage => 'Escolher Idioma';

  @override
  String get settingsSystemDefault => 'Padrão do sistema';

  @override
  String get modeSelectionTitle => 'Novo Personagem';

  @override
  String get modeSelectionQuestion => 'Como você quer criar seu personagem?';

  @override
  String get modeGuidedTitle => 'Guiado';

  @override
  String get modeGuidedSubtitle => 'Assistente passo a passo. Escolha classe, raça, antecedente, perícias e atributos um de cada vez. Recomendado para novos jogadores.';

  @override
  String get modeManualTitle => 'Manual';

  @override
  String get modeManualSubtitle => 'Preencha tudo você mesmo. Todos os campos são livres e nenhum valor é calculado para você. Melhor para jogadores experientes.';

  @override
  String get modeRandomTitle => 'Aleatório';

  @override
  String get modeRandomSubtitle => 'Tudo é rolado para você — raça, classe, antecedente e atributos. Ótimo para desafios ou one-shots.';

  @override
  String get modeSemiRandomTitle => 'Semi-aleatório';

  @override
  String get modeSemiRandomSubtitle => 'Você faz as escolhas importantes; todo o resto é rolado. Bom para quando você tem um conceito mas quer surpresas.';

  @override
  String get modeComingSoon => 'Em breve';

  @override
  String get creationStepClass => 'Classe';

  @override
  String get creationStepRace => 'Raça';

  @override
  String get creationStepBackground => 'Antecedente';

  @override
  String get creationStepSkills => 'Perícias';

  @override
  String get creationStepAttributes => 'Atributos';

  @override
  String get creationStepName => 'Nome';

  @override
  String get creationStepReview => 'Revisão';

  @override
  String get creationDiscardTitle => 'Descartar personagem?';

  @override
  String get creationDiscardContent => 'Todo o progresso será perdido. Tem certeza?';

  @override
  String get creationTooltipCancel => 'Cancelar';

  @override
  String get creationBack => 'Voltar';

  @override
  String get creationCreateCharacter => 'Criar Personagem';

  @override
  String get detailLeaveWithoutSaving => 'Sair sem salvar?';

  @override
  String get detailChangesWillBeDiscarded => 'As alterações serão descartadas. Para salvar, use o botão ✓ no canto superior direito.';

  @override
  String get detailLeaveAndDiscard => 'Sair e descartar';

  @override
  String detailErrorLoading(String error) {
    return 'Erro ao carregar personagem: $error';
  }

  @override
  String get detailTooltipLongRest => 'Descanso Longo';

  @override
  String get detailTooltipCancelEdit => 'Cancelar edição';

  @override
  String get detailTooltipDoneEditing => 'Concluir edição';

  @override
  String get detailTooltipEditCharacter => 'Editar personagem';

  @override
  String get detailCancelEditTitle => 'Cancelar edição?';

  @override
  String get detailCancelEditContent => 'Todas as alterações serão descartadas.';

  @override
  String get detailFinishEditTitle => 'Finalizar edição?';

  @override
  String get detailFinishEditContent => 'As alterações serão salvas.';

  @override
  String get detailTabStats => 'Status';

  @override
  String get detailTabSkills => 'Perícias';

  @override
  String get detailTabFeatures => 'Habilidades';

  @override
  String get detailTabSpells => 'Magias';

  @override
  String get detailTabInventory => 'Inventário';

  @override
  String get detailTabNotes => 'Notas';

  @override
  String get longRestTitle => 'Descanso Longo';

  @override
  String get longRestContent => 'Restaurar o HP ao máximo e recuperar todos os espaços de magia?';

  @override
  String get longRestButton => 'Descansar';

  @override
  String get sectionIdentity => 'Identidade';

  @override
  String get sectionHitPoints => 'Pontos de Vida';

  @override
  String get sectionCombat => 'Combate';

  @override
  String get sectionAbilityScores => 'Atributos';

  @override
  String get sectionSavingThrows => 'Proficiências em Resistências';

  @override
  String get labelName => 'Nome';

  @override
  String get labelBackground => 'Antecedente';

  @override
  String get labelChange => 'Alterar';

  @override
  String get labelAlignment => 'Alinhamento';

  @override
  String get labelPlayer => 'Jogador';

  @override
  String get labelLevel => 'Nível';

  @override
  String get labelSubclass => 'Subclasse';

  @override
  String get labelLanguages => 'Idiomas';

  @override
  String get hintAddLanguage => 'Adicionar idioma…';

  @override
  String get labelChoose => 'Escolher';

  @override
  String get labelMaxHP => 'PV Máx';

  @override
  String get labelTempHP => 'PV Temp';

  @override
  String get labelAmount => 'Quantidade';

  @override
  String get labelSpeed => 'Velocidade (ft)';

  @override
  String get detailDamage => 'Dano';

  @override
  String get detailHeal => 'Cura';

  @override
  String get detailNone => 'Nenhum';

  @override
  String get tempHpDialogTitle => 'Adicionar PV Temporários';

  @override
  String get tempHpDialogTitleReplace => 'PV Temporários';

  @override
  String tempHpCurrent(int n) {
    return 'Atual: +$n PV temp';
  }

  @override
  String get tempHpNoStack => 'PV temporários não se acumulam — apenas valores maiores substituem o atual.';

  @override
  String get tempHpReplace => 'Substituir';

  @override
  String subclassConfirmTitle(String feature) {
    return 'Confirmar $feature';
  }

  @override
  String subclassChooseTitle(String feature) {
    return 'Escolher $feature';
  }

  @override
  String subclassConfirmBody(int level, String feature) {
    return 'Você chegou ao nível $level. Confirme ou altere sua $feature.';
  }

  @override
  String subclassChooseBody(int level, String feature) {
    return 'Você chegou ao nível $level! Escolha sua $feature.';
  }

  @override
  String get subclassKeepCurrent => 'Manter atual';

  @override
  String get subclassChangeTitle => 'Trocar subclasse';

  @override
  String get subclassChangeWarning => 'Atenção: magias e proficiências concedidas pela subclasse anterior não são removidas automaticamente. Você precisará ajustá-las manualmente.';

  @override
  String get backgroundChooseTitle => 'Escolher Antecedente';

  @override
  String get featuresTooltipAdd => 'Adicionar habilidade';

  @override
  String get featuresTooltipRemove => 'Remover';

  @override
  String get featuresRemoveTitle => 'Remover habilidade?';

  @override
  String featuresRemoveContent(String name) {
    return '\"$name\" será removida.';
  }

  @override
  String get featuresNoneAvailable => 'Nenhuma habilidade disponível.';

  @override
  String get featuresAddLabel => 'Adicionar Habilidade';

  @override
  String get featuresLoadError => 'Erro ao carregar habilidades.';

  @override
  String get hintSearch => 'Buscar...';

  @override
  String get labelFeatureName => 'Nome';

  @override
  String get labelFeatureDescription => 'Descrição (opcional)';

  @override
  String get labelFeatureType => 'Tipo:';

  @override
  String get labelPassive => 'Passiva';

  @override
  String get labelActive => 'Ativa';

  @override
  String get spellsTooltipAdd => 'Adicionar magia';

  @override
  String get spellsRemoveTitle => 'Remover magia?';

  @override
  String spellsRemoveContent(String name) {
    return 'Remover \"$name\" da sua lista de magias?';
  }

  @override
  String get spellsAtWill => 'À vontade';

  @override
  String get notesTooltipAdd => 'Adicionar nota';

  @override
  String get notesTooltipEdit => 'Editar nota';

  @override
  String get notesTooltipDelete => 'Excluir nota';

  @override
  String get notesDeleteTitle => 'Excluir nota?';

  @override
  String notesDeleteContentNamed(String title) {
    return '\"$title\" será excluída permanentemente.';
  }

  @override
  String get notesDeleteContent => 'Esta nota será excluída permanentemente.';

  @override
  String get notesLabelTitle => 'Título';

  @override
  String get notesLabelContent => 'Conteúdo';

  @override
  String get sectionPersonalityTraits => 'Traços de Personalidade';

  @override
  String get sectionIdeals => 'Ideais';

  @override
  String get sectionBonds => 'Laços';

  @override
  String get sectionFlaws => 'Fraquezas';

  @override
  String get sectionBackstory => 'História';

  @override
  String inventoryEquippedSection(int count, int ac) {
    return 'Equipado ($count)  ·  CA $ac';
  }

  @override
  String get inventoryTooltipAdd => 'Adicionar item';

  @override
  String get inventoryTooltipRemove => 'Remover';

  @override
  String get inventoryRemoveTitle => 'Remover item?';

  @override
  String inventoryRemoveContent(String name) {
    return 'Remover $name do inventário?';
  }

  @override
  String inventoryRemovePartial(int count, int total) {
    return 'Será removido: $count de $total';
  }

  @override
  String get inventoryLabelQuantity => 'Quantidade:';

  @override
  String get inventoryLabelQuantityToRemove => 'Quantidade a remover';

  @override
  String get inventoryAddCustomItem => 'Adicionar Item Personalizado';

  @override
  String get inventoryAddItem => 'Adicionar Item';

  @override
  String get inventoryLabelItemName => 'Nome *';

  @override
  String get inventoryLabelType => 'Tipo';

  @override
  String get inventoryLabelCategory => 'Categoria';

  @override
  String get inventoryLabelItemQuantity => 'Quantidade';

  @override
  String get inventoryLabelDescription => 'Descrição (opcional)';

  @override
  String get inventoryTypeWeapon => 'Arma';

  @override
  String get inventoryTypeArmor => 'Armadura';

  @override
  String get inventoryTypeConsumable => 'Consumível';

  @override
  String get inventoryTypeGear => 'Equipamento';

  @override
  String get inventoryReplaceArmorTitle => 'Substituir armadura equipada?';

  @override
  String get inventoryTabWeapons => 'Armas';

  @override
  String get inventoryTabArmor => 'Armaduras';

  @override
  String get inventoryTabGear => 'Equipamentos';

  @override
  String get inventoryTabMagic => 'Mágicos';

  @override
  String get inventoryTabTools => 'Ferramentas';

  @override
  String get inventoryTabCustom => 'Personalizados';

  @override
  String hintSearchCategory(String category) {
    return 'Buscar $category...';
  }

  @override
  String get stepChooseMethod => 'Escolha seu método:';

  @override
  String get stepStandardArray => 'Array Padrão';

  @override
  String get stepPointBuy => 'Compra de Pontos';

  @override
  String get stepRoll4d6 => 'Rolar 4d6';

  @override
  String get stepDistributeRacialBonuses => 'Distribuir bônus raciais livremente';

  @override
  String get stepAssignRolls => 'Atribuir cada rolagem a um atributo:';

  @override
  String get stepAssignValues => 'Atribuir cada valor a um atributo:';

  @override
  String get stepPointsRemaining => 'Pontos restantes: ';

  @override
  String stepRaceBonus(int n) {
    return '+$n raça';
  }

  @override
  String get stepChooseSubrace => 'Escolha uma sub-raça:';

  @override
  String get stepGrantedByBackground => 'Concedido pelo antecedente:';

  @override
  String stepClassSkillChoices(int count) {
    return 'Escolhas de perícias da classe ($count):';
  }

  @override
  String get stepChooseOne => 'Escolher';

  @override
  String get stepSelectTool => 'Selecionar ferramenta…';

  @override
  String get statAC => 'CA';

  @override
  String get statArmor => 'Armadura';

  @override
  String get statNoArmor => 'Sem armadura';

  @override
  String get statNoArmorShield => 'Sem armadura + Escudo';

  @override
  String get statShieldSuffix => ' + Escudo';

  @override
  String get statSpeed => 'Velocidade';

  @override
  String get statInitiative => 'Iniciativa';

  @override
  String get statProfBonus => 'Bônus Prof.';

  @override
  String get statPassivePerc => 'Perc. Passiva';

  @override
  String get statUnconsciousDying => 'Inconsciente / Morrendo';

  @override
  String get tooltipAddTempHp => 'Adicionar PV temp.';

  @override
  String get tooltipChangeTempHp => 'Alterar PV temp.';

  @override
  String get abilityStr => 'FOR';

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
    return 'Características Raciais — $name';
  }

  @override
  String featuresSectionBackground(String name) {
    return 'Característica de Antecedente — $name';
  }

  @override
  String featuresSectionClass(String name) {
    return 'Características de Classe — $name';
  }

  @override
  String featuresSectionSubclass(String name) {
    return 'Características de Subclasse — $name';
  }

  @override
  String get featuresSectionTools => 'Proficiências de Ferramentas';

  @override
  String get featuresSectionExtra => 'Características Extras';

  @override
  String get spellsNoSpellcasting => 'Sem Conjuração';

  @override
  String get spellsNoSpellcastingDesc => 'Esta classe não possui características de conjuração.';

  @override
  String get spellsSlots => 'Espaços de Magia';

  @override
  String get spellsSpellcasting => 'Conjuração';

  @override
  String get spellsAttack => 'Ataque';

  @override
  String get spellsSaveDC => 'CD de Resistência';

  @override
  String get spellsCantrips => 'Truques';

  @override
  String get spellsPrepared => 'Preparadas';

  @override
  String get spellsKnown => 'Conhecidas';

  @override
  String get spellsEmpty => 'Nenhuma magia adicionada ainda.\nToque em + para navegar pelas magias.';

  @override
  String spellsSlotLevel(int level) {
    return 'Nv $level';
  }

  @override
  String spellsLevelN(int level) {
    return 'Nível $level';
  }

  @override
  String get inventoryCurrency => 'Moedas';

  @override
  String inventoryCarriedSection(int count) {
    return 'Carregados ($count)';
  }

  @override
  String get inventoryInventory => 'Inventário';

  @override
  String get inventoryEmpty => 'Sem itens ainda. Toque em + para adicionar.';

  @override
  String get inventoryAmmunition => 'Munição';

  @override
  String get coinCopper => 'Cobre';

  @override
  String get coinSilver => 'Prata';

  @override
  String get coinElectrum => 'Electrum';

  @override
  String get coinGold => 'Ouro';

  @override
  String get coinPlatinum => 'Platina';

  @override
  String get inventoryGroupSimpleMelee => 'Corpo a Corpo Simples';

  @override
  String get inventoryGroupSimpleRanged => 'À Distância Simples';

  @override
  String get inventoryGroupMartialMelee => 'Corpo a Corpo Marcial';

  @override
  String get inventoryGroupMartialRanged => 'À Distância Marcial';

  @override
  String get inventoryGroupLightArmor => 'Armadura Leve';

  @override
  String get inventoryGroupMediumArmor => 'Armadura Média';

  @override
  String get inventoryGroupHeavyArmor => 'Armadura Pesada';

  @override
  String get inventoryGroupShields => 'Escudos';

  @override
  String get inventoryGroupAdventuringGear => 'Equipamento de Aventura';

  @override
  String get inventoryGroupAmmunition => 'Munições';

  @override
  String get inventoryGroupArcaneFocus => 'Foco Arcano';

  @override
  String get inventoryGroupClothing => 'Vestimentas';

  @override
  String get inventoryGroupContainer => 'Recipientes';

  @override
  String get inventoryGroupPoison => 'Venenos';

  @override
  String get inventoryGroupPotions => 'Poções';

  @override
  String get inventoryGroupRings => 'Anéis';

  @override
  String get inventoryGroupWands => 'Varinhas';

  @override
  String get inventoryGroupWeapons => 'Armas';

  @override
  String get inventoryGroupArmor => 'Armaduras';

  @override
  String get inventoryGroupWondrousItems => 'Itens Maravilhosos';

  @override
  String get inventoryGroupArtisansTools => 'Ferramentas de Artesão';

  @override
  String get inventoryGroupGamingSets => 'Jogos de Mesa';

  @override
  String get inventoryGroupMusicalInstruments => 'Instrumentos Musicais';

  @override
  String get inventoryGroupOtherTools => 'Outras Ferramentas';

  @override
  String get armorStealthDisadvantage => 'Desvantagem em Furtividade';

  @override
  String get spellDetailCastingTime => 'Tempo de conjuração';

  @override
  String get spellDetailRange => 'Alcance';

  @override
  String get spellDetailDuration => 'Duração';

  @override
  String get spellDetailComponents => 'Componentes';

  @override
  String get spellDetailConcentration => 'Requer concentração';

  @override
  String get spellDetailRitual => 'Pode ser conjurada como ritual';

  @override
  String get spellDetailAtHigherLevels => 'Em Níveis Superiores. ';

  @override
  String spellDetailClasses(String classes) {
    return 'Classes: $classes';
  }

  @override
  String spellDetailLevelSchool(String ordinal, String school) {
    return '$ordinalº nível — $school';
  }

  @override
  String spellDetailCantrip(String school) {
    return 'Truque de $school';
  }
}
