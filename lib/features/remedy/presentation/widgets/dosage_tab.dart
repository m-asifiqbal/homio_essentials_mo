/// ============================================================
/// DOSAGE TAB — potency + age → dose per time; how to take; Boericke's note
/// ============================================================
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import 'package:homio_essentials/core/ads/hm_ad_banner.dart';
import 'package:homio_essentials/core/l10n/i18n.dart';
import 'package:homio_essentials/core/theme/tokens.dart';
import 'package:homio_essentials/core/widgets/widgets.dart';
import 'package:homio_essentials/features/remedy/presentation/providers/remedy_providers.dart';
import 'package:homio_essentials/features/remedy/presentation/widgets/remedy_hero.dart';

class DosageTab extends ConsumerWidget {
  const DosageTab({super.key, required this.d});
  final RemedyDetail d;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.hm;
    final l = context.l;
    final bangla = context.bn;
    final r = d.remedy;
    final sel = ref.watch(dosageControllerProvider(r.slug));
    final ctl = ref.read(dosageControllerProvider(r.slug).notifier);
    final pots = d.potencies;
    final pot = sel.potency ?? (pots.contains('30C') ? '30C' : pots.firstOrNull);
    final rule = d.rules.where((x) => x.potency == pot && x.ageGroup == sel.ageGroup).firstOrNull;
    final high = pot == '1M' || pot == '200C';
    final boerickeDose = r.curated ? null : ref.watch(materiaProvider(r.id)).value?.where((m) => m.book == 'boericke' && m.section == 'Dose').firstOrNull;

    return TabList(name: 'dosage', children: [
      Gutter(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(l.doseGuide, style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 4),
        Text(l.doseGuideSub, style: TextStyle(color: c.ink2, fontSize: 13.5)),
      ])),
      if (!r.curated) Gutter(top: 14, child: Callout(CalloutKind.warn, child: Text(l.notCuratedDose))),
      Gutter(top: 20, child: Cap(l.stepPotency)),
      const SizedBox(height: 8),
      ChipRow(children: [for (final p in pots) HmChip(p, selected: p == pot, onTap: () => ctl.setPotency(p))]),
      Gutter(top: 18, child: Cap(l.stepWho)),
      Gutter(
        top: 8,
        child: Row(children: [
          for (final (i, g) in d.ageGroups.indexed) ...[
            if (i > 0) const SizedBox(width: 8),
            Expanded(child: _AgeButton(label: g.label.of(bangla) ?? g.code, on: g.code == sel.ageGroup, onTap: () => ctl.setAge(g.code))),
          ],
        ]),
      ),
      if (rule != null)
        Gutter(
          top: 16,
          child: Semantics(
            liveRegion: true,
            child: HeroBox(
              padding: const EdgeInsets.fromLTRB(20, 22, 20, 22),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(l.dosePerTime, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: bangla ? 0 : 1, color: Colors.white.withValues(alpha: .96))),
                const SizedBox(height: 2),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: Text.rich(
                    key: ValueKey('${rule.potency}${rule.ageGroup}'),
                    TextSpan(children: [
                      TextSpan(text: numL(context, rule.amount), style: const TextStyle(fontSize: 40, fontWeight: FontWeight.w800, letterSpacing: -0.8)),
                      TextSpan(text: '  ${rule.isTablet ? l.tablets : l.pellets}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                    ]),
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                Text('${rule.isTablet ? l.chewOrDissolve : l.dissolveUnderTongue} · $pot', style: TextStyle(fontSize: 14, color: Colors.white.withValues(alpha: .96))),
                const SizedBox(height: 14),
                Wrap(spacing: 8, runSpacing: 8, children: [
                  if (rule.frequency.of(bangla) != null) HmBadge(rule.frequency.of(bangla)!, glass: true, icon: Icons.schedule_rounded),
                  HmBadge(d.ageGroups.where((g) => g.code == sel.ageGroup).firstOrNull?.label.of(bangla) ?? sel.ageGroup, glass: true),
                ]),
                if (rule.note.of(bangla) != null) ...[
                  const SizedBox(height: 12),
                  Text(rule.note.of(bangla)!, style: TextStyle(fontSize: 13.5, color: Colors.white.withValues(alpha: .96))),
                ],
              ]),
            ),
          ),
        ),
      if (high) Gutter(top: 12, child: Callout(CalloutKind.warn, child: Text(l.highPotencyWarn))),
      if (boerickeDose != null) ...[
        SectionHeader(l.boerickeDose, top: 28),
        Gutter(
          child: HmCard(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              SelectableText(boerickeDose.body, style: const TextStyle(fontSize: 14.5, height: 1.6)),
              const SizedBox(height: 8),
              Text(l.sourceBoericke, style: TextStyle(fontSize: 12, color: c.ink3)),
            ]),
          ),
        ),
      ],
      SectionHeader(l.howToTake, top: 28),
      for (final (i, (t, b)) in [(l.step1T, l.step1B), (l.step2T, l.step2B), (l.step3T, l.step3B), (l.step4T, l.step4B)].indexed)
        Gutter(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(width: 32, height: 32, alignment: Alignment.center, decoration: BoxDecoration(color: c.p, shape: BoxShape.circle),
                  child: Text(numL(context, i + 1), style: TextStyle(color: c.onp, fontWeight: FontWeight.w800, fontSize: 14))),
              const SizedBox(width: 14),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(t, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                Text(b, style: TextStyle(fontSize: 13.5, color: c.ink2, height: 1.45)),
              ])),
            ]),
          ),
        ),
      Gutter(top: 8, child: Text(l.doseDisclaimer, style: TextStyle(fontSize: 12, color: c.ink3, height: 1.6))),
      const SizedBox(height: 20),
      const HmAdBanner(),
    ]);
  }
}

class _AgeButton extends StatelessWidget {
  const _AgeButton({required this.label, required this.on, required this.onTap});
  final String label;
  final bool on;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.hm;
    final m = RegExp(r'^(.*?)\s*\((.*)\)$').firstMatch(label);
    return Semantics(
      button: true, selected: on, label: label,
      child: Material(
        color: on ? c.sf2 : c.sf,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18), side: BorderSide(color: on ? c.p : c.ln, width: 1.5)),
        child: InkWell(
          customBorder: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
            child: ExcludeSemantics(
              child: Column(children: [
                Text(m?.group(1) ?? label, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: on ? c.pd : c.ink)),
                if (m != null) Text(m.group(2)!, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 11.5, color: c.ink2)),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}
