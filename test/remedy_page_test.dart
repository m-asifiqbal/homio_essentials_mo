/// The medicine details page: sticky index chips, jump landing, scroll-spy and empty sections.
library;

import 'package:material_ui/material_ui.dart' show IconButton, Icons, SliverAppBar;
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:homio_essentials/core/theme/tokens.dart';
import 'package:homio_essentials/core/widgets/hm_card.dart';
import 'package:homio_essentials/core/widgets/hm_feedback.dart';
import 'package:homio_essentials/features/remedy/presentation/widgets/remedy_section.dart';

import 'helpers/app_harness.dart';
import 'helpers/synthetic_archive.dart';

void main() {
  setUpAll(loadAppFonts);

  final selectedColor = HomaColors.of(dark: false, accent: 'teal').p;
  // Pinned bars: app bar (56) + index bar (50), no status-bar inset in tests.
  const pinnedBottom = 56.0 + 50.0;
  const landing = pinnedBottom + 10;

  Finder indexBar() => find.byWidgetPredicate((w) => w is SingleChildScrollView && w.scrollDirection == Axis.horizontal).first;
  Finder chip(String title) => find.descendant(of: indexBar(), matching: find.text(title));
  Finder card(String id) => find.byWidgetPredicate((w) => w is RemedySectionCard && w.spec.id == id);

  bool isSelected(WidgetTester tester, String title) {
    final box = tester.widget<AnimatedContainer>(find.ancestor(of: chip(title), matching: find.byType(AnimatedContainer)).first);
    return (box.decoration as BoxDecoration).color == selectedColor;
  }

  ScrollController pageController(WidgetTester tester) => tester.widget<CustomScrollView>(find.byType(CustomScrollView)).controller!;

  Future<void> settle(WidgetTester tester, {int ms = 1600}) async {
    for (var t = 0; t < ms; t += 100) {
      await tester.pump(const Duration(milliseconds: 100));
    }
  }

  /// Taps a chip like a person: if it is scrolled out of view in the chip row, swipe the row first.
  Future<void> tapChip(WidgetTester tester, String title) async {
    for (var i = 0; i < 6; i++) {
      final x = tester.getCenter(chip(title)).dx;
      if (x > 20 && x < 370) break;
      await tester.drag(indexBar(), Offset(x > 370 ? -240 : 240, 0));
      await tester.pump(const Duration(milliseconds: 300));
    }
    await tester.tap(chip(title));
  }

  /// Runs [body] with every framework error captured, ALWAYS restoring the handler (a failed expect must not
  /// leave flutter_test with a replaced FlutterError.onError).
  Future<void> guarded(WidgetTester tester, Future<void> Function() body) async {
    final log = ErrorLog.install();
    try {
      await body();
      final errors = log.take();
      expect(errors, isEmpty, reason: errors.join('\n'));
    } finally {
      log.restore();
    }
  }

  bool landedUnderBars(WidgetTester tester, String id) {
    final c = pageController(tester);
    final top = tester.getTopLeft(card(id)).dy;
    final atEnd = c.offset >= c.position.maxScrollExtent - 1;
    return (top - landing).abs() <= 6 || (atEnd && top > pinnedBottom);
  }

  const titles = {
    'uses': 'Indications',
    'dosage': 'Dosage & administration',
    'keynotes': 'Keynotes',
    'safety': 'Safety & precautions',
    'relations': 'Relationships',
    'brands': 'Available brands',
    'materia': 'Materia Medica',
    'sources': 'Sources & review',
  };

  Future<void> openArnica(WidgetTester tester) async {
    final app = await pumpApp(tester, buildSyntheticArchive(), materia: syntheticMateria());
    app.go('/remedy/arnica-montana');
    await settle(tester, ms: 600);
  }

  testWidgets('tapping each index chip lands that section under the bars and highlights its chip', (tester) => guarded(tester, () async {
        await openArnica(tester);
        final failures = <String>[];
        for (final e in titles.entries) {
          await tapChip(tester, e.value);
          await settle(tester);
          if (!landedUnderBars(tester, e.key)) failures.add('${e.key}: card top ${tester.getTopLeft(card(e.key)).dy}, wanted ~$landing');
          if (!isSelected(tester, e.value)) failures.add('${e.key}: chip not highlighted');
        }
        expect(failures, isEmpty, reason: failures.join('\n'));
      }));

  testWidgets('jumping far down and back up repeatedly stays exact (no drift, no flash)', (tester) => guarded(tester, () async {
        await openArnica(tester);
        for (final id in ['materia', 'uses', 'safety', 'dosage', 'materia', 'keynotes', 'sources', 'uses']) {
          await tapChip(tester, titles[id]!);
          await settle(tester);
          expect(landedUnderBars(tester, id), isTrue, reason: '$id landed at ${tester.getTopLeft(card(id)).dy}');
          expect(isSelected(tester, titles[id]!), isTrue, reason: '$id chip highlighted');
        }
      }));

  testWidgets('fast taps on several chips end on the LAST one tapped', (tester) => guarded(tester, () async {
        await openArnica(tester);
        for (final id in ['dosage', 'keynotes', 'safety', 'relations']) {
          await tapChip(tester, titles[id]!);
          await tester.pump(const Duration(milliseconds: 90)); // before the previous jump has finished
        }
        await settle(tester, ms: 2200);
        expect(landedUnderBars(tester, 'relations'), isTrue, reason: 'relations at ${tester.getTopLeft(card('relations')).dy}');
        expect(isSelected(tester, titles['relations']!), isTrue);
        for (final other in ['dosage', 'keynotes', 'safety']) {
          expect(isSelected(tester, titles[other]!), isFalse, reason: '$other must not stay highlighted');
        }
      }));

  testWidgets('scrolling by hand moves the highlighted chip (scroll-spy) without moving the page by itself', (tester) => guarded(tester, () async {
        await openArnica(tester);
        expect(isSelected(tester, 'Overview'), isTrue);

        // The Overview card alone is ~900 px tall, so scroll well past it, into the Dosage / Keynotes area.
        await tester.drag(find.byType(CustomScrollView), const Offset(0, -1500));
        await settle(tester, ms: 900);
        expect(isSelected(tester, 'Overview'), isFalse, reason: 'after scrolling past the Overview card, another chip is highlighted');

        // Scroll-spy only moves the CHIP ROW: with no touch the page must not move.
        final before = pageController(tester).offset;
        await settle(tester, ms: 900);
        expect(pageController(tester).offset, before);

        await tester.drag(find.byType(CustomScrollView), const Offset(0, 4000));
        await settle(tester, ms: 1200);
        expect(isSelected(tester, 'Overview'), isTrue);
      }));

  testWidgets('a chip tap right after a manual scroll still lands exactly', (tester) => guarded(tester, () async {
        await openArnica(tester);
        await tester.drag(find.byType(CustomScrollView), const Offset(0, -500));
        await tester.pump(const Duration(milliseconds: 80)); // still flinging
        await tapChip(tester, titles['safety']!);
        await settle(tester, ms: 2000);
        expect(landedUnderBars(tester, 'safety'), isTrue, reason: 'safety at ${tester.getTopLeft(card('safety')).dy}');
        expect(isSelected(tester, titles['safety']!), isTrue);
      }));

  testWidgets('the toolbar is native Material: plain icons (no rounded backgrounds), back arrow 16 dp from the edge', (tester) => guarded(tester, () async {
        await openArnica(tester);
        // Scoped to the app bar: the bottom Save button also shows a bookmark icon.
        Finder inBar(IconData icon) => find.descendant(of: find.byType(SliverAppBar), matching: find.byIcon(icon));
        for (final icon in [Icons.arrow_back_rounded, Icons.ios_share_rounded, Icons.bookmark_border_rounded]) {
          final button = find.ancestor(of: inBar(icon), matching: find.byType(IconButton));
          expect(button, findsOneWidget, reason: '$icon is an IconButton');
          // A 48 dp touch target…
          final size = tester.getSize(button);
          expect(size.width >= 48 && size.height >= 48, isTrue, reason: '$icon target is $size');
          // …with nothing rounded drawn behind the glyph.
          final rounded = find.descendant(
            of: button,
            matching: find.byWidgetPredicate((w) => w is DecoratedBox && w.decoration is BoxDecoration && (w.decoration as BoxDecoration).borderRadius != null),
          );
          expect(rounded, findsNothing, reason: '$icon has no rounded background');
        }
        // Material spec: the back arrow glyph sits 16 dp from the screen edge (it used to be ~11 dp inside a 42 dp frosted square).
        final backLeft = tester.getTopLeft(inBar(Icons.arrow_back_rounded)).dx;
        expect(backLeft, closeTo(16, 1.5), reason: 'back arrow left edge');
        // The trailing icon keeps the standard 12 dp margin to the right edge.
        final saveRight = tester.getTopRight(inBar(Icons.bookmark_border_rounded)).dx;
        expect(390 - saveRight, closeTo(12, 1.5), reason: 'save icon right margin');
      }));

  testWidgets('cards sit 3 dp closer to the screen edges, and nested cards 2.5 dp closer to their parent (13 / 13.5 dp)', (tester) => guarded(tester, () async {
        final app = await pumpApp(tester, buildSyntheticArchive());
        app.go('/remedy/arnica-montana');
        await settle(tester, ms: 800);

        // Section cards: 16 → 13 dp from each screen edge (390 dp wide screen).
        for (final id in ['overview', 'uses']) {
          final rect = tester.getRect(card(id));
          expect(rect.left, closeTo(13, 0.01), reason: '$id card left edge');
          expect(390 - rect.right, closeTo(13, 0.01), reason: '$id card right edge');
        }
        // Nested card inside the Uses section: 16 → 13.5 dp from its parent card's edges.
        final parent = tester.getRect(card('uses'));
        final nested = tester.getRect(find.descendant(of: card('uses'), matching: find.byType(HmCard)).first);
        expect(nested.left - parent.left, closeTo(13.5, 0.01), reason: 'nested card left inset');
        expect(parent.right - nested.right, closeTo(13.5, 0.01), reason: 'nested card right inset');
      }));

  testWidgets('a remedy with no data lists every section with an empty state (icon + message), and nothing throws', (tester) => guarded(tester, () async {
        final app = await pumpApp(tester, buildSyntheticArchive(), materia: const {});
        app.go('/remedy/bare-remedy');
        await settle(tester, ms: 600);
        await tester.tap(find.byIcon(Icons.unfold_more_rounded));
        await settle(tester, ms: 1200);
        for (final id in ['uses', 'keynotes', 'relations', 'brands', 'materia']) {
          expect(card(id), findsOneWidget, reason: '$id section is still listed');
          expect(find.descendant(of: card(id), matching: find.byType(SectionEmpty)), findsOneWidget, reason: '$id shows an empty state');
        }
      }));
}
