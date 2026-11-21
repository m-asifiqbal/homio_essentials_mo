/// Routes owned by the settings feature: the tab root and its info pages.
library;

import 'package:go_router/go_router.dart';

import 'package:homio_essentials/core/router/app_routes.dart';
import 'package:homio_essentials/features/settings/presentation/screens/info_screens.dart';
import 'package:homio_essentials/features/settings/presentation/screens/settings_screen.dart';

final List<RouteBase> settingsTabRoutes = [GoRoute(path: AppRoutes.settings, builder: (_, _) => const SettingsScreen())];

final List<RouteBase> settingsRootRoutes = [
  GoRoute(path: AppRoutes.offline, builder: (_, _) => const OfflineScreen()),
  GoRoute(path: AppRoutes.disclaimer, builder: (_, _) => const DisclaimerScreen()),
  GoRoute(path: AppRoutes.sources, builder: (_, _) => const SourcesScreen()),
  GoRoute(path: AppRoutes.guide, builder: (_, _) => const PotencyGuideScreen()),
];
