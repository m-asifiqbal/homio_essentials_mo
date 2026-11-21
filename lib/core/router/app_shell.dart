/// ============================================================
/// APP SHELL — tab scaffold: offline banner, anchored ad, auto-hiding bottom bar
/// ============================================================
///
/// Bottom bar behaviour follows the mgi_recruitment shell:
///
///  • Scrolling DOWN hides the bar (a pure SlideTransition — no relayout of the list),
///    and it stays hidden to the end of the list.
///  • Real travel back UP (≥ 12 dp, uninterrupted), reaching the top, switching tab, or a
///    descendant's [RevealBottomNavNotification] brings it back.
///  • Only the page's own vertical scrollable counts (`depth == 0`); nested horizontal
///    strips and sheets never move the bar. Only a finger DRAG can hide it, so a
///    programmatic scroll (scroll-to-top pill, refresh snap) never re-hides it.
///  • Switchable in Settings (`hideBarOnScroll`); turning it off only stops the HIDE
///    trigger, every reveal path stays live so the bar can never be stranded.
///
/// The anchored AdMob banner sits directly above the bar. When the bar slides away the
/// ad slides down with it and settles on the bottom edge, so it stays visible.
/// The body paints behind the bar (`extendBody`) — tab lists pad with `context.barClearance`.
///
/// Android back at a tab root: another tab → Home; Home → leave the app.
/// ============================================================
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import 'package:homio_essentials/core/ads/hm_ad_banner.dart';
import 'package:homio_essentials/core/l10n/i18n.dart';
import 'package:homio_essentials/core/theme/tokens.dart';
import 'package:homio_essentials/core/widgets/hm_bottom_nav.dart';
import 'package:homio_essentials/core/widgets/reveal_bottom_nav_notification.dart';
import 'package:homio_essentials/shared/providers/settings_provider.dart';
import 'package:homio_essentials/shared/widgets/offline_banner.dart';

class AppShell extends ConsumerStatefulWidget {
  const AppShell({super.key, required this.shell, required this.body});
  final StatefulNavigationShell shell;

