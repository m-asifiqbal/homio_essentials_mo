/// Test harness: the REAL app (theme, router, localisation, text scaler) over an in-memory archive.
///
/// Used by the screen smoke tests to open every page with real or synthetic data under debug assertions —
/// the same conditions as `flutter run` — so a "red screen" shows up here as a test failure with its message.
library;

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart' show DiagnosticLevel, FlutterError, FlutterExceptionHandler;
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:dio/dio.dart';
import 'package:homio_essentials/app.dart';
import 'package:homio_essentials/core/ads/ad_service.dart';
import 'package:homio_essentials/features/search/domain/entities/search_hit.dart';
import 'package:homio_essentials/features/search/presentation/providers/search_providers.dart';
import 'package:homio_essentials/core/archive/domain/entities/archive.dart';
import 'package:homio_essentials/core/connection/domain/repository/connection_repository.dart';
import 'package:homio_essentials/core/router/app_router.dart';
import 'package:homio_essentials/features/promotions/domain/entities/promotion.dart';
import 'package:homio_essentials/features/promotions/presentation/providers/promotions_providers.dart';
import 'package:homio_essentials/features/remedy/domain/entities/materia_entry.dart';
import 'package:homio_essentials/features/remedy/presentation/providers/remedy_providers.dart';
import 'package:homio_essentials/shared/providers/archive_provider.dart';
import 'package:homio_essentials/shared/providers/connection_provider.dart';
import 'package:homio_essentials/shared/providers/core_providers.dart';
import 'package:homio_essentials/shared/providers/repository_providers.dart';

/// Loads the bundled fonts so text has its real widths (the default test font is a box that hides overflow).
Future<void> loadAppFonts() async {
  const families = <String, List<String>>{
    'LexendDeca': ['LexendDeca-Regular', 'LexendDeca-Medium', 'LexendDeca-SemiBold', 'LexendDeca-Bold'],
    'NunitoSans': ['NunitoSans-Regular', 'NunitoSans-Medium', 'NunitoSans-SemiBold', 'NunitoSans-Bold', 'NunitoSans-ExtraBold', 'NunitoSans-Italic'],
  };
  for (final e in families.entries) {
    final loader = FontLoader(e.key);
    for (final f in e.value) {
      loader.addFont(rootBundle.load('assets/fonts/$f.ttf'));
    }
    await loader.load();
  }
  final bn = Directory('assets/fonts').listSync().whereType<File>().where((f) => f.path.contains('NotoSansBengali')).toList();
  if (bn.isNotEmpty) {
    final loader = FontLoader('NotoSansBengali');
    for (final f in bn) {
      loader.addFont(Future.value(ByteData.sublistView(f.readAsBytesSync())));
    }
    await loader.load();
  }
}

/// No consent form, no SDK, no 12-second timer.
class FakeAdService extends AdService {
  @override
  Future<void> start() async {}
}

class FakeArchiveController extends ArchiveController {
  FakeArchiveController(this.archive);
  final Archive archive;

  /// Every refresh(force:) call, so a test can tell what a tap triggered.
  final refreshCalls = <bool>[];

  @override
  Future<Archive> build() async => archive;

  @override
  Future<void> refresh({bool force = false}) async => refreshCalls.add(force);
}

/// Stays loading until [finish] is called (the first download in progress).
class LoadingArchiveController extends ArchiveController {
  LoadingArchiveController(this.archive);
  final Archive archive;
  static int builds = 0;

  @override
  Future<Archive> build() {
    builds++;
    return Completer<Archive>().future;
  }
}

/// Fails like a real download would, [failures] times, then loads. Counts its builds.
class FlakyArchiveController extends ArchiveController {
  FlakyArchiveController(this.archive, this.error, {this.failures = 1});
  final Archive archive;
  final Object error;
  final int failures;
  static int builds = 0;

  @override
  Future<Archive> build() async {
    await Future<void>.value();
    if (builds++ < failures) throw error;
    return archive;
  }
}

/// An archive saved by the fixture fetch script (`{signature, synced_at, tables}`), or null when absent.
Archive? loadFixtureArchive(String path) {
  final f = File(path);
  if (!f.existsSync()) return null;
  return Archive.fromJson(jsonDecode(f.readAsStringSync()) as Map<String, dynamic>);
}

Map<String, List<MateriaEntry>> loadFixtureMateria(String path) {
  final f = File(path);
  if (!f.existsSync()) return const {};
  final raw = jsonDecode(f.readAsStringSync()) as Map<String, dynamic>;
  return raw.map((id, list) => MapEntry(id, [for (final e in list as List) MateriaEntry.from(Map<String, dynamic>.from(e as Map))]));
}

/// A phone whose network and server the test controls (no plugin channels, no real sockets).
class FakeConnectionRepository implements ConnectionRepository {
  bool network = true, server = true;
  int networkChecks = 0, serverChecks = 0;
  final changes = StreamController<void>.broadcast();

