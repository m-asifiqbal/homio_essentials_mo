/// Results: grouped (All) or one category, book hits, did-you-mean, empty state.
///
/// The screen is ONE lazy `ListView.builder` over a flat list of rows (headers, hits,
/// book snippets, notices). The old version put every hit of a category (up to ~700 remedies)
/// into a non-lazy Column; building only what is on screen keeps typing and scrolling smooth.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import 'package:homio_essentials/core/archive/domain/entities/archive.dart';
import 'package:homio_essentials/core/l10n/i18n.dart';
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
    final category = ref.watch(searchControllerProvider.select((s) => s.category));
    final q = ref.watch(searchControllerProvider.select((s) => s.query.trim()));
    final ctl = ref.read(searchControllerProvider.notifier);
    final results = ref.watch(searchResultsProvider);
    final books = ref.watch(bookResultsProvider(q));
    void opened() => ctl.remember();

    Widget hit(SearchHit h) => SearchHitTile(hit: h, archive: archive, query: q, onOpen: opened);

    // ── flat row list ──
    final rows = <Widget Function(BuildContext)>[];
    void add(Widget w) => rows.add((_) => w);
    void addHeader(String title, {String? action, VoidCallback? onAction}) => add(SectionHeader(title, top: rows.isEmpty ? 4 : 18, action: action, onAction: onAction));

    List<Widget> bookTiles(Iterable<BookHit> hits) => [for (final b in hits) BookHitTile(hit: b, archive: archive, query: q, onOpen: opened)];
    final bookList = books.value;

    void addBooks({required bool all}) {
      switch (books) {
        case AsyncValue(:final value?):
          for (final w in bookTiles(all ? value : value.take(3))) {
            add(w);
          }
        case AsyncError(:final error):
          add(Gutter(child: Padding(padding: const EdgeInsets.only(bottom: 10), child: HmErrorState(error: error, compact: true, onRetry: () => ref.invalidate(bookResultsProvider(q))))));
        default:
          for (var i = 0; i < 2; i++) {
            add(const Gutter(child: Padding(padding: EdgeInsets.only(bottom: 10), child: HmSkeleton(height: 88, radius: 20))));
          }
      }
    }

    if (category == SearchCategory.books) {
      add(Gutter(child: Padding(padding: const EdgeInsets.only(bottom: 10), child: Text(l.booksExplain, style: TextStyle(fontSize: 12.5, color: c.ink2, height: 1.45)))));
      addBooks(all: true);
      if (bookList != null && bookList.isEmpty) add(EmptyState(icon: Icons.menu_book_outlined, title: l.noBookMatches(q)));
    } else if (results.hits.isEmpty) {
      add(EmptyState(
        icon: Icons.search_off_rounded,
        title: l.noResultsTitle(q),
        body: l.noResultsBody,
        action: l.requestThis,
        onAction: () => context.push(AppRoutes.requestFor(name: q)),
        secondary: results.didYouMean == null
            ? null
            : Padding(
                padding: const EdgeInsets.only(top: 12),
                child: TextButton.icon(onPressed: () => ctl.searchNow(results.didYouMean!), icon: const Icon(Icons.spellcheck_rounded), label: Text(l.didYouMean(results.didYouMean!))),
              ),
      ));
      if ((bookList?.length ?? 0) > 0) {
        addHeader(l.inTheBooks);
        addBooks(all: false);
      }
    } else if (category == SearchCategory.all) {
      void group(HitKind k, String title, SearchCategory cat) {
        final all = results.hits.where((h) => h.kind == k).toList();
        if (all.isEmpty) return;
        addHeader(title, action: all.length > 5 ? l.seeAllN(numL(context, results.counts[k] ?? all.length)) : null, onAction: () => ctl.setCategory(cat));
        for (final h in all.take(5)) {
          add(hit(h));
        }
      }

      group(HitKind.remedy, l.segRemedies, SearchCategory.remedies);
      group(HitKind.condition, l.segSymptoms, SearchCategory.symptoms);
      if (bookList == null || bookList.isNotEmpty) {
        addHeader(l.inTheBooks, action: (bookList?.length ?? 0) > 3 ? l.seeAllN(numL(context, bookList!.length)) : null, onAction: () => ctl.setCategory(SearchCategory.books));
        addBooks(all: false);
      }
      group(HitKind.manufacturer, l.segCompanies, SearchCategory.companies);
    } else {
      for (final h in results.hits) {
        add(hit(h));
      }
    }

    return HmScrollTopHost(
      itemExtent: 66,
      builder: (context, scroll) => ListView.builder(
        controller: scroll,
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: EdgeInsets.only(top: 2, bottom: MediaQuery.viewPaddingOf(context).bottom + 32),
        itemCount: rows.length,
        itemBuilder: (context, i) => rows[i](context),
      ),
    );
  }
}
