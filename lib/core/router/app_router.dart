import 'package:go_router/go_router.dart';

import '../../features/character_list/character_list_screen.dart';
import '../../features/character_creation/character_creation_screen.dart';
import '../../features/character_detail/character_detail_screen.dart';
import '../../features/home/settings_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  // Safety net: if Android/iOS passes a content:// or file:// URI to the router
  // (e.g. when opening a .dndchar file), redirect to home instead of crashing.
  redirect: (context, state) {
    final scheme = state.uri.scheme;
    if (scheme == 'content' || scheme == 'file') return '/';
    return null;
  },
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
