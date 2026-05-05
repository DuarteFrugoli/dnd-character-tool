import 'package:go_router/go_router.dart';

import '../../features/character_list/character_list_screen.dart';
import '../../features/character_creation/character_creation_screen.dart';
import '../../features/character_detail/character_detail_screen.dart';
import '../../features/home/settings_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const CharacterListScreen(),
    ),
    GoRoute(
      path: '/character/:id',
      builder: (context, state) => CharacterDetailScreen(
        characterId: state.pathParameters['id']!,
      ),
    ),
    GoRoute(
      path: '/create',
      builder: (context, state) => const CharacterCreationScreen(),
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsScreen(),
    ),
  ],
);