  /// The animated branch container built by the router.
  final Widget body;

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> with SingleTickerProviderStateMixin {
  /// 0 = bar visible, 1 = slid off the bottom edge.
  late final AnimationController _nav = AnimationController(
    vsync: this,
    // Asymmetric on purpose: revealing feels immediate (the user is reaching for it), hiding is a touch lazier.
    duration: const Duration(milliseconds: 240),
    reverseDuration: const Duration(milliseconds: 180),
  );
  late final Animation<double> _eased = CurvedAnimation(parent: _nav, curve: Curves.easeOutCubic);

  bool _hidden = false;
  int _lastIndex = 0;
  ScrollDirection _userDirection = ScrollDirection.idle;
  double _upTravel = 0;

  /// The page must be this far down before a downward drag may hide the bar (a rubber-band tug at the top must not).
  static const _hideThreshold = 24.0;

  /// Uninterrupted upward travel that brings the bar back.
  static const _revealTravel = 12.0;

  @override
  void initState() {
    super.initState();
    _lastIndex = widget.shell.currentIndex;
  }

  @override
  void didUpdateWidget(covariant AppShell old) {
    super.didUpdateWidget(old);
    // Tracked here (not via oldWidget): StatefulShellRoute reuses the same shell object across a branch switch.
    final i = widget.shell.currentIndex;
    if (i != _lastIndex) {
      _lastIndex = i;
      _setHidden(false); // never land on a tab with no visible bar
      _userDirection = ScrollDirection.idle;
      _upTravel = 0;
    }
  }

  @override
  void dispose() {
    _nav.dispose();
    super.dispose();
  }

  void _setHidden(bool hide) {
    if (_hidden == hide) return;
    _hidden = hide;
    hide ? _nav.forward() : _nav.reverse();
  }

  /// Direction comes from `UserScrollNotification` (user gestures only); live metrics and drag
  /// details from `ScrollUpdateNotification` — see mgi_recruitment's shell for why they must be split.
  bool _onScroll(ScrollNotification n) {
    if (n.depth != 0 || n.metrics.axis != Axis.vertical) return false;
    if (n is UserScrollNotification) {
      _userDirection = n.direction;
    } else if (n is ScrollUpdateNotification) {
      if (n.dragDetails != null) {
        final delta = n.scrollDelta ?? 0;
        if (delta > 0) {
          _upTravel = 0;
        } else if (delta < 0) {
          _upTravel -= delta;
          if (_upTravel >= _revealTravel) _setHidden(false);
        }
      }
      // At the top the bar is ALWAYS shown (an invariant, however the list got there).
      if (n.metrics.pixels <= _hideThreshold) {
        _setHidden(false);
        return false;
      }
      if (_userDirection == ScrollDirection.reverse && n.dragDetails != null && ref.read(settingsProvider).hideBarOnScroll) {
        _setHidden(true);
      }
    }
    return false;
  }

  /// A page that changed SIZE (a filter narrowed its list) and now sits at its top can no longer
  /// scroll back up — bring the bar back so it is never stranded.
  bool _onMetrics(ScrollMetricsNotification n) {
    if (n.depth != 0 || n.metrics.axis != Axis.vertical) return false;
    if (n.metrics.pixels <= _hideThreshold) _setHidden(false);
    return false;
  }

  void _select(int i) => widget.shell.goBranch(i, initialLocation: i == widget.shell.currentIndex);

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    // Turning the setting OFF mid-scroll snaps the bar back at once.
    ref.listen(settingsProvider.select((s) => s.hideBarOnScroll), (_, on) {
      if (!on) _setHidden(false);
    });
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return PopScope(
      canPop: widget.shell.currentIndex == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _select(0);
      },
      child: Scaffold(
        // The body paints behind the bar, so sliding it away reveals real content, not a blank strip.
        extendBody: true,
        body: NotificationListener<RevealBottomNavNotification>(
          onNotification: (_) {
            _setHidden(false);
            _userDirection = ScrollDirection.idle;
            _upTravel = 0;
            return true;
          },
          child: NotificationListener<ScrollMetricsNotification>(
            onNotification: _onMetrics,
            child: NotificationListener<ScrollNotification>(
              onNotification: _onScroll,
              child: Column(children: [const OfflineBanner(), Expanded(child: widget.body)]),
            ),
          ),
        ),
        bottomNavigationBar: Column(mainAxisSize: MainAxisSize.min, children: [
          // The ad follows the bar down and settles on the bottom edge (above the system inset).
          AnimatedBuilder(
            animation: _eased,
            child: const HmAdBanner(placement: AdPlacement.anchored),
            builder: (context, ad) => Transform.translate(offset: Offset(0, Hm.navBarHeight * _eased.value), child: ad),
          ),
          AnimatedBuilder(
            animation: _eased,
            child: RepaintBoundary(
              child: HmBottomNav(
                currentIndex: widget.shell.currentIndex,
                onSelect: _select,
                items: [
                  HmNavItem(icon: Icons.home_outlined, selectedIcon: Icons.home_rounded, label: l.tabHome),
                  HmNavItem(icon: Icons.grid_view_outlined, selectedIcon: Icons.grid_view_rounded, label: l.tabExplore),
                  HmNavItem(icon: Icons.bookmark_border_rounded, selectedIcon: Icons.bookmark_rounded, label: l.tabSaved),
                  HmNavItem(icon: Icons.settings_outlined, selectedIcon: Icons.settings_rounded, label: l.tabSettings),
                ],
              ),
            ),
            builder: (context, bar) => Transform.translate(offset: Offset(0, (Hm.navBarHeight + bottomInset) * _eased.value), child: bar),
          ),
        ]),
      ),
    );
  }
}
