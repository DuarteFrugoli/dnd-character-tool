// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class AppLocalizationsKo extends AppLocalizations {
  AppLocalizationsKo([String locale = 'ko']) : super(locale);

  @override
  String get appTitle => 'D&D 캐릭터 도구';

  @override
  String get charListTitle => 'D&D 캐릭터';

  @override
  String get charListImportTooltip => 'JSON 가져오기';

  @override
  String get charListSettingsTooltip => '설정';

  @override
  String get charListNewCharacter => '새로운 캐릭터';

  @override
  String get charListEmpty => '아직 문자가 없습니다.';

  @override
  String get charListEmptyHint => '+를 탭하여 첫 번째 캐릭터를 생성하세요';

  @override
  String charListImportedSuccess(String name) {
    return '$name를 성공적으로 가져왔습니다!';
  }

  @override
  String get charListImportError => '가져오는 동안 예상치 못한 오류가 발생했습니다. 다시 시도해 주세요.';

  @override
  String get importErrorInvalidJson => '붙여넣은 텍스트가 유효한 JSON가 아닙니다.';

  @override
  String get importErrorNotObject => '잘못된 형식: JSON 개체가 예상됩니다.';

  @override
  String get importErrorMissingCharacter =>
      '잘못된 JSON: \"character\" 필드를 찾을 수 없습니다.';

  @override
  String get importErrorCorruptedCharacter =>
      '캐릭터를 읽을 수 없습니다. JSON이 오래된 앱 버전에서 오거나 지원되지 않는 형식일 수 있습니다.';

  @override
  String charCardLevel(int level) {
    return '레벨 $level';
  }

  @override
  String get charCardPin => '상단에 고정';

  @override
  String get charCardUnpin => '고정 해제';

  @override
  String get charCardChangePhoto => '사진 변경';

  @override
  String get charCardRename => '이름 바꾸기';

  @override
  String get charCardExport => '내보내다';

  @override
  String get charCardDelete => '삭제';

  @override
  String get renameDialogTitle => '캐릭터 이름 바꾸기';

  @override
  String get renameDialogLabel => '이름';

  @override
  String get dialogCancel => '취소';

  @override
  String get dialogSave => '구하다';

  @override
  String get deleteDialogTitle => '캐릭터를 삭제하시겠습니까?';

  @override
  String deleteDialogContent(String name) {
    return '$name 을(를) 삭제하시겠습니까? 이 작업은 취소할 수 없습니다.';
  }

  @override
  String get dialogConfirm => '확인하다';

  @override
  String get dialogDiscard => '버리다';

  @override
  String get dialogContinue => '계속하다';

  @override
  String get dialogKeepEditing => '계속 수정하세요';

  @override
  String get dialogRemove => '제거하다';

  @override
  String get dialogAdd => '추가하다';

  @override
  String get settingsTitle => '설정';

  @override
  String get settingsSectionTheme => '시각적 테마';

  @override
  String get settingsDark => '어두운';

  @override
  String get settingsLight => '빛';

  @override
  String get settingsChooseTheme => '테마를 선택하세요';

  @override
  String get settingsSectionLanguage => '언어';

  @override
  String get settingsAppLanguage => '앱 언어';

  @override
  String get settingsChooseLanguage => '언어를 선택하세요';

  @override
  String get settingsSystemDefault => '시스템 기본값';

  @override
  String get modeSelectionTitle => '새로운 캐릭터';

  @override
  String get modeSelectionQuestion => '캐릭터를 어떻게 만들고 싶나요?';

  @override
  String get modeGuidedTitle => '안내';

  @override
  String get modeGuidedSubtitle =>
      '단계별 마법사. 클래스, 인종, 배경, 기술 및 속성을 한 번에 하나씩 선택하십시오. 신규 플레이어에게 권장됩니다.';

  @override
  String get modeManualTitle => '수동';

  @override
  String get modeManualSubtitle =>
      '모든 것을 직접 작성하십시오. 모든 필드는 무료이며 어떤 값도 계산되지 않습니다. 숙련된 플레이어에게 가장 적합합니다.';

  @override
  String get modeRandomTitle => '무작위의';

  @override
  String get modeRandomSubtitle =>
      '인종, 클래스, 배경, 속성 등 모든 것이 당신을 위해 준비되어 있습니다. 도전이나 원샷에 적합합니다.';

  @override
  String get modeSemiRandomTitle => '준 무작위';

  @override
  String get modeSemiRandomSubtitle =>
      '중요한 선택을 선택하세요. 다른 모든 것은 굴러갑니다. 컨셉이 있지만 놀라움을 원할 때 좋습니다.';

  @override
  String get modeComingSoon => '곧';

  @override
  String get creationStepClass => '수업';

  @override
  String get creationStepRace => '경주';

  @override
  String get creationStepBackground => '배경';

  @override
  String get creationStepSkills => '기술';

  @override
  String get creationStepAttributes => '속성';

  @override
  String get creationStepName => '이름';

  @override
  String get creationStepReview => '검토';

  @override
  String get creationDiscardTitle => '캐릭터를 삭제하시겠습니까?';

  @override
  String get creationDiscardContent => '모든 진행 상황이 손실됩니다. 확실합니까?';

  @override
  String get creationTooltipCancel => '취소';

  @override
  String get creationBack => '뒤쪽에';

  @override
  String get creationCreateCharacter => '캐릭터 생성';

  @override
  String get detailLeaveWithoutSaving => '저장하지 않고 나가시겠습니까?';

  @override
  String get detailChangesWillBeDiscarded =>
      '변경사항이 삭제됩니다. 저장하려면 오른쪽 상단의 ✓ 버튼을 사용하세요.';

  @override
  String get detailLeaveAndDiscard => '떠나서 버리세요';

  @override
  String detailErrorLoading(String error) {
    return '문자 로드 중 오류 발생: $error';
  }

  @override
  String get detailTooltipLongRest => '긴 휴식';

  @override
  String get detailTooltipCancelEdit => '편집 취소';

  @override
  String get detailTooltipDoneEditing => '편집 완료';

  @override
  String get detailTooltipEditCharacter => '캐릭터 편집';

  @override
  String get detailCancelEditTitle => '수정을 취소하시겠습니까?';

  @override
  String get detailCancelEditContent => '모든 변경사항이 삭제됩니다.';

  @override
  String get detailFinishEditTitle => '편집을 마치시겠습니까?';

  @override
  String get detailFinishEditContent => '변경사항이 저장됩니다.';

  @override
  String get detailTabStats => '통계';

  @override
  String get detailTabSkills => '기술';

  @override
  String get detailTabFeatures => '특징';

  @override
  String get detailTabSpells => '주문';

  @override
  String get detailTabInventory => '목록';

  @override
  String get detailTabNotes => '메모';

  @override
  String get longRestTitle => '긴 휴식';

  @override
  String get longRestContent => 'HP를 최대로 회복하고 모든 주문 슬롯을 회복하시겠습니까?';

  @override
  String get longRestButton => '나머지';

  @override
  String get sectionIdentity => '신원';

  @override
  String get sectionHitPoints => '히트 포인트';

  @override
  String get sectionCombat => '전투';

  @override
  String get sectionAbilityScores => '능력 점수';

  @override
  String get sectionSavingThrows => '던지기 숙련도 저장';

  @override
  String get labelName => '이름';

  @override
  String get labelBackground => '배경';

  @override
  String get labelChange => '변화';

  @override
  String get labelAlignment => '조정';

  @override
  String get labelPlayer => '플레이어';

  @override
  String get labelLevel => '수준';

  @override
  String get labelSubclass => '아강';

  @override
  String get labelLanguages => '언어';

  @override
  String get hintAddLanguage => '언어 추가…';

  @override
  String get labelChoose => '선택하다';

  @override
  String get labelMaxHP => '최대 HP';

  @override
  String get labelTempHP => '임시 HP';

  @override
  String get labelAmount => '양';

  @override
  String get labelSpeed => '속도(피트)';

  @override
  String get detailDamage => '손상';

  @override
  String get detailHeal => '치유하다';

  @override
  String get detailNone => '없음';

  @override
  String get tempHpDialogTitle => '임시 HP 추가';

  @override
  String get tempHpDialogTitleReplace => '임시 HP';

  @override
  String tempHpCurrent(int n) {
    return '현재: + $n 임시 HP';
  }

  @override
  String get tempHpNoStack => '임시 HP는 누적되지 않습니다. 더 높은 값만 현재를 대체합니다.';

  @override
  String get tempHpReplace => '바꾸다';

  @override
  String subclassConfirmTitle(String feature) {
    return '$feature 확인';
  }

  @override
  String subclassChooseTitle(String feature) {
    return '$feature를 선택하세요';
  }

  @override
  String subclassConfirmBody(int level, String feature) {
    return '$level 레벨에 도달했습니다. $feature를 확인하거나 변경하세요.';
  }

  @override
  String subclassChooseBody(int level, String feature) {
    return '$level 레벨에 도달했습니다! $feature를 선택하세요.';
  }

  @override
  String get subclassKeepCurrent => '최신 상태 유지';

  @override
  String get subclassChangeTitle => '하위 클래스 변경';

  @override
  String get subclassChangeWarning =>
      '경고: 이전 하위직업이 부여한 주문과 숙련도는 자동으로 제거되지 않습니다. 수동으로 조정해야 합니다.';

  @override
  String get backgroundChooseTitle => '배경 선택';

  @override
  String get featuresTooltipAdd => '기능 추가';

  @override
  String get featuresTooltipRemove => '제거하다';

  @override
  String get featuresTooltipEnable => '활성화';

  @override
  String get featuresTooltipDisable => '비활성화';

  @override
  String get featuresTabClass => '직업';

  @override
  String get featuresTabRacial => '종족';

  @override
  String get featuresTabCustom => '커스텀';

  @override
  String get featuresRemoveTitle => '기능을 삭제하시겠습니까?';

  @override
  String featuresRemoveContent(String name) {
    return '\" $name \"가 제거됩니다.';
  }

  @override
  String get featuresNoneAvailable => '사용할 수 있는 기능이 없습니다.';

  @override
  String get featuresAddLabel => '기능 추가';

  @override
  String get featuresLoadError => '기능을 로드하는 중에 오류가 발생했습니다.';

  @override
  String get hintSearch => '찾다...';

  @override
  String get labelFeatureName => '이름';

  @override
  String get labelFeatureDescription => '설명(선택사항)';

  @override
  String get labelFeatureType => '유형:';

  @override
  String get labelPassive => '수동적인';

  @override
  String get labelActive => '활동적인';

  @override
  String get spellsTooltipAdd => '주문 추가';

  @override
  String get spellsRemoveTitle => '주문을 삭제하시겠습니까?';

  @override
  String spellsRemoveContent(String name) {
    return '주문 목록에서 \" $name \"를 제거하시겠습니까?';
  }

  @override
  String get spellsAtWill => '마음대로';

  @override
  String get notesTooltipAdd => '메모 추가';

  @override
  String get notesTooltipEdit => '메모 수정';

  @override
  String get notesTooltipDelete => '메모 삭제';

  @override
  String get notesDeleteTitle => '메모를 삭제하시겠습니까?';

  @override
  String notesDeleteContentNamed(String title) {
    return '\" $title \"가 영구적으로 삭제됩니다.';
  }

  @override
  String get notesDeleteContent => '이 메모는 영구적으로 삭제됩니다.';

  @override
  String get notesLabelTitle => '제목';

  @override
  String get notesLabelContent => '콘텐츠';

  @override
  String get sectionPersonalityTraits => '성격 특성';

  @override
  String get sectionIdeals => '이상';

  @override
  String get sectionBonds => '채권';

  @override
  String get sectionFlaws => '결함';

  @override
  String get sectionBackstory => '뒷이야기';

  @override
  String inventoryEquippedSection(int count, int ac) {
    return '장착 ( $count ) · AC $ac';
  }

  @override
  String get inventoryTooltipAdd => '항목 추가';

  @override
  String get inventoryTooltipRemove => '제거하다';

  @override
  String get inventoryRemoveTitle => '항목을 삭제하시겠습니까?';

  @override
  String inventoryRemoveContent(String name) {
    return '인벤토리에서 $name를 제거하시겠습니까?';
  }

  @override
  String inventoryRemovePartial(int count, int total) {
    return '제거 예정: $total의 $count';
  }

  @override
  String get inventoryLabelQuantity => '수량:';

  @override
  String get inventoryLabelQuantityToRemove => '제거할 수량';

  @override
  String get inventoryAddCustomItem => '맞춤 항목 추가';

  @override
  String get inventoryAddItem => '항목 추가';

  @override
  String get inventoryLabelItemName => '이름 *';

  @override
  String get inventoryLabelType => '유형';

  @override
  String get inventoryLabelCategory => '범주';

  @override
  String get inventoryLabelItemQuantity => '수량';

  @override
  String get inventoryLabelDescription => '설명(선택사항)';

  @override
  String get inventoryTypeWeapon => '무기';

  @override
  String get inventoryTypeArmor => '갑옷';

  @override
  String get inventoryTypeConsumable => '소모품';

  @override
  String get inventoryTypeGear => '기어';

  @override
  String get inventoryReplaceArmorTitle => '장착된 방어구를 교체하시겠습니까?';

  @override
  String get inventoryTabWeapons => '무기';

  @override
  String get inventoryTabArmor => '갑옷';

  @override
  String get inventoryTabGear => '기어';

  @override
  String get inventoryTabMagic => '마법';

  @override
  String get inventoryTabTools => '도구';

  @override
  String get inventoryTabCustom => '관습';

  @override
  String hintSearchCategory(String category) {
    return '$category 검색 ...';
  }

  @override
  String get stepChooseMethod => '방법을 선택하세요:';

  @override
  String get stepStandardArray => '표준 어레이';

  @override
  String get stepPointBuy => '포인트 구매';

  @override
  String get stepRoll4d6 => '4d6 롤';

  @override
  String get stepDistributeRacialBonuses => '인종 보너스를 자유롭게 배포';

  @override
  String get stepAssignRolls => '각 롤을 속성에 할당합니다.';

  @override
  String get stepAssignValues => '각 값을 하나의 속성에 할당합니다.';

  @override
  String get stepPointsRemaining => '남은 포인트:';

  @override
  String stepRaceBonus(int n) {
    return '+ $n 경주';
  }

  @override
  String get stepChooseSubrace => '하위 경주를 선택하세요:';

  @override
  String get stepGrantedByBackground => '배경에 따라 부여됨:';

  @override
  String stepClassSkillChoices(int count) {
    return '클래스 스킬 선택( $count ):';
  }

  @override
  String get stepChooseOne => '하나를 선택하세요';

  @override
  String get stepSelectTool => '도구를 선택하세요…';

  @override
  String get statAC => '교류';

  @override
  String get statArmor => '갑옷';

  @override
  String get statNoArmor => '갑옷 없음';

  @override
  String get statNoArmorShield => '갑옷 + 방패 없음';

  @override
  String get statShieldSuffix => '+ 방패';

  @override
  String get statSpeed => '속도';

  @override
  String get statInitiative => '계획';

  @override
  String get statProfBonus => '교수 보너스';

  @override
  String get statPassivePerc => '패시브 퍼크';

  @override
  String get statUnconsciousDying => '의식불명 / 사망';

  @override
  String get tooltipAddTempHp => '임시 HP 추가';

  @override
  String get tooltipChangeTempHp => '임시 HP 변경';

  @override
  String get abilityStr => 'STR';

  @override
  String get abilityDex => '덱스';

  @override
  String get abilityCon => '범죄자';

  @override
  String get abilityInt => '정수';

  @override
  String get abilityWis => '위스';

  @override
  String get abilityCha => '차';

  @override
  String featuresSectionRacialTraits(String name) {
    return '인종 특성 — $name';
  }

  @override
  String featuresSectionBackground(String name) {
    return '배경 기능 — $name';
  }

  @override
  String featuresSectionClass(String name) {
    return '클래스 기능 — $name';
  }

  @override
  String featuresSectionSubclass(String name) {
    return '하위 클래스 기능 — $name';
  }

  @override
  String get featuresSectionTools => '도구 숙련도';

  @override
  String get featuresSectionExtra => '추가 기능';

  @override
  String get spellsNoSpellcasting => '주문 시전 금지';

  @override
  String get spellsNoSpellcastingDesc => '이 클래스에는 주문 시전 기능이 없습니다.';

  @override
  String get spellsSlots => '주문 슬롯';

  @override
  String get spellsSpellcasting => '주문 시전';

  @override
  String get spellsAttack => '공격';

  @override
  String get spellsSaveDC => 'DC 저장';

  @override
  String get spellsCantrips => '캔트립';

  @override
  String get spellsPrepared => '준비됨';

  @override
  String get spellsKnown => '알려진';

  @override
  String get spellsEmpty => '아직 추가된 주문이 없습니다.\n주문을 찾아보려면 +를 탭하세요.';

  @override
  String spellsSlotLevel(int level) {
    return '레벨 $level';
  }

  @override
  String spellsLevelN(int level) {
    return '레벨 $level';
  }

  @override
  String get inventoryCurrency => '통화';

  @override
  String inventoryCarriedSection(int count) {
    return '운반됨( $count )';
  }

  @override
  String get inventoryInventory => '목록';

  @override
  String get inventoryEmpty => '아직 항목이 없습니다. 추가하려면 +를 탭하세요.';

  @override
  String get inventoryAmmunition => '탄약';

  @override
  String get coinCopper => '구리';

  @override
  String get coinSilver => '은';

  @override
  String get coinElectrum => '일렉트럼';

  @override
  String get coinGold => '금';

  @override
  String get coinPlatinum => '백금';

  @override
  String get inventoryGroupSimpleMelee => '단순 근접전';

  @override
  String get inventoryGroupSimpleRanged => '단순 원거리';

  @override
  String get inventoryGroupMartialMelee => '무술 근접전';

  @override
  String get inventoryGroupMartialRanged => '무술 원거리';

  @override
  String get inventoryGroupLightArmor => '가벼운 갑옷';

  @override
  String get inventoryGroupMediumArmor => '중간 갑옷';

  @override
  String get inventoryGroupHeavyArmor => '중갑';

  @override
  String get inventoryGroupShields => '방패';

  @override
  String get inventoryGroupAdventuringGear => '모험 장비';

  @override
  String get inventoryGroupAmmunition => '탄약';

  @override
  String get inventoryGroupArcaneFocus => '비전 집중 장치';

  @override
  String get inventoryGroupClothing => '의류';

  @override
  String get inventoryGroupContainer => '컨테이너';

  @override
  String get inventoryGroupPoison => '독';

  @override
  String get inventoryGroupPotions => '물약';

  @override
  String get inventoryGroupRings => '반지';

  @override
  String get inventoryGroupWands => '지팡이';

  @override
  String get inventoryGroupWeapons => '무기';

  @override
  String get inventoryGroupArmor => '갑옷';

  @override
  String get inventoryGroupWondrousItems => '놀라운 아이템';

  @override
  String get inventoryGroupArtisansTools => '장인의 도구';

  @override
  String get inventoryGroupGamingSets => '게임 세트';

  @override
  String get inventoryGroupMusicalInstruments => '악기';

  @override
  String get inventoryGroupOtherTools => '기타 도구';

  @override
  String get armorStealthDisadvantage => '스텔스 단점';

  @override
  String get spellDetailCastingTime => '캐스팅 시간';

  @override
  String get spellDetailRange => '범위';

  @override
  String get spellDetailDuration => '지속';

  @override
  String get spellDetailComponents => '구성요소';

  @override
  String get spellDetailConcentration => '집중력이 필요함';

  @override
  String get spellDetailRitual => '의식으로 시전 가능';

  @override
  String get spellDetailAtHigherLevels => '더 높은 수준에서.';

  @override
  String spellDetailClasses(String classes) {
    return '클래스: $classes';
  }

  @override
  String spellDetailLevelSchool(String ordinal, String school) {
    return '$ordinal -레벨 $school';
  }

  @override
  String spellDetailCantrip(String school) {
    return '$school 캔트립';
  }

  @override
  String armorSwapCurrent(String name) {
    return '현재: $name';
  }

  @override
  String armorSwapAcNow(int ac) {
    return '현재 AC: $ac';
  }

  @override
  String armorSwapAcAfter(int ac) {
    return '이후 AC: $ac';
  }

  @override
  String get armorSwapButton => '갑옷 교환';

  @override
  String get reviewRowName => '이름';

  @override
  String get reviewUnnamedHero => '이름 없는 영웅';

  @override
  String get reviewRowPlayer => '플레이어';

  @override
  String get reviewRowSubclass => '아강';

  @override
  String get reviewRowHitDie => '히트 다이';

  @override
  String get reviewRowSavingThrows => '던지기 저장';

  @override
  String get reviewRowSubrace => '서브레이스';

  @override
  String get reviewRowSpeed => '속도';

  @override
  String get reviewRowLanguages => '언어';

  @override
  String get reviewRowFeature => '특징';

  @override
  String get reviewRowFromBackground => '배경에서';

  @override
  String get reviewRowClassChoices => '클래스 선택';

  @override
  String get reviewRowMaxHp => '최대 HP';

  @override
  String get reviewRowAcUnarmored => 'AC(비무장)';

  @override
  String reviewRowAcWith(String name) {
    return '$name를 갖춘 AC';
  }

  @override
  String get reviewRowProficiencyBonus => '숙련도 보너스';

  @override
  String get reviewStartingGold => '골드 시작';

  @override
  String get reviewStartingEquipment => '시동 장비';

  @override
  String get reviewDeselectAll => '모두 선택 취소';

  @override
  String get reviewSelectAll => '모두 선택';

  @override
  String get reviewUncheckHint => '인벤토리에 추가하고 싶지 않은 항목을 선택 취소하세요.';

  @override
  String get reviewEquipmentChoices => '장비 선택';

  @override
  String get reviewEquipmentChoicesHint => '각 슬롯에 대한 특정 항목을 선택하십시오.';

  @override
  String get reviewToolProficiencies => '도구 숙련도';

  @override
  String get reviewChooseToolProficiency => '도구 숙련도를 선택하세요.';

  @override
  String reviewChooseLanguages(int count) {
    return '인종이나 배경에 따라 부여된 $count 언어를 선택하세요.';
  }

  @override
  String get reviewChooseOne => '하나를 선택하세요:';

  @override
  String get stepTashaRule => 'Tasha의 선택적 규칙 - 모든 속성에 ASI 포인트 할당';

  @override
  String get stepRollDice => '주사위 굴리기';

  @override
  String get stepReroll => '재굴림';

  @override
  String get stepRollHint => '굴려서 6개의 값을 생성합니다(4d6, 가장 낮은 값으로 떨어짐).';

  @override
  String get stepPrimaryAbilities => '주요 능력:';

  @override
  String get stepNameTitle => '캐릭터에게 이름을 지어주세요.';

  @override
  String get stepNameHint => '나중에 언제든지 변경할 수 있습니다.';

  @override
  String get stepNameCharLabel => '캐릭터 이름';

  @override
  String get stepNamePlayerLabel => '플레이어 이름(선택사항)';

  @override
  String get stepHitDieLabel => '죽어라';

  @override
  String get stepSavesLabel => '저장';

  @override
  String get stepSpellcastingLabel => '주문 시전';

  @override
  String get stepOptionsLabel => '옵션';

  @override
  String stepChooseSubclassPrompt(String feature, int level) {
    return '$feature(Lv $level)을 선택하세요:';
  }

  @override
  String get stepRaceSpeedLabel => '속도';

  @override
  String get stepRaceASILabel => 'ASI';

  @override
  String stepRaceSubracesAvailable(int count) {
    return '$count개의 하위 경주 사용 가능';
  }

  @override
  String stepChooseSkillsHint(int count) {
    return '클래스 목록에서 $count개의 기술을 선택하세요.';
  }

  @override
  String get abilityStrength => '힘';

  @override
  String get abilityDexterity => '재치';

  @override
  String get abilityConstitution => '헌법';

  @override
  String get abilityIntelligence => '지능';

  @override
  String get abilityWisdom => '지혜';

  @override
  String get abilityCharisma => '카리스마';

  @override
  String stepFreeAsiRemaining(int remaining) {
    return '인종별 ASI 포인트를 자유롭게 배포하세요($remaining 남음):';
  }

  @override
  String stepFreePicksRemaining(int total, int remaining) {
    return '인종 자유 ASI: $total 속성에 +1 할당($remaining 남음):';
  }

  @override
  String get stepFreePicksNoStack => '이미 인종 보너스를 받고 있는 속성에는 할당할 수 없습니다.';

  @override
  String reviewClassEquipmentTitle(String name) {
    return '직업 장비 — $name';
  }

  @override
  String get reviewEquipmentIncluded => '포함:';

  @override
  String get stepToolCategoryGamingSet => '게임 세트';

  @override
  String get stepToolCategoryInstrument => '악기';

  @override
  String get stepToolCategoryArtisanTool => '장인의 도구';

  @override
  String get stepToolCategoryArtisanOrInstrument => '장인의 도구 또는 도구';

  @override
  String exportCopied(String label) {
    return '$label 복사됨!';
  }

  @override
  String exportDialogTitle(String name) {
    return '$name 내보내기';
  }

  @override
  String get exportLabelToken => '토큰';

  @override
  String get exportCopyToken => '토큰 복사';

  @override
  String get exportHideQr => 'QR 코드 숨기기';

  @override
  String get exportShowQr => 'QR 코드 표시';

  @override
  String get exportQrTooLarge =>
      '캐릭터가 QR 코드에 비해 너무 큽니다.\n토큰 또는 JSON을 사용하여 공유하세요.';

  @override
  String get exportShowJson => 'JSON 표시';

  @override
  String get exportCopyJson => 'JSON 복사';

  @override
  String get dialogClose => '닫기';

  @override
  String get importDialogTitle => '캐릭터 가져오기';

  @override
  String get importTokenHint => '여기에 토큰 붙여넣기…';

  @override
  String get importScanQr => 'QR 코드 스캔';

  @override
  String get importUseJson => 'JSON 직접 사용';

  @override
  String get importJsonHint => '여기에 JSON 붙여넣기…';

  @override
  String get dialogImport => '가져오기';

  @override
  String get spellBrowserTitle => '주문 검색';

  @override
  String get spellBrowserFilters => '필터';

  @override
  String get spellBrowserSearchHint => '주문 검색...';

  @override
  String get filterClearAll => '모두 지우기';

  @override
  String get loadingLabel => '로딩 중...';

  @override
  String spellBrowserCount(int count, String s) {
    return '주문 $count개';
  }

  @override
  String get spellBrowserEmpty => '현재 필터와 일치하는 주문이 없습니다.';

  @override
  String get spellCantrip => '소마법';

  @override
  String spellLevelN(int n) {
    return '$n레벨';
  }

  @override
  String get castingTimeAction => '행동';

  @override
  String get castingTimeBonusAction => '추가 행동';

  @override
  String get castingTimeReaction => '반응';

  @override
  String get castingTimeLonger => '긴 시전';

  @override
  String get filterConcentration => '집중';

  @override
  String get filterRitual => '의식';

  @override
  String get filterAllLevels => '모든 레벨';

  @override
  String get avatarChoosePhoto => '사진 선택';

  @override
  String get avatarRemovePhoto => '사진 제거';

  @override
  String get avatarCropPhoto => '사진 자르기';

  @override
  String get avatarChangePhoto => '사진 변경';

  @override
  String featureAddedSnackbar(String name) {
    return '$name 추가됨!';
  }

  @override
  String get featureAddButton => '특성 추가';

  @override
  String get reviewLanguageChoices => '언어 선택';

  @override
  String get reviewLanguageTypeHint => '언어 입력…';
}
