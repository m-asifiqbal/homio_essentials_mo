/// ============================================================
/// MATERIA REPOSITORY (contract) — source-book text per remedy
/// ============================================================
///
/// Book text is too large to ship in the archive, so it is fetched the first
/// time a remedy's Study / Dosage tab needs it, then served from the device.
/// ============================================================
library;

import 'package:homio_essentials/features/remedy/domain/entities/materia_entry.dart';

abstract interface class MateriaRepository {
  /// Sections ordered by book, then position in the book. Falls back to the
  /// cached copy when offline; throws ApiException when neither is available.
  Future<List<MateriaEntry>> forRemedy(String remedyId);
}
