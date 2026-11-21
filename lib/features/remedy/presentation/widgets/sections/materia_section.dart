/// Materia Medica — Boericke / Allen text by section (Student & Practitioner levels).
///
/// General level sees a faded teaser and a one-tap switch to Student. Modalities
/// (worse ‹ / better ›) are lifted out of the text into two coloured boxes.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import 'package:homio_essentials/core/l10n/i18n.dart';
import 'package:homio_essentials/core/router/app_routes.dart';
import 'package:homio_essentials/core/theme/tokens.dart';
import 'package:homio_essentials/core/utils/launcher.dart';
import 'package:homio_essentials/core/widgets/widgets.dart';
import 'package:homio_essentials/features/remedy/domain/entities/materia_entry.dart';
import 'package:homio_essentials/features/remedy/presentation/providers/remedy_providers.dart';
import 'package:homio_essentials/shared/providers/settings_provider.dart';

class MateriaSection extends ConsumerStatefulWidget {
  const MateriaSection({super.key, required this.d});
  final RemedyDetail d;

  @override
  ConsumerState<MateriaSection> createState() => _MateriaSectionState();
}

class _MateriaSectionState extends ConsumerState<MateriaSection> {
  String? _book;

  @override
  Widget build(BuildContext context) {
    final c = context.hm;
    final l = context.l;
    final role = ref.watch(settingsProvider.select((s) => s.role));
    final r = widget.d.remedy;
    return switch (ref.watch(materiaProvider(r.id))) {
      AsyncValue(:final value?) => () {
          if (value.isEmpty) return Padding(padding: const EdgeInsets.symmetric(vertical: 8), child: Text(l.studyEmpty, style: TextStyle(color: c.ink2)));
          final books = value.map((e) => e.book).toSet().toList()..sort((x, y) => x == 'boericke' ? -1 : y == 'boericke' ? 1 : x.compareTo(y));
          final book = _book != null && books.contains(_book) ? _book! : books.first;
          final entries = value.where((e) => e.book == book).toList();
          if (role == Role.general) return _locked(context, entries);
          final worse = entries.where((e) => e.section == 'Worse').firstOrNull;
          final better = entries.where((e) => e.section == 'Better').firstOrNull;
          final allenKey = book == 'allen' ? entries.where((e) => e.section == 'Keynotes').firstOrNull : null;
          final rest = entries.where((e) => !(book == 'allen' && (e.section == 'Worse' || e.section == 'Better' || e.section == 'Keynotes'))).toList();
          return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Row(children: [
              Expanded(child: Text(l.materiaMedica, style: TextStyle(fontSize: 12.5, color: c.ink2, fontWeight: FontWeight.w600))),
              HmBadge(role == Role.practitioner ? l.rolePractitioner : l.roleStudent, bg: c.miBg, ink: c.miInk, icon: Icons.school_outlined),
            ]),
            if (books.length > 1) ...[
              const SizedBox(height: 12),
              Cap(l.sourceBook),
              const SizedBox(height: 8),
              Wrap(spacing: 8, runSpacing: 8, children: [for (final b in books) HmChip(l.book(b), small: true, selected: b == book, onTap: () => setState(() => _book = b))]),
            ],
            if (allenKey != null) ...[const SizedBox(height: 14), SelectableText(allenKey.body, style: const TextStyle(fontSize: 14, height: 1.65))],
            if (worse != null || better != null) ...[
              const SizedBox(height: 12),
              Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                if (worse != null) Expanded(child: _Modality(title: '‹ ${worse.section}', body: worse.body, bg: c.dg, ink: c.dgInk)),
                if (worse != null && better != null) const SizedBox(width: 10),
                if (better != null) Expanded(child: _Modality(title: '› ${better.section}', body: better.body, bg: c.ptBg, ink: c.ptInk)),
              ]),
            ],
            const SizedBox(height: 14),
            for (final (i, e) in rest.indexed)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                // own storage key: ExpansionTile keeps its open state in PageStorage
                child: _BookSection(key: PageStorageKey('${e.book}:${e.sort}:${e.section}'), e: e, initiallyOpen: i < 1, d: widget.d),
              ),
            const SizedBox(height: 4),
            Text(l.studyFooter, style: TextStyle(fontSize: 11.5, color: c.ink3, height: 1.55)),
            if (entries.first.sourceUrl != null)
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: TextButton.icon(onPressed: () => openTarget('website', entries.first.sourceUrl!), icon: const Icon(Icons.open_in_new_rounded, size: 16), label: Text(l.viewSource)),
              ),
          ]);
        }(),
      AsyncError() => Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Callout(CalloutKind.warn, icon: Icons.cloud_off_rounded, child: Text(l.materiaOffline)),
          const SizedBox(height: 12),
          OutlinedButton(onPressed: () => ref.invalidate(materiaProvider(r.id)), child: Text(l.retry)),
        ]),
      _ => Column(children: [for (var i = 0; i < 4; i++) const Padding(padding: EdgeInsets.only(bottom: 10), child: HmSkeleton(height: 48, radius: 16))]),
    };
  }

  Widget _locked(BuildContext context, List<MateriaEntry> entries) {
    final c = context.hm;
    final l = context.l;
    final teaser = entries.where((e) => e.section == 'Overview').firstOrNull?.body ?? entries.first.body;
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      ShaderMask(
        shaderCallback: (rect) => LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.black, Colors.black.withValues(alpha: 0)]).createShader(rect),
        blendMode: BlendMode.dstIn,
        child: Text(teaser.length > 360 ? '${teaser.substring(0, 360)}…' : teaser, style: const TextStyle(fontSize: 14, height: 1.65)),
      ),
      const SizedBox(height: 8),
      HmCard(
        elevated: false,
        color: c.miBg, border: c.miBg, radius: 18,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [Icon(Icons.lock_outline_rounded, color: c.miInk, size: 20), const SizedBox(width: 10), Expanded(child: Text(l.studyLockedTitle, style: TextStyle(fontWeight: FontWeight.w700, color: c.miInk)))]),
          const SizedBox(height: 8),
          Text(l.studyLockedBody, style: TextStyle(color: c.miInk, height: 1.5, fontSize: 13)),
          const SizedBox(height: 14),
          FilledButton(onPressed: () => ref.read(settingsProvider.notifier).setRole(Role.student), child: Text(l.switchToStudent)),
        ]),
      ),
    ]);
  }
}

