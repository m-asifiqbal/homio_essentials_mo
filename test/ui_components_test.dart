import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'package:homio_essentials/core/theme/app_text_scaler.dart';
import 'package:homio_essentials/core/theme/tokens.dart';
import 'package:homio_essentials/core/widgets/hm_bottom_nav.dart';
import 'package:homio_essentials/core/widgets/hm_card.dart';
import 'package:homio_essentials/core/widgets/hm_chips.dart';
import 'package:homio_essentials/features/remedy/presentation/widgets/remedy_section.dart';
import 'package:homio_essentials/shared/providers/settings_provider.dart';

Widget host(Widget child) => MaterialApp(
      theme: ThemeData(extensions: [HomaColors.of(dark: false, accent: 'teal')]),
      home: Scaffold(body: child),
    );

void main() {
  group('AppTextScaler', () {
    test('composes the in-app factor on top of the system scaler', () {
      final s = AppTextScaler.compose(const TextScaler.linear(1.2), 0.9);
      expect(s.scale(10), closeTo(10.8, 1e-9));
    });

    test('factor 1 returns the system scaler untouched', () {
      const system = TextScaler.linear(1.3);
      expect(identical(AppTextScaler.compose(system, 1), system), isTrue);
    });

    test('never shrinks below the OS and never grows past 2x on its own', () {
      expect(AppTextScaler.compose(const TextScaler.linear(1.0), 3).scale(10), 20);
      expect(AppTextScaler.compose(const TextScaler.linear(2.5), 1.3).scale(10), 25); // OS already above 2x: untouched
    });
  });

  group('AppSettings text size', () {
    AppSettings with_(double scale) => AppSettings(locale: 'en', role: Role.general, dayNight: DayNight.system, accent: 'teal', textScale: scale, onboarded: true, deviceId: 'x');

    test('default is a notch under 1.0', () => expect(AppSettings.defaultTextScale, lessThan(1)));
    test('maps a saved value to the nearest stop', () {
      expect(with_(0.85).textScaleIndex, 0);
      expect(with_(AppSettings.defaultTextScale).textScaleIndex, 2);
      expect(with_(1.3).textScaleIndex, AppSettings.textScaleStops.length - 1);
      expect(with_(1.12).textScaleIndex, 4); // 1.15 is the closest stop
    });
    test('hide-bar-on-scroll defaults on', () => expect(with_(1).hideBarOnScroll, isTrue));
  });

  testWidgets('bottom bar reports the tapped tab and slides its indicator', (tester) async {
    var current = 0;
    int? tapped;
    late StateSetter set;
    final items = [
      for (final n in ['Home', 'Explore', 'Saved', 'Settings']) HmNavItem(icon: Icons.circle_outlined, selectedIcon: Icons.circle, label: n),
    ];
    await tester.pumpWidget(host(StatefulBuilder(builder: (context, setState) {
      set = setState;
      return Align(alignment: Alignment.bottomCenter, child: HmBottomNav(items: items, currentIndex: current, onSelect: (i) => tapped = i));
    })));
    double indicatorLeft() => tester.widget<AnimatedPositioned>(find.byType(AnimatedPositioned)).left!;
    final first = indicatorLeft();

    await tester.tap(find.text('Saved'));
    await tester.pump();
    expect(tapped, 2);

    set(() => current = 2);
    await tester.pumpAndSettle();
    final width = tester.getSize(find.byType(HmBottomNav)).width;
    expect(indicatorLeft() - first, closeTo(width / 4 * 2, 0.5));
  });

  testWidgets('section card builds its body only once opened and keeps it', (tester) async {
    var open = false;
    late StateSetter set;
    final spec = RemedySectionSpec(
      id: 'dosage', title: 'Dosage', icon: Icons.medication_outlined, tone: (Colors.teal.shade50, Colors.teal),
      builder: (_) => const Text('BODY'),
    );
    await tester.pumpWidget(host(StatefulBuilder(builder: (context, setState) {
      set = setState;
      return SingleChildScrollView(child: RemedySectionCard(spec: spec, open: open, onToggle: () => set(() => open = !open)));
    })));
    expect(find.text('BODY'), findsNothing); // never opened: not even built

    await tester.tap(find.text('Dosage'));
    await tester.pumpAndSettle();
    expect(find.text('BODY'), findsOneWidget);

    await tester.tap(find.text('Dosage'));
    await tester.pumpAndSettle();
    expect(find.text('BODY'), findsNothing); // closed again: kept but Offstage (no layout, no paint)
    expect(find.text('BODY', skipOffstage: false), findsOneWidget);
  });

  group('cards', () {
    test('side margin is 16 and the shadow is very soft in both themes', () {
      expect(Hm.gutter, 16);
      for (final dark in [false, true]) {
        final shadow = HomaColors.of(dark: dark, accent: 'teal').cardShadow.single;
        expect(shadow.blurRadius, lessThanOrEqualTo(10));
        expect(shadow.offset.dy, lessThanOrEqualTo(2));
        expect(shadow.color.a, lessThanOrEqualTo(0.26));
      }
    });

    testWidgets('HmCard lifts by default and not when nested', (tester) async {
      BoxShadow? shadowOf(WidgetTester t) {
        final box = t.widget<DecoratedBox>(find.descendant(of: find.byType(HmCard), matching: find.byType(DecoratedBox)).first);
        return ((box.decoration as BoxDecoration).boxShadow)?.firstOrNull;
      }

      await tester.pumpWidget(host(const HmCard(child: Text('a'))));
      expect(shadowOf(tester), isNotNull);
      await tester.pumpWidget(host(const HmCard(elevated: false, child: Text('a'))));
      expect(shadowOf(tester), isNull);
    });
  });

  testWidgets('segmented control changes value on tap', (tester) async {
    var v = 'en';
    late StateSetter set;
    await tester.pumpWidget(host(StatefulBuilder(builder: (context, setState) {
      set = setState;
      return Segmented<String>(options: const [('en', 'English'), ('bn', 'বাংলা')], value: v, onChanged: (x) => set(() => v = x));
    })));
    await tester.tap(find.text('বাংলা'));
    await tester.pumpAndSettle();
    expect(v, 'bn');
  });
}
