/// Routes owned by the explore feature (tab root, `?tab=symptoms|companies`).
library;

import 'package:go_router/go_router.dart';

import 'package:homio_essentials/core/router/app_routes.dart';
import 'package:homio_essentials/features/explore/presentation/screens/explore_screen.dart';

final List<RouteBase> exploreTabRoutes = [
  GoRoute(path: AppRoutes.explore, builder: (_, s) => ExploreScreen(initialSegment: s.uri.queryParameters['tab'])),
];
