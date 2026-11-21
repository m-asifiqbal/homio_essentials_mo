/// ============================================================
/// SEARCH REPOSITORY (contract) — archive search + book full-text search
/// ============================================================
///
/// [search] is offline and instant (in-memory index over the cached
/// archive, filters and sort applied). [searchBooks] is online: full-text
/// search inside Boericke / Allen (`materia_entries`), for symptom phrases
/// like "worse at night" or "fear of death".
/// ============================================================
library;

import 'package:homio_essentials/features/search/domain/entities/search_hit.dart';
import 'package:homio_essentials/features/search/domain/entities/search_query.dart';

abstract interface class SearchRepository {
  SearchResults search(SearchQuery query);

  /// Throws ApiException when offline.
  Future<List<BookHit>> searchBooks(String text, {int limit = 40});
}