  /// Like switching Wi-Fi / mobile data on or off: changes the state and fires the change event.
  void setNetwork(bool on) {
    network = on;
    changes.add(null);
  }

  @override
  Stream<void> get networkChanges => changes.stream;

  @override
  Future<bool> hasNetwork() async {
    networkChecks++;
    return network;
  }

  @override
  Future<bool> serverReachable() async {
    serverChecks++;
    return server;
  }
}

class AppHarness {
  AppHarness(this.container, this.connection);
  final ProviderContainer container;
  final FakeConnectionRepository connection;

  GoRouter get router => container.read(appRouterProvider);
  void go(String location) => router.go(location);
}

/// Pumps the whole app over [archive]. Language `en` | `bn`; text scale as saved by Settings.
Future<AppHarness> pumpApp(
  WidgetTester tester,
  Archive archive, {
  String locale = 'en',
  double textScale = 1.0,
  String role = 'student',
  Map<String, List<MateriaEntry>> materia = const {},
  Size size = const Size(390, 844),
  bool dark = false,
  ArchiveController Function()? controller,
  Future<List<MateriaEntry>> Function(String remedyId)? materiaLoader,
  FakeConnectionRepository? connection,
  ConnectionTiming timing = ConnectionTiming.off,
}) async {
  final phone = connection ?? FakeConnectionRepository();
  SharedPreferences.setMockInitialValues({
    'onboarded': true, 'locale': locale, 'role': role, 'text_scale': textScale, 'day_night': dark ? 'night' : 'day',
  });
  final prefs = await SharedPreferences.getInstance();
  tester.view
    ..physicalSize = Size(size.width * 3, size.height * 3)
    ..devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  final container = ProviderContainer(retry: noAutoRetry, overrides: [
    prefsProvider.overrideWithValue(prefs),
    connectionRepositoryProvider.overrideWithValue(phone),
    connectionTimingProvider.overrideWithValue(timing),
    archiveProvider.overrideWith(controller ?? () => FakeArchiveController(archive)),
    materiaProvider.overrideWith((ref, remedyId) => (materiaLoader ?? (id) async => materia[id] ?? const <MateriaEntry>[])(remedyId)),
    livePromotionsProvider.overrideWith((ref) async => const <Promotion>[]),
    adServiceProvider.overrideWithValue(FakeAdService()),
    dioProvider.overrideWithValue(Dio(BaseOptions(baseUrl: 'https://offline.invalid'))),
    bookResultsProvider.overrideWith((ref, text) async => const <BookHit>[]),
  ]);
  addTearDown(container.dispose);
  await tester.pumpWidget(UncontrolledProviderScope(container: container, child: const HomioApp()));
  await tester.pump(const Duration(milliseconds: 300));
  return AppHarness(container, phone);
}

/// Pumps a few frames (not pumpAndSettle: skeletons and sliders animate forever).
Future<void> settleFrames(WidgetTester tester, {int frames = 6, Duration step = const Duration(milliseconds: 120)}) async {
  for (var i = 0; i < frames; i++) {
    await tester.pump(step);
  }
}

/// Collects EVERY framework error (red screens, overflows, asserts), each with the first app frames of its stack.
/// Install at the start of a test and call [restore] at the end (flutter_test requires the handler back).
class ErrorLog {
  ErrorLog._(this._previous);
  final FlutterExceptionHandler? _previous;
  final entries = <String>[];

  static ErrorLog install() {
    final log = ErrorLog._(FlutterError.onError);
    FlutterError.onError = (details) {
      final msg = details.exceptionAsString().split('\n').first;
      final frames = (details.stack?.toString().split('\n') ?? const <String>[])
          .where((l) => l.contains('homio_essentials') && !l.contains('/test/'))
          .take(2)
          .map((l) => l.replaceAll(RegExp(r'package:homio_essentials/|[()]|^#\d+\s+'), '').trim());
      final text = details.toDiagnosticsNode().toStringDeep(minLevel: DiagnosticLevel.debug);
      final where = RegExp(r'lib/[A-Za-z0-9_/]+\.dart:\d+').allMatches(text).map((m) => m.group(0)).toSet().take(2);
      final detail = text.length > 1200 ? text.substring(0, 1200) : text;
      log.entries.add('$msg  @ ${[...where, ...frames].join(' <- ')}  :: $detail');
    };
    return log;
  }

  /// Entries since the last [take], de-duplicated.
  List<String> take() {
    final out = entries.toSet().toList();
    entries.clear();
    return out;
  }

  void restore() => FlutterError.onError = _previous;
}

/// Kept for simple tests: exceptions the test binding caught since the last call.
List<String> drainExceptions(WidgetTester tester) {
  final out = <String>[];
  Object? e;
  while ((e = tester.takeException()) != null) {
    final text = e.toString().split('\n').take(3).join(' | ');
    out.add(text.length > 360 ? '${text.substring(0, 360)}...' : text);
  }
  return out;
}
