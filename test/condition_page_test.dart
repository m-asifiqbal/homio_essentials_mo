/// Symptom pages: red flags, remedies quoted from the books (with the source named) and the machine-translation note.
library;

import 'package:flutter_test/flutter_test.dart';

import 'helpers/app_harness.dart';
import 'helpers/synthetic_archive.dart';

void main() {
  setUpAll(loadAppFonts);

  Future<void> open(WidgetTester tester, {String locale = 'en'}) async {
    final app = await pumpApp(tester, buildSyntheticArchive(), locale: locale);
    app.go('/condition/injury');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
  }

  testWidgets('English: names the book the lines are quoted from, no machine-translation note', (tester) async {
    final log = ErrorLog.install();
    try {
      await open(tester);
      expect(find.textContaining("W. Boericke, Pocket Manual of Homoeopathic Materia Medica"), findsOneWidget);
      expect(find.textContaining('quoted word for word'), findsOneWidget);
      expect(find.textContaining('translated automatically'), findsNothing);
      final errors = log.take();
      expect(errors, isEmpty, reason: errors.join('\n'));
    } finally {
      log.restore();
    }
  });

  testWidgets('Bangla: says the Bangla was translated automatically (the flag from the database), and names the book in Bangla', (tester) async {
    await open(tester, locale: 'bn');
    expect(find.textContaining('স্বয়ংক্রিয়'), findsWidgets, reason: 'the "translated automatically" note is on the page');
    expect(find.textContaining('ডব্লিউ. বোরিকে'), findsOneWidget);
  });
}
