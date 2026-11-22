/// ============================================================
/// REMEDY SECTION — one collapsible, titled block of the details page
/// ============================================================
///
/// The details page is a single scrolling page of sections (the MedEx pattern:
/// Indications · Dosage & Administration · Precautions · Brands …) with a sticky
/// index on top — not five tabs hiding content. Each section is an accordion card:
/// icon tile, title, a short summary line, and a chevron.
///
/// The body is built the first time the section opens and then kept (state such as
/// the selected potency survives collapsing); while closed it is Offstage — no layout,
/// no paint. Opening animates the height factor, never rebuilds the body.
/// ============================================================
library;

import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import 'package:homio_essentials/core/l10n/i18n.dart';
import 'package:homio_essentials/core/theme/tokens.dart';
import 'package:homio_essentials/core/widgets/widgets.dart';

/// What the screen needs to know about a section to lay it out, index it and jump to it.
class RemedySectionSpec {
  const RemedySectionSpec({required this.id, required this.title, required this.icon, required this.tone, required this.builder, this.summary, this.count, this.empty = false});
  final String id;
  final String title;
  final IconData icon;
  final (Color, Color) tone;
  final WidgetBuilder builder;

  /// One line under the title while collapsed ("30C · 6 age groups").
  final String? summary;

  /// A small count badge (uses, relations, brands).
  final int? count;

  /// No information for this remedy: the section stays listed (consistent page, like MedEx) but its tile is
  /// muted and its body is an empty state with an icon and a message.
  final bool empty;
}

class RemedySectionCard extends StatelessWidget {
  /// Space between the screen edge and a section card: the page gutter (16) minus 3 dp.
  static const sideInset = Hm.gutter - 3;

  /// Space between a section card's edge and the cards / text nested inside it: 16 minus 2.5 dp.
  static const bodyInset = 16 - 2.5;

  const RemedySectionCard({super.key, required this.spec, required this.open, required this.onToggle});
  final RemedySectionSpec spec;
  final bool open;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final c = context.hm;
    return Semantics(
      container: true,
      child: DecoratedBox(
        decoration: BoxDecoration(color: c.sf, borderRadius: BorderRadius.circular(22), border: Border.all(color: c.ln), boxShadow: c.cardShadow),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Semantics(
            button: true,
            expanded: open,
            label: spec.title,
            excludeSemantics: true,
            onTap: onToggle,
            child: InkWell(
              borderRadius: BorderRadius.circular(22),
              onTap: () {
                HapticFeedback.selectionClick();
                onToggle();
              },
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 12, 12),
                child: Row(children: [
                  IconTile(spec.icon, spec.empty ? (c.sf2, c.ink3) : spec.tone, size: 38),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(spec.title, style: Theme.of(context).textTheme.titleMedium),
                      if ((spec.empty || spec.summary != null) && !open)
                        Padding(
                          padding: const EdgeInsets.only(top: 1),
                          child: Text(spec.empty ? context.l.noInfoYet : spec.summary!, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12, color: spec.empty ? c.ink3 : c.ink2)),
                        ),
                    ]),
                  ),
                  if (spec.count != null) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(color: c.sf2, borderRadius: BorderRadius.circular(99)),
                      child: Text('${spec.count}', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: c.pd)),
                    ),
                    const SizedBox(width: 4),
                  ],
                  AnimatedRotation(
                    turns: open ? .5 : 0,
                    duration: context.motion(HmMotion.normal),
                    curve: HmMotion.curve,
                    child: Icon(Icons.keyboard_arrow_down_rounded, color: open ? c.p : c.ink3),
                  ),
                ]),
              ),
            ),
          ),
          _Collapsible(
            open: open,
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              Divider(height: 1, color: c.ln),
              Padding(padding: const EdgeInsets.fromLTRB(bodyInset, 14, bodyInset, 16), child: Builder(builder: spec.builder)),
            ]),
          ),
        ]),
      ),
    );
  }
}

class _Collapsible extends StatefulWidget {
  const _Collapsible({required this.open, required this.child});
  final bool open;
  final Widget child;

  @override
  State<_Collapsible> createState() => _CollapsibleState();
}

class _CollapsibleState extends State<_Collapsible> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 240), value: widget.open ? 1 : 0);
  late final Animation<double> _t = CurvedAnimation(parent: _c, curve: HmMotion.curve);
  late bool _built = widget.open;

  @override
  void didUpdateWidget(_Collapsible old) {
    super.didUpdateWidget(old);
    if (widget.open == old.open) return;
    if (widget.open) _built = true;
    if (context.reduceMotion) {
      _c.value = widget.open ? 1 : 0;
    } else {
      widget.open ? _c.forward() : _c.reverse();
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_built) return const SizedBox(width: double.infinity);
    return AnimatedBuilder(
      animation: _t,
      child: widget.child,
      builder: (context, child) => Offstage(
        offstage: _c.isDismissed,
        child: ClipRect(child: Align(alignment: Alignment.topCenter, heightFactor: _t.value, child: SizedBox(width: double.infinity, child: child))),
      ),
    );
  }
}
