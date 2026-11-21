/// ============================================================
/// SEARCH ENTITIES — hits, book hits and grouped results
/// ============================================================
library;

enum HitKind { remedy, condition, manufacturer }

/// An archive match (offline index).
class SearchHit {
  const SearchHit(this.kind, this.id, this.score, this.matched);
  final HitKind kind;

  /// Remedy / condition slug, or manufacturer id.
  final String id;
  final double score;

  /// The term that matched (Latin, Bangla, Banglish key…) — shown when it differs from the title.
  final String matched;
}

/// A match inside source-book text (online full-text search).
class BookHit {
  const BookHit({required this.remedyId, required this.book, required this.section, required this.snippet});
  final String remedyId, book, section, snippet;
}

/// Ranked hits plus per-kind counts for the category chips.
class SearchResults {
  const SearchResults({this.hits = const [], this.counts = const {}, this.didYouMean});
  final List<SearchHit> hits;
  final Map<HitKind, int> counts;
  final String? didYouMean;

  static const empty = SearchResults();
  int get total => counts.values.fold(0, (a, b) => a + b);
}
