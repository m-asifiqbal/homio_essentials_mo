/// ============================================================
/// PROMO SLIDER — paid banners (Home, remedy pages) with a fallback card
/// ============================================================
///
/// Auto-advances every 5 s (paused when animations are off), logs one
/// impression per banner per screen and every tap. When nothing is live,
/// the "advertise with us" card from `app_config.promo_fallback` shows.
/// ============================================================
library;

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import 'package:homio_essentials/core/archive/domain/entities/models.dart';
import 'package:homio_essentials/core/l10n/i18n.dart';
import 'package:homio_essentials/core/theme/tokens.dart';
import 'package:homio_essentials/core/utils/launcher.dart';
import 'package:homio_essentials/core/widgets/widgets.dart';
import 'package:homio_essentials/features/promotions/domain/entities/promotion.dart';
import 'package:homio_essentials/features/promotions/presentation/providers/promotions_providers.dart';
import 'package:homio_essentials/shared/providers/archive_provider.dart';
import 'package:homio_essentials/shared/providers/repository_providers.dart';

class PromoSlider extends ConsumerStatefulWidget {
  const PromoSlider({super.key, required this.placement, this.remedyId});
  final String placement; // home | remedy
  final String? remedyId;

  @override
  ConsumerState<PromoSlider> createState() => _PromoSliderState();
}

class _PromoSliderState extends ConsumerState<PromoSlider> {
  final _page = PageController(viewportFraction: .9);
  Timer? _timer;
  int _i = 0;
  final _seen = <String>{};

  @override
  void dispose() {
    _timer?.cancel();
    _page.dispose();
    super.dispose();
  }

  void _autoplay(int n) {
    if (_timer != null || n < 2 || MediaQuery.disableAnimationsOf(context)) return;
    _timer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (_page.hasClients) _page.animateToPage((_i + 1) % n, duration: const Duration(milliseconds: 450), curve: Curves.easeOutCubic);
    });
  }

  void _log(Promotion p, String event) =>
      ref.read(promotionsRepositoryProvider).log(p.id, event: event, placement: widget.placement, locale: context.bn ? 'bn' : 'en');

  @override
  Widget build(BuildContext context) {
    final promos = ref.watch(livePromotionsProvider).value?.where((p) => p.showsOn(widget.placement, remedyId: widget.remedyId)).toList() ?? const <Promotion>[];
    if (promos.isEmpty) return const _FallbackCard();
    _autoplay(promos.length);
    final current = promos[_i % promos.length];
    if (_seen.add(current.id)) WidgetsBinding.instance.addPostFrameCallback((_) { if (mounted) _log(current, 'impression'); });
    final repo = ref.read(promotionsRepositoryProvider);
    final c = context.hm;
    return Column(children: [
      SizedBox(
        height: 168,
        child: PageView.builder(
          controller: _page,
          itemCount: promos.length,
          onPageChanged: (i) => setState(() => _i = i),
          itemBuilder: (context, i) {
            final p = promos[i];
            final path = context.bn && p.imageBnPath != null ? p.imageBnPath! : p.imagePath;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Material(
                  color: c.sf2,
                  child: InkWell(
                    onTap: () { _log(p, 'tap'); openTarget(p.tapAction, p.tapValue); },
                    child: Stack(fit: StackFit.expand, children: [
                      Image.network(repo.imageUrl(path), fit: BoxFit.cover, semanticLabel: p.title.of(context.bn),
                          errorBuilder: (_, _, _) => Center(child: Text(p.title.of(context.bn) ?? p.advertiser, style: TextStyle(color: c.pd, fontWeight: FontWeight.w700)))),
                      PositionedDirectional(start: 12, top: 12, child: HmBadge(context.l.sponsored, bg: Colors.black.withValues(alpha: .45), ink: Colors.white)),
                    ]),
                  ),
                ),
              ),
            );
          },
        ),
      ),
      if (promos.length > 1)
        Padding(
          padding: const EdgeInsets.only(top: 10),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            for (var k = 0; k < promos.length; k++)
              AnimatedContainer(
                duration: const Duration(milliseconds: 200), margin: const EdgeInsets.symmetric(horizontal: 3), width: k == _i ? 20 : 7, height: 7,
                decoration: BoxDecoration(color: k == _i ? c.p : c.sf3, borderRadius: BorderRadius.circular(99)),
              ),
          ]),
        ),
    ]);
  }
}

class _FallbackCard extends ConsumerWidget {
  const _FallbackCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final a = ref.watch(archiveProvider).value;
    final cfg = a?.config['promo_fallback'];
    if (cfg is Map && cfg['enabled'] == false) return const SizedBox.shrink();
    final bangla = context.bn;
    final l = context.l;
    final c = context.hm;
    final title = (cfg is Map ? I18n.from(cfg['title']).of(bangla) : null) ?? l.promoFallbackTitle;
    final body = (cfg is Map ? I18n.from(cfg['body']).of(bangla) : null) ?? l.promoFallbackBody;
    final ads = a?.config['ads_contact'];
    String? field(String k) => ads is Map && ads[k] is String && !(ads[k] as String).contains('X') && !(ads[k] as String).contains('yourdomain') ? ads[k] as String : null;
    final whatsapp = field('whatsapp'), email = field('email');
    return Gutter(
      child: HmCard(
        radius: 24, color: c.sf2, border: c.sf2, padding: const EdgeInsets.all(18),
        child: Row(children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              HmBadge(l.sponsored, bg: c.sf, ink: c.ink2),
              const SizedBox(height: 8),
              Text(title, style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: c.pd)),
              const SizedBox(height: 4),
              Text(body, style: TextStyle(fontSize: 13, color: c.ink2, height: 1.45)),
              if (whatsapp != null || email != null) ...[
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () => whatsapp != null ? openTarget('whatsapp', whatsapp) : openTarget('email', email!),
                  icon: const Icon(Icons.campaign_outlined, size: 18),
                  label: Text(l.advertiseWithUs),
                ),
              ],
            ]),
          ),
          const SizedBox(width: 10),
          Icon(Icons.campaign_outlined, size: 48, color: c.pd.withValues(alpha: .35)),
        ]),
      ),
    );
  }
}
