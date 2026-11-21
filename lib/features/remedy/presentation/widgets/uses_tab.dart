/// USES TAB — reviewed uses by symptom (curated remedies only).
library;

import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import 'package:homio_essentials/core/l10n/i18n.dart';
import 'package:homio_essentials/core/router/app_routes.dart';
import 'package:homio_essentials/core/theme/tokens.dart';
import 'package:homio_essentials/core/widgets/widgets.dart';
import 'package:homio_essentials/features/remedy/presentation/providers/remedy_providers.dart';
import 'package:homio_essentials/features/remedy/presentation/widgets/remedy_hero.dart';

class UsesTab extends StatelessWidget {
  const UsesTab({super.key, required this.d, required this.openStudy});
  final RemedyDetail d;
  final VoidCallback openStudy;

  @override
  Widget build(BuildContext context) {
    final c = context.hm;
    final l = context.l;
    final bangla = context.bn;
    if (d.uses.isEmpty) {
      return TabList(name: 'uses', children: [
        EmptyState(icon: Icons.fact_check_outlined, title: l.usesEmptyTitle, body: l.usesEmptyBody, action: l.openStudy, onAction: openStudy),
      ]);
    }
    return TabList(name: 'uses', children: [
      Gutter(child: Text(l.usesTitle, style: Theme.of(context).textTheme.headlineSmall)),
      const SizedBox(height: 14),
      for (final u in d.uses)
        Gutter(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Builder(builder: (context) {
              final cond = d.conditionsById[u.conditionId];
              return HmCard(
                onTap: cond == null ? null : () => context.push(AppRoutes.condition(cond.slug)),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    IconTile(Icons.monitor_heart_outlined, (c.dg, c.dgInk), size: 36),
                    const SizedBox(width: 12),
                    Expanded(child: Text(cond?.name(bangla) ?? u.title(bangla) ?? '', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700))),
                    if (cond != null) Icon(Icons.chevron_right_rounded, color: c.ink3),
                  ]),
                  if (u.description(bangla) != null) ...[
                    const SizedBox(height: 10),
                    Text(u.description(bangla)!, style: TextStyle(fontSize: 14.5, height: 1.55, color: c.ink2)),
                  ],
                  if (u.route != 'internal' || u.typicalPotencies.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Wrap(spacing: 6, runSpacing: 6, children: [
                      if (u.route != 'internal') HmBadge(l.externalUse, bg: c.pe, ink: c.peInk, icon: Icons.back_hand_outlined),
                      for (final p in u.typicalPotencies) HmBadge(p),
                    ]),
                  ],
                ]),
              );
            }),
          ),
        ),
      Gutter(top: 8, child: Text(l.referenceNote, style: TextStyle(fontSize: 12, color: c.ink3))),
    ]);
  }
}
