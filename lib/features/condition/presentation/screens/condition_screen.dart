/// ============================================================
/// CONDITION SCREEN — "I have a cough": red flags first, then remedies to compare
/// ============================================================
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import 'package:homio_essentials/core/ads/hm_ad_banner.dart';
import 'package:homio_essentials/core/archive/domain/entities/models.dart';
import 'package:homio_essentials/core/l10n/i18n.dart';
import 'package:homio_essentials/core/router/app_routes.dart';
import 'package:homio_essentials/core/theme/tokens.dart';
import 'package:homio_essentials/core/widgets/widgets.dart';
import 'package:homio_essentials/shared/widgets/archive_gate.dart';
import 'package:homio_essentials/features/condition/presentation/providers/condition_providers.dart';

/// Which source books the lines on this page are quoted from (the `source:` tags of its remedy links).
List<String> _sources(List<({Remedy remedy, RemedyUse use})> entries) =>
    {for (final e in entries) for (final t in e.use.tags) if (t.startsWith('source:')) t.substring(7)}.toList()..sort();

class ConditionScreen extends ConsumerWidget {
  const ConditionScreen({super.key, required this.slug});
  final String slug;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l;
    final c = context.hm;
    final bangla = context.bn;
    return Scaffold(
      appBar: AppBar(leading: IconButton(onPressed: () => context.pop(), icon: const Icon(Icons.arrow_back_rounded), tooltip: l.back)),
      body: switch (ref.watch(conditionDetailProvider(slug))) {
        AsyncValue(:final value?) => ListView(padding: const EdgeInsets.only(bottom: 32), children: [
            Gutter(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              HmBadge(l.kindSymptom, bg: c.dg, ink: c.dgInk, icon: Icons.monitor_heart_outlined),
              const SizedBox(height: 10),
              Semantics(header: true, child: Text(value.condition.name(bangla), style: Theme.of(context).textTheme.headlineMedium)),
              if (value.condition.description(bangla) != null)
                Padding(padding: const EdgeInsets.only(top: 6), child: Text(value.condition.description(bangla)!, style: TextStyle(color: c.ink2, height: 1.5))),
              if (value.condition.autoBangla(bangla))
                Padding(padding: const EdgeInsets.only(top: 6), child: Text(l.autoTranslatedPage, style: TextStyle(fontSize: 11.5, color: c.ink3, height: 1.4))),
            ])),
            if (value.condition.redFlags(bangla) != null)
              Gutter(
                top: 16,
                child: Callout(CalloutKind.danger, icon: Icons.local_hospital_outlined,
                    child: Text.rich(TextSpan(children: [TextSpan(text: '${l.seeDoctorIf}: ', style: const TextStyle(fontWeight: FontWeight.w700)), TextSpan(text: value.condition.redFlags(bangla))]))),
              ),
            SectionHeader(l.remediesForThis, top: 24, trailing: HmBadge(numL(context, value.entries.length))),
            if (value.entries.isEmpty) EmptyState(icon: Icons.medication_outlined, title: l.conditionEmpty),
            for (final (:remedy, :use) in value.entries)
              Gutter(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: HmCard(
                    onTap: () => context.push(AppRoutes.remedy(remedy.slug)),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Row(children: [
                        LetterTile(remedy.initial, kingdom: remedy.kingdom, size: 40),
                        const SizedBox(width: 12),
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(remedy.latin, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                          Text([remedy.common(bangla), if (bangla) remedy.bnName()].whereType<String>().join(' · '), style: TextStyle(fontSize: 13, color: c.ink2)),
                        ])),
                        Icon(Icons.chevron_right_rounded, color: c.ink3),
                      ]),
                      if ((use.keyDifference(bangla) ?? use.description(bangla)) != null) ...[
                        const SizedBox(height: 10),
                        Text(use.keyDifference(bangla) ?? use.description(bangla)!, style: TextStyle(fontSize: 14, height: 1.5, color: c.ink2)),
                      ],
                    ]),
                  ),
                ),
              ),
            if (_sources(value.entries).isNotEmpty)
              Gutter(top: 4, child: Text(l.quotedFrom(_sources(value.entries).map((s) => l.bookSource(s)).join(' · ')), style: TextStyle(fontSize: 12, color: c.ink3, height: 1.45))),
            Gutter(top: 8, child: Text(l.referenceNote, style: TextStyle(fontSize: 12, color: c.ink3))),
            const SizedBox(height: 20),
            const HmAdBanner(),
          ]),
        AsyncValue(hasValue: true) => EmptyState(icon: Icons.search_off_rounded, title: l.notFound),
        AsyncError(:final error) => ArchiveError(error: error),
        _ => const SkeletonList(),
      },
    );
  }
}
