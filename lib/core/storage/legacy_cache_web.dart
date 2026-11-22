import 'package:shared_preferences/shared_preferences.dart';

/// Web build: the old cache lived in localStorage under `cache.*` keys.
Future<void> purge() async {
  final prefs = await SharedPreferences.getInstance();
  for (final key in prefs.getKeys().where((k) => k.startsWith('cache.')).toList()) {
    await prefs.remove(key);
  }
}
