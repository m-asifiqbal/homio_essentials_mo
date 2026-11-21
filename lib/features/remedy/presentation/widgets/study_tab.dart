/// ============================================================
/// STUDY TAB — Boericke / Allen text by section (Student & Practitioner)
/// ============================================================
///
/// General mode sees a faded teaser and a one-tap switch to Student.
/// ============================================================
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import 'package:homio_essentials/core/ads/hm_ad_banner.dart';
import 'package:homio_essentials/core/l10n/i18n.dart';
import 'package:homio_essentials/core/router/app_routes.dart';
import 'package:homio_essentials/core/theme/tokens.dart';
import 'package:homio_essentials/core/utils/launcher.dart';
import 'package:homio_essentials/core/widgets/widgets.dart';
import 'package:homio_essentials/features/remedy/domain/entities/materia_entry.dart';
import 'package:homio_essentials/features/remedy/presentation/providers/remedy_providers.dart';
import 'package:homio_essentials/features/remedy/presentation/widgets/remedy_hero.dart';
import 'package:homio_essentials/shared/providers/settings_provider.dart';

class StudyTab extends ConsumerStatefulWidget {
  const StudyTab({super.key, required this.d});
  final RemedyDetail d;

  @override
  ConsumerState<StudyTab> createState() => _StudyTabState();
}

class _StudyTabState extends ConsumerState<StudyTab> {
  String? _book;

  @override
  Widget build(BuildContext context) {
    final c = context.hm;
    final l = context.l;
    final role = ref.watch(settingsProvider.select((s) => s.role));
    final r = widget.d.remedy;
    return switch (ref.watch(materiaProvider(r.id))) {
      AsyncValue(:final value?) => () {
          if (value.isEmpty) return TabList(name: 'study', children: [EmptyState(icon: Icons.menu_book_outlined, title: l.studyEmpty)]);
          final books = value.map((e) => e.book).toSet().toList()..sort((x, y) => x == 'boericke' ? -1 : y == 'boericke' ? 1 : x.compareTo(y));
          final book = _book != null && books.contains(_book) ? _book! : books.first;
          final entries = value.where((e) => e.book == book).toList();
          if (role == Role.general) return _locked(context, entries);
          final worse = entries.where((e) => e.section == 'Worse').firstOrNull;
          final better = entries.where((e) => e.section == 'Better').firstOrNull;
          final allenKey = book == 'allen' ? entries.where((e) => e.section == 'Keynotes').firstOrNull : null;
          final rest = entries.where((e) => !(book == 'allen' && (e.section == 'Worse' || e.section == 'Better' || e.section == 'Keynotes'))).toList();
          return TabList(name: 'study', children: [
            Gutter(child: Row(children: [
              Expanded(child: Text(l.materiaMedica, style: Theme.of(context).textTheme.headlineSmall)),
              HmBadge(role == Role.practitioner ? l.rolePractitioner : l.roleStudent, bg: c.miBg, ink: c.miInk, icon: Icons.school_outlined),
            ])),
            if (books.length > 1) ...[
              Gutter(top: 14, child: Cap(l.sourceBook)),
              const SizedBox(height: 8),
              ChipRow(children: [for (final b in books) HmChip(l.book(b), small: true, selected: b == book, onTap: () => setState(() => _book = b))]),
            ],
            if (book == 'boericke' && r.keynotes.isNotEmpty) Gutter(top: 18, child: _KeynotesCard(notes: r.keynotes)),
            if (allenKey != null) Gutter(top: 18, child: HmCard(child: SelectableText(allenKey.body, style: const TextStyle(fontSize: 15, height: 1.65)))),
            if (worse != null || better != null)
              Gutter(
                top: 12,
                child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  if (worse != null) Expanded(child: _Modality(title: '‹ ${worse.section}', body: worse.body, bg: c.dg, ink: c.dgInk)),
                  if (worse != null && better != null) const SizedBox(width: 10),
                  if (better != null) Expanded(child: _Modality(title: '› ${better.section}', body: better.body, bg: c.ptBg, ink: c.ptInk)),
                ]),
              ),
            const SizedBox(height: 16),
            for (final (i, e) in rest.indexed)
              Gutter(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  // own storage key: ExpansionTile keeps its open state in PageStorage
                  child: _Section(key: PageStorageKey('${e.book}:${e.sort}:${e.section}'), e: e, initiallyOpen: i < 2, d: widget.d),
                ),
              ),
            Gutter(top: 12, child: Text(l.studyFooter, style: TextStyle(fontSize: 12, color: c.ink3, height: 1.6))),
            if (entries.first.sourceUrl != null)
              Gutter(child: TextButton.icon(onPressed: () => openTarget('website', entries.first.sourceUrl!), icon: const Icon(Icons.open_in_new_rounded, size: 16), label: Text(l.viewSource))),
            const SizedBox(height: 12),
            const HmAdBanner(),
          ]);
        }(),
      AsyncError() => TabList(name: 'study', children: [
          Gutter(child: Callout(CalloutKind.warn, icon: Icons.cloud_off_rounded, child: Text(l.materiaOffline))),
          Gutter(top: 12, child: OutlinedButton(onPressed: () => ref.invalidate(materiaProvider(r.id)), child: Text(l.retry))),
        ]),
      _ => TabList(name: 'study', children: [
          for (var i = 0; i < 5; i++) const Gutter(child: Padding(padding: EdgeInsets.only(bottom: 10), child: HmSkeleton(height: 56, radius: 18))),
        ]),
    };
  }

  Widget _locked(BuildContext context, List<MateriaEntry> entries) {
    final c = context.hm;
    final l = context.l;
    final teaser = entries.where((e) => e.section == 'Overview').firstOrNull?.body ?? entries.first.body;
    return TabList(name: 'study', children: [
      Gutter(child: Text(l.materiaMedica, style: Theme.of(context).textTheme.headlineSmall)),
      Gutter(
        top: 14,
        child: ShaderMask(
          shaderCallback: (rect) => LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.black, Colors.black.withValues(alpha: 0)]).createShader(rect),
          blendMode: BlendMode.dstIn,
          child: Text(teaser.length > 420 ? '${teaser.substring(0, 420)}…' : teaser, style: const TextStyle(fontSize: 15, height: 1.65)),
        ),
      ),
      Gutter(
        top: 8,
        child: HmCard(
          color: c.miBg, border: c.miBg,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [Icon(Icons.lock_outline_rounded, color: c.miInk), const SizedBox(width: 10), Expanded(child: Text(l.studyLockedTitle, style: TextStyle(fontWeight: FontWeight.w700, color: c.miInk)))]),
            const SizedBox(height: 8),
            Text(l.studyLockedBody, style: TextStyle(color: c.miInk, height: 1.5)),
            const SizedBox(height: 14),
            FilledButton(onPressed: () => ref.read(settingsProvider.notifier).setRole(Role.student), child: Text(l.switchToStudent)),
          ]),
        ),
      ),
    ]);
  }
}

