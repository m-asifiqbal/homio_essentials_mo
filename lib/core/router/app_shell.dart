/// ============================================================
/// APP SHELL — tab scaffold: offline banner, anchored ad, bottom bar
/// ============================================================
///
/// Android back at a tab root: another tab → Home; Home → leave the app.
/// The anchored AdMob banner sits directly above the bottom bar (design).
/// ============================================================
library;

import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import 'package:homio_essentials/core/ads/hm_ad_banner.dart';
import 'package:homio_essentials/core/l10n/i18n.dart';
import 'package:homio_essentials/shared/widgets/offline_banner.dart';

class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.shell});
  final StatefulNavigationShell shell;

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    return PopScope(
      canPop: shell.currentIndex == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) shell.goBranch(0);
      },
      child: Scaffold(
        body: Column(children: [const OfflineBanner(), Expanded(child: shell)]),
        bottomNavigationBar: Column(mainAxisSize: MainAxisSize.min, children: [
          const HmAdBanner(placement: AdPlacement.anchored),
          NavigationBar(
            selectedIndex: shell.currentIndex,
            onDestinationSelected: (i) {
              HapticFeedback.selectionClick();
              shell.goBranch(i, initialLocation: i == shell.currentIndex);
            },
            destinations: [
              NavigationDestination(icon: const Icon(Icons.home_outlined), selectedIcon: const Icon(Icons.home_rounded), label: l.tabHome),
              NavigationDestination(icon: const Icon(Icons.grid_view_outlined), selectedIcon: const Icon(Icons.grid_view_rounded), label: l.tabExplore),
              NavigationDestination(icon: const Icon(Icons.bookmark_border_rounded), selectedIcon: const Icon(Icons.bookmark_rounded), label: l.tabSaved),
              NavigationDestination(icon: const Icon(Icons.tune_outlined), selectedIcon: const Icon(Icons.tune_rounded), label: l.tabSettings),
            ],
          ),
        ]),
      ),
    );
  }
}
