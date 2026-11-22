/// What a person sees while the app talks to the server: the loader (with progress, a slow-connection hint and
/// Retry), a typed error per kind of failure, the "can't reach the server" banner, and the inline error for book text.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart' show CircularProgressIndicator, LinearProgressIndicator;

import 'package:homio_essentials/core/network/api_exception.dart';
import 'package:homio_essentials/core/widgets/hm_feedback.dart';
import 'package:homio_essentials/features/home/presentation/widgets/home_sections.dart';
import 'package:homio_essentials/shared/providers/archive_provider.dart';

import 'helpers/app_harness.dart';
import 'helpers/synthetic_archive.dart';

void main() {
  setUpAll(loadAppFonts);

  const slow = 'Still loading — your connection looks slow.';

  Future<void> frames(WidgetTester t, [int ms = 400]) async {
    await t.pump();
    await t.pump(Duration(milliseconds: ms));
  }

  group('loading is always a shimmer skeleton', () {
    Future<AppHarness> loadingApp(WidgetTester tester, {String locale = 'en'}) =>
        pumpApp(tester, buildSyntheticArchive(), locale: locale, controller: () => LoadingArchiveController(buildSyntheticArchive()));

    testWidgets('every screen shimmers while the archive loads: no spinner, no progress bar', (tester) async {
      final log = ErrorLog.install();
      try {
        final app = await loadingApp(tester);
        for (final path in ['/home', '/explore', '/saved', '/search', '/data', '/remedy/arnica-montana', '/condition/injury']) {
          app.go(path);
          await frames(tester);
          expect(find.byType(HmSkeleton), findsWidgets, reason: '$path shows shimmer placeholders');
          expect(find.byType(LinearProgressIndicator), findsNothing, reason: '$path has no progress bar');
          expect(find.byType(CircularProgressIndicator), findsNothing, reason: '$path has no spinner');
          expect(find.text('Loading the latest remedies…'), findsNothing, reason: '$path has no second loader message');
        }
        final errors = log.take();
        expect(errors, isEmpty, reason: errors.join('\n'));
      } finally {
        log.restore();
      }
    });

    testWidgets('Home: silent at first, a hint on a slow connection, Try again after a long wait', (tester) async {
      LoadingArchiveController.builds = 0;
      final app = await loadingApp(tester);
      app.go('/home');
      await frames(tester);

      expect(find.byType(HomeSkeleton), findsOneWidget);
      expect(find.text(slow), findsNothing);
      await tester.pump(const Duration(seconds: 9));
      expect(find.text(slow), findsOneWidget);
      expect(find.text('Try again'), findsNothing, reason: 'Retry only appears when it is taking very long');

      await tester.pump(const Duration(seconds: 12));
      expect(find.text('Try again'), findsOneWidget);
      final before = LoadingArchiveController.builds;
      await tester.tap(find.text('Try again'));
      await frames(tester);
      expect(LoadingArchiveController.builds, before + 1, reason: 'Retry starts the download again');
    });

    testWidgets('the hint is Bangla in Bangla mode', (tester) async {
      final app = await loadingApp(tester, locale: 'bn');
      app.go('/home');
      await frames(tester);
      await tester.pump(const Duration(seconds: 9));
      expect(find.text('এখনও লোড হচ্ছে — আপনার সংযোগ ধীর মনে হচ্ছে।'), findsOneWidget);
    });
  });

  group('typed errors', () {
    final cases = <(String, ApiException, String, String)>[
      ('offline', const ApiException(ApiErrorKind.offline), 'No internet connection', 'Connect to Wi-Fi or mobile data, then try again.'),
      ('timeout', const ApiException(ApiErrorKind.timeout), 'Connection is too slow', 'The server took too long to answer. Check your signal and try again.'),
      ('server', const ApiException(ApiErrorKind.server, 'boom', 503), 'Server problem', 'Something went wrong on our side. Please try again in a moment.'),
      ('unknown', const ApiException(ApiErrorKind.unknown, 'weird'), 'Something went wrong', "We couldn't load this. Please try again."),
    ];

    for (final (name, error, title, body) in cases) {
      testWidgets('Home when the first load fails: $name', (tester) async {
        final log = ErrorLog.install();
        try {
          final app = await pumpApp(tester, buildSyntheticArchive(), controller: () => FlakyArchiveController(buildSyntheticArchive(), error, failures: 99));
          app.go('/home');
          await frames(tester);
          expect(find.text(title), findsOneWidget);
          expect(find.text(body), findsOneWidget);
          expect(find.text('Try again'), findsOneWidget);
          if (error.statusCode != null) expect(find.text('Error code: ${error.statusCode}'), findsOneWidget);
          expect(find.byType(HomeSkeleton), findsNothing);
          final errors = log.take();
          expect(errors, isEmpty, reason: errors.join('\n'));
        } finally {
          log.restore();
        }
      });
    }

    testWidgets('error text is Bangla in Bangla mode', (tester) async {
      final app = await pumpApp(tester, buildSyntheticArchive(), locale: 'bn',
          controller: () => FlakyArchiveController(buildSyntheticArchive(), const ApiException(ApiErrorKind.offline), failures: 99));
      app.go('/home');
      await frames(tester);
      expect(find.text('ইন্টারনেট সংযোগ নেই'), findsOneWidget);
      expect(find.text('ওয়াই-ফাই বা মোবাইল ডেটা চালু করে আবার চেষ্টা করুন।'), findsOneWidget);
    });

    testWidgets('Try again reloads and the screen fills in', (tester) async {
      FlakyArchiveController.builds = 0;
      final app = await pumpApp(tester, buildSyntheticArchive(), controller: () => FlakyArchiveController(buildSyntheticArchive(), const ApiException(ApiErrorKind.offline)));
      app.go('/home');
      await frames(tester);
      expect(find.text('No internet connection'), findsOneWidget);

      await tester.tap(find.text('Try again'));
      await frames(tester, 600);
      expect(FlakyArchiveController.builds, 2);
      expect(find.text('No internet connection'), findsNothing);
      expect(find.text('Browse the archive'), findsOneWidget, reason: 'the Home content is here');
    });

    testWidgets('other screens show the same typed error: Saved, Explore, a remedy page (with a back arrow)', (tester) async {
      final log = ErrorLog.install();
      try {
        final app = await pumpApp(tester, buildSyntheticArchive(),
            controller: () => FlakyArchiveController(buildSyntheticArchive(), const ApiException(ApiErrorKind.timeout), failures: 99));
        for (final path in ['/saved', '/explore', '/remedy/arnica-montana', '/condition/injury']) {
          app.go(path);
          await frames(tester);
          expect(find.text('Connection is too slow'), findsOneWidget, reason: path);
          expect(find.text('Try again'), findsOneWidget, reason: path);
        }
        app.go('/remedy/arnica-montana');
        await frames(tester);
        expect(find.byTooltip('Back'), findsOneWidget, reason: 'a remedy page must not be a dead end while loading or failing');
        final errors = log.take();
        expect(errors, isEmpty, reason: errors.join('\n'));
      } finally {
        log.restore();
      }
    });
  });

  group('banner', () {
    testWidgets('appears when the server can\'t be reached, hides again, and a tap forces a refresh', (tester) async {
      final app = await pumpApp(tester, buildSyntheticArchive());
      app.go('/home');
      await frames(tester);
      const banner = "Can't reach the server — showing what's already loaded. Tap to retry.";
      expect(find.text(banner), findsNothing);

      app.container.read(syncStateProvider.notifier).set(SyncState.offline);
      await frames(tester);
      expect(find.text(banner), findsOneWidget);
      expect(find.text('Browse the archive'), findsOneWidget, reason: 'the loaded data stays on screen');

      await tester.tap(find.text(banner));
      await frames(tester);
      expect((app.container.read(archiveProvider.notifier) as FakeArchiveController).refreshCalls, [true]);

      app.container.read(syncStateProvider.notifier).set(SyncState.idle);
      await frames(tester);
      expect(find.text(banner), findsNothing);
    });
  });

  group('book text (loaded from the server per remedy)', () {
    testWidgets('failure shows an inline typed error with Try again; retrying loads the text', (tester) async {
      final log = ErrorLog.install();
      try {
        var calls = 0;
        final app = await pumpApp(tester, buildSyntheticArchive(), materiaLoader: (id) async {
          if (calls++ == 0) throw const ApiException(ApiErrorKind.offline);
          return syntheticMateria()[id] ?? const [];
        });
        app.go('/remedy/arnica-montana?tab=study');
        for (var i = 0; i < 12; i++) {
          await tester.pump(const Duration(milliseconds: 150));
        }
        expect(find.text('No internet connection'), findsOneWidget);
        await tester.ensureVisible(find.text('Try again'));
        await tester.tap(find.text('Try again'));
        for (var i = 0; i < 8; i++) {
          await tester.pump(const Duration(milliseconds: 150));
        }
        expect(calls, 2);
        expect(find.text('No internet connection'), findsNothing);
        expect(find.textContaining('Boericke on Overview'), findsWidgets);
        final errors = log.take();
        expect(errors, isEmpty, reason: errors.join('\n'));
      } finally {
        log.restore();
      }
    });
  });
}
