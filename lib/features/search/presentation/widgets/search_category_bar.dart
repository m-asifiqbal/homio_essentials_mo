/// Category chips with live counts, plus filter and sort buttons.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import 'package:homio_essentials/core/l10n/i18n.dart';
import 'package:homio_essentials/core/theme/tokens.dart';
import 'package:homio_essentials/core/widgets/widgets.dart';
import 'package:homio_essentials/features/search/domain/entities/search_hit.dart';
import 'package:homio_essentials/features/search/domain/entities/search_query.dart';
import 'package:homio_essentials/features/search/presentation/providers/search_providers.dart';
import 'package:homio_essentials/features/search/presentation/widgets/search_filter_sheet.dart';

class SearchCategoryBar extends ConsumerWidget {
  const SearchCategoryBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l;
    final c = context.hm;
    final s = ref.watch(searchControllerProvider);
    final ctl = ref.read(searchControllerProvider.notifier);
    final results = ref.watch(searchResultsProvider);
    final books = s.hasQuery ? ref.watch(bookResultsProvider(s.query.trim())).value : null;
    int? n(HitKind k) => s.hasQuery ? (results.counts[k] ?? 0) : null;

    return SizedBox(
      height: 48,
      child: Row(children: [
        Expanded(
          child: ChipRow(children: [
            HmChip(l.all, small: true, selected: s.category == SearchCategory.all, count: s.hasQuery ? results.total : null, onTap: () => ctl.setCategory(SearchCategory.all)),
            HmChip(l.segRemedies, small: true, selected: s.category == SearchCategory.remedies, count: n(HitKind.remedy), onTap: () => ctl.setCategory(SearchCategory.remedies)),
            HmChip(l.segSymptoms, small: true, selected: s.category == SearchCategory.symptoms, count: n(HitKind.condition), onTap: () => ctl.setCategory(SearchCategory.symptoms)),
            HmChip(l.inTheBooks, small: true, icon: Icons.menu_book_outlined, selected: s.category == SearchCategory.books, count: books?.length, onTap: () => ctl.setCategory(SearchCategory.books)),
            HmChip(l.segCompanies, small: true, selected: s.category == SearchCategory.companies, count: n(HitKind.manufacturer), onTap: () => ctl.setCategory(SearchCategory.companies)),
          ]),
        ),
        Container(width: 1, height: 28, color: c.ln),
        Badge(
          isLabelVisible: !s.filters.isEmpty,
          label: Text(numL(context, s.filters.activeCount)),
          backgroundColor: c.p, textColor: c.onp,
          offset: const Offset(-4, 4),
          child: IconButton(
            tooltip: l.filters,
            icon: Icon(Icons.tune_rounded, color: s.filters.isEmpty ? c.ink2 : c.p),
            onPressed: () => showSearchFilterSheet(context, ref),
          ),
        ),
        IconButton(
          tooltip: s.sort == SearchSort.relevance ? l.sortRelevance : l.sortAZ,
          icon: Icon(s.sort == SearchSort.relevance ? Icons.auto_awesome_outlined : Icons.sort_by_alpha_rounded, color: s.sort == SearchSort.relevance ? c.ink2 : c.p),
          onPressed: () {
            final next = s.sort == SearchSort.relevance ? SearchSort.alphabetical : SearchSort.relevance;
            ctl.setSort(next);
            showHmSnack(context, next == SearchSort.relevance ? l.sortRelevance : l.sortAZ);
          },
        ),
        const SizedBox(width: 8),
      ]),
    );
  }
}
