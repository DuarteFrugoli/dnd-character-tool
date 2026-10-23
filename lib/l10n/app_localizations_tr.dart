// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get appTitle => 'DnD Character Tool';

  @override
  String get charListTitle => 'DnD Karakterleri';

  @override
  String get charListImportTooltip => 'Karakter veya yedek içe aktar';

  @override
  String get charListSettingsTooltip => 'Ayarlar';

  @override
  String get charListNewCharacter => 'Yeni Karakter';

  @override
  String get charListEmpty => 'Henüz karakter yok';

  @override
  String get charListEmptyHint =>
      'İlk karakterinizi oluşturmak için + düğmesine dokunun';

  @override
  String get whatsNewTitle => 'Yenilikler';

  @override
  String whatsNewVersionSubtitle(String version) {
    return 'Sürüm $version';
  }

  @override
  String get whatsNewIntro =>
      'Bir sonraki oyun oturumunuz için yararlı yenilikler hazır.';

  @override
  String get whatsNewContextualRollsTitle => 'Bağlamsal zar atışları';

  @override
  String get whatsNewContextualRollsBody =>
      'Özellik, beceri, kurtarma atışı, silah ve basit büyü zarlarını doğrudan karakter sayfasından atın.';

  @override
  String get whatsNewCriticalsTitle => 'Kritik vuruş seçenekleri';

  @override
  String get whatsNewCriticalsBody =>
      'Kritik hasarın nasıl hesaplanacağını seçin; gerektiğinde avantaj ve dezavantaj seçeneklerini kullanın.';

  @override
  String get whatsNewConfirmationsTitle => 'Daha anlaşılır onaylar';

  @override
  String get whatsNewConfirmationsBody =>
      'Güvenli ve geri alınamaz işlemler artık daha kolay ayırt ediliyor.';

  @override
  String get whatsNewDone => 'Anladım';

  @override
  String get whatsNewSummary =>
      'Türkçe desteği geldi, SRD 5.1 büyülü eşya kataloğu genişledi ve karakter güncellemeleri daha anlaşılır hâle geldi. D&D 2024 desteği geliştiriliyor.';

  @override
  String get whatsNewTurkishTitle => 'Artık Türkçe';

  @override
  String get whatsNewTurkishBody =>
      'Uygulama arayüzü ve SRD 5.1 oyun içeriği artık Türkçe olarak kullanılabilir.';

  @override
  String get whatsNewMagicItemsTitle => 'Daha fazla büyülü eşya';

  @override
  String get whatsNewMagicItemsBody =>
      'Daha fazla SRD 5.1 büyülü eşyayı keşfedin. Desteklenen dillerde eksik olan çeviriler de eklendi.';

  @override
  String get whatsNewCharacterUpdatesTitle =>
      'Daha anlaşılır karakter güncellemeleri';

  @override
  String get whatsNewCharacterUpdatesBody =>
      'Bir karakterin güncellenmesi gerektiğinde karakterlerinizi yedekleyebilir, hepsini güncelleyebilir veya işlemi iptal edebilirsiniz. Güncellenene kadar karakter sayfası açılmaz.';

  @override
  String get whatsNew2024Title => 'D&D 2024 geliştiriliyor';

  @override
  String get whatsNew2024Body =>
      '2014 kurallarına göre oluşturulmuş karakterleri oynanabilir tutarken güncellenmiş sınıflar, alt sınıflar, türler, büyüler, ekipman ve büyülü eşyalar içeren ayrı bir 2024 kural modu geliştiriyoruz. İsteğe bağlı rehberli dönüştürme planlanıyor; 2024 kurallarıyla karakter oluşturma ve dönüştürme henüz kullanılamıyor.';

  @override
  String get whatsNewSettingsSubtitle => 'Son duyuruyu yeniden oku.';

  @override
  String get whatsNewThanks =>
      'Oynadığınız ve görüşlerinizi paylaştığınız için teşekkür ederiz. Fikirleriniz sonraki adımlarımıza yön veriyor.';

  @override
  String charListImportedSuccess(String name) {
    return '$name başarıyla içe aktarıldı!';
  }

  @override
  String charListDuplicatedSuccess(String name) {
    return '$name başarıyla çoğaltıldı!';
  }

  @override
  String get charListImportError =>
      'İçe aktarılırken beklenmeyen bir hata oluştu. Lütfen yeniden deneyin.';

  @override
  String get charListDuplicateError =>
      'Karakter çoğaltılamadı. Lütfen yeniden deneyin.';

  @override
  String get importErrorInvalidJson => 'Yapıştırılan JSON geçerli değil.';

  @override
  String get importFieldLockedHint =>
      'Bu alanı kullanmak için diğer alanı temizleyin.';

  @override
  String get importErrorNotObject =>
      'Geçersiz biçim: JSON nesnesi bekleniyordu.';

  @override
  String get importErrorMissingCharacter =>
      'Geçersiz JSON: \'character\' alanı bulunamadı.';

  @override
  String get importErrorCorruptedCharacter =>
      'Karakter okunamadı. JSON eksik veya uyumsuz bir sürümden olabilir.';

  @override
  String charCardLevel(int level) {
    return 'Seviye $level';
  }

  @override
  String get charCardPin => 'Üste sabitle';

  @override
  String get charCardUnpin => 'Sabitlemeyi kaldır';

  @override
  String get charCardChangePhoto => 'Fotoğrafı değiştir';

  @override
  String get charCardRename => 'Yeniden adlandır';

  @override
  String get charCardDuplicate => 'Çoğalt';

  @override
  String get charCardExport => 'Dışa aktar';

  @override
  String get charCardDelete => 'Sil';

  @override
  String charDuplicateName(String name) {
    return '$name (kopya)';
  }

  @override
  String charDuplicateNameNumbered(String name, int number) {
    return '$name (kopya $number)';
  }

  @override
  String get renameDialogTitle => 'Karakteri yeniden adlandır';

  @override
  String get renameDialogLabel => 'Ad';

  @override
  String get dialogCancel => 'İptal';

  @override
  String get dialogSave => 'Kaydet';

  @override
  String get deleteDialogTitle => 'Karakter silinsin mi?';

  @override
  String deleteDialogContent(String name) {
    return '$name karakterini silmek istediğinizden emin misiniz? Bu işlem geri alınamaz.';
  }

  @override
  String get dialogConfirm => 'Onayla';

  @override
  String get dialogDiscard => 'Vazgeç';

  @override
  String get dialogContinue => 'Devam et';

  @override
  String get dialogKeepEditing => 'Düzenlemeye devam et';

  @override
  String get dialogRemove => 'Kaldır';

  @override
  String get dialogAdd => 'Ekle';

  @override
  String get dialogDone => 'Bitti';

  @override
  String get settingsTitle => 'Ayarlar';

  @override
  String get settingsSectionTheme => 'Görsel Tema';

  @override
  String get settingsDark => 'Koyu';

  @override
  String get settingsLight => 'Açık';

  @override
  String get settingsChooseTheme => 'Tema Seç';

  @override
  String get settingsSectionLanguage => 'Dil';

  @override
  String get settingsAppLanguage => 'Uygulama dili';

  @override
  String get settingsChooseLanguage => 'Dil Seç';

  @override
  String get settingsSystemDefault => 'Sistem varsayılanı';

  @override
  String get modeSelectionTitle => 'Yeni Karakter';

  @override
  String get modeSelectionQuestion =>
      'Karakterinizi nasıl oluşturmak istersiniz?';

  @override
  String get modeGuidedTitle => 'Rehberli';

  @override
  String get modeGuidedSubtitle =>
      'Adım adım sihirbaz. Sınıfı, türü, geçmişi, becerileri ve nitelikleri tek tek seçin. Yeni oyuncular için önerilir.';

  @override
  String get modeManualTitle => 'Elle';

  @override
  String get modeManualSubtitle =>
      'Her şeyi kendiniz doldurun. Tüm alanlar serbesttir ve değerler sizin yerinize hesaplanmaz. Deneyimli oyuncular için uygundur.';

  @override
  String get modeRandomTitle => 'Rastgele';

  @override
  String get modeRandomSubtitle =>
      'Tür, sınıf, geçmiş ve nitelikler sizin için rastgele belirlenir. Meydan okumalar veya tek oturumluk oyunlar için idealdir.';

  @override
  String get modeSemiRandomTitle => 'Yarı rastgele';

  @override
  String get modeSemiRandomSubtitle =>
      'Önemli seçimleri siz yaparsınız; geri kalanı rastgele belirlenir. Bir karakter fikriniz varsa ama sürpriz de istiyorsanız uygundur.';

  @override
  String get modeComingSoon => 'Yakında';

  @override
  String get creationStepClass => 'Sınıf';

  @override
  String get creationStepRace => 'Tür';

  @override
  String get creationStepBackground => 'Geçmiş';

  @override
  String get creationStepSkills => 'Beceriler';

  @override
  String get creationStepAttributes => 'Nitelikler';

  @override
  String get creationStepName => 'Ad';

  @override
  String get creationStepReview => 'Gözden Geçir';

  @override
  String get creationDiscardTitle => 'Karakter oluşturma iptal edilsin mi?';

  @override
  String get creationDiscardContent => 'Tüm ilerleme kaybolacak. Emin misiniz?';

  @override
  String get creationTooltipCancel => 'İptal';

  @override
  String get creationBack => 'Geri';

  @override
  String get creationCreateCharacter => 'Karakter Oluştur';

  @override
  String get detailLeaveWithoutSaving => 'Kaydetmeden çıkılsın mı?';

  @override
  String get detailChangesWillBeDiscarded =>
      'Değişiklikler silinecek. Kaydetmek için sağ üstteki ✓ düğmesini kullanın.';

  @override
  String get detailLeaveAndDiscard => 'Çık ve değişiklikleri sil';

  @override
  String detailErrorLoading(String error) {
    return 'Karakter yüklenirken hata oluştu: $error';
  }

  @override
  String get detailTooltipLongRest => 'Uzun Dinlenme';

  @override
  String get characterActionRollDice => 'Zar at';

  @override
  String get characterActionResetLevels => 'Seviyeleri sıfırla';

  @override
  String get diceExpressionLabel => 'İfade';

  @override
  String get diceExpressionHint => 'Örnek: 1d20+5 veya 4d6dl1';

  @override
  String get diceExpressionHelpTooltip => 'Zar ifadeleri nasıl çalışır?';

  @override
  String get diceExpressionHelpTitle => 'Zar ifadeleri';

  @override
  String get diceExpressionHelpBody =>
      'Zar atmak için XdY kullanın: 2d6, altı yüzlü iki zar atar.\nDeğiştirici ekleyin veya çıkarın: 1d20+5 ya da 2d6 - 1.\nYüzdelik zar için d% veya d100 kullanın.\nd20 avantaj/dezavantajı için: 2d20kh1 yüksek olanı, 2d20kl1 düşük olanı tutar.\nkh, kl, dh veya dl ile zarları tutun ya da çıkarın. Örnek: 4d6dl1 dört d6 atar ve en düşük olanı çıkarır.\nBoşluklar isteğe bağlıdır: 2d6+1d8 ve 2d6 + 1d8 aynı şekilde çalışır.';

  @override
  String get diceQuantityLabel => 'Adet';

  @override
  String get diceModifierLabel => 'Değiştirici';

  @override
  String get diceRollButton => 'At';

  @override
  String get diceRerollButton => 'Tekrar at';

  @override
  String get diceModeNormal => 'Normal';

  @override
  String get diceModeAdvantage => 'Avantaj';

  @override
  String get diceModeDisadvantage => 'Dezavantaj';

  @override
  String get diceResultTitle => 'Sonuç';

  @override
  String get diceHistoryTitle => 'Son atışlar';

  @override
  String get diceNoRollsYet => 'Henüz zar atılmadı.';

  @override
  String get diceNaturalOne => 'Doğal 1';

  @override
  String get diceNaturalTwenty => 'Doğal 20';

  @override
  String get contextualRollCriticalApplied => 'Kritik uygulandı';

  @override
  String get contextualRollVersatileGrip => 'Silah tutuşu';

  @override
  String get contextualRollVersatileOneHanded => 'Tek elle';

  @override
  String get contextualRollVersatileTwoHanded => 'İki elle';

  @override
  String diceInvalidExpression(String message) {
    return 'Geçersiz zar ifadesi: $message';
  }

  @override
  String get detailTooltipCancelEdit => 'Düzenlemeyi iptal et';

  @override
  String get detailTooltipDoneEditing => 'Düzenlemeyi bitir';

  @override
  String get detailTooltipEditCharacter => 'Karakteri düzenle';

  @override
  String get detailCancelEditTitle => 'Düzenleme iptal edilsin mi?';

  @override
  String get detailCancelEditContent => 'Tüm değişiklikler silinecek.';

  @override
  String get detailFinishEditTitle => 'Düzenleme bitirilsin mi?';

  @override
  String get detailFinishEditContent => 'Değişiklikler kaydedilecek.';

  @override
  String get detailTabIdentity => 'Kimlik';

  @override
  String get detailEditButton => 'Düzenle';

  @override
  String get skillsEditHint =>
      'Değiştirmek için basılı tutun: yok → yetkin → uzman';

  @override
  String get skillsOrganizeTooltip => 'Düzenle';

  @override
  String get skillsDisplayTitle => 'Beceri görünümü';

  @override
  String get skillsDisplayModeLabel => 'Düzen';

  @override
  String get skillsDisplayByAbility => 'Niteliğe göre';

  @override
  String get skillsDisplayProficiencyFirst => 'Önce yetkin olanlar';

  @override
  String get skillsDisplayAlphabetical => 'Alfabetik';

  @override
  String get skillsDisplayAbilityOrder => 'Nitelik sırası';

  @override
  String get skillsDisplayProficientFirstInsideGroups =>
      'Gruplarda önce yetkin olanlar';

  @override
  String get skillsDisplayRestoreDefault => 'Varsayılanı geri yükle';

  @override
  String get skillsDisplayProficientSection => 'Yetkin';

  @override
  String get skillsDisplayOtherSection => 'Diğer beceriler';

  @override
  String get skillsDisplayAllSection => 'Tüm beceriler';

  @override
  String get detailTabStats => 'İstatistikler';

  @override
  String get detailTabSkills => 'Beceriler';

  @override
  String get detailTabFeatures => 'Özellikler';

  @override
  String get detailTabSpells => 'Büyüler';

  @override
  String get detailTabInventory => 'Envanter';

  @override
  String get detailTabNotes => 'Notlar';

  @override
  String get longRestTitle => 'Uzun Dinlenme';

  @override
  String get longRestContent =>
      'Canı en yüksek değere çıkarıp tüm büyü yuvalarını geri kazanmak istiyor musunuz?';

  @override
  String get longRestButton => 'Dinlen';

  @override
  String get restPickerTitle => 'Dinlenme';

  @override
  String get restPickerShort => 'Kısa Dinlenme';

  @override
  String get restPickerShortCaption => 'Can yenilemek için Can Zarlarını harca';

  @override
  String get restPickerLong => 'Uzun Dinlenme';

  @override
  String get restPickerLongCaption => 'Tüm canı ve büyü yuvalarını yenile';

  @override
  String get shortRestTitle => 'Kısa Dinlenme';

  @override
  String get shortRestAvailableDice => 'Kullanılabilir Can Zarları';

  @override
  String get shortRestSpend => 'Harca';

  @override
  String get shortRestRolled => 'Yenilenen can';

  @override
  String get shortRestRollButton => 'At';

  @override
  String get shortRestButton => 'Dinlen';

  @override
  String get shortRestNoDice => 'Can Zarı kalmadı';

  @override
  String get concentrationBannerLabel => 'Konsantre olunan:';

  @override
  String get concentrationBreakButton => 'Bitir';

  @override
  String get concentrationReplaceTitle => 'Konsantrasyon değiştirilsin mi?';

  @override
  String concentrationReplaceBody(String current, String next) {
    return 'Şu anda $current büyüsüne konsantresiniz. $next başlatılırsa mevcut konsantrasyonunuz sona erecek.';
  }

  @override
  String get concentrationReplaceConfirm => 'Değiştir';

  @override
  String get concentrationTooltip => 'Konsantrasyon ayarla';

  @override
  String get sectionIdentity => 'Kimlik';

  @override
  String get sectionHitPoints => 'Can Puanı';

  @override
  String get sectionCombat => 'Savaş';

  @override
  String get sectionProgression => 'İlerleme';

  @override
  String get sectionAbilityScores => 'Nitelik Puanları';

  @override
  String get sectionSavingThrows => 'Kurtarma Atışı Yetkinlikleri';

  @override
  String get labelName => 'Ad';

  @override
  String get labelBackground => 'Geçmiş';

  @override
  String get labelChange => 'Değiştir';

  @override
  String get labelAlignment => 'Hizalanma';

  @override
  String get labelPlayer => 'Oyuncu';

  @override
  String get labelLevel => 'Seviye';

  @override
  String get tooltipLevelUp => 'Seviye Atla';

  @override
  String get levelUpTitle => 'Seviye Atlama';

  @override
  String get levelUpStepClassTarget => 'Seviye atlatılacak sınıfı seçin';

  @override
  String get levelUpClassTargetExisting => 'Mevcut sınıflar';

  @override
  String get levelUpClassTargetAddClass => 'Yeni sınıf ekle';

  @override
  String levelUpClassTargetCurrentLevel(int level) {
    return 'Mevcut seviye $level';
  }

  @override
  String levelUpClassTargetNextClassLevel(int level) {
    return 'Sınıf seviyesi $level';
  }

  @override
  String levelUpClassTargetRequirement(String requirement) {
    return 'Gerekli: $requirement';
  }

  @override
  String levelUpClassTargetRequirementMissing(String requirement) {
    return 'Koşul karşılanmıyor: $requirement';
  }

  @override
  String get levelUpClassTargetCurrentRequirementsMissing =>
      'Mevcut sınıfınız çok sınıflılık koşulunu karşılamıyor.';

  @override
  String get levelUpConfirm => 'Seviye Atlamayı Onayla';

  @override
  String get levelUpCancel => 'İptal';

  @override
  String get levelUpStepFeatures => 'Yeni Özellikler';

  @override
  String levelUpStepSubclass(String feature) {
    return '$feature seç';
  }

  @override
  String get levelUpStepAsi => 'Nitelik Puanı Artışı';

  @override
  String get levelUpStepHp => 'Can Puanı';

  @override
  String get levelUpStepCantrips => 'Yeni Sihirbazlıklar';

  @override
  String get levelUpStepSpells => 'Yeni Büyüler';

  @override
  String get levelUpStepSummary => 'Özet';

  @override
  String get levelUpNoNewFeatures => 'Bu seviyede yeni sınıf özelliği yok.';

  @override
  String get featureChoicesTitle => 'Özellik Seçimleri';

  @override
  String get featureChoicesPending => 'Bekleyen seçim';

  @override
  String get featureChoicesEdit => 'Seçimleri düzenle';

  @override
  String get featureChoicesChooseDependencyFirst =>
      'Önce gerekli önceki seçeneği seçin.';

  @override
  String featureChoicesChooseCount(String kind, int count) {
    return '$count $kind seçin.';
  }

  @override
  String featureChoicesSelectedCount(int selected, int count) {
    return '$selected/$count seçildi';
  }

  @override
  String get levelUpHpRoll => 'At';

  @override
  String get levelUpHpAverage => 'Ortalama';

  @override
  String levelUpHpGained(int n) {
    return '+$n Can';
  }

  @override
  String levelUpHpFormula(int die, String mod) {
    return 'd$die + CON ($mod)';
  }

  @override
  String get levelUpAsiOption => 'Nitelik Puanı Artışı';

  @override
  String get levelUpFeatOption => 'Bir Marifet Seç';

  @override
  String levelUpAsiPointsLeft(int n) {
    return 'Kalan puan: $n';
  }

  @override
  String levelUpSpellsToLearn(int n) {
    return 'Öğrenmek için $n büyü seçin';
  }

  @override
  String get levelUpSpellRestrictedSection => 'Okul koşulu';

  @override
  String get levelUpSpellFreeSection => 'Serbest seçim';

  @override
  String levelUpSpellRestrictedInstruction(int count, String schools) {
    return '$schools okullarından $count büyü seçin.';
  }

  @override
  String levelUpSpellFreeInstruction(int count) {
    return 'Herhangi bir okuldan $count büyü seçin.';
  }

  @override
  String get levelUpSpellFreeLocked => 'Önce okul koşulunu tamamlayın.';

  @override
  String levelUpCantripsToLearn(int n) {
    return '$n sihirbazlık seçin';
  }

  @override
  String get levelUpSpellSwap => 'Bilinen bir büyüyü değiştir (isteğe bağlı)';

  @override
  String levelUpSpellSwapCurrent(String name) {
    return 'Şu anda: $name';
  }

  @override
  String levelUpSummaryLevel(int level) {
    return '→ Seviye $level';
  }

  @override
  String levelUpSummaryClassLevel(String className, int level) {
    return '$className seviye $level';
  }

  @override
  String levelUpSummaryHp(int n) {
    return 'Maksimum Can +$n';
  }

  @override
  String levelUpSummaryAsi(String changes) {
    return 'Nitelik Puanı Artışı: $changes';
  }

  @override
  String levelUpSummaryFeat(String name) {
    return 'Marifet: $name';
  }

  @override
  String levelUpSummarySubclass(String name) {
    return 'Alt sınıf: $name';
  }

  @override
  String levelUpSummarySpellsLearned(int count) {
    return 'Öğrenilen büyüler: $count';
  }

  @override
  String levelUpSummaryCantripsLearned(int count) {
    return 'Öğrenilen sihirbazlıklar: $count';
  }

  @override
  String levelUpSubclassAlreadyHas(String name) {
    return 'Mevcut alt sınıf: $name';
  }

  @override
  String get levelUpMaxLevel => 'Zaten en yüksek seviyede (20).';

  @override
  String get levelUpHpReroll => 'Yeniden at / değiştir';

  @override
  String get levelUpSpellSwapPickReplacement =>
      'Şimdi yerine geçecek büyüyü seçin';

  @override
  String get levelUpSpellSwapReplaceWith => 'Yerine geçecek büyü';

  @override
  String get levelUpSpellSwapNone => 'Yok';

  @override
  String get levelUpSpellAlreadyKnown => 'Zaten biliniyor';

  @override
  String levelUpSpellCantripSubtitle(String school) {
    return '$school sihirbazlığı';
  }

  @override
  String levelUpSpellSubtitle(int level, String school) {
    return 'Sv $level $school';
  }

  @override
  String get resetLevelsTitle => 'Seviyeleri sıfırla';

  @override
  String get resetLevelsConfirmBody =>
      'Bu işlem sınıf ilerlemesini 1. seviyeye sıfırlar. Notlarınız, envanteriniz, kaplarınız, paranız, görseliniz, hikâyeniz, görünüşünüz, türünüz, geçmişiniz ve nitelik puanlarınız korunur.\n\nSınıf seviyeleri, sınıf büyüleri, sınıf ve alt sınıf seçimleri, ilerleme kaynakları ve nitelik artışı marifetleri kaldırılır veya yeniden hesaplanır. Ek bir kopya istiyorsanız önce yedek dışa aktarın.';

  @override
  String resetLevelsCountdown(int seconds) {
    return '$seconds sn bekleyin';
  }

  @override
  String get resetLevelsIntro =>
      'Yeni 1. seviye sınıf bilgilerini seçin. Sıfırlama yalnızca son düğmeye bastığınızda kaydedilir.';

  @override
  String get resetLevelsSubclassRequired =>
      'Bu sınıf 1. seviyede alt sınıf seçer.';

  @override
  String resetLevelsInitialHp(int hp) {
    return 'Başlangıç Canı: $hp';
  }

  @override
  String resetLevelsSelectSkills(int count) {
    return '$count sınıf becerisi seçin.';
  }

  @override
  String get resetLevelsFixedTools => 'Otomatik olarak kazanılanlar:';

  @override
  String resetLevelsSelectTools(int count) {
    return '$count araç yetkinliği seçin.';
  }

  @override
  String get resetLevelsApply => '1. seviyeye sıfırla';

  @override
  String resetLevelsApplyAndRebuild(int level) {
    return 'Sıfırla ve $level. seviyeye kadar yeniden oluştur';
  }

  @override
  String get resetLevelsIncomplete => 'Gerekli seçimleri tamamlayın';

  @override
  String get resetLevelsApplied => 'Seviyeler sıfırlandı.';

  @override
  String resetLevelsRebuildTitle(int level) {
    return '$level. seviyeye kadar yeniden oluştur';
  }

  @override
  String resetLevelsRebuildSubtitle(int level) {
    return '1. seviyeyi seçtikten sonra uygulama $level. seviyeye kadar seviye atlama adımlarını açacak. Bitmeden iptal ederseniz hiçbir şey kaydedilmez.';
  }

  @override
  String resetLevelsRebuildStep(int level, int targetLevel) {
    return '$targetLevel seviyeden $level. seviye yeniden oluşturuluyor';
  }

  @override
  String get resetLevelsRebuildCancelled =>
      'Sıfırlama iptal edildi. Değişiklik kaydedilmedi.';

  @override
  String resetLevelsRebuiltApplied(int level) {
    return 'Seviyeler sıfırlandı ve $level. seviyeye kadar yeniden oluşturuldu.';
  }

  @override
  String get labelSubclass => 'Alt sınıf';

  @override
  String get labelLanguages => 'Diller';

  @override
  String get hintAddLanguage => 'Dil ekle…';

  @override
  String get labelChoose => 'Seç';

  @override
  String get sectionAppearance => 'Görünüş';

  @override
  String get labelAge => 'Yaş';

  @override
  String get labelHeight => 'Boy';

  @override
  String get labelWeight => 'Kilo';

  @override
  String get labelEyes => 'Gözler';

  @override
  String get labelSkin => 'Ten';

  @override
  String get labelHair => 'Saç';

  @override
  String get labelMaxHP => 'Maksimum Can';

  @override
  String get labelTempHP => 'Geçici Can';

  @override
  String get labelAmount => 'Miktar';

  @override
  String get labelSpeed => 'Hız (ft)';

  @override
  String get detailDamage => 'Hasar';

  @override
  String get detailHeal => 'İyileştir';

  @override
  String get detailNone => 'Yok';

  @override
  String get tempHpDialogTitle => 'Geçici Can Ekle';

  @override
  String get tempHpDialogTitleReplace => 'Geçici Can';

  @override
  String tempHpCurrent(int n) {
    return 'Mevcut: +$n geçici Can';
  }

  @override
  String get tempHpNoStack =>
      'Geçici Can birikmez; yalnızca daha yüksek değer mevcut değerin yerini alır.';

  @override
  String get tempHpReplace => 'Değiştir';

  @override
  String statsTempHpChip(int n) {
    return '+$n geçici';
  }

  @override
  String subclassConfirmTitle(String feature) {
    return '$feature onayla';
  }

  @override
  String subclassChooseTitle(String feature) {
    return '$feature seç';
  }

  @override
  String subclassConfirmBody(int level, String feature) {
    return '$level. seviyeye ulaştınız. $feature seçiminizi onaylayın veya değiştirin.';
  }

  @override
  String subclassChooseBody(int level, String feature) {
    return '$level. seviyeye ulaştınız! $feature seçin.';
  }

  @override
  String get subclassKeepCurrent => 'Mevcut seçimi koru';

  @override
  String get subclassChangeTitle => 'Alt sınıfı değiştir';

  @override
  String get subclassChangeWarning =>
      'Uyarı: Önceki alt sınıfın kazandırdığı büyüler ve yetkinlikler otomatik kaldırılmaz. Bunları elle düzenlemeniz gerekir.';

  @override
  String get backgroundChooseTitle => 'Geçmiş Seç';

  @override
  String get featuresTooltipAdd => 'Özellik ekle';

  @override
  String get featuresTooltipRemove => 'Kaldır';

  @override
  String get featuresTooltipEnable => 'Etkinleştir';

  @override
  String get featuresTooltipDisable => 'Devre dışı bırak';

  @override
  String get featuresTabFeats => 'Marifetler';

  @override
  String featPrerequisite(String req) {
    return 'Ön koşul: $req';
  }

  @override
  String get featuresSectionFeats => 'Marifetler';

  @override
  String get featuresTabClass => 'Sınıf';

  @override
  String get featuresTabRacial => 'Irksal';

  @override
  String get featuresTabCustom => 'Özel';

  @override
  String get featuresTabTools => 'Araçlar';

  @override
  String get featuresRemoveTitle => 'Özellik kaldırılsın mı?';

  @override
  String featuresRemoveContent(String name) {
    return '\"$name\" kaldırılacak.';
  }

  @override
  String get featuresNoneAvailable => 'Kullanılabilir özellik yok.';

  @override
  String get featuresAddLabel => 'Özellik Ekle';

  @override
  String get featuresLoadError => 'Özellikler yüklenirken hata oluştu.';

  @override
  String get hintSearch => 'Ara...';

  @override
  String get labelFeatureName => 'Ad';

  @override
  String get labelFeatureDescription => 'Açıklama (isteğe bağlı)';

  @override
  String get labelFeatureType => 'Tür:';

  @override
  String get labelPassive => 'Pasif';

  @override
  String get labelActive => 'Etkin';

  @override
  String get spellsTooltipAdd => 'Büyü ekle';

  @override
  String get spellsRemoveTitle => 'Büyü kaldırılsın mı?';

  @override
  String spellsRemoveContent(String name) {
    return '\"$name\" büyü listenizden kaldırılsın mı?';
  }

  @override
  String get spellsAtWill => 'İstendiğinde';

  @override
  String get notesTooltipAdd => 'Not ekle';

  @override
  String get notesTooltipEdit => 'Notu düzenle';

  @override
  String get notesTooltipDelete => 'Notu sil';

  @override
  String get notesEmptyTitle => 'Henüz not yok';

  @override
  String get notesEmptyHint =>
      'İlk notunuzu oluşturmak için + düğmesine dokunun.';

  @override
  String get notesUntitled => 'Başlıksız';

  @override
  String get notesDeleteTitle => 'Not silinsin mi?';

  @override
  String notesDeleteContentNamed(String title) {
    return '\"$title\" kalıcı olarak silinecek.';
  }

  @override
  String get notesDeleteContent => 'Bu not kalıcı olarak silinecek.';

  @override
  String get notesLabelTitle => 'Başlık';

  @override
  String get notesLabelContent => 'İçerik';

  @override
  String get notesSearchHint => 'Notlarda veya etiketlerde ara';

  @override
  String get notesNoResultsTitle => 'Eşleşen not yok';

  @override
  String get notesNoResultsHint =>
      'Başka bir arama deneyin veya etiket filtresini temizleyin.';

  @override
  String get notesReadMore => 'Devamını oku';

  @override
  String get notesTags => 'Etiketler';

  @override
  String get notesAllTags => 'Tümü';

  @override
  String get notesCustomTag => 'Özel etiket';

  @override
  String get notesAddTag => 'Etiket ekle';

  @override
  String get notesTagColor => 'Etiket rengi';

  @override
  String get notesChooseTagColor => 'Etiket rengini seç';

  @override
  String get notesTooltipPin => 'Notu sabitle';

  @override
  String get notesTooltipUnpin => 'Notun sabitlemesini kaldır';

  @override
  String get notesMoveUp => 'Yukarı taşı';

  @override
  String get notesMoveDown => 'Aşağı taşı';

  @override
  String get notesMoreActions => 'Diğer işlemler';

  @override
  String get notesPinnedSection => 'Sabitlenenler';

  @override
  String get notesOtherSection => 'Notlar';

  @override
  String get notesDefaultTagSession => 'Oturum';

  @override
  String get notesDefaultTagNpc => 'NPC';

  @override
  String get notesDefaultTagQuest => 'Görev';

  @override
  String get notesDefaultTagPlace => 'Yer';

  @override
  String get notesDefaultTagLoot => 'Ganimet';

  @override
  String get notesDefaultTagRule => 'Kural';

  @override
  String get sectionPersonalityTraits => 'Kişilik Özellikleri';

  @override
  String get sectionPersonality => 'Kişilik';

  @override
  String get sectionIdeals => 'İdealler';

  @override
  String get sectionBonds => 'Bağlar';

  @override
  String get sectionFlaws => 'Kusurlar';

  @override
  String get sectionBackstory => 'Geçmiş Hikâyesi';

  @override
  String inventoryEquippedSection(int count, int ac) {
    return 'Kuşanılanlar ($count)  ·  ZS $ac';
  }

  @override
  String get inventoryTooltipAdd => 'Eşya ekle';

  @override
  String get inventoryTooltipRemove => 'Kaldır';

  @override
  String get inventoryTooltipMove => 'Taşı';

  @override
  String inventoryMoveTitle(String name) {
    return '$name taşı';
  }

  @override
  String get inventoryMoveToInventory => 'Envanter';

  @override
  String inventoryContainersSection(int count) {
    return 'Kaplar ($count)';
  }

  @override
  String inventoryContainerContents(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count eşya',
      one: '1 eşya',
    );
    return '$_temp0';
  }

  @override
  String get inventoryContainerEmpty => 'Boş';

  @override
  String get inventoryRemoveTitle => 'Eşya kaldırılsın mı?';

  @override
  String inventoryRemoveContent(String name) {
    return '$name envanterden kaldırılsın mı?';
  }

  @override
  String inventoryRemovePartial(int count, int total) {
    return 'Kaldırılacak: $total eşyanın $count tanesi';
  }

  @override
  String get inventoryRemoveContainerTitle => 'Kap silinsin mi?';

  @override
  String inventoryRemoveContainerContent(String name, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count eşya',
      one: '1 eşya',
    );
    return '$name içinde $_temp0 var. Bunlara ne yapılsın?';
  }

  @override
  String get inventoryRemoveContainerMoveContents => 'Eşyaları envantere taşı';

  @override
  String get inventoryRemoveContainerDeleteContents => 'Hepsini kaldır';

  @override
  String get inventoryLabelQuantity => 'Adet:';

  @override
  String get inventoryLabelQuantityToRemove => 'Kaldırılacak adet';

  @override
  String get inventoryAddCustomItem => 'Özel Eşya Ekle';

  @override
  String get inventoryAddItem => 'Eşya Ekle';

  @override
  String get inventoryLabelItemName => 'Ad *';

  @override
  String get inventoryLabelType => 'Tür';

  @override
  String get inventoryLabelCategory => 'Kategori';

  @override
  String get inventoryLabelItemQuantity => 'Adet';

  @override
  String get inventoryLabelWeight => 'Ağırlık';

  @override
  String get weightCarried => 'Taşınan';

  @override
  String get weightCapacity => 'Kapasite';

  @override
  String get weightEncumbered => 'Yük altında';

  @override
  String get weightHeavilyEncumbered => 'Ağır yük altında';

  @override
  String get weightEnableTooltip => 'Ağırlık takibini aç';

  @override
  String get weightDisableTooltip => 'Ağırlık takibini kapat';

  @override
  String get inventoryLabelDescription => 'Açıklama (isteğe bağlı)';

  @override
  String get inventoryTypeWeapon => 'Silah';

  @override
  String get inventoryTypeArmor => 'Zırh';

  @override
  String get inventoryTypeConsumable => 'Tüketilebilir';

  @override
  String get inventoryTypeGear => 'Ekipman';

  @override
  String get inventoryTypeEquippable => 'Kuşanılabilir';

  @override
  String get inventoryTypeContainer => 'Kap';

  @override
  String get inventoryAddItemError => 'Eşya eklenemedi.';

  @override
  String inventoryLoadItemsError(String error) {
    return 'Eşyalar yüklenirken hata oluştu:\n$error';
  }

  @override
  String inventoryNoResults(String query) {
    return '\"$query\" için sonuç yok';
  }

  @override
  String get inventoryTooltipEquip => 'Kuşan';

  @override
  String get inventoryTooltipUnequip => 'Çıkar';

  @override
  String get inventoryCustomDamageDice => 'Hasar (ör. 1d8)';

  @override
  String get inventoryCustomDamageType => 'Hasar türü';

  @override
  String get inventoryCustomWeaponProperties => 'Özellikler (virgülle ayırın)';

  @override
  String get inventoryCustomRangeNormal => 'Normal menzil';

  @override
  String get inventoryCustomRangeLong => 'Uzun menzil';

  @override
  String get inventoryCustomAddDexToAc => 'ZS\'ye ÇEV ekle';

  @override
  String get inventoryCustomEquipSlot => 'Konum (ör. yüzük, boyun)';

  @override
  String get inventoryCustomCompatibleWith =>
      'Uyumlu olduğu şeyler (virgülle ayırın)';

  @override
  String get inventoryDetailYes => 'Evet';

  @override
  String get inventoryDetailNo => 'Hayır';

  @override
  String get inventoryDetailMaxShort => 'en fazla';

  @override
  String get inventoryDetailDamage => 'Hasar';

  @override
  String get inventoryDetailDamageType => 'Hasar türü';

  @override
  String get inventoryDetailWeaponProperties => 'Özellikler';

  @override
  String get inventoryDetailVersatileDamage => 'Çok yönlü hasar';

  @override
  String get inventoryDetailRange => 'Menzil';

  @override
  String get inventoryDetailRangeNormal => 'normal';

  @override
  String get inventoryDetailRangeLong => 'uzun';

  @override
  String get inventoryDetailArmorType => 'Zırh türü';

  @override
  String get inventoryDetailShield => 'Kalkan';

  @override
  String get inventoryDetailBaseAc => 'Temel ZS';

  @override
  String get inventoryDetailAcBonus => 'ZS bonusu';

  @override
  String get inventoryDetailAddDexToAc => 'ZS\'ye ÇEV ekler';

  @override
  String get inventoryDetailMaxDex => 'Azami ÇEV';

  @override
  String get inventoryDetailStrengthMinimum => 'Asgari Güç';

  @override
  String get inventoryDetailEquipSlot => 'Konum';

  @override
  String get inventoryDetailRequiresAttunement => 'Uyumlanma gerektirir';

  @override
  String get inventoryDetailCapacityWeight => 'Ağırlık kapasitesi';

  @override
  String get inventoryDetailCapacityVolume => 'Hacim';

  @override
  String get inventoryDetailCapacityVolumeUnit => 'Hacim birimi';

  @override
  String get inventoryDetailIgnoreContentWeight =>
      'İçindekilerin ağırlığını yok sayar';

  @override
  String get inventoryDetailEffect => 'Etki';

  @override
  String get inventoryDetailUses => 'Kullanım';

  @override
  String get inventoryDetailAction => 'Eylem';

  @override
  String get inventoryDetailAmmoType => 'Mühimmat türü';

  @override
  String get inventoryDetailCompatibleWith => 'Uyumlu olduğu şeyler';

  @override
  String get inventoryDetailBonus => 'Bonus';

  @override
  String get inventoryDetailExtraDamage => 'Ek hasar';

  @override
  String get inventoryDetailExtraDamageType => 'Ek hasar türü';

  @override
  String get inventoryDetailSubtype => 'Alt tür';

  @override
  String get inventoryDetailCost => 'Fiyat';

  @override
  String get inventoryDetailRarity => 'Nadirlik';

  @override
  String get inventoryDetailFeatures => 'Özellikler';

  @override
  String get inventoryDetailWeightEach => 'Eşya başına ağırlık';

  @override
  String get inventoryDetailWeightTotal => 'Toplam ağırlık';

  @override
  String get inventoryDetailState => 'Durum';

  @override
  String get inventoryDetailEquipped => 'Kuşanılmış';

  @override
  String get inventoryDetailNotEquipped => 'Kuşanılmamış';

  @override
  String get inventoryDetailSummary => 'Özet';

  @override
  String get inventoryDetailDescription => 'Açıklama';

  @override
  String get inventoryDetailAttributes => 'Nitelikler';

  @override
  String get inventoryReplaceArmorTitle => 'Kuşanılmış zırh değiştirilsin mi?';

  @override
  String get inventoryTabWeapons => 'Silahlar';

  @override
  String get inventoryTabArmor => 'Zırh';

  @override
  String get inventoryTabGear => 'Ekipman';

  @override
  String get inventoryTabMagic => 'Büyülü';

  @override
  String get inventoryTabTools => 'Araçlar';

  @override
  String get inventoryTabCustom => 'Özel';

  @override
  String hintSearchCategory(String category) {
    return '$category ara...';
  }

  @override
  String get stepChooseMethod => 'Yönteminizi seçin:';

  @override
  String get stepStandardArray => 'Standart Dizi';

  @override
  String get stepPointBuy => 'Puan Satın Alma';

  @override
  String get stepRoll4d6 => '4d6 At';

  @override
  String get stepDistributeRacialBonuses => 'Irksal bonusları serbestçe dağıt';

  @override
  String get stepAssignRolls => 'Her zar sonucunu bir niteliğe ata:';

  @override
  String get stepAssignValues => 'Her değeri bir niteliğe ata:';

  @override
  String get stepPointsRemaining => 'Kalan puan: ';

  @override
  String stepRaceBonus(int n) {
    return '+$n ırk';
  }

  @override
  String get stepChooseSubrace => 'Alt ırk seçin:';

  @override
  String get stepGrantedByBackground => 'Geçmişten kazanılan:';

  @override
  String stepClassSkillChoices(int count) {
    return 'Sınıf becerisi seçimleri ($count):';
  }

  @override
  String get stepChooseOne => 'Birini seçin';

  @override
  String get stepSelectTool => 'Araç seçin…';

  @override
  String get statAC => 'ZS';

  @override
  String get statArmor => 'Zırh';

  @override
  String get statNoArmor => 'Zırhsız';

  @override
  String get statNoArmorShield => 'Zırhsız + Kalkan';

  @override
  String get statShieldSuffix => ' + Kalkan';

  @override
  String get statSpeed => 'Hız';

  @override
  String get statInitiative => 'Girişim';

  @override
  String get statProfBonus => 'Yetkinlik Bonusu';

  @override
  String get statPassivePerc => 'Pasif Algı';

  @override
  String get statInspiration => 'İlham';

  @override
  String get statXP => 'XP';

  @override
  String get inspirationGranted => 'Verildi';

  @override
  String get inspirationNotGranted => 'Verilmedi';

  @override
  String statLevel(int level) {
    return 'Seviye $level';
  }

  @override
  String get tooltipAddXp => 'XP Ekle';

  @override
  String get labelLevelTable => 'Seviye Tablosu';

  @override
  String get statUnconsciousDying => 'Bilinçsiz / Ölmek Üzere';

  @override
  String get deathSavesTitle => 'Ölüm Kurtarma Atışları';

  @override
  String get deathSavesSuccesses => 'Başarılar';

  @override
  String get deathSavesFailures => 'Başarısızlıklar';

  @override
  String get deathSavesStabilized => 'Stabil';

  @override
  String get deathSavesDead => 'Ölü';

  @override
  String get sectionActiveConditions => 'Etkin Durumlar';

  @override
  String get conditionsNone => 'Etkin durum yok';

  @override
  String get conditionsAdd => 'Durum ekle';

  @override
  String get conditionsPickTitle => 'Durum Uygula';

  @override
  String get conditionsRemove => 'Durumu kaldır';

  @override
  String get tooltipAddTempHp => 'Geçici Can ekle';

  @override
  String get tooltipChangeTempHp => 'Geçici Canı değiştir';

  @override
  String get abilityStr => 'GÜÇ';

  @override
  String get abilityDex => 'ÇEV';

  @override
  String get abilityCon => 'DAY';

  @override
  String get abilityInt => 'ZEK';

  @override
  String get abilityWis => 'BİL';

  @override
  String get abilityCha => 'KAR';

  @override
  String featuresSectionRacialTraits(String name) {
    return 'Irksal Özellikler — $name';
  }

  @override
  String featuresSectionBackground(String name) {
    return 'Geçmiş Özelliği — $name';
  }

  @override
  String featuresSectionClass(String name) {
    return 'Sınıf Özellikleri — $name';
  }

  @override
  String featuresSectionSubclass(String name) {
    return 'Alt Sınıf Özellikleri — $name';
  }

  @override
  String get featuresSectionTools => 'Araç Yetkinlikleri';

  @override
  String get featuresSectionExtra => 'Ek Özellikler';

  @override
  String get spellsNoSpellcasting => 'Büyü Kullanımı Yok';

  @override
  String get spellsNoSpellcastingDesc =>
      'Bu sınıfın büyü kullanma özelliği yok.';

  @override
  String get spellsSlots => 'Büyü Yuvaları';

  @override
  String get spellsPactMagicSlots => 'Pakt Büyüsü';

  @override
  String get spellsSpellcasting => 'Büyü Kullanımı';

  @override
  String get spellsAttack => 'Saldırı';

  @override
  String get spellsSaveDC => 'Kurtarma ZS';

  @override
  String get spellsCantrips => 'Sihirbazlıklar';

  @override
  String get spellsPrepared => 'Hazırlanmış';

  @override
  String get spellsKnown => 'Bilinen';

  @override
  String get spellsEmpty =>
      'Henüz büyü eklenmedi.\nBüyülere göz atmak için + düğmesine dokunun.';

  @override
  String spellsSlotLevel(int level) {
    return 'Sv $level';
  }

  @override
  String spellsLevelN(int level) {
    return 'Seviye $level';
  }

  @override
  String get spellsInnateHeader => 'Irksal Büyüler';

  @override
  String get spellsDisableTitle => 'Büyü devre dışı bırakılsın mı?';

  @override
  String get spellsEnableTitle => 'Büyü etkinleştirilsin mi?';

  @override
  String spellsDisableContent(String name) {
    return '\"$name\" devre dışı bırakılsın mı? Gri görünecek ve hazırlanamayacak.';
  }

  @override
  String spellsEnableContent(String name) {
    return '\"$name\" etkinleştirilsin mi? Yeniden normal görünecek.';
  }

  @override
  String get spellsDisable => 'Devre dışı bırak';

  @override
  String get spellsEnable => 'Etkinleştir';

  @override
  String get spellsExtrasHeader => 'Ek Büyüler';

  @override
  String get spellFilterTitle => 'Filtreler';

  @override
  String get spellFilterReset => 'Sıfırla';

  @override
  String get spellFilterApply => 'Filtreleri Uygula';

  @override
  String get spellFilterSectionClasses => 'Sınıflar';

  @override
  String get spellFilterClassesHint =>
      'Sınıf seçilmezse tüm sınıflar gösterilir';

  @override
  String get spellFilterSectionLevel => 'Büyü Seviyesi';

  @override
  String get spellFilterShowAllLevels => 'Tüm büyü seviyelerini göster';

  @override
  String spellFilterShowAllLevelsHint(int max) {
    return 'Mevcut üst sınırınızın (Sv $max) üzerindeki büyüleri de dahil et';
  }

  @override
  String get spellFilterCantrip => 'Sihirbazlık';

  @override
  String spellFilterLvl(int n) {
    return 'Sv $n';
  }

  @override
  String get spellFilterSectionCastingTime => 'Büyü Yapma Süresi';

  @override
  String get spellFilterCastAction => 'Eylem';

  @override
  String get spellFilterCastBonus => 'Ek eylem';

  @override
  String get spellFilterCastReaction => 'Tepki';

  @override
  String get spellFilterCastLonger => 'Uzun süreli büyü (1 dk+)';

  @override
  String get spellFilterSectionProperties => 'Özellikler';

  @override
  String get spellFilterConcentration => 'Konsantrasyon';

  @override
  String get spellFilterConcentrationHint =>
      'Yalnızca konsantrasyon gerektiren büyüler';

  @override
  String get spellFilterRitual => 'Ritüel';

  @override
  String get spellFilterRitualHint =>
      'Yalnızca ritüel olarak yapılabilen büyüler';

  @override
  String get spellFilterSectionSchool => 'Büyü Okulu';

  @override
  String get spellRemoveTitle => 'Büyüyü kaldır';

  @override
  String spellRemoveContent(String name) {
    return '\"$name\" büyü listenizden kaldırılsın mı?';
  }

  @override
  String get spellActionPrepared =>
      'Hazırlandı — hazırlamayı kaldırmak için dokunun';

  @override
  String get spellActionPrepare => 'Bugün için hazırla';

  @override
  String get spellActionAdd => 'Karaktere ekle';

  @override
  String get spellActionInList => 'Büyü listenizde — kaldırmak için dokunun';

  @override
  String get spellActionAlreadyInList => 'Zaten büyü listenizde';

  @override
  String get spellActionClassSpellInfo =>
      'Bu büyü zaten sınıf listenizin parçası; ayrıca öğrenilmesi gerekmiyor.';

  @override
  String get inventoryCurrency => 'Para';

  @override
  String inventoryCarriedSection(int count) {
    return 'Taşınanlar ($count)';
  }

  @override
  String inventoryEquippableSection(int count) {
    return 'Kuşanılabilirler ($count)';
  }

  @override
  String get inventoryEquipHint =>
      'Kuşanmak veya çıkarmak için soldaki daire simgesine dokunun';

  @override
  String get inventoryInventory => 'Envanter';

  @override
  String get inventoryEmpty =>
      'Henüz eşya yok. Eklemek için + düğmesine dokunun.';

  @override
  String get inventoryAmmunition => 'Mühimmat';

  @override
  String get coinCopper => 'Bakır';

  @override
  String get coinSilver => 'Gümüş';

  @override
  String get coinElectrum => 'Elektrum';

  @override
  String get coinGold => 'Altın';

  @override
  String get coinPlatinum => 'Platin';

  @override
  String get inventoryGroupSimpleMelee => 'Basit Yakın Dövüş';

  @override
  String get inventoryGroupSimpleRanged => 'Basit Menzilli';

  @override
  String get inventoryGroupMartialMelee => 'Savaş Yakın Dövüş';

  @override
  String get inventoryGroupMartialRanged => 'Savaş Menzilli';

  @override
  String get inventoryGroupLightArmor => 'Hafif Zırh';

  @override
  String get inventoryGroupMediumArmor => 'Orta Zırh';

  @override
  String get inventoryGroupHeavyArmor => 'Ağır Zırh';

  @override
  String get inventoryGroupShields => 'Kalkanlar';

  @override
  String get inventoryGroupAdventuringGear => 'Maceracı Ekipmanı';

  @override
  String get inventoryGroupAmmunition => 'Mühimmat';

  @override
  String get inventoryGroupArcaneFocus => 'Büyü Odağı';

  @override
  String get inventoryGroupClothing => 'Giysiler';

  @override
  String get inventoryGroupContainer => 'Kap';

  @override
  String get inventoryGroupPoison => 'Zehir';

  @override
  String get inventoryGroupPotions => 'İksirler';

  @override
  String get inventoryGroupRings => 'Yüzükler';

  @override
  String get inventoryGroupWands => 'Asalar';

  @override
  String get inventoryGroupWeapons => 'Silahlar';

  @override
  String get inventoryGroupArmor => 'Zırh';

  @override
  String get inventoryGroupWondrousItems => 'Harikulade Eşyalar';

  @override
  String get inventoryGroupArtisansTools => 'Zanaatkâr Araçları';

  @override
  String get inventoryGroupGamingSets => 'Oyun Setleri';

  @override
  String get inventoryGroupMusicalInstruments => 'Müzik Aletleri';

  @override
  String get inventoryGroupOtherTools => 'Diğer Araçlar';

  @override
  String get armorStealthDisadvantage => 'Gizlilikte dezavantaj';

  @override
  String get spellDetailCastingTime => 'Büyü yapma süresi';

  @override
  String get spellDetailRange => 'Menzil';

  @override
  String get spellRangeSelf => 'Kendisi';

  @override
  String get spellRangeTouch => 'Dokunma';

  @override
  String get spellRangeSight => 'Görüş';

  @override
  String get spellRangeSpecial => 'Özel';

  @override
  String get spellRangeUnlimited => 'Sınırsız';

  @override
  String get spellAreaSphere => 'küre';

  @override
  String get spellAreaCone => 'koni';

  @override
  String get spellAreaCube => 'küp';

  @override
  String get spellAreaCylinder => 'silindir';

  @override
  String get spellAreaLine => 'çizgi';

  @override
  String get spellAreaWall => 'duvar';

  @override
  String get spellAreaCircle => 'daire';

  @override
  String get spellDetailDuration => 'Süre';

  @override
  String get spellDetailComponents => 'Bileşenler';

  @override
  String get spellDetailConcentration => 'Konsantrasyon gerektirir';

  @override
  String get spellDetailRitual => 'Ritüel olarak yapılabilir';

  @override
  String get spellDetailAtHigherLevels => 'Daha Yüksek Seviyelerde. ';

  @override
  String spellDetailClasses(String classes) {
    return 'Sınıflar: $classes';
  }

  @override
  String spellDetailLevelSchool(String ordinal, String school) {
    return '$ordinal. seviye $school';
  }

  @override
  String spellDetailCantrip(String school) {
    return '$school sihirbazlığı';
  }

  @override
  String armorSwapCurrent(String name) {
    return 'Mevcut: $name';
  }

  @override
  String armorSwapAcNow(int ac) {
    return 'Şimdiki ZS: $ac';
  }

  @override
  String armorSwapAcAfter(int ac) {
    return 'Sonraki ZS: $ac';
  }

  @override
  String get armorSwapButton => 'Zırhı değiştir';

  @override
  String get reviewRowName => 'Ad';

  @override
  String get reviewUnnamedHero => 'Adsız Kahraman';

  @override
  String get reviewRowPlayer => 'Oyuncu';

  @override
  String get reviewRowSubclass => 'Alt sınıf';

  @override
  String get reviewRowHitDie => 'Can Zarı';

  @override
  String get reviewRowSavingThrows => 'Kurtarma Atışları';

  @override
  String get reviewRowSubrace => 'Alt ırk';

  @override
  String get reviewRowSpeed => 'Hız';

  @override
  String get reviewRowLanguages => 'Diller';

  @override
  String get reviewRowFeature => 'Özellik';

  @override
  String get reviewRowFromBackground => 'Geçmişten';

  @override
  String get reviewRowClassChoices => 'Sınıf seçimleri';

  @override
  String get reviewRowMaxHp => 'Maksimum Can';

  @override
  String get reviewRowAcUnarmored => 'ZS (Zırhsız)';

  @override
  String reviewRowAcWith(String name) {
    return '$name ile ZS';
  }

  @override
  String get reviewRowProficiencyBonus => 'Yetkinlik Bonusu';

  @override
  String get reviewStartingGold => 'Başlangıç Altını';

  @override
  String get reviewStartingEquipment => 'Başlangıç Ekipmanı';

  @override
  String get reviewDeselectAll => 'Tüm seçimleri kaldır';

  @override
  String get reviewSelectAll => 'Tümünü seç';

  @override
  String get reviewUncheckHint =>
      'Envanterinize eklemek istemediğiniz eşyaların işaretini kaldırın.';

  @override
  String get reviewEquipmentChoices => 'Ekipman Seçimleri';

  @override
  String get reviewEquipmentChoicesHint =>
      'Her yer için belirli bir eşya seçin.';

  @override
  String get reviewToolProficiencies => 'Araç Yetkinlikleri';

  @override
  String get reviewChooseToolProficiency => 'Araç yetkinliğinizi seçin:';

  @override
  String reviewChooseLanguages(int count) {
    return 'Irkınızın veya geçmişinizin kazandırdığı $count dil seçin.';
  }

  @override
  String get reviewChooseOne => 'Birini seçin:';

  @override
  String get stepTashaRule =>
      'Tasha\'nın isteğe bağlı kuralı — nitelik artışı puanlarını istediğiniz niteliğe verin';

  @override
  String get stepRollDice => 'Zar at';

  @override
  String get stepReroll => 'Yeniden at';

  @override
  String get stepRollHint =>
      '6 değer üretmek için zar atın (4d6, en düşüğü çıkarın)';

  @override
  String get stepPrimaryAbilities => 'öncelikli nitelikler: ';

  @override
  String get stepNameTitle => 'Karakterinize bir ad verin.';

  @override
  String get stepNameHint => 'Bunu daha sonra değiştirebilirsiniz.';

  @override
  String get stepNameCharLabel => 'Karakter adı';

  @override
  String get stepNamePlayerLabel => 'Oyuncu adı (isteğe bağlı)';

  @override
  String get stepHitDieLabel => 'Can zarı';

  @override
  String get stepSavesLabel => 'Kurtarmalar';

  @override
  String get stepSpellcastingLabel => 'Büyü kullanımı';

  @override
  String get stepOptionsLabel => 'seçenekler';

  @override
  String stepChooseSubclassPrompt(String feature, int level) {
    return '$feature seçin (Sv $level):';
  }

  @override
  String get stepRaceSpeedLabel => 'Hız';

  @override
  String get stepRaceASILabel => 'Nitelik Artışı';

  @override
  String stepRaceSubracesAvailable(int count) {
    return 'Kullanılabilir alt ırk: $count';
  }

  @override
  String stepChooseSkillsHint(int count) {
    return 'Sınıf listenizden $count beceri seçin.';
  }

  @override
  String get abilityStrength => 'Güç';

  @override
  String get abilityDexterity => 'Çeviklik';

  @override
  String get abilityConstitution => 'Dayanıklılık';

  @override
  String get abilityIntelligence => 'Zekâ';

  @override
  String get abilityWisdom => 'Bilgelik';

  @override
  String get abilityCharisma => 'Karizma';

  @override
  String stepFreeAsiRemaining(int remaining) {
    return 'Irksal nitelik artışı puanlarını serbestçe dağıtın ($remaining kaldı):';
  }

  @override
  String stepFreePicksRemaining(int total, int remaining) {
    return 'Irksal serbest nitelik artışı: $total niteliğe +1 verin ($remaining kaldı):';
  }

  @override
  String get stepFreePicksNoStack =>
      'Zaten ırksal bonus alan niteliklere atanamaz.';

  @override
  String reviewClassEquipmentTitle(String name) {
    return 'Sınıf Ekipmanı — $name';
  }

  @override
  String get reviewEquipmentIncluded => 'Dahil olanlar:';

  @override
  String get stepToolCategoryGamingSet => 'Oyun seti';

  @override
  String get stepToolCategoryInstrument => 'Müzik aleti';

  @override
  String get stepToolCategoryArtisanTool => 'Zanaatkâr aracı';

  @override
  String get stepToolCategoryArtisanOrInstrument =>
      'Zanaatkâr aracı veya müzik aleti';

  @override
  String exportCopied(String label) {
    return '$label kopyalandı!';
  }

  @override
  String exportDialogTitle(String name) {
    return '$name Dışa Aktar';
  }

  @override
  String get exportShowJson => 'JSON\'u Göster';

  @override
  String get exportCopyJson => 'JSON\'u Kopyala';

  @override
  String get exportSectionFile => 'Tam dosya';

  @override
  String get exportSectionFileCaption => 'Karakter fotoğrafını içerir';

  @override
  String get exportShareFile => '.dndchar paylaş';

  @override
  String get dialogClose => 'Kapat';

  @override
  String get importDialogTitle => 'Karakter veya Yedek İçe Aktar';

  @override
  String get importUseJson => 'Doğrudan JSON kullan';

  @override
  String get importJsonHint => 'JSON\'u buraya yapıştırın…';

  @override
  String get importPickFile => '.dndchar veya .dndbackup dosyası seç';

  @override
  String get importFileError =>
      'Geçersiz veya bozuk .dndchar/.dndbackup dosyası';

  @override
  String get importFileIncoming => 'Dosyadan karakter içe aktarılsın mı?';

  @override
  String get dialogImport => 'İçe Aktar';

  @override
  String get spellBrowserTitle => 'Büyülere Göz At';

  @override
  String get spellBrowserFilters => 'Filtreler';

  @override
  String get spellBrowserSearchHint => 'Büyü ara...';

  @override
  String get filterClearAll => 'Tümünü temizle';

  @override
  String get loadingLabel => 'Yükleniyor...';

  @override
  String spellBrowserCount(int count, String s) {
    return '$count büyü';
  }

  @override
  String get spellBrowserEmpty => 'Geçerli filtrelerle eşleşen büyü yok.';

  @override
  String get spellCantrip => 'Sihirbazlık';

  @override
  String spellLevelN(int n) {
    return 'Sv $n';
  }

  @override
  String get castingTimeAction => 'Eylem';

  @override
  String get castingTimeBonusAction => 'Ek eylem';

  @override
  String get castingTimeReaction => 'Tepki';

  @override
  String get castingTimeLonger => 'Uzun süreli büyü';

  @override
  String get filterConcentration => 'Konsantrasyon';

  @override
  String get filterRitual => 'Ritüel';

  @override
  String get filterAllLevels => 'Tüm seviyeler';

  @override
  String get avatarChoosePhoto => 'Fotoğraf seç';

  @override
  String get avatarRemovePhoto => 'Fotoğrafı kaldır';

  @override
  String get avatarCropPhoto => 'Fotoğrafı kırp';

  @override
  String get avatarChangePhoto => 'Fotoğrafı değiştir';

  @override
  String get avatarSavePhoto => 'Fotoğrafı kaydet';

  @override
  String get avatarSaveSuccess => 'Fotoğraf galeriye kaydedildi';

  @override
  String get avatarSaveError => 'Fotoğraf kaydedilemedi';

  @override
  String featureAddedSnackbar(String name) {
    return '$name eklendi!';
  }

  @override
  String get featureAddButton => 'Özellik Ekle';

  @override
  String get reviewLanguageChoices => 'Dil Seçimleri';

  @override
  String get reviewLanguageTypeHint => 'Bir dil yazın…';

  @override
  String get avatarRemoveConfirmTitle => 'Fotoğraf kaldırılsın mı?';

  @override
  String get avatarRemoveConfirmBody => 'Bu işlem geri alınamaz.';

  @override
  String get editModeBanner => 'Düzenleniyor';

  @override
  String get detailSheetInfoTooltip => 'Ayrıntılar';

  @override
  String get detailSheetProficiencies => 'Yetkinlikler';

  @override
  String get detailSheetTraits => 'Özellikler';

  @override
  String get detailSheetSubclassFeaturePlaceholder => 'Alt Sınıf Özelliği';

  @override
  String detailSheetAvailableSubclasses(String feature) {
    return 'Kullanılabilir $feature';
  }

  @override
  String get detailSheetAvailableSubraces => 'Alt ırklar';

  @override
  String get xpTrackingLabel => 'XP\'yi takip et';

  @override
  String get xpReadyToLevelUp => 'Seviye atlamaya hazır!';

  @override
  String get xpLevelUpNowTitle => 'Seviye atlansın mı?';

  @override
  String xpLevelUpNowMessage(int level) {
    return '$level. seviyeye ulaşmak için yeterli XP\'niz var. Şimdi seviye atlamak ister misiniz?';
  }

  @override
  String get xpLevelUpLater => 'Sonra';

  @override
  String get settingsSectionUnits => 'Birimler';

  @override
  String get settingsUnitSystem => 'Birim sistemi';

  @override
  String get settingsUnitImperial => 'İmparatorluk (ft / lb)';

  @override
  String get settingsUnitMetric => 'Metrik (m / kg)';

  @override
  String get settingsUnitSquares => 'Kare (kare / kg)';

  @override
  String get settingsChooseUnitSystem => 'Birim Sistemini Seç';

  @override
  String get settingsSectionCharacterSheet => 'Karakter Sayfası';

  @override
  String get settingsKeepScreenOnTitle => 'Ekranı açık tut';

  @override
  String get settingsKeepScreenOnSubtitle =>
      'Karakter sayfası açıkken ekranın uykuya geçmesini önle.';

  @override
  String get settingsContextualRollAskTitle =>
      'Bağlamsal zar seçeneklerini göster';

  @override
  String get settingsContextualRollAskSubtitle =>
      'Sayfadan zar atmadan önce avantaj veya dezavantaj gibi ilgili seçimleri sor.';

  @override
  String get settingsContextualCriticalRuleTitle => 'Kritik vuruş kuralı';

  @override
  String get settingsContextualCriticalRuleSubtitle =>
      'Saldırı zarında doğal 20 gelince otomatik uygulanır.';

  @override
  String get settingsContextualCriticalRuleChoose =>
      'Kritik vuruş kuralını seç';

  @override
  String get settingsContextualCriticalRuleDoubleDice =>
      'Hasar zarlarını iki kat sayıda at';

  @override
  String get settingsContextualCriticalRuleDoubleDamage =>
      'Toplam hasarı ikiye katla';

  @override
  String get settingsBackupSection => 'Yedekleme';

  @override
  String get settingsBackupExportTitle => 'Yedeği dışa aktar';

  @override
  String get settingsBackupExportSubtitle =>
      'Tüm karakterleri bir yedek dosyasına kaydet.';

  @override
  String get settingsBackupExporting => 'Yedek oluşturuluyor...';

  @override
  String get settingsBackupExportSuccess => 'Yedek dışa aktarıldı.';

  @override
  String get settingsBackupExportError => 'Yedek dışa aktarılamadı.';

  @override
  String get settingsBackupImportTitle => 'Yedeği içe aktar';

  @override
  String get settingsBackupImportSubtitle =>
      'Karakterleri bir .dndbackup dosyasından geri yükle.';

  @override
  String get settingsBackupImporting => 'Yedek içe aktarılıyor...';

  @override
  String get settingsBackupImportError => 'Yedek içe aktarılamadı.';

  @override
  String settingsBackupImportSuccess(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Yedekten $count karakter içe aktarıldı.',
      one: 'Yedekten 1 karakter içe aktarıldı.',
    );
    return '$_temp0';
  }

  @override
  String get settingsSectionApp => 'Uygulama';

  @override
  String get settingsReviewTitle => 'Play Store\'da değerlendir';

  @override
  String get settingsReviewSubtitle =>
      'Puan veya yorum bırakmak için uygulama sayfasını aç.';

  @override
  String get settingsReviewOpenError => 'Play Store açılamadı.';

  @override
  String get settingsMaintenanceSection => 'Bakım';

  @override
  String get settingsMaintenanceCheckTitle =>
      'Karakter güncellemelerini denetle';

  @override
  String get settingsMaintenanceCheckSubtitle =>
      'Kaydedilmiş verilerdeki düzeltmeleri ara.';

  @override
  String get settingsMaintenanceUpdateTitle => 'Karakterleri güncelle';

  @override
  String get settingsMaintenanceWorking => 'Güncellemeler denetleniyor...';

  @override
  String get settingsMaintenanceNoUpdates => 'Tüm karakterler zaten güncel.';

  @override
  String get settingsMaintenanceError => 'Karakterler güncellenemedi.';

  @override
  String get settingsMaintenanceConfirmTitle => 'Karakterler güncellensin mi?';

  @override
  String get settingsMaintenanceCompleteTitle => 'Güncelleme tamamlandı';

  @override
  String settingsMaintenanceUpdatesFound(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count karakterin güncellenmesi gerekiyor.',
      one: '1 karakterin güncellenmesi gerekiyor.',
    );
    return '$_temp0';
  }

  @override
  String settingsMaintenanceConfirmBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count karakterin güncellenmesi gerekiyor. Değişiklikler uygulanmadan önce kaydetmeniz veya paylaşmanız için bir yedek açılacak.',
      one:
          '1 karakterin güncellenmesi gerekiyor. Değişiklikler uygulanmadan önce kaydetmeniz veya paylaşmanız için bir yedek açılacak.',
    );
    return '$_temp0';
  }

  @override
  String get characterUpdateRequiredTitle => 'Karakter güncellemesi gerekli';

  @override
  String get characterUpdateRequiredBody =>
      'Bu karakter açılmadan önce güncellenmeli. Şimdi karakterlerinizi yedekleyebilir veya hepsini güncelleyebilirsiniz. Herhangi bir güncelleme uygulanmadan önce bir yedek açılır.';

  @override
  String get characterUpdateRequiredAction => 'Güncelleme seçenekleri';

  @override
  String get characterUpdateBackupAction => 'Karakterleri yedekle';

  @override
  String get characterUpdateAllAction => 'Tüm karakterleri güncelle';

  @override
  String get characterUpdateApplying => 'Karakterler güncelleniyor...';

  @override
  String settingsMaintenanceReportChecked(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count karakter denetlendi.',
      one: '1 karakter denetlendi.',
    );
    return '$_temp0';
  }

  @override
  String settingsMaintenanceReportUpdated(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count karakter güncellendi.',
      one: '1 karakter güncellendi.',
    );
    return '$_temp0';
  }

  @override
  String settingsMaintenanceReportDataChanged(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count karakterin verileri düzeltildi.',
      one: '1 karakterin verileri düzeltildi.',
    );
    return '$_temp0';
  }

  @override
  String get settingsMaintenanceReportVersionUpdated =>
      'Veri sürümü güncellendi.';

  @override
  String settingsMaintenanceChangeEquipmentWeights(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count eşyanın ağırlığı düzeltildi.',
      one: '1 eşyanın ağırlığı düzeltildi.',
    );
    return '$_temp0';
  }

  @override
  String settingsMaintenanceChangeEquipmentNormalized(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ekipman eşyası standartlaştırıldı.',
      one: '1 ekipman eşyası standartlaştırıldı.',
    );
    return '$_temp0';
  }

  @override
  String settingsMaintenanceChangeEquipmentPacksExpanded(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ekipman paketi açıldı.',
      one: '1 ekipman paketi açıldı.',
    );
    return '$_temp0';
  }

  @override
  String settingsMaintenanceChangeEquipmentOrder(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count envanter eşyasının sırası standartlaştırıldı.',
      one: '1 envanter eşyasının sırası standartlaştırıldı.',
    );
    return '$_temp0';
  }

  @override
  String get settingsMaintenanceChangeMulticlassStructure =>
      'Karakterin sınıf yapısı çok sınıflılık için hazırlandı.';

  @override
  String get settingsMaintenanceChangeSpellSlots =>
      'Standart büyü yuvaları yeniden hesaplandı.';

  @override
  String get settingsMaintenanceChangePactMagicSlots =>
      'Pakt Büyüsü yuvaları ayrıldı.';

  @override
  String get settingsMaintenanceChangeArmorClass =>
      'Zırh Sınıfı yeniden hesaplandı.';

  @override
  String get settingsMaintenanceChangeRuleset2014 =>
      'Bu karakter 2014 kurallarını (SRD 5.1) kullanıyor olarak işaretlendi.';

  @override
  String settingsMaintenanceChangeGeneric(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count değişiklik uygulandı.',
      one: '1 değişiklik uygulandı.',
    );
    return '$_temp0';
  }

  @override
  String get incomingBackupPrompt => 'Dosyadan yedek içe aktarılsın mı?';

  @override
  String incomingBackupSuccess(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Yedekten $count karakter içe aktarıldı.',
      one: 'Yedekten 1 karakter içe aktarıldı.',
    );
    return '$_temp0';
  }
}
