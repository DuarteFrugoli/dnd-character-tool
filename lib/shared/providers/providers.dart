import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/locale/locale_provider.dart';
import '../../data/character_progression/progression_2024_engine.dart';
import '../../data/feature_usage_engine.dart';
import '../../data/datasources/srd/srd_data_source.dart';
import '../../data/datasources/srd/srd_i18n_service.dart';
import '../../data/datasources/srd/srd_models.dart';
import '../../data/datasources/srd/srd_2024_creation_catalog.dart';
import '../../data/repositories/character_repository.dart';
import '../../data/rulesets/ruleset_ids.dart';
import '../../data/rulesets/srd_content_pack.dart';
import '../../data/rulesets/character_rules_context.dart';

final characterRepositoryProvider = Provider<CharacterRepository>(
  (ref) => CharacterRepository(),
);

final characterRulesContextProvider = Provider.family<
    CharacterRulesContext, (RulesetId, ContentPackId)>(
  (ref, key) => CharacterRulesContext.forIds(key.$1, key.$2),
);

final srd2024SpeciesProvider = FutureProvider<List<Creation2024Species>>(
  (ref) => Creation2024Catalog.loadSpecies(),
);

final srd2024ClassesProvider = FutureProvider<List<Creation2024Class>>(
  (ref) => Creation2024Catalog.loadClasses(),
);

final srd2024SubclassesProvider =
    FutureProvider<Map<String, List<Creation2024Subclass>>>(
      (ref) => Creation2024Catalog.loadSubclasses(),
    );

/// SRD 5.2.1 data for 2024 progression; species traits are added per sheet.
final srd2024RulesDataProvider = FutureProvider<Rules2024Data>((ref) async {
  final srd = ref.watch(srdDataSourceForPackProvider(ContentPackId.srd521));
  return Rules2024Data(
    classes: await ref.watch(srd2024ClassesProvider.future),
    subclasses: await ref.watch(srd2024SubclassesProvider.future),
    subclassFeatures: await srd.getAllSubclassFeatures(),
    feats: await srd.getFeats(),
    choices: await srd.getFeatureChoiceCatalog(),
    spells: await srd.getSpells(),
    skills: await srd.getSkills(),
    tools: await srd.getTools(),
    languages: await srd.getLanguages(),
    speciesTraits: const [],
  );
});

final srd2024CreationCatalogProvider = FutureProvider<Creation2024Catalog>(
  (ref) async => Creation2024Catalog.load(
    source: ref.watch(srdDataSourceForPackProvider(ContentPackId.srd521)),
    species: await ref.watch(srd2024SpeciesProvider.future),
    classes: await ref.watch(srd2024ClassesProvider.future),
  ),
);

final srdDataSourceForPackProvider = Provider.family<SrdDataSource, ContentPackId>(
  (ref, packId) =>
      SrdDataSource.forPack(SrdContentPackRegistry.forId(packId)),
);

final srdDataSourceProvider = Provider<SrdDataSource>(
  (ref) => ref.watch(srdDataSourceForPackProvider(ContentPackId.srd51)),
);

final srdItemsForPackProvider = FutureProvider.family<
    Map<String, SrdItemData>, ContentPackId>(
  (ref, packId) => ref.watch(srdDataSourceForPackProvider(packId)).getItems(),
);

final srdSkillsForPackProvider = FutureProvider.family<List<SrdSkill>, ContentPackId>(
  (ref, packId) => ref.watch(srdDataSourceForPackProvider(packId)).getSkills(),
);

final srdSpellsForPackProvider = FutureProvider.family<List<SrdSpell>, ContentPackId>(
  (ref, packId) => ref.watch(srdDataSourceForPackProvider(packId)).getSpells(),
);

final srdLanguagesForPackProvider = FutureProvider.family<List<SrdLanguage>, ContentPackId>(
  (ref, packId) => ref.watch(srdDataSourceForPackProvider(packId)).getLanguages(),
);

final srdWeaponsForPackProvider = FutureProvider.family<List<SrdWeapon>, ContentPackId>(
  (ref, packId) => ref.watch(srdDataSourceForPackProvider(packId)).getWeapons(),
);

final srdToolsForPackProvider = FutureProvider.family<List<SrdTool>, ContentPackId>(
  (ref, packId) => ref.watch(srdDataSourceForPackProvider(packId)).getTools(),
);

final srdFeatsForPackProvider = FutureProvider.family<List<SrdFeat>, ContentPackId>(
  (ref, packId) => ref.watch(srdDataSourceForPackProvider(packId)).getFeats(),
);

final srdRaceTraitsForPackProvider = FutureProvider.family<
    Map<String, String>, ContentPackId>(
  (ref, packId) => ref.watch(srdDataSourceForPackProvider(packId)).getRaceTraits(),
);

final srdFeatureChoicesForPackProvider = FutureProvider.family<
    SrdFeatureChoiceCatalog, ContentPackId>(
  (ref, packId) => ref.watch(srdDataSourceForPackProvider(packId)).getFeatureChoiceCatalog(),
);

final srdFeatureUsagesForPackProvider = FutureProvider.family<
    FeatureUsageCatalog, ContentPackId>(
  (ref, packId) => ref.watch(srdDataSourceForPackProvider(packId)).getFeatureUsageCatalog(),
);

