// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get creationRulesetTitle => '选择规则版本';

  @override
  String get creationRuleset2014 => 'D&D 5e (2014)';

  @override
  String get creationRuleset2024 => 'D&D 5.5e (2024)';

  @override
  String get rulesetShort2014 => '5e';

  @override
  String get rulesetShort2024 => '5.5e';

  @override
  String get customBackgroundTitle => '自定义背景';

  @override
  String get customBackgroundSubtitle => '按规则创建你自己的背景';

  @override
  String get customBackgroundName => '背景名称';

  @override
  String get customBackgroundFeature => '背景特性';

  @override
  String customBackgroundSkills(int count) {
    return '选择$count项技能';
  }

  @override
  String customBackgroundTools2014(int count) {
    return '最多选择$count种工具，其余变为语言';
  }

  @override
  String customBackgroundLanguages(int count) {
    return '稍后选择的语言：$count';
  }

  @override
  String get customBackgroundEquipment2014 => '装备包';

  @override
  String customBackgroundAbilities(int count) {
    return '选择$count项属性用于提升';
  }

  @override
  String get customBackgroundTool2024 => '与其他熟练项一起选择一种任意类型的工具。';

  @override
  String customBackgroundGold2024(int gp) {
    return '装备：$gp金币可供花费';
  }

  @override
  String get customBackgroundSave => '使用此背景';

  @override
  String get wildShapeTitle => '荒野形态';

  @override
  String wildShapeUses(int current, int max) {
    return '使用次数：$current/$max';
  }

  @override
  String get wildShapeUsesUnlimited => '使用次数：无限';

  @override
  String wildShapeLimits(String cr) {
    return '形态最高挑战等级 $cr';
  }

  @override
  String get wildShapeNoFly => '无飞行速度';

  @override
  String get wildShapeNoSwim => '无游泳速度';

  @override
  String wildShapeChallengeRating(String cr) {
    return '挑战等级 $cr';
  }

  @override
  String wildShapeKnownForms(int count, int max) {
    return '已知形态：$count/$max';
  }

  @override
  String get wildShapeChooseForms => '请在“特性”标签页的荒野形态中选择你的已知形态。';

  @override
  String get wildShapeAssume => '变为一种形态';

  @override
  String get wildShapeLeave => '解除形态';

  @override
  String get wildShapeNoUsesLeft => '荒野形态没有剩余次数。休息可以恢复。';

  @override
  String get wildShapeSearch => '搜索野兽';

  @override
  String get wildShapeSeenNote => '选择一种你以前见过的野兽。';

  @override
  String wildShapeConfirmTitle(String name) {
    return '变为$name形态？';
  }

  @override
  String wildShapeConfirmUse(int current, int after, int max) {
    return '消耗1次荒野形态：$current → $after（共$max）。';
  }

  @override
  String get wildShapeConfirmUnlimited => '在你的等级，荒野形态没有次数限制。';

  @override
  String get wildShapeConfirmReplace => '这将替换你当前的形态。';

  @override
  String wildShapeConfirmFormHp(int amount) {
    return '该形态有$amount点生命值。降至0时你会恢复原形，多余的伤害由你承受。';
  }

  @override
  String wildShapeConfirmTempHp(int amount) {
    return '你获得$amount点临时生命值。';
  }

  @override
  String wildShapeConfirmTempHpKept(int current, int gain) {
    return '你保留现有的$current点临时生命值；形态给予的$gain点不会叠加。';
  }

  @override
  String wildShapeConfirmDuration(int hours) {
    String _temp0 = intl.Intl.pluralLogic(
      hours,
      locale: localeName,
      other: '$hours小时',
      one: '1小时',
    );
    return '最多持续$_temp0，或提前结束。';
  }

  @override
  String get wildShapeConfirmKeeps2024 =>
      '你保留生命值、生命骰、智力、感知、魅力、职业特性、语言、专长和熟练项。你无法施法，但专注会持续。';

  @override
  String get wildShapeConfirmKeeps2014 => '你保留智力、感知、魅力、阵营、个性和熟练项。你无法施法，但专注会持续。';

  @override
  String get wildShapeConfirm => '变为形态';

  @override
  String wildShapeActive(String name) {
    return '$name形态';
  }

  @override
  String wildShapeFormHp(int current, int max) {
    return '形态生命值 $current/$max';
  }

  @override
  String get wildShapeScoresNote => '力量、敏捷和体质来自形态；智力、感知和魅力是你自己的。';

  @override
  String get wildShapeAttacks => '形态攻击';

  @override
  String get wildShapeAttackRoll => '攻击检定';

  @override
  String get wildShapeStatBlock => '数据卡';

  @override
  String wildShapeLeaveTitle(String name) {
    return '解除$name形态？';
  }

  @override
  String get wildShapeLeaveBody2024 => '你恢复原形。已使用的荒野形态次数不会返还。';

  @override
  String get wildShapeLeaveBody2014 => '你以变身前的生命值恢复原形。形态剩余的生命值和荒野形态次数都会失去。';

  @override
  String get wildShapeDamageToForm => '伤害和治疗会先作用于你的荒野形态。';

  @override
  String get changesKindWildShapeForms => '荒野形态的已知形态';

  @override
  String get changesWildShapeEnds => '当前形态结束。';

  @override
  String get monsterSizeTiny => '微型';

  @override
  String get monsterSizeSmall => '小型';

  @override
  String get monsterSizeMedium => '中型';

  @override
  String get monsterSizeLarge => '大型';

  @override
  String get monsterSizeHuge => '巨型';

  @override
  String get monsterSizeGargantuan => '超巨型';

  @override
  String get monsterSizeOr => '或';

  @override
  String monsterSizeType(String size, String type) {
    return '$size$type';
  }

  @override
  String get monsterTypeBeast => '野兽';

  @override
  String monsterSwarmOfBeasts(String size) {
    return '野兽集群（个体$size）';
  }

  @override
  String get monsterSpeedBurrow => '掘穴';

  @override
  String get monsterSpeedClimb => '攀爬';

  @override
  String get monsterSpeedFly => '飞行';

  @override
  String get monsterSpeedSwim => '游泳';

  @override
  String get monsterSpeedHover => '（悬浮）';

  @override
  String monsterSpeedChoice(String first, String second, String distance) {
    return '$first或$second $distance（由DM选择）';
  }

  @override
  String get monsterSavingThrows => '豁免检定';

  @override
  String get monsterSkills => '技能';

  @override
  String get monsterVulnerabilities => '易伤';

  @override
  String get monsterResistances => '抗性';

  @override
  String get monsterImmunities => '免疫';

  @override
  String get monsterConditionImmunities => '状态免疫';

  @override
  String get monsterSenses => '感官';

  @override
  String get monsterSenseBlindsight => '盲视';

  @override
  String get monsterSenseDarkvision => '黑暗视觉';

  @override
  String get monsterSenseTremorsense => '震颤感知';

  @override
  String get monsterSenseTruesight => '真实视觉';

  @override
  String get monsterLanguages => '语言';

  @override
  String get monsterLanguagesNone => '无';

  @override
  String get monsterChallenge => '挑战等级';

  @override
  String monsterChallengeValue(String cr, String xp, int pb) {
    return '$cr（经验值 $xp；熟练加值 +$pb）';
  }

  @override
  String get monsterTraits => '特性';

  @override
  String get monsterActions => '动作';

  @override
  String get monsterBonusActions => '附赠动作';

  @override
  String get monsterReactions => '反应';

  @override
  String get monsterLegendaryActions => '传奇动作';

  @override
  String monsterRecharge(int min) {
    return '充能 $min–6';
  }

  @override
  String monsterPerDay(int uses) {
    return '每日$uses次';
  }

  @override
  String get creation2024Species => '物种';

  @override
  String get creation2024Size => '体型';

  @override
  String get creation2024SizeSmall => '小型';

  @override
  String get creation2024SizeMedium => '中型';

  @override
  String get creation2024OriginFeat => '起源专长';

  @override
  String get creation2024StandardArray => '将15、14、13、12、10和8各分配一次。';

  @override
  String get creation2024OriginBonuses => '背景属性提升';

  @override
  String get creation2024BonusTwoOne => '+2和+1';

  @override
  String get creation2024BonusThree => '三项各+1';

  @override
  String get creation2024Languages => '除通用语外选择两种语言';

  @override
  String get creation2024ClassEquipment => '职业装备';

  @override
  String get creation2024BackgroundEquipment => '背景装备';

  @override
  String get creation2024SpecificTool => '选择一种工具';

  @override
  String get creation2024PrepareSpells => '从法术书中准备四个法术';

  @override
  String get character2024ReadOnlyNotice =>
      '2024版角色卡仍在整合中。目前可以查看角色卡，并使用笔记、头像和基础掷骰功能。';

  @override
  String get appTitle => 'DnD 角色工具';

  @override
  String get charListTitle => '龙与地下城角色';

  @override
  String get charListImportTooltip => '导入角色或备份';

  @override
  String get charListSettingsTooltip => '设置';

  @override
  String get charListNewCharacter => '新角色';

  @override
  String get charListEmpty => '还没有角色';

  @override
  String get charListEmptyHint => '点击+创建你的第一个角色';

  @override
  String get whatsNewTitle => '新功能';

  @override
  String whatsNewVersionSubtitle(String version) {
    return '版本 $version';
  }

  @override
  String get whatsNewIntro => '一些实用改进已经准备好用于你的下一场游戏。';

  @override
  String get whatsNewContextualRollsTitle => '情境掷骰';

  @override
  String get whatsNewContextualRollsBody => '可直接从角色卡掷属性、技能、豁免、武器和简单法术。';

  @override
  String get whatsNewCriticalsTitle => '重击选项';

  @override
  String get whatsNewCriticalsBody => '选择重击伤害的计算方式，并在需要时使用优势和劣势选项。';

  @override
  String get whatsNewConfirmationsTitle => '更清晰的确认';

  @override
  String get whatsNewConfirmationsBody => '安全操作和破坏性操作现在更容易区分。';

  @override
  String get whatsNewDone => '知道了';

  @override
  String get whatsNewSummary =>
      '现已支持土耳其语，SRD 5.1 魔法物品目录更加丰富，角色更新流程也更加清晰。D&D 2024 支持功能仍在开发中。';

  @override
  String get whatsNewTurkishTitle => '现已支持土耳其语';

  @override
  String get whatsNewTurkishBody => '应用界面和 SRD 5.1 游戏内容现已提供土耳其语版本。';

  @override
  String get whatsNewMagicItemsTitle => '更多魔法物品';

  @override
  String get whatsNewMagicItemsBody => '探索更多 SRD 5.1 魔法物品。我们还补齐了支持语言中此前缺失的翻译。';

  @override
  String get whatsNewCharacterUpdatesTitle => '更清晰的角色更新流程';

  @override
  String get whatsNewCharacterUpdatesBody =>
      '如果角色需要更新，你可以先备份角色、更新所有角色，或取消操作。更新完成前，该角色卡不会打开。';

  @override
  String get whatsNew2024Title => 'D&D 2024 正在开发中';

  @override
  String get whatsNew2024Body =>
      '我们正在开发独立的 2024 规则模式，包含更新后的职业、子职业、物种、法术、装备和魔法物品，同时保留对 2014 规则角色的支持。我们计划提供可选的引导式转换；目前还不能创建或转换 2024 规则角色。';

  @override
  String get whatsNewSettingsSubtitle => '再次阅读最新公告。';

  @override
  String get creditsTitle => '致谢与许可';

  @override
  String get creditsSettingsSubtitle => 'SRD 5.1 与 SRD 5.2.1 声明';

  @override
  String get creditsIntro =>
      '规则和游戏内容来自 Wizards of the Coast 发布的 System Reference Documents。其许可要求展示以下声明，并保留英文原文。';

  @override
  String get creditsEdition2014 => 'D&D 5e（2014）';

  @override
  String get creditsEdition2024 => 'D&D 5.5e（2024）';

  @override
  String creditsLicense(String license) {
    return '许可：$license';
  }

  @override
  String get creditsSource => '官方来源';

  @override
  String get creditsUnavailable => '无法加载此声明。';

  @override
  String get creditsNotAffiliated =>
      '本应用与 Wizards of the Coast LLC 无关联，也未获得其认可、赞助或特别批准。';

  @override
  String get creditsCopyright => '© 2026 Pedro Frugoli。保留所有权利。';

  @override
  String get whatsNewThanks => '感谢你使用本应用并分享反馈。你的建议将帮助我们决定接下来做什么。';

  @override
  String get whatsNew3Summary =>
      'D&D 2024（5.5e）来了：在2014角色之外，用SRD 5.2.1规则创建并培养角色。';

  @override
  String get whatsNew3RulesTitle => 'D&D 2024规则';

  @override
  String get whatsNew3RulesBody =>
      '创建角色时可选择D&D 5e（2014）或5.5e（2024）。2024角色可从1级成长到20级，包含子职业、专长、史诗恩赐、兼职和武器精通。';

  @override
  String get whatsNew3RestsTitle => '休息与状态';

  @override
  String get whatsNew3RestsBody =>
      '2024规则中，长休恢复所有生命骰并降低一级力竭；力竭影响d20检定和速度；短休可使用Arcane Recovery等能力。';

  @override
  String get whatsNew3ResetTitle => '更安全的等级重置';

  @override
  String get whatsNew3ResetBody =>
      '保存前会列出每一项更改。重置会撤销被移除职业所给予的内容，两种规则都可以重建回之前的等级。';

  @override
  String get whatsNew3UpdateTitle => '一次性角色更新';

  @override
  String get whatsNew3UpdateBody =>
      '打开角色时，应用会请求更新所有角色并先打开备份。2014角色保留其规则和数据；2024角色会保存用于升级和重置的等级记录。';

  @override
  String charListImportedSuccess(String name) {
    return '$name导入成功！';
  }

  @override
  String charListDuplicatedSuccess(String name) {
    return '$name复制成功！';
  }

  @override
  String get charListImportError => '导入时出现意外错误。请再试一次。';

  @override
  String get charListDuplicateError => '无法复制角色。请再试一次。';

  @override
  String get importErrorInvalidJson => '粘贴的JSON无效。';

  @override
  String get importFieldLockedHint => '清除另一个字段才能使用此字段。';

  @override
  String get importErrorNotObject => '格式无效：需要 JSON 对象。';

  @override
  String get importErrorMissingCharacter => 'JSON 无效：未找到 \"character\" 字段。';

  @override
  String get importErrorCorruptedCharacter => '无法读取角色。JSON 可能不完整或来自不兼容的版本。';

  @override
  String charCardLevel(int level) {
    return '等级 $level';
  }

  @override
  String get charCardPin => '固定到顶部';

  @override
  String get charCardUnpin => '取消固定';

  @override
  String get charCardChangePhoto => '更改照片';

  @override
  String get charCardRename => '重命名';

  @override
  String get charCardDuplicate => '复制';

  @override
  String get charCardExport => '出口';

  @override
  String get charCardDelete => '删除';

  @override
  String charDuplicateName(String name) {
    return '$name（副本）';
  }

  @override
  String charDuplicateNameNumbered(String name, int number) {
    return '$name（副本 $number）';
  }

  @override
  String get renameDialogTitle => '重命名角色';

  @override
  String get renameDialogLabel => '姓名';

  @override
  String get dialogCancel => '取消';

  @override
  String get dialogSave => '节省';

  @override
  String get deleteDialogTitle => '删除角色？';

  @override
  String deleteDialogContent(String name) {
    return '您确定要删除 $name 吗？此操作无法撤消。';
  }

  @override
  String get dialogConfirm => '确认';

  @override
  String get dialogDiscard => '丢弃';

  @override
  String get dialogContinue => '继续';

  @override
  String get dialogKeepEditing => '继续编辑';

  @override
  String get dialogRemove => '消除';

  @override
  String get dialogAdd => '添加';

  @override
  String get dialogDone => '完成';

  @override
  String get settingsTitle => '设置';

  @override
  String get settingsSectionTheme => '视觉主题';

  @override
  String get settingsDark => '黑暗的';

  @override
  String get settingsLight => '光';

  @override
  String get settingsChooseTheme => '选择一个主题';

  @override
  String get settingsSectionLanguage => '语言';

  @override
  String get settingsAppLanguage => '应用语言';

  @override
  String get settingsChooseLanguage => '选择语言';

  @override
  String get settingsSystemDefault => '系统默认';

  @override
  String get modeSelectionTitle => '新角色';

  @override
  String get modeSelectionQuestion => '你想如何塑造你的角色？';

  @override
  String get modeGuidedTitle => '引导';

  @override
  String get modeGuidedSubtitle => '分步向导。一次选择一个职业、种族、背景、技能和属性。推荐给新玩家。';

  @override
  String get modeManualTitle => '手动的';

  @override
  String get modeManualSubtitle => '一切都自己填写。所有字段都是免费的，不会为您计算任何值。最适合有经验的玩家。';

  @override
  String get modeRandomTitle => '随机的';

  @override
  String get modeRandomSubtitle => '一切都为你准备好了——种族、阶级、背景和属性。非常适合挑战或一次性。';

  @override
  String get modeSemiRandomTitle => '半随机';

  @override
  String get modeSemiRandomSubtitle => '你做出重要的选择；其他一切都已滚动。适合当您有一个概念但想要惊喜时。';

  @override
  String get modeComingSoon => '很快';

  @override
  String get creationStepClass => '班级';

  @override
  String get creationStepRace => '种族';

  @override
  String get creationStepBackground => '背景';

  @override
  String get creationStepSkills => '技能';

  @override
  String get creationStepAttributes => '属性';

  @override
  String get creationStepName => '姓名';

  @override
  String get creationStepReview => '审查';

  @override
  String get creationDiscardTitle => '丢弃角色？';

  @override
  String get creationDiscardContent => '所有进展都将丢失。你确定吗？';

  @override
  String get creationTooltipCancel => '取消';

  @override
  String get creationBack => '后退';

  @override
  String get creationCreateCharacter => '创建角色';

  @override
  String get detailLeaveWithoutSaving => '不保存就离开？';

  @override
  String get detailChangesWillBeDiscarded => '更改将被丢弃。要保存，请使用右上角的 ✓ 按钮。';

  @override
  String get detailLeaveAndDiscard => '留下并丢弃';

  @override
  String detailErrorLoading(String error) {
    return '加载字符时出错：$error';
  }

  @override
  String get detailTooltipLongRest => '长时间休息';

  @override
  String get characterActionRollDice => '掷骰';

  @override
  String get characterActionResetLevels => '重置等级';

  @override
  String get diceExpressionLabel => '表达式';

  @override
  String get diceExpressionHint => '示例：1d20+5 或 4d6dl1';

  @override
  String get diceExpressionHelpTooltip => '骰子表达式说明';

  @override
  String get diceExpressionHelpTitle => '骰子表达式';

  @override
  String get diceExpressionHelpBody =>
      '使用 XdY 掷骰：2d6 表示掷两个六面骰。\n可以加减调整值：1d20+5 或 2d6 - 1。\n使用 d% 或 d100 表示百分骰。\nd20 的优势/劣势：2d20kh1 保留较高值，2d20kl1 保留较低值。\n使用 kh、kl、dh 或 dl 保留/丢弃骰子。示例：4d6dl1 掷四个 d6 并丢弃最低值。\n空格可选：2d6+1d8 和 2d6 + 1d8 都可以使用。';

  @override
  String get diceQuantityLabel => '数量';

  @override
  String get diceModifierLabel => '调整值';

  @override
  String get diceRollButton => '掷骰';

  @override
  String get diceRerollButton => '再次掷骰';

  @override
  String get diceModeNormal => '普通';

  @override
  String get diceModeAdvantage => '优势';

  @override
  String get diceModeDisadvantage => '劣势';

  @override
  String get diceResultTitle => '结果';

  @override
  String get diceHistoryTitle => '最近掷骰';

  @override
  String get diceNoRollsYet => '还没有掷骰。';

  @override
  String get diceNaturalOne => '自然 1';

  @override
  String get diceNaturalTwenty => '自然 20';

  @override
  String get contextualRollCriticalApplied => '已应用重击';

  @override
  String get contextualRollVersatileGrip => '武器握持';

  @override
  String get contextualRollVersatileOneHanded => '单手';

  @override
  String get contextualRollVersatileTwoHanded => '双手';

  @override
  String diceInvalidExpression(String message) {
    return '无效的骰子表达式：$message';
  }

  @override
  String get detailTooltipCancelEdit => '取消编辑';

  @override
  String get detailTooltipDoneEditing => '编辑完成';

  @override
  String get detailTooltipEditCharacter => '编辑角色';

  @override
  String get detailCancelEditTitle => '取消编辑？';

  @override
  String get detailCancelEditContent => '所有更改都将被丢弃。';

  @override
  String get detailFinishEditTitle => '完成编辑吗？';

  @override
  String get detailFinishEditContent => '更改将被保存。';

  @override
  String get detailTabIdentity => '身份';

  @override
  String get detailEditButton => '编辑';

  @override
  String get skillsEditHint => '长按切换: 无 → 熟练 → 专精';

  @override
  String get skillsOrganizeTooltip => '整理';

  @override
  String get skillsDisplayTitle => '技能显示';

  @override
  String get skillsDisplayModeLabel => '布局';

  @override
  String get skillsDisplayByAbility => '按属性';

  @override
  String get skillsDisplayProficiencyFirst => '熟练优先';

  @override
  String get skillsDisplayAlphabetical => '按字母顺序';

  @override
  String get skillsDisplayAbilityOrder => '属性顺序';

  @override
  String get skillsDisplayProficientFirstInsideGroups => '组内熟练优先';

  @override
  String get skillsDisplayRestoreDefault => '恢复默认';

  @override
  String get skillsDisplayProficientSection => '熟练';

  @override
  String get skillsDisplayOtherSection => '其他技能';

  @override
  String get skillsDisplayAllSection => '全部技能';

  @override
  String get detailTabStats => '统计数据';

  @override
  String get detailTabSkills => '技能';

  @override
  String get detailTabFeatures => '特征';

  @override
  String get detailTabSpells => '法术';

  @override
  String get detailTabInventory => '存货';

  @override
  String get detailTabNotes => '笔记';

  @override
  String get longRestTitle => '长时间休息';

  @override
  String get longRestContent => '将HP恢复到最大并恢复所有法术位？';

  @override
  String get longRestButton => '休息';

  @override
  String get restPickerTitle => '休息';

  @override
  String get restPickerShort => '短休息';

  @override
  String get restPickerShortCaption => '花费生命骰恢复HP';

  @override
  String get restPickerLong => '长休息';

  @override
  String get restPickerLongCaption => '恢复全部HP和法术位';

  @override
  String get shortRestTitle => '短休息';

  @override
  String get shortRestAvailableDice => '可用生命骰';

  @override
  String get shortRestSpend => '花费';

  @override
  String get shortRestRolled => '恢复的HP';

  @override
  String get shortRestRollButton => '投掷';

  @override
  String get shortRestButton => '休息';

  @override
  String get shortRestNoDice => '没有剩余生命骰';

  @override
  String get shortRestRecoveryTitle => '恢复能力';

  @override
  String shortRestRecoverySlotsHint(int levels) {
    return '恢复已消耗的法术位，总环阶不超过$levels环（不能高于5环）。';
  }

  @override
  String shortRestRecoveryPointsHint(int points) {
    return '最多恢复$points点。';
  }

  @override
  String get exhaustionLevelTitle => '力竭等级';

  @override
  String exhaustionEffects(String penalty, String distance) {
    return 'd20检定$penalty · 速度 −$distance';
  }

  @override
  String get exhaustionLethal => '达到6级时，角色死亡。';

  @override
  String rollExhaustionApplied(String modifier) {
    return '已对d20应用力竭$modifier。';
  }

  @override
  String levelUp2024AsiHint(int max) {
    return '一项属性+2，或两项属性各+1（上限$max）。';
  }

  @override
  String levelUp2024AbilityHint(int increase, int max) {
    return '一项属性+$increase（上限$max）。';
  }

  @override
  String levelUp2024SpellLimits(
    String className,
    int cantrips,
    int prepared,
    int level,
  ) {
    return '$className：$cantrips个戏法，$prepared个已准备法术，最高$level环。请在法术标签页中选择。';
  }

  @override
  String resetLevels2024Body(String className) {
    return '回到1级？接下来你可以保留$className或选择其他职业。来自职业的等级、子职业、专长、选择和法术将根据已保存的等级记录撤销。出身、手动属性修改、物品、笔记和背景故事会保留。';
  }

  @override
  String spells2024Cantrips(int count, int max) {
    return '戏法：$count / $max';
  }

  @override
  String spells2024Spellbook(int count, int max) {
    return '法术书：$count / $max';
  }

  @override
  String get spells2024ChooseClass => '选择此法术所属的职业';

  @override
  String get featureChoicesChooseTarget => '选择目标';

  @override
  String get featureChoicesNoTargets => '暂时没有可选目标。';

  @override
  String get levelUp2024SwapTitle => '替换法术（可选）';

  @override
  String get levelUp2024SwapCantrip => '要替换的戏法';

  @override
  String get levelUp2024SwapSpell => '要替换的已准备法术';

  @override
  String get levelUp2024SwapLearn => '替换为';

  @override
  String get resetLevels2024ClassTitle => '1级职业';

  @override
  String get changesReviewTitle => '检查更改';

  @override
  String get changesReviewIntro => '保存后将更改：';

  @override
  String get changesReviewNone => '不会有任何更改。';

  @override
  String get changesReviewApply => '保存更改';

  @override
  String get changesKindClasses => '职业';

  @override
  String get changesKindExpertise => '专精';

  @override
  String get changesKindProficiencies => '熟练项';

  @override
  String get changesKindExperience => '经验值';

  @override
  String get changesAdded => '新增';

  @override
  String get changesRemoved => '移除';

  @override
  String get changesKeptTitle => '保持不变';

  @override
  String get resetLimitAbilityIncreases => '此角色卡没有完整的等级记录，之前等级获得的属性提升会保留。';

  @override
  String get resetLimitClassSkills => '此角色卡没有记录哪些技能来自职业，因此会保留。';

  @override
  String get concentrationBannerLabel => '正在专注于：';

  @override
  String get concentrationBreakButton => '结束';

  @override
  String get concentrationReplaceTitle => '更换专注？';

  @override
  String concentrationReplaceBody(String current, String next) {
    return '您正在专注于$current。施放$next将终止专注。';
  }

  @override
  String get concentrationReplaceConfirm => '更换';

  @override
  String get concentrationTooltip => '设置专注';

  @override
  String get sectionIdentity => '身份';

  @override
  String get sectionHitPoints => '生命值';

  @override
  String get sectionCombat => '战斗';

  @override
  String get sectionProgression => '进度';

  @override
  String get sectionAbilityScores => '能力分数';

  @override
  String get sectionSavingThrows => '豁免熟练项';

  @override
  String get labelName => '姓名';

  @override
  String get labelBackground => '背景';

  @override
  String get labelChange => '改变';

  @override
  String get labelAlignment => '结盟';

  @override
  String get labelPlayer => '玩家';

  @override
  String get labelLevel => '等级';

  @override
  String get tooltipLevelUp => '升级';

  @override
  String get levelUpTitle => '升级';

  @override
  String get levelUpStepClassTarget => '选择要升级的职业';

  @override
  String get levelUpClassTargetExisting => '当前职业';

  @override
  String get levelUpClassTargetAddClass => '添加新职业';

  @override
  String levelUpClassTargetCurrentLevel(int level) {
    return '当前等级 $level';
  }

  @override
  String levelUpClassTargetNextClassLevel(int level) {
    return '职业等级 $level';
  }

  @override
  String levelUpClassTargetRequirement(String requirement) {
    return '需要 $requirement';
  }

  @override
  String levelUpClassTargetRequirementMissing(String requirement) {
    return '缺少条件：$requirement';
  }

  @override
  String get levelUpClassTargetCurrentRequirementsMissing => '你的当前职业不满足兼职条件。';

  @override
  String get levelUpConfirm => '确认升级';

  @override
  String get levelUpCancel => '取消';

  @override
  String get levelUpStepFeatures => '新职业特性';

  @override
  String levelUpStepSubclass(String feature) {
    return '选择$feature';
  }

  @override
  String get levelUpStepAsi => '属性值提升';

  @override
  String get levelUpStepHp => '生命值';

  @override
  String get levelUpStepCantrips => '新戏法';

  @override
  String get levelUpStepSpells => '新法术';

  @override
  String get levelUpStepSummary => '总结';

  @override
  String get levelUpNoNewFeatures => '此等级没有新的职业特性。';

  @override
  String get featureChoicesTitle => '特性选择';

  @override
  String get featureChoicesPending => '待选择';

  @override
  String get featureChoicesEdit => '编辑选择';

  @override
  String get featureChoicesChooseDependencyFirst => '请先选择所需的前置选项。';

  @override
  String featureChoicesChooseCount(String kind, int count) {
    return '选择 $count 个$kind。';
  }

  @override
  String featureChoicesSelectedCount(int selected, int count) {
    return '已选择 $selected/$count';
  }

  @override
  String get levelUpHpRoll => '掷骰';

  @override
  String get levelUpHpAverage => '平均值';

  @override
  String levelUpHpGained(int n) {
    return '+$n HP';
  }

  @override
  String levelUpHpFormula(int die, String mod) {
    return 'd$die + 体质 ($mod)';
  }

  @override
  String get levelUpAsiOption => '属性值提升';

  @override
  String get levelUpFeatOption => '选择专长';

  @override
  String levelUpAsiPointsLeft(int n) {
    return '剩余$n点';
  }

  @override
  String levelUpSpellsToLearn(int n) {
    return '选择$n个法术';
  }

  @override
  String get levelUpSpellRestrictedSection => '指定学派';

  @override
  String get levelUpSpellFreeSection => '自由选择';

  @override
  String levelUpSpellRestrictedInstruction(int count, String schools) {
    return '需选择 $count 个法术。可选学派：$schools。';
  }

  @override
  String levelUpSpellFreeInstruction(int count) {
    return '需选择 $count 个法术，可从任意学派选择。';
  }

  @override
  String get levelUpSpellFreeLocked => '请先完成指定学派的法术选择。';

  @override
  String levelUpCantripsToLearn(int n) {
    return '选择$n个戏法';
  }

  @override
  String get levelUpSpellSwap => '替换已知法术（可选）';

  @override
  String levelUpSpellSwapCurrent(String name) {
    return '当前：$name';
  }

  @override
  String levelUpSummaryLevel(int level) {
    return '→ $level级';
  }

  @override
  String levelUpSummaryClassLevel(String className, int level) {
    return '$className $level级';
  }

  @override
  String levelUpSummaryHp(int n) {
    return '最大HP +$n';
  }

  @override
  String levelUpSummaryAsi(String changes) {
    return '属性提升: $changes';
  }

  @override
  String levelUpSummaryFeat(String name) {
    return '专长: $name';
  }

  @override
  String levelUpSummarySubclass(String name) {
    return '子职业: $name';
  }

  @override
  String levelUpSummarySpellsLearned(int count) {
    return '学会法术: $count';
  }

  @override
  String levelUpSummaryCantripsLearned(int count) {
    return '学会戏法: $count';
  }

  @override
  String levelUpSubclassAlreadyHas(String name) {
    return '当前子职业: $name';
  }

  @override
  String get levelUpMaxLevel => '已达到最高等级（20）。';

  @override
  String get levelUpHpReroll => '重掷 / 更改';

  @override
  String get levelUpSpellSwapPickReplacement => '现在选择一个替换法术';

  @override
  String get levelUpSpellSwapReplaceWith => '替换为';

  @override
  String get levelUpSpellSwapNone => '无';

  @override
  String get levelUpSpellAlreadyKnown => '已知晓';

  @override
  String levelUpSpellCantripSubtitle(String school) {
    return '$school（戏法）';
  }

  @override
  String levelUpSpellSubtitle(int level, String school) {
    return '$level环 $school';
  }

  @override
  String get resetLevelsTitle => '重置等级';

  @override
  String get resetLevelsConfirmBody =>
      '这会把职业成长重置为1级。笔记、物品、容器、货币、图片、背景故事、外貌、种族和背景会保留。\n\n职业等级、职业法术、职业与子职业选择及其带来的内容、成长资源和等级专长会被移除。如果角色卡有完整的等级记录，等级带来的属性提升也会撤销。保存之前你会检查每一项更改。';

  @override
  String resetLevelsCountdown(int seconds) {
    return '等待 $seconds 秒';
  }

  @override
  String get resetLevelsIntro => '选择新的 1 级职业数据。只有按下最后的按钮后才会保存重置。';

  @override
  String get resetLevelsSubclassRequired => '该职业在 1 级选择子职业。';

  @override
  String resetLevelsInitialHp(int hp) {
    return '初始 HP：$hp';
  }

  @override
  String resetLevelsSelectSkills(int count) {
    return '选择 $count 个职业技能。';
  }

  @override
  String get resetLevelsFixedTools => '自动获得：';

  @override
  String resetLevelsSelectTools(int count) {
    return '选择 $count 个工具熟练项。';
  }

  @override
  String get resetLevelsApply => '重置到 1 级';

  @override
  String resetLevelsApplyAndRebuild(int level) {
    return '重置并重建到 $level 级';
  }

  @override
  String get resetLevelsIncomplete => '完成必选项';

  @override
  String get resetLevelsApplied => '等级已重置。';

  @override
  String resetLevelsRebuildTitle(int level) {
    return '重建到 $level 级';
  }

  @override
  String resetLevelsRebuildSubtitle(int level) {
    return '选择 1 级后，应用会打开升级步骤直到 $level 级。如果中途取消，不会保存任何更改。';
  }

  @override
  String resetLevelsRebuildStep(int level, int targetLevel) {
    return '正在重建 $level/$targetLevel 级';
  }

  @override
  String get resetLevelsRebuildCancelled => '重置已取消。没有保存任何更改。';

  @override
  String resetLevelsRebuiltApplied(int level) {
    return '等级已重置并重建到 $level 级。';
  }

  @override
  String get labelSubclass => '子类';

  @override
  String get labelLanguages => '语言';

  @override
  String get hintAddLanguage => '添加语言...';

  @override
  String get labelChoose => '选择';

  @override
  String get sectionAppearance => '外貌';

  @override
  String get labelAge => '年龄';

  @override
  String get labelHeight => '身高';

  @override
  String get labelWeight => '体重';

  @override
  String get labelEyes => '眼睛';

  @override
  String get labelSkin => '肤色';

  @override
  String get labelHair => '发色';

  @override
  String get labelMaxHP => '最大生命值';

  @override
  String get labelTempHP => '温度HP';

  @override
  String get labelAmount => '数量';

  @override
  String get labelSpeed => '速度（英尺）';

  @override
  String get detailDamage => '损害';

  @override
  String get detailHeal => '愈合';

  @override
  String get detailNone => '没有任何';

  @override
  String get tempHpDialogTitle => '添加临时HP';

  @override
  String get tempHpDialogTitleReplace => '临时生命值';

  @override
  String tempHpCurrent(int n) {
    return '当前：+ $n 温度 HP';
  }

  @override
  String get tempHpNoStack => '临时 HP 不会叠加——只有更高的值会取代当前的值。';

  @override
  String get tempHpReplace => '代替';

  @override
  String statsTempHpChip(int n) {
    return '+$n临时HP';
  }

  @override
  String subclassConfirmTitle(String feature) {
    return '确认$feature';
  }

  @override
  String subclassChooseTitle(String feature) {
    return '选择$feature';
  }

  @override
  String subclassConfirmBody(int level, String feature) {
    return '您已达到 $level 级别。确认或更改您的 $feature 。';
  }

  @override
  String subclassChooseBody(int level, String feature) {
    return '您已达到 $level 级别！选择您的 $feature 。';
  }

  @override
  String get subclassKeepCurrent => '保持最新状态';

  @override
  String get subclassChangeTitle => '改变子类';

  @override
  String get subclassChangeWarning => '警告：先前子类别授予的法术和熟练程度不会自动删除。您需要手动调整它们。';

  @override
  String get backgroundChooseTitle => '选择背景';

  @override
  String get featuresTooltipAdd => '添加功能';

  @override
  String get featuresTooltipRemove => '消除';

  @override
  String get featuresTooltipEnable => '启用';

  @override
  String get featuresTooltipDisable => '禁用';

  @override
  String get featuresTabFeats => '专长';

  @override
  String featPrerequisite(String req) {
    return '先决条件: $req';
  }

  @override
  String get featuresSectionFeats => '专长';

  @override
  String get featuresTabClass => '职业';

  @override
  String get featuresTabRacial => '种族';

  @override
  String get featuresTabCustom => '自定义';

  @override
  String get featuresTabTools => '工具';

  @override
  String get featuresRemoveTitle => '删除功能？';

  @override
  String featuresRemoveContent(String name) {
    return '“ $name ”将被删除。';
  }

  @override
  String get featuresNoneAvailable => '没有可用的功能。';

  @override
  String get featuresAddLabel => '添加功能';

  @override
  String get featuresLoadError => '加载功能时出错。';

  @override
  String get hintSearch => '搜索...';

  @override
  String get labelFeatureName => '姓名';

  @override
  String get labelFeatureDescription => '说明（可选）';

  @override
  String get labelFeatureType => '类型：';

  @override
  String get labelPassive => '被动的';

  @override
  String get labelActive => '积极的';

  @override
  String get spellsTooltipAdd => '添加咒语';

  @override
  String get spellsRemoveTitle => '解除咒语？';

  @override
  String spellsRemoveContent(String name) {
    return '从你的法术列表中删除“ $name ”？';
  }

  @override
  String get spellsAtWill => '随意';

  @override
  String get notesTooltipAdd => '添加备注';

  @override
  String get notesTooltipEdit => '编辑备注';

  @override
  String get notesTooltipDelete => '删除注释';

  @override
  String get notesEmptyTitle => '暂无笔记';

  @override
  String get notesEmptyHint => '点击 + 创建您的第一条笔记。';

  @override
  String get notesUntitled => '无标题';

  @override
  String get notesDeleteTitle => '删除注释？';

  @override
  String notesDeleteContentNamed(String title) {
    return '“ $title ”将被永久删除。';
  }

  @override
  String get notesDeleteContent => '此注释将被永久删除。';

  @override
  String get notesLabelTitle => '标题';

  @override
  String get notesLabelContent => '内容';

  @override
  String get notesSearchHint => '搜索笔记或标签';

  @override
  String get notesNoResultsTitle => '没有匹配的笔记';

  @override
  String get notesNoResultsHint => '尝试其他搜索或清除标签筛选。';

  @override
  String get notesReadMore => '阅读更多';

  @override
  String get notesTags => '标签';

  @override
  String get notesAllTags => '全部';

  @override
  String get notesCustomTag => '自定义标签';

  @override
  String get notesAddTag => '添加标签';

  @override
  String get notesTagColor => '标签颜色';

  @override
  String get notesChooseTagColor => '选择标签颜色';

  @override
  String get notesTooltipPin => '固定笔记';

  @override
  String get notesTooltipUnpin => '取消固定';

  @override
  String get notesMoveUp => '上移';

  @override
  String get notesMoveDown => '下移';

  @override
  String get notesMoreActions => '更多操作';

  @override
  String get notesPinnedSection => '已固定';

  @override
  String get notesOtherSection => '笔记';

  @override
  String get notesDefaultTagSession => '会话';

  @override
  String get notesDefaultTagNpc => 'NPC';

  @override
  String get notesDefaultTagQuest => '任务';

  @override
  String get notesDefaultTagPlace => '地点';

  @override
  String get notesDefaultTagLoot => '战利品';

  @override
  String get notesDefaultTagRule => '规则';

  @override
  String get sectionPersonalityTraits => '性格特征';

  @override
  String get sectionPersonality => '个性';

  @override
  String get sectionIdeals => '理想';

  @override
  String get sectionBonds => '债券';

  @override
  String get sectionFlaws => '缺陷';

  @override
  String get sectionBackstory => '背景故事';

  @override
  String inventoryEquippedSection(int count, int ac) {
    return '装备 ( $count ) · AC $ac';
  }

  @override
  String get inventoryTooltipAdd => '添加项目';

  @override
  String get inventoryTooltipRemove => '消除';

  @override
  String get inventoryTooltipMove => '移动';

  @override
  String inventoryMoveTitle(String name) {
    return '移动 $name';
  }

  @override
  String get inventoryMoveToInventory => '库存';

  @override
  String inventoryContainersSection(int count) {
    return '容器 ($count)';
  }

  @override
  String inventoryContainerContents(int count) {
    return '$count 个物品';
  }

  @override
  String get inventoryContainerEmpty => '空';

  @override
  String get inventoryRemoveTitle => '删除项目？';

  @override
  String inventoryRemoveContent(String name) {
    return '从库存中移除 $name？';
  }

  @override
  String inventoryRemovePartial(int count, int total) {
    return '将删除： $count 或 $total';
  }

  @override
  String get inventoryRemoveContainerTitle => '移除容器？';

  @override
  String inventoryRemoveContainerContent(String name, int count) {
    return '$name 中有 $count 个物品。要如何处理？';
  }

  @override
  String get inventoryRemoveContainerMoveContents => '将物品移回库存';

  @override
  String get inventoryRemoveContainerDeleteContents => '全部移除';

  @override
  String get inventoryLabelQuantity => '数量：';

  @override
  String get inventoryLabelQuantityToRemove => '移除数量';

  @override
  String get inventoryAddCustomItem => '添加自定义项目';

  @override
  String get inventoryAddItem => '添加项目';

  @override
  String get inventoryLabelItemName => '姓名 *';

  @override
  String get inventoryLabelType => '类型';

  @override
  String get inventoryLabelCategory => '类别';

  @override
  String get inventoryLabelItemQuantity => '数量';

  @override
  String get inventoryLabelWeight => '重量';

  @override
  String get weightCarried => '携带中';

  @override
  String get weightCapacity => '承载量';

  @override
  String get weightEncumbered => '负重';

  @override
  String get weightHeavilyEncumbered => '严重负重';

  @override
  String get weightEnableTooltip => '启用重量跟踪';

  @override
  String get weightDisableTooltip => '禁用重量跟踪';

  @override
  String get inventoryLabelDescription => '说明（可选）';

  @override
  String get inventoryTypeWeapon => '武器';

  @override
  String get inventoryTypeArmor => '盔甲';

  @override
  String get inventoryTypeConsumable => '消耗品';

  @override
  String get inventoryTypeGear => '装备';

  @override
  String get inventoryTypeEquippable => '可装备';

  @override
  String get inventoryTypeContainer => '容器';

  @override
  String get inventoryAddItemError => '无法添加物品。';

  @override
  String inventoryLoadItemsError(String error) {
    return '加载物品时出错:\n$error';
  }

  @override
  String inventoryNoResults(String query) {
    return '没有“$query”的结果';
  }

  @override
  String get inventoryTooltipEquip => '装备';

  @override
  String get inventoryTooltipUnequip => '卸下';

  @override
  String get inventoryCustomDamageDice => '伤害（例如 1d8）';

  @override
  String get inventoryCustomDamageType => '伤害类型';

  @override
  String get inventoryCustomWeaponProperties => '属性（用逗号分隔）';

  @override
  String get inventoryCustomRangeNormal => '普通射程';

  @override
  String get inventoryCustomRangeLong => '远射程';

  @override
  String get inventoryCustomAddDexToAc => '将DEX加入AC';

  @override
  String get inventoryCustomEquipSlot => '部位（例如：戒指，颈部）';

  @override
  String get inventoryCustomCompatibleWith => '兼容对象（用逗号分隔）';

  @override
  String get inventoryDetailYes => '是';

  @override
  String get inventoryDetailNo => '否';

  @override
  String get inventoryDetailMaxShort => '最大';

  @override
  String get inventoryDetailDamage => '伤害';

  @override
  String get inventoryDetailDamageType => '伤害类型';

  @override
  String get inventoryDetailWeaponProperties => '属性';

  @override
  String get inventoryDetailVersatileDamage => '多用伤害';

  @override
  String get inventoryDetailRange => '射程';

  @override
  String get inventoryDetailRangeNormal => '普通';

  @override
  String get inventoryDetailRangeLong => '远';

  @override
  String get inventoryDetailArmorType => '护甲类型';

  @override
  String get inventoryDetailShield => '盾牌';

  @override
  String get inventoryDetailBaseAc => '基础AC';

  @override
  String get inventoryDetailAcBonus => 'AC加值';

  @override
  String get inventoryDetailAddDexToAc => '将DEX加入AC';

  @override
  String get inventoryDetailMaxDex => '最大DEX';

  @override
  String get inventoryDetailStrengthMinimum => '最低力量';

  @override
  String get inventoryDetailEquipSlot => '部位';

  @override
  String get inventoryDetailRequiresAttunement => '需要同调';

  @override
  String get inventoryDetailCapacityWeight => '重量容量';

  @override
  String get inventoryDetailCapacityVolume => '体积';

  @override
  String get inventoryDetailCapacityVolumeUnit => '体积单位';

  @override
  String get inventoryDetailIgnoreContentWeight => '忽略内容重量';

  @override
  String get inventoryDetailEffect => '效果';

  @override
  String get inventoryDetailUses => '使用次数';

  @override
  String get inventoryDetailAction => '动作';

  @override
  String get inventoryDetailAmmoType => '弹药类型';

  @override
  String get inventoryDetailCompatibleWith => '兼容对象';

  @override
  String get inventoryDetailBonus => '加值';

  @override
  String get inventoryDetailExtraDamage => '额外伤害';

  @override
  String get inventoryDetailExtraDamageType => '额外伤害类型';

  @override
  String get inventoryDetailSubtype => '子类型';

  @override
  String get inventoryDetailCost => '价格';

  @override
  String get inventoryDetailRarity => '稀有度';

  @override
  String get inventoryDetailFeatures => '特性';

  @override
  String get inventoryDetailWeightEach => '单件重量';

  @override
  String get inventoryDetailWeightTotal => '总重量';

  @override
  String get inventoryDetailState => '状态';

  @override
  String get inventoryDetailEquipped => '已装备';

  @override
  String get inventoryDetailNotEquipped => '未装备';

  @override
  String get inventoryDetailSummary => '摘要';

  @override
  String get inventoryDetailDescription => '描述';

  @override
  String get inventoryDetailAttributes => '属性';

  @override
  String get inventoryReplaceArmorTitle => '更换装备的装甲？';

  @override
  String get inventoryTabWeapons => '武器';

  @override
  String get inventoryTabArmor => '盔甲';

  @override
  String get inventoryTabGear => '齿轮';

  @override
  String get inventoryTabMagic => '魔法';

  @override
  String get inventoryTabTools => '工具';

  @override
  String get inventoryTabCustom => '风俗';

  @override
  String hintSearchCategory(String category) {
    return '搜索 $category ...';
  }

  @override
  String get stepChooseMethod => '选择您的方法：';

  @override
  String get stepStandardArray => '标准阵列';

  @override
  String get stepPointBuy => '点买';

  @override
  String get stepRoll4d6 => '滚动 4d6';

  @override
  String get stepDistributeRacialBonuses => '自由分配种族奖金';

  @override
  String get stepAssignRolls => '将每个卷分配给一个属性：';

  @override
  String get stepAssignValues => '将每个值分配给一个属性：';

  @override
  String get stepPointsRemaining => '剩余积分：';

  @override
  String stepRaceBonus(int n) {
    return '种族加值 +$n';
  }

  @override
  String get stepChooseSubrace => '选择一个亚种：';

  @override
  String get stepGrantedByBackground => '背景授予：';

  @override
  String stepClassSkillChoices(int count) {
    return '职业技能选择（$count）：';
  }

  @override
  String get stepChooseOne => '选择一个';

  @override
  String get stepSelectTool => '选择一个工具...';

  @override
  String get statAC => 'AC';

  @override
  String get statArmor => '盔甲';

  @override
  String get statNoArmor => '无盔甲';

  @override
  String get statNoArmorShield => '无铠+盾';

  @override
  String get statShieldSuffix => '+ 盾牌';

  @override
  String get statSpeed => '速度';

  @override
  String get statInitiative => '倡议';

  @override
  String get statProfBonus => '教授奖金';

  @override
  String get statPassivePerc => '被动察觉';

  @override
  String get statInspiration => '灵感';

  @override
  String get statXP => '经验';

  @override
  String get inspirationGranted => '已获得';

  @override
  String get inspirationNotGranted => '未获得';

  @override
  String statLevel(int level) {
    return '第$level级';
  }

  @override
  String get tooltipAddXp => '添加经验';

  @override
  String get labelLevelTable => '等级表';

  @override
  String get statUnconsciousDying => '失去知觉/濒临死亡';

  @override
  String get deathSavesTitle => '死亡豁免';

  @override
  String get deathSavesSuccesses => '成功';

  @override
  String get deathSavesFailures => '失败';

  @override
  String get deathSavesStabilized => '已稳定';

  @override
  String get deathSavesDead => '死亡';

  @override
  String get sectionActiveConditions => '活跃状态';

  @override
  String get conditionsNone => '无活跃状态';

  @override
  String get conditionsAdd => '添加状态';

  @override
  String get conditionsPickTitle => '应用状态';

  @override
  String get conditionsRemove => '移除状态';

  @override
  String get tooltipAddTempHp => '添加临时 HP';

  @override
  String get tooltipChangeTempHp => '改变温度 HP';

  @override
  String get abilityStr => '力量';

  @override
  String get abilityDex => '敏捷';

  @override
  String get abilityCon => '体质';

  @override
  String get abilityInt => '智力';

  @override
  String get abilityWis => '感知';

  @override
  String get abilityCha => '魅力';

  @override
  String featuresSectionRacialTraits(String name) {
    return '种族特征 — $name';
  }

  @override
  String featuresSectionBackground(String name) {
    return '背景功能 — $name';
  }

  @override
  String featuresSectionClass(String name) {
    return '类特性 — $name';
  }

  @override
  String featuresSectionSubclass(String name) {
    return '子类功能 — $name';
  }

  @override
  String get featuresSectionTools => '工具熟练程度';

  @override
  String get featuresSectionExtra => '额外功能';

  @override
  String get spellsNoSpellcasting => '没有施法';

  @override
  String get spellsNoSpellcastingDesc => '该职业没有施法功能。';

  @override
  String get spellsSlots => '法术槽';

  @override
  String get spellsPactMagicSlots => '契约魔法';

  @override
  String get spellsSpellcasting => '施法';

  @override
  String get spellsAttack => '攻击';

  @override
  String get spellsSaveDC => '保存 DC';

  @override
  String get spellsCantrips => '戏法';

  @override
  String get spellsPrepared => '准备好了';

  @override
  String get spellsKnown => '已知';

  @override
  String get spellsEmpty => '尚未添加咒语。\n点击+浏览咒语。';

  @override
  String spellsSlotLevel(int level) {
    return '$level 级';
  }

  @override
  String spellsLevelN(int level) {
    return '等级 $level';
  }

  @override
  String get spellsInnateHeader => '种族法术';

  @override
  String get spellsDisableTitle => '禁用法术？';

  @override
  String get spellsEnableTitle => '启用法术？';

  @override
  String spellsDisableContent(String name) {
    return '禁用“$name”？它将显示为灰色，无法准备。';
  }

  @override
  String spellsEnableContent(String name) {
    return '启用“$name”？它将再次正常显示。';
  }

  @override
  String get spellsDisable => '禁用';

  @override
  String get spellsEnable => '启用';

  @override
  String get spellsExtrasHeader => '额外法术';

  @override
  String get spellFilterTitle => '筛选';

  @override
  String get spellFilterReset => '重置';

  @override
  String get spellFilterApply => '应用筛选';

  @override
  String get spellFilterSectionClasses => '职业';

  @override
  String get spellFilterClassesHint => '未选职业 = 显示所有职业';

  @override
  String get spellFilterSectionLevel => '法术环位';

  @override
  String get spellFilterShowAllLevels => '显示所有环位';

  @override
  String spellFilterShowAllLevelsHint(int max) {
    return '包括超过当前最大环位（第$max环）的法术';
  }

  @override
  String get spellFilterCantrip => '戏法';

  @override
  String spellFilterLvl(int n) {
    return '$n环';
  }

  @override
  String get spellFilterSectionCastingTime => '施法时间';

  @override
  String get spellFilterCastAction => '动作';

  @override
  String get spellFilterCastBonus => '附赠动作';

  @override
  String get spellFilterCastReaction => '反应';

  @override
  String get spellFilterCastLonger => '较长施法（1分钟+）';

  @override
  String get spellFilterSectionProperties => '属性';

  @override
  String get spellFilterConcentration => '专注';

  @override
  String get spellFilterConcentrationHint => '仅显示需要专注的法术';

  @override
  String get spellFilterRitual => '仪式';

  @override
  String get spellFilterRitualHint => '仅显示可以作为仪式施放的法术';

  @override
  String get spellFilterSectionSchool => '法术流派';

  @override
  String get spellRemoveTitle => '移除法术';

  @override
  String spellRemoveContent(String name) {
    return '从法术列表中移除“$name”？';
  }

  @override
  String get spellActionPrepared => '已准备 — 点击取消准备';

  @override
  String get spellActionPrepare => '今日准备';

  @override
  String get spellActionAdd => '添加到角色';

  @override
  String get spellActionInList => '在你的列表中 — 点击移除';

  @override
  String get spellActionAlreadyInList => '已在你的法术列表中';

  @override
  String get spellActionClassSpellInfo => '此法术已包含在你的职业法术列表中，无需学习。';

  @override
  String get inventoryCurrency => '货币';

  @override
  String inventoryCarriedSection(int count) {
    return '携带（$count）';
  }

  @override
  String inventoryEquippableSection(int count) {
    return '可装备（$count）';
  }

  @override
  String get inventoryEquipHint => '点击左侧圆形图标以装备或卸下该物品';

  @override
  String get inventoryInventory => '存货';

  @override
  String get inventoryEmpty => '还没有商品。点击 + 进行添加。';

  @override
  String get inventoryAmmunition => '弹药';

  @override
  String get coinCopper => '铜';

  @override
  String get coinSilver => '银';

  @override
  String get coinElectrum => '金金银';

  @override
  String get coinGold => '金子';

  @override
  String get coinPlatinum => '铂';

  @override
  String get inventoryGroupSimpleMelee => '简单的近战';

  @override
  String get inventoryGroupSimpleRanged => '简单远程';

  @override
  String get inventoryGroupMartialMelee => '武术近战';

  @override
  String get inventoryGroupMartialRanged => '武术远程';

  @override
  String get inventoryGroupLightArmor => '轻甲';

  @override
  String get inventoryGroupMediumArmor => '中型装甲';

  @override
  String get inventoryGroupHeavyArmor => '重甲';

  @override
  String get inventoryGroupShields => '盾牌';

  @override
  String get inventoryGroupAdventuringGear => '冒险装备';

  @override
  String get inventoryGroupAmmunition => '弹药';

  @override
  String get inventoryGroupArcaneFocus => '奥术焦点';

  @override
  String get inventoryGroupClothing => '衣服';

  @override
  String get inventoryGroupContainer => '容器';

  @override
  String get inventoryGroupPoison => '毒';

  @override
  String get inventoryGroupPotions => '药水';

  @override
  String get inventoryGroupRings => '戒指';

  @override
  String get inventoryGroupWands => '魔杖';

  @override
  String get inventoryGroupWeapons => '武器';

  @override
  String get inventoryGroupArmor => '盔甲';

  @override
  String get inventoryGroupWondrousItems => '奇妙物品';

  @override
  String get inventoryGroupArtisansTools => '工匠的工具';

  @override
  String get inventoryGroupGamingSets => '游戏套装';

  @override
  String get inventoryGroupMusicalInstruments => '乐器';

  @override
  String get inventoryGroupOtherTools => '其他工具';

  @override
  String get armorStealthDisadvantage => '隐身劣势';

  @override
  String get spellDetailCastingTime => '施法时间';

  @override
  String get spellDetailRange => '范围';

  @override
  String get spellRangeSelf => '自身';

  @override
  String get spellRangeTouch => '触碰';

  @override
  String get spellRangeSight => '视野';

  @override
  String get spellRangeSpecial => '特殊';

  @override
  String get spellRangeUnlimited => '无限';

  @override
  String get spellAreaSphere => '球形';

  @override
  String get spellAreaCone => '锥形';

  @override
  String get spellAreaCube => '立方体';

  @override
  String get spellAreaCylinder => '圆柱体';

  @override
  String get spellAreaLine => '直线';

  @override
  String get spellAreaWall => '墙';

  @override
  String get spellAreaCircle => '圆形';

  @override
  String get spellDetailDuration => '期间';

  @override
  String get spellDetailComponents => '成分';

  @override
  String get spellDetailConcentration => '需要集中注意力';

  @override
  String get spellDetailRitual => '可以作为仪式施放';

  @override
  String get spellDetailAtHigherLevels => '在更高的层次上。';

  @override
  String spellDetailClasses(String classes) {
    return '类别： $classes';
  }

  @override
  String spellDetailLevelSchool(String ordinal, String school) {
    return '$ordinal 级别 $school';
  }

  @override
  String spellDetailCantrip(String school) {
    return '$school 戏法';
  }

  @override
  String armorSwapCurrent(String name) {
    return '当前: $name';
  }

  @override
  String armorSwapAcNow(int ac) {
    return 'AC现在: $ac';
  }

  @override
  String armorSwapAcAfter(int ac) {
    return 'AC之后: $ac';
  }

  @override
  String get armorSwapButton => '更换护甲';

  @override
  String get reviewRowName => '姓名';

  @override
  String get reviewUnnamedHero => '无名英雄';

  @override
  String get reviewRowPlayer => '玩家';

  @override
  String get reviewRowSubclass => '子类';

  @override
  String get reviewRowHitDie => '生命骰';

  @override
  String get reviewRowSavingThrows => '豁免检定';

  @override
  String get reviewRowSubrace => '亚种';

  @override
  String get reviewRowSpeed => '速度';

  @override
  String get reviewRowLanguages => '语言';

  @override
  String get reviewRowFeature => '特征';

  @override
  String get reviewRowFromBackground => '从背景来看';

  @override
  String get reviewRowClassChoices => '班级选择';

  @override
  String get reviewRowMaxHp => '最大生命值';

  @override
  String get reviewRowAcUnarmored => 'AC（未穿护甲）';

  @override
  String reviewRowAcWith(String name) {
    return '装备$name时的AC';
  }

  @override
  String get reviewRowProficiencyBonus => '熟练度加成';

  @override
  String get reviewStartingGold => '起始黄金';

  @override
  String get reviewStartingEquipment => '启动设备';

  @override
  String get reviewDeselectAll => '取消全选';

  @override
  String get reviewSelectAll => '选择全部';

  @override
  String get reviewUncheckHint => '取消选中您不想添加到库存中的商品。';

  @override
  String get reviewEquipmentChoices => '设备选择';

  @override
  String get reviewEquipmentChoicesHint => '为每个插槽选择特定的项目。';

  @override
  String get reviewToolProficiencies => '工具熟练程度';

  @override
  String get reviewChooseToolProficiency => '选择您的工具熟练程度：';

  @override
  String reviewChooseLanguages(int count) {
    return '选择您的种族或背景授予的 $count 种语言。';
  }

  @override
  String get reviewChooseOne => '选择一项：';

  @override
  String get stepTashaRule => 'Tasha 的可选规则 — 将 ASI 点分配给任何属性';

  @override
  String get stepRollDice => '掷骰子';

  @override
  String get stepReroll => '重新滚动';

  @override
  String get stepRollHint => '滚动生成 6 个值（4d6，降到最低）';

  @override
  String get stepPrimaryAbilities => '主要能力：';

  @override
  String get stepNameTitle => '为你的角色取个名字。';

  @override
  String get stepNameHint => '之后随时可以修改。';

  @override
  String get stepNameCharLabel => '角色名称';

  @override
  String get stepNamePlayerLabel => '玩家姓名（可选）';

  @override
  String get stepHitDieLabel => '生命骰';

  @override
  String get stepSavesLabel => '豁免检定';

  @override
  String get stepSpellcastingLabel => '施法';

  @override
  String get stepOptionsLabel => '选项';

  @override
  String stepChooseSubclassPrompt(String feature, int level) {
    return '选择$feature（等级 $level）：';
  }

  @override
  String get stepRaceSpeedLabel => '速度';

  @override
  String get stepRaceASILabel => '种族属性加值';

  @override
  String stepRaceSubracesAvailable(int count) {
    return '可选亚种族：$count';
  }

  @override
  String stepChooseSkillsHint(int count) {
    return '从你的职业技能列表中选择 $count 项技能。';
  }

  @override
  String get abilityStrength => '力量';

  @override
  String get abilityDexterity => '敏捷';

  @override
  String get abilityConstitution => '体质';

  @override
  String get abilityIntelligence => '智力';

  @override
  String get abilityWisdom => '感知';

  @override
  String get abilityCharisma => '魅力';

  @override
  String stepFreeAsiRemaining(int remaining) {
    return '自由分配种族属性加值（剩余 $remaining 点）：';
  }

  @override
  String stepFreePicksRemaining(int total, int remaining) {
    return '为 $total 项属性各分配 +1（剩余 $remaining 项）：';
  }

  @override
  String get stepFreePicksNoStack => '不能选择已经获得种族加值的属性。';

  @override
  String reviewClassEquipmentTitle(String name) {
    return '等级装备 — $name';
  }

  @override
  String get reviewEquipmentIncluded => '包括：';

  @override
  String get stepToolCategoryGamingSet => '游戏套装';

  @override
  String get stepToolCategoryInstrument => '乐器';

  @override
  String get stepToolCategoryArtisanTool => '工匠的工具';

  @override
  String get stepToolCategoryArtisanOrInstrument => '工匠的工具或仪器';

  @override
  String exportCopied(String label) {
    return '$label已复制!';
  }

  @override
  String exportDialogTitle(String name) {
    return '导出$name';
  }

  @override
  String get exportShowJson => '显示JSON';

  @override
  String get exportCopyJson => '复制JSON';

  @override
  String get exportSectionFile => '完整文件';

  @override
  String get exportSectionFileCaption => '包含角色照片';

  @override
  String get exportShareFile => '分享 .dndchar';

  @override
  String get dialogClose => '关闭';

  @override
  String get importDialogTitle => '导入角色或备份';

  @override
  String get importUseJson => '直接使用JSON';

  @override
  String get importJsonHint => '在此粘贴JSON…';

  @override
  String get importPickFile => '选择 .dndchar 或 .dndbackup 文件';

  @override
  String get importFileError => '无效或损坏的 .dndchar/.dndbackup 文件';

  @override
  String get importFileIncoming => '从文件导入角色？';

  @override
  String get dialogImport => '导入';

  @override
  String get spellBrowserTitle => '浏览法术';

  @override
  String get spellBrowserFilters => '筛选';

  @override
  String get spellBrowserSearchHint => '搜索法术...';

  @override
  String get filterClearAll => '清除所有';

  @override
  String get loadingLabel => '加载中...';

  @override
  String spellBrowserCount(int count, String s) {
    return '$count个法术';
  }

  @override
  String get spellBrowserEmpty => '没有法术符合当前筛选条件。';

  @override
  String get spellCantrip => '戏法';

  @override
  String spellLevelN(int n) {
    return '等级$n';
  }

  @override
  String get castingTimeAction => '动作';

  @override
  String get castingTimeBonusAction => '附赠动作';

  @override
  String get castingTimeReaction => '反应';

  @override
  String get castingTimeLonger => '较长施法';

  @override
  String get filterConcentration => '专注';

  @override
  String get filterRitual => '仪式';

  @override
  String get filterAllLevels => '所有等级';

  @override
  String get avatarChoosePhoto => '选择照片';

  @override
  String get avatarRemovePhoto => '删除照片';

  @override
  String get avatarCropPhoto => '裁剪照片';

  @override
  String get avatarChangePhoto => '更换照片';

  @override
  String get avatarSavePhoto => '保存照片';

  @override
  String get avatarSaveSuccess => '照片已保存到相册';

  @override
  String get avatarSaveError => '无法保存照片';

  @override
  String featureAddedSnackbar(String name) {
    return '$name已添加!';
  }

  @override
  String get featureAddButton => '添加特性';

  @override
  String get reviewLanguageChoices => '语言选择';

  @override
  String get reviewLanguageTypeHint => '输入一门语言…';

  @override
  String get avatarRemoveConfirmTitle => '删除照片？';

  @override
  String get avatarRemoveConfirmBody => '此操作无法撤销。';

  @override
  String get editModeBanner => '编辑中';

  @override
  String get detailSheetInfoTooltip => '详情';

  @override
  String get detailSheetProficiencies => '熟练项';

  @override
  String get detailSheetTraits => '种族特性';

  @override
  String get detailSheetSubclassFeaturePlaceholder => '子职业特性';

  @override
  String detailSheetAvailableSubclasses(String feature) {
    return '可选$feature';
  }

  @override
  String get detailSheetAvailableSubraces => '亚种';

  @override
  String get xpTrackingLabel => '记录经验值';

  @override
  String get xpReadyToLevelUp => '可以升级了！';

  @override
  String get xpLevelUpNowTitle => '现在升级？';

  @override
  String xpLevelUpNowMessage(int level) {
    return '经验值足以达到 $level 级。现在升级吗？';
  }

  @override
  String get xpLevelUpLater => '稍后';

  @override
  String get settingsSectionUnits => '单位';

  @override
  String get settingsUnitSystem => '单位制';

  @override
  String get settingsUnitImperial => '英制 (ft / lb)';

  @override
  String get settingsUnitMetric => '公制 (m / kg)';

  @override
  String get settingsUnitSquares => '格 (sq / kg)';

  @override
  String get settingsChooseUnitSystem => '选择单位制';

  @override
  String get settingsSectionCharacterSheet => '角色卡';

  @override
  String get settingsKeepScreenOnTitle => '保持屏幕常亮';

  @override
  String get settingsKeepScreenOnSubtitle => '查看角色卡时防止屏幕休眠。';

  @override
  String get settingsContextualRollAskTitle => '显示情境掷骰选项';

  @override
  String get settingsContextualRollAskSubtitle => '从角色卡掷骰前显示相关选项，例如优势或劣势。';

  @override
  String get settingsContextualCriticalRuleTitle => '重击规则';

  @override
  String get settingsContextualCriticalRuleSubtitle => '当攻击掷骰掷出自然 20 时自动使用。';

  @override
  String get settingsContextualCriticalRuleChoose => '选择重击规则';

  @override
  String get settingsContextualCriticalRuleDoubleDice => '掷双倍伤害骰';

  @override
  String get settingsContextualCriticalRuleDoubleDamage => '伤害总值翻倍';

  @override
  String get settingsBackupSection => '备份';

  @override
  String get settingsBackupExportTitle => '导出备份';

  @override
  String get settingsBackupExportSubtitle => '将所有角色保存到备份文件。';

  @override
  String get settingsBackupExporting => '正在创建备份...';

  @override
  String get settingsBackupExportSuccess => '备份已导出。';

  @override
  String get settingsBackupExportError => '无法导出备份。';

  @override
  String get settingsBackupImportTitle => '导入备份';

  @override
  String get settingsBackupImportSubtitle => '从 .dndbackup 文件恢复角色。';

  @override
  String get settingsBackupImporting => '正在导入备份...';

  @override
  String get settingsBackupImportError => '无法导入备份。';

  @override
  String settingsBackupImportSuccess(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '已从备份导入 $count 个角色。',
      one: '已从备份导入 1 个角色。',
    );
    return '$_temp0';
  }

  @override
  String get settingsSectionApp => '应用';

  @override
  String get settingsReviewTitle => '在 Play 商店评分';

  @override
  String get settingsReviewSubtitle => '打开应用页面留下评分或评论。';

  @override
  String get settingsReviewOpenError => '无法打开 Play 商店。';

  @override
  String get settingsMaintenanceSection => '维护';

  @override
  String get settingsMaintenanceCheckTitle => '检查角色更新';

  @override
  String get settingsMaintenanceCheckSubtitle => '查找已保存数据的修正。';

  @override
  String get settingsMaintenanceUpdateTitle => '更新角色';

  @override
  String get settingsMaintenanceWorking => '正在检查更新...';

  @override
  String get settingsMaintenanceNoUpdates => '所有角色都已是最新状态。';

  @override
  String get settingsMaintenanceError => '无法更新角色。';

  @override
  String get settingsMaintenanceConfirmTitle => '要更新角色吗？';

  @override
  String get settingsMaintenanceCompleteTitle => '更新完成';

  @override
  String settingsMaintenanceUpdatesFound(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 个角色需要更新。',
      one: '1 个角色需要更新。',
    );
    return '$_temp0';
  }

  @override
  String settingsMaintenanceConfirmBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 个角色需要更新。应用更改前，应用会打开一个可保存或分享的备份。',
      one: '1 个角色需要更新。应用更改前，应用会打开一个可保存或分享的备份。',
    );
    return '$_temp0';
  }

  @override
  String get characterUpdateRequiredTitle => '需要更新角色';

  @override
  String get characterUpdateRequiredBody =>
      '打开此角色前需要更新。你可以先备份角色，或立即更新所有角色。应用更新前会打开备份界面。';

  @override
  String get characterUpdateRequiredAction => '更新选项';

  @override
  String get characterUpdateBackupAction => '备份角色';

  @override
  String get characterUpdateAllAction => '更新所有角色';

  @override
  String get characterUpdateApplying => '正在更新角色...';

  @override
  String settingsMaintenanceReportChecked(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '已检查 $count 个角色。',
      one: '已检查 1 个角色。',
    );
    return '$_temp0';
  }

  @override
  String settingsMaintenanceReportUpdated(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '已更新 $count 个角色。',
      one: '已更新 1 个角色。',
    );
    return '$_temp0';
  }

  @override
  String settingsMaintenanceReportDataChanged(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '已修正 $count 个角色的数据。',
      one: '已修正 1 个角色的数据。',
    );
    return '$_temp0';
  }

  @override
  String get settingsMaintenanceReportVersionUpdated => '数据版本已更新。';

  @override
  String settingsMaintenanceChangeEquipmentWeights(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '已修正 $count 个物品的重量。',
      one: '已修正 1 个物品的重量。',
    );
    return '$_temp0';
  }

  @override
  String settingsMaintenanceChangeEquipmentNormalized(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '已规范化 $count 个装备物品。',
      one: '已规范化 1 个装备物品。',
    );
    return '$_temp0';
  }

  @override
  String settingsMaintenanceChangeEquipmentPacksExpanded(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '已展开 $count 个装备包。',
      one: '已展开 1 个装备包。',
    );
    return '$_temp0';
  }

  @override
  String settingsMaintenanceChangeEquipmentOrder(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '已规范化 $count 个库存物品的顺序。',
      one: '已规范化 1 个库存物品的顺序。',
    );
    return '$_temp0';
  }

  @override
  String get settingsMaintenanceChangeMulticlassStructure => '已为兼职准备职业结构。';

  @override
  String get settingsMaintenanceChangeSpellSlots => '已重新计算标准法术槽。';

  @override
  String get settingsMaintenanceChangePactMagicSlots => '已分离契约魔法法术槽。';

  @override
  String get settingsMaintenanceChangeArmorClass => '已重新计算护甲等级。';

  @override
  String get settingsMaintenanceChangeRuleset2014 =>
      '已将此角色设为使用 2014 年规则（SRD 5.1）。';

  @override
  String get settingsMaintenanceChangeLevelHistory => '已保存用于升级和重置等级的1级记录。';

  @override
  String get settingsMaintenanceChangeClassSkills => '已保存1级时来自职业的技能。';

  @override
  String settingsMaintenanceChangeGeneric(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '已应用 $count 项更改。',
      one: '已应用 1 项更改。',
    );
    return '$_temp0';
  }

  @override
  String get incomingBackupPrompt => '要从文件导入备份吗？';

  @override
  String incomingBackupSuccess(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '已从备份导入 $count 个角色。',
      one: '已从备份导入 1 个角色。',
    );
    return '$_temp0';
  }
}
