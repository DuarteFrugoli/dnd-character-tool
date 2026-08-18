// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appTitle => 'DnD Character Tool';

  @override
  String get charListTitle => 'Personagens DnD';

  @override
  String get charListImportTooltip => 'Importar JSON';

  @override
  String get charListSettingsTooltip => 'Configurações';

  @override
  String get charListNewCharacter => 'Novo Personagem';

  @override
  String get charListEmpty => 'Nenhum personagem ainda';

  @override
  String get charListEmptyHint =>
      'Toque em + para criar seu primeiro personagem';

  @override
  String charListImportedSuccess(String name) {
    return '$name importado com sucesso!';
  }

  @override
  String charListDuplicatedSuccess(String name) {
    return '$name duplicado com sucesso!';
  }

  @override
  String get charListImportError =>
      'Erro inesperado ao importar. Tente novamente.';

  @override
  String get charListDuplicateError =>
      'Não foi possível duplicar o personagem. Tente novamente.';

  @override
  String get importErrorInvalidJson => 'O JSON colado não é válido.';

  @override
  String get importFieldLockedHint => 'Limpe o outro campo para usar este.';

  @override
  String get importErrorNotObject =>
      'Formato inválido: esperado um objeto JSON.';

  @override
  String get importErrorMissingCharacter =>
      'JSON inválido: campo \"character\" não encontrado.';

  @override
  String get importErrorCorruptedCharacter =>
      'Não foi possível ler o personagem. O JSON pode estar incompleto ou ser de uma versão incompatível.';

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
  String get charCardDuplicate => 'Duplicar';

  @override
  String get charCardExport => 'Exportar';

  @override
  String get charCardDelete => 'Excluir';

  @override
  String charDuplicateName(String name) {
    return '$name (cópia)';
  }

  @override
  String charDuplicateNameNumbered(String name, int number) {
    return '$name (cópia $number)';
  }

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
  String get dialogDone => 'Concluído';

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
  String get modeGuidedSubtitle =>
      'Assistente passo a passo. Escolha classe, raça, antecedente, perícias e atributos um de cada vez. Recomendado para novos jogadores.';

  @override
  String get modeManualTitle => 'Manual';

  @override
  String get modeManualSubtitle =>
      'Preencha tudo você mesmo. Todos os campos são livres e nenhum valor é calculado para você. Melhor para jogadores experientes.';

  @override
  String get modeRandomTitle => 'Aleatório';

  @override
  String get modeRandomSubtitle =>
      'Tudo é rolado para você — raça, classe, antecedente e atributos. Ótimo para desafios ou one-shots.';

  @override
  String get modeSemiRandomTitle => 'Semi-aleatório';

  @override
  String get modeSemiRandomSubtitle =>
      'Você faz as escolhas importantes; todo o resto é rolado. Bom para quando você tem um conceito mas quer surpresas.';

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
  String get creationDiscardContent =>
      'Todo o progresso será perdido. Tem certeza?';

  @override
  String get creationTooltipCancel => 'Cancelar';

  @override
  String get creationBack => 'Voltar';

  @override
  String get creationCreateCharacter => 'Criar Personagem';

  @override
  String get detailLeaveWithoutSaving => 'Sair sem salvar?';

  @override
  String get detailChangesWillBeDiscarded =>
      'As alterações serão descartadas. Para salvar, use o botão ✓ no canto superior direito.';

  @override
  String get detailLeaveAndDiscard => 'Sair e descartar';

  @override
  String detailErrorLoading(String error) {
    return 'Erro ao carregar personagem: $error';
  }

  @override
  String get detailTooltipLongRest => 'Descanso Longo';

  @override
  String get characterActionRollDice => 'Rolar dados';

  @override
  String get characterActionResetLevels => 'Reiniciar níveis';

  @override
  String get diceExpressionLabel => 'Expressão';

  @override
  String get diceExpressionHint => 'Exemplo: 1d20+5 ou 4d6dl1';

  @override
  String get diceExpressionHelpTooltip =>
      'Como funcionam as expressões de dados';

  @override
  String get diceExpressionHelpTitle => 'Expressões de dados';

  @override
  String get diceExpressionHelpBody =>
      'Use XdY para rolar dados: 2d6 rola dois dados de 6 lados.\nAdicione ou subtraia modificadores: 1d20+5 ou 2d6 - 1.\nUse d% ou d100 para dado percentual.\nPara vantagem/desvantagem no d20: 2d20kh1 mantém o maior, 2d20kl1 mantém o menor.\nMantenha/descarte dados com kh, kl, dh ou dl. Exemplo: 4d6dl1 rola quatro d6 e descarta o menor.\nEspaços são opcionais: 2d6+1d8 e 2d6 + 1d8 funcionam.';

  @override
  String get diceQuantityLabel => 'Quantidade';

  @override
  String get diceModifierLabel => 'Modificador';

  @override
  String get diceRollButton => 'Rolar';

  @override
  String get diceRerollButton => 'Rolar novamente';

  @override
  String get diceModeNormal => 'Normal';

  @override
  String get diceModeAdvantage => 'Vantagem';

  @override
  String get diceModeDisadvantage => 'Desvantagem';

  @override
  String get diceResultTitle => 'Resultado';

  @override
  String get diceHistoryTitle => 'Rolagens recentes';

  @override
  String get diceNoRollsYet => 'Nenhuma rolagem ainda.';

  @override
  String get diceNaturalOne => '1 natural';

  @override
  String get diceNaturalTwenty => '20 natural';

  @override
  String diceInvalidExpression(String message) {
    return 'Expressão de dados inválida: $message';
  }

  @override
  String get detailTooltipCancelEdit => 'Cancelar edição';

  @override
  String get detailTooltipDoneEditing => 'Concluir edição';

  @override
  String get detailTooltipEditCharacter => 'Editar personagem';

  @override
  String get detailCancelEditTitle => 'Cancelar edição?';

  @override
  String get detailCancelEditContent =>
      'Todas as alterações serão descartadas.';

  @override
  String get detailFinishEditTitle => 'Finalizar edição?';

  @override
  String get detailFinishEditContent => 'As alterações serão salvas.';

  @override
  String get detailTabIdentity => 'Identidade';

  @override
  String get detailEditButton => 'Editar';

  @override
  String get skillsEditHint =>
      'Segure para alternar: nenhum → proficiente → experiente';

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
  String get longRestContent =>
      'Restaurar o HP ao máximo e recuperar todos os espaços de magia?';

  @override
  String get longRestButton => 'Descansar';

  @override
  String get restPickerTitle => 'Descanso';

  @override
  String get restPickerShort => 'Descanso Curto';

  @override
  String get restPickerShortCaption => 'Gaste Dados de Vida para recuperar PV';

  @override
  String get restPickerLong => 'Descanso Longo';

  @override
  String get restPickerLongCaption =>
      'Recupera PV máximos e todos os espaços de magia';

  @override
  String get shortRestTitle => 'Descanso Curto';

  @override
  String get shortRestAvailableDice => 'Dados de Vida disponíveis';

  @override
  String get shortRestSpend => 'Gastar';

  @override
  String get shortRestRolled => 'PV recuperados';

  @override
  String get shortRestRollButton => 'Rolar';

  @override
  String get shortRestButton => 'Descansar';

  @override
  String get shortRestNoDice => 'Sem Dados de Vida restantes';

  @override
  String get concentrationBannerLabel => 'Concentrado em:';

  @override
  String get concentrationBreakButton => 'Encerrar';

  @override
  String get concentrationReplaceTitle => 'Substituir Concentração?';

  @override
  String concentrationReplaceBody(String current, String next) {
    return 'Você está concentrado em $current. Iniciar $next vai encerrar sua concentração.';
  }

  @override
  String get concentrationReplaceConfirm => 'Substituir';

  @override
  String get concentrationTooltip => 'Definir concentração';

  @override
  String get sectionIdentity => 'Identidade';

  @override
  String get sectionHitPoints => 'Pontos de Vida';

  @override
  String get sectionCombat => 'Combate';

  @override
  String get sectionProgression => 'Progressão';

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
  String get tooltipLevelUp => 'Upar Nível';

  @override
  String get levelUpTitle => 'Subir de Nível';

  @override
  String get levelUpStepClassTarget => 'Escolher classe para subir';

  @override
  String get levelUpClassTargetExisting => 'Classes atuais';

  @override
  String get levelUpClassTargetAddClass => 'Adicionar uma nova classe';

  @override
  String levelUpClassTargetCurrentLevel(int level) {
    return 'Nível atual $level';
  }

  @override
  String levelUpClassTargetNextClassLevel(int level) {
    return 'Nível de classe $level';
  }

  @override
  String levelUpClassTargetRequirement(String requirement) {
    return 'Requer $requirement';
  }

  @override
  String levelUpClassTargetRequirementMissing(String requirement) {
    return 'Requisito ausente: $requirement';
  }

  @override
  String get levelUpClassTargetCurrentRequirementsMissing =>
      'Sua classe atual não cumpre o requisito de multiclasse.';

  @override
  String get levelUpConfirm => 'Confirmar Level Up';

  @override
  String get levelUpCancel => 'Cancelar';

  @override
  String get levelUpStepFeatures => 'Novas Habilidades';

  @override
  String levelUpStepSubclass(String feature) {
    return 'Escolher $feature';
  }

  @override
  String get levelUpStepAsi => 'Melhoria de Atributo';

  @override
  String get levelUpStepHp => 'Pontos de Vida';

  @override
  String get levelUpStepCantrips => 'Novos Truques';

  @override
  String get levelUpStepSpells => 'Novas Magias';

  @override
  String get levelUpStepSummary => 'Resumo';

  @override
  String get levelUpNoNewFeatures =>
      'Nenhuma nova habilidade de classe neste nível.';

  @override
  String get featureChoicesTitle => 'Escolhas de Habilidades';

  @override
  String get featureChoicesPending => 'Escolha pendente';

  @override
  String get featureChoicesEdit => 'Editar escolhas';

  @override
  String get featureChoicesChooseDependencyFirst =>
      'Escolha primeiro a opção necessária acima.';

  @override
  String featureChoicesChooseCount(String kind, int count) {
    return 'Escolha $count $kind.';
  }

  @override
  String featureChoicesSelectedCount(int selected, int count) {
    return '$selected/$count selecionadas';
  }

  @override
  String get levelUpHpRoll => 'Rolar';

  @override
  String get levelUpHpAverage => 'Média';

  @override
  String levelUpHpGained(int n) {
    return '+$n PV';
  }

  @override
  String levelUpHpFormula(int die, String mod) {
    return 'd$die + CON ($mod)';
  }

  @override
  String get levelUpAsiOption => 'Melhoria de Atributo';

  @override
  String get levelUpFeatOption => 'Escolher um Talento';

  @override
  String levelUpAsiPointsLeft(int n) {
    return '$n ponto(s) restante(s)';
  }

  @override
  String levelUpSpellsToLearn(int n) {
    return 'Escolher $n magia(s)';
  }

  @override
  String get levelUpSpellRestrictedSection => 'Exigência de escola';

  @override
  String get levelUpSpellFreeSection => 'Escolha livre';

  @override
  String levelUpSpellRestrictedInstruction(int count, String schools) {
    return 'Escolha $count magia(s) de $schools.';
  }

  @override
  String levelUpSpellFreeInstruction(int count) {
    return 'Escolha $count magia(s) de qualquer escola.';
  }

  @override
  String get levelUpSpellFreeLocked =>
      'Complete a exigência de escola primeiro.';

  @override
  String levelUpCantripsToLearn(int n) {
    return 'Escolher $n truque(s)';
  }

  @override
  String get levelUpSpellSwap => 'Substituir uma magia conhecida (opcional)';

  @override
  String levelUpSpellSwapCurrent(String name) {
    return 'Atual: $name';
  }

  @override
  String levelUpSummaryLevel(int level) {
    return '→ Nível $level';
  }

  @override
  String levelUpSummaryClassLevel(String className, int level) {
    return '$className nível $level';
  }

  @override
  String levelUpSummaryHp(int n) {
    return 'PV Máx +$n';
  }

  @override
  String levelUpSummaryAsi(String changes) {
    return 'MHA: $changes';
  }

  @override
  String levelUpSummaryFeat(String name) {
    return 'Talento: $name';
  }

  @override
  String levelUpSummarySubclass(String name) {
    return 'Subclasse: $name';
  }

  @override
  String levelUpSummarySpellsLearned(int count) {
    return 'Magias aprendidas: $count';
  }

  @override
  String levelUpSummaryCantripsLearned(int count) {
    return 'Truques aprendidos: $count';
  }

  @override
  String levelUpSubclassAlreadyHas(String name) {
    return 'Subclasse atual: $name';
  }

  @override
  String get levelUpMaxLevel => 'Já está no nível máximo (20).';

  @override
  String get levelUpHpReroll => 'Rolar novamente / alterar';

  @override
  String get levelUpSpellSwapPickReplacement =>
      'Agora escolha uma magia substituta';

  @override
  String get levelUpSpellSwapReplaceWith => 'Substituir por';

  @override
  String get levelUpSpellSwapNone => 'Nenhuma';

  @override
  String get levelUpSpellAlreadyKnown => 'Já conhecida';

  @override
  String levelUpSpellCantripSubtitle(String school) {
    return '$school (truque)';
  }

  @override
  String levelUpSpellSubtitle(int level, String school) {
    return 'Nv $level $school';
  }

  @override
  String get resetLevelsTitle => 'Reiniciar níveis';

  @override
  String get resetLevelsConfirmBody =>
      'Isso vai reiniciar a progressão de classe para o nível 1. Suas notas, inventário, containers, moedas, imagem, história, aparência, raça, antecedente e atributos serão mantidos.\n\nNíveis de classe, magias de classe, escolhas de classe/subclasse, recursos de progressão e talentos de ASI serão removidos ou recalculados. Exporte um backup antes se quiser uma cópia extra.';

  @override
  String resetLevelsCountdown(int seconds) {
    return 'Aguarde ${seconds}s';
  }

  @override
  String get resetLevelsIntro =>
      'Escolha os novos dados de classe do nível 1. O reset só é salvo quando você pressionar o botão final.';

  @override
  String get resetLevelsSubclassRequired =>
      'Esta classe escolhe uma subclasse no nível 1.';

  @override
  String resetLevelsInitialHp(int hp) {
    return 'PV inicial: $hp';
  }

  @override
  String resetLevelsSelectSkills(int count) {
    return 'Escolha $count perícias de classe.';
  }

  @override
  String get resetLevelsFixedTools => 'Concedido automaticamente:';

  @override
  String resetLevelsSelectTools(int count) {
    return 'Escolha $count proficiências com ferramentas.';
  }

  @override
  String get resetLevelsApply => 'Reiniciar para nível 1';

  @override
  String resetLevelsApplyAndRebuild(int level) {
    return 'Reiniciar e reconstruir até o nível $level';
  }

  @override
  String get resetLevelsIncomplete => 'Complete as escolhas obrigatórias';

  @override
  String get resetLevelsApplied => 'Níveis reiniciados.';

  @override
  String resetLevelsRebuildTitle(int level) {
    return 'Reconstruir até o nível $level';
  }

  @override
  String resetLevelsRebuildSubtitle(int level) {
    return 'Depois de escolher o nível 1, o app abre os passos de Level Up até o nível $level. Se você cancelar antes do fim, nada é salvo.';
  }

  @override
  String resetLevelsRebuildStep(int level, int targetLevel) {
    return 'Reconstruindo nível $level de $targetLevel';
  }

  @override
  String get resetLevelsRebuildCancelled =>
      'Reset cancelado. Nenhuma alteração foi salva.';

  @override
  String resetLevelsRebuiltApplied(int level) {
    return 'Níveis reiniciados e reconstruídos até o nível $level.';
  }

  @override
  String get labelSubclass => 'Subclasse';

  @override
  String get labelLanguages => 'Idiomas';

  @override
  String get hintAddLanguage => 'Adicionar idioma…';

  @override
  String get labelChoose => 'Escolher';

  @override
  String get sectionAppearance => 'Aparência';

  @override
  String get labelAge => 'Idade';

  @override
  String get labelHeight => 'Altura';

  @override
  String get labelWeight => 'Peso';

  @override
  String get labelEyes => 'Olhos';

  @override
  String get labelSkin => 'Pele';

  @override
  String get labelHair => 'Cabelo';

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
  String get tempHpNoStack =>
      'PV temporários não se acumulam — apenas valores maiores substituem o atual.';

  @override
  String get tempHpReplace => 'Substituir';

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
  String get subclassChangeWarning =>
      'Atenção: magias e proficiências concedidas pela subclasse anterior não são removidas automaticamente. Você precisará ajustá-las manualmente.';

  @override
  String get backgroundChooseTitle => 'Escolher Antecedente';

  @override
  String get featuresTooltipAdd => 'Adicionar habilidade';

  @override
  String get featuresTooltipRemove => 'Remover';

  @override
  String get featuresTooltipEnable => 'Habilitar';

  @override
  String get featuresTooltipDisable => 'Desabilitar';

  @override
  String get featuresTabFeats => 'Talentos';

  @override
  String featPrerequisite(String req) {
    return 'Pré-requisito: $req';
  }

  @override
  String get featuresSectionFeats => 'Talentos';

  @override
  String get featuresTabClass => 'Classe';

  @override
  String get featuresTabRacial => 'Racial';

  @override
  String get featuresTabCustom => 'Personalizado';

  @override
  String get featuresTabTools => 'Ferramentas';

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
  String get notesEmptyTitle => 'Nenhuma nota ainda';

  @override
  String get notesEmptyHint => 'Toque em + para criar sua primeira nota.';

  @override
  String get notesUntitled => 'Sem título';

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
  String get notesSearchHint => 'Pesquisar notas ou tags';

  @override
  String get notesNoResultsTitle => 'Nenhuma nota encontrada';

  @override
  String get notesNoResultsHint =>
      'Tente outra busca ou limpe o filtro de tag.';

  @override
  String get notesReadMore => 'Ler mais';

  @override
  String get notesTags => 'Tags';

  @override
  String get notesAllTags => 'Todas';

  @override
  String get notesCustomTag => 'Tag personalizada';

  @override
  String get notesAddTag => 'Adicionar tag';

  @override
  String get notesTagColor => 'Cor da tag';

  @override
  String get notesChooseTagColor => 'Escolher cor da tag';

  @override
  String get notesTooltipPin => 'Fixar nota';

  @override
  String get notesTooltipUnpin => 'Desafixar nota';

  @override
  String get notesMoveUp => 'Mover para cima';

  @override
  String get notesMoveDown => 'Mover para baixo';

  @override
  String get notesMoreActions => 'Mais ações';

  @override
  String get notesPinnedSection => 'Fixadas';

  @override
  String get notesOtherSection => 'Notas';

  @override
  String get notesDefaultTagSession => 'Sessão';

  @override
  String get notesDefaultTagNpc => 'NPC';

  @override
  String get notesDefaultTagQuest => 'Missão';

  @override
  String get notesDefaultTagPlace => 'Lugar';

  @override
  String get notesDefaultTagLoot => 'Loot';

  @override
  String get notesDefaultTagRule => 'Regra';

  @override
  String get sectionPersonalityTraits => 'Traços de Personalidade';

  @override
  String get sectionPersonality => 'Personalidade';

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
  String get inventoryTooltipMove => 'Mover';

  @override
  String inventoryMoveTitle(String name) {
    return 'Mover $name';
  }

  @override
  String get inventoryMoveToInventory => 'Inventário';

  @override
  String inventoryContainersSection(int count) {
    return 'Recipientes ($count)';
  }

  @override
  String inventoryContainerContents(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count itens',
      one: '1 item',
    );
    return '$_temp0';
  }

  @override
  String get inventoryContainerEmpty => 'Vazio';

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
  String get inventoryRemoveContainerTitle => 'Remover recipiente?';

  @override
  String inventoryRemoveContainerContent(String name, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count itens',
      one: '1 item',
    );
    return '$name contém $_temp0. O que deve acontecer com eles?';
  }

  @override
  String get inventoryRemoveContainerMoveContents =>
      'Mover itens para o inventário';

  @override
  String get inventoryRemoveContainerDeleteContents => 'Remover tudo';

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
  String get inventoryLabelWeight => 'Peso';

  @override
  String get weightCarried => 'Carregando';

  @override
  String get weightCapacity => 'Capacidade';

  @override
  String get weightEncumbered => 'Sobrecarregado';

  @override
  String get weightHeavilyEncumbered => 'Muito Sobrecarregado';

  @override
  String get weightEnableTooltip => 'Ativar rastreamento de peso';

  @override
  String get weightDisableTooltip => 'Desativar rastreamento de peso';

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
  String get inventoryTypeEquippable => 'Equipável';

  @override
  String get inventoryTypeContainer => 'Recipiente';

  @override
  String get inventoryAddItemError => 'Não foi possível adicionar o item.';

  @override
  String inventoryLoadItemsError(String error) {
    return 'Erro ao carregar itens:\n$error';
  }

  @override
  String inventoryNoResults(String query) {
    return 'Nenhum resultado para \"$query\"';
  }

  @override
  String get inventoryTooltipEquip => 'Equipar';

  @override
  String get inventoryTooltipUnequip => 'Desequipar';

  @override
  String get inventoryCustomDamageDice => 'Dano (ex: 1d8)';

  @override
  String get inventoryCustomDamageType => 'Tipo de dano';

  @override
  String get inventoryCustomWeaponProperties =>
      'Propriedades (separadas por vírgula)';

  @override
  String get inventoryCustomRangeNormal => 'Alcance normal';

  @override
  String get inventoryCustomRangeLong => 'Alcance longo';

  @override
  String get inventoryCustomAddDexToAc => 'Adicionar DES na CA';

  @override
  String get inventoryCustomEquipSlot => 'Slot (ex: anel, pescoço)';

  @override
  String get inventoryCustomCompatibleWith =>
      'Compatível com (separado por vírgula)';

  @override
  String get inventoryDetailYes => 'Sim';

  @override
  String get inventoryDetailNo => 'Não';

  @override
  String get inventoryDetailMaxShort => 'máx.';

  @override
  String get inventoryDetailDamage => 'Dano';

  @override
  String get inventoryDetailDamageType => 'Tipo de dano';

  @override
  String get inventoryDetailWeaponProperties => 'Propriedades';

  @override
  String get inventoryDetailVersatileDamage => 'Dano versátil';

  @override
  String get inventoryDetailRange => 'Alcance';

  @override
  String get inventoryDetailRangeNormal => 'normal';

  @override
  String get inventoryDetailRangeLong => 'longo';

  @override
  String get inventoryDetailArmorType => 'Tipo de armadura';

  @override
  String get inventoryDetailShield => 'Escudo';

  @override
  String get inventoryDetailBaseAc => 'CA base';

  @override
  String get inventoryDetailAcBonus => 'Bônus de CA';

  @override
  String get inventoryDetailAddDexToAc => 'Soma DES na CA';

  @override
  String get inventoryDetailMaxDex => 'Máx DES';

  @override
  String get inventoryDetailStrengthMinimum => 'Força mínima';

  @override
  String get inventoryDetailEquipSlot => 'Slot';

  @override
  String get inventoryDetailRequiresAttunement => 'Requer sintonia';

  @override
  String get inventoryDetailCapacityWeight => 'Capacidade de peso';

  @override
  String get inventoryDetailCapacityVolume => 'Volume';

  @override
  String get inventoryDetailCapacityVolumeUnit => 'Unidade de volume';

  @override
  String get inventoryDetailIgnoreContentWeight => 'Ignora peso do conteúdo';

  @override
  String get inventoryDetailEffect => 'Efeito';

  @override
  String get inventoryDetailUses => 'Usos';

  @override
  String get inventoryDetailAction => 'Ação';

  @override
  String get inventoryDetailAmmoType => 'Tipo de munição';

  @override
  String get inventoryDetailCompatibleWith => 'Compatível com';

  @override
  String get inventoryDetailBonus => 'Bônus';

  @override
  String get inventoryDetailExtraDamage => 'Dano extra';

  @override
  String get inventoryDetailExtraDamageType => 'Tipo do dano extra';

  @override
  String get inventoryDetailSubtype => 'Subtipo';

  @override
  String get inventoryDetailCost => 'Custo';

  @override
  String get inventoryDetailRarity => 'Raridade';

  @override
  String get inventoryDetailFeatures => 'Características';

  @override
  String get inventoryDetailWeightEach => 'Peso por item';

  @override
  String get inventoryDetailWeightTotal => 'Peso total';

  @override
  String get inventoryDetailState => 'Estado';

  @override
  String get inventoryDetailEquipped => 'Equipado';

  @override
  String get inventoryDetailNotEquipped => 'Não equipado';

  @override
  String get inventoryDetailSummary => 'Resumo';

  @override
  String get inventoryDetailDescription => 'Descrição';

  @override
  String get inventoryDetailAttributes => 'Atributos';

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
  String get stepDistributeRacialBonuses =>
      'Distribuir bônus raciais livremente';

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
  String get statInspiration => 'Inspiração';

  @override
  String get statXP => 'XP';

  @override
  String get inspirationGranted => 'Concedida';

  @override
  String get inspirationNotGranted => 'Não concedida';

  @override
  String statLevel(int level) {
    return 'Nível $level';
  }

  @override
  String get tooltipAddXp => 'Adicionar XP';

  @override
  String get labelLevelTable => 'Tabela de Níveis';

  @override
  String get statUnconsciousDying => 'Inconsciente / Morrendo';

  @override
  String get deathSavesTitle => 'Salvaguardas de Morte';

  @override
  String get deathSavesSuccesses => 'Sucessos';

  @override
  String get deathSavesFailures => 'Falhas';

  @override
  String get deathSavesStabilized => 'Estabilizado';

  @override
  String get deathSavesDead => 'Morto';

  @override
  String get sectionActiveConditions => 'Condições Ativas';

  @override
  String get conditionsNone => 'Nenhuma ativa';

  @override
  String get conditionsAdd => 'Adicionar condição';

  @override
  String get conditionsPickTitle => 'Aplicar Condição';

  @override
  String get conditionsRemove => 'Remover condição';

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
  String get spellsNoSpellcastingDesc =>
      'Esta classe não possui características de conjuração.';

  @override
  String get spellsSlots => 'Espaços de Magia';

  @override
  String get spellsPactMagicSlots => 'Magia de Pacto';

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
  String get spellsEmpty =>
      'Nenhuma magia adicionada ainda.\nToque em + para navegar pelas magias.';

  @override
  String spellsSlotLevel(int level) {
    return 'Nv $level';
  }

  @override
  String spellsLevelN(int level) {
    return 'Nível $level';
  }

  @override
  String get spellsInnateHeader => 'Magias Raciais';

  @override
  String get spellsDisableTitle => 'Desativar magia?';

  @override
  String get spellsEnableTitle => 'Reativar magia?';

  @override
  String spellsDisableContent(String name) {
    return 'Desativar \"$name\"? Ela ficará esmaecida e não poderá ser preparada.';
  }

  @override
  String spellsEnableContent(String name) {
    return 'Reativar \"$name\"? Ela voltará a aparecer normalmente.';
  }

  @override
  String get spellsDisable => 'Desativar';

  @override
  String get spellsEnable => 'Reativar';

  @override
  String get spellsExtrasHeader => 'Magias Extras';

  @override
  String get spellFilterTitle => 'Filtros';

  @override
  String get spellFilterReset => 'Redefinir';

  @override
  String get spellFilterApply => 'Aplicar Filtros';

  @override
  String get spellFilterSectionClasses => 'Classes';

  @override
  String get spellFilterClassesHint =>
      'Nenhuma classe selecionada = mostrar todas as classes';

  @override
  String get spellFilterSectionLevel => 'Nível de Magia';

  @override
  String get spellFilterShowAllLevels => 'Mostrar todos os níveis';

  @override
  String spellFilterShowAllLevelsHint(int max) {
    return 'Incluir magias acima do seu máximo atual (Nível $max)';
  }

  @override
  String get spellFilterCantrip => 'Truque';

  @override
  String spellFilterLvl(int n) {
    return 'Nível $n';
  }

  @override
  String get spellFilterSectionCastingTime => 'Tempo de Conjuração';

  @override
  String get spellFilterCastAction => 'Ação';

  @override
  String get spellFilterCastBonus => 'Ação de bônus';

  @override
  String get spellFilterCastReaction => 'Reação';

  @override
  String get spellFilterCastLonger => 'Conjuração longa (1 min+)';

  @override
  String get spellFilterSectionProperties => 'Propriedades';

  @override
  String get spellFilterConcentration => 'Concentração';

  @override
  String get spellFilterConcentrationHint =>
      'Apenas magias que exigem concentração';

  @override
  String get spellFilterRitual => 'Ritual';

  @override
  String get spellFilterRitualHint =>
      'Apenas magias que podem ser conjuradas como rituais';

  @override
  String get spellFilterSectionSchool => 'Escola de Magia';

  @override
  String get spellRemoveTitle => 'Remover magia';

  @override
  String spellRemoveContent(String name) {
    return 'Remover \"$name\" da sua lista de magias?';
  }

  @override
  String get spellActionPrepared => 'Preparada — toque para despreparar';

  @override
  String get spellActionPrepare => 'Preparar para hoje';

  @override
  String get spellActionAdd => 'Adicionar ao personagem';

  @override
  String get spellActionInList => 'Na sua lista — toque para remover';

  @override
  String get spellActionAlreadyInList => 'Já está na sua lista de magias';

  @override
  String get spellActionClassSpellInfo =>
      'Esta magia já faz parte da lista da sua classe e não precisa ser aprendida.';

  @override
  String get inventoryCurrency => 'Moedas';

  @override
  String inventoryCarriedSection(int count) {
    return 'Carregados ($count)';
  }

  @override
  String inventoryEquippableSection(int count) {
    return 'Equipáveis ($count)';
  }

  @override
  String get inventoryEquipHint =>
      'Toque no ícone circular à esquerda para equipar ou desequipar';

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
  String get spellRangeSelf => 'Si mesmo';

  @override
  String get spellRangeTouch => 'Toque';

  @override
  String get spellRangeSight => 'Visão';

  @override
  String get spellRangeSpecial => 'Especial';

  @override
  String get spellRangeUnlimited => 'Ilimitado';

  @override
  String get spellAreaSphere => 'esfera';

  @override
  String get spellAreaCone => 'cone';

  @override
  String get spellAreaCube => 'cubo';

  @override
  String get spellAreaCylinder => 'cilindro';

  @override
  String get spellAreaLine => 'linha';

  @override
  String get spellAreaWall => 'parede';

  @override
  String get spellAreaCircle => 'círculo';

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

  @override
  String armorSwapCurrent(String name) {
    return 'Atual: $name';
  }

  @override
  String armorSwapAcNow(int ac) {
    return 'CA atual: $ac';
  }

  @override
  String armorSwapAcAfter(int ac) {
    return 'CA depois: $ac';
  }

  @override
  String get armorSwapButton => 'Trocar armadura';

  @override
  String get reviewRowName => 'Nome';

  @override
  String get reviewUnnamedHero => 'Herói Sem Nome';

  @override
  String get reviewRowPlayer => 'Jogador';

  @override
  String get reviewRowSubclass => 'Subclasse';

  @override
  String get reviewRowHitDie => 'Dado de Vida';

  @override
  String get reviewRowSavingThrows => 'Resistências';

  @override
  String get reviewRowSubrace => 'Subraça';

  @override
  String get reviewRowSpeed => 'Movimento';

  @override
  String get reviewRowLanguages => 'Idiomas';

  @override
  String get reviewRowFeature => 'Habilidade';

  @override
  String get reviewRowFromBackground => 'Do antecedente';

  @override
  String get reviewRowClassChoices => 'Escolhas da classe';

  @override
  String get reviewRowMaxHp => 'PV Máx.';

  @override
  String get reviewRowAcUnarmored => 'CA (Sem armadura)';

  @override
  String reviewRowAcWith(String name) {
    return 'CA com $name';
  }

  @override
  String get reviewRowProficiencyBonus => 'Bônus de Proficiência';

  @override
  String get reviewStartingGold => 'Ouro Inicial';

  @override
  String get reviewStartingEquipment => 'Equipamento Inicial';

  @override
  String get reviewDeselectAll => 'Desmarcar todos';

  @override
  String get reviewSelectAll => 'Marcar todos';

  @override
  String get reviewUncheckHint =>
      'Desmarque os itens que não quer adicionar ao inventário.';

  @override
  String get reviewEquipmentChoices => 'Escolhas de Equipamento';

  @override
  String get reviewEquipmentChoicesHint =>
      'Escolha o item específico para cada vaga.';

  @override
  String get reviewToolProficiencies => 'Proficiências em Ferramentas';

  @override
  String get reviewChooseToolProficiency =>
      'Escolha sua proficiência em ferramenta:';

  @override
  String reviewChooseLanguages(int count) {
    return 'Escolha $count idioma(s) concedido(s) pela sua raça ou antecedente.';
  }

  @override
  String get reviewChooseOne => 'Escolha uma opção:';

  @override
  String get stepTashaRule =>
      'Regra opcional de Tasha — distribua pontos de ATR em qualquer atributo';

  @override
  String get stepRollDice => 'Rolar dados';

  @override
  String get stepReroll => 'Rolar novamente';

  @override
  String get stepRollHint => 'Role para gerar 6 valores (4d6, menor excluído)';

  @override
  String get stepPrimaryAbilities => 'habilidades primárias: ';

  @override
  String get stepNameTitle => 'Dê um nome ao seu personagem.';

  @override
  String get stepNameHint => 'Você pode alterar isso depois.';

  @override
  String get stepNameCharLabel => 'Nome do personagem';

  @override
  String get stepNamePlayerLabel => 'Nome do jogador (opcional)';

  @override
  String get stepHitDieLabel => 'Dado de Vida';

  @override
  String get stepSavesLabel => 'Resistências';

  @override
  String get stepSpellcastingLabel => 'Conjuração';

  @override
  String get stepOptionsLabel => 'opções';

  @override
  String stepChooseSubclassPrompt(String feature, int level) {
    return 'Escolha um(a) $feature (Nv $level):';
  }

  @override
  String get stepRaceSpeedLabel => 'Velocidade';

  @override
  String get stepRaceASILabel => 'Bônus de Atributo';

  @override
  String stepRaceSubracesAvailable(int count) {
    return '$count subraças disponíveis';
  }

  @override
  String stepChooseSkillsHint(int count) {
    return 'Escolha $count perícias da lista da sua classe.';
  }

  @override
  String get abilityStrength => 'Força';

  @override
  String get abilityDexterity => 'Destreza';

  @override
  String get abilityConstitution => 'Constituição';

  @override
  String get abilityIntelligence => 'Inteligência';

  @override
  String get abilityWisdom => 'Sabedoria';

  @override
  String get abilityCharisma => 'Carisma';

  @override
  String stepFreeAsiRemaining(int remaining) {
    return 'Distribua os bônus raciais livremente ($remaining restantes):';
  }

  @override
  String stepFreePicksRemaining(int total, int remaining) {
    return 'ASI racial livre: atribua +1 a $total atributos ($remaining restantes):';
  }

  @override
  String get stepFreePicksNoStack =>
      'Não é possível atribuir a atributos que já recebem bônus racial.';

  @override
  String reviewClassEquipmentTitle(String name) {
    return 'Equipamento de Classe — $name';
  }

  @override
  String get reviewEquipmentIncluded => 'Incluído:';

  @override
  String get stepToolCategoryGamingSet => 'Kit de jogo';

  @override
  String get stepToolCategoryInstrument => 'Instrumento musical';

  @override
  String get stepToolCategoryArtisanTool => 'Ferramenta de artesão';

  @override
  String get stepToolCategoryArtisanOrInstrument =>
      'Ferramenta de artesão ou instrumento';

  @override
  String exportCopied(String label) {
    return '$label copiado!';
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
  String get exportSectionFile => 'Arquivo completo';

  @override
  String get exportSectionFileCaption => 'Inclui a foto do personagem';

  @override
  String get exportShareFile => 'Compartilhar .dndchar';

  @override
  String get dialogClose => 'Fechar';

  @override
  String get importDialogTitle => 'Importar Personagem';

  @override
  String get importUseJson => 'Usar JSON diretamente';

  @override
  String get importJsonHint => 'Cole o JSON aqui…';

  @override
  String get importPickFile => 'Escolher arquivo .dndchar';

  @override
  String get importFileError => 'Arquivo .dndchar inválido ou corrompido';

  @override
  String get importFileIncoming => 'Importar personagem do arquivo?';

  @override
  String get dialogImport => 'Importar';

  @override
  String get spellBrowserTitle => 'Buscar Magias';

  @override
  String get spellBrowserFilters => 'Filtros';

  @override
  String get spellBrowserSearchHint => 'Buscar magias...';

  @override
  String get filterClearAll => 'Limpar tudo';

  @override
  String get loadingLabel => 'Carregando...';

  @override
  String spellBrowserCount(int count, String s) {
    return '$count magia$s';
  }

  @override
  String get spellBrowserEmpty =>
      'Nenhuma magia corresponde aos filtros atuais.';

  @override
  String get spellCantrip => 'Truque';

  @override
  String spellLevelN(int n) {
    return 'Nív $n';
  }

  @override
  String get castingTimeAction => 'Ação';

  @override
  String get castingTimeBonusAction => 'Ação bônus';

  @override
  String get castingTimeReaction => 'Reação';

  @override
  String get castingTimeLonger => 'Conjuração longa';

  @override
  String get filterConcentration => 'Concentração';

  @override
  String get filterRitual => 'Ritual';

  @override
  String get filterAllLevels => 'Todos os níveis';

  @override
  String get avatarChoosePhoto => 'Escolher foto';

  @override
  String get avatarRemovePhoto => 'Remover foto';

  @override
  String get avatarCropPhoto => 'Recortar foto';

  @override
  String get avatarChangePhoto => 'Alterar foto';

  @override
  String get avatarSavePhoto => 'Salvar foto';

  @override
  String get avatarSaveSuccess => 'Foto salva na galeria';

  @override
  String get avatarSaveError => 'Não foi possível salvar a foto';

  @override
  String featureAddedSnackbar(String name) {
    return '$name adicionada!';
  }

  @override
  String get featureAddButton => 'Adicionar Feature';

  @override
  String get reviewLanguageChoices => 'Escolhas de Idioma';

  @override
  String get reviewLanguageTypeHint => 'Digite um idioma…';

  @override
  String get avatarRemoveConfirmTitle => 'Remover foto?';

  @override
  String get avatarRemoveConfirmBody => 'Esta ação não pode ser desfeita.';

  @override
  String get editModeBanner => 'Editando';

  @override
  String get detailSheetInfoTooltip => 'Detalhes';

  @override
  String get detailSheetProficiencies => 'Proficiências';

  @override
  String get detailSheetTraits => 'Características';

  @override
  String get detailSheetSubclassFeaturePlaceholder => 'Habilidade de Subclasse';

  @override
  String detailSheetAvailableSubclasses(String feature) {
    return '$feature disponíveis';
  }

  @override
  String get detailSheetAvailableSubraces => 'Subraças';

  @override
  String get xpTrackingLabel => 'Rastrear XP';

  @override
  String get xpReadyToLevelUp => 'Pronto para subir de nível!';

  @override
  String get xpLevelUpNowTitle => 'Subir de Nível?';

  @override
  String xpLevelUpNowMessage(int level) {
    return 'Você tem XP suficiente para atingir o Nível $level. Subir de nível agora?';
  }

  @override
  String get xpLevelUpLater => 'Depois';

  @override
  String get settingsSectionUnits => 'Unidades';

  @override
  String get settingsUnitSystem => 'Sistema de unidades';

  @override
  String get settingsUnitImperial => 'Imperial (ft / lb)';

  @override
  String get settingsUnitMetric => 'Métrico (m / kg)';

  @override
  String get settingsUnitSquares => 'Quadrados (sq / kg)';

  @override
  String get settingsChooseUnitSystem => 'Escolher Sistema de Unidades';

  @override
  String get settingsSectionCharacterSheet => 'Ficha do personagem';

  @override
  String get settingsKeepScreenOnTitle => 'Manter tela ligada';

  @override
  String get settingsKeepScreenOnSubtitle =>
      'Impede que a tela apague enquanto você visualiza uma ficha de personagem.';

  @override
  String get settingsBackupSection => 'Backup';

  @override
  String get settingsBackupExportTitle => 'Exportar backup';

  @override
  String get settingsBackupExportSubtitle =>
      'Salva todos os personagens em um arquivo de backup.';

  @override
  String get settingsBackupExporting => 'Criando backup...';

  @override
  String get settingsBackupExportSuccess => 'Backup exportado.';

  @override
  String get settingsBackupExportError => 'Não foi possível exportar o backup.';

  @override
  String get settingsBackupImportTitle => 'Importar backup';

  @override
  String get settingsBackupImportSubtitle =>
      'Restaura personagens de um arquivo .dndbackup.';

  @override
  String get settingsBackupImporting => 'Importando backup...';

  @override
  String get settingsBackupImportError => 'Não foi possível importar o backup.';

  @override
  String settingsBackupImportSuccess(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count personagens importados do backup.',
      one: '1 personagem importado do backup.',
    );
    return '$_temp0';
  }

  @override
  String get settingsSectionApp => 'Aplicativo';

  @override
  String get settingsReviewTitle => 'Avaliar na Play Store';

  @override
  String get settingsReviewSubtitle =>
      'Abra a página do app para deixar uma avaliação ou comentário.';

  @override
  String get settingsReviewOpenError => 'Não foi possível abrir a Play Store.';

  @override
  String get settingsMaintenanceSection => 'Manutenção';

  @override
  String get settingsMaintenanceCheckTitle =>
      'Verificar atualizações de personagens';

  @override
  String get settingsMaintenanceCheckSubtitle =>
      'Procura correções de dados salvos.';

  @override
  String get settingsMaintenanceUpdateTitle => 'Atualizar personagens';

  @override
  String get settingsMaintenanceWorking => 'Verificando atualizações...';

  @override
  String get settingsMaintenanceNoUpdates =>
      'Todos os personagens já estão atualizados.';

  @override
  String get settingsMaintenanceError =>
      'Não foi possível atualizar os personagens.';

  @override
  String get settingsMaintenanceConfirmTitle => 'Atualizar personagens?';

  @override
  String get settingsMaintenanceCompleteTitle => 'Atualização concluída';

  @override
  String settingsMaintenanceUpdatesFound(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count personagens precisam de atualização.',
      one: '1 personagem precisa de atualização.',
    );
    return '$_temp0';
  }

  @override
  String settingsMaintenanceConfirmBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count personagens precisam de atualização. O app vai abrir um backup para você salvar ou compartilhar antes de aplicar as mudanças.',
      one:
          '1 personagem precisa de atualização. O app vai abrir um backup para você salvar ou compartilhar antes de aplicar as mudanças.',
    );
    return '$_temp0';
  }

  @override
  String get characterUpdateRequiredTitle =>
      'Atualização de personagem necessária';

  @override
  String get characterUpdateRequiredBody =>
      'Este personagem foi salvo em uma versão antiga dos dados. Atualize seus personagens nas Configurações antes de editar.';

  @override
  String get characterUpdateRequiredAction => 'Ir para atualizações';

  @override
  String settingsMaintenanceReportChecked(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count personagens verificados.',
      one: '1 personagem verificado.',
    );
    return '$_temp0';
  }

  @override
  String settingsMaintenanceReportUpdated(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count personagens atualizados.',
      one: '1 personagem atualizado.',
    );
    return '$_temp0';
  }

  @override
  String settingsMaintenanceReportDataChanged(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count personagens tiveram dados corrigidos.',
      one: '1 personagem teve dados corrigidos.',
    );
    return '$_temp0';
  }

  @override
  String get settingsMaintenanceReportVersionUpdated =>
      'Versão de dados atualizada.';

  @override
  String settingsMaintenanceChangeEquipmentWeights(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Peso de $count itens corrigido.',
      one: 'Peso de 1 item corrigido.',
    );
    return '$_temp0';
  }

  @override
  String settingsMaintenanceChangeEquipmentNormalized(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count itens de equipamento normalizados.',
      one: '1 item de equipamento normalizado.',
    );
    return '$_temp0';
  }

  @override
  String settingsMaintenanceChangeEquipmentPacksExpanded(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pacotes de equipamento expandidos.',
      one: '1 pacote de equipamento expandido.',
    );
    return '$_temp0';
  }

  @override
  String settingsMaintenanceChangeEquipmentOrder(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Ordem de $count itens do inventário normalizada.',
      one: 'Ordem de 1 item do inventário normalizada.',
    );
    return '$_temp0';
  }

  @override
  String get settingsMaintenanceChangeMulticlassStructure =>
      'Estrutura de classes preparada para multiclasse.';

  @override
  String get settingsMaintenanceChangeSpellSlots =>
      'Espaços de magia normais recalculados.';

  @override
  String get settingsMaintenanceChangePactMagicSlots =>
      'Espaços de Magia de Pacto separados.';

  @override
  String get settingsMaintenanceChangeArmorClass =>
      'Classe de Armadura recalculada.';

  @override
  String settingsMaintenanceChangeGeneric(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count alterações aplicadas.',
      one: '1 alteração aplicada.',
    );
    return '$_temp0';
  }

  @override
  String get incomingBackupPrompt => 'Importar backup do arquivo?';

  @override
  String incomingBackupSuccess(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count personagens importados do backup.',
      one: '1 personagem importado do backup.',
    );
    return '$_temp0';
  }
}
