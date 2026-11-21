/// ============================================================
/// AD SERVICE — consent (UMP) then the Mobile Ads SDK; banners only
/// ============================================================
///
/// Same structure as Ludo Mela's AdService. Ads are optional: any failure
/// simply means no banner. Content is capped at PG (health reference app).
/// Remote switch: `app_config.admob` {enabled, anchored_on_main_tabs,
/// inline_on_detail_pages} — editable from the admin app.
/// ============================================================
library;

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'package:homio_essentials/core/ads/ad_ids.dart';
import 'package:homio_essentials/core/utils/app_logger.dart';
import 'package:homio_essentials/shared/providers/archive_provider.dart';

class AdService {
  /// Off on web, desktop and in tests.
  static final bool supported = !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android || defaultTargetPlatform == TargetPlatform.iOS) &&
      !const bool.fromEnvironment('FLUTTER_TEST');

  bool _starting = false;

  /// True once consent is settled and the SDK is running.
  final ValueNotifier<bool> ready = ValueNotifier(false);

  Future<void> start() async {
    if (!supported || _starting || ready.value) return;
    _starting = true;
    try {
      final done = Completer<void>();
      ConsentInformation.instance.requestConsentInfoUpdate(
        ConsentRequestParameters(),
        () async {
          await ConsentForm.loadAndShowConsentFormIfRequired((_) {});
          if (!done.isCompleted) done.complete();
        },
        (_) { if (!done.isCompleted) done.complete(); },
      );
      await done.future.timeout(const Duration(seconds: 12), onTimeout: () {});
      if (!await ConsentInformation.instance.canRequestAds()) return;
      await MobileAds.instance.updateRequestConfiguration(RequestConfiguration(maxAdContentRating: MaxAdContentRating.pg));
      await MobileAds.instance.initialize();
      ready.value = true;
    } catch (e) {
      AppLogger.d('ads not started: $e');
    } finally {
      _starting = false;
    }
  }

  Future<bool> privacyOptionsRequired() async {
    if (!supported) return false;
    try {
      return await ConsentInformation.instance.getPrivacyOptionsRequirementStatus() == PrivacyOptionsRequirementStatus.required;
    } catch (_) {
      return false;
    }
  }

  Future<void> showPrivacyOptions() async {
    if (!supported) return;
    try {
      await ConsentForm.showPrivacyOptionsForm((_) {});
    } catch (_) {}
  }
}

final adServiceProvider = Provider<AdService>((ref) => AdService());

/// Where banners may show, from the remote config (default: off until the archive says so).
class AdsConfig {
  const AdsConfig({this.enabled = false, this.anchored = true, this.inline = true});
  final bool enabled, anchored, inline;
}

/// Debug builds on Google's TEST units always show banners (so placement can be
/// checked); release builds follow the remote switch. `--dart-define=ADMOB_FORCE_TEST=true`
/// does the same for a release-mode test build.
bool get _forceTestAds => (kDebugMode || const bool.fromEnvironment('ADMOB_FORCE_TEST')) && AdIds.isTest;

final adsConfigProvider = Provider<AdsConfig>((ref) {
  final a = ref.watch(archiveProvider).value;
  if (a == null) return const AdsConfig();
  return AdsConfig(
    enabled: a.configFlag('admob', 'enabled') || _forceTestAds,
    anchored: a.configFlag('admob', 'anchored_on_main_tabs', fallback: true),
    inline: a.configFlag('admob', 'inline_on_detail_pages', fallback: true),
  );
});
