/// Dosage & administration — pick potency + age → dose per time, the whole age table
/// for that potency (MedEx lists dose per age group), how to take pellets, Boericke's note.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import 'package:homio_essentials/core/archive/domain/entities/models.dart';
import 'package:homio_essentials/core/l10n/i18n.dart';
import 'package:homio_essentials/core/theme/tokens.dart';
import 'package:homio_essentials/core/widgets/widgets.dart';
import 'package:homio_essentials/features/remedy/domain/entities/materia_entry.dart';
import 'package:homio_essentials/features/remedy/presentation/providers/remedy_providers.dart';

class DosageSection extends ConsumerWidget {
  const DosageSection({super.key, required this.d});
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
    final doseNotes = r.curated ? const <MateriaEntry>[] : (ref.watch(materiaProvider(r.id)).value ?? const <MateriaEntry>[]).where((m) => m.book == 'boericke' && m.section == 'Dose');
    // Bangla translation of Boericke's note when reading in Bangla, else his English
    final boerickeDose = (context.bn ? doseNotes.where((m) => !m.isEnglish).firstOrNull : null) ?? doseNotes.where((m) => m.isEnglish).firstOrNull;
    String ageLabel(String code) => d.ageGroups.where((g) => g.code == code).firstOrNull?.label.of(bangla) ?? code;

    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Text(l.doseGuideSub, style: TextStyle(color: c.ink2, fontSize: 12.5, height: 1.45)),
      if (!r.curated) ...[const SizedBox(height: 12), Callout(CalloutKind.warn, child: Text(l.notCuratedDose))],
      if (d.rules.isEmpty) ...[const SizedBox(height: 12), SectionEmpty(icon: Icons.medication_outlined, title: l.doseEmptyTitle, body: l.doseEmptyBody)],
      if (pots.isNotEmpty) ...[
        const SizedBox(height: 16),
        Cap(l.stepPotency),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(children: [for (final (i, p) in pots.indexed) Padding(padding: EdgeInsetsDirectional.only(start: i == 0 ? 0 : 8), child: HmChip(p, small: true, selected: p == pot, onTap: () => ctl.setPotency(p)))]),
        ),
        const SizedBox(height: 16),
        Cap(l.stepWho),
        const SizedBox(height: 8),
        Row(children: [
          for (final (i, g) in d.ageGroups.indexed) ...[
            if (i > 0) const SizedBox(width: 8),
            Expanded(child: _AgeButton(label: g.label.of(bangla) ?? g.code, on: g.code == sel.ageGroup, onTap: () => ctl.setAge(g.code))),
          ],
        ]),
      ],
      if (rule != null) ...[
        const SizedBox(height: 14),
        Semantics(
          liveRegion: true,
          child: HeroBox(
            radius: 22,
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(bangla ? l.dosePerTime : l.dosePerTime.toUpperCase(), style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, letterSpacing: bangla ? 0 : 1, color: Colors.white.withValues(alpha: .96))),
              const SizedBox(height: 2),
              AnimatedSwitcher(
                duration: context.motion(const Duration(milliseconds: 200)),
                child: Text.rich(
                  key: ValueKey('${rule.potency}${rule.ageGroup}'),
                  TextSpan(children: [
                    TextSpan(text: numL(context, rule.amount), style: TextStyle(fontSize: 34, fontWeight: FontWeight.w700, letterSpacing: bangla ? 0 : -0.6)),
                    TextSpan(text: '  ${rule.isTablet ? l.tablets : l.pellets}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  ]),
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              Text('${rule.isTablet ? l.chewOrDissolve : l.dissolveUnderTongue} · $pot', style: TextStyle(fontSize: 13, color: Colors.white.withValues(alpha: .96))),
              const SizedBox(height: 12),
              Wrap(spacing: 8, runSpacing: 8, children: [
                if (rule.frequency.of(bangla) != null) HmBadge(rule.frequency.of(bangla)!, glass: true, icon: Icons.schedule_rounded),
                HmBadge(ageLabel(sel.ageGroup), glass: true),
              ]),
              if (rule.note.of(bangla) != null) ...[
                const SizedBox(height: 10),
                Text(rule.note.of(bangla)!, style: TextStyle(fontSize: 13, color: Colors.white.withValues(alpha: .96), height: 1.45)),
              ],
            ]),
          ),
        ),
      ],
      if (high) ...[const SizedBox(height: 12), Callout(CalloutKind.warn, child: Text(l.highPotencyWarn))],
      if (pot != null && d.rules.any((x) => x.potency == pot)) ...[
        const SizedBox(height: 18),
        Cap(l.doseTable(pot)),
        const SizedBox(height: 8),
        _DoseTable(rows: [for (final g in d.ageGroups) (ageLabel(g.code), d.rules.where((x) => x.potency == pot && x.ageGroup == g.code).firstOrNull)], selected: sel.ageGroup, ageCode: [for (final g in d.ageGroups) g.code]),
      ],
      if (boerickeDose != null) ...[
        const SizedBox(height: 18),
        Cap(l.boerickeDose),
        const SizedBox(height: 8),
        SelectableText(boerickeDose.body, style: const TextStyle(fontSize: 13.5, height: 1.6)),
        const SizedBox(height: 6),
        Text(l.sourceBoericke, style: TextStyle(fontSize: 11.5, color: c.ink3)),
        if (!boerickeDose.isEnglish) Padding(padding: const EdgeInsets.only(top: 2), child: Text(l.autoTranslatedNote, style: TextStyle(fontSize: 11.5, color: c.ink3))),
      ],
      const SizedBox(height: 18),
      Cap(l.howToTake),
      const SizedBox(height: 10),
      for (final (i, (t, b)) in [(l.step1T, l.step1B), (l.step2T, l.step2B), (l.step3T, l.step3B), (l.step4T, l.step4B)].indexed)
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(
              width: 28, height: 28, alignment: Alignment.center,
              decoration: BoxDecoration(color: c.p, shape: BoxShape.circle),
              child: Text(numL(context, i + 1), style: TextStyle(color: c.onp, fontWeight: FontWeight.w700, fontSize: 12.5)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(t, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                Text(b, style: TextStyle(fontSize: 13, color: c.ink2, height: 1.45)),
              ]),
            ),
          ]),
        ),
      Text(l.doseDisclaimer, style: TextStyle(fontSize: 11.5, color: c.ink3, height: 1.55)),
    ]);
  }
}

