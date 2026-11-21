/// Explore › Symptoms and Companies lists.
library;

import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import 'package:homio_essentials/core/archive/domain/entities/archive.dart';
import 'package:homio_essentials/core/l10n/i18n.dart';
import 'package:homio_essentials/core/router/app_routes.dart';
import 'package:homio_essentials/core/theme/tokens.dart';
import 'package:homio_essentials/core/utils/launcher.dart';
import 'package:homio_essentials/core/widgets/widgets.dart';

class SymptomList extends StatelessWidget {
  const SymptomList({super.key, required this.archive});
  final Archive archive;

  @override
  Widget build(BuildContext context) {
    final c = context.hm;
    final bangla = context.bn;
    return ListView.separated(
      padding: EdgeInsets.fromLTRB(Hm.gutter, 4, Hm.gutter, context.barClearance),
      itemCount: archive.conditions.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, i) {
        final cd = archive.conditions[i];
        final n = archive.usesByCondition[cd.id]?.length ?? 0;
        return HmCard(
          onTap: () => context.push(AppRoutes.condition(cd.slug)),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(children: [
            IconTile(Icons.monitor_heart_outlined, (c.dg, c.dgInk)),
            const SizedBox(width: 14),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(cd.name(bangla), style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14.5)),
                Text(context.l.remedyCount(numL(context, n)), style: TextStyle(fontSize: 12.5, color: c.ink2)),
              ]),
            ),
            Icon(Icons.chevron_right_rounded, color: c.ink3),
          ]),
        );
      },
    );
  }
}

class CompanyList extends StatelessWidget {
  const CompanyList({super.key, required this.archive});
  final Archive archive;

  @override
  Widget build(BuildContext context) {
    final c = context.hm;
    final l = context.l;
    return ListView.separated(
      padding: EdgeInsets.fromLTRB(Hm.gutter, 4, Hm.gutter, context.barClearance),
      itemCount: archive.manufacturers.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, i) {
        final m = archive.manufacturers[i];
        final mono = (m.shortName ?? m.name).replaceAll(RegExp(r'[^A-Za-z]'), '');
        return HmCard(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          onTap: m.website == null ? null : () => openTarget('website', m.website!),
          child: Row(children: [
            Container(
              width: 44, height: 44, alignment: Alignment.center,
              decoration: BoxDecoration(color: c.miBg, borderRadius: BorderRadius.circular(12)),
              child: Text(mono.length >= 2 ? mono.substring(0, 2).toUpperCase() : mono.toUpperCase(), style: TextStyle(color: c.miInk, fontWeight: FontWeight.w700, fontSize: 14)),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(m.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14.5)),
                Text([m.city, m.country].whereType<String>().join(', '), style: TextStyle(fontSize: 12.5, color: c.ink2)),
                if (m.soldInBd == true) Padding(padding: const EdgeInsets.only(top: 4), child: HmBadge(l.soldInBd, bg: c.ok, ink: c.okInk, icon: Icons.check_rounded)),
              ]),
            ),
            if (m.website != null) Icon(Icons.open_in_new_rounded, size: 18, color: c.ink3, semanticLabel: l.website),
          ]),
        );
      },
    );
  }
}
