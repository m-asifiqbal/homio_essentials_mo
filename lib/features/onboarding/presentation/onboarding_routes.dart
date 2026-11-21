/// Routes owned by onboarding (first launch only — see AppRouter.redirect).
library;

import 'package:go_router/go_router.dart';

import 'package:homio_essentials/core/router/app_routes.dart';
import 'package:homio_essentials/features/onboarding/presentation/screens/onboarding_screen.dart';

final List<RouteBase> onboardingRoutes = [GoRoute(path: AppRoutes.onboarding, builder: (_, _) => const OnboardingScreen())];