/// One row per age group: age + dose on the first line, how often beneath it (the frequency
/// sentence is long, so it gets the full row width). The group picked above is highlighted.
class _DoseTable extends StatelessWidget {
  const _DoseTable({required this.rows, required this.selected, required this.ageCode});
  final List<(String, DoseRule?)> rows;
  final String selected;
  final List<String> ageCode;

  @override
  Widget build(BuildContext context) {
    final c = context.hm;
    final l = context.l;
    final bangla = context.bn;
    TextStyle head() => TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: c.ink3);
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: DecoratedBox(
        decoration: BoxDecoration(border: Border.all(color: c.ln), borderRadius: BorderRadius.circular(14)),
        child: Column(children: [
          Container(
            color: c.sf2,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(children: [
              Expanded(child: Text(l.colAge, style: head())),
              Text(l.colDose, style: head()),
            ]),
          ),
          for (final (i, (age, rule)) in rows.indexed) ...[
            if (i > 0) Divider(height: 1, color: c.ln),
            AnimatedContainer(
              duration: context.motion(HmMotion.fast),
              color: ageCode[i] == selected ? c.sf2.withValues(alpha: .6) : Colors.transparent,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Expanded(child: Text(age, style: TextStyle(fontSize: 13, fontWeight: ageCode[i] == selected ? FontWeight.w700 : FontWeight.w500))),
                  Text(rule == null ? '—' : '${numL(context, rule.amount)} ${rule.isTablet ? l.tablets : l.pellets}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                ]),
                if (rule?.frequency.of(bangla) != null) Padding(padding: const EdgeInsets.only(top: 2), child: Text(rule!.frequency.of(bangla)!, style: TextStyle(fontSize: 12, color: c.ink2, height: 1.4))),
              ]),
            ),
          ],
        ]),
      ),
    );
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
      button: true, selected: on, label: label, excludeSemantics: true,
      child: HmPressable(
        haptic: true,
        onTap: onTap,
        child: AnimatedContainer(
          duration: context.motion(HmMotion.fast),
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
          decoration: BoxDecoration(
            color: on ? c.sf2 : c.bg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: on ? c.p : c.ln, width: on ? 1.5 : 1),
          ),
          child: Column(children: [
            Text(m?.group(1) ?? label, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: on ? c.pd : c.ink)),
            if (m != null) Text(m.group(2)!, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 11, color: c.ink2)),
          ]),
        ),
      ),
    );
  }
}
