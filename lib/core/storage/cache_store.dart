import 'package:homio_essentials/core/storage/cache_store_io.dart' if (dart.library.js_interop) 'package:homio_essentials/core/storage/cache_store_web.dart' as impl;

/// Small key → JSON-string store for the offline archive.
/// Files in the app-support folder on Android/iOS; localStorage on the web build.
abstract class CacheStore {
  Future<String?> read(String key);
  Future<void> write(String key, String value);
  Future<void> delete(String key);
  Future<int> sizeBytes();

  static Future<CacheStore> open() => impl.openStore();
}
