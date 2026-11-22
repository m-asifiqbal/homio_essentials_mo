import 'dart:io';

import 'package:path_provider/path_provider.dart';

import 'package:homio_essentials/core/utils/app_logger.dart';

/// Deletes `<app support dir>/archive` (where the old offline cache lived). [supportDir] is for tests.
Future<void> purge({Directory? supportDir}) async {
  try {
    final base = supportDir ?? await getApplicationSupportDirectory();
    final dir = Directory('${base.path}/archive');
    if (await dir.exists()) await dir.delete(recursive: true);
  } catch (e, st) {
    AppLogger.e('could not delete the old offline cache', error: e, stackTrace: st); // harmless: never blocks launch
  }
}
