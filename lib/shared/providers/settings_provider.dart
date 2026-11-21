/// ============================================================
/// SETTINGS PROVIDER — language, detail level, theme, text size, device id
/// ============================================================
///
/// Plain preferences, read synchronously (prefs are resolved in bootstrap).
/// `canStudy` gates the full Materia Medica (Student / Practitioner modes).
/// ============================================================
library;

import 'dart:math';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart' show ThemeMode;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:homio_essentials/shared/providers/core_providers.dart';

enum Role { general, student, practitioner }

enum DayNight { day, night, system }

@immutable
class AppSettings {
  const AppSettings({
    required this.locale, required this.role, required this.dayNight, required this.accent,
    required this.textScale, required this.onboarded, required this.deviceId, this.hideBarOnScroll = true,
  });

  /// Text-size stops shown in Settings (multiplier on top of the OS scale). Same ramp as FocusFlow.
  static const textScaleStops = <double>[0.85, 0.9, 0.95, 1.05, 1.15, 1.3];

  /// "Default" — a notch under 1.0 keeps the UI calm on small phones.
  static const defaultTextScale = 0.95;

  final String locale; // 'en' | 'bn'
  final Role role;
  final DayNight dayNight;
  final String accent; // teal | ocean | forest | plum
  final double textScale; // 0.85 – 1.3
  final bool onboarded;
  final String deviceId; // random per install; keys "My requests"

  /// Slide the tab bar away while scrolling down, bring it back on scroll up.
  final bool hideBarOnScroll;

  bool get bn => locale == 'bn';
  bool get canStudy => role != Role.general;
  ThemeMode get themeMode => switch (dayNight) { DayNight.day => ThemeMode.light, DayNight.night => ThemeMode.dark, DayNight.system => ThemeMode.system };

  /// Index of the stop closest to [textScale].
  int get textScaleIndex {
    var best = 0;
    for (var i = 1; i < textScaleStops.length; i++) {
      if ((textScaleStops[i] - textScale).abs() < (textScaleStops[best] - textScale).abs()) best = i;
    }
    return best;
  }

  AppSettings copyWith({String? locale, Role? role, DayNight? dayNight, String? accent, double? textScale, bool? onboarded, bool? hideBarOnScroll}) => AppSettings(
        locale: locale ?? this.locale, role: role ?? this.role, dayNight: dayNight ?? this.dayNight, accent: accent ?? this.accent,
        textScale: textScale ?? this.textScale, onboarded: onboarded ?? this.onboarded, deviceId: deviceId,
        hideBarOnScroll: hideBarOnScroll ?? this.hideBarOnScroll,
      );
}

class SettingsController extends Notifier<AppSettings> {
  SharedPreferences get _p => ref.read(prefsProvider);

  @override
  AppSettings build() {
    final p = ref.watch(prefsProvider);
    var deviceId = p.getString('device_id');
    if (deviceId == null) {
      final r = Random.secure();
      deviceId = List.generate(16, (_) => r.nextInt(256).toRadixString(16).padLeft(2, '0')).join();
      p.setString('device_id', deviceId);
    }
    return AppSettings(
      locale: p.getString('locale') ?? 'en',
      role: Role.values.asNameMap()[p.getString('role')] ?? Role.general,
      dayNight: DayNight.values.asNameMap()[p.getString('day_night')] ?? DayNight.system,
      accent: p.getString('accent') ?? 'teal',
      textScale: p.getDouble('text_scale') ?? AppSettings.defaultTextScale,
      onboarded: p.getBool('onboarded') ?? false,
      deviceId: deviceId,
      hideBarOnScroll: p.getBool('hide_bar_on_scroll') ?? true,
    );
  }

  void setLocale(String v) { _p.setString('locale', v); state = state.copyWith(locale: v); }
  void setRole(Role v) { _p.setString('role', v.name); state = state.copyWith(role: v); }
  void setDayNight(DayNight v) { _p.setString('day_night', v.name); state = state.copyWith(dayNight: v); }
  void setAccent(String v) { _p.setString('accent', v); state = state.copyWith(accent: v); }
  void setTextScale(double v) { _p.setDouble('text_scale', v); state = state.copyWith(textScale: v); }
  void setHideBarOnScroll(bool v) { _p.setBool('hide_bar_on_scroll', v); state = state.copyWith(hideBarOnScroll: v); }
  void completeOnboarding() { _p.setBool('onboarded', true); state = state.copyWith(onboarded: true); }
}

final settingsProvider = NotifierProvider<SettingsController, AppSettings>(SettingsController.new);
