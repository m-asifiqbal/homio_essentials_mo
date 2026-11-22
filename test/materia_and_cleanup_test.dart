/// Book text is fetched from the server and only remembered in memory; the old on-phone copy is removed.
library;

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:homio_essentials/core/network/api_exception.dart';
import 'package:homio_essentials/core/storage/legacy_cache_io.dart' as legacy;
import 'package:homio_essentials/features/remedy/data/repository/materia_repository_impl.dart';

import 'helpers/fake_supabase.dart';

Rows _entries(String remedyId, {int n = 3}) => [
      for (var i = 0; i < n; i++) {'remedy_id': remedyId, 'source_book': i.isEven ? 'boericke' : 'allen', 'section': 'S$i', 'body': 'Text $i of $remedyId', 'source_url': null, 'sort_order': i},
    ];

FakeSupabase _server({Duration latency = Duration.zero}) =>
    FakeSupabase({'materia_entries': [for (final id in ['a', 'b', 'c', 'd']) ..._entries(id)]}, latency: latency);

void main() {
  group('MateriaRepositoryImpl', () {
    test('asks the server for that remedy only, sorted by book then position', () async {
      final server = _server();
      final repo = MateriaRepositoryImpl(api: server.api());
      final out = await repo.forRemedy('a');
      expect(out.map((e) => e.body).toSet(), {'Text 0 of a', 'Text 1 of a', 'Text 2 of a'});
      expect(out.map((e) => e.book).toList(), ['allen', 'boericke', 'boericke'], reason: 'books alphabetical, then position');
      expect(server.requests.single.queryParameters['remedy_id'], 'eq.a');
    });

    test('a remedy opened again comes from memory (no second request)', () async {
      final server = _server();
      final repo = MateriaRepositoryImpl(api: server.api());
      await repo.forRemedy('a');
      await repo.forRemedy('a');
      expect(server.requests, hasLength(1));
    });

    test('a double tap while loading shares ONE request', () async {
      final server = _server(latency: const Duration(milliseconds: 30));
      final repo = MateriaRepositoryImpl(api: server.api());
      final results = await Future.wait([repo.forRemedy('a'), repo.forRemedy('a'), repo.forRemedy('a')]);
      expect(server.requests, hasLength(1));
      expect(results[1], same(results[0]));
    });

    test('a failure is not remembered: the next try asks the server again', () async {
      final server = _server()..offline = true;
      final repo = MateriaRepositoryImpl(api: server.api());
      await expectLater(repo.forRemedy('a'), throwsA(isA<ApiException>().having((e) => e.kind, 'kind', ApiErrorKind.offline)));
      server.offline = false;
      expect(await repo.forRemedy('a'), isNotEmpty);
      expect(server.requests, hasLength(2));
    });

    test('memory is bounded: the least recently used remedy is dropped first', () async {
      final server = _server();
      final repo = MateriaRepositoryImpl(api: server.api(), memoSize: 2);
      await repo.forRemedy('a');
      await repo.forRemedy('b');
      await repo.forRemedy('a'); // a is now the most recent
      await repo.forRemedy('c'); // evicts b
      server.requests.clear();
      await repo.forRemedy('a');
      expect(server.requests, isEmpty, reason: 'a was kept');
      await repo.forRemedy('b');
      expect(server.requests, hasLength(1), reason: 'b was evicted and is fetched again');
    });
  });

  group('old offline copy', () {
    test('is deleted at launch: the archive folder and everything in it', () async {
      final base = await Directory.systemTemp.createTemp('homio_support_');
      addTearDown(() => base.delete(recursive: true));
      final dir = Directory('${base.path}/archive')..createSync();
      File('${dir.path}/archive_v1.json').writeAsStringSync('{"tables":{}}');
      File('${dir.path}/materia_abc.json').writeAsStringSync('[]');
      File('${base.path}/keep_me.txt').writeAsStringSync('other app data');

      await legacy.purge(supportDir: base);

      expect(dir.existsSync(), isFalse);
      expect(File('${base.path}/keep_me.txt').existsSync(), isTrue, reason: 'nothing else is touched');
    });

    test('is a no-op when there is nothing to delete', () async {
      final base = await Directory.systemTemp.createTemp('homio_support_');
      addTearDown(() => base.delete(recursive: true));
      await legacy.purge(supportDir: base);
      expect(base.existsSync(), isTrue);
    });
  });

  test('guard: no app code writes files (the archive and book text stay in memory)', () {
    final writers = RegExp(r'writeAsString|writeAsBytes|openWrite|\.create\(recursive');
    final offenders = [
      for (final f in Directory('lib').listSync(recursive: true).whereType<File>().where((f) => f.path.endsWith('.dart')))
        if (writers.hasMatch(f.readAsStringSync())) f.path.replaceAll(r'\', '/'),
    ];
    expect(offenders, isEmpty, reason: 'online-only: nothing may be saved to the phone — $offenders');
  });
}