class _KeynotesCard extends StatelessWidget {
  const _KeynotesCard({required this.notes});
  final List<String> notes;

  @override
  Widget build(BuildContext context) {
    final c = context.hm;
    return HmCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Cap(context.l.keynotes),
        const SizedBox(height: 10),
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

class _Modality extends StatelessWidget {
  const _Modality({required this.title, required this.body, required this.bg, required this.ink});
  final String title, body;
  final Color bg, ink;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(14)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: ink)),
          const SizedBox(height: 4),
          Text(body, style: TextStyle(fontSize: 13.5, color: ink, height: 1.5)),
        ]),
      );
}

class _Section extends StatelessWidget {
  const _Section({super.key, required this.e, required this.initiallyOpen, required this.d});
  final MateriaEntry e;
  final bool initiallyOpen;
  final RemedyDetail d;

  @override
  Widget build(BuildContext context) {
    final c = context.hm;
    final l = context.l;
    final isRel = e.section == 'Relationship' || e.section == 'Relations';
    return Container(
      decoration: BoxDecoration(color: c.sf, borderRadius: BorderRadius.circular(18), border: Border.all(color: c.ln)),
      clipBehavior: Clip.antiAlias,
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: initiallyOpen,
          tilePadding: const EdgeInsets.symmetric(horizontal: 16),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          expandedCrossAxisAlignment: CrossAxisAlignment.start,
          iconColor: c.p, collapsedIconColor: c.ink3,
          title: Text(e.section, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15.5)),
          children: [
            SelectableText(e.body, style: TextStyle(fontSize: 14.5, height: 1.62, color: c.ink)),
            if (isRel && d.related.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(spacing: 8, runSpacing: 8, children: [
                for (final (:remedy, :type) in d.related)
                  ActionChip(
                    avatar: Icon(kingdomIcon(remedy.kingdom), size: 16, color: c.pd),
                    label: Text('${l.relation(type)}: ${remedy.latin}', style: const TextStyle(fontSize: 13)),
                    backgroundColor: c.sf2, side: BorderSide.none, shape: const StadiumBorder(),
                    onPressed: () => context.push(AppRoutes.remedy(remedy.slug)),
                  ),
              ]),
            ],
          ],
        ),
      ),
    );
  }
}
