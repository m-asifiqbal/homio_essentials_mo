/// ============================================================
/// APP ROUTER — go_router with a 4-tab StatefulShellRoute
/// ============================================================
///
/// Each feature registers its own routes in
/// `features/<f>/presentation/<f>_routes.dart`; this file only composes them.
/// First launch redirects to onboarding.
/// ============================================================
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:homio_essentials/core/router/app_routes.dart';
import 'package:homio_essentials/core/router/app_shell.dart';
import 'package:homio_essentials/core/router/page_transitions.dart';
import 'package:homio_essentials/features/condition/presentation/condition_routes.dart';
import 'package:homio_essentials/features/explore/presentation/explore_routes.dart';
import 'package:homio_essentials/features/home/presentation/home_routes.dart';
import 'package:homio_essentials/features/onboarding/presentation/onboarding_routes.dart';
import 'package:homio_essentials/features/remedy/presentation/remedy_routes.dart';
import 'package:homio_essentials/features/requests/presentation/requests_routes.dart';
import 'package:homio_essentials/features/saved/presentation/saved_routes.dart';
import 'package:homio_essentials/features/search/presentation/search_routes.dart';
import 'package:homio_essentials/features/settings/presentation/settings_routes.dart';
import 'package:homio_essentials/shared/providers/settings_provider.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoutes.home,
    redirect: (context, state) {
      final onboarded = ref.read(settingsProvider).onboarded;
      final atOnboarding = state.matchedLocation == AppRoutes.onboarding;
      if (!onboarded && !atOnboarding) return AppRoutes.onboarding;
      if (onboarded && atOnboarding) return AppRoutes.home;
      return null;
    },
    routes: [
      ...onboardingRoutes,
      StatefulShellRoute(
        builder: (context, state, shell) => shell,
        // Tabs cross-fade and keep their state alive; the shell owns the bar + ad around them.
        navigatorContainerBuilder: (context, shell, children) =>
            AppShell(shell: shell, body: HmAnimatedBranchContainer(currentIndex: shell.currentIndex, children: children)),
        branches: [
          StatefulShellBranch(routes: homeTabRoutes),
          StatefulShellBranch(routes: exploreTabRoutes),
          StatefulShellBranch(routes: savedTabRoutes),
          StatefulShellBranch(routes: settingsTabRoutes),
        ],
      ),
      ...searchRoutes,
      ...remedyRoutes,
      ...conditionRoutes,
      ...requestsRoutes,
      ...settingsRootRoutes,
    ],
  );
});
