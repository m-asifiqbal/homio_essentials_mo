/// ============================================================
/// HM SCROLL-TO-TOP PILL — appears after a long scroll, jumps back to the top
/// ============================================================
///
/// From mgi_recruitment's `ScrollToTopPill`: a small floating pill that fades in
/// once the list is ≥ [threshold] dp down and the user is heading back UP.
/// Tapping animates to the top and dispatches [RevealBottomNavNotification] so
/// the auto-hiding bar returns (a programmatic scroll never reveals it by itself).
///
/// Wrap the list in a Stack and put this on top; give it the list's controller.
/// ============================================================
library;

import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import 'package:homio_essentials/core/l10n/i18n.dart';
import 'package:homio_essentials/core/theme/tokens.dart';
import 'package:homio_essentials/core/widgets/reveal_bottom_nav_notification.dart';

class HmScrollTopPill extends StatefulWidget {
  const HmScrollTopPill({super.key, required this.controller, this.threshold = 600});
  final ScrollController controller;
  final double threshold;

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
    final down = p.pixels > widget.threshold;
    // Visible while far down and the user is scrolling back up (or stopped); hidden while heading down.
    final goingDown = p.userScrollDirection == ScrollDirection.reverse;
    final next = down && !goingDown;
    if (next != _show) setState(() => _show = next);
  }

  void _top() {
    HapticFeedback.selectionClick();
    const RevealBottomNavNotification().dispatch(context);
    widget.controller.animateTo(0, duration: context.motion(const Duration(milliseconds: 420)), curve: Curves.easeOutCubic);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.hm;
    return Positioned(
      top: 10,
      left: 0,
      right: 0,
      child: IgnorePointer(
        ignoring: !_show,
        child: AnimatedSlide(
          duration: context.motion(HmMotion.normal),
          curve: HmMotion.curve,
          offset: _show ? Offset.zero : const Offset(0, -1.6),
          child: AnimatedOpacity(
            duration: context.motion(HmMotion.fast),
            opacity: _show ? 1 : 0,
            child: Center(
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
    );
  }
}
