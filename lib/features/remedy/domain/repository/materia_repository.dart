/// ============================================================
/// MATERIA REPOSITORY (contract) — source-book text per remedy
/// ============================================================
///
/// Book text is too large to ship in the archive, so it is fetched from the
/// server when a remedy's Study / Dosage tab needs it (and only remembered in
/// memory for the session — nothing is saved on the phone).
/// ============================================================
library;

import 'package:homio_essentials/features/remedy/domain/entities/materia_entry.dart';

abstract interface class MateriaRepository {
  /// Sections ordered by book, then position in the book. Throws ApiException when the server can't be reached.
  Future<List<MateriaEntry>> forRemedy(String remedyId);
}
