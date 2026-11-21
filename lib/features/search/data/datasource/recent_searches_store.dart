/// ============================================================
/// RECENT SEARCHES STORE — last 10 terms on this device
/// ============================================================
library;

import 'package:shared_preferences/shared_preferences.dart';

class RecentSearchesStore {
  RecentSearchesStore(this.prefs);
  final SharedPreferences prefs;
  static const _key = 'recent_searches';
  static const max = 10;

  List<String> read() => prefs.getStringList(_key) ?? const [];
  Future<void> write(List<String> v) => prefs.setStringList(_key, v);

  /// [term] moved to the front, case-insensitively de-duplicated, capped at [max].
  static List<String> push(List<String> current, String term) {
    final t = term.trim();
    if (t.length < 2) return current;
    return [t, ...current.where((x) => x.toLowerCase() != t.toLowerCase())].take(max).toList();
  }
}
