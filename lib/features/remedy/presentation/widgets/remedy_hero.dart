/// ============================================================
/// REMEDY HERO — kingdom badge, Latin name, common + Bangla names, stats;
/// the pinned tab header; glass buttons; TabList (per-tab scrolling)
/// ============================================================
library;

import 'package:material_ui/material_ui.dart';

import 'package:homio_essentials/core/archive/domain/entities/models.dart';
import 'package:homio_essentials/core/l10n/i18n.dart';
import 'package:homio_essentials/core/theme/app_theme.dart';
import 'package:homio_essentials/core/theme/tokens.dart';
import 'package:homio_essentials/core/widgets/widgets.dart';

class RemedyHero extends StatelessWidget {
  const RemedyHero({super.key, required this.r});
  final Remedy r;

  @override
  Widget build(BuildContext context) {
    final c = context.hm;
    final l = context.l;
    final bangla = context.bn;
    final white96 = Colors.white.withValues(alpha: .96);
    final stats = <(String, String)>[
      if (r.forms.isNotEmpty) (l.forms, r.forms.take(3).map((f) => f.replaceAll('_', ' ')).join(', ')),
      if (r.potencies.isNotEmpty) (l.potency, r.potencies.length > 1 ? '${r.potencies.first} – ${r.potencies.last}' : r.potencies.first),
      if (r.curated) (l.route, r.externalUse ? l.routeOralSkin : l.routeOral),
    ];
    return Container(
      decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [c.hero1, c.hero2])),
      child: Stack(children: [
        PositionedDirectional(end: -110, top: -60, child: heroCircle(300)),
        PositionedDirectional(end: 16, top: 24, child: Icon(kingdomIcon(r.kingdom), size: 120, color: Colors.white.withValues(alpha: .14))),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Wrap(spacing: 8, runSpacing: 6, children: [
              KingdomBadge(r.kingdom, glass: true, extra: r.family),
              if (r.curated) HmBadge(l.reviewed, glass: true, icon: Icons.verified_rounded),
            ]),
            const SizedBox(height: 12),
            Semantics(header: true, child: Text(r.latin, style: latinStyle(size: 38, color: Colors.white))),
            const SizedBox(height: 8),
            Text([r.common(bangla), r.abbr].whereType<String>().where((s) => s.isNotEmpty).join(' · '), style: TextStyle(fontSize: 14, color: white96)),
            if (r.bnName() != null) Text(r.bnName()!, style: TextStyle(fontSize: 16, color: white96, fontWeight: FontWeight.w600)),
            if (stats.isNotEmpty) ...[
              const SizedBox(height: 18),
              Container(
                decoration: BoxDecoration(color: Colors.white.withValues(alpha: .12), borderRadius: BorderRadius.circular(18), border: Border.all(color: Colors.white.withValues(alpha: .16))),
                child: IntrinsicHeight(
                  child: Row(children: [
                    for (final (i, (k, v)) in stats.indexed) ...[
                      if (i > 0) VerticalDivider(width: 1, color: Colors.white.withValues(alpha: .18)),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text(bangla ? k : k.toUpperCase(), style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, letterSpacing: bangla ? 0 : .8, color: white96)),
                            const SizedBox(height: 2),
                            Text(v, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white, height: 1.3)),
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

class RemedyTabsHeader extends SliverPersistentHeaderDelegate {
  RemedyTabsHeader(this.controller, this.labels, this.c);
  final TabController controller;
  final List<String> labels;
  final HomaColors c;

  @override
  double get minExtent => 52;
  @override
  double get maxExtent => 52;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) => Container(
        color: c.hero2,
        child: Container(
          decoration: BoxDecoration(color: c.bg, borderRadius: BorderRadius.vertical(top: Radius.circular(shrinkOffset > 0 || overlapsContent ? 0 : 24))),
          child: TabBar(
            controller: controller, isScrollable: true, tabAlignment: TabAlignment.start,
            padding: const EdgeInsets.symmetric(horizontal: 8), labelPadding: const EdgeInsets.symmetric(horizontal: 10),
            tabs: [for (final t in labels) Tab(text: t, height: 51)],
          ),
        ),
      );

  @override
  bool shouldRebuild(covariant RemedyTabsHeader old) => old.labels != labels || old.c != c;
}

class GlassButton extends StatelessWidget {
  const GlassButton({super.key, required this.icon, required this.onTap, required this.tooltip});
  final IconData icon;
  final VoidCallback onTap;
  final String tooltip;

  @override
  Widget build(BuildContext context) => Tooltip(
        message: tooltip,
        child: Material(
          color: Colors.white.withValues(alpha: .16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14), side: BorderSide(color: Colors.white.withValues(alpha: .22))),
          child: InkWell(
            customBorder: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            onTap: onTap,
            child: SizedBox(width: 44, height: 44, child: Icon(icon, color: Colors.white, semanticLabel: tooltip)),
          ),
        ),
      );
}

/// A tab's own scroll view inside the NestedScrollView (never hidden under the pinned header).
class TabList extends StatelessWidget {
  const TabList({super.key, required this.name, required this.children});
  final String name;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Builder(
        builder: (context) => CustomScrollView(
          key: PageStorageKey(name),
          slivers: [
            SliverOverlapInjector(handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context)),
            SliverPadding(padding: const EdgeInsets.only(top: 16, bottom: 32), sliver: SliverList.list(children: children)),
          ],
        ),
      );
}
