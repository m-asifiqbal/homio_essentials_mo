/// Category chips with live counts (All · Remedies · Symptoms · In the books · Companies).
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import 'package:homio_essentials/core/l10n/i18n.dart';
import 'package:homio_essentials/core/widgets/widgets.dart';
import 'package:homio_essentials/features/search/domain/entities/search_hit.dart';
import 'package:homio_essentials/features/search/presentation/providers/search_providers.dart';

class SearchCategoryBar extends ConsumerWidget {
  const SearchCategoryBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l;
    // Only what the chips show: not every keystroke (input) rebuilds them, just the debounced query.
    final category = ref.watch(searchControllerProvider.select((s) => s.category));
    final query = ref.watch(searchControllerProvider.select((s) => s.query.trim()));
    final ctl = ref.read(searchControllerProvider.notifier);
    final results = ref.watch(searchResultsProvider);
    final books = query.isNotEmpty ? ref.watch(bookResultsProvider(query)).value : null;
    final has = query.isNotEmpty;
    int? n(HitKind k) => has ? (results.counts[k] ?? 0) : null;

    return SizedBox(
      height: 46,
      child: ChipRow(children: [
        HmChip(l.all, small: true, selected: category == SearchCategory.all, count: has ? results.total : null, onTap: () => ctl.setCategory(SearchCategory.all)),
        HmChip(l.segRemedies, small: true, selected: category == SearchCategory.remedies, count: n(HitKind.remedy), onTap: () => ctl.setCategory(SearchCategory.remedies)),
        HmChip(l.segSymptoms, small: true, selected: category == SearchCategory.symptoms, count: n(HitKind.condition), onTap: () => ctl.setCategory(SearchCategory.symptoms)),
        HmChip(l.inTheBooks, small: true, icon: Icons.menu_book_outlined, selected: category == SearchCategory.books, count: books?.length, onTap: () => ctl.setCategory(SearchCategory.books)),
        HmChip(l.segCompanies, small: true, selected: category == SearchCategory.companies, count: n(HitKind.manufacturer), onTap: () => ctl.setCategory(SearchCategory.companies)),
      ]),
    );
  }
}
