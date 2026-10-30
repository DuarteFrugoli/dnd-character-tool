// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class AppLocalizationsKo extends AppLocalizations {
  AppLocalizationsKo([String locale = 'ko']) : super(locale);

  @override
  String get creationRulesetTitle => '규칙 선택';

  @override
  String get creationRuleset2014 => 'D&D 5e (2014)';

  @override
  String get creationRuleset2024 => 'D&D 5.5e (2024)';

  @override
  String get rulesetShort2014 => '5e';

  @override
  String get rulesetShort2024 => '5.5e';

  @override
  String get customBackgroundTitle => '사용자 지정 배경';

  @override
  String get customBackgroundSubtitle => '규칙에 따라 나만의 배경 만들기';

  @override
  String get customBackgroundName => '배경 이름';

  @override
  String get customBackgroundFeature => '배경 특징';

  @override
  String customBackgroundSkills(int count) {
    return '기술 $count개 선택';
  }

  @override
  String customBackgroundTools2014(int count) {
    return '도구를 최대 $count개 선택하세요. 나머지는 언어가 됩니다';
  }

  @override
  String customBackgroundLanguages(int count) {
    return '나중에 고를 언어: $count';
  }

  @override
  String get customBackgroundEquipment2014 => '장비 꾸러미';

  @override
  String customBackgroundAbilities(int count) {
    return '능력치 상승에 쓸 능력치 $count개 선택';
  }

  @override
  String get customBackgroundTool2024 => '다른 숙련과 함께 아무 종류의 도구 1개를 선택합니다.';

  @override
  String customBackgroundGold2024(int gp) {
    return '장비: ${gp}GP 사용';
  }

  @override
  String get customBackgroundSave => '이 배경 사용';

  @override
  String get wildShapeTitle => '야생 변신';

  @override
  String wildShapeUses(int current, int max) {
    return '사용 횟수: $current/$max';
  }

  @override
  String get wildShapeUsesUnlimited => '사용 횟수: 무제한';

  @override
  String wildShapeLimits(String cr) {
    return '도전 지수 $cr까지의 형태';
  }

  @override
  String get wildShapeNoFly => '비행 속도 없음';

  @override
  String get wildShapeNoSwim => '수영 속도 없음';

  @override
  String wildShapeChallengeRating(String cr) {
    return '도전 지수 $cr';
  }

  @override
  String wildShapeKnownForms(int count, int max) {
    return '알고 있는 형태: $count/$max';
  }

  @override
  String get wildShapeChooseForms => '특성 탭의 야생 변신에서 알고 있는 형태를 고르세요.';

  @override
  String get wildShapeAssume => '형태 취하기';

  @override
  String get wildShapeLeave => '형태 해제';

  @override
  String get wildShapeNoUsesLeft => '남은 야생 변신 사용 횟수가 없습니다. 휴식으로 회복됩니다.';

  @override
  String get wildShapeSearch => '야수 검색';

  @override
  String get wildShapeSeenNote => '이전에 본 적 있는 야수를 고르세요.';

  @override
  String wildShapeConfirmTitle(String name) {
    return '$name 형태를 취할까요?';
  }

  @override
  String wildShapeConfirmUse(int current, int after, int max) {
    return '야생 변신 1회 사용: $max회 중 $current → $after.';
  }

  @override
  String get wildShapeConfirmUnlimited => '현재 레벨에서는 야생 변신 사용 횟수 제한이 없습니다.';

  @override
  String get wildShapeConfirmReplace => '현재 형태를 대체합니다.';

  @override
  String wildShapeConfirmFormHp(int amount) {
    return '이 형태는 히트 포인트가 $amount입니다. 0이 되면 원래 모습으로 돌아오고 남은 피해는 당신이 받습니다.';
  }

  @override
  String wildShapeConfirmTempHp(int amount) {
    return '임시 히트 포인트 $amount을 얻습니다.';
  }

  @override
  String wildShapeConfirmTempHpKept(int current, int gain) {
    return '현재 임시 히트 포인트 $current을 유지합니다. 형태의 $gain과 합쳐지지 않습니다.';
  }

  @override
  String wildShapeConfirmDuration(int hours) {
    String _temp0 = intl.Intl.pluralLogic(
      hours,
      locale: localeName,
      other: '$hours시간',
      one: '1시간',
    );
    return '최대 $_temp0 또는 더 일찍 끝날 때까지 지속됩니다.';
  }

  @override
  String get wildShapeConfirmKeeps2024 =>
      '히트 포인트, 히트 다이스, 지능, 지혜, 매력, 클래스 특성, 언어, 재주, 숙련을 유지합니다. 주문은 시전할 수 없지만 집중은 계속됩니다.';

  @override
  String get wildShapeConfirmKeeps2014 =>
      '지능, 지혜, 매력, 성향, 성격, 숙련을 유지합니다. 주문은 시전할 수 없지만 집중은 계속됩니다.';

  @override
  String get wildShapeConfirm => '형태 취하기';

  @override
  String wildShapeActive(String name) {
    return '$name 형태';
  }

  @override
  String wildShapeFormHp(int current, int max) {
    return '형태 HP $current/$max';
  }

  @override
  String get wildShapeScoresNote => '근력, 민첩, 건강은 형태의 값이고 지능, 지혜, 매력은 당신의 값입니다.';

  @override
  String get wildShapeAttacks => '형태의 공격';

  @override
  String get wildShapeAttackRoll => '명중 굴림';

  @override
  String get wildShapeStatBlock => '능력치 블록';

  @override
  String wildShapeLeaveTitle(String name) {
    return '$name 형태를 해제할까요?';
  }

  @override
  String get wildShapeLeaveBody2024 => '원래 모습으로 돌아옵니다. 야생 변신 사용 횟수는 돌려받지 못합니다.';

  @override
  String get wildShapeLeaveBody2014 =>
      '변신 전의 히트 포인트로 원래 모습으로 돌아옵니다. 형태의 남은 히트 포인트와 야생 변신 사용 횟수는 사라집니다.';

  @override
  String get wildShapeDamageToForm => '피해와 치유는 먼저 야생 변신 형태에 적용됩니다.';

  @override
  String get changesKindWildShapeForms => '야생 변신의 알고 있는 형태';

  @override
  String get changesWildShapeEnds => '현재 형태가 끝납니다.';

  @override
  String get monsterSizeTiny => '초소형';

  @override
  String get monsterSizeSmall => '소형';

  @override
  String get monsterSizeMedium => '중형';

  @override
  String get monsterSizeLarge => '대형';

  @override
  String get monsterSizeHuge => '초대형';

  @override
  String get monsterSizeGargantuan => '거대형';

  @override
  String get monsterSizeOr => ' 또는 ';

  @override
  String monsterSizeType(String size, String type) {
    return '$size $type';
  }

  @override
  String get monsterTypeBeast => '야수';

  @override
  String monsterSwarmOfBeasts(String size) {
    return '야수 무리 (개체 $size)';
  }

  @override
  String get monsterSpeedBurrow => '굴착';

  @override
  String get monsterSpeedClimb => '등반';

  @override
  String get monsterSpeedFly => '비행';

  @override
  String get monsterSpeedSwim => '수영';

  @override
  String get monsterSpeedHover => '(부양)';

  @override
  String monsterSpeedChoice(String first, String second, String distance) {
    return '$first 또는 $second $distance (DM 선택)';
  }

  @override
  String get monsterSavingThrows => '내성 굴림';

  @override
  String get monsterSkills => '기술';

  @override
  String get monsterVulnerabilities => '취약';

  @override
  String get monsterResistances => '저항';

  @override
  String get monsterImmunities => '면역';

  @override
  String get monsterConditionImmunities => '상태 면역';

  @override
  String get monsterSenses => '감각';

  @override
  String get monsterSenseBlindsight => '맹안시야';

  @override
  String get monsterSenseDarkvision => '암시야';

  @override
  String get monsterSenseTremorsense => '진동감지';

  @override
  String get monsterSenseTruesight => '진시야';

  @override
  String get monsterLanguages => '언어';

  @override
  String get monsterLanguagesNone => '없음';

  @override
  String get monsterChallenge => '도전 지수';

  @override
  String monsterChallengeValue(String cr, String xp, int pb) {
    return '$cr (XP $xp; 숙련 보너스 +$pb)';
  }

  @override
  String get monsterTraits => '특징';

  @override
  String get monsterActions => '행동';

  @override
  String get monsterBonusActions => '추가 행동';

  @override
  String get monsterReactions => '반응';

  @override
  String get monsterLegendaryActions => '전설적 행동';

  @override
  String monsterRecharge(int min) {
    return '재충전 $min–6';
  }

  @override
  String monsterPerDay(int uses) {
    return '하루 $uses회';
  }

  @override
  String get creation2024Species => '종족';

  @override
  String get creation2024Size => '크기';

  @override
  String get creation2024SizeSmall => '소형';

  @override
  String get creation2024SizeMedium => '중형';

  @override
  String get creation2024OriginFeat => '출신 특기';

  @override
  String get creation2024StandardArray =>
      '15, 14, 13, 12, 10, 8을 각각 한 번씩 배분하세요.';

  @override
  String get creation2024OriginBonuses => '배경 능력치 증가';

  @override
  String get creation2024BonusTwoOne => '+2와 +1';

  @override
  String get creation2024BonusThree => '세 능력치에 +1';

  @override
  String get creation2024Languages => '공용어 외에 언어 두 개 선택';

  @override
  String get creation2024ClassEquipment => '직업 장비';

  @override
  String get creation2024BackgroundEquipment => '배경 장비';

  @override
  String get creation2024SpecificTool => '도구 선택';

  @override
  String get creation2024PrepareSpells => '주문책에서 주문 네 개 준비';

  @override
  String get character2024ReadOnlyNotice =>
      '2024년 캐릭터 시트는 아직 통합 중입니다. 현재는 시트 조회와 메모, 초상화, 기본 주사위 굴림을 사용할 수 있습니다.';

  @override
  String get appTitle => 'DnD 캐릭터 도구';

  @override
  String get charListTitle => 'DnD 캐릭터';

  @override
  String get charListImportTooltip => '캐릭터 또는 백업 가져오기';

  @override
  String get charListSettingsTooltip => '설정';

  @override
  String get charListNewCharacter => '새로운 캐릭터';

  @override
  String get charListEmpty => '아직 문자가 없습니다.';

  @override
  String get charListEmptyHint => '+를 탭하여 첫 번째 캐릭터를 생성하세요';

  @override
  String get whatsNewTitle => '새로운 기능';

  @override
  String whatsNewVersionSubtitle(String version) {
    return '버전 $version';
  }

  @override
  String get whatsNewIntro => '다음 세션에 유용한 개선 사항이 준비되었습니다.';

  @override
  String get whatsNewContextualRollsTitle => '상황별 굴림';

  @override
  String get whatsNewContextualRollsBody =>
      '능력치, 기술, 내성, 무기, 단순 주문을 캐릭터 시트에서 바로 굴릴 수 있습니다.';

  @override
  String get whatsNewCriticalsTitle => '치명타 옵션';

  @override
  String get whatsNewCriticalsBody =>
      '치명타 피해 계산 방식을 선택하고, 필요할 때 이점과 불리점 옵션을 확인할 수 있습니다.';

  @override
  String get whatsNewConfirmationsTitle => '더 명확한 확인';

  @override
  String get whatsNewConfirmationsBody =>
      '안전한 작업과 삭제 같은 위험한 작업을 더 쉽게 구분할 수 있습니다.';

  @override
  String get whatsNewDone => '확인';

  @override
  String get whatsNewSummary =>
      '이제 터키어를 지원하고, SRD 5.1 마법 아이템이 늘었으며, 캐릭터 업데이트 과정도 더 명확해졌습니다. D&D 2024 지원은 개발 중입니다.';

  @override
  String get whatsNewTurkishTitle => '터키어 지원';

  @override
  String get whatsNewTurkishBody => '앱 화면과 SRD 5.1 게임 콘텐츠를 터키어로 이용할 수 있습니다.';

  @override
  String get whatsNewMagicItemsTitle => '마법 아이템 추가';

  @override
  String get whatsNewMagicItemsBody =>
      'SRD 5.1 마법 아이템이 추가되었고, 지원 언어에서 누락되었던 번역도 보완했습니다.';

  @override
  String get whatsNewCharacterUpdatesTitle => '더 명확해진 캐릭터 업데이트';

  @override
  String get whatsNewCharacterUpdatesBody =>
      '캐릭터를 업데이트해야 할 때는 먼저 캐릭터를 백업한 뒤 모두 업데이트하거나 취소할 수 있습니다. 업데이트를 마칠 때까지 해당 캐릭터 시트는 열리지 않습니다.';

  @override
  String get whatsNew2024Title => 'D&D 2024 개발 중';

  @override
  String get whatsNew2024Body =>
      '2014년 규칙의 캐릭터를 계속 사용할 수 있도록 하면서, 클래스, 서브클래스, 종족, 주문, 장비, 마법 아이템을 업데이트한 별도의 2024년 규칙 모드를 개발하고 있습니다. 선택형 안내 변환 기능도 계획 중입니다. 2024년 규칙으로 캐릭터를 생성하거나 변환하는 기능은 아직 제공되지 않습니다.';

  @override
  String get whatsNewSettingsSubtitle => '최신 소식을 다시 읽어보세요.';

  @override
  String get creditsTitle => '크레딧 및 라이선스';

  @override
  String get creditsSettingsSubtitle => 'SRD 5.1 및 SRD 5.2.1 고지';

  @override
  String get creditsIntro =>
      '규칙과 게임 콘텐츠는 Wizards of the Coast가 공개한 System Reference Documents에서 가져왔습니다. 라이선스에 따라 아래 고지를 영어 원문 그대로 표시합니다.';

  @override
  String get creditsEdition2014 => 'D&D 5e (2014)';

  @override
  String get creditsEdition2024 => 'D&D 5.5e (2024)';

  @override
  String creditsLicense(String license) {
    return '라이선스: $license';
  }

  @override
  String get creditsSource => '공식 출처';

  @override
  String get creditsUnavailable => '이 고지를 불러올 수 없습니다.';

  @override
  String get creditsNotAffiliated =>
      '이 앱은 Wizards of the Coast LLC와 제휴하지 않았으며, 해당 회사의 보증, 후원 또는 특별한 승인을 받지 않았습니다.';

  @override
  String get creditsCopyright => '© 2026 Pedro Frugoli. All rights reserved.';

  @override
  String weaponMasteryNoteTitle(String name) {
    return '숙달: $name';
  }

  @override
  String weaponMasteryGrazeValue(int damage, String type) {
    return '빗나가면: $type 피해 $damage.';
  }

  @override
  String weaponMasteryToppleValue(int dc) {
    return '내성 DC $dc.';
  }

  @override
  String weaponMasteryCleaveValue(String bonus, String damage) {
    return '두 번째 공격: 명중 $bonus, 피해 $damage.';
  }

  @override
  String get weaponMasteryTacticalMasterTitle => '전술의 달인';

  @override
  String weaponMasteryTacticalMaster(String options) {
    return '이 공격에는 대신 $options을(를) 사용할 수 있습니다.';
  }

  @override
  String agonizingBlastNote(int bonus) {
    return '매력 수정치(+$bonus)가 피해에 더해집니다.';
  }

  @override
  String get eldritchBlastBeamsTitle => '광선';

  @override
  String eldritchBlastBeams(int count) {
    return '광선 $count개: 각각 따로 명중 굴림과 피해 굴림을 합니다.';
  }

  @override
  String get whatsNewThanks =>
      '게임을 즐기고 의견을 나눠 주셔서 감사합니다. 여러분의 아이디어가 앞으로의 개발에 큰 도움이 됩니다.';

  @override
  String get whatsNew3Summary =>
      'D&D 2024(5.5e)가 왔습니다. 2014 캐릭터와 함께 SRD 5.2.1 규칙으로 캐릭터를 만들고 성장시키세요.';

  @override
  String get whatsNew3RulesTitle => 'D&D 2024 규칙';

  @override
  String get whatsNew3RulesBody =>
      '캐릭터를 만들 때 D&D 5e(2014) 또는 5.5e(2024)를 선택하세요. 2024 캐릭터는 하위 클래스, 재주, 에픽 부운, 멀티클래스, 무기 숙련과 함께 1레벨부터 20레벨까지 성장합니다.';

  @override
  String get whatsNew3RestsTitle => '휴식과 상태';

  @override
  String get whatsNew3RestsBody =>
      '2024에서는 긴 휴식으로 모든 히트 다이스를 회복하고 탈진이 1단계 줄어듭니다. 탈진은 d20 굴림과 이동속도에 영향을 주며, 짧은 휴식에는 Arcane Recovery 같은 능력을 쓸 수 있습니다.';

  @override
  String get whatsNew3ResetTitle => '더 안전한 레벨 초기화';

  @override
  String get whatsNew3ResetBody =>
      '저장하기 전에 모든 변경 사항을 보여 줍니다. 초기화는 제거된 클래스가 준 것을 되돌리며, 두 규칙 모두 이전 레벨까지 다시 구성할 수 있습니다.';

  @override
  String get whatsNew3UpdateTitle => '한 번만 하는 캐릭터 업데이트';

  @override
  String get whatsNew3UpdateBody =>
      '캐릭터를 열면 앱이 모든 캐릭터의 업데이트를 요청하고 먼저 백업을 엽니다. 2014 캐릭터는 규칙과 데이터를 유지하고, 2024 캐릭터는 레벨 업과 초기화에 쓰는 레벨 기록을 저장합니다.';

  @override
  String charListImportedSuccess(String name) {
    return '$name를 성공적으로 가져왔습니다!';
  }

  @override
  String charListDuplicatedSuccess(String name) {
    return '$name 복제 완료!';
  }

  @override
  String get charListImportError => '가져오는 동안 예상치 못한 오류가 발생했습니다. 다시 시도해 주세요.';

  @override
  String get charListDuplicateError => '캐릭터를 복제할 수 없습니다. 다시 시도해 주세요.';

  @override
  String get importErrorInvalidJson => '붙여넣은 JSON이 유효하지 않습니다.';

  @override
  String get importFieldLockedHint => '이 필드를 사용하려면 다른 필드를 지우세요.';

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
  String get charCardDuplicate => '복제';

  @override
  String get charCardExport => '내보내다';

  @override
  String get charCardDelete => '삭제';

  @override
  String charDuplicateName(String name) {
    return '$name (복사본)';
  }

  @override
  String charDuplicateNameNumbered(String name, int number) {
    return '$name (복사본 $number)';
  }

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
  String get dialogDone => '완료';

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
  String get characterActionRollDice => '주사위 굴리기';

  @override
  String get characterActionResetLevels => '레벨 초기화';

  @override
  String get characterActionConvert2024 => 'D&D 2024로 변환';

  @override
  String get convert2024Title => 'D&D 2024로 변환';

  @override
  String convert2024Intro(String name) {
    return '$name을(를) 바탕으로 새 D&D 2024(5.5e) 시트를 만듭니다. 2014 시트는 그대로 남습니다.';
  }

  @override
  String get convert2024Kept => '유지: 이름, 외모, 성격, 배경 이야기, 메모, 소지품, 돈, 경험치.';

  @override
  String convert2024Chosen(String classes) {
    return '2024 규칙으로 다시 선택: 종족, 능력치 상승과 출신 재주가 있는 배경, 각 레벨의 선택. $classes까지 한 레벨씩 다시 구성합니다.';
  }

  @override
  String get convert2024Reset => '새 시트는 히트 포인트가 가득 찬 상태로, 상태 이상 없이 시작합니다.';

  @override
  String get convert2024Start => '변환 시작';

  @override
  String get convert2024ScoresFromSheet => '2014 시트';

  @override
  String get convert2024ScoresHint =>
      '2014 시트의 값에서 종족 보너스와 기록된 레벨 상승을 뺀 값입니다. 2024 배경의 상승은 아래에서 더하고, 재주는 레벨업에서 다시 고릅니다.';

  @override
  String get convert2024ScoresUnknown =>
      '일부 상승을 확인할 수 없습니다(직접 고른 종족 보너스 또는 레벨 기록 이전에 얻은 레벨). 이 값을 확인하세요.';

  @override
  String get convert2024InventoryKept => '시작 장비 대신 2014 시트의 소지품과 돈을 유지합니다.';

  @override
  String get convert2024Confirm => '변환';

  @override
  String convert2024Done(String name) {
    return '$name이(가) D&D 2024로 변환되었습니다.';
  }

  @override
  String get convert2024Cancelled => '변환이 취소되었습니다. 아무것도 저장되지 않았습니다.';

  @override
  String convert2024ChooseSpecies(String race) {
    return '$race에 해당하는 D&D 2024 종족이 없습니다. 캐릭터와 가장 가까운 종족을 고르세요.';
  }

  @override
  String convert2024ChooseBackground(String background) {
    return '$background은(는) D&D 2024 배경이 아닙니다. 배경을 고르거나 사용자 지정 배경을 만드세요.';
  }

  @override
  String get diceExpressionLabel => '식';

  @override
  String get diceExpressionHint => '예: 1d20+5 또는 4d6dl1';

  @override
  String get diceExpressionHelpTooltip => '주사위 식 사용 방법';

  @override
  String get diceExpressionHelpTitle => '주사위 식';

  @override
  String get diceExpressionHelpBody =>
      'XdY로 주사위를 굴립니다: 2d6은 6면체 주사위 2개를 굴립니다.\n수정치를 더하거나 뺄 수 있습니다: 1d20+5 또는 2d6 - 1.\nd% 또는 d100은 백분율 주사위입니다.\nd20 이점/불리점: 2d20kh1은 높은 값을 남기고, 2d20kl1은 낮은 값을 남깁니다.\nkh, kl, dh, dl로 주사위를 남기거나 버릴 수 있습니다. 예: 4d6dl1은 d6 4개를 굴리고 가장 낮은 값을 버립니다.\n공백은 선택 사항입니다: 2d6+1d8과 2d6 + 1d8 모두 작동합니다.';

  @override
  String get diceQuantityLabel => '개수';

  @override
  String get diceModifierLabel => '수정치';

  @override
  String get diceRollButton => '굴리기';

  @override
  String get diceRerollButton => '다시 굴리기';

  @override
  String get diceModeNormal => '일반';

  @override
  String get diceModeAdvantage => '이점';

  @override
  String get diceModeDisadvantage => '불리점';

  @override
  String get diceResultTitle => '결과';

  @override
  String get diceHistoryTitle => '최근 굴림';

  @override
  String get diceNoRollsYet => '아직 굴림이 없습니다.';

  @override
  String get diceNaturalOne => '내추럴 1';

  @override
  String get diceNaturalTwenty => '내추럴 20';

  @override
  String get contextualRollCriticalApplied => '치명타 적용됨';

  @override
  String get contextualRollVersatileGrip => '무기 사용 방식';

  @override
  String get contextualRollVersatileOneHanded => '한 손';

  @override
  String get contextualRollVersatileTwoHanded => '두 손';

  @override
  String diceInvalidExpression(String message) {
    return '잘못된 주사위 식: $message';
  }

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
  String get detailTabIdentity => '신원';

  @override
  String get detailEditButton => '편집';

  @override
  String get skillsEditHint => '길게 눌러 전환: 없음 → 숙련 → 전문가';

  @override
  String get skillsOrganizeTooltip => '정리';

  @override
  String get skillsDisplayTitle => '기술 표시';

  @override
  String get skillsDisplayModeLabel => '레이아웃';

  @override
  String get skillsDisplayByAbility => '능력치별';

  @override
  String get skillsDisplayProficiencyFirst => '숙련 우선';

  @override
  String get skillsDisplayAlphabetical => '가나다순';

  @override
  String get skillsDisplayAbilityOrder => '능력치 순서';

  @override
  String get skillsDisplayProficientFirstInsideGroups => '그룹 안에서 숙련 우선';

  @override
  String get skillsDisplayRestoreDefault => '기본값 복원';

  @override
  String get skillsDisplayProficientSection => '숙련';

  @override
  String get skillsDisplayOtherSection => '다른 기술';

  @override
  String get skillsDisplayAllSection => '모든 기술';

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
  String get restPickerTitle => '휴식';

  @override
  String get restPickerShort => '짧은 휴식';

  @override
  String get restPickerShortCaption => '히트 다이스를 써서 HP 회복';

  @override
  String get restPickerLong => '긴 휴식';

  @override
  String get restPickerLongCaption => 'HP와 주문 슬롯 전체 회복';

  @override
  String get shortRestTitle => '짧은 휴식';

  @override
  String get shortRestAvailableDice => '사용 가능한 히트 다이스';

  @override
  String get shortRestSpend => '사용';

  @override
  String get shortRestRolled => '회복된 HP';

  @override
  String get shortRestRollButton => '굴리기';

  @override
  String get shortRestButton => '휴식하기';

  @override
  String get shortRestNoDice => '남은 히트 다이스 없음';

  @override
  String get shortRestRecoveryTitle => '회복 능력';

  @override
  String shortRestRecoverySlotsHint(int levels) {
    return '소모한 주문 슬롯을 합계 $levels레벨까지 회복합니다(6레벨 이상 불가).';
  }

  @override
  String shortRestRecoveryPointsHint(int points) {
    return '최대 $points포인트를 회복합니다.';
  }

  @override
  String get exhaustionLevelTitle => '탈진 단계';

  @override
  String exhaustionEffects(String penalty, String distance) {
    return 'd20 판정 $penalty · 이동속도 −$distance';
  }

  @override
  String get exhaustionLethal => '6단계에서 캐릭터가 사망합니다.';

  @override
  String rollExhaustionApplied(String modifier) {
    return '탈진 $modifier이(가) d20에 적용되었습니다.';
  }

  @override
  String levelUp2024AsiHint(int max) {
    return '능력치 하나에 +2 또는 두 개에 +1 (최대 $max).';
  }

  @override
  String levelUp2024AbilityHint(int increase, int max) {
    return '능력치 하나에 +$increase (최대 $max).';
  }

  @override
  String levelUp2024SpellLimits(
    String className,
    int cantrips,
    int prepared,
    int level,
  ) {
    return '$className: 소마법 $cantrips개, $level레벨까지 준비 주문 $prepared개. 주문 탭에서 선택하세요.';
  }

  @override
  String resetLevels2024Body(String className) {
    return '1레벨로 돌아갈까요? 다음 화면에서 $className을(를) 유지하거나 다른 클래스를 고를 수 있습니다. 클래스로 얻은 레벨, 하위 클래스, 재주, 선택, 주문은 저장된 레벨 기록으로 되돌려집니다. 출신, 수동 능력치 수정, 소지품, 메모, 이야기는 유지됩니다.';
  }

  @override
  String spells2024Cantrips(int count, int max) {
    return '소마법: $count / $max';
  }

  @override
  String spells2024Spellbook(int count, int max) {
    return '주문책: $count / $max';
  }

  @override
  String get spells2024ChooseClass => '이 주문의 클래스를 선택하세요';

  @override
  String get featureChoicesChooseTarget => '대상 선택';

  @override
  String get featureChoicesNoTargets => '아직 선택할 수 있는 대상이 없습니다.';

  @override
  String get levelUp2024SwapTitle => '주문 교체 (선택)';

  @override
  String get levelUp2024SwapCantrip => '교체할 소마법';

  @override
  String get levelUp2024SwapSpell => '교체할 준비 주문';

  @override
  String get levelUp2024SwapLearn => '대체 주문';

  @override
  String get resetLevels2024ClassTitle => '1레벨 클래스';

  @override
  String get changesReviewTitle => '변경 사항 확인';

  @override
  String get changesReviewIntro => '저장하면 다음이 바뀝니다:';

  @override
  String get changesReviewNone => '바뀌는 것이 없습니다.';

  @override
  String get changesReviewApply => '변경 사항 저장';

  @override
  String get changesKindClasses => '클래스';

  @override
  String get changesKindExpertise => '전문화';

  @override
  String get changesKindProficiencies => '숙련';

  @override
  String get changesKindExperience => '경험치';

  @override
  String get changesAdded => '추가됨';

  @override
  String get changesRemoved => '제거됨';

  @override
  String get changesKeptTitle => '그대로 유지';

  @override
  String get resetLimitAbilityIncreases =>
      '이 시트에는 완전한 레벨 기록이 없어 이전 레벨의 능력치 상승이 그대로 남습니다.';

  @override
  String get resetLimitClassSkills => '이 시트는 클래스에서 얻은 기술을 기록하지 않아 그대로 남습니다.';

  @override
  String get concentrationBannerLabel => '집중 중:';

  @override
  String get concentrationBreakButton => '종료';

  @override
  String get concentrationReplaceTitle => '집중 교체?';

  @override
  String concentrationReplaceBody(String current, String next) {
    return '$current에 집중하고 있습니다. $next을 시작하면 집중이 종료됩니다.';
  }

  @override
  String get concentrationReplaceConfirm => '교체';

  @override
  String get concentrationTooltip => '집중 설정';

  @override
  String get sectionIdentity => '신원';

  @override
  String get sectionHitPoints => '히트 포인트';

  @override
  String get sectionCombat => '전투';

  @override
  String get sectionProgression => '진행';

  @override
  String get sectionAbilityScores => '능력 점수';

  @override
  String get sectionSavingThrows => '내성 굴림 숙련';

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
  String get tooltipLevelUp => '레벨 업';

  @override
  String get levelUpTitle => '레벨 업';

  @override
  String get levelUpStepClassTarget => '레벨을 올릴 클래스 선택';

  @override
  String get levelUpClassTargetExisting => '현재 클래스';

  @override
  String get levelUpClassTargetAddClass => '새 클래스 추가';

  @override
  String levelUpClassTargetCurrentLevel(int level) {
    return '현재 레벨 $level';
  }

  @override
  String levelUpClassTargetNextClassLevel(int level) {
    return '클래스 레벨 $level';
  }

  @override
  String levelUpClassTargetRequirement(String requirement) {
    return '$requirement 필요';
  }

  @override
  String levelUpClassTargetRequirementMissing(String requirement) {
    return '부족한 조건: $requirement';
  }

  @override
  String get levelUpClassTargetCurrentRequirementsMissing =>
      '현재 클래스가 멀티클래스 조건을 충족하지 않습니다.';

  @override
  String get levelUpConfirm => '레벨 업 확정';

  @override
  String get levelUpCancel => '취소';

  @override
  String get levelUpStepFeatures => '새로운 특성';

  @override
  String levelUpStepSubclass(String feature) {
    return '$feature 선택';
  }

  @override
  String get levelUpStepAsi => '능력치 향상';

  @override
  String get levelUpStepHp => '히트포인트';

  @override
  String get levelUpStepCantrips => '새로운 소마술';

  @override
  String get levelUpStepSpells => '새로운 주문';

  @override
  String get levelUpStepSummary => '요약';

  @override
  String get levelUpNoNewFeatures => '이 레벨에서 새로운 클래스 특성이 없습니다.';

  @override
  String get featureChoicesTitle => '특성 선택';

  @override
  String get featureChoicesPending => '선택 필요';

  @override
  String get featureChoicesEdit => '선택 편집';

  @override
  String get featureChoicesChooseDependencyFirst => '먼저 필요한 이전 선택을 고르세요.';

  @override
  String featureChoicesChooseCount(String kind, int count) {
    return '$kind $count개를 선택하세요.';
  }

  @override
  String featureChoicesSelectedCount(int selected, int count) {
    return '$selected/$count 선택됨';
  }

  @override
  String get levelUpHpRoll => '주사위 굴리기';

  @override
  String get levelUpHpAverage => '평균값';

  @override
  String levelUpHpGained(int n) {
    return '+$n HP';
  }

  @override
  String levelUpHpFormula(int die, String mod) {
    return 'd$die + CON ($mod)';
  }

  @override
  String get levelUpAsiOption => '능력치 향상';

  @override
  String get levelUpFeatOption => '특기 선택';

  @override
  String levelUpAsiPointsLeft(int n) {
    return '남은 포인트: $n';
  }

  @override
  String levelUpSpellsToLearn(int n) {
    return '주문 $n개 선택';
  }

  @override
  String get levelUpSpellRestrictedSection => '지정된 마법 학파';

  @override
  String get levelUpSpellFreeSection => '자유 선택';

  @override
  String levelUpSpellRestrictedInstruction(int count, String schools) {
    return '선택할 주문: $count개. 허용된 학파: $schools.';
  }

  @override
  String levelUpSpellFreeInstruction(int count) {
    return '선택할 주문: $count개. 어떤 학파에서든 선택할 수 있습니다.';
  }

  @override
  String get levelUpSpellFreeLocked => '먼저 지정된 학파의 주문을 선택하세요.';

  @override
  String levelUpCantripsToLearn(int n) {
    return '소마술 $n개 선택';
  }

  @override
  String get levelUpSpellSwap => '알고 있는 주문 교체 (선택)';

  @override
  String levelUpSpellSwapCurrent(String name) {
    return '현재: $name';
  }

  @override
  String levelUpSummaryLevel(int level) {
    return '→ 레벨 $level';
  }

  @override
  String levelUpSummaryClassLevel(String className, int level) {
    return '$className 레벨 $level';
  }

  @override
  String levelUpSummaryHp(int n) {
    return '최대 HP +$n';
  }

  @override
  String levelUpSummaryAsi(String changes) {
    return '능력치: $changes';
  }

  @override
  String levelUpSummaryFeat(String name) {
    return '특기: $name';
  }

  @override
  String levelUpSummarySubclass(String name) {
    return '서브클래스: $name';
  }

  @override
  String levelUpSummarySpellsLearned(int count) {
    return '습득한 주문: $count';
  }

  @override
  String levelUpSummaryCantripsLearned(int count) {
    return '습득한 소마술: $count';
  }

  @override
  String levelUpSubclassAlreadyHas(String name) {
    return '현재 서브클래스: $name';
  }

  @override
  String get levelUpMaxLevel => '이미 최대 레벨(20)입니다.';

  @override
  String get levelUpHpReroll => '다시 굴리기 / 변경';

  @override
  String get levelUpSpellSwapPickReplacement => '교체할 주문을 선택하세요';

  @override
  String get levelUpSpellSwapReplaceWith => '교체할 주문';

  @override
  String get levelUpSpellSwapNone => '없음';

  @override
  String get levelUpSpellAlreadyKnown => '이미 습득';

  @override
  String levelUpSpellCantripSubtitle(String school) {
    return '$school (소마술)';
  }

  @override
  String levelUpSpellSubtitle(int level, String school) {
    return '레벨 $level $school';
  }

  @override
  String get resetLevelsTitle => '레벨 초기화';

  @override
  String get resetLevelsConfirmBody =>
      '클래스 성장을 1레벨로 되돌립니다. 메모, 소지품, 보관함, 화폐, 이미지, 이야기, 외모, 종족, 배경은 유지됩니다.\n\n클래스 레벨, 클래스 주문, 클래스와 하위 클래스 선택과 그로 얻은 것, 성장 자원, 레벨 재주는 제거됩니다. 시트에 완전한 레벨 기록이 있으면 레벨로 얻은 능력치 상승도 되돌립니다. 저장하기 전에 모든 변경 사항을 확인하게 됩니다.';

  @override
  String resetLevelsCountdown(int seconds) {
    return '$seconds초 대기';
  }

  @override
  String get resetLevelsIntro =>
      '새 레벨 1 클래스 정보를 선택하세요. 마지막 버튼을 누를 때만 초기화가 저장됩니다.';

  @override
  String get resetLevelsSubclassRequired => '이 클래스는 레벨 1에서 하위 클래스를 선택합니다.';

  @override
  String resetLevelsInitialHp(int hp) {
    return '초기 HP: $hp';
  }

  @override
  String resetLevelsSelectSkills(int count) {
    return '클래스 기술 $count개를 선택하세요.';
  }

  @override
  String get resetLevelsFixedTools => '자동 부여:';

  @override
  String resetLevelsSelectTools(int count) {
    return '도구 숙련 $count개를 선택하세요.';
  }

  @override
  String get resetLevelsApply => '레벨 1로 초기화';

  @override
  String resetLevelsApplyAndRebuild(int level) {
    return '초기화하고 레벨 $level까지 재구성';
  }

  @override
  String get resetLevelsIncomplete => '필수 선택을 완료하세요';

  @override
  String get resetLevelsApplied => '레벨이 초기화되었습니다.';

  @override
  String resetLevelsRebuildTitle(int level) {
    return '레벨 $level까지 재구성';
  }

  @override
  String resetLevelsRebuildSubtitle(int level) {
    return '레벨 1을 선택한 뒤 레벨 $level까지 레벨 업 단계를 엽니다. 끝나기 전에 취소하면 아무것도 저장되지 않습니다.';
  }

  @override
  String resetLevelsRebuildStep(int level, int targetLevel) {
    return '레벨 $level/$targetLevel 재구성 중';
  }

  @override
  String get resetLevelsRebuildCancelled => '초기화가 취소되었습니다. 변경 사항은 저장되지 않았습니다.';

  @override
  String resetLevelsRebuiltApplied(int level) {
    return '레벨을 초기화하고 레벨 $level까지 재구성했습니다.';
  }

  @override
  String get labelSubclass => '아강';

  @override
  String get labelLanguages => '언어';

  @override
  String get hintAddLanguage => '언어 추가…';

  @override
  String get labelChoose => '선택하다';

  @override
  String get sectionAppearance => '외모';

  @override
  String get labelAge => '나이';

  @override
  String get labelHeight => '키';

  @override
  String get labelWeight => '몸무게';

  @override
  String get labelEyes => '눈';

  @override
  String get labelSkin => '피부';

  @override
  String get labelHair => '머리카락';

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
  String statsTempHpChip(int n) {
    return '+$n 임시HP';
  }

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
  String get featuresTabFeats => '특기';

  @override
  String featPrerequisite(String req) {
    return '전제 조건: $req';
  }

  @override
  String get featuresSectionFeats => '특기';

  @override
  String get featuresTabClass => '직업';

  @override
  String get featuresTabRacial => '종족';

  @override
  String get featuresTabCustom => '커스텀';

  @override
  String get featuresTabTools => '도구';

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
  String get notesEmptyTitle => '아직 메모가 없습니다';

  @override
  String get notesEmptyHint => '+ 를 눌러 첫 번째 메모를 만드세요.';

  @override
  String get notesUntitled => '제목 없음';

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
  String get notesSearchHint => '메모 또는 태그 검색';

  @override
  String get notesNoResultsTitle => '일치하는 메모가 없습니다';

  @override
  String get notesNoResultsHint => '다른 검색어를 입력하거나 태그 필터를 지우세요.';

  @override
  String get notesReadMore => '더 보기';

  @override
  String get notesTags => '태그';

  @override
  String get notesAllTags => '전체';

  @override
  String get notesCustomTag => '사용자 태그';

  @override
  String get notesAddTag => '태그 추가';

  @override
  String get notesTagColor => '태그 색상';

  @override
  String get notesChooseTagColor => '태그 색상 선택';

  @override
  String get notesTooltipPin => '메모 고정';

  @override
  String get notesTooltipUnpin => '고정 해제';

  @override
  String get notesMoveUp => '위로 이동';

  @override
  String get notesMoveDown => '아래로 이동';

  @override
  String get notesMoreActions => '추가 작업';

  @override
  String get notesPinnedSection => '고정됨';

  @override
  String get notesOtherSection => '메모';

  @override
  String get notesDefaultTagSession => '세션';

  @override
  String get notesDefaultTagNpc => 'NPC';

  @override
  String get notesDefaultTagQuest => '퀘스트';

  @override
  String get notesDefaultTagPlace => '장소';

  @override
  String get notesDefaultTagLoot => '전리품';

  @override
  String get notesDefaultTagRule => '규칙';

  @override
  String get sectionPersonalityTraits => '성격 특성';

  @override
  String get sectionPersonality => '성격';

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
  String get inventoryTooltipMove => '이동';

  @override
  String inventoryMoveTitle(String name) {
    return '$name 이동';
  }

  @override
  String get inventoryMoveToInventory => '인벤토리';

  @override
  String inventoryContainersSection(int count) {
    return '컨테이너 ($count)';
  }

  @override
  String inventoryContainerContents(int count) {
    return '$count개 항목';
  }

  @override
  String get inventoryContainerEmpty => '비어 있음';

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
  String get inventoryRemoveContainerTitle => '컨테이너를 제거하시겠습니까?';

  @override
  String inventoryRemoveContainerContent(String name, int count) {
    return '$name에 $count개 항목이 들어 있습니다. 어떻게 할까요?';
  }

  @override
  String get inventoryRemoveContainerMoveContents => '항목을 인벤토리로 이동';

  @override
  String get inventoryRemoveContainerDeleteContents => '모두 제거';

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
  String get inventoryLabelWeight => '무게';

  @override
  String get weightCarried => '휴대 중';

  @override
  String get weightCapacity => '수낙 능력';

  @override
  String get weightEncumbered => '과적재';

  @override
  String get weightHeavilyEncumbered => '중에 과적재';

  @override
  String get weightEnableTooltip => '무게 추적 활성화';

  @override
  String get weightDisableTooltip => '무게 추적 비활성화';

  @override
  String get inventoryLabelDescription => '설명(선택사항)';

  @override
  String get inventoryTypeWeapon => '무기';

  @override
  String get inventoryTypeArmor => '갑옷';

  @override
  String get inventoryTypeConsumable => '소모품';

  @override
  String get inventoryTypeGear => '장비';

  @override
  String get inventoryTypeEquippable => '장착 가능';

  @override
  String get inventoryTypeContainer => '보관함';

  @override
  String get inventoryAddItemError => '아이템을 추가할 수 없습니다.';

  @override
  String inventoryLoadItemsError(String error) {
    return '아이템 로드 오류:\n$error';
  }

  @override
  String inventoryNoResults(String query) {
    return '\"$query\"에 대한 결과 없음';
  }

  @override
  String get inventoryTooltipEquip => '장착';

  @override
  String get inventoryTooltipUnequip => '장착 해제';

  @override
  String get inventoryCustomDamageDice => '피해 (예: 1d8)';

  @override
  String get inventoryCustomDamageType => '피해 유형';

  @override
  String get inventoryCustomWeaponProperties => '속성 (쉼표로 구분)';

  @override
  String get inventoryCustomRangeNormal => '일반 사거리';

  @override
  String get inventoryCustomRangeLong => '긴 사거리';

  @override
  String get inventoryCustomAddDexToAc => 'AC에 DEX 추가';

  @override
  String get inventoryCustomEquipSlot => '슬롯 (예: 반지, 목)';

  @override
  String get inventoryCustomCompatibleWith => '호환 대상 (쉼표로 구분)';

  @override
  String get inventoryDetailYes => '예';

  @override
  String get inventoryDetailNo => '아니요';

  @override
  String get inventoryDetailMaxShort => '최대';

  @override
  String get inventoryDetailDamage => '피해';

  @override
  String get inventoryDetailDamageType => '피해 유형';

  @override
  String get inventoryDetailWeaponProperties => '속성';

  @override
  String get inventoryDetailVersatileDamage => '다용도 피해';

  @override
  String get inventoryDetailRange => '사거리';

  @override
  String get inventoryDetailRangeNormal => '일반';

  @override
  String get inventoryDetailRangeLong => '장거리';

  @override
  String get inventoryDetailArmorType => '방어구 유형';

  @override
  String get inventoryDetailShield => '방패';

  @override
  String get inventoryDetailBaseAc => '기본 AC';

  @override
  String get inventoryDetailAcBonus => 'AC 보너스';

  @override
  String get inventoryDetailAddDexToAc => 'AC에 DEX 추가';

  @override
  String get inventoryDetailMaxDex => '최대 DEX';

  @override
  String get inventoryDetailStrengthMinimum => '최소 힘';

  @override
  String get inventoryDetailEquipSlot => '슬롯';

  @override
  String get inventoryDetailRequiresAttunement => '조율 필요';

  @override
  String get inventoryDetailCapacityWeight => '무게 용량';

  @override
  String get inventoryDetailCapacityVolume => '부피';

  @override
  String get inventoryDetailCapacityVolumeUnit => '부피 단위';

  @override
  String get inventoryDetailIgnoreContentWeight => '내용물 무게 무시';

  @override
  String get inventoryDetailEffect => '효과';

  @override
  String get inventoryDetailUses => '사용 횟수';

  @override
  String get inventoryDetailAction => '행동';

  @override
  String get inventoryDetailAmmoType => '탄약 유형';

  @override
  String get inventoryDetailCompatibleWith => '호환 대상';

  @override
  String get inventoryDetailBonus => '보너스';

  @override
  String get inventoryDetailExtraDamage => '추가 피해';

  @override
  String get inventoryDetailExtraDamageType => '추가 피해 유형';

  @override
  String get inventoryDetailSubtype => '하위 유형';

  @override
  String get inventoryDetailCost => '가격';

  @override
  String get inventoryDetailRarity => '희귀도';

  @override
  String get inventoryDetailFeatures => '특징';

  @override
  String get inventoryDetailWeightEach => '개당 무게';

  @override
  String get inventoryDetailWeightTotal => '총 무게';

  @override
  String get inventoryDetailState => '상태';

  @override
  String get inventoryDetailEquipped => '장착됨';

  @override
  String get inventoryDetailNotEquipped => '장착 안 됨';

  @override
  String get inventoryDetailSummary => '요약';

  @override
  String get inventoryDetailDescription => '설명';

  @override
  String get inventoryDetailAttributes => '속성';

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
    return '종족 보너스 +$n';
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
  String get statAC => 'AC';

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
  String get statPassivePerc => '수동 감지';

  @override
  String get statInspiration => '영감';

  @override
  String get statXP => 'XP';

  @override
  String get inspirationGranted => '획득';

  @override
  String get inspirationNotGranted => '미획득';

  @override
  String statLevel(int level) {
    return '레벨 $level';
  }

  @override
  String get tooltipAddXp => 'XP 추가';

  @override
  String get labelLevelTable => '레벨 표';

  @override
  String get statUnconsciousDying => '무의식 / 죽어가는 중';

  @override
  String get deathSavesTitle => '죽음의 내성굴림';

  @override
  String get deathSavesSuccesses => '성공';

  @override
  String get deathSavesFailures => '실패';

  @override
  String get deathSavesStabilized => '안정됨';

  @override
  String get deathSavesDead => '사망';

  @override
  String get sectionActiveConditions => '활성 상태';

  @override
  String get conditionsNone => '활성 없음';

  @override
  String get conditionsAdd => '상태 추가';

  @override
  String get conditionsPickTitle => '상태 적용';

  @override
  String get conditionsRemove => '상태 제거';

  @override
  String get tooltipAddTempHp => '임시 HP 추가';

  @override
  String get tooltipChangeTempHp => '임시 HP 변경';

  @override
  String get abilityStr => '근력';

  @override
  String get abilityDex => '민첩';

  @override
  String get abilityCon => '건강';

  @override
  String get abilityInt => '지능';

  @override
  String get abilityWis => '지혜';

  @override
  String get abilityCha => '매력';

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
  String get spellsPactMagicSlots => '계약 마법';

  @override
  String get spellsSpellcasting => '주문 시전';

  @override
  String get spellsAttack => '공격';

  @override
  String get spellsSaveDC => '내성 DC';

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
  String get spellsInnateHeader => '종족 주문';

  @override
  String get spellsDisableTitle => '주문 비활성화?';

  @override
  String get spellsEnableTitle => '주문 활성화?';

  @override
  String spellsDisableContent(String name) {
    return '\"$name\"을(를) 비활성화하시겠습니까? 회색으로 표시되어 준비할 수 없게 됩니다.';
  }

  @override
  String spellsEnableContent(String name) {
    return '\"$name\"을(를) 활성화하시겠습니까? 정상적으로 다시 표시됩니다.';
  }

  @override
  String get spellsDisable => '비활성화';

  @override
  String get spellsEnable => '활성화';

  @override
  String get spellsExtrasHeader => '추가 주문';

  @override
  String get spellFilterTitle => '필터';

  @override
  String get spellFilterReset => '초기화';

  @override
  String get spellFilterApply => '필터 적용';

  @override
  String get spellFilterSectionClasses => '클래스';

  @override
  String get spellFilterClassesHint => '클래스 미선택 = 모든 클래스 표시';

  @override
  String get spellFilterSectionLevel => '주문 레벨';

  @override
  String get spellFilterShowAllLevels => '모든 레벨 표시';

  @override
  String spellFilterShowAllLevelsHint(int max) {
    return '현재 최대 레벨($max) 이상의 주문 포함';
  }

  @override
  String get spellFilterCantrip => '소마법';

  @override
  String spellFilterLvl(int n) {
    return '레벨 $n';
  }

  @override
  String get spellFilterSectionCastingTime => '시전 시간';

  @override
  String get spellFilterCastAction => '행동';

  @override
  String get spellFilterCastBonus => '추가 행동';

  @override
  String get spellFilterCastReaction => '반응';

  @override
  String get spellFilterCastLonger => '긴 시전 (1분+)';

  @override
  String get spellFilterSectionProperties => '속성';

  @override
  String get spellFilterConcentration => '집중';

  @override
  String get spellFilterConcentrationHint => '집중이 필요한 주문만';

  @override
  String get spellFilterRitual => '의식';

  @override
  String get spellFilterRitualHint => '의식으로 시전할 수 있는 주문만';

  @override
  String get spellFilterSectionSchool => '마법 계열';

  @override
  String get spellRemoveTitle => '주문 제거';

  @override
  String spellRemoveContent(String name) {
    return '\"$name\"을(를) 주문 목록에서 제거하시겠습니까?';
  }

  @override
  String get spellActionPrepared => '준비됨 — 탭하여 해제';

  @override
  String get spellActionPrepare => '오늘을 위해 준비';

  @override
  String get spellActionAdd => '캐릭터에 추가';

  @override
  String get spellActionInList => '목록에 있음 — 탭하여 제거';

  @override
  String get spellActionAlreadyInList => '이미 주문 목록에 있습니다';

  @override
  String get spellActionClassSpellInfo => '이 주문은 이미 클래스 목록의 일부이며 학습할 필요가 없습니다.';

  @override
  String get inventoryCurrency => '통화';

  @override
  String inventoryCarriedSection(int count) {
    return '운반됨( $count )';
  }

  @override
  String inventoryEquippableSection(int count) {
    return '장착 가능 ($count)';
  }

  @override
  String get inventoryEquipHint => '왼쪽 원형 아이콘을 탭하여 장착하거나 해제할 수 있습니다';

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
  String get spellRangeSelf => '자신';

  @override
  String get spellRangeTouch => '접촉';

  @override
  String get spellRangeSight => '시야';

  @override
  String get spellRangeSpecial => '특수';

  @override
  String get spellRangeUnlimited => '무제한';

  @override
  String get spellAreaSphere => '구체';

  @override
  String get spellAreaCone => '원뿔';

  @override
  String get spellAreaCube => '정육면체';

  @override
  String get spellAreaCylinder => '원기둥';

  @override
  String get spellAreaLine => '선';

  @override
  String get spellAreaWall => '벽';

  @override
  String get spellAreaCircle => '원';

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
  String get reviewRowSavingThrows => '내성 굴림';

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
    return '$name 착용 시 AC';
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
  String get stepHitDieLabel => '히트 다이스';

  @override
  String get stepSavesLabel => '내성 굴림';

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
  String get stepRaceASILabel => '종족 능력치 보너스';

  @override
  String stepRaceSubracesAvailable(int count) {
    return '선택 가능한 하위 종족: $count개';
  }

  @override
  String stepChooseSkillsHint(int count) {
    return '직업 목록에서 기술을 $count개 선택하세요.';
  }

  @override
  String get abilityStrength => '근력';

  @override
  String get abilityDexterity => '민첩';

  @override
  String get abilityConstitution => '건강';

  @override
  String get abilityIntelligence => '지능';

  @override
  String get abilityWisdom => '지혜';

  @override
  String get abilityCharisma => '매력';

  @override
  String stepFreeAsiRemaining(int remaining) {
    return '종족 능력치 보너스를 자유롭게 분배하세요(남은 점수: $remaining):';
  }

  @override
  String stepFreePicksRemaining(int total, int remaining) {
    return '능력치 $total개에 각각 +1을 배정하세요(남은 선택: $remaining):';
  }

  @override
  String get stepFreePicksNoStack => '이미 종족 보너스를 받은 능력치에는 배정할 수 없습니다.';

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
  String get exportShowJson => 'JSON 표시';

  @override
  String get exportCopyJson => 'JSON 복사';

  @override
  String get exportSectionFile => '완전한 파일';

  @override
  String get exportSectionFileCaption => '캐릭터 사진 포함';

  @override
  String get exportShareFile => '.dndchar 공유';

  @override
  String get dialogClose => '닫기';

  @override
  String get importDialogTitle => '캐릭터 또는 백업 가져오기';

  @override
  String get importUseJson => 'JSON 직접 사용';

  @override
  String get importJsonHint => '여기에 JSON 붙여넣기…';

  @override
  String get importPickFile => '.dndchar 또는 .dndbackup 파일 선택';

  @override
  String get importFileError => '잘못되거나 손상된 .dndchar/.dndbackup 파일';

  @override
  String get importFileIncoming => '파일에서 캐릭터를 가져오시겠습니까?';

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
  String get avatarSavePhoto => '사진 저장';

  @override
  String get avatarSaveSuccess => '사진이 갤러리에 저장되었습니다';

  @override
  String get avatarSaveError => '사진을 저장할 수 없습니다';

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

  @override
  String get avatarRemoveConfirmTitle => '사진을 삭제할까요?';

  @override
  String get avatarRemoveConfirmBody => '이 작업은 취소할 수 없습니다.';

  @override
  String get editModeBanner => '편집 중';

  @override
  String get detailSheetInfoTooltip => '상세 정보';

  @override
  String get detailSheetProficiencies => '숙련';

  @override
  String get detailSheetTraits => '특성';

  @override
  String get detailSheetSubclassFeaturePlaceholder => '하위 클래스 특성';

  @override
  String detailSheetAvailableSubclasses(String feature) {
    return '$feature 선택지';
  }

  @override
  String get detailSheetAvailableSubraces => '하위 종족';

  @override
  String get xpTrackingLabel => '경험치 기록';

  @override
  String get xpReadyToLevelUp => '레벨을 올릴 수 있습니다!';

  @override
  String get xpLevelUpNowTitle => '레벨을 올릴까요?';

  @override
  String xpLevelUpNowMessage(int level) {
    return '레벨 $level에 필요한 경험치를 얻었습니다. 지금 레벨을 올릴까요?';
  }

  @override
  String get xpLevelUpLater => '나중에';

  @override
  String get settingsSectionUnits => '단위';

  @override
  String get settingsUnitSystem => '단위 시스템';

  @override
  String get settingsUnitImperial => '야드파운드법 (ft / lb)';

  @override
  String get settingsUnitMetric => '미터법 (m / kg)';

  @override
  String get settingsUnitSquares => '칸 (sq / kg)';

  @override
  String get settingsChooseUnitSystem => '단위 시스템 선택';

  @override
  String get settingsSectionCharacterSheet => '캐릭터 시트';

  @override
  String get settingsKeepScreenOnTitle => '화면 켜진 상태 유지';

  @override
  String get settingsKeepScreenOnSubtitle => '캐릭터 시트를 보는 동안 화면이 꺼지지 않게 합니다.';

  @override
  String get settingsContextualRollAskTitle => '상황별 굴림 옵션 표시';

  @override
  String get settingsContextualRollAskSubtitle =>
      '시트에서 굴리기 전에 이점이나 불리점 같은 관련 선택지를 표시합니다.';

  @override
  String get settingsContextualCriticalRuleTitle => '치명타 규칙';

  @override
  String get settingsContextualCriticalRuleSubtitle =>
      '공격 굴림에서 자연 20이 나오면 자동으로 사용됩니다.';

  @override
  String get settingsContextualCriticalRuleChoose => '치명타 규칙 선택';

  @override
  String get settingsContextualCriticalRuleDoubleDice => '피해 주사위를 두 배로 굴리기';

  @override
  String get settingsContextualCriticalRuleDoubleDamage => '피해 총합 두 배';

  @override
  String get settingsBackupSection => '백업';

  @override
  String get settingsBackupExportTitle => '백업 내보내기';

  @override
  String get settingsBackupExportSubtitle => '모든 캐릭터를 백업 파일로 저장합니다.';

  @override
  String get settingsBackupExporting => '백업을 만드는 중...';

  @override
  String get settingsBackupExportSuccess => '백업을 내보냈습니다.';

  @override
  String get settingsBackupExportError => '백업을 내보낼 수 없습니다.';

  @override
  String get settingsBackupImportTitle => '백업 가져오기';

  @override
  String get settingsBackupImportSubtitle => '.dndbackup 파일에서 캐릭터를 복원합니다.';

  @override
  String get settingsBackupImporting => '백업을 가져오는 중...';

  @override
  String get settingsBackupImportError => '백업을 가져올 수 없습니다.';

  @override
  String settingsBackupImportSuccess(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '백업에서 캐릭터 $count명을 가져왔습니다.',
      one: '백업에서 캐릭터 1명을 가져왔습니다.',
    );
    return '$_temp0';
  }

  @override
  String get settingsSectionApp => '앱';

  @override
  String get settingsReviewTitle => 'Play 스토어에서 평가';

  @override
  String get settingsReviewSubtitle => '앱 페이지를 열어 평가나 댓글을 남깁니다.';

  @override
  String get settingsReviewOpenError => 'Play 스토어를 열 수 없습니다.';

  @override
  String get settingsMaintenanceSection => '유지 관리';

  @override
  String get settingsMaintenanceCheckTitle => '캐릭터 업데이트 확인';

  @override
  String get settingsMaintenanceCheckSubtitle => '저장된 데이터 수정 사항을 찾습니다.';

  @override
  String get settingsMaintenanceUpdateTitle => '캐릭터 업데이트';

  @override
  String get settingsMaintenanceWorking => '업데이트 확인 중...';

  @override
  String get settingsMaintenanceNoUpdates => '모든 캐릭터가 이미 최신 상태입니다.';

  @override
  String get settingsMaintenanceError => '캐릭터를 업데이트할 수 없습니다.';

  @override
  String get settingsMaintenanceConfirmTitle => '캐릭터를 업데이트할까요?';

  @override
  String get settingsMaintenanceCompleteTitle => '업데이트 완료';

  @override
  String settingsMaintenanceUpdatesFound(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '캐릭터 $count명에 업데이트가 필요합니다.',
      one: '캐릭터 1명에 업데이트가 필요합니다.',
    );
    return '$_temp0';
  }

  @override
  String settingsMaintenanceConfirmBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '캐릭터 $count명에 업데이트가 필요합니다. 변경 사항을 적용하기 전에 저장하거나 공유할 수 있는 백업을 엽니다.',
      one: '캐릭터 1명에 업데이트가 필요합니다. 변경 사항을 적용하기 전에 저장하거나 공유할 수 있는 백업을 엽니다.',
    );
    return '$_temp0';
  }

  @override
  String get characterUpdateRequiredTitle => '캐릭터 업데이트 필요';

  @override
  String get characterUpdateRequiredBody =>
      '이 캐릭터를 열기 전에 업데이트해야 합니다. 캐릭터를 백업하거나 모두 업데이트할 수 있습니다. 업데이트를 적용하기 전에 백업 화면이 열립니다.';

  @override
  String get characterUpdateRequiredAction => '업데이트 옵션';

  @override
  String get characterUpdateBackupAction => '캐릭터 백업';

  @override
  String get characterUpdateAllAction => '모든 캐릭터 업데이트';

  @override
  String get characterUpdateApplying => '캐릭터 업데이트 중...';

  @override
  String settingsMaintenanceReportChecked(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '캐릭터 $count명을 확인했습니다.',
      one: '캐릭터 1명을 확인했습니다.',
    );
    return '$_temp0';
  }

  @override
  String settingsMaintenanceReportUpdated(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '캐릭터 $count명을 업데이트했습니다.',
      one: '캐릭터 1명을 업데이트했습니다.',
    );
    return '$_temp0';
  }

  @override
  String settingsMaintenanceReportDataChanged(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '캐릭터 $count명의 데이터를 수정했습니다.',
      one: '캐릭터 1명의 데이터를 수정했습니다.',
    );
    return '$_temp0';
  }

  @override
  String get settingsMaintenanceReportVersionUpdated => '데이터 버전을 업데이트했습니다.';

  @override
  String settingsMaintenanceChangeEquipmentWeights(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '아이템 $count개의 무게를 수정했습니다.',
      one: '아이템 1개의 무게를 수정했습니다.',
    );
    return '$_temp0';
  }

  @override
  String settingsMaintenanceChangeEquipmentNormalized(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '장비 아이템 $count개를 정규화했습니다.',
      one: '장비 아이템 1개를 정규화했습니다.',
    );
    return '$_temp0';
  }

  @override
  String settingsMaintenanceChangeEquipmentPacksExpanded(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '장비 꾸러미 $count개를 펼쳤습니다.',
      one: '장비 꾸러미 1개를 펼쳤습니다.',
    );
    return '$_temp0';
  }

  @override
  String settingsMaintenanceChangeEquipmentOrder(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '인벤토리 아이템 $count개의 순서를 정규화했습니다.',
      one: '인벤토리 아이템 1개의 순서를 정규화했습니다.',
    );
    return '$_temp0';
  }

  @override
  String get settingsMaintenanceChangeMulticlassStructure =>
      '멀티클래스를 위한 클래스 구조를 준비했습니다.';

  @override
  String get settingsMaintenanceChangeSpellSlots => '일반 주문 슬롯을 다시 계산했습니다.';

  @override
  String get settingsMaintenanceChangePactMagicSlots => '계약 마법 슬롯을 분리했습니다.';

  @override
  String get settingsMaintenanceChangeArmorClass => '방어도를 다시 계산했습니다.';

  @override
  String get settingsMaintenanceChangeRuleset2014 =>
      '이 캐릭터에 2014년 규칙(SRD 5.1)을 지정했습니다.';

  @override
  String get settingsMaintenanceChangeLevelHistory =>
      '레벨 업과 레벨 초기화에 쓰이는 1레벨 기록을 저장했습니다.';

  @override
  String get settingsMaintenanceChangeClassSkills => '1레벨에 클래스로 얻은 기술을 저장했습니다.';

  @override
  String settingsMaintenanceChangeGeneric(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '변경 사항 $count개를 적용했습니다.',
      one: '변경 사항 1개를 적용했습니다.',
    );
    return '$_temp0';
  }

  @override
  String get incomingBackupPrompt => '파일에서 백업을 가져올까요?';

  @override
  String incomingBackupSuccess(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '백업에서 캐릭터 $count명을 가져왔습니다.',
      one: '백업에서 캐릭터 1명을 가져왔습니다.',
    );
    return '$_temp0';
  }
}
