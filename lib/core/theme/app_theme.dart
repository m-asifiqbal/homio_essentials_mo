import 'package:google_fonts/google_fonts.dart';
import 'package:material_ui/material_ui.dart';

import 'package:homio_essentials/core/router/page_transitions.dart';
import 'package:homio_essentials/core/theme/tokens.dart';

/// Builds Material ThemeData from the Homio Essentials tokens.
/// Plus Jakarta Sans for Latin text, Hind Siliguri for Bangla (as fallback),
/// Newsreader italic for Latin remedy names (see [latinStyle]).
///
/// Type scale follows FocusFlow's calmer ramp (semibold titles, 14–15 body,
/// 12 captions); the app also runs at a 0.95 default text scale (see app.dart).
ThemeData buildTheme(HomaColors c) {
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
    extensions: [c],
  );
  final bangla = GoogleFonts.hindSiliguri().fontFamily;
  final text = GoogleFonts.plusJakartaSansTextTheme(base.textTheme).apply(
    bodyColor: c.ink, displayColor: c.ink, fontFamilyFallback: [?bangla],
  );
  return base.copyWith(
    textTheme: text.copyWith(
      headlineMedium: text.headlineMedium?.copyWith(fontSize: 24, fontWeight: FontWeight.w700, letterSpacing: -0.4, height: 1.2),
      headlineSmall: text.headlineSmall?.copyWith(fontSize: 19, fontWeight: FontWeight.w700, letterSpacing: -0.2, height: 1.25),
      titleLarge: text.titleLarge?.copyWith(fontSize: 17, fontWeight: FontWeight.w700, height: 1.3),
      titleMedium: text.titleMedium?.copyWith(fontSize: 15, fontWeight: FontWeight.w600, height: 1.3),
      titleSmall: text.titleSmall?.copyWith(fontSize: 14, fontWeight: FontWeight.w600, height: 1.3),
      bodyLarge: text.bodyLarge?.copyWith(fontSize: 14.5, height: 1.55),
      bodyMedium: text.bodyMedium?.copyWith(fontSize: 13.5, height: 1.5),
      bodySmall: text.bodySmall?.copyWith(fontSize: 12, height: 1.4, color: c.ink2),
      labelLarge: text.labelLarge?.copyWith(fontSize: 14, fontWeight: FontWeight.w600),
      labelSmall: text.labelSmall?.copyWith(fontSize: 11.5, fontWeight: FontWeight.w700, letterSpacing: 0.8, color: c.ink3),
    ),
    appBarTheme: AppBarTheme(backgroundColor: c.bg, foregroundColor: c.ink, elevation: 0, scrolledUnderElevation: 0, centerTitle: true,
        titleTextStyle: text.titleMedium?.copyWith(fontSize: 15, fontWeight: FontWeight.w600)),
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

/// Latin remedy names are set in Newsreader italic, as on the design canvas.
TextStyle latinStyle({double size = 17, Color? color, FontWeight weight = FontWeight.w500}) =>
    GoogleFonts.newsreader(fontSize: size, fontStyle: FontStyle.italic, fontWeight: weight, color: color, height: 1.15);
