/// Results: grouped (All) or one category, book hits, did-you-mean, empty state.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import 'package:homio_essentials/core/archive/domain/entities/archive.dart';
import 'package:homio_essentials/core/l10n/i18n.dart';
import 'package:homio_essentials/core/network/api_exception.dart';
import 'package:homio_essentials/core/router/app_routes.dart';
import 'package:homio_essentials/core/theme/tokens.dart';
import 'package:homio_essentials/core/widgets/widgets.dart';
import 'package:homio_essentials/features/search/domain/entities/search_hit.dart';
import 'package:homio_essentials/features/search/presentation/providers/search_providers.dart';
import 'package:homio_essentials/features/search/presentation/widgets/search_result_tiles.dart';

class SearchResultsView extends ConsumerWidget {
  const SearchResultsView({super.key, required this.archive});
  final Archive archive;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l;
    final c = context.hm;
    final s = ref.watch(searchControllerProvider);
    final ctl = ref.read(searchControllerProvider.notifier);
    final results = ref.watch(searchResultsProvider);
    final q = s.query.trim();
    final books = ref.watch(bookResultsProvider(q));
    void opened() => ctl.remember();

    Widget hitList(Iterable<SearchHit> hits) => Column(children: [for (final h in hits) SearchHitTile(hit: h, archive: archive, query: q, onOpen: opened)]);

    final bookSection = switch (books) {
      AsyncValue(:final value?) => [for (final b in s.category == SearchCategory.books ? value : value.take(3)) BookHitTile(hit: b, archive: archive, query: q, onOpen: opened)],
      AsyncError(:final error) => [
          Gutter(child: Callout(CalloutKind.warn, icon: Icons.cloud_off_rounded, child: Text(ApiException.from(error).isOffline ? l.booksOffline : l.booksFailed))),
        ],
      _ => [for (var i = 0; i < 2; i++) const Gutter(child: Padding(padding: EdgeInsets.only(bottom: 10), child: HmSkeleton(height: 92, radius: 20)))],
    };
    final bookCount = books.value?.length;

    final children = <Widget>[];
    if (s.category == SearchCategory.books) {
      children
        ..add(Gutter(child: Padding(padding: const EdgeInsets.only(bottom: 10), child: Text(l.booksExplain, style: TextStyle(fontSize: 13, color: c.ink2)))))
        ..addAll(bookSection);
      if (bookCount == 0) children.add(EmptyState(icon: Icons.menu_book_outlined, title: l.noBookMatches(q)));
    } else if (results.hits.isEmpty) {
      children.add(EmptyState(
        icon: Icons.search_off_rounded,
        title: l.noResultsTitle(q),
        body: l.noResultsBody,
        action: l.requestThis,
        onAction: () => context.push(AppRoutes.requestFor(name: q)),
        secondary: results.didYouMean == null
            ? null
            : Padding(
                padding: const EdgeInsets.only(top: 12),
                child: TextButton.icon(
                  onPressed: () => ctl.searchNow(results.didYouMean!),
                  icon: const Icon(Icons.spellcheck_rounded),
                  label: Text(l.didYouMean(results.didYouMean!)),
                ),
              ),
      ));
      if ((bookCount ?? 0) > 0) children..add(SectionHeader(l.inTheBooks, top: 8))..addAll(bookSection);
    } else if (s.category == SearchCategory.all) {
      Iterable<SearchHit> of(HitKind k) => results.hits.where((h) => h.kind == k);
      void group(HitKind k, String title, SearchCategory cat) {
        final all = of(k).toList();
        if (all.isEmpty) return;
        children.add(SectionHeader(title, top: children.isEmpty ? 4 : 20,
            action: all.length > 5 ? l.seeAllN(numL(context, results.counts[k] ?? all.length)) : null, onAction: () => ctl.setCategory(cat)));
        children.add(hitList(all.take(5)));
      }
      group(HitKind.remedy, l.segRemedies, SearchCategory.remedies);
      group(HitKind.condition, l.segSymptoms, SearchCategory.symptoms);
      if (bookCount != 0) {
        children.add(SectionHeader(l.inTheBooks, top: 20,
            action: (bookCount ?? 0) > 3 ? l.seeAllN(numL(context, bookCount!)) : null, onAction: () => ctl.setCategory(SearchCategory.books)));
        children.addAll(bookSection);
      }
      group(HitKind.manufacturer, l.segCompanies, SearchCategory.companies);
    } else {
      children.add(hitList(results.hits));
    }

    return ListView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: const EdgeInsets.only(top: 6, bottom: 32),
      children: [
        if (results.total > 0 && s.category != SearchCategory.books)
          Gutter(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(l.resultsFor(numL(context, results.total), q), style: TextStyle(fontSize: 12.5, color: c.ink3, fontWeight: FontWeight.w600)),
            ),
          ),
        ...children,
      ],
    );
  }
}
