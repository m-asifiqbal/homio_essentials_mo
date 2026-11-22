/// Opens every remedy / condition page of the REAL archive with every section expanded, in English and Bangla,
/// at a normal and a cramped phone size, and fails with the exact exception text of any red screen.
///
/// Needs the fixture files written by the fetch scripts. Skipped when they are absent:
///   node tool/fetch_test_fixture.mjs   (writes build/fixtures, git-ignored)
///   HOMIO_FIXTURE_DIR=build/fixtures flutter test test/screens_smoke_real_data_test.dart
/// Optional: HOMIO_SMOKE_LIMIT=N checks only the first N remedies (default: all).
library;

import 'dart:io';
import 'dart:ui' show Size;

import 'package:flutter/material.dart' show Icons;
import 'package:flutter_test/flutter_test.dart';

import 'package:homio_essentials/features/remedy/domain/entities/materia_entry.dart';

import 'helpers/app_harness.dart';

void main() {
  final dir = Platform.environment['HOMIO_FIXTURE_DIR'];
  final archive = dir == null ? null : loadFixtureArchive('$dir/archive_fixture.json');
  final Map<String, List<MateriaEntry>> materia = dir == null ? const {} : loadFixtureMateria('$dir/materia_fixture.json');
  final limit = int.tryParse(Platform.environment['HOMIO_SMOKE_LIMIT'] ?? '');

  setUpAll(loadAppFonts);

  Future<void> expandAll(WidgetTester tester) async {
    final btn = find.byIcon(Icons.unfold_more_rounded);
    if (btn.evaluate().isNotEmpty) {
      await tester.tap(btn.first);
      await settleFrames(tester, frames: 5);
    }
  }

  for (final (locale, size, scale) in [('en', const Size(390, 844), 1.0), ('bn', const Size(360, 640), 1.3)]) {
    testWidgets('every remedy page opens without a red screen [$locale ${size.width.toInt()}x${size.height.toInt()} ×$scale]', (tester) async {
      final a = archive!;
      final log = ErrorLog.install();
      final app = await pumpApp(tester, a, locale: locale, size: size, textScale: scale, materia: Map.of(materia));
      final failures = <String, List<String>>{};
      final remedies = a.remedies.take(limit ?? a.remedies.length).toList();
      for (final r in remedies) {
        app.go('/remedy/${r.slug}');
        await settleFrames(tester, frames: 4);
        await expandAll(tester);
        final errs = log.take();
        if (errs.isNotEmpty) failures[r.slug] = errs;
      }
      log.restore();
      // Group identical messages so the report stays readable.
      final byMessage = <String, List<String>>{};
      failures.forEach((slug, errs) { for (final e in errs.toSet()) { (byMessage[e] ??= []).add(slug); } });
      final report = byMessage.entries.map((e) => '• ${e.key}\n    on ${e.value.length} page(s): ${e.value.take(6).join(', ')}').join('\n');
      expect(failures, isEmpty, reason: '${failures.length} of ${remedies.length} remedy pages threw:\n$report');
    }, skip: archive == null, // set HOMIO_FIXTURE_DIR to run against the real archive
     timeout: const Timeout(Duration(minutes: 20)));
  }

  Future<void> visitAll(WidgetTester tester, Iterable<String> locations, {String locale = 'en'}) async {
    final log = ErrorLog.install();
    final app = await pumpApp(tester, archive!, locale: locale, materia: Map.of(materia));
    final failures = <String>[];
    for (final location in locations) {
      app.go(location);
      await settleFrames(tester, frames: 4);
      final errs = log.take();
      if (errs.isNotEmpty) failures.add('$location -> ${errs.join(' | ')}');
    }
    log.restore();
    expect(failures, isEmpty, reason: failures.join('\n'));
  }

  testWidgets('every condition page opens without a red screen', (tester) async {
    await visitAll(tester, archive!.conditions.map((c) => '/condition/${c.slug}'));
  }, skip: archive == null, timeout: const Timeout(Duration(minutes: 5)));

  for (final loc in ['/home', '/explore', '/explore?tab=symptoms', '/explore?tab=companies', '/saved', '/settings', '/guide', '/disclaimer', '/sources']) {
    for (final locale in ['en', 'bn']) {
      testWidgets('$loc opens without a red screen [$locale]', (tester) => visitAll(tester, [loc], locale: locale), skip: archive == null);
    }
  }

  // Home's "Symptoms" / "Companies" cards switch Explore's segment while Explore is already built (tab kept alive).
  testWidgets('explore deep links while Explore is already open (the red screen on Home cards)', (tester) async {
    await visitAll(tester, ['/explore', '/explore?tab=symptoms', '/explore?tab=companies', '/explore?tab=remedies', '/home', '/explore?tab=symptoms']);
  }, skip: archive == null);

  testWidgets('search: idle, typed query, category switch, leave', (tester) async {
    await visitAll(tester, ['/search', '/search?q=arnica', '/search?q=fever', '/search?q=আর্নিকা', '/home']);
  }, skip: archive == null);
}
