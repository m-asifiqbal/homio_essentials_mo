/// Before typing: recent searches, recently viewed, popular, symptoms, tips.
library;

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
      padding: const EdgeInsets.only(top: 12, bottom: 32),
      children: [
        if (recent.isNotEmpty) ...[
          SectionHeader(l.recentSearches, top: 4, action: l.clearAll, onAction: () {
            final before = recent;
            ref.read(recentSearchesProvider.notifier).clear();
            showHmSnack(context, l.historyCleared, action: l.undo, onAction: () => ref.read(recentSearchesProvider.notifier).restore(before));
          }),
          ChipRow(children: [
            for (final r in recent)
              HmChip(r, small: true, icon: Icons.history_rounded, onTap: () => run(r), onDelete: () => ref.read(recentSearchesProvider.notifier).remove(r)),
          ]),
        ],
        if (viewed.isNotEmpty) ...[
          SectionHeader(l.recentlyViewed, top: recent.isEmpty ? 4 : 24),
          for (final r in viewed)
            Gutter(child: Padding(padding: const EdgeInsets.only(bottom: 8), child: RemedyRow(r, dense: true, onTap: () => context.push(AppRoutes.remedy(r.slug))))),
        ],
        SectionHeader(l.popularRemedies, top: 24),
        Gutter(
          child: Wrap(spacing: 8, runSpacing: 8, children: [
            for (final r in archive.popular.take(12))
              HmChip(bangla && r.bnName() != null ? r.bnName()! : r.latin, small: true, dot: c.kingdom(r.kingdom).$2,
                  onTap: () => context.push(AppRoutes.remedy(r.slug))),
          ]),
        ),
        SectionHeader(l.findBySymptom, top: 24),
        Gutter(
          child: Wrap(spacing: 8, runSpacing: 8, children: [
            for (final cd in archive.conditions.take(14))
              HmChip(cd.name(bangla), small: true, icon: Icons.monitor_heart_outlined, onTap: () => context.push(AppRoutes.condition(cd.slug))),
          ]),
        ),
        Gutter(
          top: 24,
          child: Callout(CalloutKind.note, icon: Icons.translate_rounded,
              child: Text.rich(TextSpan(children: [TextSpan(text: '${l.banglishTipTitle} ', style: const TextStyle(fontWeight: FontWeight.w700)), TextSpan(text: l.banglishTipBody)]))),
        ),
        Gutter(
          top: 10,
          child: Callout(CalloutKind.note, icon: Icons.menu_book_outlined,
              child: Text.rich(TextSpan(children: [TextSpan(text: '${l.booksTipTitle} ', style: const TextStyle(fontWeight: FontWeight.w700)), TextSpan(text: l.booksTipBody)]))),
        ),
      ],
    );
  }
}
