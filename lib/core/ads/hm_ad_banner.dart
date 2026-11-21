/// ============================================================
/// HM AD BANNER — anchored (above the tab bar) and inline (detail pages)
/// ============================================================
///
/// Sizes: the anchored slot uses the *standard* anchored adaptive banner
/// (≈ 50–60 dp on phones — not the "large" ≈ 100 dp one), and inline slots are
/// capped at 60 dp so an ad never takes over a page.
///
/// The slot keeps its height while loading so content never jumps; a failed
/// load collapses it. Anchored banners hide while the keyboard is open.
/// An inline banner that has loaded is kept alive inside scrolling lists
/// (AutomaticKeepAlive), so scrolling away and back never re-requests an ad.
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

/// Tallest inline ad we ask for.
const double _inlineMaxHeight = 60;

class HmAdBanner extends ConsumerStatefulWidget {
  const HmAdBanner({super.key, this.placement = AdPlacement.inline});
  final AdPlacement placement;

  @override
  ConsumerState<HmAdBanner> createState() => _HmAdBannerState();
}

class _HmAdBannerState extends ConsumerState<HmAdBanner> with AutomaticKeepAliveClientMixin {
  BannerAd? _ad;
  AdSize? _size;
  bool _failed = false;
  double? _forWidth;

  bool get _anchored => widget.placement == AdPlacement.anchored;

  @override
  bool get wantKeepAlive => _ad != null;

  Future<void> _load(double width) async {
    if (_forWidth == width) return;
    _forWidth = width;
    _ad?.dispose();
    _ad = null;
    final w = width.truncate();
    final size = _anchored
        ? await AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(w)
        : AdSize.getInlineAdaptiveBannerAdSize(w, _inlineMaxHeight.truncate());
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
          if (!mounted) return ad.dispose();
          setState(() { _ad = ad; if (real != null) _size = real; });
          updateKeepAlive();
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
    super.build(context); // AutomaticKeepAliveClientMixin
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
          if (_forWidth != width) WidgetsBinding.instance.addPostFrameCallback((_) => mounted ? _load(width) : null);
          final h = (_size?.height ?? (_anchored ? 50 : 50)).toDouble();
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
        Text(context.l.advertisement, style: TextStyle(fontSize: 10.5, color: c.ink3, fontWeight: FontWeight.w600)),
        const SizedBox(height: 3),
        Center(child: child),
      ]),
    );
  }

  Widget _placeholder(BuildContext context) {
    final c = context.hm;
    return _frame(
      context,
      Container(
        height: _anchored ? 50 : 56,
        width: double.infinity,
        alignment: Alignment.center,
        decoration: BoxDecoration(color: c.sf2, border: _anchored ? null : Border.all(color: c.ln), borderRadius: BorderRadius.circular(_anchored ? 0 : 12)),
        child: Text('${context.l.testAd} · ${_anchored ? 'anchored adaptive' : 'inline adaptive'}', style: TextStyle(fontSize: 11.5, color: c.ink3, fontWeight: FontWeight.w700)),
      ),
    );
  }
}
