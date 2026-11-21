/// Routes owned by the remedy feature: `/remedy/:slug?tab=overview|uses|dosage|brands|study`.
library;

import 'package:go_router/go_router.dart';

import 'package:homio_essentials/core/router/app_routes.dart';
import 'package:homio_essentials/features/remedy/presentation/screens/remedy_screen.dart';

final List<RouteBase> remedyRoutes = [
  GoRoute(path: AppRoutes.remedyPattern, builder: (_, s) => RemedyScreen(slug: s.pathParameters['slug']!, tab: s.uri.queryParameters['tab'])),
];
