/// Home › Learn the basics: a swipeable slider with a page indicator.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'package:homio_essentials/features/home/presentation/widgets/learn_slider.dart';

import 'helpers/app_harness.dart';
import 'helpers/synthetic_archive.dart';

void main() {
  setUpAll(loadAppFonts);

  Finder dots() => find.descendant(of: find.byType(LearnSlider), matching: find.byWidgetPredicate((w) => w is AnimatedContainer && w.constraints?.maxHeight == 7));
  List<double> dotWidths(WidgetTester t) => [for (final d in dots().evaluate()) (d.widget as AnimatedContainer).constraints!.maxWidth];
  int active(WidgetTester t) => dotWidths(t).indexWhere((w) => w > 10);

  Future<void> showSlider(WidgetTester tester) async {
    await tester.scrollUntilVisible(find.byType(LearnSlider), 300, scrollable: find.descendant(of: find.byType(CustomScrollView), matching: find.byType(Scrollable)).first);
    await tester.pump(const Duration(milliseconds: 400));
  }

  Future<void> settle(WidgetTester t) async {
    await t.pump();
    await t.pump(const Duration(milliseconds: 500));
  }

  testWidgets('six topics, one indicator dot each; swiping and tapping dots move the indicator', (tester) async {
    final log = ErrorLog.install();
    try {
      final app = await pumpApp(tester, buildSyntheticArchive());
      app.go('/home');
      await settle(tester);
      await showSlider(tester);

      expect(dots(), findsNWidgets(6));
      expect(active(tester), 0);
      expect(find.textContaining('Potency, dilution and dose'), findsWidgets, reason: 'the first topic is on screen');

      // Swipe to the next topic.
      await tester.drag(find.byType(PageView), const Offset(-260, 0));
      await settle(tester);
      expect(active(tester), 1);
      expect(find.text('How to take pellets'), findsWidgets);

      // The active dot stretches into a pill; the others stay small.
      final widths = dotWidths(tester);
      expect(widths.where((w) => w > 10), hasLength(1));

      // Tap the 5th dot: jumps there.
      await tester.tap(dots().at(4));
      await settle(tester);
      expect(active(tester), 4);
      expect(find.text('Search like a pro'), findsWidgets);

      // Back with a swipe.
      await tester.drag(find.byType(PageView), const Offset(260, 0));
      await settle(tester);
      expect(active(tester), 3);

      final errors = log.take();
      expect(errors, isEmpty, reason: errors.join('\n'));
    } finally {
      log.restore();
    }
  });

  for (final (locale, scale) in [('en', 1.3), ('bn', 1.3), ('bn', 1.0)]) {
    testWidgets('every topic card fits (no overflow) on a 360x640 phone [$locale ×$scale]', (tester) async {
      final log = ErrorLog.install();
      try {
        final app = await pumpApp(tester, buildSyntheticArchive(), locale: locale, textScale: scale, size: const Size(360, 640));
        app.go('/home');
        await settle(tester);
        await showSlider(tester);
        for (var i = 0; i < 5; i++) {
          await tester.drag(find.byType(PageView), const Offset(-240, 0));
          await settle(tester);
        }
        expect(active(tester), 5);
        final errors = log.take();
        expect(errors, isEmpty, reason: errors.join('\n'));
      } finally {
        log.restore();
      }
    });
  }
}
