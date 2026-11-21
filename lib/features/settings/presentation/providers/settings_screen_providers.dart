/// Settings-only state: whether the ad privacy options row must be shown.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:homio_essentials/core/ads/ad_service.dart';

/// Google's UMP says this user must be able to change ad choices (EEA/UK…).
final adPrivacyRequiredProvider = FutureProvider.autoDispose<bool>((ref) {
  if (!ref.watch(adsConfigProvider).enabled) return false;
  return ref.read(adServiceProvider).privacyOptionsRequired();
});
