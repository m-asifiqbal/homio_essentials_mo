/// Overview section — summary, "mostly used for", typical dose, and the quick-facts table.
library;

import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import 'package:homio_essentials/core/l10n/i18n.dart';
import 'package:homio_essentials/core/router/app_routes.dart';
import 'package:homio_essentials/core/theme/tokens.dart';
import 'package:homio_essentials/core/widgets/widgets.dart';
import 'package:homio_essentials/features/remedy/presentation/providers/remedy_providers.dart';

class OverviewSection extends StatelessWidget {
  const OverviewSection({super.key, required this.d, required this.goSection});
  final RemedyDetail d;
  final ValueChanged<String> goSection;

  @override
  Widget build(BuildContext context) {
    final c = context.hm;
    final l = context.l;
    final bangla = context.bn;
    final r = d.remedy;
    final typical = d.typicalDose;
    final summary = r.summary(bangla);
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      if (summary == null && d.uses.isEmpty && typical == null) ...[
        SectionEmpty(icon: Icons.info_outline_rounded, title: l.overviewEmptyTitle, body: l.overviewEmptyBody, action: l.openMateria, onAction: () => goSection('materia')),
        const SizedBox(height: 12),
      ],
      if (summary != null) ...[
        SelectableText(summary, style: TextStyle(fontSize: 14.5, height: 1.65, color: c.ink)),
        if (r.summaryIsFallback(bangla)) Padding(padding: const EdgeInsets.only(top: 6), child: Text(l.inEnglishNote, style: TextStyle(fontSize: 11.5, color: c.ink3))),
        if (!r.summaryIsFallback(bangla) && r.autoBangla(bangla, 'summary')) Padding(padding: const EdgeInsets.only(top: 6), child: Text(l.autoTranslatedNote, style: TextStyle(fontSize: 11.5, color: c.ink3))),
        const SizedBox(height: 16),
      ],
      if (d.uses.isNotEmpty) ...[
        Cap(l.mostlyUsedFor),
        const SizedBox(height: 8),
        Wrap(spacing: 8, runSpacing: 8, children: [
          for (final u in d.uses.take(6))
            () {
              final cond = d.conditionsById[u.conditionId];
              return HmChip(cond?.name(bangla) ?? u.title(bangla) ?? '', small: true,
                  onTap: cond != null ? () => context.push(AppRoutes.condition(cond.slug)) : () => goSection('uses'));
            }(),
        ]),
        const SizedBox(height: 16),
      ],
      if (typical != null) ...[
        HmCard(
          elevated: false,
          color: c.sf2, border: c.sf2, radius: 18,
          padding: const EdgeInsets.all(12),
          onTap: () => goSection('dosage'),
          child: Row(children: [
            // Grows with its content (large text sizes, taller Bangla script) instead of a fixed 58 x 58 box.
            Container(
              constraints: const BoxConstraints(minWidth: 58, minHeight: 58),
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
              decoration: BoxDecoration(color: c.sf, borderRadius: BorderRadius.circular(16)),
              child: Column(mainAxisSize: MainAxisSize.min, mainAxisAlignment: MainAxisAlignment.center, children: [
                Text(numL(context, typical.amount), style: TextStyle(fontSize: 19, fontWeight: FontWeight.w700, color: c.pd, height: 1.1)),
                Text(typical.isTablet ? l.tablets : l.pellets, style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600, color: c.pd)),
              ]),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Cap(l.typicalAdultDose),
                const SizedBox(height: 2),
                Text('${typical.potency} · ${typical.frequency.of(bangla) ?? ''}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                // A real icon, not the "→" character (neither bundled font has that glyph).
                Row(mainAxisSize: MainAxisSize.min, children: [
                  Flexible(child: Text(l.dosesByAge, style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: c.p))),
                  const SizedBox(width: 4),
                  Icon(Icons.arrow_forward_rounded, size: 14, color: c.p),
                ]),
              ]),
            ),
          ]),
        ),
        const SizedBox(height: 16),
      ],
      Cap(l.quickFacts),
      const SizedBox(height: 6),
      _Facts(rows: [
        (l.factCommon, r.common(bangla)),
        if (bangla) (l.factBangla, r.bnName()),
        (l.factAbbr, r.abbr),
        (l.factKingdom, r.kingdom == null ? null : l.kingdom(r.kingdom)),
        (l.factFamily, r.family),
        (l.factGroups, r.groups.isEmpty ? null : r.groups.map((g) => groupLabel(g, bangla)).join(', ')),
        (l.forms, r.forms.isEmpty ? null : r.forms.map((f) => formLabel(f, bangla)).join(', ')),
        (l.potency, r.potencies.isEmpty ? null : r.potencies.join(', ')),
        (l.route, r.curated ? (r.externalUse ? l.routeOralSkin : l.routeOral) : null),
      ]),
    ]);
  }
}

/// MedEx-style label / value rows with hairlines. Rows with no value are skipped.
class _Facts extends StatelessWidget {
  const _Facts({required this.rows});
  final List<(String, String?)> rows;

  @override
  Widget build(BuildContext context) {
    final c = context.hm;
    final shown = [for (final (k, v) in rows) if (v != null && v.trim().isNotEmpty) (k, v)];
    return Column(children: [
      for (final (i, (k, v)) in shown.indexed) ...[
        if (i > 0) Divider(height: 1, color: c.ln),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 9),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            SizedBox(width: 108, child: Text(k, style: TextStyle(fontSize: 12.5, color: c.ink3, fontWeight: FontWeight.w600))),
            Expanded(child: SelectableText(v, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600, height: 1.35))),
          ]),
        ),
      ],
    ]);
  }
}
