/// ============================================================
/// APP — MaterialApp.router with theme, locale and text scale from settings
/// ============================================================
library;

import 'package:cupertino_ui/cupertino_ui.dart' show GlobalCupertinoLocalizations;
import 'package:flutter_localizations/flutter_localizations.dart' show GlobalWidgetsLocalizations;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import 'package:homio_essentials/core/ads/ad_service.dart';
import 'package:homio_essentials/core/constants/app_info.dart';
import 'package:homio_essentials/core/l10n/i18n.dart';
import 'package:homio_essentials/core/router/app_router.dart';
import 'package:homio_essentials/core/theme/app_theme.dart';
import 'package:homio_essentials/core/theme/tokens.dart';
import 'package:homio_essentials/shared/providers/settings_provider.dart';

class HomioApp extends ConsumerStatefulWidget {
  const HomioApp({super.key});
  @override
  ConsumerState<HomioApp> createState() => _HomioAppState();
}

class _HomioAppState extends ConsumerState<HomioApp> {
  @override
  void initState() {
    super.initState();
    // Ads only after onboarding, so the consent form never covers the welcome.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (ref.read(settingsProvider).onboarded) ref.read(adServiceProvider).start();
    });
    ref.listenManual(settingsProvider.select((s) => s.onboarded), (_, onboarded) {
      if (onboarded) ref.read(adServiceProvider).start();
    });
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(settingsProvider);
    return MaterialApp.router(
      title: AppInfo.name,
      debugShowCheckedModeBanner: false,
      routerConfig: ref.watch(appRouterProvider),
      locale: Locale(s.locale),
      supportedLocales: L.supportedLocales,
      localizationsDelegates: const [L.delegate, GlobalMaterialLocalizations.delegate, GlobalWidgetsLocalizations.delegate, GlobalCupertinoLocalizations.delegate],
      themeMode: s.themeMode,
      theme: buildTheme(HomaColors.of(dark: false, accent: s.accent)),
      darkTheme: buildTheme(HomaColors.of(dark: true, accent: s.accent)),
      builder: (context, child) {
        // Bangla script reads better a touch larger (design: 16 pt vs 15 pt body).
        final scale = s.textScale * (s.bn ? 1.05 : 1.0);
        return MediaQuery(data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(scale)), child: child!);
      },
    );
  }
}
