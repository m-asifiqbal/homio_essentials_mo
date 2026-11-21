/// ============================================================
/// ARCHIVE REPOSITORY (impl) — cache first, refresh when the server changed
/// ============================================================
library;

import 'package:homio_essentials/core/archive/data/datasource/archive_local_datasource.dart';
import 'package:homio_essentials/core/archive/data/datasource/archive_remote_datasource.dart';
import 'package:homio_essentials/core/archive/domain/entities/archive.dart';
import 'package:homio_essentials/core/archive/domain/repository/archive_repository.dart';
import 'package:homio_essentials/core/utils/app_logger.dart';

class ArchiveRepositoryImpl implements ArchiveRepository {
  ArchiveRepositoryImpl({required this.remote, required this.local});
  final ArchiveRemoteDataSource remote;
  final ArchiveLocalDataSource local;

  @override
  Future<Archive?> loadCached() async {
    try {
      final json = await local.readArchive();
      return json == null ? null : Archive.fromJson(json);
    } catch (e, st) {
      AppLogger.e('cached archive unreadable — will re-download', error: e, stackTrace: st);
      return null;
    }
  }

  @override
  Future<Archive?> sync({Archive? current, bool force = false}) async {
    final signature = await remote.fetchSignature();
    if (!force && current != null && current.signature == signature) return null;
    final archive = Archive.build(await remote.fetchAllTables(), signature, DateTime.now());
    await local.writeArchive(archive.toJson());
    return archive;
  }

  @override
  Future<int> cacheSizeBytes() => local.sizeBytes();
}
