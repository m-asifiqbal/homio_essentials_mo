/// ============================================================
/// HM FEEDBACK — callouts, empty states, skeletons, snackbars
/// ============================================================
library;

import 'package:material_ui/material_ui.dart';

import 'package:homio_essentials/core/theme/tokens.dart';

enum CalloutKind { warn, danger, note, ok }

/// The design's one safety/info pattern (`.warn` `.dgr` `.note` `.okn`): calm, never alarming.
class Callout extends StatelessWidget {
  const Callout(this.kind, {super.key, required this.child, this.icon});
  final CalloutKind kind;
  final Widget child;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final c = context.hm;
    final (bg, ink, ic) = switch (kind) {
      CalloutKind.warn => (c.am, c.amInk, Icons.warning_amber_rounded),
      CalloutKind.danger => (c.dg, c.dgInk, Icons.error_outline_rounded),
      CalloutKind.note => (c.sf2, c.pd, Icons.info_outline_rounded),
      CalloutKind.ok => (c.ok, c.okInk, Icons.check_circle_outline_rounded),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(18)),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(icon ?? ic, color: ink, size: 20),
        const SizedBox(width: 12),
        Expanded(child: DefaultTextStyle.merge(style: TextStyle(color: ink, fontSize: 14, height: 1.5), child: child)),
      ]),
    );
  }
}

class EmptyState extends StatelessWidget {
  const EmptyState({super.key, required this.icon, required this.title, this.body, this.action, this.onAction, this.secondary});
  final IconData icon;
  final String title;
  final String? body, action;
  final VoidCallback? onAction;
  final Widget? secondary;

  @override
  Widget build(BuildContext context) {
    final c = context.hm;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 32),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 72, height: 72, decoration: BoxDecoration(color: c.sf2, borderRadius: BorderRadius.circular(22)), child: Icon(icon, color: c.pd, size: 32)),
        const SizedBox(height: 16),
        Text(title, textAlign: TextAlign.center, style: Theme.of(context).textTheme.titleMedium),
        if (body != null) ...[const SizedBox(height: 6), Text(body!, textAlign: TextAlign.center, style: TextStyle(color: c.ink2, height: 1.5))],
        if (action != null) ...[const SizedBox(height: 16), OutlinedButton(onPressed: onAction, child: Text(action!))],
        ?secondary,
      ]),
    );
  }
}

/// Shimmering placeholder block (design `.sk`). Static when animations are off.
class HmSkeleton extends StatefulWidget {
  const HmSkeleton({super.key, this.height = 16, this.width, this.radius = 10});
  final double height;
  final double? width;
  final double radius;
  @override
  State<HmSkeleton> createState() => _HmSkeletonState();
}

class _HmSkeletonState extends State<HmSkeleton> with SingleTickerProviderStateMixin {
  late final _ctl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1300))..repeat();

  @override
  void dispose() {
    _ctl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.hm;
    final still = MediaQuery.disableAnimationsOf(context);
    return AnimatedBuilder(
      animation: _ctl,
      builder: (context, _) => Container(
        height: widget.height,
        width: widget.width,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(widget.radius),
          gradient: LinearGradient(
            begin: Alignment(-1.5 + (still ? 1 : _ctl.value * 3), 0),
            end: Alignment(-0.5 + (still ? 1 : _ctl.value * 3), 0),
            colors: [c.sf2, c.sf3, c.sf2],
          ),
        ),
      ),
    );
  }
}

/// A list of skeleton rows shaped like remedy rows.
class SkeletonList extends StatelessWidget {
  const SkeletonList({super.key, this.count = 6});
  final int count;
  @override
  Widget build(BuildContext context) => Column(children: [
        for (var i = 0; i < count; i++)
          Padding(
            padding: const EdgeInsets.fromLTRB(Hm.gutter, 0, Hm.gutter, 10),
            child: Row(children: [
              const HmSkeleton(height: 48, width: 48, radius: 14),
              const SizedBox(width: 14),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                HmSkeleton(height: 14, width: 120.0 + (i % 3) * 40),
                const SizedBox(height: 8),
                const HmSkeleton(height: 11, width: 140),
              ])),
            ]),
          ),
      ]);
}

void showHmSnack(BuildContext context, String msg, {String? action, VoidCallback? onAction}) => ScaffoldMessenger.of(context)
  ..hideCurrentSnackBar()
  ..showSnackBar(SnackBar(
    content: Text(msg),
    duration: const Duration(seconds: 3),
    action: action == null ? null : SnackBarAction(label: action, onPressed: onAction ?? () {}),
  ));

/// The empty state INSIDE a card / section: a soft layered icon on top, a title, a short message and an
/// optional action. (Full-page empties use [EmptyState]; this one is compact and sits in a section body.)
class SectionEmpty extends StatelessWidget {
  const SectionEmpty({super.key, required this.icon, required this.title, this.body, this.action, this.onAction});
  final IconData icon;
  final String title;
  final String? body, action;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final c = context.hm;
    return Semantics(
      container: true,
      label: [title, ?body].join('. '),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          // Two soft rings behind the icon give it depth without any image asset.
          Container(
            width: 84, height: 84, alignment: Alignment.center,
            decoration: BoxDecoration(shape: BoxShape.circle, color: c.sf2.withValues(alpha: .55)),
            child: Container(
              width: 62, height: 62, alignment: Alignment.center,
              decoration: BoxDecoration(shape: BoxShape.circle, color: c.sf2, border: Border.all(color: c.ln)),
              child: ExcludeSemantics(child: Icon(icon, size: 30, color: c.pd)),
            ),
          ),
          const SizedBox(height: 14),
          Text(title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
          if (body != null) ...[
            const SizedBox(height: 6),
            Text(body!, textAlign: TextAlign.center, style: TextStyle(fontSize: 13, color: c.ink2, height: 1.5)),
          ],
          if (action != null) ...[
            const SizedBox(height: 14),
            OutlinedButton(onPressed: onAction, child: Text(action!)),
          ],
        ]),
      ),
    );
  }
}