class _Modality extends StatelessWidget {
  const _Modality({required this.title, required this.body, required this.bg, required this.ink});
  final String title, body;
  final Color bg, ink;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(14)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12.5, color: ink)),
          const SizedBox(height: 4),
          Text(body, style: TextStyle(fontSize: 13, color: ink, height: 1.5)),
        ]),
      );
}

class _BookSection extends StatelessWidget {
  const _BookSection({super.key, required this.e, required this.initiallyOpen, required this.d});
  final MateriaEntry e;
  final bool initiallyOpen;
  final RemedyDetail d;

  @override
  Widget build(BuildContext context) {
    final c = context.hm;
    final l = context.l;
    final isRel = e.section == 'Relationship' || e.section == 'Relations';
    return Container(
      decoration: BoxDecoration(color: c.bg, borderRadius: BorderRadius.circular(16), border: Border.all(color: c.ln)),
      clipBehavior: Clip.antiAlias,
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: initiallyOpen,
          tilePadding: const EdgeInsets.symmetric(horizontal: 14),
          childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
          expandedCrossAxisAlignment: CrossAxisAlignment.start,
          iconColor: c.p, collapsedIconColor: c.ink3,
          title: Text(e.section, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
          children: [
            SelectableText(e.body, style: TextStyle(fontSize: 13.5, height: 1.62, color: c.ink)),
            if (isRel && d.related.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(spacing: 8, runSpacing: 8, children: [
                for (final (:remedy, :type) in d.related.take(12))
                  HmChip('${l.relation(type)}: ${remedy.latin}', small: true, icon: kingdomIcon(remedy.kingdom), onTap: () => context.push(AppRoutes.remedy(remedy.slug))),
              ]),
            ],
          ],
        ),
      ),
    );
  }
}
