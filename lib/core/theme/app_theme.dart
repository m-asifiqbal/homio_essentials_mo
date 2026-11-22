import 'package:material_ui/material_ui.dart';

import 'package:homio_essentials/core/router/page_transitions.dart';
import 'package:homio_essentials/core/theme/tokens.dart';

/// Bundled font families (pubspec `fonts:`) — nothing is downloaded at runtime, so text never swaps font after
/// the first frame (the old google_fonts setup fetched every weight over the network on first use).
abstract final class HmFonts {
  /// Headings, buttons, numbers (same as FocusFlow's headings).
  static const heading = 'LexendDeca';

  /// Body text and the italic Latin remedy names (same as FocusFlow's body).
  static const body = 'NunitoSans';

  /// Bangla glyphs (the two Latin families have none) — Noto Sans Bengali: Google's industry-standard Bengali font,
  /// full script coverage (conjuncts, Bangla digits), bundled so it renders the same on every phone.
  static const bangla = 'NotoSansBengali';
  static const fallback = [bangla];
}

/// Builds Material ThemeData from the app's design tokens.
/// Nunito Sans body + Lexend Deca headings (as FocusFlow), Noto Sans Bengali as the Bangla fallback,
/// Nunito Sans italic for Latin remedy names (see [latinStyle]).
///
/// Type scale follows FocusFlow's calmer ramp (semibold titles, 14–15 body,
/// 12 captions); the app also runs at a 0.95 default text scale (see app.dart).
ThemeData buildTheme(HomaColors c, {bool bangla = false}) {
  // Bengali is shaped in clusters (conjuncts, vowel signs): ANY letter-spacing — positive or negative — pulls the marks
  // apart or onto their neighbours, so Bangla text runs with none.
  double ls(double v) => bangla ? 0 : v;
  final base = ThemeData(
    useMaterial3: true,
    brightness: c.dark ? Brightness.dark : Brightness.light,
    colorScheme: ColorScheme(
      brightness: c.dark ? Brightness.dark : Brightness.light,
      primary: c.p, onPrimary: c.onp, secondary: c.p2, onSecondary: c.onp,
      error: c.dgInk, onError: c.sf, surface: c.sf, onSurface: c.ink,
      surfaceContainerHighest: c.sf2, outline: c.ln, outlineVariant: c.ln,
    ),
    scaffoldBackgroundColor: c.bg,
    splashFactory: InkRipple.splashFactory,
    fontFamily: HmFonts.body,
    fontFamilyFallback: HmFonts.fallback,
    extensions: [c],
  );
  final text = base.textTheme.apply(bodyColor: c.ink, displayColor: c.ink);
  // Headings / buttons in Lexend Deca; everything else inherits Nunito Sans from the theme.
  TextStyle? head(TextStyle? t) => t?.copyWith(fontFamily: HmFonts.heading, fontFamilyFallback: HmFonts.fallback);
  return base.copyWith(
    textTheme: text.copyWith(
      headlineMedium: head(text.headlineMedium)?.copyWith(fontSize: 21, fontWeight: FontWeight.w600, letterSpacing: ls(-0.3), height: 1.2),
      headlineSmall: head(text.headlineSmall)?.copyWith(fontSize: 18.5, fontWeight: FontWeight.w600, letterSpacing: ls(-0.1), height: 1.25),
      titleLarge: head(text.titleLarge)?.copyWith(fontSize: 17, fontWeight: FontWeight.w600, height: 1.3),
      titleMedium: head(text.titleMedium)?.copyWith(fontSize: 15, fontWeight: FontWeight.w600, height: 1.3),
      titleSmall: head(text.titleSmall)?.copyWith(fontSize: 14, fontWeight: FontWeight.w600, height: 1.3),
      bodyLarge: text.bodyLarge?.copyWith(fontSize: 15, height: 1.55),
      bodyMedium: text.bodyMedium?.copyWith(fontSize: 14, height: 1.5),
      bodySmall: text.bodySmall?.copyWith(fontSize: 12.5, height: 1.4, color: c.ink2),
      labelLarge: head(text.labelLarge)?.copyWith(fontSize: 14, fontWeight: FontWeight.w600),
      labelSmall: text.labelSmall?.copyWith(fontSize: 11.5, fontWeight: FontWeight.w700, letterSpacing: ls(0.8), color: c.ink3),
    ),
    appBarTheme: AppBarTheme(backgroundColor: c.bg, foregroundColor: c.ink, elevation: 0, scrolledUnderElevation: 0, centerTitle: true,
        titleTextStyle: head(text.titleMedium)?.copyWith(fontSize: 15, fontWeight: FontWeight.w600)),
    dividerTheme: DividerThemeData(color: c.ln, thickness: 1, space: 1),
    cardTheme: CardThemeData(color: c.sf, elevation: 0, margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Hm.rCard), side: BorderSide(color: c.ln))),
    filledButtonTheme: FilledButtonThemeData(style: FilledButton.styleFrom(
      backgroundColor: c.p, foregroundColor: c.onp, minimumSize: const Size(64, 50),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Hm.rButton)),
      textStyle: text.labelLarge?.copyWith(fontSize: 15, fontWeight: FontWeight.w600),
    )),
    outlinedButtonTheme: OutlinedButtonThemeData(style: OutlinedButton.styleFrom(
      foregroundColor: c.p, minimumSize: const Size(64, 44), side: BorderSide(color: c.p, width: 1.25),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      textStyle: text.labelLarge?.copyWith(fontSize: 14, fontWeight: FontWeight.w600),
    )),
    textButtonTheme: TextButtonThemeData(style: TextButton.styleFrom(foregroundColor: c.p, textStyle: text.labelLarge?.copyWith(fontSize: 13.5, fontWeight: FontWeight.w600))),
    inputDecorationTheme: InputDecorationTheme(
      filled: true, fillColor: c.sf, hintStyle: TextStyle(color: c.ink3),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: c.ln, width: 1.25)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: c.ln, width: 1.25)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: c.p, width: 1.75)),
      errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: c.dgInk, width: 1.25)),
    ),
    tabBarTheme: TabBarThemeData(
      labelColor: c.p, unselectedLabelColor: c.ink3, indicatorColor: c.p, dividerColor: c.ln,
      indicatorSize: TabBarIndicatorSize.label, labelStyle: text.labelLarge?.copyWith(fontSize: 13.5, fontWeight: FontWeight.w600),
      unselectedLabelStyle: text.labelLarge?.copyWith(fontSize: 13.5, fontWeight: FontWeight.w600),
      indicator: UnderlineTabIndicator(borderSide: BorderSide(color: c.p, width: 2.5)),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected) ? c.onp : Colors.white),
      trackColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected) ? c.p : c.sf3),
      trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
    ),
    sliderTheme: SliderThemeData(activeTrackColor: c.p, inactiveTrackColor: c.sf3, thumbColor: c.p, overlayColor: c.ring, trackHeight: 6),
    snackBarTheme: SnackBarThemeData(behavior: SnackBarBehavior.floating, backgroundColor: c.ink, contentTextStyle: TextStyle(color: c.bg, fontSize: 13.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
    bottomSheetTheme: BottomSheetThemeData(backgroundColor: c.sf, showDragHandle: true,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28)))),
    // Same slide + parallax on every platform (iOS keeps Cupertino for its swipe-back).
    pageTransitionsTheme: PageTransitionsTheme(builders: {
      for (final p in TargetPlatform.values) p: const HmPageTransitionsBuilder(),
    }),
  );
}

/// Latin remedy names are set in italic (Nunito Sans Italic — bundled; the design canvas' serif italic
/// was a runtime download). Only the regular-weight italic ships, so [weight] is accepted for call-site
/// compatibility but the face stays regular; size and ink carry the emphasis.
TextStyle latinStyle({double size = 17, Color? color, FontWeight weight = FontWeight.w500}) =>
    TextStyle(fontFamily: HmFonts.body, fontFamilyFallback: HmFonts.fallback, fontSize: size + 0.5, fontStyle: FontStyle.italic, fontWeight: FontWeight.w400, color: color, height: 1.2);
