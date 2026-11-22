/// ============================================================
/// REMEDY HERO — the page header: source badge, Latin + common + Bangla names,
/// and a facts strip (forms · potency · route · brands)
/// ============================================================
///
/// MedEx's header block carries name, form, generic, strength, company and price at a
/// glance; this is the homeopathic equivalent. The strip only shows what is known.
/// ============================================================
library;

import 'package:material_ui/material_ui.dart';

import 'package:homio_essentials/core/archive/domain/entities/models.dart';
import 'package:homio_essentials/core/l10n/i18n.dart';
import 'package:homio_essentials/core/theme/app_theme.dart';
import 'package:homio_essentials/core/theme/tokens.dart';
import 'package:homio_essentials/core/widgets/widgets.dart';

class RemedyHero extends StatelessWidget {
  const RemedyHero({super.key, required this.r, this.brandCount = 0, this.priceFrom});
  final Remedy r;
  final int brandCount;
  final double? priceFrom;

  @override
  Widget build(BuildContext context) {
    final c = context.hm;
    final l = context.l;
    final bangla = context.bn;
    final white96 = Colors.white.withValues(alpha: .96);
    final stats = <(String, String)>[
      if (r.potencies.isNotEmpty) (l.potency, r.potencies.length > 1 ? '${r.potencies.first} – ${r.potencies.last}' : r.potencies.first),
      if (r.forms.isNotEmpty) (l.forms, r.forms.take(2).map((f) => formLabel(f, context.bn)).join(', ')),
      if (r.curated) (l.route, r.externalUse ? l.routeOralSkin : l.routeOral),
      if (brandCount > 0) (l.tabBrands, priceFrom != null ? l.priceFrom(numL(context, priceFrom!.toStringAsFixed(0))) : numL(context, brandCount)),
    ];
    return Container(
      decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [c.hero1, c.hero2])),
      child: Stack(children: [
        PositionedDirectional(end: -110, top: -60, child: heroCircle(300)),
        PositionedDirectional(end: 16, top: 24, child: Icon(kingdomIcon(r.kingdom), size: 104, color: Colors.white.withValues(alpha: .14))),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 2, 16, 30),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Wrap(spacing: 8, runSpacing: 6, children: [
              KingdomBadge(r.kingdom, glass: true, extra: r.family),
              if (r.curated) HmBadge(l.reviewed, glass: true, icon: Icons.verified_rounded),
            ]),
            const SizedBox(height: 12),
            Semantics(header: true, child: Text(r.latin, style: latinStyle(size: 32, color: Colors.white))),
            const SizedBox(height: 6),
            Text([r.common(bangla), r.abbr].whereType<String>().where((s) => s.isNotEmpty).join(' · '), style: TextStyle(fontSize: 13.5, color: white96)),
            if (r.bnName() != null) Text(r.bnName()!, style: TextStyle(fontSize: 15, color: white96, fontWeight: FontWeight.w600)),
            if (stats.isNotEmpty) ...[
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(color: Colors.white.withValues(alpha: .12), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white.withValues(alpha: .16))),
                child: IntrinsicHeight(
                  child: Row(children: [
                    for (final (i, (k, v)) in stats.indexed) ...[
                      if (i > 0) VerticalDivider(width: 1, color: Colors.white.withValues(alpha: .18)),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text(bangla ? k : k.toUpperCase(), maxLines: 1, overflow: TextOverflow.ellipsis,
                                style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, letterSpacing: bangla ? 0 : .7, color: white96)),
                            const SizedBox(height: 2),
                            Text(v, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white, height: 1.25)),
                          ]),
                        ),
                      ),
                    ],
                  ]),
                ),
              ),
            ],
          ]),
        ),
      ]),
    );
  }
}
