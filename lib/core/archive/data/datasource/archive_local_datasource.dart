/// ============================================================
/// ARCHIVE LOCAL DATASOURCE — the archive and book text on this device
/// ============================================================
library;

import 'dart:convert';

import 'package:homio_essentials/core/storage/cache_store.dart';
import 'package:homio_essentials/core/utils/json.dart';

class ArchiveLocalDataSource {
  ArchiveLocalDataSource(this.store);
  final CacheStore store;
  static const _archiveKey = 'archive_v1';

  Future<Json?> readArchive() async {
    final raw = await store.read(_archiveKey);
    return raw == null ? null : jsonDecode(raw) as Json;
  }

  Future<void> writeArchive(Json json) => store.write(_archiveKey, jsonEncode(json));

  Future<List<Json>?> readRows(String key) async {
    final raw = await store.read(key);
    return raw == null ? null : (jsonDecode(raw) as List).map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  Future<void> writeRows(String key, List<Json> rows) => store.write(key, jsonEncode(rows));

  Future<int> sizeBytes() => store.sizeBytes();
}
