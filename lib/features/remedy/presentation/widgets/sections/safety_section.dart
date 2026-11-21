/// Safety & precautions — the remedy's own safety notes first, then the standing
/// precautions MedEx also gives for every medicine (pregnancy, children, existing
/// treatment, storage, when to see a doctor) as icon rows.
library;

import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import 'package:homio_essentials/core/l10n/i18n.dart';
import 'package:homio_essentials/core/router/app_routes.dart';
import 'package:homio_essentials/core/theme/tokens.dart';
import 'package:homio_essentials/core/widgets/widgets.dart';
import 'package:homio_essentials/features/remedy/presentation/providers/remedy_providers.dart';

class SafetySection extends StatelessWidget {
  const SafetySection({super.key, required this.d});
  final RemedyDetail d;

  @override
  Widget build(BuildContext context) {
    final c = context.hm;
    final l = context.l;
    final bangla = context.bn;
    final rows = <(IconData, (Color, Color), String, String)>[
      (Icons.pregnant_woman_rounded, (c.noBg, c.noInk), l.precPregnancyT, l.precPregnancyB),
      (Icons.child_care_rounded, (c.am, c.amInk), l.precChildrenT, l.precChildrenB),
      (Icons.medication_liquid_outlined, (c.miBg, c.miInk), l.precOngoingT, l.precOngoingB),
      (Icons.inventory_2_outlined, (c.ptBg, c.ptInk), l.precStorageT, l.precStorageB),
      (Icons.local_hospital_outlined, (c.dg, c.dgInk), l.precDoctorT, l.precDoctorB),
    ];
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      for (final s in d.safety)
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Callout(switch (s.severity) { 'danger' => CalloutKind.danger, 'info' => CalloutKind.note, _ => CalloutKind.warn }, child: Text(s.body.of(bangla) ?? '')),
        ),
      if (d.safety.isNotEmpty) const SizedBox(height: 6),
      for (final (i, (icon, tone, t, b)) in rows.indexed)
        Padding(
          padding: EdgeInsets.only(top: i == 0 ? 0 : 12),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            IconTile(icon, tone, size: 34),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(t, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600)),
                const SizedBox(height: 1),
                Text(b, style: TextStyle(fontSize: 12.5, color: c.ink2, height: 1.45)),
              ]),
            ),
          ]),
        ),
      const SizedBox(height: 14),
      Wrap(crossAxisAlignment: WrapCrossAlignment.center, children: [
        Text('${l.referenceNote} ', style: TextStyle(fontSize: 11.5, color: c.ink3, height: 1.6)),
        GestureDetector(
          onTap: () => context.push(AppRoutes.disclaimer),
          child: Text(l.readFullNote, style: TextStyle(fontSize: 11.5, color: c.p, fontWeight: FontWeight.w700)),
        ),
      ]),
    ]);
  }
}
