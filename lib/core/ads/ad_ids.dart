/// ============================================================
/// AD IDS — AdMob unit ids (Google's public TEST units by default)
/// ============================================================
///
/// Development builds can never serve real ads (tapping your own live ads
/// can get an AdMob account banned). For release, pass your own ids:
///   flutter build apk --release --dart-define-from-file=config/admob.json
/// with ADMOB_APP_ID_ANDROID, ADMOB_BANNER_ANDROID, ADMOB_BANNER_IOS
/// (iOS app id: GADApplicationIdentifier in ios/Runner/Info.plist).
/// ============================================================
library;

import 'package:flutter/foundation.dart';

abstract final class AdIds {
  static const _bannerAndroid = String.fromEnvironment('ADMOB_BANNER_ANDROID', defaultValue: 'ca-app-pub-3940256099942544/9214589741');
  static const _bannerIos = String.fromEnvironment('ADMOB_BANNER_IOS', defaultValue: 'ca-app-pub-3940256099942544/2435281174');

  static String get banner => defaultTargetPlatform == TargetPlatform.iOS ? _bannerIos : _bannerAndroid;

  /// True while the build uses Google's sample units.
  static bool get isTest => banner.startsWith('ca-app-pub-3940256099942544/');
}
