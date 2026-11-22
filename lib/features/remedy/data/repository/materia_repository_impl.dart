/// ============================================================
/// MATERIA REPOSITORY (impl) — always from the server, remembered for this session only
/// ============================================================
///
/// Nothing is written to the phone. A small in-memory memo (most recent remedies) makes going back to a
/// remedy instant, and a request already in flight is shared, so a double tap never downloads twice.
/// Failures are not memoised: the next try asks the server again.
/// ============================================================
library;

import 'package:homio_essentials/core/network/dio_client.dart';
import 'package:homio_essentials/features/remedy/domain/entities/materia_entry.dart';
import 'package:homio_essentials/features/remedy/domain/repository/materia_repository.dart';

class MateriaRepositoryImpl implements MateriaRepository {
  MateriaRepositoryImpl({required this.api, this.memoSize = 24});
  final PostgrestApi api;

  /// How many remedies' book text stay in memory (a remedy's text is ≈4 KB–60 KB).
  final int memoSize;

  final _memo = <String, List<MateriaEntry>>{}; // map literals keep insertion order: first = least recently used
  final _inFlight = <String, Future<List<MateriaEntry>>>{};

  static List<MateriaEntry> _sorted(List<MateriaEntry> xs) =>
      xs..sort((a, b) => a.book == b.book ? a.sort.compareTo(b.sort) : a.book.compareTo(b.book));

  @override
  Future<List<MateriaEntry>> forRemedy(String remedyId) {
    final hit = _memo.remove(remedyId);
    if (hit != null) {
      _memo[remedyId] = hit; // refresh recency
      return Future.value(hit);
    }
    // Block body on purpose: `() => _inFlight.remove(id)` would RETURN this very future, and whenComplete waits
    // for a returned future — the load would wait for itself forever.
    return _inFlight[remedyId] ??= _fetch(remedyId).whenComplete(() {
      _inFlight.remove(remedyId);
    });
  }

  Future<List<MateriaEntry>> _fetch(String remedyId) async {
    final rows = await api.select('materia_entries',
        columns: 'source_book,section,body,source_url,sort_order,locale',
        filters: {'remedy_id': 'eq.$remedyId'},
        order: const ['source_book.asc', 'sort_order.asc']);
    final entries = _sorted(rows.map(MateriaEntry.from).toList());
    _memo[remedyId] = entries;
    while (_memo.length > memoSize) {
      _memo.remove(_memo.keys.first);
    }
    return entries;
  }
}
