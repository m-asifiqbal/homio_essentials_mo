/// ============================================================
/// SEARCH REPOSITORY (impl) — index + filters + PostgREST full-text
/// ============================================================
library;

import 'package:homio_essentials/core/archive/domain/entities/archive.dart';
import 'package:homio_essentials/core/network/dio_client.dart';
import 'package:homio_essentials/features/search/domain/entities/search_query.dart';
import 'package:homio_essentials/features/search/domain/repository/search_repository.dart';
import 'package:homio_essentials/features/search/domain/services/search_index.dart';

class SearchRepositoryImpl implements SearchRepository {
  SearchRepositoryImpl({required this.archive, required this.index, required this.api});
  final Archive archive;
  final SearchIndex index;
  final PostgrestApi api;

  bool _passes(SearchHit h, SearchFilters f) {
    if (f.isEmpty) return true;
    if (h.kind != HitKind.remedy) return f.kingdoms.isEmpty && !f.reviewedOnly && !f.withBangla;
    final r = archive.remedyBySlug[h.id];
    if (r == null) return false;
    if (f.kingdoms.isNotEmpty && !f.kingdoms.contains(r.kingdom ?? 'other')) return false;
    if (f.reviewedOnly && !r.curated) return false;
    if (f.withBangla && r.bn == null) return false;
    return true;
  }

  String _title(SearchHit h) => switch (h.kind) {
        HitKind.remedy => archive.remedyBySlug[h.id]?.latin ?? '',
        HitKind.condition => archive.conditionBySlug[h.id]?.en?.name ?? '',
        HitKind.manufacturer => archive.manufacturerById[h.id]?.name ?? '',
      };

  @override
  SearchResults search(SearchQuery q) {
    if (q.text.trim().isEmpty) return SearchResults.empty;
    final all = index.search(q.text, limit: 200).where((h) => _passes(h, q.filters)).toList();
    final counts = <HitKind, int>{};
    for (final h in all) {
      counts[h.kind] = (counts[h.kind] ?? 0) + 1;
    }
    var hits = q.kind == null ? all : all.where((h) => h.kind == q.kind).toList();
    if (q.sort == SearchSort.alphabetical) hits = [...hits]..sort((a, b) => _title(a).toLowerCase().compareTo(_title(b).toLowerCase()));
    return SearchResults(hits: hits.take(80).toList(), counts: counts, didYouMean: all.isEmpty ? index.didYouMean(q.text) : null);
  }

  @override
  Future<List<BookHit>> searchBooks(String text, {int limit = 40}) async {
    final words = text.trim().split(RegExp(r'\s+')).where((w) => w.length >= 2).map((w) => w.replaceAll(RegExp(r'[^\p{L}\p{N}-]', unicode: true), '')).where((w) => w.isNotEmpty).toList();
    if (words.isEmpty) return const [];
    // websearch-style full-text over the English book text: every word must appear.
    final rows = await api.select('materia_entries',
        columns: 'remedy_id,source_book,section,body',
        filters: {'body': 'wfts(english).${words.join(' ')}', 'locale': 'eq.en'},
        limit: limit);
    return [
      for (final r in rows)
        if (archive.remedyById[r['remedy_id']] != null)
          BookHit(remedyId: r['remedy_id'], book: r['source_book'], section: r['section'], snippet: _snippet(r['body'] as String, words)),
    ];
  }

  /// ~160 characters around the first matching word.
  static String _snippet(String body, List<String> words) {
    final lower = body.toLowerCase();
    var at = -1;
    for (final w in words) {
      final stem = w.toLowerCase().length > 5 ? w.toLowerCase().substring(0, 5) : w.toLowerCase();
      at = lower.indexOf(stem);
      if (at >= 0) break;
    }
    if (at < 0) at = 0;
    final start = (at - 60).clamp(0, body.length);
    final end = (at + 110).clamp(0, body.length);
    return '${start > 0 ? '…' : ''}${body.substring(start, end).replaceAll('\n', ' ').trim()}${end < body.length ? '…' : ''}';
  }
}
