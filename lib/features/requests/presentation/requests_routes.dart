/// Routes owned by the requests feature: `/request?name=&kind=`, `/my-requests`.
library;

import 'package:go_router/go_router.dart';

import 'package:homio_essentials/core/router/app_routes.dart';
import 'package:homio_essentials/features/requests/presentation/screens/my_requests_screen.dart';
import 'package:homio_essentials/features/requests/presentation/screens/request_screen.dart';

final List<RouteBase> requestsRoutes = [
  GoRoute(path: AppRoutes.request, builder: (_, s) => RequestScreen(prefill: s.uri.queryParameters['name'], kind: s.uri.queryParameters['kind'])),
  GoRoute(path: AppRoutes.myRequests, builder: (_, _) => const MyRequestsScreen()),
];
