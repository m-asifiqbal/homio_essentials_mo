import 'package:material_ui/material_ui.dart';

/// Colour tokens from the Homio Essentials design system (design canvas `hm.css`).
/// One instance per (brightness × accent); read with `context.hm`.
@immutable
class HomaColors extends ThemeExtension<HomaColors> {
  const HomaColors({
    required this.bg, required this.sf, required this.sf2, required this.sf3, required this.ln,
    required this.ink, required this.ink2, required this.ink3,
    required this.p, required this.pd, required this.p2, required this.onp, required this.ring,
    required this.pe, required this.peInk, required this.co,
    required this.am, required this.amInk, required this.dg, required this.dgInk, required this.ok, required this.okInk,
    required this.ptBg, required this.ptInk, required this.miBg, required this.miInk,
    required this.anBg, required this.anInk, required this.noBg, required this.noInk, required this.bcBg, required this.bcInk,
    required this.hero1, required this.hero2, required this.dark,
  });

  final Color bg, sf, sf2, sf3, ln, ink, ink2, ink3, p, pd, p2, onp, ring;
  final Color pe, peInk, co, am, amInk, dg, dgInk, ok, okInk;
  final Color ptBg, ptInk, miBg, miInk, anBg, anInk, noBg, noInk, bcBg, bcInk;
  final Color hero1, hero2;
  final bool dark;

  LinearGradient get heroGradient => LinearGradient(
        begin: const Alignment(-0.6, -1), end: const Alignment(0.6, 1), colors: [hero1, hero2]);

  /// Badge colours for a remedy's source kingdom.
  (Color bg, Color ink) kingdom(String? k) => switch (k) {
        'plant' => (ptBg, ptInk),
        'mineral' => (miBg, miInk),
        'animal' => (anBg, anInk),
        'nosode' => (noBg, noInk),
        'sarcode' => (bcBg, bcInk),
        'imponderabilia' => (pe, peInk),
        _ => (sf2, pd),
      };

  static const _lightBase = HomaColors(
    bg: Color(0xFFF3F9F8), sf: Color(0xFFFFFFFF), sf2: Color(0xFFE9F4F2), sf3: Color(0xFFD8EAE7), ln: Color(0xFFD3E3E0),
    ink: Color(0xFF0F2B2C), ink2: Color(0xFF44605F), ink3: Color(0xFF566E6D),
    p: Color(0xFF0F6466), pd: Color(0xFF0A4A4C), p2: Color(0xFF1E8A8A), onp: Color(0xFFFFFFFF), ring: Color(0x2E0F6466),
    pe: Color(0xFFFFE3D8), peInk: Color(0xFF7B2D17), co: Color(0xFFE4694A),
    am: Color(0xFFFFF3DC), amInk: Color(0xFF7A4B00), dg: Color(0xFFFDE8E6), dgInk: Color(0xFF9B2318), ok: Color(0xFFE1F2E6), okInk: Color(0xFF1F6B3A),
    ptBg: Color(0xFFE1F2E6), ptInk: Color(0xFF1F6B3A), miBg: Color(0xFFE4ECF8), miInk: Color(0xFF31528A),
    anBg: Color(0xFFF7E9DA), anInk: Color(0xFF7D4A1B), noBg: Color(0xFFECE6F7), noInk: Color(0xFF5B3F94), bcBg: Color(0xFFFBEFC4), bcInk: Color(0xFF6B5200),
    hero1: Color(0xFF0B5557), hero2: Color(0xFF1B8077), dark: false,
  );

  static const _darkBase = HomaColors(
    bg: Color(0xFF0B1A1B), sf: Color(0xFF122526), sf2: Color(0xFF1A3234), sf3: Color(0xFF244244), ln: Color(0xFF29484A),
    ink: Color(0xFFE7F3F1), ink2: Color(0xFFB0C8C5), ink3: Color(0xFF92ADAA),
    p: Color(0xFF5CC8C0), pd: Color(0xFF9BE3DD), p2: Color(0xFF5CC8C0), onp: Color(0xFF062B2C), ring: Color(0x405CC8C0),
    pe: Color(0xFF3B2319), peInk: Color(0xFFFFD2C0), co: Color(0xFFFF8A6B),
    am: Color(0xFF35290F), amInk: Color(0xFFFFD58A), dg: Color(0xFF3A1C19), dgInk: Color(0xFFFFB4AB), ok: Color(0xFF1B3524), okInk: Color(0xFF9ADBAF),
    ptBg: Color(0xFF1B3524), ptInk: Color(0xFF9ADBAF), miBg: Color(0xFF1E2E48), miInk: Color(0xFFA9C7FF),
    anBg: Color(0xFF3A2A18), anInk: Color(0xFFF0C08F), noBg: Color(0xFF2C2342), noInk: Color(0xFFCDB8FF), bcBg: Color(0xFF3A3210), bcInk: Color(0xFFF2DC85),
    hero1: Color(0xFF08393B), hero2: Color(0xFF136D68), dark: true,
  );

