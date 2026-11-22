/// ============================================================
/// ARCHIVE REPOSITORY (impl) — download from the server, keep in memory
/// ============================================================
library;

import 'package:dio/dio.dart';

import 'package:homio_essentials/core/archive/data/datasource/archive_remote_datasource.dart';
import 'package:homio_essentials/core/archive/domain/entities/archive.dart';
import 'package:homio_essentials/core/archive/domain/repository/archive_repository.dart';

class ArchiveRepositoryImpl implements ArchiveRepository {
  ArchiveRepositoryImpl({required this.remote});
  final ArchiveRemoteDataSource remote;

  @override
  Future<Archive> load({CancelToken? cancel}) async {
    final download = await remote.fetchAll(cancel: cancel);
    return Archive.build(download.tables, download.signature, DateTime.now());
  }

  @override
  Future<Archive?> refresh(Archive current, {bool force = false, CancelToken? cancel}) async {
    if (!force) {
      final signature = await remote.fetchSignature(cancel: cancel);
      // An unreadable manifest ('' signature on the first load) never counts as "unchanged".
      if (signature.isNotEmpty && signature == current.signature) return null;
    }
    return load(cancel: cancel);
  }
}
