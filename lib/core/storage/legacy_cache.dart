import 'package:homio_essentials/core/storage/legacy_cache_io.dart' if (dart.library.js_interop) 'package:homio_essentials/core/storage/legacy_cache_web.dart' as impl;

/// Earlier versions saved the whole archive and every opened book text on the phone (plain JSON). The app is
/// online-only now, so the first launch after the update deletes that leftover copy. Safe to call every launch.
Future<void> purgeLegacyArchiveCache() => impl.purge();
