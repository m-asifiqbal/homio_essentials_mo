/// ============================================================
/// APP SHELL — tab scaffold: offline banner, anchored ad, always-visible bottom bar
/// ============================================================
///
/// The bar is ALWAYS visible (an earlier hide-on-scroll mode, and its Settings switch, were removed).
/// The anchored AdMob banner sits directly above it. The body ends where the ad begins, so no list is
/// ever drawn under the bar and screens only need a small `context.barClearance` at the end of a list.
///
/// Android back at a tab root: another tab → Home; Home → leave the app.
/// ============================================================
library;

import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import 'package:homio_essentials/core/ads/hm_ad_banner.dart';
import 'package:homio_essentials/core/l10n/i18n.dart';
import 'package:homio_essentials/core/widgets/hm_bottom_nav.dart';
import 'package:homio_essentials/shared/widgets/offline_banner.dart';

class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.shell, required this.body});
  final StatefulNavigationShell shell;

  /// The animated branch container built by the router.
  final Widget body;

  void _select(int i) => shell.goBranch(i, initialLocation: i == shell.currentIndex);

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    return PopScope(
      canPop: shell.currentIndex == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _select(0);
      },
      child: Scaffold(
        body: Column(children: [const OfflineBanner(), Expanded(child: body)]),
        bottomNavigationBar: Column(mainAxisSize: MainAxisSize.min, children: [
          const HmAdBanner(placement: AdPlacement.anchored),
          RepaintBoundary(
            child: HmBottomNav(
              currentIndex: shell.currentIndex,
              onSelect: _select,
              items: [
                HmNavItem(icon: Icons.home_outlined, selectedIcon: Icons.home_rounded, label: l.tabHome),
                HmNavItem(icon: Icons.grid_view_outlined, selectedIcon: Icons.grid_view_rounded, label: l.tabExplore),
                HmNavItem(icon: Icons.bookmark_border_rounded, selectedIcon: Icons.bookmark_rounded, label: l.tabSaved),
                HmNavItem(icon: Icons.settings_outlined, selectedIcon: Icons.settings_rounded, label: l.tabSettings),
              ],
            ),
          ),
        ]),
      ),
    );
  }
}
