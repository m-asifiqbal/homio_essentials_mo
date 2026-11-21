/// ============================================================
/// APP TEXT SCALER — Settings › text size on top of the OS scale
/// ============================================================
///
/// Same approach as FocusFlow: the in-app multiplier is composed *on top of*
/// the system [TextScaler] instead of replacing it, so Android 14's
/// non-linear font scaling survives and a user who already runs large system
/// text is never capped below what the OS asked for.
///
///   scale(size) = system.scale(size) × factor
///
/// Enlarging is limited so the app multiplier alone never pushes text past
/// [maxAppScale]× the font size.
/// ============================================================
library;

import 'dart:math' as math;

import 'package:flutter/foundation.dart' show immutable;
import 'package:flutter/painting.dart';

@immutable
class AppTextScaler extends TextScaler {
  const AppTextScaler({required this.system, required this.factor});

  /// Wraps [system] with [factor], or returns [system] itself when the factor is 1.
  static TextScaler compose(TextScaler system, double factor) => factor == 1 ? system : AppTextScaler(system: system, factor: factor);

  /// Upper bound the app multiplier may enlarge to on its own.
  static const double maxAppScale = 2.0;

  /// The device's scaler (possibly non-linear).
  final TextScaler system;

  /// Settings multiplier.
  final double factor;

  @override
  double scale(double fontSize) {
    final base = system.scale(fontSize);
    final scaled = base * factor;
    if (factor <= 1) return scaled;
    // Never below what the OS asked for; never above 2× from the app alone.
    return math.min(scaled, math.max(base, fontSize * maxAppScale));
  }

  /// Linear approximation, only for legacy readers (use [scale]).
  @override
  double get textScaleFactor => scale(14) / 14;

  @override
  bool operator ==(Object other) => other is AppTextScaler && other.system == system && other.factor == factor;

  @override
  int get hashCode => Object.hash(system, factor);

  @override
  String toString() => 'AppTextScaler($system × $factor)';
}
