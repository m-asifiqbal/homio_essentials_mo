/// Routes owned by the condition feature: `/condition/:slug`.
library;

import 'package:go_router/go_router.dart';

import 'package:homio_essentials/core/router/app_routes.dart';
import 'package:homio_essentials/features/condition/presentation/screens/condition_screen.dart';

final List<RouteBase> conditionRoutes = [
  GoRoute(path: AppRoutes.conditionPattern, builder: (_, s) => ConditionScreen(slug: s.pathParameters['slug']!)),
];
