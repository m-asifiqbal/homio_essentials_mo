/// ============================================================
/// HM LAYOUT — page gutter, section headers, caps labels
/// ============================================================
library;

import 'package:material_ui/material_ui.dart';

import 'package:homio_essentials/core/l10n/i18n.dart';
import 'package:homio_essentials/core/theme/tokens.dart';

/// A tab page with a PINNED header: [header] stays put, [body] (a scroll view) scrolls
/// beneath it. A hairline appears under the header only once the content has scrolled,
/// so the header reads as part of the page at rest and as a bar while scrolling.
///
/// Only a ValueNotifier flips on scroll — nothing rebuilds per frame.
class HmTabPage extends StatefulWidget {
  const HmTabPage({super.key, required this.header, required this.body});
  final Widget header;
  final Widget body;

  @override
  State<HmTabPage> createState() => _HmTabPageState();
}

class _HmTabPageState extends State<HmTabPage> {
  final _scrolled = ValueNotifier<bool>(false);

  @override
  void dispose() {
    _scrolled.dispose();
    super.dispose();
  }

  bool _onScroll(ScrollNotification n) {
    if (n.depth == 0 && n.metrics.axis == Axis.vertical) _scrolled.value = n.metrics.pixels > 2;
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final c = context.hm;
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      ValueListenableBuilder<bool>(
        valueListenable: _scrolled,
        child: widget.header,
        builder: (context, scrolled, header) => AnimatedContainer(
          duration: context.motion(HmMotion.fast),
          decoration: BoxDecoration(
            color: c.bg,
            border: Border(bottom: BorderSide(color: scrolled ? c.ln : Colors.transparent)),
          ),
          child: header,
        ),
      ),
      Expanded(child: NotificationListener<ScrollNotification>(onNotification: _onScroll, child: widget.body)),
    ]);
  }
}

/// Content inset by the page gutter (20 pt), as on every design artboard.
class Gutter extends StatelessWidget {
  const Gutter({super.key, required this.child, this.top = 0});
  final Widget child;
  final double top;

  @override
  Widget build(BuildContext context) => Padding(padding: EdgeInsetsDirectional.fromSTEB(Hm.gutter, top, Hm.gutter, 0), child: child);
}

class SectionHeader extends StatelessWidget {
  const SectionHeader(this.title, {super.key, this.action, this.onAction, this.top = 32, this.trailing});
  final String title;
  final String? action;
  final VoidCallback? onAction;
  final double top;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) => Padding(
        padding: EdgeInsetsDirectional.fromSTEB(Hm.gutter, top, Hm.gutter - 8, 10),
        child: Row(children: [
          Expanded(child: Semantics(header: true, child: Text(title, style: Theme.of(context).textTheme.titleLarge))),
          ?trailing,
          if (action != null) TextButton(onPressed: onAction, child: Text(action!)),
        ]),
      );
}

/// Small uppercase label (sentence case in Bangla — no capitals there).
class Cap extends StatelessWidget {
  const Cap(this.text, {super.key, this.color});
  final String text;
  final Color? color;

  @override
  Widget build(BuildContext context) => Text(
        context.bn ? text : text.toUpperCase(),
        style: TextStyle(fontSize: context.bn ? 13 : 12, fontWeight: FontWeight.w700, letterSpacing: context.bn ? 0 : 1, color: color ?? context.hm.ink3),
      );
}
