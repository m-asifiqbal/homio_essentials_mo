/// ============================================================
/// SEARCH QUERY — text + category + filters + sort
/// ============================================================
library;

import 'package:flutter/foundation.dart';

import 'package:homio_essentials/features/search/domain/entities/search_hit.dart';

enum SearchSort { relevance, alphabetical }

@immutable
class SearchFilters {
  const SearchFilters({this.kingdoms = const {}, this.reviewedOnly = false, this.withBangla = false});

  /// Empty = every kingdom.
  final Set<String> kingdoms;

  /// Only remedies with reviewed uses and doses (curated).
  final bool reviewedOnly;

  /// Only remedies that have a Bangla page.
  final bool withBangla;

  static const none = SearchFilters();
  int get activeCount => kingdoms.length + (reviewedOnly ? 1 : 0) + (withBangla ? 1 : 0);
  bool get isEmpty => activeCount == 0;

  SearchFilters copyWith({Set<String>? kingdoms, bool? reviewedOnly, bool? withBangla}) =>
      SearchFilters(kingdoms: kingdoms ?? this.kingdoms, reviewedOnly: reviewedOnly ?? this.reviewedOnly, withBangla: withBangla ?? this.withBangla);

  @override
  bool operator ==(Object other) =>
      other is SearchFilters && setEquals(other.kingdoms, kingdoms) && other.reviewedOnly == reviewedOnly && other.withBangla == withBangla;

  @override
  int get hashCode => Object.hash(Object.hashAllUnordered(kingdoms), reviewedOnly, withBangla);
}

@immutable
class SearchQuery {
  const SearchQuery({required this.text, this.kind, this.filters = SearchFilters.none, this.sort = SearchSort.relevance});
  final String text;

  /// Category chip (null = All).
  final HitKind? kind;
  final SearchFilters filters;
  final SearchSort sort;

  @override
  bool operator ==(Object other) => other is SearchQuery && other.text == text && other.kind == kind && other.filters == filters && other.sort == sort;

  @override
  int get hashCode => Object.hash(text, kind, filters, sort);
}