final srdClassFeaturesForPackProvider = FutureProvider.family<
    List<SrdClassFeature>, (ContentPackId, String)>(
  (ref, key) => ref.watch(srdDataSourceForPackProvider(key.$1)).getClassFeatures(key.$2),
);

final srdAllSubclassFeaturesForPackProvider = FutureProvider.family<
    Map<String, Map<String, List<SrdClassFeature>>>, ContentPackId>(
  (ref, packId) => ref.watch(srdDataSourceForPackProvider(packId)).getAllSubclassFeatures(),
);

final srdSubclassFeaturesForPackProvider = FutureProvider.family<
    List<SrdClassFeature>, (ContentPackId, String, String)>(
  (ref, key) => ref.watch(srdDataSourceForPackProvider(key.$1))
      .getSubclassFeatures(key.$2, key.$3),
);

final srdItemsProvider = FutureProvider<Map<String, SrdItemData>>(
  (ref) => ref.watch(srdItemsForPackProvider(ContentPackId.srd51).future),
);

final srdSkillsProvider = FutureProvider<List<SrdSkill>>(
  (ref) => ref.watch(srdSkillsForPackProvider(ContentPackId.srd51).future),
);

final srdRacesProvider = FutureProvider<List<SrdRace>>(
  (ref) => ref.read(srdDataSourceProvider).getRaces(),
);

final srdBackgroundsProvider = FutureProvider<List<SrdBackground>>(
  (ref) => ref.read(srdDataSourceProvider).getBackgrounds(),
);

final srdClassesProvider = FutureProvider<List<SrdClass>>(
  (ref) => ref.read(srdDataSourceProvider).getClasses(),
);

final srdSpellsProvider = FutureProvider<List<SrdSpell>>(
  (ref) => ref.watch(srdSpellsForPackProvider(ContentPackId.srd51).future),
);

final srdLanguagesProvider = FutureProvider<List<SrdLanguage>>(
  (ref) => ref.watch(srdLanguagesForPackProvider(ContentPackId.srd51).future),
);

final srdWeaponsProvider = FutureProvider<List<SrdWeapon>>(
  (ref) => ref.watch(srdWeaponsForPackProvider(ContentPackId.srd51).future),
);

final srdToolsProvider = FutureProvider<List<SrdTool>>(
  (ref) => ref.watch(srdToolsForPackProvider(ContentPackId.srd51).future),
);

final srdFeatsProvider = FutureProvider<List<SrdFeat>>(
  (ref) => ref.watch(srdFeatsForPackProvider(ContentPackId.srd51).future),
);

final srdRaceTraitsProvider = FutureProvider<Map<String, String>>(
  (ref) => ref.watch(srdRaceTraitsForPackProvider(ContentPackId.srd51).future),
);

final srdFeatureChoiceCatalogProvider = FutureProvider<SrdFeatureChoiceCatalog>(
  (ref) => ref.watch(srdFeatureChoicesForPackProvider(ContentPackId.srd51).future),
);

final srdFeatureUsageCatalogProvider = FutureProvider<FeatureUsageCatalog>(
  (ref) => ref.watch(srdFeatureUsagesForPackProvider(ContentPackId.srd51).future),
);

final srdClassFeaturesProvider =
    FutureProvider.family<List<SrdClassFeature>, String>(
      (ref, className) => ref.watch(
        srdClassFeaturesForPackProvider((ContentPackId.srd51, className)).future,
      ),
    );

final srdAllSubclassFeaturesProvider =
    FutureProvider<Map<String, Map<String, List<SrdClassFeature>>>>(
      (ref) => ref.watch(
        srdAllSubclassFeaturesForPackProvider(ContentPackId.srd51).future,
      ),
    );

final srdSubclassFeaturesProvider =
    FutureProvider.family<List<SrdClassFeature>, SrdSubclassFeatureKey>(
      (ref, key) => ref.watch(
        srdSubclassFeaturesForPackProvider(
          (ContentPackId.srd51, key.className, key.subclassName),
        ).future,
      ),
    );

final srdI18nForPackProvider =
    FutureProvider.family<SrdI18nService, ContentPackId>((ref, packId) {
  final locale = ref.watch(localeProvider);
  final code =
      locale?.languageCode ??
      WidgetsBinding.instance.platformDispatcher.locale.languageCode;
  return SrdI18nService.load(
    code,
    pack: SrdContentPackRegistry.forId(packId),
  );
});

final srdI18nProvider = FutureProvider<SrdI18nService>(
  (ref) => ref.watch(srdI18nForPackProvider(ContentPackId.srd51).future),
);

final srdConditionsForPackProvider = FutureProvider.family<
  List<({String name, String description})>,
  ContentPackId
>((ref, packId) async {
      final raw = await rootBundle.loadString(
        SrdContentPackRegistry.forId(packId).srdAsset('conditions'),
      );
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

final srdConditionsProvider =
    FutureProvider<List<({String name, String description})>>(
      (ref) =>
          ref.watch(srdConditionsForPackProvider(ContentPackId.srd51).future),
    );

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
