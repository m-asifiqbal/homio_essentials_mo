/// Indications section — reviewed uses by symptom (curated remedies only).
library;

import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import 'package:homio_essentials/core/l10n/i18n.dart';
import 'package:homio_essentials/core/router/app_routes.dart';
import 'package:homio_essentials/core/theme/tokens.dart';
import 'package:homio_essentials/core/widgets/widgets.dart';
import 'package:homio_essentials/features/remedy/presentation/providers/remedy_providers.dart';

class UsesSection extends StatelessWidget {
  const UsesSection({super.key, required this.d, required this.goSection});
  final RemedyDetail d;
  final ValueChanged<String> goSection;

  @override
  Widget build(BuildContext context) {
    final c = context.hm;
    final l = context.l;
    final bangla = context.bn;
    if (d.uses.isEmpty) {
      return Column(children: [
        Text(l.usesEmptyBody, style: TextStyle(fontSize: 13.5, color: c.ink2, height: 1.55)),
        const SizedBox(height: 12),
        OutlinedButton(onPressed: () => goSection('materia'), child: Text(l.openStudy)),
      ]);
    }
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      for (final (i, u) in d.uses.indexed)
        Padding(
          padding: EdgeInsets.only(bottom: i == d.uses.length - 1 ? 0 : 10),
          child: Builder(builder: (context) {
            final cond = d.conditionsById[u.conditionId];
            return HmCard(
              elevated: false,
              color: c.bg,
              radius: 16,
              padding: const EdgeInsets.all(12),
              onTap: cond == null ? null : () => context.push(AppRoutes.condition(cond.slug)),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  IconTile(Icons.monitor_heart_outlined, (c.dg, c.dgInk), size: 32),
                  const SizedBox(width: 10),
                  Expanded(child: Text(cond?.name(bangla) ?? u.title(bangla) ?? '', style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w600))),
                  if (cond != null) Icon(Icons.chevron_right_rounded, color: c.ink3),
                ]),
                if (u.description(bangla) != null) ...[
                  const SizedBox(height: 8),
                  Text(u.description(bangla)!, style: TextStyle(fontSize: 13.5, height: 1.55, color: c.ink2)),
                ],
                if (u.keyDifference(bangla) != null) ...[
                  const SizedBox(height: 8),
                  Callout(CalloutKind.note, icon: Icons.lightbulb_outline_rounded, child: Text(u.keyDifference(bangla)!)),
                ],
                if (u.route != 'internal' || u.typicalPotencies.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Wrap(spacing: 6, runSpacing: 6, children: [
                    if (u.route != 'internal') HmBadge(l.externalUse, bg: c.pe, ink: c.peInk, icon: Icons.back_hand_outlined),
                    for (final p in u.typicalPotencies) HmBadge(p),
                  ]),
                ],
              ]),
            );
          }),
        ),
      const SizedBox(height: 12),
      Text(l.referenceNote, style: TextStyle(fontSize: 11.5, color: c.ink3, height: 1.5)),
    ]);
  }
}
