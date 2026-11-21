/// Before typing: recent searches, things to try, recently viewed, popular, symptoms.
library;

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import 'package:homio_essentials/core/archive/domain/entities/archive.dart';
import 'package:homio_essentials/core/archive/domain/entities/models.dart';
import 'package:homio_essentials/core/l10n/i18n.dart';
import 'package:homio_essentials/core/router/app_routes.dart';
import 'package:homio_essentials/core/theme/tokens.dart';
import 'package:homio_essentials/core/widgets/widgets.dart';
import 'package:homio_essentials/features/search/presentation/providers/search_providers.dart';
import 'package:homio_essentials/shared/providers/library_provider.dart';
import 'package:homio_essentials/shared/widgets/remedy_row.dart';

/// Tap-to-run examples: Banglish / Bangla for names, plain phrases for the books.
const _nameExamples = ['arnika', 'nuks vomika', 'আর্নিকা', 'belladona'];
const _bookExamples = ['worse at night', 'fear of death', 'burning pain'];

class SearchIdleView extends ConsumerWidget {
  const SearchIdleView({super.key, required this.archive});
  final Archive archive;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l;
    final c = context.hm;
    final bangla = context.bn;
    final recent = ref.watch(recentSearchesProvider);
    final viewed = ref.watch(historyProvider).map((s) => archive.remedyBySlug[s]).whereType<Remedy>().take(3).toList();
    final ctl = ref.read(searchControllerProvider.notifier);
    void run(String q) { ctl.searchNow(q); ctl.remember(q); }

    return ListView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: EdgeInsets.only(top: 4, bottom: MediaQuery.viewPaddingOf(context).bottom + 32),
      children: [
        if (recent.isNotEmpty) ...[
          SectionHeader(l.recentSearches, top: 4, action: l.clearAll, onAction: () {
            final before = recent;
            ref.read(recentSearchesProvider.notifier).clear();
            showHmSnack(context, l.historyCleared, action: l.undo, onAction: () => ref.read(recentSearchesProvider.notifier).restore(before));
          }),
          for (final r in recent.take(5))
            _RecentRow(
              term: r,
              onRun: () => run(r),
              onFill: () { HapticFeedback.selectionClick(); ctl.setInput(r); },
              onRemove: () => ref.read(recentSearchesProvider.notifier).remove(r),
            ),
        ],
        SectionHeader(l.trySearching, top: recent.isEmpty ? 4 : 22),
        _Examples(icon: Icons.translate_rounded, label: l.banglishTipTitle, examples: _nameExamples, onRun: run),
        const SizedBox(height: 10),
        _Examples(icon: Icons.menu_book_outlined, label: l.booksTipTitle, note: l.booksNeedNet, examples: _bookExamples, onRun: run),
        if (viewed.isNotEmpty) ...[
          SectionHeader(l.recentlyViewed, top: 24),
          for (final r in viewed)
            Gutter(child: Padding(padding: const EdgeInsets.only(bottom: 8), child: RemedyRow(r, dense: true, onTap: () => context.push(AppRoutes.remedy(r.slug))))),
        ],
        SectionHeader(l.popularRemedies, top: 22),
        Gutter(
          child: Wrap(spacing: 8, runSpacing: 8, children: [
            for (final r in archive.popular.take(12))
              HmChip(bangla && r.bnName() != null ? r.bnName()! : r.latin, small: true, dot: c.kingdom(r.kingdom).$2, onTap: () => context.push(AppRoutes.remedy(r.slug))),
          ]),
        ),
        SectionHeader(l.findBySymptom, top: 22),
        Gutter(
          child: Wrap(spacing: 8, runSpacing: 8, children: [
            for (final cd in archive.conditions.take(14))
              HmChip(cd.name(bangla), small: true, icon: Icons.monitor_heart_outlined, onTap: () => context.push(AppRoutes.condition(cd.slug))),
          ]),
        ),
      ],
    );
  }
}

/// A recent search: tap runs it, the ↖ arrow only fills the field (to edit it), swipe removes.
class _RecentRow extends StatelessWidget {
  const _RecentRow({required this.term, required this.onRun, required this.onFill, required this.onRemove});
  final String term;
  final VoidCallback onRun, onFill, onRemove;

  @override
  Widget build(BuildContext context) {
    final c = context.hm;
    final l = context.l;
    return Dismissible(
      key: ValueKey('recent-$term'),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onRemove(),
      background: Container(alignment: AlignmentDirectional.centerEnd, padding: const EdgeInsetsDirectional.only(end: Hm.gutter), color: c.dg, child: Icon(Icons.delete_outline_rounded, color: c.dgInk)),
      child: InkWell(
        onTap: onRun,
        child: Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(Hm.gutter, 2, 6, 2),
          child: Row(children: [
            Icon(Icons.history_rounded, size: 20, color: c.ink3),
            const SizedBox(width: 14),
            Expanded(child: Padding(padding: const EdgeInsets.symmetric(vertical: 12), child: Text(term, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w500)))),
            IconButton(onPressed: onFill, tooltip: l.useThisSearch, icon: Icon(Icons.north_west_rounded, size: 18, color: c.ink3)),
          ]),
        ),
      ),
    );
  }
}

/// A labelled card of tappable example searches.
class _Examples extends StatelessWidget {
  const _Examples({required this.icon, required this.label, required this.examples, required this.onRun, this.note});
  final IconData icon;
  final String label;
  final String? note;
  final List<String> examples;
  final ValueChanged<String> onRun;

  @override
  Widget build(BuildContext context) {
    final c = context.hm;
    return Gutter(
      child: HmCard(
        radius: 18,
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Icon(icon, size: 17, color: c.p),
            const SizedBox(width: 8),
            Expanded(child: Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700))),
          ]),
          const SizedBox(height: 10),
          Wrap(spacing: 8, runSpacing: 8, children: [for (final e in examples) HmChip('“$e”', small: true, onTap: () => onRun(e))]),
          if (note != null) Padding(padding: const EdgeInsets.only(top: 8), child: Text(note!, style: TextStyle(fontSize: 11.5, color: c.ink3))),
        ]),
      ),
    );
  }
}
