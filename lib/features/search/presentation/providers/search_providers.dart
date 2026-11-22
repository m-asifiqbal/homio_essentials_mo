/// ============================================================
/// SEARCH PROVIDERS — search screen state, live results, history, voice
/// ============================================================
///
///   searchControllerProvider  input, debounced query (180 ms), category,
///                             filters, sort, voice status + live words
///   searchResultsProvider     offline archive results for the current query
///   bookResultsProvider       online full-text hits inside the source books
///   recentSearchesProvider    last 10 terms (device only)
/// ============================================================
library;

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:homio_essentials/core/platform/voice_input.dart';
import 'package:homio_essentials/features/search/data/datasource/recent_searches_store.dart';
import 'package:homio_essentials/features/search/data/repository/search_repository_impl.dart';
import 'package:homio_essentials/features/search/domain/entities/search_query.dart';
import 'package:homio_essentials/features/search/domain/repository/search_repository.dart';
import 'package:homio_essentials/features/search/domain/services/search_index.dart';
import 'package:homio_essentials/shared/providers/archive_provider.dart';
import 'package:homio_essentials/shared/providers/core_providers.dart';

/// Rebuilt only when the archive changes (≈1 ms per 1,000 names).
final searchIndexProvider = Provider<SearchIndex?>((ref) {
  final a = ref.watch(archiveProvider).value;
  return a == null ? null : SearchIndex(a);
});

final searchRepositoryProvider = Provider<SearchRepository?>((ref) {
  final a = ref.watch(archiveProvider).value;
  final index = ref.watch(searchIndexProvider);
  return a == null || index == null ? null : SearchRepositoryImpl(archive: a, index: index, api: ref.watch(postgrestProvider));
});

/// Category chip: an archive kind, or the books.
enum SearchCategory { all, remedies, symptoms, companies, books }

@immutable
class SearchUiState {
  const SearchUiState({
    this.input = '', this.query = '', this.category = SearchCategory.all, this.filters = SearchFilters.none,
    this.sort = SearchSort.relevance, this.voice = VoiceStatus.idle, this.voiceWords = '',
  });

  /// Text in the field now.
  final String input;

  /// [input] after the debounce — what is actually searched.
  final String query;
  final SearchCategory category;
  final SearchFilters filters;
  final SearchSort sort;
  final VoiceStatus voice;
  final String voiceWords;

  bool get hasQuery => query.trim().isNotEmpty;

  HitKind? get kind => switch (category) {
        SearchCategory.remedies => HitKind.remedy,
        SearchCategory.symptoms => HitKind.condition,
        SearchCategory.companies => HitKind.manufacturer,
        _ => null,
      };

  SearchQuery get request => SearchQuery(text: query.trim(), kind: kind, filters: filters, sort: sort);

  SearchUiState copyWith({String? input, String? query, SearchCategory? category, SearchFilters? filters, SearchSort? sort, VoiceStatus? voice, String? voiceWords}) =>
      SearchUiState(
        input: input ?? this.input, query: query ?? this.query, category: category ?? this.category, filters: filters ?? this.filters,
        sort: sort ?? this.sort, voice: voice ?? this.voice, voiceWords: voiceWords ?? this.voiceWords,
      );
}

/// Owns the debounce timer, every choice on the screen, and the voice session.
class SearchController extends Notifier<SearchUiState> {
  static const debounce = Duration(milliseconds: 180);
  Timer? _timer;

  @override
  SearchUiState build() {
    // Resolve the voice service NOW: a provider cannot be read from inside its own onDispose callback.
    final voice = ref.read(voiceInputProvider);
    ref.onDispose(() {
      _timer?.cancel();
      voice.cancel();
    });
    return const SearchUiState();
  }

  void setInput(String text) {
    state = state.copyWith(input: text);
    _timer?.cancel();
    if (text.trim().isEmpty) {
      state = state.copyWith(query: '');
      return;
    }
    _timer = Timer(debounce, () => state = state.copyWith(query: text));
  }

  /// Search immediately (submit, recent / popular chip, voice result, `?q=`).
  void searchNow(String text) {
    _timer?.cancel();
    state = state.copyWith(input: text, query: text);
  }

  void clear() => searchNow('');
  void setCategory(SearchCategory c) => state = state.copyWith(category: c);
  void setFilters(SearchFilters f) => state = state.copyWith(filters: f);
  void setSort(SearchSort s) => state = state.copyWith(sort: s);

  void remember([String? term]) => ref.read(recentSearchesProvider.notifier).add(term ?? state.query);

  // ---- voice ----
  Future<void> startVoice(String appLanguage) async {
    state = state.copyWith(voice: VoiceStatus.starting, voiceWords: '');
    final voice = ref.read(voiceInputProvider);
    final status = await voice.listen(
      appLanguage: appLanguage,
      onWords: (words, isFinal) {
        state = state.copyWith(voiceWords: words);
        if (isFinal) _finishVoice(words);
      },
      onStopped: () { if (state.voice == VoiceStatus.listening) _finishVoice(state.voiceWords); },
    );
    if (state.voice == VoiceStatus.starting) state = state.copyWith(voice: status);
  }

  void _finishVoice(String words) {
    final w = words.trim();
    state = state.copyWith(voice: w.isEmpty ? VoiceStatus.error : VoiceStatus.done);
    if (w.isNotEmpty) {
      searchNow(w);
      remember(w);
    }
  }

  Future<void> stopVoice() async {
    await ref.read(voiceInputProvider).stop();
    if (state.voice == VoiceStatus.listening) _finishVoice(state.voiceWords);
  }

  void resetVoice() => state = state.copyWith(voice: VoiceStatus.idle, voiceWords: '');
}

final searchControllerProvider = NotifierProvider.autoDispose<SearchController, SearchUiState>(SearchController.new);

/// Offline results for the screen's current request (instant).
final searchResultsProvider = Provider.autoDispose<SearchResults>((ref) {
  final repo = ref.watch(searchRepositoryProvider);
  final request = ref.watch(searchControllerProvider.select((s) => s.request));
  if (repo == null || request.text.isEmpty) return SearchResults.empty;
  return repo.search(request);
});

/// Full-text hits inside Boericke / Allen (online). Empty for short queries.
final bookResultsProvider = FutureProvider.autoDispose.family<List<BookHit>, String>((ref, text) async {
  final repo = ref.watch(searchRepositoryProvider);
  if (repo == null || text.trim().length < 3) return const [];
  return repo.searchBooks(text);
});

final recentSearchesStoreProvider = Provider((ref) => RecentSearchesStore(ref.watch(prefsProvider)));

class RecentSearchesController extends Notifier<List<String>> {
  RecentSearchesStore get _store => ref.read(recentSearchesStoreProvider);

  @override
  List<String> build() => ref.watch(recentSearchesStoreProvider).read();

  void add(String term) => _set(RecentSearchesStore.push(state, term));
  void remove(String term) => _set(state.where((t) => t != term).toList());
  void clear() => _set(const []);
  void restore(List<String> v) => _set(v);

  void _set(List<String> v) {
    state = v;
    _store.write(v);
  }
}

final recentSearchesProvider = NotifierProvider<RecentSearchesController, List<String>>(RecentSearchesController.new);
