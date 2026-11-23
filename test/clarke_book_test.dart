/// Clarke's Dictionary is a third book in the Study tab: its own chip, its own sections, the right source link.
library;

import 'package:flutter_test/flutter_test.dart';

import 'package:homio_essentials/features/remedy/domain/entities/materia_entry.dart';

import 'helpers/app_harness.dart';
import 'helpers/synthetic_archive.dart';

void main() {
  setUpAll(loadAppFonts);

  Map<String, List<MateriaEntry>> withClarke() {
    final m = syntheticMateria();
    return {
      'r1': [
        ...m['r1']!,
        for (final (i, s) in [('Clinical', 'Bruises. Concussion. Gout.'), ('Characteristics', 'Clarke on Arnica: the great remedy for the effects of falls, blows and bruises.'), ('Mind', 'Fear of being touched.')].indexed)
          MateriaEntry.from({'source_book': 'clarke', 'section': s.$1, 'body': s.$2, 'sort_order': i, 'source_url': 'https://example.test/clarke/arnica', 'locale': 'en'}),
      ],
    };
  }

  testWidgets('a Clarke chip appears next to Boericke and shows Clarke\'s own sections', (tester) async {
    final log = ErrorLog.install();
    try {
      final app = await pumpApp(tester, buildSyntheticArchive(), materia: withClarke());
      app.go('/remedy/arnica-montana?tab=study');
      for (var i = 0; i < 12; i++) {
        await tester.pump(const Duration(milliseconds: 150));
      }
      expect(find.text("Clarke's Dictionary"), findsOneWidget, reason: 'the book chip');
      expect(find.text('Boericke'), findsWidgets);
      await tester.ensureVisible(find.text("Clarke's Dictionary"));
      await tester.tap(find.text("Clarke's Dictionary"));
      for (var i = 0; i < 8; i++) {
        await tester.pump(const Duration(milliseconds: 150));
      }
      expect(find.text('Clinical'), findsOneWidget);
      expect(find.textContaining('the great remedy for the effects of falls'), findsNothing, reason: 'collapsed sections stay closed except the first');
      expect(find.text('Characteristics'), findsOneWidget);
      final errors = log.take();
      expect(errors, isEmpty, reason: errors.join('\n'));
    } finally {
      log.restore();
    }
  });
}
