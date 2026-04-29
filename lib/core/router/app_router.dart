import 'package:go_router/go_router.dart';

import '../../features/character_list/character_list_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const CharacterListScreen(),
    ),
  ],
);
