/// The Student detail level is described as the Education level (Settings and onboarding).
library;

import 'dart:ui' show Locale;

import 'package:flutter_test/flutter_test.dart';

import 'package:homio_essentials/core/l10n/i18n.dart';

import 'helpers/app_harness.dart';
import 'helpers/synthetic_archive.dart';

void main() {
  setUpAll(loadAppFonts);

  test('student descriptions carry the Education keyword (English and Bangla)', () async {
    final en = await L.delegate.load(const Locale('en'));
    final bn = await L.delegate.load(const Locale('bn'));
    expect(en.roleStudentDesc, startsWith('Education: '));
    expect(en.modeNote('student'), startsWith('Education: '));
    expect(bn.roleStudentDesc, startsWith('শিক্ষা: '));
    expect(bn.modeNote('student'), startsWith('শিক্ষা: '));
    // The other levels are unchanged.
    expect(en.modeNote('general'), isNot(contains('Education')));
  });

  testWidgets('Settings shows the Education description under the Student level', (tester) async {
    final app = await pumpApp(tester, buildSyntheticArchive());
    app.go('/settings');
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('Education: adds Materia Medica, keynotes and related remedies.'), findsOneWidget);
  });
}
