import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/srd/srd_data_source.dart';
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
