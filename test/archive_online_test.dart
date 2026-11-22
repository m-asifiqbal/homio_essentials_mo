/// The online-only data layer: everything comes from the server at launch and nothing is saved on the phone.
/// Runs the real remote data source, repository and controller against an in-process fake of Supabase.
library;

import 'dart:convert';
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:homio_essentials/core/archive/data/datasource/archive_remote_datasource.dart';
import 'package:homio_essentials/core/archive/data/repository/archive_repository_impl.dart';
import 'package:homio_essentials/core/archive/domain/entities/archive.dart';
import 'package:homio_essentials/core/archive/domain/repository/archive_repository.dart';
import 'package:homio_essentials/core/network/api_exception.dart';
import 'package:homio_essentials/shared/providers/archive_provider.dart';
import 'package:homio_essentials/shared/providers/core_providers.dart';
import 'package:homio_essentials/shared/providers/repository_providers.dart';
import 'package:dio/dio.dart';

import 'helpers/fake_supabase.dart';
import 'helpers/synthetic_archive.dart';

/// The synthetic archive with `remedy_relations` grown to [n] rows (so it needs several 1000-row pages).
Map<String, Rows> bigTables(int n) {
  final t = syntheticTables();
  t['remedy_relations'] = [for (var i = 0; i < n; i++) {'remedy_id': 'r1', 'related_remedy_id': 'r${3 + i % 7}', 'relation_type': 'compare$i'}];
  return t;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('remote data source', () {
    test('loads all 14 tables; a 2,500-row table is fetched as 3 pages, the last two together, using the total from the first response', () async {
      final server = FakeSupabase(bigTables(2500), latency: const Duration(milliseconds: 40));
      final result = await ArchiveRemoteDataSource(server.api()).fetchAll();

      expect(result.tables.keys, ArchiveRemoteDataSource.tables.keys);
      expect(result.tables['remedy_relations'], hasLength(2500));
      expect(result.tables['remedies'], hasLength(9));
      expect(server.offsetsFor('remedy_relations')..sort(), [0, 1000, 2000]);
      // 14 first pages + the manifest + 2 more relation pages — and no table waited for another.
      expect(server.requests.where((r) => r.path == 'remedy_relations' && '${r.headers['Prefer']}'.contains('count=exact')), hasLength(1), reason: 'only the first page asks for the total');
      expect(server.requests, hasLength(14 + 1 + 2));
      expect(server.maxInFlight, greaterThanOrEqualTo(15), reason: 'the 14 tables and the manifest start together');
      expect(result.signature, isNotEmpty);
    });

    test('rows come back in order and complete (no page lost or repeated)', () async {
      final server = FakeSupabase(bigTables(2500));
      final rows = (await ArchiveRemoteDataSource(server.api()).fetchAll()).tables['remedy_relations']!;
      expect([for (final r in rows) r['relation_type']], [for (var i = 0; i < 2500; i++) 'compare$i']);
    });

    test('without a Content-Range total (hidden header) it still loads everything, one page after another', () async {
      final server = FakeSupabase(bigTables(2500))..sendContentRange = false;
      final result = await ArchiveRemoteDataSource(server.api()).fetchAll();
      expect(result.tables['remedy_relations'], hasLength(2500));
      expect(server.offsetsFor('remedy_relations'), [0, 1000, 2000], reason: 'in order: each page waits for the previous one');
    });

    test('without the manifest function it still loads everything and in parallel; the signature is just unknown', () async {
      final server = FakeSupabase(bigTables(2500))..manifestAvailable = false;
      final result = await ArchiveRemoteDataSource(server.api()).fetchAll();
      expect(result.tables['remedy_relations'], hasLength(2500));
      expect(server.offsetsFor('remedy_relations')..sort(), [0, 1000, 2000]);
      expect(result.signature, '', reason: 'unknown signature: a later refresh must not call it "unchanged"');
    });

    test('rows added after the count was taken are still picked up', () async {
      final server = FakeSupabase(bigTables(1500))..countOverride['remedy_relations'] = 1000;
      final rows = (await ArchiveRemoteDataSource(server.api()).fetchAll()).tables['remedy_relations']!;
      expect(rows, hasLength(1500));
    });

    test('a table of exactly 1,000 rows ends with one empty page, not an endless loop', () async {
      final server = FakeSupabase(bigTables(1000));
      final rows = (await ArchiveRemoteDataSource(server.api()).fetchAll()).tables['remedy_relations']!;
      expect(rows, hasLength(1000));
      expect(server.offsetsFor('remedy_relations')..sort(), [0, 1000]);
    });

    test('the first failure cancels the requests still running', () async {
      final server = FakeSupabase(syntheticTables(), latency: const Duration(milliseconds: 60))..failTables.add('remedies');
      await expectLater(
        ArchiveRemoteDataSource(server.api()).fetchAll(),
        throwsA(isA<ApiException>().having((e) => e.kind, 'kind', ApiErrorKind.offline)),
      );
      await Future<void>.delayed(const Duration(milliseconds: 120));
      expect(server.cancelled, greaterThan(0), reason: 'siblings must not keep downloading after a failure');
    });

    test('a failure does not poison the caller token: the next load works', () async {
      final server = FakeSupabase(syntheticTables())..offline = true;
      final remote = ArchiveRemoteDataSource(server.api());
      final token = CancelToken();
      await expectLater(remote.fetchAll(cancel: token), throwsA(isA<ApiException>()));
      expect(token.isCancelled, isFalse);
      server.offline = false;
      expect((await remote.fetchAll(cancel: token)).tables['remedies'], hasLength(9));
    });

    test('error kinds: offline, timeout, server (with its HTTP code)', () async {
      Future<ApiException> failure(void Function(FakeSupabase) arrange) async {
        final server = FakeSupabase(syntheticTables());
        arrange(server);
        try {
          await ArchiveRemoteDataSource(server.api()).fetchAll();
        } on ApiException catch (e) {
          return e;
        }
        fail('expected an ApiException');
      }

      expect((await failure((s) => s.offline = true)).kind, ApiErrorKind.offline);
      expect((await failure((s) => s.timeout = true)).kind, ApiErrorKind.timeout);
      final server500 = await failure((s) => s.failStatus = 503);
      expect(server500.kind, ApiErrorKind.server);
      expect(server500.statusCode, 503);
    });

    test('real data: the live archive pages and reassembles exactly (skipped without the fixture)', () async {
      final file = File('${Platform.environment['HOMIO_FIXTURE_DIR'] ?? 'build/fixtures'}/archive_fixture.json');
      if (!file.existsSync()) {
        markTestSkipped('no fixture: run node tool/fetch_test_fixture.mjs');
        return;
      }
      final tables = <String, Rows>{
        for (final e in ((jsonDecode(file.readAsStringSync()) as Map)['tables'] as Map).entries)
          e.key as String: [for (final r in e.value as List) Map<String, dynamic>.from(r as Map)],
      };
      final server = FakeSupabase(tables);
      final result = await ArchiveRemoteDataSource(server.api()).fetchAll();
      for (final e in tables.entries) {
        expect(result.tables[e.key], hasLength(e.value.length), reason: e.key);
      }
      final archive = Archive.build(result.tables, result.signature, DateTime.now());
      expect(archive.remedies, hasLength(tables['remedies']!.length));
    });
  });

  group('repository', () {
    test('load builds the archive and keeps nothing else', () async {
      final repo = ArchiveRepositoryImpl(remote: ArchiveRemoteDataSource(FakeSupabase(syntheticTables()).api()));
      final archive = await repo.load();
      expect(archive.remedies.map((r) => r.slug), contains('arnica-montana'));
      expect(archive.signature, isNotEmpty);
    });

    test('refresh: unchanged → null after ONE tiny request; changed or forced → a full download', () async {
      final server = FakeSupabase(syntheticTables());
      final repo = ArchiveRepositoryImpl(remote: ArchiveRemoteDataSource(server.api()));
      final loaded = await repo.load();

      server.requests.clear();
      expect(await repo.refresh(loaded), isNull);
      expect(server.requests.map((r) => r.path), ['rpc/sync_manifest'], reason: 'checking for changes must not re-download anything');

      server.version = 'v2';
      final changed = await repo.refresh(loaded);
      expect(changed, isNotNull);
      expect(changed!.signature, isNot(loaded.signature));

      server.requests.clear();
      expect(await repo.refresh(changed, force: true), isNotNull);
      expect(server.tableRequests, 14);
    });

    test('an unreadable signature never counts as "unchanged"', () async {
      final server = FakeSupabase(syntheticTables())..manifestAvailable = false;
      final repo = ArchiveRepositoryImpl(remote: ArchiveRemoteDataSource(server.api()));
      final loaded = await repo.load();
      expect(loaded.signature, '');
      server.manifestAvailable = true;
      expect(await repo.refresh(loaded), isNotNull);
    });
  });

  group('controller (what the screens watch)', () {
    ProviderContainer containerFor(FakeSupabase server) {
      final c = ProviderContainer(retry: noAutoRetry, overrides: [
        archiveRepositoryProvider.overrideWithValue(ArchiveRepositoryImpl(remote: ArchiveRemoteDataSource(server.api()))),
      ]);
      addTearDown(c.dispose);
      return c;
    }

    Future<Archive> loaded(ProviderContainer c) => c.read(archiveProvider.future);

    test('loading → data', () async {
      final c = containerFor(FakeSupabase(syntheticTables(), latency: const Duration(milliseconds: 10)));
      c.listen(archiveProvider, (_, _) {});
      expect(c.read(archiveProvider).isLoading, isTrue);
      await loaded(c);
      expect(c.read(archiveProvider).value!.remedies, isNotEmpty);
      expect(c.read(syncStateProvider), SyncState.idle);
    });

    test('a failed first load is an error with a typed cause; Retry (invalidate) loads it', () async {
      final server = FakeSupabase(syntheticTables())..offline = true;
      final c = containerFor(server);
      c.listen(archiveProvider, (_, _) {});
      await expectLater(c.read(archiveProvider.future), throwsA(isA<ApiException>()));
      final err = c.read(archiveProvider);
      expect(err.hasError, isTrue);
      expect(ApiException.from(err.error!).kind, ApiErrorKind.offline);

      server.offline = false;
      c.invalidate(archiveProvider);
      expect(c.read(archiveProvider).isLoading, isTrue, reason: 'Retry shows the skeleton again');
      expect((await loaded(c)).remedies, isNotEmpty);
    });

    test('after loading, losing the connection keeps the data and flags it; reconnecting clears the flag', () async {
      final server = FakeSupabase(syntheticTables());
      final c = containerFor(server);
      c.listen(archiveProvider, (_, _) {});
      final first = await loaded(c);

      server.offline = true;
      await c.read(archiveProvider.notifier).refresh();
      expect(c.read(syncStateProvider), SyncState.offline);
      expect(c.read(archiveProvider).value, same(first), reason: 'already-loaded data stays usable');

      server.offline = false;
      await c.read(archiveProvider.notifier).refresh();
      expect(c.read(syncStateProvider), SyncState.idle);
    });

    test('a changed server swaps in the new archive; unchanged keeps the same object', () async {
      final server = FakeSupabase(syntheticTables());
      final c = containerFor(server);
      c.listen(archiveProvider, (_, _) {});
      final first = await loaded(c);

      await c.read(archiveProvider.notifier).refresh();
      expect(c.read(archiveProvider).value, same(first));

      server.version = 'v2';
      await c.read(archiveProvider.notifier).refresh();
      expect(c.read(archiveProvider).value, isNot(same(first)));
    });

    test('two quick refreshes share one check', () async {
      final server = FakeSupabase(syntheticTables(), latency: const Duration(milliseconds: 20));
      final c = containerFor(server);
      c.listen(archiveProvider, (_, _) {});
      await loaded(c);
      server.requests.clear();
      final ctl = c.read(archiveProvider.notifier);
      await Future.wait([ctl.refresh(), ctl.refresh(), ctl.refresh()]);
      expect(server.manifestRequests, 1);
    });

    test('pull-to-refresh during the first download does not restart it', () async {
      final server = FakeSupabase(syntheticTables(), latency: const Duration(milliseconds: 30));
      final c = containerFor(server);
      c.listen(archiveProvider, (_, _) {});
      await c.read(archiveProvider.notifier).refresh();
      await loaded(c);
      expect(server.requests.where((r) => r.path == 'remedies'), hasLength(1));
    });

    test('coming back to the app after a failed check retries it', () async {
      final server = FakeSupabase(syntheticTables());
      final c = containerFor(server);
      c.listen(archiveProvider, (_, _) {});
      await loaded(c);
      server.offline = true;
      await c.read(archiveProvider.notifier).refresh();
      expect(c.read(syncStateProvider), SyncState.offline);

      server.offline = false;
      final binding = TestWidgetsFlutterBinding.instance;
      for (final s in [AppLifecycleState.inactive, AppLifecycleState.hidden, AppLifecycleState.paused, AppLifecycleState.hidden, AppLifecycleState.inactive, AppLifecycleState.resumed]) {
        binding.handleAppLifecycleStateChanged(s);
      }
      await Future<void>.delayed(const Duration(milliseconds: 50));
      expect(c.read(syncStateProvider), SyncState.idle);
    });

    test('disposing mid-download cancels it (leaving the app never leaves requests running)', () async {
      final server = FakeSupabase(syntheticTables(), latency: const Duration(milliseconds: 80));
      final c = ProviderContainer(retry: noAutoRetry, overrides: [
        archiveRepositoryProvider.overrideWithValue(ArchiveRepositoryImpl(remote: ArchiveRemoteDataSource(server.api()))),
      ]);
      c.listen(archiveProvider, (_, _) {});
      await Future<void>.delayed(const Duration(milliseconds: 20));
      c.dispose();
      await Future<void>.delayed(const Duration(milliseconds: 150));
      expect(server.cancelled, greaterThan(0));
    });
  });

  test('ArchiveRepository is the only door: the contract has load and refresh, no disk cache', () {
    // Compile-time guard: a stub implementing just these two members satisfies the contract.
    final ArchiveRepository stub = _Stub();
    expect(stub, isA<ArchiveRepository>());
  });
}

class _Stub implements ArchiveRepository {
  @override
  Future<Archive> load({CancelToken? cancel}) async => buildSyntheticArchive();

  @override
  Future<Archive?> refresh(Archive current, {bool force = false, CancelToken? cancel}) async => null;
}
