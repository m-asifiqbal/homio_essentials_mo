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
    final flat = shrinkOffset > 0 || overlapsContent;
    return Container(
      color: heroColor,
      child: AnimatedContainer(
        duration: context.motion(HmMotion.fast),
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

  @override
  void initState() {
    super.initState();
    widget.active.addListener(_reveal);
  }

  @override
  void dispose() {
    widget.active.removeListener(_reveal);
    super.dispose();
  }

  /// Keeps the active chip in view as the page scrolls.
  void _reveal() {
    final ctx = _keys[widget.active.value]?.currentContext;
    if (ctx == null) return;
    Scrollable.ensureVisible(ctx, alignment: .35, duration: context.motion(HmMotion.normal), curve: HmMotion.curve);
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.c;
    return ValueListenableBuilder<String>(
      valueListenable: widget.active,
      builder: (context, active, _) => ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: Hm.gutter, vertical: 7),
        itemCount: widget.specs.length,
        separatorBuilder: (_, _) => const SizedBox(width: 6),
        itemBuilder: (context, i) {
          final s = widget.specs[i];
          final on = s.id == active;
          return Semantics(
            button: true,
            selected: on,
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
                  color: on ? c.p : c.sf,
                  borderRadius: BorderRadius.circular(99),
                  border: Border.all(color: on ? c.p : c.ln),
                ),
                child: Text(s.title, style: TextStyle(fontSize: 12.5, fontWeight: on ? FontWeight.w700 : FontWeight.w600, color: on ? c.onp : c.ink2)),
              ),
            ),
          );
        },
      ),
    );
  }
}
