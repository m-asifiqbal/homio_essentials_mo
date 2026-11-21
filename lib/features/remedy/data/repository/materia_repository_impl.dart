/// ============================================================
/// MATERIA REPOSITORY (impl) — network first, device cache as fallback
/// ============================================================
library;

import 'package:homio_essentials/core/archive/data/datasource/archive_local_datasource.dart';
import 'package:homio_essentials/core/network/api_exception.dart';
import 'package:homio_essentials/core/network/dio_client.dart';
import 'package:homio_essentials/features/remedy/domain/entities/materia_entry.dart';
import 'package:homio_essentials/features/remedy/domain/repository/materia_repository.dart';

class MateriaRepositoryImpl implements MateriaRepository {
  MateriaRepositoryImpl({required this.api, required this.local});
  final PostgrestApi api;
  final ArchiveLocalDataSource local;

  static List<MateriaEntry> _sorted(List<MateriaEntry> xs) =>
      xs..sort((a, b) => a.book == b.book ? a.sort.compareTo(b.sort) : a.book.compareTo(b.book));

  @override
  Future<List<MateriaEntry>> forRemedy(String remedyId) async {
    final key = 'materia_$remedyId';
    try {
      final rows = await api.select('materia_entries',
          columns: 'source_book,section,body,source_url,sort_order',
          filters: {'remedy_id': 'eq.$remedyId'},
          order: const ['source_book.asc', 'sort_order.asc']);
      await local.writeRows(key, rows);
      return _sorted(rows.map(MateriaEntry.from).toList());
    } on ApiException {
      final cached = await local.readRows(key);
      if (cached == null) rethrow;
      return _sorted(cached.map(MateriaEntry.from).toList());
    }
  }
}
