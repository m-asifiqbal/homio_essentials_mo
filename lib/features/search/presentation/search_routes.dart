/// Routes owned by the search feature: `/search?q=&voice=1` (full screen).
library;

import 'package:go_router/go_router.dart';

import 'package:homio_essentials/core/router/app_routes.dart';
import 'package:homio_essentials/features/search/presentation/screens/search_screen.dart';

final List<RouteBase> searchRoutes = [
  GoRoute(
    path: AppRoutes.search,
    builder: (context, state) => SearchScreen(
      initialQuery: state.uri.queryParameters['q'],
      startWithVoice: state.uri.queryParameters['voice'] == '1',
    ),
  ),
];
