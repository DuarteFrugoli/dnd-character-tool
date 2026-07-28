import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/locale/locale_provider.dart';
import '../../data/feature_usage_engine.dart';
import '../../data/datasources/srd/srd_data_source.dart';
import '../../data/datasources/srd/srd_i18n_service.dart';
import '../../data/datasources/srd/srd_models.dart';
import '../../data/repositories/character_repository.dart';

final characterRepositoryProvider = Provider<CharacterRepository>(
  (ref) => CharacterRepository(),
);

final srdDataSourceProvider = Provider<SrdDataSource>(
  (ref) => SrdDataSource.instance,
);

final srdItemsProvider = FutureProvider<Map<String, SrdItemData>>(
  (ref) => ref.read(srdDataSourceProvider).getItems(),
);

final srdSkillsProvider = FutureProvider<List<SrdSkill>>(
  (ref) => ref.read(srdDataSourceProvider).getSkills(),
);

final srdRacesProvider = FutureProvider<List<SrdRace>>(
  (ref) => ref.read(srdDataSourceProvider).getRaces(),
);

final srdBackgroundsProvider = FutureProvider<List<SrdBackground>>(
  (ref) => ref.read(srdDataSourceProvider).getBackgrounds(),
);

final srdSpellsProvider = FutureProvider<List<SrdSpell>>(
  (ref) => ref.read(srdDataSourceProvider).getSpells(),
);

final srdLanguagesProvider = FutureProvider<List<SrdLanguage>>(
  (ref) => ref.read(srdDataSourceProvider).getLanguages(),
);

final srdWeaponsProvider = FutureProvider<List<SrdWeapon>>(
  (ref) => ref.read(srdDataSourceProvider).getWeapons(),
);

final srdToolsProvider = FutureProvider<List<SrdTool>>(
  (ref) => ref.read(srdDataSourceProvider).getTools(),
);

final srdFeatsProvider = FutureProvider<List<SrdFeat>>(
  (ref) => ref.read(srdDataSourceProvider).getFeats(),
);

final srdRaceTraitsProvider = FutureProvider<Map<String, String>>(
  (ref) => ref.read(srdDataSourceProvider).getRaceTraits(),
);

final srdFeatureChoiceCatalogProvider =
    FutureProvider<SrdFeatureChoiceCatalog>(
  (ref) => ref.read(srdDataSourceProvider).getFeatureChoiceCatalog(),
);

final srdFeatureUsageCatalogProvider = FutureProvider<FeatureUsageCatalog>(
  (ref) => ref.read(srdDataSourceProvider).getFeatureUsageCatalog(),
);

final srdClassFeaturesProvider =
    FutureProvider.family<List<SrdClassFeature>, String>(
  (ref, className) => ref.read(srdDataSourceProvider).getClassFeatures(
        className,
      ),
);

final srdAllSubclassFeaturesProvider =
    FutureProvider<Map<String, Map<String, List<SrdClassFeature>>>>(
  (ref) => ref.read(srdDataSourceProvider).getAllSubclassFeatures(),
);

final srdSubclassFeaturesProvider =
    FutureProvider.family<List<SrdClassFeature>, SrdSubclassFeatureKey>(
  (ref, key) => ref.read(srdDataSourceProvider).getSubclassFeatures(
        key.className,
        key.subclassName,
      ),
);

final srdI18nProvider = FutureProvider<SrdI18nService>((ref) async {
  final locale = ref.watch(localeProvider);
  final code = locale?.languageCode ??
      WidgetsBinding.instance.platformDispatcher.locale.languageCode;
  return SrdI18nService.load(code);
});

final srdConditionsProvider =
    FutureProvider<List<({String name, String description})>>((ref) async {
  final raw =
      await rootBundle.loadString('assets/data/srd/conditions.json');
  final list = jsonDecode(raw) as List<dynamic>;
  return list
      .map(
        (e) => (
          name: e['name'] as String,
          description: e['description'] as String,
        ),
      )
      .toList();
});

class SrdSubclassFeatureKey {
  const SrdSubclassFeatureKey({
    required this.className,
    required this.subclassName,
  });

  final String className;
  final String subclassName;

  @override
  bool operator ==(Object other) {
    return other is SrdSubclassFeatureKey &&
        className == other.className &&
        subclassName == other.subclassName;
  }

  @override
  int get hashCode => Object.hash(className, subclassName);
}
