/// Book text (Materia Medica): every sub-section of a remedy must open, close and open again without an error.
///
/// Why this test exists: the all-remedies sweep only ever built the FIRST sub-section (the others are collapsed,
/// and a collapsed ExpansionTile doesn't build its body). A body that threw only on the first tap showed up on
/// a phone as a grey box that scrolls forever (a release build draws a failed widget grey, with no height limit).
/// Cause: a PageStorageKey above a SelectableText — the tile's open flag (bool) and the text's scroll offset
/// (double) shared one storage slot.
library;

import 'dart:io';

import 'package:flutter/widgets.dart' show Size;
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart' show ExpansionTile, ListTile;

import 'helpers/app_harness.dart';

void main() {
  setUpAll(loadAppFonts);

  final dir = Platform.environment['HOMIO_FIXTURE_DIR'] ?? 'build/fixtures';
  final archive = loadFixtureArchive('$dir/archive_fixture.json');
  final materia = loadFixtureMateria('$dir/materia_fixture.json');

  // Aconitum (the reported one) in both languages, plus the remedies with the most book sections.
  final bySize = materia.entries.toList()..sort((a, b) => b.value.length.compareTo(a.value.length));
  final biggest = [
    for (final e in bySize.take(5))
      if (archive != null) archive.remedyById[e.key]?.slug,
  ].whereType<String>();

  Future<void> openAndCloseEverySubSection(WidgetTester tester, String slug, String locale) async {
    final log = ErrorLog.install();
    try {
      // A very tall window: the page is a lazy list, and every sub-section must be built to be tapped.
      final app = await pumpApp(tester, archive!, locale: locale, role: 'student', materia: materia, size: const Size(390, 12000));
      app.go('/remedy/$slug?tab=study');
      for (var i = 0; i < 14; i++) {
        await tester.pump(const Duration(milliseconds: 150));
      }
      final tiles = find.byType(ExpansionTile);
      final count = tiles.evaluate().length;
      expect(count, greaterThan(2), reason: '$slug: the book sub-sections are on the page');
      for (var i = 0; i < count; i++) {
        for (final action in ['toggle', 'toggle back']) {
          // Tap the tile's HEADER (an open tile's centre is its body, which can hold tappable chips).
          final header = find.descendant(of: tiles.at(i), matching: find.byType(ListTile)).first;
          await tester.ensureVisible(header);
          await tester.pump(const Duration(milliseconds: 50));
          await tester.tap(header, warnIfMissed: false);
          await tester.pump(const Duration(milliseconds: 80));
          await tester.pump(const Duration(milliseconds: 300));
          final errors = log.take();
          expect(errors, isEmpty, reason: '$slug sub-section #$i ($action) [$locale]: ${errors.join('\n')}');
        }
      }
    } finally {
      log.restore();
    }
  }

  for (final locale in ['en', 'bn']) {
    testWidgets('Aconitum: open and close every book sub-section [$locale]', (tester) => openAndCloseEverySubSection(tester, 'aconitum-napellus', locale),
        skip: archive == null);
  }

  // One test per remedy (a second pumpApp inside one test leaves a Riverpod dispose timer behind).
  for (final slug in biggest) {
    testWidgets('one of the remedies with the most book sections, $slug: every sub-section opens', (tester) => openAndCloseEverySubSection(tester, slug, 'en'),
        skip: archive == null);
  }
}