  /// Accent themes: teal (default), ocean, forest, plum.
  static HomaColors of({required bool dark, required String accent}) {
    final b = dark ? _darkBase : _lightBase;
    if (dark) {
      return switch (accent) {
        'ocean' => b.copyWith(p: const Color(0xFF7DB8F0), pd: const Color(0xFFB9D8F7), p2: const Color(0xFF7DB8F0), onp: const Color(0xFF0A2440), hero1: const Color(0xFF0E2F52), hero2: const Color(0xFF1D5C96), ring: const Color(0x407DB8F0)),
        'forest' => b.copyWith(p: const Color(0xFF8CCB92), pd: const Color(0xFFBFE5C2), p2: const Color(0xFF8CCB92), onp: const Color(0xFF10301A), hero1: const Color(0xFF173A1F), hero2: const Color(0xFF2F6A3A), ring: const Color(0x408CCB92)),
        'plum' => b.copyWith(p: const Color(0xFFCDA6E0), pd: const Color(0xFFE6CFF0), p2: const Color(0xFFCDA6E0), onp: const Color(0xFF2C1838), hero1: const Color(0xFF341C42), hero2: const Color(0xFF6A3F7E), ring: const Color(0x40CDA6E0)),
        _ => b,
      };
    }
    return switch (accent) {
      'ocean' => b.copyWith(p: const Color(0xFF1D5C96), pd: const Color(0xFF123F6B), p2: const Color(0xFF2E7BC0), ring: const Color(0x2E1D5C96), sf2: const Color(0xFFE8F0F9), sf3: const Color(0xFFD5E3F2), ln: const Color(0xFFD3DEEA), bg: const Color(0xFFF4F8FC), hero1: const Color(0xFF164E82), hero2: const Color(0xFF2B74B3)),
      'forest' => b.copyWith(p: const Color(0xFF2F6A3A), pd: const Color(0xFF1F4A28), p2: const Color(0xFF3F8A4E), ring: const Color(0x2E2F6A3A), sf2: const Color(0xFFEAF3EA), sf3: const Color(0xFFD6E8D8), ln: const Color(0xFFD4E4D6), bg: const Color(0xFFF5F9F4), hero1: const Color(0xFF285C32), hero2: const Color(0xFF3F7F44)),
      'plum' => b.copyWith(p: const Color(0xFF6A3F7E), pd: const Color(0xFF4C2A5C), p2: const Color(0xFF8A5AA0), ring: const Color(0x2E6A3F7E), sf2: const Color(0xFFF3ECF6), sf3: const Color(0xFFE6D9EC), ln: const Color(0xFFE4D8EA), bg: const Color(0xFFFAF6FB), hero1: const Color(0xFF5A3370), hero2: const Color(0xFF8456A0)),
      _ => b,
    };
  }

  /// Swatch gradients shown in Settings → Theme colour.
  static const accents = <(String id, Color c1, Color c2)>[
    ('teal', Color(0xFF0B5557), Color(0xFF1B8077)),
    ('ocean', Color(0xFF164E82), Color(0xFF2B74B3)),
    ('forest', Color(0xFF285C32), Color(0xFF3F7F44)),
    ('plum', Color(0xFF5A3370), Color(0xFF8456A0)),
  ];

  @override
  HomaColors copyWith({
    Color? bg, Color? sf, Color? sf2, Color? sf3, Color? ln, Color? p, Color? pd, Color? p2, Color? onp, Color? ring,
    Color? hero1, Color? hero2,
  }) =>
      HomaColors(
        bg: bg ?? this.bg, sf: sf ?? this.sf, sf2: sf2 ?? this.sf2, sf3: sf3 ?? this.sf3, ln: ln ?? this.ln,
        ink: ink, ink2: ink2, ink3: ink3, p: p ?? this.p, pd: pd ?? this.pd, p2: p2 ?? this.p2, onp: onp ?? this.onp, ring: ring ?? this.ring,
        pe: pe, peInk: peInk, co: co, am: am, amInk: amInk, dg: dg, dgInk: dgInk, ok: ok, okInk: okInk,
        ptBg: ptBg, ptInk: ptInk, miBg: miBg, miInk: miInk, anBg: anBg, anInk: anInk, noBg: noBg, noInk: noInk, bcBg: bcBg, bcInk: bcInk,
        hero1: hero1 ?? this.hero1, hero2: hero2 ?? this.hero2, dark: dark,
      );

  @override
  HomaColors lerp(ThemeExtension<HomaColors>? other, double t) => (other is HomaColors && t >= 0.5) ? other : this;
}

extension HomaContext on BuildContext {
  HomaColors get hm => Theme.of(this).extension<HomaColors>()!;
}

/// Spacing / radius scale used across screens.
abstract final class Hm {
  static const gutter = 20.0;
  static const rCard = 20.0;
  static const rTile = 14.0;
  static const rButton = 18.0;

  /// Height of the tab bar's content (the safe-area inset comes on top).
  static const navBarHeight = 60.0;

  /// Gap kept under the last item of a tab list, on top of the bar's own height.
  static const barGap = 16.0;
}

/// One motion language for the whole app (same values as FocusFlow's `AppMotion`).
abstract final class HmMotion {
  static const fast = Duration(milliseconds: 180);
  static const normal = Duration(milliseconds: 220);
  static const slow = Duration(milliseconds: 260);
  static const curve = Curves.easeOutCubic;

  /// Card press scale.
  static const pressScale = 0.98;
}

extension HmMotionContext on BuildContext {
  /// True when the OS (or the app) asks for reduced motion.
  bool get reduceMotion => MediaQuery.maybeDisableAnimationsOf(this) ?? false;

  /// [d], or zero under reduce motion.
  Duration motion(Duration d) => reduceMotion ? Duration.zero : d;

  /// Bottom padding for a tab's scroll view: clears the floating bar + ad (the shell
  /// reserves their height in the MediaQuery) plus a small gap.
  double get barClearance => MediaQuery.paddingOf(this).bottom + Hm.barGap;
}
