/// The app works online only: with no connection the whole app is replaced by the no-internet page, and it
/// comes back by itself. Covers the View (ConnectionGate), the ViewModel (ConnectionController), the
/// repository (ConnectionRepositoryImpl over Dio) and the Dio interceptor.
library;

import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart' show AppLifecycleState, SizedBox;
import 'package:flutter_test/flutter_test.dart';

import 'package:homio_essentials/core/connection/data/repository/connection_repository_impl.dart';
import 'package:homio_essentials/core/network/dio_client.dart';
import 'package:homio_essentials/shared/providers/archive_provider.dart';
import 'package:homio_essentials/shared/providers/connection_provider.dart';

import 'helpers/app_harness.dart';
import 'helpers/fake_supabase.dart';
import 'helpers/synthetic_archive.dart';

void main() {
  setUpAll(loadAppFonts);

  const title = 'No internet connection';
  const body = 'Connect to Wi-Fi or mobile data, then try again.';
  const homeMarker = 'Browse the archive';

  /// Real timing (polls every 20 s online / 3 s offline) but no debounce delay, so fake time stays readable.
  const polling = ConnectionTiming(changeDebounce: Duration.zero);

  Future<void> settle(WidgetTester t, [int ms = 300]) async {
    await t.pump();
    await t.pump(Duration(milliseconds: ms));
  }

  /// Unmounts the app and disposes its providers, so the controller's poll timer is gone before flutter_test
  /// checks for pending timers.
  Future<void> shutDown(WidgetTester t, AppHarness app) async {
    await t.pumpWidget(const SizedBox());
    app.container.dispose();
  }

  Future<void> seconds(WidgetTester t, int n) async {
    for (var i = 0; i < n; i++) {
      await t.pump(const Duration(seconds: 1));
    }
  }

  group('gate + ViewModel in the real app', () {
    testWidgets('online: the app is shown and nothing about the connection is', (tester) async {
      final app = await pumpApp(tester, buildSyntheticArchive());
      app.go('/home');
      await settle(tester);
      expect(find.text(homeMarker), findsOneWidget);
      expect(find.text(title), findsNothing);
    });

    testWidgets('network off → the whole app is replaced by the no-internet page; data is NOT shown', (tester) async {
      final log = ErrorLog.install();
      try {
        final app = await pumpApp(tester, buildSyntheticArchive());
        app.go('/home');
        await settle(tester);
        expect(find.text(homeMarker), findsOneWidget);

        app.connection.setNetwork(false);
        await settle(tester);
        expect(find.text(title), findsOneWidget);
        expect(find.text(body), findsOneWidget);
        expect(find.textContaining('works online only'), findsOneWidget);
        expect(find.text('Try again'), findsOneWidget);
        expect(find.text(homeMarker), findsNothing, reason: 'the remedies must not stay visible while offline');
        expect(find.text('Aconitum'), findsNothing);

        final errors = log.take();
        expect(errors, isEmpty, reason: errors.join('\n'));
      } finally {
        log.restore();
      }
    });

    testWidgets('network back → the page returns exactly where it was and the archive is refreshed', (tester) async {
      final app = await pumpApp(tester, buildSyntheticArchive());
      app.go('/home');
      await settle(tester);
      app.connection.setNetwork(false);
      await settle(tester);
      expect(find.text(title), findsOneWidget);

      app.connection.setNetwork(true);
      await settle(tester);
      expect(find.text(title), findsNothing);
      expect(find.text(homeMarker), findsOneWidget);
      expect((app.container.read(archiveProvider.notifier) as FakeArchiveController).refreshCalls, [false],
          reason: 'coming back online checks the server for new data (one signature request, not a forced download)');
    });

    testWidgets('it covers pushed pages too, and brings the same page back', (tester) async {
      final app = await pumpApp(tester, buildSyntheticArchive());
      app.go('/home');
      await settle(tester);
      app.router.push('/remedy/arnica-montana');
      await settle(tester, 700);
      expect(find.text('Arnica montana'), findsWidgets);

      app.connection.setNetwork(false);
      await settle(tester);
      expect(find.text(title), findsOneWidget);
      expect(find.text('Arnica montana'), findsNothing, reason: 'a remedy page is hidden too');

      app.connection.setNetwork(true);
      await settle(tester);
      expect(find.text(title), findsNothing);
      expect(find.text('Arnica montana'), findsWidgets, reason: 'the person is back on the remedy page');
    });

    testWidgets('Android back while offline does nothing behind the page; online it asks to exit as before', (tester) async {
      var exits = 0;
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform, (call) async {
        if (call.method == 'SystemNavigator.pop') exits++;
        return null;
      });
      addTearDown(() => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform, null));
      final app = await pumpApp(tester, buildSyntheticArchive());
      app.go('/home');
      await settle(tester);
      app.connection.setNetwork(false);
      await settle(tester);

      final handled = await tester.binding.handlePopRoute();
      await settle(tester);
      expect(handled, isTrue);
      expect(find.text('Exit Homiopedia?'), findsNothing, reason: 'no invisible dialog behind the offline page');
      expect(exits, 0);

      app.connection.setNetwork(true);
      await settle(tester);
      await tester.binding.handlePopRoute();
      await settle(tester);
      expect(find.text('Exit Homiopedia?'), findsOneWidget, reason: 'online again: back works as before');
    });

    testWidgets('Try again: stays on the page while still offline, goes away once the connection is back', (tester) async {
      final app = await pumpApp(tester, buildSyntheticArchive());
      app.go('/home');
      await settle(tester);
      app.connection.setNetwork(false);
      await settle(tester);

      await tester.tap(find.text('Try again'));
      await settle(tester);
      expect(find.text(title), findsOneWidget, reason: 'still offline');
      expect(find.text('Try again'), findsOneWidget, reason: 'the button is back after the check');

      app.connection.network = true; // quietly (no change event): only the button can find out
      await tester.tap(find.text('Try again'));
      await settle(tester);
      expect(find.text(title), findsNothing);
      expect(find.text(homeMarker), findsOneWidget);
    });

    testWidgets('Wi-Fi without internet: two failed probes in a row (about 40 s) → offline; it recovers by itself', (tester) async {
      final app = await pumpApp(tester, buildSyntheticArchive(), timing: polling);
      app.go('/home');
      await settle(tester);
      app.connection.server = false; // the network is "on" but our server doesn't answer

      await seconds(tester, 21);
      expect(find.text(title), findsNothing, reason: 'one failed probe is not enough: a single blip must not black out the app');
      await seconds(tester, 21);
      expect(find.text(title), findsOneWidget, reason: 'the second failure in a row');
      expect(find.text(homeMarker), findsNothing);

      app.connection.server = true;
      await seconds(tester, 4);
      expect(find.text(title), findsNothing, reason: 'offline pages re-check every 3 s and come back on their own');
      expect(find.text(homeMarker), findsOneWidget);
      await shutDown(tester, app);
    });

    testWidgets('a request that failed because of the network + a failing probe → offline at once; a failing request alone → not', (tester) async {
      final app = await pumpApp(tester, buildSyntheticArchive());
      app.go('/home');
      await settle(tester);
      final vm = app.container.read(connectionControllerProvider.notifier);

      vm.onRequestFailed(); // the probe still succeeds
      await settle(tester);
      expect(find.text(title), findsNothing);

      app.connection.server = false;
      await tester.pump(const Duration(seconds: 3)); // past the rate limit between request-triggered checks
      vm.onRequestFailed();
      await settle(tester);
      expect(find.text(title), findsOneWidget);
      await shutDown(tester, app);
    });

    testWidgets('coming back to the app re-checks at once', (tester) async {
      final app = await pumpApp(tester, buildSyntheticArchive());
      app.go('/home');
      await settle(tester);
      app.connection.network = false; // lost while the app was in the background: no event reached it
      for (final s in [AppLifecycleState.inactive, AppLifecycleState.hidden, AppLifecycleState.paused, AppLifecycleState.hidden, AppLifecycleState.inactive, AppLifecycleState.resumed]) {
        tester.binding.handleAppLifecycleStateChanged(s);
      }
      await settle(tester);
      expect(find.text(title), findsOneWidget);
    });

    testWidgets('the no-internet page is Bangla in Bangla mode', (tester) async {
      final app = await pumpApp(tester, buildSyntheticArchive(), locale: 'bn');
      app.go('/home');
      await settle(tester);
      app.connection.setNetwork(false);
      await settle(tester);
      expect(find.text('ইন্টারনেট সংযোগ নেই'), findsOneWidget);
      expect(find.text('ওয়াই-ফাই বা মোবাইল ডেটা চালু করে আবার চেষ্টা করুন।'), findsOneWidget);
    });
  });

  group('repository (a tiny Dio request)', () {
    FakeSupabase server() => FakeSupabase({'app_config': [{'key': 'a', 'value': 1}, {'key': 'b', 'value': 2}]});
    ConnectionRepositoryImpl repoFor(FakeSupabase s) => ConnectionRepositoryImpl(api: s.api());

    test('answers → reachable, with one 1-row, 1-column request', () async {
      final s = server();
      expect(await repoFor(s).serverReachable(), isTrue);
      expect(s.requests, hasLength(1));
      expect(s.requests.single.queryParameters, containsPair('limit', '1'));
      expect(s.requests.single.queryParameters, containsPair('select', 'key'));
    });

    test('no connection / timeout → not reachable', () async {
      expect(await repoFor(server()..offline = true).serverReachable(), isFalse);
      expect(await repoFor(server()..timeout = true).serverReachable(), isFalse);
    });

    test('the server answering with an error still counts as reachable (only a dead connection is offline)', () async {
      expect(await repoFor(server()..failStatus = 503).serverReachable(), isTrue);
      expect(await repoFor(server()..failStatus = 401).serverReachable(), isTrue);
    });
  });

  group('Dio setup', () {
    test('network failures are reported once the error is final; server errors and cancels are not', () async {
      var reports = 0;
      Dio clientFor(FakeSupabase s) => s.dio()..interceptors.add(NetworkErrorInterceptor(() => reports++));
      final tables = {'t': <Map<String, dynamic>>[]};

      await expectLater(clientFor(FakeSupabase(tables)..offline = true).get<dynamic>('t'), throwsA(isA<DioException>()));
      expect(reports, 1, reason: 'no connection');

      await expectLater(clientFor(FakeSupabase(tables)..timeout = true).get<dynamic>('t'), throwsA(isA<DioException>()));
      expect(reports, 2, reason: 'timeout');

      await expectLater(clientFor(FakeSupabase(tables)..failStatus = 500).get<dynamic>('t'), throwsA(isA<DioException>()));
      expect(reports, 2, reason: 'the server ANSWERED: that is not a network failure');

      final token = CancelToken()..cancel();
      await expectLater(clientFor(FakeSupabase(tables)).get<dynamic>('t', cancelToken: token), throwsA(isA<DioException>()));
      expect(reports, 2, reason: 'a request the app cancelled itself is not a network failure');
    });

    test('buildDio: retries are on by default and can be turned off (the probe client)', () {
      const base = 'https://fake.supabase.test/rest/v1/';
      final withRetry = buildDio(baseUrl: base).interceptors.length;
      final probe = buildDio(baseUrl: base, retry: false, connectTimeout: const Duration(seconds: 5), receiveTimeout: const Duration(seconds: 5));
      expect(withRetry - probe.interceptors.length, 1);
      expect(probe.options.connectTimeout, const Duration(seconds: 5));
      expect(buildDio(baseUrl: base, onNetworkError: () {}).interceptors.whereType<NetworkErrorInterceptor>(), hasLength(1));
    });
  });
}
