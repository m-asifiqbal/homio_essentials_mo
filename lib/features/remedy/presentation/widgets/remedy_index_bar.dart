/// ============================================================
/// REMEDY INDEX BAR — sticky "jump to section" chips with scroll-spy
/// ============================================================
///
/// MedEx stacks its sections with no way to jump between them; this pinned strip is
/// the improvement: one chip per section, the chip of the section being read is
/// highlighted (and scrolled into view), tapping a chip scrolls to it and opens it,
/// and one button expands / collapses everything.
///
/// Only [active] (a ValueNotifier) changes while scrolling — the strip rebuilds, the
/// page does not.
/// ============================================================
library;

import 'package:flutter/foundation.dart' show ValueListenable;
import 'package:flutter/rendering.dart' show ScrollDirection;
import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import 'package:homio_essentials/core/l10n/i18n.dart';
import 'package:homio_essentials/core/theme/tokens.dart';
import 'package:homio_essentials/features/remedy/presentation/widgets/remedy_section.dart';

class RemedyIndexBar extends SliverPersistentHeaderDelegate {
  RemedyIndexBar({required this.heroColor, required this.specs, required this.active, required this.allOpen, required this.onJump, required this.onToggleAll, required this.colors});
  final Color heroColor;
  final List<RemedySectionSpec> specs;
  final ValueListenable<String> active;
  final ValueListenable<bool> allOpen;
  final ValueChanged<String> onJump;
  final VoidCallback onToggleAll;
  final HomaColors colors;

  static const height = 50.0;

  @override
  double get minExtent => height;
  @override
  double get maxExtent => height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    final c = colors;
    // Docked (content scrolls under it) the bar is a plain flat strip; at rest it is the hero's rounded "lip".
    // This switch is deliberately INSTANT: animating the corner radius made the hero colour flash in the
    // corners every time the page reached the top — the glitch seen when scrolling back up.
    final flat = shrinkOffset > 0 || overlapsContent;
    return ColoredBox(
      color: flat ? c.bg : heroColor,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: c.bg,
          borderRadius: BorderRadius.vertical(top: Radius.circular(flat ? 0 : 22)),
          border: Border(bottom: BorderSide(color: flat ? c.ln : Colors.transparent)),
        ),
        child: Row(children: [
          Expanded(child: _Chips(specs: specs, active: active, onJump: onJump, c: c)),
          ValueListenableBuilder<bool>(
            valueListenable: allOpen,
            builder: (context, all, _) => IconButton(
              tooltip: all ? context.l.collapseAll : context.l.expandAll,
              visualDensity: VisualDensity.compact,
              onPressed: () {
                HapticFeedback.selectionClick();
                onToggleAll();
              },
              icon: AnimatedSwitcher(
                duration: context.motion(HmMotion.fast),
                child: Icon(all ? Icons.unfold_less_rounded : Icons.unfold_more_rounded, key: ValueKey(all), color: c.ink2),
              ),
            ),
          ),
          const SizedBox(width: 4),
        ]),
      ),
    );
  }

  @override
  bool shouldRebuild(covariant RemedyIndexBar old) => old.specs.length != specs.length || old.colors != colors || old.heroColor != heroColor;
}

class _Chips extends StatefulWidget {
  const _Chips({required this.specs, required this.active, required this.onJump, required this.c});
  final List<RemedySectionSpec> specs;
  final ValueListenable<String> active;
  final ValueChanged<String> onJump;
  final HomaColors c;

  @override
  State<_Chips> createState() => _ChipsState();
}

class _ChipsState extends State<_Chips> {
  final _keys = <String, GlobalKey>{};
  final _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    widget.active.addListener(_centreActive);
  }

  @override
  void dispose() {
    widget.active.removeListener(_centreActive);
    _scroll.dispose();
    super.dispose();
  }

  /// Slides the chip row so the active chip is centred — and ONLY the chip row.
  ///
  /// This used to call `Scrollable.ensureVisible`, which walks up EVERY scrollable ancestor of the chip. The
  /// index bar lives inside the page's own CustomScrollView, so each chip tap / scroll-spy change also tried to
  /// scroll the page, fighting the page's own jump animation: that was the glitch after pressing a capsule.
  void _centreActive() {
    if (!_scroll.hasClients) return;
    // The user is dragging the chips themselves: don't fight their finger.
    if (_scroll.position.userScrollDirection != ScrollDirection.idle) return;
    final chip = _keys[widget.active.value]?.currentContext?.findRenderObject();
    final row = context.findRenderObject();
    if (chip is! RenderBox || row is! RenderBox || !chip.attached || !row.attached) return;
    final left = chip.localToGlobal(Offset.zero, ancestor: row).dx;
    final target = (_scroll.offset + left + chip.size.width / 2 - row.size.width / 2).clamp(0.0, _scroll.position.maxScrollExtent);
    if ((target - _scroll.offset).abs() < 1) return;
    _scroll.animateTo(target, duration: context.motion(HmMotion.normal), curve: HmMotion.curve);
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.c;
    // A plain Row in a SingleChildScrollView (9 short chips): every chip is always built, so it can always be
    // measured — a lazy ListView leaves far-away chips without a RenderBox.
    return ValueListenableBuilder<String>(
      valueListenable: widget.active,
      builder: (context, active, _) => SingleChildScrollView(
        controller: _scroll,
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: Hm.gutter, vertical: 7),
        child: Row(children: [
          for (final (i, s) in widget.specs.indexed) ...[
            if (i > 0) const SizedBox(width: 6),
            Semantics(
              button: true,
              selected: s.id == active,
              label: s.title,
              excludeSemantics: true,
              child: GestureDetector(
                key: _keys.putIfAbsent(s.id, GlobalKey.new),
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  HapticFeedback.selectionClick();
                  widget.onJump(s.id);
                },
                child: AnimatedContainer(
                  duration: context.motion(HmMotion.fast),
                  curve: HmMotion.curve,
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(horizontal: 13),
                  decoration: BoxDecoration(
                    color: s.id == active ? c.p : c.sf,
                    borderRadius: BorderRadius.circular(99),
                    border: Border.all(color: s.id == active ? c.p : c.ln),
                  ),
                  child: Text(s.title, style: TextStyle(fontSize: 12.5, fontWeight: s.id == active ? FontWeight.w700 : FontWeight.w600, color: s.id == active ? c.onp : c.ink2)),
                ),
              ),
            ),
          ],
        ]),
      ),
    );
  }
}
