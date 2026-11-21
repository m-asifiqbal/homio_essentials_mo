/// ============================================================
/// REMEDY ROW — the list card for a remedy (Explore, Saved, Home, Condition)
/// ============================================================
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import 'package:homio_essentials/core/archive/domain/entities/models.dart';
import 'package:homio_essentials/core/l10n/i18n.dart';
import 'package:homio_essentials/core/theme/tokens.dart';
import 'package:homio_essentials/core/widgets/widgets.dart';
import 'package:homio_essentials/shared/providers/library_provider.dart';

class RemedyRow extends ConsumerWidget {
  const RemedyRow(this.r, {super.key, this.onTap, this.subtitle, this.dense = false, this.highlight = false, this.query});
  final Remedy r;
  final VoidCallback? onTap;
  final String? subtitle;
  final bool dense, highlight;

  /// When set, matching letters in the name are highlighted.
  final String? query;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.hm;
    final bangla = context.bn;
    final saved = ref.watch(savedProvider.select((s) => s.contains(r.slug)));
    final sub = subtitle ?? [r.common(bangla), r.abbr].whereType<String>().where((s) => s.isNotEmpty).join(' · ');
    final titleStyle = TextStyle(fontWeight: FontWeight.w700, fontSize: dense ? 15 : 16, height: 1.3, color: c.ink);
    return HmCard(
      onTap: onTap,
      border: highlight ? c.p : null,
      semanticLabel: [r.latin, if (sub.isNotEmpty) sub].join(', '),
      padding: EdgeInsets.symmetric(horizontal: 14, vertical: dense ? 10 : 14),
      child: Row(children: [
        LetterTile(r.initial, kingdom: r.kingdom, size: dense ? 40 : 48),
        const SizedBox(width: 14),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            query == null ? Text(r.latin, maxLines: 1, overflow: TextOverflow.ellipsis, style: titleStyle) : HighlightedText(r.latin, query!, style: titleStyle),
            if (bangla && r.bnName() != null) Text(r.bnName()!, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 14, color: c.ink2)),
            if (sub.isNotEmpty) Text(sub, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 13, color: c.ink2, height: 1.4)),
          ]),
        ),
        if (r.curated) Padding(padding: const EdgeInsetsDirectional.only(end: 6), child: Icon(Icons.verified_rounded, size: 16, color: c.okInk, semanticLabel: context.l.reviewed)),
        if (saved) Icon(Icons.bookmark_rounded, color: c.p, size: 20, semanticLabel: context.l.savedTitle) else Icon(Icons.chevron_right_rounded, color: c.ink3),
      ]),
    );
  }
}
