/// ============================================================
/// ARCHIVE REPOSITORY (contract) — the offline remedy archive
/// ============================================================
///
/// The archive (remedies, conditions, uses, doses, safety notes, relations,
/// companies, contact channels, app config) is small (≈1 MB), so it is
/// downloaded whole, kept on the device and re-downloaded only when the
/// server's `sync_manifest()` signature changes.
/// ============================================================
library;

import 'package:homio_essentials/core/archive/domain/entities/archive.dart';

abstract interface class ArchiveRepository {
  /// The copy saved on this device, or null on first launch / corrupt cache.
  Future<Archive?> loadCached();

  /// Downloads a fresh archive when the server changed (or when [force]).
  /// Returns null when [current] is already up to date. Throws ApiException.
  Future<Archive?> sync({Archive? current, bool force = false});

  /// Bytes used by the archive and cached book text.
  Future<int> cacheSizeBytes();
}
