/// Routes owned by the saved feature (tab root).
library;

import 'package:go_router/go_router.dart';

import 'package:homio_essentials/core/router/app_routes.dart';
import 'package:homio_essentials/features/saved/presentation/screens/saved_screen.dart';

final List<RouteBase> savedTabRoutes = [GoRoute(path: AppRoutes.saved, builder: (_, _) => const SavedScreen())];
