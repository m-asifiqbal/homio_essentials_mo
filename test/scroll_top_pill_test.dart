/// The back-to-top pill: bottom of the list, 6 dp above the bar, after 15 items.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'package:homio_essentials/core/l10n/i18n.dart';
import 'package:homio_essentials/core/theme/tokens.dart';
import 'package:homio_essentials/core/widgets/hm_scroll_top_pill.dart';

const _itemExtent = 50.0;
const _barHeight = 60.0;

/// A 100-item list above a stand-in 60 dp bar, exactly how the tab screens are laid out.
Widget _app({required ScrollController? external}) => MaterialApp(
      locale: const Locale('en'),
      localizationsDelegates: L.localizationsDelegates,
      supportedLocales: L.supportedLocales,
      theme: ThemeData(extensions: [HomaColors.of(dark: false, accent: 'teal')]),
      home: Scaffold(
        body: Column(children: [
          Expanded(
            child: HmScrollTopHost(
              itemExtent: _itemExtent,
              builder: (context, scroll) => ListView.builder(controller: scroll, itemExtent: _itemExtent, itemCount: 100, itemBuilder: (_, i) => Text('Item $i')),
            ),
          ),
          Container(height: _barHeight, color: const Color(0xFF123456)), // the bottom bar
        ]),
      ),
    );

void main() {
  Finder pillText() => find.text('Back to top');
  double opacity(WidgetTester t) => t.widget<AnimatedOpacity>(find.ancestor(of: pillText(), matching: find.byType(AnimatedOpacity)).first).opacity;
  ScrollController controller(WidgetTester t) => t.widget<ListView>(find.byType(ListView)).controller!;
  // One frame to rebuild with the new target, a second to run the slide / fade to its end.
  Future<void> settle(WidgetTester t) async {
    await t.pump();
    await t.pump(const Duration(milliseconds: 600));
  }

  testWidgets('hidden for the first 15 items, shown after them', (tester) async {
    await tester.pumpWidget(_app(external: null));
    expect(opacity(tester), 0);

    // Scroll 14 items (700 dp) and let go: still hidden.
    controller(tester).jumpTo(14 * _itemExtent);
    await settle(tester);
    expect(opacity(tester), 0, reason: 'only 14 items scrolled through');

    // 16 items: shown.
    controller(tester).jumpTo(16 * _itemExtent);
    await settle(tester);
    expect(opacity(tester), 1, reason: '16 items scrolled through');
  });

  testWidgets('sits 6 dp above the bar, centred', (tester) async {
    await tester.pumpWidget(_app(external: null));
    controller(tester).jumpTo(20 * _itemExtent);
    await settle(tester);
    final screen = tester.getSize(find.byType(Scaffold));
    // The pill itself: the Material with the stadium (capsule) shape.
    final pill = tester.getRect(find.ancestor(of: pillText(), matching: find.byWidgetPredicate((w) => w is Material && w.shape is StadiumBorder)).first);
    final barTop = screen.height - _barHeight;
    expect(barTop - pill.bottom, closeTo(6, 0.6), reason: 'gap between the pill and the bar');
    expect(pill.center.dx, closeTo(screen.width / 2, 1));
  });

  testWidgets('hides while the user scrolls down, returns when they stop or scroll up; tapping goes to the top', (tester) async {
    await tester.pumpWidget(_app(external: null));
    controller(tester).jumpTo(30 * _itemExtent);
    await settle(tester);
    expect(opacity(tester), 1);

    // Finger moves UP the screen = scrolling DOWN the list: the pill steps out of the way.
    final gesture = await tester.startGesture(const Offset(200, 400));
    await gesture.moveBy(const Offset(0, -80));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(opacity(tester), 0, reason: 'scrolling down');
    // Finger moves DOWN = scrolling back up: it returns.
    await gesture.moveBy(const Offset(0, 200));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(opacity(tester), 1, reason: 'scrolling up');
    await gesture.up();
    await settle(tester);
    expect(opacity(tester), 1, reason: 'resting after scrolling up');

    await tester.tap(pillText());
    await tester.pump(); // starts the 450 ms scroll animation
    await tester.pump(const Duration(milliseconds: 900));
    expect(controller(tester).offset, 0);
    await settle(tester);
    expect(opacity(tester), 0, reason: 'at the top the pill goes away');
  });
}
