// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => 'D&D 角色工具';

  @override
  String get charListTitle => '龙与地下城角色';

  @override
  String get charListImportTooltip => '导入 JSON';

  @override
  String get charListSettingsTooltip => '设置';

  @override
  String get charListNewCharacter => '新角色';

  @override
  String get charListEmpty => '还没有角色';

  @override
  String get charListEmptyHint => '点击+创建你的第一个角色';

  @override
  String charListImportedSuccess(String name) {
    return '$name导入成功！';
  }

  @override
  String get charListImportError => '导入时出现意外错误。请再试一次。';

  @override
  String get importErrorInvalidJson => '粘贴的文本不是有效的 JSON。';

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
  String get charCardExport => '出口';

  @override
  String get charCardDelete => '删除';

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
  String get sectionSavingThrows => '豁免能力';

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
  String get levelManualChangeWarning =>
      '仅职业特性和法术位会自动更新。如需完整升级（HP、属性、专长、法术），请使用顶部栏的「升级」按鈕。';

  @override
  String get tooltipLevelUp => '升级';

  @override
  String get levelUpTitle => '升级';

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
  String get inventoryLabelDescription => '说明（可选）';

  @override
  String get inventoryTypeWeapon => '武器';

  @override
  String get inventoryTypeArmor => '盔甲';

  @override
  String get inventoryTypeConsumable => '消耗品';

  @override
  String get inventoryTypeGear => '齿轮';

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
    return '+ $n 竞赛';
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
  String get statAC => '交流电';

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
  String get statPassivePerc => '被动全氯乙烯';

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
  String get tooltipAddTempHp => '添加临时 HP';

  @override
  String get tooltipChangeTempHp => '改变温度 HP';

  @override
  String get abilityStr => 'STR';

  @override
  String get abilityDex => '去中心化交易所';

  @override
  String get abilityCon => '康';

  @override
  String get abilityInt => 'INT';

  @override
  String get abilityWis => '气象信息系统';

  @override
  String get abilityCha => '查安';

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
  String get reviewRowHitDie => '击中骰子';

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
  String get reviewRowAcUnarmored => '交流（非装甲）';

  @override
  String reviewRowAcWith(String name) {
    return '与 $name 的交流';
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
  String get stepNameTitle => '给你的角色起一个名字。';

  @override
  String get stepNameHint => '您以后可以随时更改此设置。';

  @override
  String get stepNameCharLabel => '角色名称';

  @override
  String get stepNamePlayerLabel => '玩家姓名（可选）';

  @override
  String get stepHitDieLabel => '命中死亡';

  @override
  String get stepSavesLabel => '保存';

  @override
  String get stepSpellcastingLabel => '施法';

  @override
  String get stepOptionsLabel => '选项';

  @override
  String stepChooseSubclassPrompt(String feature, int level) {
    return '选择一个$feature（Lv $level）：';
  }

  @override
  String get stepRaceSpeedLabel => '速度';

  @override
  String get stepRaceASILabel => '亚洲SI';

  @override
  String stepRaceSubracesAvailable(int count) {
    return '$count 个子比赛可用';
  }

  @override
  String stepChooseSkillsHint(int count) {
    return '从您的班级列表中选择 $count 项技能。';
  }

  @override
  String get abilityStrength => '力量';

  @override
  String get abilityDexterity => '灵巧';

  @override
  String get abilityConstitution => '宪法';

  @override
  String get abilityIntelligence => '智力';

  @override
  String get abilityWisdom => '智慧';

  @override
  String get abilityCharisma => '魅力';

  @override
  String stepFreeAsiRemaining(int remaining) {
    return '自由分配种族ASI积分（剩余$remaining）：';
  }

  @override
  String stepFreePicksRemaining(int total, int remaining) {
    return '无种族 ASI：为 $total 属性指定 +1（剩余 $remaining）：';
  }

  @override
  String get stepFreePicksNoStack => '无法分配给已经获得种族加值的属性。';

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
  String get exportLabelToken => '令牌';

  @override
  String get exportCopyToken => '复制令牌';

  @override
  String get exportHideQr => '隐藏二维码';

  @override
  String get exportShowQr => '显示二维码';

  @override
  String get exportQrTooLarge => '角色太大，无法生成二维码。\n请使用令牌或JSON进行分享。';

  @override
  String get exportShowJson => '显示JSON';

  @override
  String get exportCopyJson => '复制JSON';

  @override
  String get dialogClose => '关闭';

  @override
  String get importDialogTitle => '导入角色';

  @override
  String get importTokenHint => '在此粘贴令牌…';

  @override
  String get importScanQr => '扫描二维码';

  @override
  String get importUseJson => '直接使用JSON';

  @override
  String get importJsonHint => '在此粘贴JSON…';

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
}
