// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get appTitle => 'D&D キャラクターツール';

  @override
  String get charListTitle => 'D&Dのキャラクター';

  @override
  String get charListImportTooltip => 'JSONをインポートする';

  @override
  String get charListSettingsTooltip => '設定';

  @override
  String get charListNewCharacter => '新キャラクター';

  @override
  String get charListEmpty => 'まだ文字がありません';

  @override
  String get charListEmptyHint => '+ をタップして最初のキャラクターを作成します';

  @override
  String charListImportedSuccess(String name) {
    return '$name は正常にインポートされました。';
  }

  @override
  String get charListImportError => 'インポート中に予期しないエラーが発生しました。もう一度試してください。';

  @override
  String get importErrorInvalidJson => '貼り付けたテキストは有効なJSONではありません。';

  @override
  String get importErrorNotObject => '無効な形式です：JSONオブジェクトが予期されます。';

  @override
  String get importErrorMissingCharacter =>
      '無効なJSON：\"character\"フィールドが見つかりません。';

  @override
  String get importErrorCorruptedCharacter =>
      'キャラクターを読み込めませんでした。JSONが不完全、または互換性のないバージョンからのデータの可能性があります。';

  @override
  String charCardLevel(int level) {
    return 'レベル$level';
  }

  @override
  String get charCardPin => 'トップにピン留めする';

  @override
  String get charCardUnpin => '固定を解除する';

  @override
  String get charCardChangePhoto => '写真を変更する';

  @override
  String get charCardRename => '名前の変更';

  @override
  String get charCardExport => '輸出';

  @override
  String get charCardDelete => '消去';

  @override
  String get renameDialogTitle => 'キャラクターの名前を変更する';

  @override
  String get renameDialogLabel => '名前';

  @override
  String get dialogCancel => 'キャンセル';

  @override
  String get dialogSave => '保存';

  @override
  String get deleteDialogTitle => 'キャラクターを削除しますか？';

  @override
  String deleteDialogContent(String name) {
    return '$name を削除してもよろしいですか?これを元に戻すことはできません。';
  }

  @override
  String get dialogConfirm => '確認する';

  @override
  String get dialogDiscard => '破棄';

  @override
  String get dialogContinue => '続く';

  @override
  String get dialogKeepEditing => '編集を続ける';

  @override
  String get dialogRemove => '取り除く';

  @override
  String get dialogAdd => '追加';

  @override
  String get settingsTitle => '設定';

  @override
  String get settingsSectionTheme => 'ビジュアルテーマ';

  @override
  String get settingsDark => '暗い';

  @override
  String get settingsLight => 'ライト';

  @override
  String get settingsChooseTheme => 'テーマを選択してください';

  @override
  String get settingsSectionLanguage => '言語';

  @override
  String get settingsAppLanguage => 'アプリ言語';

  @override
  String get settingsChooseLanguage => '言語を選択してください';

  @override
  String get settingsSystemDefault => 'システムのデフォルト';

  @override
  String get modeSelectionTitle => '新キャラクター';

  @override
  String get modeSelectionQuestion => 'キャラクターをどのように作成したいですか?';

  @override
  String get modeGuidedTitle => 'ガイド付き';

  @override
  String get modeGuidedSubtitle =>
      'ステップバイステップのウィザード。クラス、種族、背景、スキル、属性を一度に 1 つずつ選択します。新規プレイヤーにお勧めします。';

  @override
  String get modeManualTitle => 'マニュアル';

  @override
  String get modeManualSubtitle =>
      'すべて自分で入力してください。すべてのフィールドは無料であり、値は自動的に計算されません。経験豊富なプレイヤーに最適です。';

  @override
  String get modeRandomTitle => 'ランダム';

  @override
  String get modeRandomSubtitle =>
      '人種、階級、背景、属性など、すべてがあなたのために決定されます。チャレンジやワンショットに最適です。';

  @override
  String get modeSemiRandomTitle => '半ランダム';

  @override
  String get modeSemiRandomSubtitle =>
      '重要な選択肢を選ぶのはあなたです。他のすべてはロールされます。コンセプトはあるけどサプライズが欲しいときに最適です。';

  @override
  String get modeComingSoon => 'すぐ';

  @override
  String get creationStepClass => 'クラス';

  @override
  String get creationStepRace => '人種';

  @override
  String get creationStepBackground => '背景';

  @override
  String get creationStepSkills => 'スキル';

  @override
  String get creationStepAttributes => '属性';

  @override
  String get creationStepName => '名前';

  @override
  String get creationStepReview => 'レビュー';

  @override
  String get creationDiscardTitle => 'キャラを捨てる？';

  @override
  String get creationDiscardContent => 'すべての進行状況は失われます。本気ですか？';

  @override
  String get creationTooltipCancel => 'キャンセル';

  @override
  String get creationBack => '戻る';

  @override
  String get creationCreateCharacter => 'キャラクターの作成';

  @override
  String get detailLeaveWithoutSaving => '保存せずに終了しますか?';

  @override
  String get detailChangesWillBeDiscarded => '変更は破棄されます。保存するには、右上の✓ボタンを使用します。';

  @override
  String get detailLeaveAndDiscard => '放置して捨てる';

  @override
  String detailErrorLoading(String error) {
    return '文字のロード中にエラーが発生しました: $error';
  }

  @override
  String get detailTooltipLongRest => '長い休憩';

  @override
  String get detailTooltipCancelEdit => '編集をキャンセルする';

  @override
  String get detailTooltipDoneEditing => '編集が完了しました';

  @override
  String get detailTooltipEditCharacter => 'キャラクターを編集する';

  @override
  String get detailCancelEditTitle => '編集をキャンセルしますか?';

  @override
  String get detailCancelEditContent => 'すべての変更は破棄されます。';

  @override
  String get detailFinishEditTitle => '編集を終了しますか?';

  @override
  String get detailFinishEditContent => '変更は保存されます。';

  @override
  String get detailTabIdentity => '素性';

  @override
  String get detailEditButton => '編集';

  @override
  String get skillsEditHint => '長押して切替: なし→習熟→熟達';

  @override
  String get detailTabStats => '統計';

  @override
  String get detailTabSkills => 'スキル';

  @override
  String get detailTabFeatures => '特徴';

  @override
  String get detailTabSpells => '呪文';

  @override
  String get detailTabInventory => '在庫';

  @override
  String get detailTabNotes => '注意事項';

  @override
  String get longRestTitle => '長い休憩';

  @override
  String get longRestContent => 'HPを最大まで回復し、魔法スロットをすべて回復しますか？';

  @override
  String get longRestButton => '休む';

  @override
  String get sectionIdentity => '身元';

  @override
  String get sectionHitPoints => 'ヒットポイント';

  @override
  String get sectionCombat => '戦闘';

  @override
  String get sectionAbilityScores => '能力値';

  @override
  String get sectionSavingThrows => '投げの熟練度を保存する';

  @override
  String get labelName => '名前';

  @override
  String get labelBackground => '背景';

  @override
  String get labelChange => '変化';

  @override
  String get labelAlignment => '位置合わせ';

  @override
  String get labelPlayer => 'プレーヤー';

  @override
  String get labelLevel => 'レベル';

  @override
  String get labelSubclass => 'サブクラス';

  @override
  String get labelLanguages => '言語';

  @override
  String get hintAddLanguage => '言語を追加…';

  @override
  String get labelChoose => '選ぶ';

  @override
  String get sectionAppearance => '外見';

  @override
  String get labelAge => '年齢';

  @override
  String get labelHeight => '身長';

  @override
  String get labelWeight => '体重';

  @override
  String get labelEyes => '目';

  @override
  String get labelSkin => '肌';

  @override
  String get labelHair => '髪';

  @override
  String get labelMaxHP => '最大HP';

  @override
  String get labelTempHP => '一時HP';

  @override
  String get labelAmount => '額';

  @override
  String get labelSpeed => '速度 (フィート)';

  @override
  String get detailDamage => 'ダメージ';

  @override
  String get detailHeal => '癒す';

  @override
  String get detailNone => 'なし';

  @override
  String get tempHpDialogTitle => '一時的なHPを追加';

  @override
  String get tempHpDialogTitleReplace => '仮HP';

  @override
  String tempHpCurrent(int n) {
    return '現在: + $n 温度 HP';
  }

  @override
  String get tempHpNoStack => '一時 HP はスタックしません。より高い値のみが現在の値に置き換わります。';

  @override
  String get tempHpReplace => '交換する';

  @override
  String subclassConfirmTitle(String feature) {
    return '$featureを確認する';
  }

  @override
  String subclassChooseTitle(String feature) {
    return '$featureを選択してください';
  }

  @override
  String subclassConfirmBody(int level, String feature) {
    return 'レベル $level に到達しました。 $feature を確認または変更します。';
  }

  @override
  String subclassChooseBody(int level, String feature) {
    return 'レベル $level に到達しました! $feature を選択してください。';
  }

  @override
  String get subclassKeepCurrent => '最新の状態を維持する';

  @override
  String get subclassChangeTitle => 'サブクラスの変更';

  @override
  String get subclassChangeWarning =>
      '警告: 前のサブクラスによって付与された呪文と熟練度は自動的には削除されません。手動で調整する必要があります。';

  @override
  String get backgroundChooseTitle => '背景の選択';

  @override
  String get featuresTooltipAdd => '機能の追加';

  @override
  String get featuresTooltipRemove => '取り除く';

  @override
  String get featuresTooltipEnable => '有効';

  @override
  String get featuresTooltipDisable => '無効';

  @override
  String get featuresTabClass => 'クラス';

  @override
  String get featuresTabRacial => '種族';

  @override
  String get featuresTabCustom => 'カスタム';

  @override
  String get featuresRemoveTitle => '機能を削除しますか?';

  @override
  String featuresRemoveContent(String name) {
    return '「 $name 」は削除されます。';
  }

  @override
  String get featuresNoneAvailable => '利用できる機能はありません。';

  @override
  String get featuresAddLabel => '機能の追加';

  @override
  String get featuresLoadError => '機能のロード中にエラーが発生しました。';

  @override
  String get hintSearch => '検索...';

  @override
  String get labelFeatureName => '名前';

  @override
  String get labelFeatureDescription => '説明 (オプション)';

  @override
  String get labelFeatureType => 'タイプ：';

  @override
  String get labelPassive => '受け身';

  @override
  String get labelActive => 'アクティブ';

  @override
  String get spellsTooltipAdd => '呪文を追加する';

  @override
  String get spellsRemoveTitle => '呪文を解除しますか？';

  @override
  String spellsRemoveContent(String name) {
    return '呪文リストから「 $name 」を削除しますか?';
  }

  @override
  String get spellsAtWill => '意のままに';

  @override
  String get notesTooltipAdd => 'メモを追加';

  @override
  String get notesTooltipEdit => 'メモを編集する';

  @override
  String get notesTooltipDelete => 'メモの削除';

  @override
  String get notesDeleteTitle => 'メモを削除しますか?';

  @override
  String notesDeleteContentNamed(String title) {
    return '「 $title 」は完全に削除されます。';
  }

  @override
  String get notesDeleteContent => 'このメモは完全に削除されます。';

  @override
  String get notesLabelTitle => 'タイトル';

  @override
  String get notesLabelContent => 'コンテンツ';

  @override
  String get sectionPersonality => '個性';

  @override
  String get sectionPersonalityTraits => '性格特性';

  @override
  String get sectionIdeals => '理想';

  @override
  String get sectionBonds => '債券';

  @override
  String get sectionFlaws => '欠陥';

  @override
  String get sectionBackstory => 'バックストーリー';

  @override
  String inventoryEquippedSection(int count, int ac) {
    return '装備（$count）・AC $ac';
  }

  @override
  String get inventoryTooltipAdd => 'アイテムの追加';

  @override
  String get inventoryTooltipRemove => '取り除く';

  @override
  String get inventoryRemoveTitle => 'アイテムを削除しますか?';

  @override
  String inventoryRemoveContent(String name) {
    return '$name をインベントリから削除しますか?';
  }

  @override
  String inventoryRemovePartial(int count, int total) {
    return '削除します: $count/$total';
  }

  @override
  String get inventoryLabelQuantity => '量：';

  @override
  String get inventoryLabelQuantityToRemove => '削除する数量';

  @override
  String get inventoryAddCustomItem => 'カスタム項目の追加';

  @override
  String get inventoryAddItem => 'アイテムの追加';

  @override
  String get inventoryLabelItemName => '名前 *';

  @override
  String get inventoryLabelType => 'タイプ';

  @override
  String get inventoryLabelCategory => 'カテゴリ';

  @override
  String get inventoryLabelItemQuantity => '量';

  @override
  String get inventoryLabelDescription => '説明 (オプション)';

  @override
  String get inventoryTypeWeapon => '武器';

  @override
  String get inventoryTypeArmor => '鎧';

  @override
  String get inventoryTypeConsumable => '消耗品';

  @override
  String get inventoryTypeGear => 'ギヤ';

  @override
  String get inventoryReplaceArmorTitle => '装備している防具を交換しますか？';

  @override
  String get inventoryTabWeapons => '兵器';

  @override
  String get inventoryTabArmor => '鎧';

  @override
  String get inventoryTabGear => 'ギヤ';

  @override
  String get inventoryTabMagic => '魔法';

  @override
  String get inventoryTabTools => 'ツール';

  @override
  String get inventoryTabCustom => 'カスタム';

  @override
  String hintSearchCategory(String category) {
    return '$category を検索 ...';
  }

  @override
  String get stepChooseMethod => '方法を選択してください:';

  @override
  String get stepStandardArray => '標準アレイ';

  @override
  String get stepPointBuy => 'ポイント購入';

  @override
  String get stepRoll4d6 => 'ロール 4d6';

  @override
  String get stepDistributeRacialBonuses => '種族ボーナスを自由に配布する';

  @override
  String get stepAssignRolls => '各ロールを属性に割り当てます。';

  @override
  String get stepAssignValues => '各値を 1 つの属性に割り当てます。';

  @override
  String get stepPointsRemaining => '残りポイント:';

  @override
  String stepRaceBonus(int n) {
    return '+$nレース';
  }

  @override
  String get stepChooseSubrace => 'サブレースを選択します。';

  @override
  String get stepGrantedByBackground => '背景により付与:';

  @override
  String stepClassSkillChoices(int count) {
    return 'クラススキルの選択 ( $count ):';
  }

  @override
  String get stepChooseOne => '1 つ選択してください';

  @override
  String get stepSelectTool => 'ツールを選択してください…';

  @override
  String get statAC => '交流';

  @override
  String get statArmor => '鎧';

  @override
  String get statNoArmor => '鎧なし';

  @override
  String get statNoArmorShield => '鎧+盾なし';

  @override
  String get statShieldSuffix => '+ シールド';

  @override
  String get statSpeed => 'スピード';

  @override
  String get statInitiative => '主導権';

  @override
  String get statProfBonus => '教授ボーナス';

  @override
  String get statPassivePerc => 'パッシブパーク';

  @override
  String get statInspiration => 'ヒラメキ';

  @override
  String get statXP => 'XP';

  @override
  String get statUnconsciousDying => '意識不明 / 瀕死';

  @override
  String get tooltipAddTempHp => '一時HPを追加';

  @override
  String get tooltipChangeTempHp => '温度HP変更';

  @override
  String get abilityStr => 'STR';

  @override
  String get abilityDex => 'デックス';

  @override
  String get abilityCon => 'CON';

  @override
  String get abilityInt => 'INT';

  @override
  String get abilityWis => 'ウィスコンシン州';

  @override
  String get abilityCha => 'チャ';

  @override
  String featuresSectionRacialTraits(String name) {
    return '人種的特徴 — $name';
  }

  @override
  String featuresSectionBackground(String name) {
    return '背景機能 — $name';
  }

  @override
  String featuresSectionClass(String name) {
    return 'クラスの機能 — $name';
  }

  @override
  String featuresSectionSubclass(String name) {
    return 'サブクラス機能 — $name';
  }

  @override
  String get featuresSectionTools => 'ツールの習熟度';

  @override
  String get featuresSectionExtra => '追加機能';

  @override
  String get spellsNoSpellcasting => '呪文詠唱なし';

  @override
  String get spellsNoSpellcastingDesc => 'このクラスには呪文を唱える機能はありません。';

  @override
  String get spellsSlots => 'スペルスロット';

  @override
  String get spellsSpellcasting => '呪文詠唱';

  @override
  String get spellsAttack => '攻撃';

  @override
  String get spellsSaveDC => 'DCの保存';

  @override
  String get spellsCantrips => 'キャントリップ';

  @override
  String get spellsPrepared => '準備した';

  @override
  String get spellsKnown => '既知の';

  @override
  String get spellsEmpty => 'まだ呪文は追加されていません。\n+ をタップして呪文を参照します。';

  @override
  String spellsSlotLevel(int level) {
    return 'レベル $level';
  }

  @override
  String spellsLevelN(int level) {
    return 'レベル$level';
  }

  @override
  String get inventoryCurrency => '通貨';

  @override
  String inventoryCarriedSection(int count) {
    return '搭載 ( $count )';
  }

  @override
  String get inventoryInventory => '在庫';

  @override
  String get inventoryEmpty => 'まだアイテムはありません。 +をタップして追加します。';

  @override
  String get inventoryAmmunition => '弾薬';

  @override
  String get coinCopper => '銅';

  @override
  String get coinSilver => '銀';

  @override
  String get coinElectrum => 'エレクトラム';

  @override
  String get coinGold => '金';

  @override
  String get coinPlatinum => '白金';

  @override
  String get inventoryGroupSimpleMelee => 'シンプルな近接攻撃';

  @override
  String get inventoryGroupSimpleRanged => 'シンプルな遠距離攻撃';

  @override
  String get inventoryGroupMartialMelee => '格闘戦';

  @override
  String get inventoryGroupMartialRanged => '遠距離格闘技';

  @override
  String get inventoryGroupLightArmor => 'ライトアーマー';

  @override
  String get inventoryGroupMediumArmor => '中装甲';

  @override
  String get inventoryGroupHeavyArmor => '重装甲';

  @override
  String get inventoryGroupShields => 'シールド';

  @override
  String get inventoryGroupAdventuringGear => '冒険ギア';

  @override
  String get inventoryGroupAmmunition => '弾薬';

  @override
  String get inventoryGroupArcaneFocus => '秘術の焦点';

  @override
  String get inventoryGroupClothing => '衣類';

  @override
  String get inventoryGroupContainer => '容器';

  @override
  String get inventoryGroupPoison => '毒';

  @override
  String get inventoryGroupPotions => 'ポーション';

  @override
  String get inventoryGroupRings => '指輪';

  @override
  String get inventoryGroupWands => 'ワンド';

  @override
  String get inventoryGroupWeapons => '兵器';

  @override
  String get inventoryGroupArmor => '鎧';

  @override
  String get inventoryGroupWondrousItems => '素晴らしいアイテム';

  @override
  String get inventoryGroupArtisansTools => '職人の道具';

  @override
  String get inventoryGroupGamingSets => 'ゲームセット';

  @override
  String get inventoryGroupMusicalInstruments => '楽器';

  @override
  String get inventoryGroupOtherTools => 'その他のツール';

  @override
  String get armorStealthDisadvantage => 'ステルスの欠点';

  @override
  String get spellDetailCastingTime => '詠唱時間';

  @override
  String get spellDetailRange => '範囲';

  @override
  String get spellDetailDuration => '間隔';

  @override
  String get spellDetailComponents => 'コンポーネント';

  @override
  String get spellDetailConcentration => '集中力が必要';

  @override
  String get spellDetailRitual => '儀式として発動できる';

  @override
  String get spellDetailAtHigherLevels => 'より高いレベルで。';

  @override
  String spellDetailClasses(String classes) {
    return 'クラス: $classes';
  }

  @override
  String spellDetailLevelSchool(String ordinal, String school) {
    return '$ordinal - レベル $school';
  }

  @override
  String spellDetailCantrip(String school) {
    return '$school キャントリップ';
  }

  @override
  String armorSwapCurrent(String name) {
    return '現在: $name';
  }

  @override
  String armorSwapAcNow(int ac) {
    return '現在AC: $ac';
  }

  @override
  String armorSwapAcAfter(int ac) {
    return 'AC後：$ac';
  }

  @override
  String get armorSwapButton => 'アーマーを交換する';

  @override
  String get reviewRowName => '名前';

  @override
  String get reviewUnnamedHero => '名前のない英雄';

  @override
  String get reviewRowPlayer => 'プレーヤー';

  @override
  String get reviewRowSubclass => 'サブクラス';

  @override
  String get reviewRowHitDie => 'ヒットダイ';

  @override
  String get reviewRowSavingThrows => 'セービングスロー';

  @override
  String get reviewRowSubrace => 'サブレース';

  @override
  String get reviewRowSpeed => 'スピード';

  @override
  String get reviewRowLanguages => '言語';

  @override
  String get reviewRowFeature => '特徴';

  @override
  String get reviewRowFromBackground => '背景から';

  @override
  String get reviewRowClassChoices => 'クラスの選択';

  @override
  String get reviewRowMaxHp => '最大HP';

  @override
  String get reviewRowAcUnarmored => 'AC (非装甲)';

  @override
  String reviewRowAcWith(String name) {
    return '$nameを搭載したAC';
  }

  @override
  String get reviewRowProficiencyBonus => '熟練度ボーナス';

  @override
  String get reviewStartingGold => 'スターティングゴールド';

  @override
  String get reviewStartingEquipment => '始動装置';

  @override
  String get reviewDeselectAll => 'すべての選択を解除します';

  @override
  String get reviewSelectAll => 'すべて選択';

  @override
  String get reviewUncheckHint => 'インベントリに追加したくないアイテムのチェックを外します。';

  @override
  String get reviewEquipmentChoices => '装備の選択';

  @override
  String get reviewEquipmentChoicesHint => '各スロットに特定のアイテムを選択します。';

  @override
  String get reviewToolProficiencies => 'ツールの習熟度';

  @override
  String get reviewChooseToolProficiency => 'ツールの習熟度を選択してください:';

  @override
  String reviewChooseLanguages(int count) {
    return '人種または背景によって許可された $count 言語を選択してください。';
  }

  @override
  String get reviewChooseOne => '1 つ選択してください:';

  @override
  String get stepTashaRule => 'Tasha のオプションのルール — ASI ポイントを任意の属性に割り当てる';

  @override
  String get stepRollDice => 'サイコロを振る';

  @override
  String get stepReroll => 'リセマラ';

  @override
  String get stepRollHint => 'ロールして 6 つの値を生成します (4d6、最低値をドロップ)';

  @override
  String get stepPrimaryAbilities => '主な能力:';

  @override
  String get stepNameTitle => 'キャラクターに名前を付けます。';

  @override
  String get stepNameHint => 'これは後でいつでも変更できます。';

  @override
  String get stepNameCharLabel => 'キャラクター名';

  @override
  String get stepNamePlayerLabel => 'プレイヤー名（任意）';

  @override
  String get stepHitDieLabel => 'ヒットダイ';

  @override
  String get stepSavesLabel => '保存';

  @override
  String get stepSpellcastingLabel => '呪文詠唱';

  @override
  String get stepOptionsLabel => 'オプション';

  @override
  String stepChooseSubclassPrompt(String feature, int level) {
    return '$feature (Lv $level) を選択してください:';
  }

  @override
  String get stepRaceSpeedLabel => 'スピード';

  @override
  String get stepRaceASILabel => 'ASI';

  @override
  String stepRaceSubracesAvailable(int count) {
    return '$count 個のサブレースが利用可能';
  }

  @override
  String stepChooseSkillsHint(int count) {
    return 'クラスリストから $count 個のスキルを選択してください。';
  }

  @override
  String get abilityStrength => '強さ';

  @override
  String get abilityDexterity => '器用さ';

  @override
  String get abilityConstitution => '憲法';

  @override
  String get abilityIntelligence => '知能';

  @override
  String get abilityWisdom => '知恵';

  @override
  String get abilityCharisma => 'カリスマ';

  @override
  String stepFreeAsiRemaining(int remaining) {
    return '人種 ASI ポイントを自由に分配します (残り $remaining):';
  }

  @override
  String stepFreePicksRemaining(int total, int remaining) {
    return '人種フリー ASI: $total 属性に +1 を割り当てます (残り $remaining):';
  }

  @override
  String get stepFreePicksNoStack => 'すでに種族ボーナスを受けている属性には割り当てることができません。';

  @override
  String reviewClassEquipmentTitle(String name) {
    return 'クラス装備 — $name';
  }

  @override
  String get reviewEquipmentIncluded => '含まれるもの:';

  @override
  String get stepToolCategoryGamingSet => 'ゲームセット';

  @override
  String get stepToolCategoryInstrument => '楽器';

  @override
  String get stepToolCategoryArtisanTool => '職人の道具';

  @override
  String get stepToolCategoryArtisanOrInstrument => '職人の道具や道具';

  @override
  String exportCopied(String label) {
    return '$labelをコピーしました!';
  }

  @override
  String exportDialogTitle(String name) {
    return '$nameをエクスポート';
  }

  @override
  String get exportLabelToken => 'トークン';

  @override
  String get exportCopyToken => 'トークンをコピー';

  @override
  String get exportHideQr => 'QRコードを非表示';

  @override
  String get exportShowQr => 'QRコードを表示';

  @override
  String get exportQrTooLarge =>
      'キャラクターがQRコードに収まりません。\nトークンまたはJSONを使って共有してください。';

  @override
  String get exportShowJson => 'JSONを表示';

  @override
  String get exportCopyJson => 'JSONをコピー';

  @override
  String get dialogClose => '閉じる';

  @override
  String get importDialogTitle => 'キャラクターをインポート';

  @override
  String get importTokenHint => 'ここにトークンを貼り付け…';

  @override
  String get importScanQr => 'QRコードをスキャン';

  @override
  String get importUseJson => 'JSONを直接使用';

  @override
  String get importJsonHint => 'ここにJSONを貼り付け…';

  @override
  String get dialogImport => 'インポート';

  @override
  String get spellBrowserTitle => '呪文を検索';

  @override
  String get spellBrowserFilters => 'フィルター';

  @override
  String get spellBrowserSearchHint => '呪文を検索...';

  @override
  String get filterClearAll => 'すべてクリア';

  @override
  String get loadingLabel => '読み込み中...';

  @override
  String spellBrowserCount(int count, String s) {
    return '呪文$count件';
  }

  @override
  String get spellBrowserEmpty => '現在のフィルターに一致する呪文がありません。';

  @override
  String get spellCantrip => 'カントリップ';

  @override
  String spellLevelN(int n) {
    return '$nレベル';
  }

  @override
  String get castingTimeAction => 'アクション';

  @override
  String get castingTimeBonusAction => 'ボーナスアクション';

  @override
  String get castingTimeReaction => '反応';

  @override
  String get castingTimeLonger => '長い詠唱';

  @override
  String get filterConcentration => '集中';

  @override
  String get filterRitual => '儀式';

  @override
  String get filterAllLevels => '全レベル';

  @override
  String get avatarChoosePhoto => '写真を選ぶ';

  @override
  String get avatarRemovePhoto => '写真を削除';

  @override
  String get avatarCropPhoto => '写真を切り取る';

  @override
  String get avatarChangePhoto => '写真を変更';

  @override
  String featureAddedSnackbar(String name) {
    return '$nameを追加しました!';
  }

  @override
  String get featureAddButton => '特性を追加';

  @override
  String get reviewLanguageChoices => '言語の選択';

  @override
  String get reviewLanguageTypeHint => '言語を入力…';

  @override
  String get avatarRemoveConfirmTitle => '写真を削除しますか？';

  @override
  String get avatarRemoveConfirmBody => 'この操作は元に戻せません。';

  @override
  String get editModeBanner => '編集中';
}
