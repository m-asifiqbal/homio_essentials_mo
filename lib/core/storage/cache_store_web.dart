import 'package:shared_preferences/shared_preferences.dart';

import 'package:homio_essentials/core/storage/cache_store.dart';

Future<CacheStore> openStore() async => _PrefsStore(await SharedPreferences.getInstance());

/// Web build (used for previews): localStorage via shared_preferences.
class _PrefsStore implements CacheStore {
  _PrefsStore(this.p);
  final SharedPreferences p;
  static const _prefix = 'cache.';

  @override
  Future<String?> read(String key) async => p.getString('$_prefix$key');

  @override
  Future<void> write(String key, String value) async => p.setString('$_prefix$key', value);

  @override
  Future<void> delete(String key) async => p.remove('$_prefix$key');

  @override
  Future<int> sizeBytes() async =>
      p.getKeys().where((k) => k.startsWith(_prefix)).fold<int>(0, (n, k) => n + (p.getString(k)?.length ?? 0));
}
