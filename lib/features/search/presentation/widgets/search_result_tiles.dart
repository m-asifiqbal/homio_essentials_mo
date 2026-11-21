/// Result rows: remedy, symptom, company and book-text hits.
library;

import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import 'package:homio_essentials/core/archive/domain/entities/archive.dart';
import 'package:homio_essentials/core/l10n/i18n.dart';
import 'package:homio_essentials/core/router/app_routes.dart';
import 'package:homio_essentials/core/theme/tokens.dart';
import 'package:homio_essentials/core/utils/launcher.dart';
import 'package:homio_essentials/core/widgets/widgets.dart';
import 'package:homio_essentials/features/search/domain/entities/search_hit.dart';

class SearchHitTile extends StatelessWidget {
  const SearchHitTile({super.key, required this.hit, required this.archive, required this.query, required this.onOpen});
  final SearchHit hit;
  final Archive archive;
  final String query;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final c = context.hm;
    final l = context.l;
    final bangla = context.bn;
    late final Widget leading;
    late final String title;
    final lines = <String>[];
    VoidCallback go = () {};
    Widget? badge;
    switch (hit.kind) {
      case HitKind.remedy:
        final r = archive.remedyBySlug[hit.id]!;
        leading = LetterTile(r.initial, kingdom: r.kingdom, size: 44);
        title = r.latin;
        lines.add([l.kingdom(r.kingdom), r.common(bangla)].whereType<String>().join(' · '));
        if (bangla && r.bnName() != null) lines.add(r.bnName()!);
        if (r.curated) badge = Icon(Icons.verified_rounded, size: 16, color: c.okInk, semanticLabel: l.reviewed);
        go = () => context.push(AppRoutes.remedy(r.slug));
      case HitKind.condition:
        final cd = archive.conditionBySlug[hit.id]!;
        leading = IconTile(Icons.monitor_heart_outlined, (c.dg, c.dgInk), size: 44);
        title = cd.name(bangla);
        lines.add('${l.kindSymptom} · ${l.remedyCount(numL(context, archive.usesByCondition[cd.id]?.length ?? 0))}');
        go = () => context.push(AppRoutes.condition(cd.slug));
      case HitKind.manufacturer:
        final m = archive.manufacturerById[hit.id]!;
        leading = IconTile(Icons.factory_outlined, (c.miBg, c.miInk), size: 44);
        title = m.name;
        lines.add([l.kindCompany, m.country].whereType<String>().join(' · '));
        go = () => m.website == null ? context.go(AppRoutes.exploreTab('companies')) : openTarget('website', m.website!);
    }
    final alias = hit.matched.toLowerCase() != title.toLowerCase() && !lines.any((x) => x.contains(hit.matched)) ? hit.matched : null;
    return InkWell(
      onTap: () { onOpen(); go(); },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: Hm.gutter, vertical: 10),
        child: Row(children: [
          leading,
          const SizedBox(width: 14),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Flexible(child: HighlightedText(title, query)),
                if (badge != null) ...[const SizedBox(width: 6), badge],
              ]),
              for (final line in lines) Text(line, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 13, color: c.ink2)),
              if (alias != null)
                Row(children: [
                  Icon(Icons.subdirectory_arrow_right_rounded, size: 14, color: c.ink3),
                  const SizedBox(width: 2),
                  Flexible(child: HighlightedText(alias, query, style: TextStyle(fontSize: 12.5, color: c.ink3))),
                ]),
            ]),
          ),
          Icon(Icons.north_east_rounded, size: 18, color: c.ink3),
        ]),
      ),
    );
  }
}

class BookHitTile extends StatelessWidget {
  const BookHitTile({super.key, required this.hit, required this.archive, required this.query, required this.onOpen});
  final BookHit hit;
  final Archive archive;
  final String query;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final c = context.hm;
    final l = context.l;
    final r = archive.remedyById[hit.remedyId]!;
    return Gutter(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: HmCard(
          onTap: () { onOpen(); context.push(AppRoutes.remedy(r.slug, tab: 'study')); },
          padding: const EdgeInsets.all(14),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              LetterTile(r.initial, kingdom: r.kingdom, size: 32),
              const SizedBox(width: 10),
              Expanded(child: latinText(r.latin, size: 17, color: c.ink, weight: FontWeight.w600, maxLines: 1)),
              HmBadge('${l.book(hit.book)} · ${hit.section}', bg: c.anBg, ink: c.anInk),
            ]),
            const SizedBox(height: 8),
            HighlightedText(hit.snippet, query, maxLines: 3, style: TextStyle(fontSize: 13.5, height: 1.5, color: c.ink2)),
          ]),
        ),
      ),
    );
  }
}
