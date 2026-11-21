/// Routes owned by the home feature (tab root).
library;

import 'package:go_router/go_router.dart';

import 'package:homio_essentials/core/router/app_routes.dart';
import 'package:homio_essentials/features/home/presentation/screens/home_screen.dart';

final List<RouteBase> homeTabRoutes = [GoRoute(path: AppRoutes.home, builder: (_, _) => const HomeScreen())];
