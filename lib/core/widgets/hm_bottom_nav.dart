/// ============================================================
/// HM BOTTOM NAV — flat bar with one sliding top indicator
/// ============================================================
///
/// Modelled on the mgi_recruitment candidate shell (a LinkedIn-style bar):
///
///  1. ONE indicator — a short rounded bar pinned to the bar's top edge that
///     travels to the newly selected tab (200 ms, fast-out-slow-in).
///  2. Outline → solid ICON SWAP on selection, instant, with a tiny 6 % pop
///     once when a tab becomes selected, and a 92 % dip under the finger.
///  3. The active label goes bold; inactive labels stay medium / grey.
///  4. A neutral ripple that fills the WHOLE tab cell.
///
/// Flat and opaque on purpose — no BackdropFilter, no per-frame glow — so the
/// bar costs nothing while the list behind it scrolls. Its hide-on-scroll
/// behaviour lives in `AppShell`; this widget only draws.
/// ============================================================
library;

import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import 'package:homio_essentials/core/theme/tokens.dart';

@immutable
class HmNavItem {
  const HmNavItem({required this.icon, required this.selectedIcon, required this.label});
  final IconData icon;
  final IconData selectedIcon;
  final String label;
}

class HmBottomNav extends StatelessWidget {
  const HmBottomNav({super.key, required this.items, required this.currentIndex, required this.onSelect});
  final List<HmNavItem> items;
  final int currentIndex;
  final ValueChanged<int> onSelect;

  static const double _indicatorHeight = 2.5;
  static const double _indicatorInset = 6;

  @override
  Widget build(BuildContext context) {
    final c = context.hm;
    final n = items.length;
    final still = context.reduceMotion;
    // The bar's colour is a Material, not a decoration: the tabs' ripples paint ON the nearest
    // Material, so an opaque decoration above it would hide every one of them.
    return MediaQuery.withClampedTextScaling(
      maxScaleFactor: 1.15,
      child: Material(
        color: c.sf,
        child: DecoratedBox(
          decoration: BoxDecoration(border: Border(top: BorderSide(color: c.ln))),
          child: SafeArea(
            top: false,
            child: SizedBox(
              height: Hm.navBarHeight,
              child: LayoutBuilder(builder: (context, box) {
                final tabWidth = box.maxWidth / n;
                return Stack(children: [
                  Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                    for (var i = 0; i < n; i++)
                      Expanded(child: _NavTab(item: items[i], selected: i == currentIndex, onTap: () => onSelect(i))),
                  ]),
                  // ONE indicator that travels, rather than four that blink.
                  AnimatedPositioned(
                    left: tabWidth * currentIndex + _indicatorInset,
                    top: 0,
                    duration: still ? Duration.zero : const Duration(milliseconds: 200),
                    curve: Curves.fastOutSlowIn,
                    child: IgnorePointer(
                      child: Container(
                        width: tabWidth - _indicatorInset * 2,
                        height: _indicatorHeight,
                        decoration: BoxDecoration(color: c.p, borderRadius: BorderRadius.circular(_indicatorHeight / 2)),
                      ),
                    ),
                  ),
                ]);
              }),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavTab extends StatefulWidget {
  const _NavTab({required this.item, required this.selected, required this.onTap});
  final HmNavItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  State<_NavTab> createState() => _NavTabState();
}

class _NavTabState extends State<_NavTab> with SingleTickerProviderStateMixin {
  bool _pressed = false;

  /// The 6 % pop, played once each time the tab becomes selected.
  late final AnimationController _pop = AnimationController(vsync: this, duration: const Duration(milliseconds: 260));
  late final Animation<double> _popScale = TweenSequence<double>([
    TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.06).chain(CurveTween(curve: Curves.easeOut)), weight: 40),
    TweenSequenceItem(tween: Tween(begin: 1.06, end: 1.0).chain(CurveTween(curve: Curves.easeIn)), weight: 60),
  ]).animate(_pop);

  @override
  void didUpdateWidget(_NavTab old) {
    super.didUpdateWidget(old);
    if (widget.selected && !old.selected && !context.reduceMotion) _pop.forward(from: 0);
  }

  @override
  void dispose() {
    _pop.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.hm;
    final selected = widget.selected;
    final color = selected ? c.p : c.ink3;
    final ink = c.dark ? Colors.white : Colors.black;
    return Semantics(
      button: true,
      selected: selected,
      label: widget.item.label,
      excludeSemantics: true,
      child: InkWell(
        onTap: () {
          if (!selected) HapticFeedback.selectionClick();
          widget.onTap();
        },
        onHighlightChanged: (v) => setState(() => _pressed = v),
        // Smooth circle from the finger that fills the cell, then a slow fade (not InkSparkle's grain).
        splashFactory: InkRipple.splashFactory,
        splashColor: ink.withValues(alpha: c.dark ? 0.14 : 0.08),
        highlightColor: ink.withValues(alpha: c.dark ? 0.06 : 0.04),
        child: Padding(
          padding: const EdgeInsets.only(top: 9, bottom: 6),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            AnimatedScale(
              scale: _pressed ? 0.92 : 1,
              duration: context.motion(const Duration(milliseconds: 120)),
              curve: Curves.easeOut,
              child: ScaleTransition(scale: _popScale, child: Icon(selected ? widget.item.selectedIcon : widget.item.icon, size: 24, color: color)),
            ),
            const SizedBox(height: 3),
            Text(
              widget.item.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 11.5, height: 1.2, letterSpacing: 0.1, fontWeight: selected ? FontWeight.w700 : FontWeight.w500, color: color),
            ),
          ]),
        ),
      ),
    );
  }
}
