/// ============================================================
/// APP LOGGER — debug-only logging, one place to route it later
/// ============================================================
library;

import 'package:flutter/foundation.dart';

abstract final class AppLogger {
  static void d(String msg) {
    if (kDebugMode) debugPrint('[homio] $msg');
  }

  static void e(String msg, {Object? error, StackTrace? stackTrace}) {
    if (kDebugMode) debugPrint('[homio] ERROR $msg${error == null ? '' : ' · $error'}');
  }
}
