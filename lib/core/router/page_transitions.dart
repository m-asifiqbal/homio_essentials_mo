/// ============================================================
/// PAGE TRANSITIONS — one motion language for every navigation
/// ============================================================
///
/// Adapted from FocusFlow (`core/router/page_transitions.dart`):
///
/// - Pushes (remedy, condition, search, settings sub-pages): [HmPageTransitionsBuilder],
///   registered once in the theme so every `GoRoute(builder:)` gets it — the page
///   slides in from the trailing edge while the page underneath travels a bit and
///   dims (parallax); pops run the same slide backwards. iOS keeps the native
///   Cupertino slide because it owns the edge swipe-back gesture.
/// - Tab switches: [HmAnimatedBranchContainer] cross-fades the tab's navigator and
///   keeps every tab's state alive (IndexedStack semantics).
///
/// Everything collapses to an instant switch under reduce motion. Only the
/// translation / opacity animate — the page is never rebuilt or re-laid-out.
/// ============================================================
library;

import 'package:cupertino_ui/cupertino_ui.dart' show CupertinoPageTransitionsBuilder;
import 'package:material_ui/material_ui.dart';

import 'package:homio_essentials/core/theme/tokens.dart';

class HmPageTransitionsBuilder extends PageTransitionsBuilder {
  const HmPageTransitionsBuilder();

  static const _cupertino = CupertinoPageTransitionsBuilder();

  @override
  Duration get transitionDuration => HmSlideTransition.forward;

  @override
  Duration get reverseTransitionDuration => HmSlideTransition.reverse;

  @override
  Widget buildTransitions<T>(PageRoute<T> route, BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation, Widget child) {
    if (MediaQuery.maybeDisableAnimationsOf(context) ?? false) return child;
    if (Theme.of(context).platform == TargetPlatform.iOS || route.fullscreenDialog) {
      return _cupertino.buildTransitions(route, context, animation, secondaryAnimation, child);
    }
    return HmSlideTransition(route: route, animation: animation, secondaryAnimation: secondaryAnimation, child: child);
  }
}

/// The push / pop slide: 280 / 240 ms, quick out of the gate with a soft landing,
/// no edge-shadow gradient (the page underneath dims with a flat fill instead).
class HmSlideTransition extends StatefulWidget {
  const HmSlideTransition({super.key, required this.route, required this.animation, required this.secondaryAnimation, required this.child});

  static const Duration forward = Duration(milliseconds: 280);
  static const Duration reverse = Duration(milliseconds: 240);

  /// How far the page underneath travels (a fraction of the width)…
  static const double parallax = 0.28;

  /// …and how dark it gets.
  static const double dim = 0.10;

  final PageRoute<Object?> route;
  final Animation<double> animation;
  final Animation<double> secondaryAnimation;
  final Widget child;

  @override
  State<HmSlideTransition> createState() => _HmSlideTransitionState();
}

class _HmSlideTransitionState extends State<HmSlideTransition> {
  late CurvedAnimation _in;
  late CurvedAnimation _under;

  // Quick start, soft landing — both ways (on pop the reverse curve runs 1 → 0,
  // so ease-*in* is what leaves fast).
  static CurvedAnimation _curved(Animation<double> parent) => CurvedAnimation(parent: parent, curve: Curves.easeOutCubic, reverseCurve: Curves.easeInCubic);

  @override
  void initState() {
    super.initState();
    _in = _curved(widget.animation);
    _under = _curved(widget.secondaryAnimation);
  }

  @override
  void didUpdateWidget(HmSlideTransition old) {
    super.didUpdateWidget(old);
    if (old.animation != widget.animation) {
      _in.dispose();
      _in = _curved(widget.animation);
    }
    if (old.secondaryAnimation != widget.secondaryAnimation) {
      _under.dispose();
      _under = _curved(widget.secondaryAnimation);
    }
  }

  @override
  void dispose() {
    _in.dispose();
    _under.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dir = Directionality.of(context) == TextDirection.rtl ? -1.0 : 1.0;
    return AnimatedBuilder(
      animation: Listenable.merge([widget.animation, widget.secondaryAnimation]),
      child: widget.child,
      builder: (context, page) {
        final linear = widget.route.navigator?.userGestureInProgress ?? false;
        final t = linear ? widget.animation.value : _in.value;
        final s = linear ? widget.secondaryAnimation.value : _under.value;
        return FractionalTranslation(
          translation: Offset(dir * (1 - t) - dir * HmSlideTransition.parallax * s, 0),
          child: Stack(fit: StackFit.passthrough, children: [
            page!,
            if (s > 0)
              Positioned.fill(child: IgnorePointer(child: ColoredBox(color: const Color(0xFF000000).withValues(alpha: HmSlideTransition.dim * s)))),
          ]),
        );
      },
    );
  }
}

/// `StatefulShellRoute.indexedStack(navigatorContainerBuilder: …)`: cross-fades
/// between tab branches while keeping every branch alive.
class HmAnimatedBranchContainer extends StatelessWidget {
  const HmAnimatedBranchContainer({super.key, required this.currentIndex, required this.children});
  final int currentIndex;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final reduce = context.reduceMotion;
    return Stack(fit: StackFit.expand, children: [
      for (var i = 0; i < children.length; i++) _Branch(active: i == currentIndex, animate: !reduce, child: children[i]),
    ]);
  }
}

class _Branch extends StatefulWidget {
  const _Branch({required this.active, required this.animate, required this.child});
  final bool active;
  final bool animate;
  final Widget child;

  @override
  State<_Branch> createState() => _BranchState();
}

/// Inactive tabs are Offstage (state kept, not painted, not hit-tested); the tab
/// being shown fades in over a short 150 ms — opacity only, so a whole screen is
/// never re-rasterised through a transform layer.
class _BranchState extends State<_Branch> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 150), value: widget.active ? 1 : 0);
  late final Animation<double> _t = CurvedAnimation(parent: _c, curve: HmMotion.curve);

  @override
  void didUpdateWidget(_Branch old) {
    super.didUpdateWidget(old);
    if (widget.active && !old.active) {
      widget.animate ? _c.forward(from: 0) : _c.value = 1;
    } else if (!widget.active) {
      _c.value = 0;
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Offstage(
        offstage: !widget.active,
        child: TickerMode(enabled: widget.active, child: RepaintBoundary(child: FadeTransition(opacity: _t, child: widget.child))),
      );
}
