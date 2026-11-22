/// Android back at a tab root: another tab → Home; Home → "Exit the app?" with Cancel / Exit.
library;

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart' show BorderRadius, Container, RoundedRectangleBorder, Text, TextAlign;
import 'package:material_ui/material_ui.dart' show FilledButton, Icons, Material, TextButton;

import 'package:homio_essentials/core/widgets/hm_dialog.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/app_harness.dart';
import 'helpers/synthetic_archive.dart';

void main() {
  setUpAll(loadAppFonts);

  /// Records `SystemNavigator.pop` (what actually closes the app) instead of closing the test.
  int Function() recordAppExit(WidgetTester tester) {
    var exits = 0;
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform, (call) async {
      if (call.method == 'SystemNavigator.pop') exits++;
      return null;
    });
    addTearDown(() => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform, null));
    return () => exits;
  }

  /// Two pumps: the first starts the route animation, the second runs it to the end.
  Future<void> settle(WidgetTester tester) async {
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
  }

  Future<void> back(WidgetTester tester) async {
    await tester.binding.handlePopRoute();
    await settle(tester);
  }

  testWidgets('back on Home asks first; Cancel keeps the app open, Exit closes it', (tester) async {
    final log = ErrorLog.install();
    try {
      final exits = recordAppExit(tester);
      final app = await pumpApp(tester, buildSyntheticArchive());
      app.go('/home');
      await tester.pump(const Duration(milliseconds: 400));

      await back(tester);
      expect(find.text('Exit Homiopedia?'), findsOneWidget);
      expect(find.text('Do you want to close the app?'), findsOneWidget);
      expect(exits(), 0, reason: 'nothing closes before the person answers');

      await tester.tap(find.text('Stay'));
      await settle(tester);
      expect(find.text('Exit Homiopedia?'), findsNothing);
      expect(exits(), 0);
      expect(find.text('Browse the archive'), findsOneWidget, reason: 'still on Home');

      await back(tester);
      expect(find.text('Exit Homiopedia?'), findsOneWidget, reason: 'asks again next time');
      await tester.tap(find.text('Exit'));
      await settle(tester);
      expect(exits(), 1);

      final errors = log.take();
      expect(errors, isEmpty, reason: errors.join('\n'));
    } finally {
      log.restore();
    }
  });

  testWidgets('the dialog looks like FocusFlow dialogs: ringed icon, centred text, stacked full-width Exit then Stay, 30 dp card', (tester) async {
    recordAppExit(tester);
    final app = await pumpApp(tester, buildSyntheticArchive());
    app.go('/home');
    await tester.pump(const Duration(milliseconds: 400));
    await back(tester);

    final dialog = find.byType(HmDialog);
    expect(dialog, findsOneWidget);
    // 30 dp rounded card, at most 340 dp wide, centred on screen.
    final card = tester.widget<Material>(find.descendant(of: dialog, matching: find.byType(Material)).first);
    expect((card.shape! as RoundedRectangleBorder).borderRadius, BorderRadius.circular(30));
    final box = tester.getRect(find.descendant(of: dialog, matching: find.byType(Material)).first);
    expect(box.width, lessThanOrEqualTo(340));
    expect(box.center.dx, closeTo(195, 1), reason: 'centred horizontally on a 390 dp screen');
    // The ringed icon (80 dp ring around a 64 dp disc) sits above the title.
    expect(find.descendant(of: dialog, matching: find.byIcon(Icons.logout_rounded)), findsOneWidget);
    final ringTop = tester.getTopLeft(find.byWidgetPredicate((w) => w is Container && w.constraints?.maxWidth == 80 && w.constraints?.maxHeight == 80)).dy;
    final titleTop = tester.getTopLeft(find.text('Exit Homiopedia?')).dy;
    expect(ringTop, lessThan(titleTop));
    // Title and message are centred.
    expect(tester.widget<Text>(find.text('Exit Homiopedia?')).textAlign, TextAlign.center);
    expect(tester.widget<Text>(find.text('Do you want to close the app?')).textAlign, TextAlign.center);
    // Actions are stacked (Exit above Stay) and both span the dialog's content width.
    final exit = tester.getRect(find.widgetWithText(FilledButton, 'Exit'));
    final stay = tester.getRect(find.widgetWithText(TextButton, 'Stay'));
    expect(exit.top, lessThan(stay.top));
    expect(exit.width, closeTo(stay.width, 0.5));
    expect(exit.width, closeTo(box.width - 48, 1), reason: 'full width inside the 24 dp padding');
  });

  testWidgets('back on another tab goes Home first (no dialog); a second back asks', (tester) async {
    final exits = recordAppExit(tester);
    final app = await pumpApp(tester, buildSyntheticArchive());
    app.go('/settings');
    await tester.pump(const Duration(milliseconds: 400));

    await back(tester);
    expect(find.text('Exit Homiopedia?'), findsNothing);
    expect(find.text('Browse the archive'), findsOneWidget, reason: 'back from Settings lands on Home');

    await back(tester);
    expect(find.text('Exit Homiopedia?'), findsOneWidget);
    expect(exits(), 0);
  });

  testWidgets('back inside a remedy page just returns to the list: no exit question', (tester) async {
    recordAppExit(tester);
    final app = await pumpApp(tester, buildSyntheticArchive());
    app.go('/home');
    await tester.pump(const Duration(milliseconds: 400));
    app.router.push('/remedy/arnica-montana');
    await tester.pump(const Duration(milliseconds: 600));

    await back(tester);
    expect(find.text('Exit Homiopedia?'), findsNothing);
    expect(find.text('Browse the archive'), findsOneWidget);
  });

  testWidgets('the exit dialog is in Bangla in Bangla mode', (tester) async {
    recordAppExit(tester);
    final app = await pumpApp(tester, buildSyntheticArchive(), locale: 'bn');
    app.go('/home');
    await tester.pump(const Duration(milliseconds: 400));
    await back(tester);
    expect(find.text('হোমিওপিডিয়া থেকে বের হবেন?'), findsOneWidget);
    expect(find.text('আপনি কি অ্যাপটি বন্ধ করতে চান?'), findsOneWidget);
    expect(find.text('বের হন'), findsOneWidget);
    expect(find.text('থাকুন'), findsOneWidget);
  });
}
