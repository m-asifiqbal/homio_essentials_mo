/// ============================================================
/// OVERVIEW TAB — used-for chips, typical dose, about, safety, related, sources
/// ============================================================
library;

import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import 'package:homio_essentials/core/ads/hm_ad_banner.dart';
import 'package:homio_essentials/core/archive/domain/entities/models.dart';
import 'package:homio_essentials/core/constants/app_info.dart';
import 'package:homio_essentials/core/l10n/i18n.dart';
import 'package:homio_essentials/core/router/app_routes.dart';
import 'package:homio_essentials/core/theme/tokens.dart';
import 'package:homio_essentials/core/utils/launcher.dart';
import 'package:homio_essentials/core/widgets/widgets.dart';
import 'package:homio_essentials/features/promotions/presentation/widgets/promo_slider.dart';
import 'package:homio_essentials/features/remedy/presentation/providers/remedy_providers.dart';
import 'package:homio_essentials/features/remedy/presentation/widgets/remedy_hero.dart';

class OverviewTab extends StatelessWidget {
  const OverviewTab({super.key, required this.d, required this.goTab});
  final RemedyDetail d;
  final ValueChanged<int> goTab;

  @override
  Widget build(BuildContext context) {
    final c = context.hm;
    final l = context.l;
    final bangla = context.bn;
    final r = d.remedy;
    final typical = d.typicalDose;
    final summary = r.summary(bangla);
    final related = d.related.where((x) => x.type != 'antidote' && x.type != 'inimical').toList();

    return TabList(name: 'overview', children: [
      if (d.uses.isNotEmpty || typical != null)
        Gutter(
          child: HmCard(
            radius: 24,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              if (d.uses.isNotEmpty) ...[
                const SizedBox(height: 14),
                Cap(l.mostlyUsedFor),
                const SizedBox(height: 10),
                Wrap(spacing: 8, runSpacing: 8, children: [
                  for (final u in d.uses.take(6))
                    () {
                      final cond = d.conditionsById[u.conditionId];
                      return HmChip(cond?.name(bangla) ?? u.title(bangla) ?? '', small: true,
                          onTap: cond != null ? () => context.push(AppRoutes.condition(cond.slug)) : () => goTab(1));
                    }(),
                ]),
                const SizedBox(height: 14),
              ],
              if (typical != null) ...[
                if (d.uses.isNotEmpty) Divider(color: c.ln),
                InkWell(
                  onTap: () => goTab(2),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    child: Row(children: [
                      Container(
                        width: 64, height: 64,
                        decoration: BoxDecoration(color: c.sf2, borderRadius: BorderRadius.circular(18)),
                        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                          Text(numL(context, typical.amount), style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: c.pd, height: 1)),
                          Text(typical.isTablet ? l.tablets : l.pellets, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: c.pd)),
                        ]),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Cap(l.typicalAdultDose),
                          const SizedBox(height: 2),
                          Text('${typical.potency} · ${typical.frequency.of(bangla) ?? ''}', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                          Text(l.dosesByAge, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: c.p)),
                        ]),
                      ),
                    ]),
                  ),
                ),
              ],
            ]),
          ),
        ),
      if (summary != null) ...[
        SectionHeader(l.about, top: d.uses.isNotEmpty || typical != null ? 28 : 4),
        Gutter(child: SelectableText(summary, style: TextStyle(fontSize: 15.5, height: 1.65, color: c.ink))),
        if (r.summaryIsFallback(bangla)) Gutter(top: 6, child: Text(l.inEnglishNote, style: TextStyle(fontSize: 12, color: c.ink3))),
      ],
      if (r.keynotes.isNotEmpty) ...[
        SectionHeader(l.keynotes, top: 28),
        Gutter(child: _Keynotes(notes: r.keynotes.take(4).toList())),
      ],
      if (d.safety.isNotEmpty) ...[
        SectionHeader(l.safety, top: 28),
        for (final s in d.safety)
          Gutter(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Callout(switch (s.severity) { 'danger' => CalloutKind.danger, 'info' => CalloutKind.note, _ => CalloutKind.warn }, child: Text(s.body.of(bangla) ?? '')),
            ),
          ),
      ],
      if (related.isNotEmpty) ...[
        SectionHeader(l.relatedRemedies, top: 28),
        SizedBox(
          height: 112,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: Hm.gutter),
            itemCount: related.length.clamp(0, 12),
            separatorBuilder: (_, _) => const SizedBox(width: 10),
            itemBuilder: (context, i) {
              final (:remedy, :type) = related[i];
              return SizedBox(
                width: 200,
                child: HmCard(
                  onTap: () => context.push(AppRoutes.remedy(remedy.slug)),
                  padding: const EdgeInsets.all(14),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [
                      LetterTile(remedy.initial, kingdom: remedy.kingdom, size: 36),
                      const SizedBox(width: 10),
                      Expanded(child: latinText(remedy.latin, size: 17, color: c.ink, weight: FontWeight.w600, maxLines: 1)),
                    ]),
                    const Spacer(),
                    Text([l.relation(type), remedy.common(bangla)].whereType<String>().join(' · '), maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12.5, color: c.ink2)),
                  ]),
                ),
              );
            },
          ),
        ),
      ],
      const SizedBox(height: 28),
      const HmAdBanner(),
      const SizedBox(height: 20),
      PromoSlider(placement: 'remedy', remedyId: r.id),
      Gutter(top: 8, child: Text(l.promoNote, style: TextStyle(fontSize: 12, color: c.ink3))),
      SectionHeader(l.sources, top: 28),
      Gutter(child: SourcesCard(r: r)),
      Gutter(
        top: 16,
        child: Wrap(crossAxisAlignment: WrapCrossAlignment.center, children: [
          Text('${l.referenceNote} ', style: TextStyle(fontSize: 12, color: c.ink3, height: 1.6)),
          GestureDetector(onTap: () => context.push(AppRoutes.disclaimer), child: Text(l.readFullNote, style: TextStyle(fontSize: 12, color: c.p, fontWeight: FontWeight.w700))),
        ]),
      ),
    ]);
  }
}

