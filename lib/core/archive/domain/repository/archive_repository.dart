/// ============================================================
/// ARCHIVE REPOSITORY (contract) — the remedy archive, always from the server
/// ============================================================
///
/// The archive (remedies, conditions, uses, doses, safety notes, relations,
/// companies, contact channels, app config) is small (≈240 KB on the wire),
/// so it is downloaded whole at every launch and kept in MEMORY only — nothing
/// is written to the phone. That makes browsing and search instant after one
/// short load, instead of a network round trip on every tap.
/// ============================================================
library;

import 'package:dio/dio.dart';

import 'package:homio_essentials/core/archive/domain/entities/archive.dart';

abstract interface class ArchiveRepository {
  /// Downloads the whole archive. Throws ApiException.
  Future<Archive> load({CancelToken? cancel});

  /// Asks the server whether anything changed since [current] (one tiny request) and downloads again only
  /// if so (or when [force]). Returns null when [current] is still up to date. Throws ApiException.
  Future<Archive?> refresh(Archive current, {bool force = false, CancelToken? cancel});
}
