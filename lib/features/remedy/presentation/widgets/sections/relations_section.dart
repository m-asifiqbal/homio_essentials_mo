/// Relationships — Boericke's Compare / Complementary / Follows well / Antidote / Inimical,
/// grouped by kind (MedEx's "Interaction" section, in homeopathic terms). Antidotes and
/// inimicals are marked as "avoid together" cautions.
library;

import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import 'package:homio_essentials/core/l10n/i18n.dart';
import 'package:homio_essentials/core/router/app_routes.dart';
import 'package:homio_essentials/core/theme/tokens.dart';
import 'package:homio_essentials/core/widgets/widgets.dart';
import 'package:homio_essentials/features/remedy/presentation/providers/remedy_providers.dart';

const relationOrder = ['complementary', 'follows_well', 'compare', 'antidote', 'inimical'];

class RelationsSection extends StatelessWidget {
  const RelationsSection({super.key, required this.related});
  final List<RelatedRemedy> related;

  @override
  Widget build(BuildContext context) {
    final c = context.hm;
    final l = context.l;
    final bangla = context.bn;
    final groups = <String, List<RelatedRemedy>>{};
    for (final x in related) {
      (groups[x.type] ??= []).add(x);
    }
    final kinds = [...relationOrder.where(groups.containsKey), ...groups.keys.where((k) => !relationOrder.contains(k))];
    (IconData, (Color, Color)) look(String t) => switch (t) {
          'antidote' => (Icons.block_rounded, (c.dg, c.dgInk)),
          'inimical' => (Icons.do_not_disturb_on_outlined, (c.dg, c.dgInk)),
          'complementary' => (Icons.add_link_rounded, (c.ptBg, c.ptInk)),
          'follows_well' => (Icons.trending_flat_rounded, (c.miBg, c.miInk)),
          _ => (Icons.compare_arrows_rounded, (c.sf2, c.pd)),
        };
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      for (final (i, k) in kinds.indexed) ...[
        if (i > 0) const SizedBox(height: 16),
        Row(children: [
          IconTile(look(k).$1, look(k).$2, size: 28),
          const SizedBox(width: 10),
          Text(l.relation(k), style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700)),
          const SizedBox(width: 6),
          Text('· ${numL(context, groups[k]!.length)}', style: TextStyle(fontSize: 12.5, color: c.ink3)),
        ]),
        const SizedBox(height: 8),
        Wrap(spacing: 8, runSpacing: 8, children: [
          for (final (:remedy, type: _) in groups[k]!.take(24))
            HmChip(
              bangla && remedy.bnName() != null ? '${remedy.latin} · ${remedy.bnName()}' : remedy.latin,
              small: true,
              icon: kingdomIcon(remedy.kingdom),
              onTap: () => context.push(AppRoutes.remedy(remedy.slug)),
            ),
        ]),
        if (k == 'antidote' || k == 'inimical') Padding(padding: const EdgeInsets.only(top: 8), child: Text(l.relationAvoidNote, style: TextStyle(fontSize: 11.5, color: c.ink3, height: 1.45))),
      ],
    ]);
  }
}
