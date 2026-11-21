/// ============================================================
/// LIBRARY PROVIDER — saved remedies and recently viewed (device only)
/// ============================================================
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:homio_essentials/shared/providers/core_providers.dart';

/// An ordered list of remedy slugs kept in preferences (newest first).
class SlugListController extends Notifier<List<String>> {
  SlugListController(this.key, {this.max = 200});
  final String key;
  final int max;

  @override
  List<String> build() => ref.watch(prefsProvider).getStringList(key) ?? const [];

  void _save(List<String> v) {
    ref.read(prefsProvider).setStringList(key, v);
    state = v;
  }

  bool contains(String slug) => state.contains(slug);

  /// Adds or removes; returns true when [slug] is now in the list.
  bool toggle(String slug) {
    final had = state.contains(slug);
    _save(had ? (state.toList()..remove(slug)) : [slug, ...state]);
    return !had;
  }

  void push(String slug) => _save([slug, ...state.where((s) => s != slug)].take(max).toList());
  void remove(String slug) => _save(state.where((s) => s != slug).toList());
  void restore(List<String> v) => _save(v);
  void clear() => _save(const []);
}

final savedProvider = NotifierProvider<SlugListController, List<String>>(() => SlugListController('saved_slugs'));
final historyProvider = NotifierProvider<SlugListController, List<String>>(() => SlugListController('history_slugs', max: 30));
