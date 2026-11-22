/// ============================================================
/// BOOTSTRAP — everything that must be ready before the first frame
/// ============================================================
///
/// Resolves the async singletons once (prefs) and injects
/// them with overrides, so no provider has to be async just to read a
/// preference. Ads start after the first frame (consent may show a form).
/// ============================================================
library;

import 'dart:async';
import 'dart:ui' show PlatformDispatcher;

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:homio_essentials/app.dart';
import 'package:homio_essentials/core/config/env.dart';
import 'package:homio_essentials/core/storage/legacy_cache.dart';
import 'package:homio_essentials/core/utils/app_logger.dart';
import 'package:homio_essentials/shared/providers/core_providers.dart';

Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();
  _installErrorHandlers();
  assert(Env.isConfigured, 'Missing env: run with --dart-define-from-file=env.json');
  final prefs = await SharedPreferences.getInstance();
  unawaited(purgeLegacyArchiveCache()); // the old offline copy is no longer used: remove it from the phone
  runApp(ProviderScope(
    retry: noAutoRetry,
    overrides: [prefsProvider.overrideWithValue(prefs)],
    child: const HomioApp(),
  ));
}

void _installErrorHandlers() {
  final defaultOnError = FlutterError.onError;
  FlutterError.onError = (details) {
    AppLogger.e('FlutterError: ${details.exceptionAsString()}', error: details.exception, stackTrace: details.stack);
    defaultOnError?.call(details);
  };
  PlatformDispatcher.instance.onError = (error, stack) {
    AppLogger.e('Uncaught async error', error: error, stackTrace: stack);
    return true;
  };
}
