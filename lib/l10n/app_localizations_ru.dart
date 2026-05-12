// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'Инструмент создания персонажей D&D';

  @override
  String get charListTitle => 'Персонажи D&D';

  @override
  String get charListImportTooltip => 'Импортировать JSON';

  @override
  String get charListSettingsTooltip => 'Настройки';

  @override
  String get charListNewCharacter => 'Новый персонаж';

  @override
  String get charListEmpty => 'Персонажей пока нет';

  @override
  String get charListEmptyHint =>
      'Нажмите +, чтобы создать своего первого персонажа.';

  @override
  String charListImportedSuccess(String name) {
    return '$name успешно импортирован!';
  }

  @override
  String get charListImportError =>
      'Непредвиденная ошибка при импорте. Пожалуйста, попробуйте еще раз.';

  @override
  String charCardLevel(int level) {
    return 'Уровень $level';
  }

  @override
  String get charCardPin => 'Закрепить вверху';

  @override
  String get charCardUnpin => 'Открепить';

  @override
  String get charCardChangePhoto => 'Изменить фотографию';

  @override
  String get charCardRename => 'Переименовать';

  @override
  String get charCardExport => 'Экспорт';

  @override
  String get charCardDelete => 'Удалить';

  @override
  String get renameDialogTitle => 'Переименовать персонажа';

  @override
  String get renameDialogLabel => 'Имя';

  @override
  String get dialogCancel => 'Отмена';

  @override
  String get dialogSave => 'Сохранять';

  @override
  String get deleteDialogTitle => 'Удалить персонажа?';

  @override
  String deleteDialogContent(String name) {
    return 'Вы уверены, что хотите удалить $name? Это невозможно отменить.';
  }

  @override
  String get dialogConfirm => 'Подтверждать';

  @override
  String get dialogDiscard => 'Отказаться';

  @override
  String get dialogContinue => 'Продолжать';

  @override
  String get dialogKeepEditing => 'Продолжайте редактировать';

  @override
  String get dialogRemove => 'Удалять';

  @override
  String get dialogAdd => 'Добавлять';

  @override
  String get settingsTitle => 'Настройки';

  @override
  String get settingsSectionTheme => 'Визуальная тема';

  @override
  String get settingsDark => 'Темный';

  @override
  String get settingsLight => 'Свет';

  @override
  String get settingsChooseTheme => 'Выберите тему';

  @override
  String get settingsSectionLanguage => 'Язык';

  @override
  String get settingsAppLanguage => 'Язык приложения';

  @override
  String get settingsChooseLanguage => 'Выберите язык';

  @override
  String get settingsSystemDefault => 'Система по умолчанию';

  @override
  String get modeSelectionTitle => 'Новый персонаж';

  @override
  String get modeSelectionQuestion => 'Как вы хотите создать своего персонажа?';

  @override
  String get modeGuidedTitle => 'Управляемый';

  @override
  String get modeGuidedSubtitle =>
      'Пошаговый мастер. Выбирайте класс, расу, происхождение, навыки и атрибуты по одному. Рекомендуется для новых игроков.';

  @override
  String get modeManualTitle => 'Руководство';

  @override
  String get modeManualSubtitle =>
      'Заполните все сами. Все поля являются бесплатными, и никакие значения не рассчитываются автоматически. Лучше всего для опытных игроков.';

  @override
  String get modeRandomTitle => 'Случайный';

  @override
  String get modeRandomSubtitle =>
      'За вас уже настроено все — раса, класс, предыстория и атрибуты. Отлично подходит для испытаний или одиночных ударов.';

  @override
  String get modeSemiRandomTitle => 'Полуслучайный';

  @override
  String get modeSemiRandomSubtitle =>
      'Вы выбираете важные решения; все остальное прокатывается. Подходит, когда у вас есть концепция, но вы хотите сюрпризов.';

  @override
  String get modeComingSoon => 'Скоро';

  @override
  String get creationStepClass => 'Сорт';

  @override
  String get creationStepRace => 'Раса';

  @override
  String get creationStepBackground => 'Фон';

  @override
  String get creationStepSkills => 'Навыки';

  @override
  String get creationStepAttributes => 'Атрибуты';

  @override
  String get creationStepName => 'Имя';

  @override
  String get creationStepReview => 'Обзор';

  @override
  String get creationDiscardTitle => 'Сбросить персонажа?';

  @override
  String get creationDiscardContent =>
      'Весь прогресс будет потерян. Вы уверены?';

  @override
  String get creationTooltipCancel => 'Отмена';

  @override
  String get creationBack => 'Назад';

  @override
  String get creationCreateCharacter => 'Создать персонажа';

  @override
  String get detailLeaveWithoutSaving => 'Уйти без сохранения?';

  @override
  String get detailChangesWillBeDiscarded =>
      'Изменения будут отменены. Для сохранения используйте кнопку ✓ вверху справа.';

  @override
  String get detailLeaveAndDiscard => 'Оставить и выбросить';

  @override
  String detailErrorLoading(String error) {
    return 'Ошибка загрузки символа: $error.';
  }

  @override
  String get detailTooltipLongRest => 'Длительный отдых';

  @override
  String get detailTooltipCancelEdit => 'Отменить редактирование';

  @override
  String get detailTooltipDoneEditing => 'Закончено редактирование';

  @override
  String get detailTooltipEditCharacter => 'Редактировать персонажа';

  @override
  String get detailCancelEditTitle => 'Отменить редактирование?';

  @override
  String get detailCancelEditContent => 'Все изменения будут отменены.';

  @override
  String get detailFinishEditTitle => 'Завершить редактирование?';

  @override
  String get detailFinishEditContent => 'Изменения будут сохранены.';

  @override
  String get detailTabStats => 'Статистика';

  @override
  String get detailTabSkills => 'Навыки';

  @override
  String get detailTabFeatures => 'Функции';

  @override
  String get detailTabSpells => 'Заклинания';

  @override
  String get detailTabInventory => 'Инвентарь';

  @override
  String get detailTabNotes => 'Примечания';

  @override
  String get longRestTitle => 'Длительный отдых';

  @override
  String get longRestContent =>
      'Восстановить HP до максимума и восстановить все ячейки заклинаний?';

  @override
  String get longRestButton => 'Отдых';

  @override
  String get sectionIdentity => 'Личность';

  @override
  String get sectionHitPoints => 'Жизни';

  @override
  String get sectionCombat => 'Бой';

  @override
  String get sectionAbilityScores => 'Показатели способностей';

  @override
  String get sectionSavingThrows => 'Сохранение навыков броска';

  @override
  String get labelName => 'Имя';

  @override
  String get labelBackground => 'Фон';

  @override
  String get labelChange => 'Изменять';

  @override
  String get labelAlignment => 'Выравнивание';

  @override
  String get labelPlayer => 'Игрок';

  @override
  String get labelLevel => 'Уровень';

  @override
  String get labelSubclass => 'Подкласс';

  @override
  String get labelLanguages => 'Языки';

  @override
  String get hintAddLanguage => 'Добавить язык…';

  @override
  String get labelChoose => 'Выбирать';

  @override
  String get labelMaxHP => 'Макс. HP';

  @override
  String get labelTempHP => 'Температура HP';

  @override
  String get labelAmount => 'Количество';

  @override
  String get labelSpeed => 'Скорость (футы)';

  @override
  String get detailDamage => 'Повреждать';

  @override
  String get detailHeal => 'Лечить';

  @override
  String get detailNone => 'Никто';

  @override
  String get tempHpDialogTitle => 'Добавить временное здоровье';

  @override
  String get tempHpDialogTitleReplace => 'Временное здоровье';

  @override
  String tempHpCurrent(int n) {
    return 'Текущее: + $n темп. HP';
  }

  @override
  String get tempHpNoStack =>
      'Temp HP не суммируется — только более высокие значения заменяют текущий.';

  @override
  String get tempHpReplace => 'Заменять';

  @override
  String subclassConfirmTitle(String feature) {
    return 'Подтвердите $feature';
  }

  @override
  String subclassChooseTitle(String feature) {
    return 'Выберите $feature';
  }

  @override
  String subclassConfirmBody(int level, String feature) {
    return 'Вы достигли уровня $level. Подтвердите или измените свой $feature.';
  }

  @override
  String subclassChooseBody(int level, String feature) {
    return 'Вы достигли уровня $level! Выберите свой $feature.';
  }

  @override
  String get subclassKeepCurrent => 'Будьте в курсе';

  @override
  String get subclassChangeTitle => 'Изменить подкласс';

  @override
  String get subclassChangeWarning =>
      'Внимание: заклинания и навыки, предоставленные предыдущим подклассом, не удаляются автоматически. Вам придется настроить их вручную.';

  @override
  String get backgroundChooseTitle => 'Выбрать фон';

  @override
  String get featuresTooltipAdd => 'Добавить функцию';

  @override
  String get featuresTooltipRemove => 'Удалять';

  @override
  String get featuresRemoveTitle => 'Удалить функцию?';

  @override
  String featuresRemoveContent(String name) {
    return '«$name» будет удален.';
  }

  @override
  String get featuresNoneAvailable => 'Нет доступных функций.';

  @override
  String get featuresAddLabel => 'Добавить функцию';

  @override
  String get featuresLoadError => 'Ошибка загрузки функций.';

  @override
  String get hintSearch => 'Поиск...';

  @override
  String get labelFeatureName => 'Имя';

  @override
  String get labelFeatureDescription => 'Описание (необязательно)';

  @override
  String get labelFeatureType => 'Тип:';

  @override
  String get labelPassive => 'Пассивный';

  @override
  String get labelActive => 'Активный';

  @override
  String get spellsTooltipAdd => 'Добавить заклинание';

  @override
  String get spellsRemoveTitle => 'Удалить заклинание?';

  @override
  String spellsRemoveContent(String name) {
    return 'Удалить «$name» из списка заклинаний?';
  }

  @override
  String get spellsAtWill => 'По желанию';

  @override
  String get notesTooltipAdd => 'Добавить примечание';

  @override
  String get notesTooltipEdit => 'Изменить заметку';

  @override
  String get notesTooltipDelete => 'Удалить заметку';

  @override
  String get notesDeleteTitle => 'Удалить заметку?';

  @override
  String notesDeleteContentNamed(String title) {
    return '«$title» будет удален без возможности восстановления.';
  }

  @override
  String get notesDeleteContent => 'Эта заметка будет удалена навсегда.';

  @override
  String get notesLabelTitle => 'Заголовок';

  @override
  String get notesLabelContent => 'Содержание';

  @override
  String get sectionPersonalityTraits => 'Черты личности';

  @override
  String get sectionIdeals => 'Идеалы';

  @override
  String get sectionBonds => 'Облигации';

  @override
  String get sectionFlaws => 'Недостатки';

  @override
  String get sectionBackstory => 'Предыстория';

  @override
  String inventoryEquippedSection(int count, int ac) {
    return 'Оборудовано ( $count ) · Кондиционер $ac';
  }

  @override
  String get inventoryTooltipAdd => 'Добавить элемент';

  @override
  String get inventoryTooltipRemove => 'Удалять';

  @override
  String get inventoryRemoveTitle => 'Удалить элемент?';

  @override
  String inventoryRemoveContent(String name) {
    return 'Удалить $name из инвентаря?';
  }

  @override
  String inventoryRemovePartial(int count, int total) {
    return 'Будет удалено: $count из $total.';
  }

  @override
  String get inventoryLabelQuantity => 'Количество:';

  @override
  String get inventoryLabelQuantityToRemove => 'Количество для удаления';

  @override
  String get inventoryAddCustomItem => 'Добавить пользовательский элемент';

  @override
  String get inventoryAddItem => 'Добавить элемент';

  @override
  String get inventoryLabelItemName => 'Имя *';

  @override
  String get inventoryLabelType => 'Тип';

  @override
  String get inventoryLabelCategory => 'Категория';

  @override
  String get inventoryLabelItemQuantity => 'Количество';

  @override
  String get inventoryLabelDescription => 'Описание (необязательно)';

  @override
  String get inventoryTypeWeapon => 'Оружие';

  @override
  String get inventoryTypeArmor => 'Броня';

  @override
  String get inventoryTypeConsumable => 'Расходный материал';

  @override
  String get inventoryTypeGear => 'Механизм';

  @override
  String get inventoryReplaceArmorTitle => 'Заменить экипированную броню?';

  @override
  String get inventoryTabWeapons => 'Оружие';

  @override
  String get inventoryTabArmor => 'Броня';

  @override
  String get inventoryTabGear => 'Механизм';

  @override
  String get inventoryTabMagic => 'Магия';

  @override
  String get inventoryTabTools => 'Инструменты';

  @override
  String get inventoryTabCustom => 'Обычай';

  @override
  String hintSearchCategory(String category) {
    return 'Поиск $category...';
  }

  @override
  String get stepChooseMethod => 'Выберите свой метод:';

  @override
  String get stepStandardArray => 'Стандартный массив';

  @override
  String get stepPointBuy => 'Пойнтовая покупка';

  @override
  String get stepRoll4d6 => 'Бросьте 4d6';

  @override
  String get stepDistributeRacialBonuses =>
      'Свободно раздавайте расовые бонусы';

  @override
  String get stepAssignRolls => 'Назначьте каждый бросок атрибуту:';

  @override
  String get stepAssignValues => 'Присвойте каждому значению один атрибут:';

  @override
  String get stepPointsRemaining => 'Оставшиеся баллы:';

  @override
  String stepRaceBonus(int n) {
    return '+ раса $n';
  }

  @override
  String get stepChooseSubrace => 'Выберите подрасу:';

  @override
  String get stepGrantedByBackground => 'Предоставлено по происхождению:';

  @override
  String stepClassSkillChoices(int count) {
    return 'Выбор навыков класса ( $count ):';
  }

  @override
  String get stepChooseOne => 'Выберите один';

  @override
  String get stepSelectTool => 'Выберите инструмент…';

  @override
  String get statAC => 'переменного тока';

  @override
  String get statArmor => 'Броня';

  @override
  String get statNoArmor => 'Нет брони';

  @override
  String get statNoArmorShield => 'Без брони + Щит';

  @override
  String get statShieldSuffix => '+ Щит';

  @override
  String get statSpeed => 'Скорость';

  @override
  String get statInitiative => 'Инициатива';

  @override
  String get statProfBonus => 'Проф Бонус';

  @override
  String get statPassivePerc => 'Пассивный процент';

  @override
  String get statUnconsciousDying => 'Без сознания / Умирающий';

  @override
  String get tooltipAddTempHp => 'Добавить временное HP';

  @override
  String get tooltipChangeTempHp => 'Изменить температуру HP';

  @override
  String get abilityStr => 'СТР';

  @override
  String get abilityDex => 'Декс';

  @override
  String get abilityCon => 'КОН';

  @override
  String get abilityInt => 'ИНТ.';

  @override
  String get abilityWis => 'ИСВ';

  @override
  String get abilityCha => 'ЦДХ';

  @override
  String featuresSectionRacialTraits(String name) {
    return 'Расовые черты — $name';
  }

  @override
  String featuresSectionBackground(String name) {
    return 'Фоновая функция — $name';
  }

  @override
  String featuresSectionClass(String name) {
    return 'Особенности класса — $name';
  }

  @override
  String featuresSectionSubclass(String name) {
    return 'Особенности подкласса — $name';
  }

  @override
  String get featuresSectionTools => 'Владение инструментами';

  @override
  String get featuresSectionExtra => 'Дополнительные возможности';

  @override
  String get spellsNoSpellcasting => 'Нет заклинаний';

  @override
  String get spellsNoSpellcastingDesc =>
      'Этот класс не имеет способностей к заклинаниям.';

  @override
  String get spellsSlots => 'Слоты заклинаний';

  @override
  String get spellsSpellcasting => 'Колдовство';

  @override
  String get spellsAttack => 'Атака';

  @override
  String get spellsSaveDC => 'Сохранить Вашингтон';

  @override
  String get spellsCantrips => 'Заговоры';

  @override
  String get spellsPrepared => 'Готовый';

  @override
  String get spellsKnown => 'Известный';

  @override
  String get spellsEmpty =>
      'Заклинания пока не добавлены.\nНажмите +, чтобы просмотреть заклинания.';

  @override
  String spellsSlotLevel(int level) {
    return 'Уровень $level';
  }

  @override
  String spellsLevelN(int level) {
    return 'Уровень $level';
  }

  @override
  String get inventoryCurrency => 'Валюта';

  @override
  String inventoryCarriedSection(int count) {
    return 'Перенесено ( $count )';
  }

  @override
  String get inventoryInventory => 'Инвентарь';

  @override
  String get inventoryEmpty => 'Товаров пока нет. Нажмите +, чтобы добавить.';

  @override
  String get inventoryAmmunition => 'Боеприпасы';

  @override
  String get coinCopper => 'Медь';

  @override
  String get coinSilver => 'Серебро';

  @override
  String get coinElectrum => 'Электрум';

  @override
  String get coinGold => 'Золото';

  @override
  String get coinPlatinum => 'Платина';

  @override
  String get inventoryGroupSimpleMelee => 'Простой ближний бой';

  @override
  String get inventoryGroupSimpleRanged => 'Простой дальний бой';

  @override
  String get inventoryGroupMartialMelee => 'Боевой ближний бой';

  @override
  String get inventoryGroupMartialRanged => 'Боевой дальний бой';

  @override
  String get inventoryGroupLightArmor => 'Легкая броня';

  @override
  String get inventoryGroupMediumArmor => 'Средняя броня';

  @override
  String get inventoryGroupHeavyArmor => 'Тяжелая броня';

  @override
  String get inventoryGroupShields => 'Щиты';

  @override
  String get inventoryGroupAdventuringGear => 'Приключенческое снаряжение';

  @override
  String get inventoryGroupAmmunition => 'Боеприпасы';

  @override
  String get inventoryGroupArcaneFocus => 'Чародейский фокус';

  @override
  String get inventoryGroupClothing => 'Одежда';

  @override
  String get inventoryGroupContainer => 'Контейнер';

  @override
  String get inventoryGroupPoison => 'Яд';

  @override
  String get inventoryGroupPotions => 'Зелья';

  @override
  String get inventoryGroupRings => 'Кольца';

  @override
  String get inventoryGroupWands => 'Жезлы';

  @override
  String get inventoryGroupWeapons => 'Оружие';

  @override
  String get inventoryGroupArmor => 'Броня';

  @override
  String get inventoryGroupWondrousItems => 'Чудесные предметы';

  @override
  String get inventoryGroupArtisansTools => 'Инструменты ремесленника';

  @override
  String get inventoryGroupGamingSets => 'Игровые наборы';

  @override
  String get inventoryGroupMusicalInstruments => 'Музыкальные инструменты';

  @override
  String get inventoryGroupOtherTools => 'Другие инструменты';

  @override
  String get armorStealthDisadvantage => 'Недостаток скрытности';

  @override
  String get spellDetailCastingTime => 'Время каста';

  @override
  String get spellDetailRange => 'Диапазон';

  @override
  String get spellDetailDuration => 'Продолжительность';

  @override
  String get spellDetailComponents => 'Компоненты';

  @override
  String get spellDetailConcentration => 'Требует концентрации';

  @override
  String get spellDetailRitual => 'Можно использовать как ритуал';

  @override
  String get spellDetailAtHigherLevels => 'На более высоких уровнях.';

  @override
  String spellDetailClasses(String classes) {
    return 'Классы: $classes';
  }

  @override
  String spellDetailLevelSchool(String ordinal, String school) {
    return '$ordinal - уровень $school';
  }

  @override
  String spellDetailCantrip(String school) {
    return '$school кантрип';
  }
}
