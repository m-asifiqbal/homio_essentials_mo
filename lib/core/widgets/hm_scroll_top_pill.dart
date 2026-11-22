/// ============================================================
/// HM BACK-TO-TOP PILL — bottom of the list, 6 dp above the bar, after 15 items
/// ============================================================
///
/// From mgi_recruitment's `ScrollToTopPill`, placed where thumbs are: floating at the BOTTOM of the
/// scroll area, [bottom] (6 dp) above whatever sits under it (tab bar / action bar). It appears once the
/// user has scrolled past [afterItems] (15) items — `afterItems × itemExtent` dp — and is not currently
/// scrolling down; it hides again when they scroll down or reach the top. Tapping animates to the top.
///
/// Use [HmScrollTopHost] around a list (it owns the controller), or put an [HmScrollTopPill] inside your
/// own Stack when you already have a controller.
/// ============================================================
library;

import 'package:flutter/rendering.dart' show ScrollDirection;
import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import 'package:homio_essentials/core/l10n/i18n.dart';
import 'package:homio_essentials/core/theme/tokens.dart';

class HmScrollTopPill extends StatefulWidget {
  const HmScrollTopPill({super.key, required this.controller, required this.itemExtent, this.afterItems = 15, this.bottom = 6});
  final ScrollController controller;

  /// Typical height of one list item in dp.
  final double itemExtent;

  /// How many items must have been scrolled through before the pill shows.
  final int afterItems;

  /// Gap between the pill and the bottom edge of the scroll area (the bar below it).
  final double bottom;

  double get threshold => itemExtent * afterItems;

  @override
  State<HmScrollTopPill> createState() => _HmScrollTopPillState();
}

class _HmScrollTopPillState extends State<HmScrollTopPill> {
  bool _show = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_tick);
  }

  @override
  void didUpdateWidget(HmScrollTopPill old) {
    super.didUpdateWidget(old);
    if (old.controller != widget.controller) {
      old.controller.removeListener(_tick);
      widget.controller.addListener(_tick);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_tick);
    super.dispose();
  }

  void _tick() {
    final c = widget.controller;
    if (!c.hasClients) return;
    final p = c.position;
    // Past the threshold: shown while moving up or resting, hidden while the user is actively scrolling down
    // (it would sit on top of the content they are reading). A jump / animateTo reports "idle".
    final next = p.pixels > widget.threshold && p.userScrollDirection != ScrollDirection.reverse;
    if (next != _show) setState(() => _show = next);
  }

  void _top() {
    HapticFeedback.selectionClick();
    widget.controller.animateTo(0, duration: context.motion(const Duration(milliseconds: 450)), curve: Curves.easeOutCubic);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.hm;
    return Positioned(
      bottom: widget.bottom,
      left: 0,
      right: 0,
      child: IgnorePointer(
        ignoring: !_show,
        child: AnimatedSlide(
          duration: context.motion(HmMotion.normal),
          curve: HmMotion.curve,
          offset: _show ? Offset.zero : const Offset(0, 1.8), // rises from just below its resting place
          child: AnimatedOpacity(
            duration: context.motion(HmMotion.fast),
            opacity: _show ? 1 : 0,
            child: Center(
              child: Semantics(
                button: true,
                label: context.l.backToTop,
                excludeSemantics: true,
                child: Material(
                  color: c.p,
                  elevation: 3,
                  shadowColor: Colors.black45,
                  shape: const StadiumBorder(),
                  child: InkWell(
                    customBorder: const StadiumBorder(),
                    onTap: _top,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        Icon(Icons.arrow_upward_rounded, size: 16, color: c.onp),
                        const SizedBox(width: 6),
                        Text(context.l.backToTop, style: TextStyle(color: c.onp, fontSize: 12.5, fontWeight: FontWeight.w600)),
                      ]),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Owns a [ScrollController], hands it to [builder] (give it to the list), and floats the pill over the result.
class HmScrollTopHost extends StatefulWidget {
  const HmScrollTopHost({super.key, required this.builder, required this.itemExtent, this.afterItems = 15});
  final Widget Function(BuildContext context, ScrollController controller) builder;
  final double itemExtent;
  final int afterItems;

  @override
  State<HmScrollTopHost> createState() => _HmScrollTopHostState();
}

class _HmScrollTopHostState extends State<HmScrollTopHost> {
  final _controller = ScrollController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Stack(children: [
        widget.builder(context, _controller),
        HmScrollTopPill(controller: _controller, itemExtent: widget.itemExtent, afterItems: widget.afterItems),
      ]);
}
