import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/locale/locale_provider.dart';
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
