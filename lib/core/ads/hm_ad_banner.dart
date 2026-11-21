/// ============================================================
/// HM AD BANNER — anchored (above the tab bar) and inline (detail pages)
/// ============================================================
///
/// The slot keeps its height while loading so content never jumps; a failed
/// load collapses it. Anchored banners hide while the keyboard is open.
/// On web (preview builds) a labelled placeholder shows where the ad goes.
/// ============================================================
library;

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:material_ui/material_ui.dart';

import 'package:homio_essentials/core/ads/ad_ids.dart';
import 'package:homio_essentials/core/ads/ad_service.dart';
import 'package:homio_essentials/core/l10n/i18n.dart';
import 'package:homio_essentials/core/theme/tokens.dart';

enum AdPlacement { anchored, inline }

class HmAdBanner extends ConsumerStatefulWidget {
  const HmAdBanner({super.key, this.placement = AdPlacement.inline});
  final AdPlacement placement;

  @override
  ConsumerState<HmAdBanner> createState() => _HmAdBannerState();
}

class _HmAdBannerState extends ConsumerState<HmAdBanner> {
  BannerAd? _ad;
  AdSize? _size;
  bool _failed = false;
  double? _forWidth;

  bool get _anchored => widget.placement == AdPlacement.anchored;

  Future<void> _load(double width) async {
    if (_forWidth == width) return;
    _forWidth = width;
    _ad?.dispose();
    _ad = null;
    final w = width.truncate();
    final size = _anchored
        ? await AdSize.getLargeAnchoredAdaptiveBannerAdSize(w)
        : AdSize.getCurrentOrientationInlineAdaptiveBannerAdSize(w);
    if (!mounted || size == null) return;
    setState(() => _size = size);
    final ad = BannerAd(
      adUnitId: AdIds.banner,
      size: size,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) async {
          if (!mounted) return ad.dispose();
          final real = await (ad as BannerAd).getPlatformAdSize();
          setState(() { _ad = ad; if (real != null) _size = real; });
        },
        onAdFailedToLoad: (ad, _) {
          ad.dispose();
          if (mounted) setState(() => _failed = true);
        },
      ),
    );
    await ad.load();
  }

  @override
  void dispose() {
    _ad?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cfg = ref.watch(adsConfigProvider);
    final allowed = cfg.enabled && (_anchored ? cfg.anchored : cfg.inline);
    if (!allowed || _failed) return const SizedBox.shrink();
    if (_anchored && MediaQuery.viewInsetsOf(context).bottom > 0) return const SizedBox.shrink();
    if (kIsWeb) return _placeholder(context);
    if (!AdService.supported) return const SizedBox.shrink();
    return ValueListenableBuilder<bool>(
      valueListenable: ref.read(adServiceProvider).ready,
      builder: (context, ready, _) {
        if (!ready) return const SizedBox.shrink();
        return LayoutBuilder(builder: (context, box) {
          final width = _anchored ? box.maxWidth : box.maxWidth - Hm.gutter * 2;
          WidgetsBinding.instance.addPostFrameCallback((_) => _load(width));
          final h = (_size?.height ?? 50).toDouble();
          return _frame(
            context,
            SizedBox(height: h, width: _ad == null ? width : _size!.width.toDouble(), child: _ad == null ? null : AdWidget(ad: _ad!)),
          );
        });
      },
    );
  }

  Widget _frame(BuildContext context, Widget child) {
    final c = context.hm;
    if (_anchored) {
      return Container(
        width: double.infinity,
        decoration: BoxDecoration(color: c.sf, border: Border(top: BorderSide(color: c.ln))),
        alignment: Alignment.center,
        child: child,
      );
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Hm.gutter),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(context.l.advertisement, style: TextStyle(fontSize: 11, color: c.ink3, fontWeight: FontWeight.w600)),
        const SizedBox(height: 4),
        Center(child: child),
      ]),
    );
  }

  Widget _placeholder(BuildContext context) {
    final c = context.hm;
    return _frame(
      context,
      Container(
        height: _anchored ? 50 : 100,
        width: double.infinity,
        alignment: Alignment.center,
        decoration: BoxDecoration(color: c.sf2, border: Border.all(color: c.ln), borderRadius: BorderRadius.circular(_anchored ? 0 : 12)),
        child: Text('${context.l.testAd} · ${_anchored ? 'anchored adaptive' : 'inline adaptive'}', style: TextStyle(fontSize: 12, color: c.ink3, fontWeight: FontWeight.w700)),
      ),
    );
  }
}
