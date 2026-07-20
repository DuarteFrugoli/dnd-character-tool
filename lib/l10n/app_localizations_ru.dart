// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'Инструмент создания персонажей DnD';

  @override
  String get charListTitle => 'Персонажи DnD';

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
  String get importErrorInvalidJson => 'Вставленный JSON недопустим.';

  @override
  String get importErrorInvalidToken =>
      'Недействительный токен. Он может быть повреждён или от несовместимой версии.';

  @override
  String get importFieldLockedHint =>
      'Очистите другое поле, чтобы использовать это.';

  @override
  String get importErrorNotObject => 'Неверный формат: ожидался объект JSON.';

  @override
  String get importErrorMissingCharacter =>
      'Недопустимый JSON: поле \"character\" не найдено.';

  @override
  String get importErrorCorruptedCharacter =>
      'Не удалось прочитать персонажа. JSON может быть неполным или от несовместимой версии.';

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
  String get dialogDone => 'Готово';

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
  String get detailTabIdentity => 'Личность';

  @override
  String get detailEditButton => 'Редактировать';

  @override
  String get skillsEditHint =>
      'Удерживайте для переключения: нет → владение → экспертиза';

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
  String get restPickerTitle => 'Отдых';

  @override
  String get restPickerShort => 'Короткий отдых';

  @override
  String get restPickerShortCaption =>
      'Потратьте кости хитов для восстановления HP';

  @override
  String get restPickerLong => 'Длинный отдых';

  @override
  String get restPickerLongCaption =>
      'Восстанавливает все HP и ячейки заклинаний';

  @override
  String get shortRestTitle => 'Короткий отдых';

  @override
  String get shortRestAvailableDice => 'Доступные кости хитов';

  @override
  String get shortRestSpend => 'Потратить';

  @override
  String get shortRestRolled => 'Восстановлено HP';

  @override
  String get shortRestRollButton => 'Бросить';

  @override
  String get shortRestButton => 'Отдохнуть';

  @override
  String get shortRestNoDice => 'Костей хитов не осталось';

  @override
  String get concentrationBannerLabel => 'Концентрация на:';

  @override
  String get concentrationBreakButton => 'Завершить';

  @override
  String get concentrationReplaceTitle => 'Заменить концентрацию?';

  @override
  String concentrationReplaceBody(String current, String next) {
    return 'Вы концентрируетесь на $current. Использование $next прервёт концентрацию.';
  }

  @override
  String get concentrationReplaceConfirm => 'Заменить';

  @override
  String get concentrationTooltip => 'Установить концентрацию';

  @override
  String get sectionIdentity => 'Личность';

  @override
  String get sectionHitPoints => 'Жизни';

  @override
  String get sectionCombat => 'Бой';

  @override
  String get sectionProgression => 'Прогресс';

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
  String get levelManualChangeWarning =>
      'Только способности и ячейки заклинаний обновляются автоматически. Для полного повышения уровня (HP, характеристики, черты, заклинания) используйте кнопку «Повышение» на верхней панели.';

  @override
  String get tooltipLevelUp => 'Повышение';

  @override
  String get levelUpTitle => 'Повышение уровня';

  @override
  String get levelUpConfirm => 'Подтвердить повышение';

  @override
  String get levelUpCancel => 'Отмена';

  @override
  String get levelUpStepFeatures => 'Новые способности';

  @override
  String levelUpStepSubclass(String feature) {
    return 'Выбрать $feature';
  }

  @override
  String get levelUpStepAsi => 'Улучшение характеристик';

  @override
  String get levelUpStepHp => 'Хиты';

  @override
  String get levelUpStepCantrips => 'Новые заговоры';

  @override
  String get levelUpStepSpells => 'Новые заклинания';

  @override
  String get levelUpStepSummary => 'Итог';

  @override
  String get levelUpNoNewFeatures =>
      'На этом уровне нет новых классовых умений.';

  @override
  String get featureChoicesTitle => 'Выбор особенностей';

  @override
  String get featureChoicesPending => 'Выбор не завершен';

  @override
  String get featureChoicesEdit => 'Изменить выбор';

  @override
  String get featureChoicesChooseDependencyFirst =>
      'Сначала выберите требуемый предыдущий вариант.';

  @override
  String featureChoicesChooseCount(String kind, int count) {
    return 'Выберите $count $kind.';
  }

  @override
  String featureChoicesSelectedCount(int selected, int count) {
    return 'Выбрано $selected/$count';
  }

  @override
  String get levelUpHpRoll => 'Бросить кости';

  @override
  String get levelUpHpAverage => 'Среднее';

  @override
  String levelUpHpGained(int n) {
    return '+$n хитов';
  }

  @override
  String levelUpHpFormula(int die, String mod) {
    return 'к$die + ТЕЛ ($mod)';
  }

  @override
  String get levelUpAsiOption => 'Улучшение характеристик';

  @override
  String get levelUpFeatOption => 'Выбрать черту';

  @override
  String levelUpAsiPointsLeft(int n) {
    return 'Осталось очков: $n';
  }

  @override
  String levelUpSpellsToLearn(int n) {
    return 'Выбрать $n заклинание(й)';
  }

  @override
  String get levelUpSpellRestrictedSection => 'School requirement';

  @override
  String get levelUpSpellFreeSection => 'Free choice';

  @override
  String levelUpSpellRestrictedInstruction(int count, String schools) {
    return 'Choose $count spell(s) from $schools.';
  }

  @override
  String levelUpSpellFreeInstruction(int count) {
    return 'Choose $count spell(s) from any school.';
  }

  @override
  String get levelUpSpellFreeLocked => 'Complete the school requirement first.';

  @override
  String levelUpCantripsToLearn(int n) {
    return 'Выбрать $n заговор(ов)';
  }

  @override
  String get levelUpSpellSwap =>
      'Заменить известное заклинание (необязательно)';

  @override
  String levelUpSpellSwapCurrent(String name) {
    return 'Текущее: $name';
  }

  @override
  String levelUpSummaryLevel(int level) {
    return '→ Уровень $level';
  }

  @override
  String levelUpSummaryHp(int n) {
    return 'Макс. хиты +$n';
  }

  @override
  String levelUpSummaryAsi(String changes) {
    return 'Улучшение: $changes';
  }

  @override
  String levelUpSummaryFeat(String name) {
    return 'Черта: $name';
  }

  @override
  String levelUpSummarySubclass(String name) {
    return 'Подкласс: $name';
  }

  @override
  String levelUpSummarySpellsLearned(int count) {
    return 'Изучено заклинаний: $count';
  }

  @override
  String levelUpSummaryCantripsLearned(int count) {
    return 'Изучено заговоров: $count';
  }

  @override
  String levelUpSubclassAlreadyHas(String name) {
    return 'Текущий подкласс: $name';
  }

  @override
  String get levelUpMaxLevel => 'Уже максимальный уровень (20).';

  @override
  String get levelUpHpReroll => 'Перебросить / изменить';

  @override
  String get levelUpSpellSwapPickReplacement =>
      'Теперь выберите заменяющее заклинание';

  @override
  String get levelUpSpellSwapReplaceWith => 'Заменить на';

  @override
  String get levelUpSpellSwapNone => 'Ни одного';

  @override
  String get levelUpSpellAlreadyKnown => 'Уже известно';

  @override
  String levelUpSpellCantripSubtitle(String school) {
    return '$school (заговор)';
  }

  @override
  String levelUpSpellSubtitle(int level, String school) {
    return 'Ур $level $school';
  }

  @override
  String get labelSubclass => 'Подкласс';

  @override
  String get labelLanguages => 'Языки';

  @override
  String get hintAddLanguage => 'Добавить язык…';

  @override
  String get labelChoose => 'Выбирать';

  @override
  String get sectionAppearance => 'Внешность';

  @override
  String get labelAge => 'Возраст';

  @override
  String get labelHeight => 'Рост';

  @override
  String get labelWeight => 'Вес';

  @override
  String get labelEyes => 'Глаза';

  @override
  String get labelSkin => 'Кожа';

  @override
  String get labelHair => 'Волосы';

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
  String statsTempHpChip(int n) {
    return '+$n врем.';
  }

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
  String get featuresTooltipEnable => 'Включить';

  @override
  String get featuresTooltipDisable => 'Отключить';

  @override
  String get featuresTabFeats => 'Таланты';

  @override
  String featPrerequisite(String req) {
    return 'Требование: $req';
  }

  @override
  String get featuresSectionFeats => 'Таланты';

  @override
  String get featuresTabClass => 'Класс';

  @override
  String get featuresTabRacial => 'Расовые';

  @override
  String get featuresTabCustom => 'Свой';

  @override
  String get featuresTabTools => 'Инструменты';

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
  String get notesEmptyTitle => 'Заметок пока нет';

  @override
  String get notesEmptyHint => 'Нажмите +, чтобы создать первую заметку.';

  @override
  String get notesUntitled => 'Без названия';

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
  String get sectionPersonality => 'Личность';

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
  String get inventoryLabelWeight => 'Вес';

  @override
  String get weightCarried => 'Несётся';

  @override
  String get weightCapacity => 'Грузоподъёмность';

  @override
  String get weightEncumbered => 'Отягощён';

  @override
  String get weightHeavilyEncumbered => 'Сильно Отягощён';

  @override
  String get weightEnableTooltip => 'Включить отслеживание веса';

  @override
  String get weightDisableTooltip => 'Выключить отслеживание веса';

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
  String get inventoryTypeEquippable => 'Можно экипировать';

  @override
  String get inventoryTypeContainer => 'Контейнер';

  @override
  String get inventoryAddItemError => 'Не удалось добавить предмет.';

  @override
  String inventoryLoadItemsError(String error) {
    return 'Ошибка загрузки предметов:\n$error';
  }

  @override
  String inventoryNoResults(String query) {
    return 'Нет результатов для \"$query\"';
  }

  @override
  String get inventoryTooltipEquip => 'Экипировать';

  @override
  String get inventoryTooltipUnequip => 'Снять';

  @override
  String get inventoryCustomDamageDice => 'Урон (например, 1d8)';

  @override
  String get inventoryCustomDamageType => 'Тип урона';

  @override
  String get inventoryCustomWeaponProperties => 'Свойства (через запятую)';

  @override
  String get inventoryCustomRangeNormal => 'Обычная дистанция';

  @override
  String get inventoryCustomRangeLong => 'Дальняя дистанция';

  @override
  String get inventoryCustomAddDexToAc => 'Добавить ЛВК к КД';

  @override
  String get inventoryCustomEquipSlot => 'Слот (например, кольцо, шея)';

  @override
  String get inventoryCustomCompatibleWith => 'Совместимо с (через запятую)';

  @override
  String get inventoryDetailYes => 'Да';

  @override
  String get inventoryDetailNo => 'Нет';

  @override
  String get inventoryDetailMaxShort => 'макс.';

  @override
  String get inventoryDetailDamage => 'Урон';

  @override
  String get inventoryDetailDamageType => 'Тип урона';

  @override
  String get inventoryDetailWeaponProperties => 'Свойства';

  @override
  String get inventoryDetailVersatileDamage => 'Урон при универсальном хвате';

  @override
  String get inventoryDetailRange => 'Дистанция';

  @override
  String get inventoryDetailRangeNormal => 'обычная';

  @override
  String get inventoryDetailRangeLong => 'дальняя';

  @override
  String get inventoryDetailArmorType => 'Тип доспеха';

  @override
  String get inventoryDetailShield => 'Щит';

  @override
  String get inventoryDetailBaseAc => 'Базовый КД';

  @override
  String get inventoryDetailAcBonus => 'Бонус КД';

  @override
  String get inventoryDetailAddDexToAc => 'Добавляет ЛВК к КД';

  @override
  String get inventoryDetailMaxDex => 'Макс. ЛВК';

  @override
  String get inventoryDetailStrengthMinimum => 'Минимальная Сила';

  @override
  String get inventoryDetailEquipSlot => 'Слот';

  @override
  String get inventoryDetailRequiresAttunement => 'Требует настройки';

  @override
  String get inventoryDetailCapacityWeight => 'Грузоподъемность';

  @override
  String get inventoryDetailCapacityVolume => 'Объем';

  @override
  String get inventoryDetailCapacityVolumeUnit => 'Единица объема';

  @override
  String get inventoryDetailIgnoreContentWeight => 'Игнорирует вес содержимого';

  @override
  String get inventoryDetailEffect => 'Эффект';

  @override
  String get inventoryDetailUses => 'Использования';

  @override
  String get inventoryDetailAction => 'Действие';

  @override
  String get inventoryDetailAmmoType => 'Тип боеприпаса';

  @override
  String get inventoryDetailCompatibleWith => 'Совместимо с';

  @override
  String get inventoryDetailBonus => 'Бонус';

  @override
  String get inventoryDetailExtraDamage => 'Дополнительный урон';

  @override
  String get inventoryDetailExtraDamageType => 'Тип дополнительного урона';

  @override
  String get inventoryDetailSubtype => 'Подтип';

  @override
  String get inventoryDetailCost => 'Стоимость';

  @override
  String get inventoryDetailRarity => 'Редкость';

  @override
  String get inventoryDetailFeatures => 'Особенности';

  @override
  String get inventoryDetailWeightEach => 'Вес за предмет';

  @override
  String get inventoryDetailWeightTotal => 'Общий вес';

  @override
  String get inventoryDetailState => 'Состояние';

  @override
  String get inventoryDetailEquipped => 'Экипировано';

  @override
  String get inventoryDetailNotEquipped => 'Не экипировано';

  @override
  String get inventoryDetailSummary => 'Сводка';

  @override
  String get inventoryDetailDescription => 'Описание';

  @override
  String get inventoryDetailAttributes => 'Атрибуты';

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
  String get statInspiration => 'Вдохновение';

  @override
  String get statXP => 'ОО';

  @override
  String get inspirationGranted => 'Получено';

  @override
  String get inspirationNotGranted => 'Не получено';

  @override
  String statLevel(int level) {
    return 'Уровень $level';
  }

  @override
  String get tooltipAddXp => 'Добавить ОО';

  @override
  String get labelLevelTable => 'Таблица уровней';

  @override
  String get statUnconsciousDying => 'Без сознания / Умирающий';

  @override
  String get deathSavesTitle => 'Спасброски от смерти';

  @override
  String get deathSavesSuccesses => 'Успехи';

  @override
  String get deathSavesFailures => 'Провалы';

  @override
  String get deathSavesStabilized => 'Стабилизирован';

  @override
  String get deathSavesDead => 'Мёртв';

  @override
  String get sectionActiveConditions => 'Активные состояния';

  @override
  String get conditionsNone => 'Нет активных';

  @override
  String get conditionsAdd => 'Добавить состояние';

  @override
  String get conditionsPickTitle => 'Применить состояние';

  @override
  String get conditionsRemove => 'Удалить состояние';

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
  String get spellsInnateHeader => 'Расовые заклинания';

  @override
  String get spellsDisableTitle => 'Отключить заклинание?';

  @override
  String get spellsEnableTitle => 'Включить заклинание?';

  @override
  String spellsDisableContent(String name) {
    return 'Отключить \"$name\"? Оно будет выделено серым и его нельзя будет подготовить.';
  }

  @override
  String spellsEnableContent(String name) {
    return 'Включить \"$name\"? Оно снова будет отображаться нормально.';
  }

  @override
  String get spellsDisable => 'Отключить';

  @override
  String get spellsEnable => 'Включить';

  @override
  String get spellsExtrasHeader => 'Дополнительные заклинания';

  @override
  String get spellFilterTitle => 'Фильтры';

  @override
  String get spellFilterReset => 'Сбросить';

  @override
  String get spellFilterApply => 'Применить фильтры';

  @override
  String get spellFilterSectionClasses => 'Классы';

  @override
  String get spellFilterClassesHint => 'Без класса = показать все классы';

  @override
  String get spellFilterSectionLevel => 'Уровень заклинания';

  @override
  String get spellFilterShowAllLevels => 'Показать все уровни';

  @override
  String spellFilterShowAllLevelsHint(int max) {
    return 'Включая заклинания выше вашего максимума (Ур. $max)';
  }

  @override
  String get spellFilterCantrip => 'Заговор';

  @override
  String spellFilterLvl(int n) {
    return 'Ур. $n';
  }

  @override
  String get spellFilterSectionCastingTime => 'Время применения';

  @override
  String get spellFilterCastAction => 'Действие';

  @override
  String get spellFilterCastBonus => 'Бонусное действие';

  @override
  String get spellFilterCastReaction => 'Реакция';

  @override
  String get spellFilterCastLonger => 'Длинное применение (1 мин+)';

  @override
  String get spellFilterSectionProperties => 'Свойства';

  @override
  String get spellFilterConcentration => 'Концентрация';

  @override
  String get spellFilterConcentrationHint =>
      'Только заклинания, требующие концентрации';

  @override
  String get spellFilterRitual => 'Ритуал';

  @override
  String get spellFilterRitualHint =>
      'Только заклинания, которые можно применять как ритуалы';

  @override
  String get spellFilterSectionSchool => 'Школа магии';

  @override
  String get spellRemoveTitle => 'Удалить заклинание';

  @override
  String spellRemoveContent(String name) {
    return 'Удалить \"$name\" из вашего списка заклинаний?';
  }

  @override
  String get spellActionPrepared => 'Подготовлено — нажмите для отмены';

  @override
  String get spellActionPrepare => 'Подготовить на сегодня';

  @override
  String get spellActionAdd => 'Добавить персонажу';

  @override
  String get spellActionInList => 'В вашем списке — нажмите для удаления';

  @override
  String get spellActionAlreadyInList => 'Уже в вашем списке заклинаний';

  @override
  String get spellActionClassSpellInfo =>
      'Это заклинание уже является частью списка вашего класса и не требует изучения.';

  @override
  String get inventoryCurrency => 'Валюта';

  @override
  String inventoryCarriedSection(int count) {
    return 'Перенесено ( $count )';
  }

  @override
  String inventoryEquippableSection(int count) {
    return 'Снаряжаемое ($count)';
  }

  @override
  String get inventoryEquipHint =>
      'Нажмите на круглый значок слева, чтобы надеть или снять предмет';

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
  String get spellRangeSelf => 'На себя';

  @override
  String get spellRangeTouch => 'Касание';

  @override
  String get spellRangeSight => 'В пределах видимости';

  @override
  String get spellRangeSpecial => 'Особая';

  @override
  String get spellRangeUnlimited => 'Неограниченная';

  @override
  String get spellAreaSphere => 'сфера';

  @override
  String get spellAreaCone => 'конус';

  @override
  String get spellAreaCube => 'куб';

  @override
  String get spellAreaCylinder => 'цилиндр';

  @override
  String get spellAreaLine => 'линия';

  @override
  String get spellAreaWall => 'стена';

  @override
  String get spellAreaCircle => 'круг';

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

  @override
  String armorSwapCurrent(String name) {
    return 'Текущий: $name';
  }

  @override
  String armorSwapAcNow(int ac) {
    return 'AC сейчас: $ac';
  }

  @override
  String armorSwapAcAfter(int ac) {
    return 'AC после: $ac';
  }

  @override
  String get armorSwapButton => 'Сменить броню';

  @override
  String get reviewRowName => 'Имя';

  @override
  String get reviewUnnamedHero => 'Безымянный герой';

  @override
  String get reviewRowPlayer => 'Игрок';

  @override
  String get reviewRowSubclass => 'Подкласс';

  @override
  String get reviewRowHitDie => 'Хит умереть';

  @override
  String get reviewRowSavingThrows => 'Спасительные броски';

  @override
  String get reviewRowSubrace => 'Подраса';

  @override
  String get reviewRowSpeed => 'Скорость';

  @override
  String get reviewRowLanguages => 'Языки';

  @override
  String get reviewRowFeature => 'Особенность';

  @override
  String get reviewRowFromBackground => 'Из фона';

  @override
  String get reviewRowClassChoices => 'Выбор класса';

  @override
  String get reviewRowMaxHp => 'Макс. HP';

  @override
  String get reviewRowAcUnarmored => 'AC (небронированный)';

  @override
  String reviewRowAcWith(String name) {
    return 'переменного тока с $name';
  }

  @override
  String get reviewRowProficiencyBonus => 'Бонус мастерства';

  @override
  String get reviewStartingGold => 'Стартовое золото';

  @override
  String get reviewStartingEquipment => 'Стартовое оборудование';

  @override
  String get reviewDeselectAll => 'Отменить выбор всех';

  @override
  String get reviewSelectAll => 'Выбрать все';

  @override
  String get reviewUncheckHint =>
      'Снимите флажки с предметов, которые вы не хотите добавлять в свой инвентарь.';

  @override
  String get reviewEquipmentChoices => 'Выбор оборудования';

  @override
  String get reviewEquipmentChoicesHint =>
      'Выберите конкретный предмет для каждого слота.';

  @override
  String get reviewToolProficiencies => 'Владение инструментами';

  @override
  String get reviewChooseToolProficiency =>
      'Выберите уровень владения инструментом:';

  @override
  String reviewChooseLanguages(int count) {
    return 'Выберите язык(и) $count, предоставленный вашей расой или происхождением.';
  }

  @override
  String get reviewChooseOne => 'Выберите один:';

  @override
  String get stepTashaRule =>
      'Необязательное правило Таши — присваивайте баллы ASI любому атрибуту';

  @override
  String get stepRollDice => 'Бросить кости';

  @override
  String get stepReroll => 'Переролл';

  @override
  String get stepRollHint =>
      'Бросайте бросок, чтобы получить 6 значений (4d6, самое низкое значение)';

  @override
  String get stepPrimaryAbilities => 'основные способности:';

  @override
  String get stepNameTitle => 'Дайте своему персонажу имя.';

  @override
  String get stepNameHint => 'Вы всегда можете изменить это позже.';

  @override
  String get stepNameCharLabel => 'Имя персонажа';

  @override
  String get stepNamePlayerLabel => 'Имя игрока (необязательно)';

  @override
  String get stepHitDieLabel => 'Хит умереть';

  @override
  String get stepSavesLabel => 'Сохранения';

  @override
  String get stepSpellcastingLabel => 'Колдовство';

  @override
  String get stepOptionsLabel => 'параметры';

  @override
  String stepChooseSubclassPrompt(String feature, int level) {
    return 'Выберите $feature (уровень $level):';
  }

  @override
  String get stepRaceSpeedLabel => 'Скорость';

  @override
  String get stepRaceASILabel => 'АСИ';

  @override
  String stepRaceSubracesAvailable(int count) {
    return 'Доступно $count подрас';
  }

  @override
  String stepChooseSkillsHint(int count) {
    return 'Выберите $count навыков из списка вашего класса.';
  }

  @override
  String get abilityStrength => 'Сила';

  @override
  String get abilityDexterity => 'Ловкость';

  @override
  String get abilityConstitution => 'Конституция';

  @override
  String get abilityIntelligence => 'Интеллект';

  @override
  String get abilityWisdom => 'Мудрость';

  @override
  String get abilityCharisma => 'Харизма';

  @override
  String stepFreeAsiRemaining(int remaining) {
    return 'Свободно распределяйте расовые очки ASI (осталось $remaining):';
  }

  @override
  String stepFreePicksRemaining(int total, int remaining) {
    return 'Свободный от расы ASI: присвойте +1 к $total атрибутам (осталось $remaining):';
  }

  @override
  String get stepFreePicksNoStack =>
      'Невозможно назначить атрибутам, уже получающим расовый бонус.';

  @override
  String reviewClassEquipmentTitle(String name) {
    return 'Классовое снаряжение — $name';
  }

  @override
  String get reviewEquipmentIncluded => 'Включено:';

  @override
  String get stepToolCategoryGamingSet => 'Игровой набор';

  @override
  String get stepToolCategoryInstrument => 'Музыкальный инструмент';

  @override
  String get stepToolCategoryArtisanTool => 'инструмент ремесленника';

  @override
  String get stepToolCategoryArtisanOrInstrument =>
      'Инструмент или инструмент ремесленника';

  @override
  String exportCopied(String label) {
    return '$label скопировано!';
  }

  @override
  String exportDialogTitle(String name) {
    return 'Экспорт $name';
  }

  @override
  String get exportLabelToken => 'Токен';

  @override
  String get exportCopyToken => 'Копировать токен';

  @override
  String get exportHideQr => 'Скрыть QR-код';

  @override
  String get exportShowQr => 'Показать QR-код';

  @override
  String get exportQrTooLarge =>
      'Персонаж слишком большой для QR-кода.\nИспользуйте токен или JSON для обмена.';

  @override
  String get exportShowJson => 'Показать JSON';

  @override
  String get exportCopyJson => 'Копировать JSON';

  @override
  String get exportSectionQuick => 'Быстрый обмен';

  @override
  String get exportSectionQuickCaption =>
      'Без фото — для обмена характеристиками';

  @override
  String get exportSectionFile => 'Полный файл';

  @override
  String get exportSectionFileCaption => 'Включает фотографию персонажа';

  @override
  String get exportShareFile => 'Поделиться .dndchar';

  @override
  String get dialogClose => 'Закрыть';

  @override
  String get importDialogTitle => 'Импорт персонажа';

  @override
  String get importTokenHint => 'Вставьте токен здесь…';

  @override
  String get importScanQr => 'Сканировать QR-код';

  @override
  String get importUseJson => 'Использовать JSON напрямую';

  @override
  String get importJsonHint => 'Вставьте JSON здесь…';

  @override
  String get importPickFile => 'Выбрать файл .dndchar';

  @override
  String get importFileError => 'Недопустимый или повреждённый файл .dndchar';

  @override
  String get importFileIncoming => 'Импортировать персонажа из файла?';

  @override
  String get dialogImport => 'Импорт';

  @override
  String get spellBrowserTitle => 'Обзор заклинаний';

  @override
  String get spellBrowserFilters => 'Фильтры';

  @override
  String get spellBrowserSearchHint => 'Поиск заклинаний...';

  @override
  String get filterClearAll => 'Очистить всё';

  @override
  String get loadingLabel => 'Загрузка...';

  @override
  String spellBrowserCount(int count, String s) {
    return '$count заклинание$s';
  }

  @override
  String get spellBrowserEmpty =>
      'Ни одно заклинание не соответствует текущим фильтрам.';

  @override
  String get spellCantrip => 'Заговор';

  @override
  String spellLevelN(int n) {
    return 'Ур $n';
  }

  @override
  String get castingTimeAction => 'Действие';

  @override
  String get castingTimeBonusAction => 'Бонусное действие';

  @override
  String get castingTimeReaction => 'Реакция';

  @override
  String get castingTimeLonger => 'Длительное';

  @override
  String get filterConcentration => 'Концентрация';

  @override
  String get filterRitual => 'Ритуал';

  @override
  String get filterAllLevels => 'Все уровни';

  @override
  String get avatarChoosePhoto => 'Выбрать фото';

  @override
  String get avatarRemovePhoto => 'Удалить фото';

  @override
  String get avatarCropPhoto => 'Обрезать фото';

  @override
  String get avatarChangePhoto => 'Изменить фото';

  @override
  String get avatarSavePhoto => 'Сохранить фото';

  @override
  String get avatarSaveSuccess => 'Фото сохранено в галерее';

  @override
  String get avatarSaveError => 'Не удалось сохранить фото';

  @override
  String featureAddedSnackbar(String name) {
    return '$name добавлено!';
  }

  @override
  String get featureAddButton => 'Добавить особенность';

  @override
  String get reviewLanguageChoices => 'Выбор языков';

  @override
  String get reviewLanguageTypeHint => 'Введите язык…';

  @override
  String get avatarRemoveConfirmTitle => 'Удалить фото?';

  @override
  String get avatarRemoveConfirmBody => 'Это действие нельзя отменить.';

  @override
  String get editModeBanner => 'Редактирование';

  @override
  String get detailSheetInfoTooltip => 'Подробнее';

  @override
  String get detailSheetProficiencies => 'Владения';

  @override
  String get detailSheetTraits => 'Черты';

  @override
  String get detailSheetSubclassFeaturePlaceholder => 'Умение подкласса';

  @override
  String detailSheetAvailableSubclasses(String feature) {
    return 'Доступные $feature';
  }

  @override
  String get detailSheetAvailableSubraces => 'Подрасы';

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

  @override
  String get settingsSectionUnits => 'Единицы';

  @override
  String get settingsUnitSystem => 'Система единиц';

  @override
  String get settingsUnitImperial => 'Имперская (ft / lb)';

  @override
  String get settingsUnitMetric => 'Метрическая (m / kg)';

  @override
  String get settingsUnitSquares => 'Клетки (sq / kg)';

  @override
  String get settingsChooseUnitSystem => 'Выбрать систему единиц';

  @override
  String get settingsBackupSection => 'Резервная копия';

  @override
  String get settingsBackupExportTitle => 'Экспортировать резервную копию';

  @override
  String get settingsBackupExportSubtitle =>
      'Сохраняет всех персонажей в файл резервной копии.';

  @override
  String get settingsBackupExporting => 'Создание резервной копии...';

  @override
  String get settingsBackupExportSuccess => 'Резервная копия экспортирована.';

  @override
  String get settingsBackupExportError =>
      'Не удалось экспортировать резервную копию.';

  @override
  String get settingsBackupImportTitle => 'Импортировать резервную копию';

  @override
  String get settingsBackupImportSubtitle =>
      'Восстанавливает персонажей из файла .dndbackup.';

  @override
  String get settingsBackupImporting => 'Импорт резервной копии...';

  @override
  String get settingsBackupImportError =>
      'Не удалось импортировать резервную копию.';

  @override
  String settingsBackupImportSuccess(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count персонажей импортировано из резервной копии.',
      one: '1 персонаж импортирован из резервной копии.',
    );
    return '$_temp0';
  }

  @override
  String get settingsMaintenanceSection => 'Обслуживание';

  @override
  String get settingsMaintenanceCheckTitle => 'Проверить обновления персонажей';

  @override
  String get settingsMaintenanceCheckSubtitle =>
      'Ищет исправления для сохраненных данных.';

  @override
  String get settingsMaintenanceUpdateTitle => 'Обновить персонажей';

  @override
  String get settingsMaintenanceWorking => 'Проверка обновлений...';

  @override
  String get settingsMaintenanceNoUpdates => 'Все персонажи уже обновлены.';

  @override
  String get settingsMaintenanceError => 'Не удалось обновить персонажей.';

  @override
  String get settingsMaintenanceConfirmTitle => 'Обновить персонажей?';

  @override
  String get settingsMaintenanceCompleteTitle => 'Обновление завершено';

  @override
  String settingsMaintenanceUpdatesFound(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count персонажам требуется обновление.',
      one: '1 персонажу требуется обновление.',
    );
    return '$_temp0';
  }

  @override
  String settingsMaintenanceConfirmBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count персонажам требуется обновление. Перед применением изменений приложение откроет резервную копию, которую можно сохранить или отправить.',
      one:
          '1 персонажу требуется обновление. Перед применением изменений приложение откроет резервную копию, которую можно сохранить или отправить.',
    );
    return '$_temp0';
  }

  @override
  String settingsMaintenanceReportChecked(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Проверено $count персонажей.',
      one: 'Проверен 1 персонаж.',
    );
    return '$_temp0';
  }

  @override
  String settingsMaintenanceReportUpdated(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Обновлено $count персонажей.',
      one: 'Обновлен 1 персонаж.',
    );
    return '$_temp0';
  }

  @override
  String settingsMaintenanceReportDataChanged(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'У $count персонажей исправлены данные.',
      one: 'У 1 персонажа исправлены данные.',
    );
    return '$_temp0';
  }

  @override
  String get settingsMaintenanceReportVersionUpdated =>
      'Версия данных обновлена.';

  @override
  String settingsMaintenanceChangeEquipmentWeights(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Исправлен вес $count предметов.',
      one: 'Исправлен вес 1 предмета.',
    );
    return '$_temp0';
  }

  @override
  String settingsMaintenanceChangeEquipmentNormalized(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Нормализовано $count предметов снаряжения.',
      one: 'Нормализован 1 предмет снаряжения.',
    );
    return '$_temp0';
  }

  @override
  String settingsMaintenanceChangeEquipmentPacksExpanded(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Развернуто $count наборов снаряжения.',
      one: 'Развернут 1 набор снаряжения.',
    );
    return '$_temp0';
  }

  @override
  String settingsMaintenanceChangeGeneric(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Применено $count изменений.',
      one: 'Применено 1 изменение.',
    );
    return '$_temp0';
  }

  @override
  String get incomingBackupPrompt => 'Импортировать резервную копию из файла?';

  @override
  String incomingBackupSuccess(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count персонажей импортировано из резервной копии.',
      one: '1 персонаж импортирован из резервной копии.',
    );
    return '$_temp0';
  }
}