class _Keynotes extends StatelessWidget {
  const _Keynotes({required this.notes});
  final List<String> notes;

  @override
  Widget build(BuildContext context) {
    final c = context.hm;
    return HmCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        for (final k in notes)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(margin: const EdgeInsets.only(top: 8), width: 7, height: 7, decoration: BoxDecoration(color: c.p2, shape: BoxShape.circle)),
              const SizedBox(width: 12),
              Expanded(child: Text(k, style: const TextStyle(fontSize: 14.5, height: 1.55))),
            ]),
          ),
        Text(context.l.keynotesSource, style: TextStyle(fontSize: 12, color: c.ink3)),
      ]),
    );
  }
}

/// Where the remedy's text comes from, and whether it was checked against the printed book.
class SourcesCard extends StatelessWidget {
  const SourcesCard({super.key, required this.r});
  final Remedy r;

  @override
  Widget build(BuildContext context) {
    final c = context.hm;
    final l = context.l;
    return HmCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        for (final ref in r.sourceRefs)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Icon(Icons.menu_book_outlined, size: 20, color: c.pd),
              const SizedBox(width: 12),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('${ref['title'] ?? l.sourceBoericke}', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                  if (ref['scan'] is Map && (ref['scan'] as Map)['page'] != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Row(children: [
                        Icon(Icons.verified_outlined, size: 14, color: c.okInk),
                        const SizedBox(width: 4),
                        Expanded(child: Text(l.sourceChecked(numL(context, (ref['scan'] as Map)['page'])), style: TextStyle(fontSize: 12.5, color: c.okInk))),
                      ]),
                    ),
                  if (ref['url'] is String)
                    GestureDetector(
                      onTap: () => openTarget('website', ref['url'] as String),
                      child: Padding(padding: const EdgeInsets.only(top: 4), child: Text(l.viewSource, style: TextStyle(fontSize: 12.5, color: c.p, fontWeight: FontWeight.w700))),
                    ),
                ]),
              ),
            ]),
          ),
        if (r.curated) Text(l.sourceCurated(AppInfo.localizedName(context.bn)), style: TextStyle(fontSize: 12.5, color: c.ink2, height: 1.5)),
      ]),
    );
  }
}
