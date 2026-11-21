/// ============================================================
/// HOME SECTIONS — remedy of the day, first-aid row, browse grid, ages
/// ============================================================
library;

import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import 'package:homio_essentials/core/archive/domain/entities/models.dart';
import 'package:homio_essentials/core/l10n/i18n.dart';
import 'package:homio_essentials/core/router/app_routes.dart';
import 'package:homio_essentials/core/theme/app_theme.dart';
import 'package:homio_essentials/core/theme/tokens.dart';
import 'package:homio_essentials/core/widgets/widgets.dart';

class RemedyOfDayCard extends StatelessWidget {
  const RemedyOfDayCard({super.key, required this.r});
  final Remedy r;

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final c = context.hm;
    final bangla = context.bn;
    final white = Colors.white.withValues(alpha: .96);
    return HeroBox(
      onTap: () => context.push(AppRoutes.remedy(r.slug)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 150),
        child: Row(children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(l.remedyOfDay, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: bangla ? 0 : 1, color: white)),
              const SizedBox(height: 6),
              Text(r.latin, style: latinStyle(size: 25, color: Colors.white)),
              const SizedBox(height: 4),
              Text([r.common(bangla), l.kingdom(r.kingdom)].whereType<String>().join(' · '), style: TextStyle(fontSize: 13, color: white)),
              if (bangla && r.bnName() != null) Text(r.bnName()!, style: const TextStyle(fontSize: 15, color: Colors.white)),
              const SizedBox(height: 10),
              Text(r.summary(bangla) ?? '', maxLines: 3, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 14, color: Colors.white, height: 1.45)),
              const SizedBox(height: 12),
              Container(
                height: 36,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(99)),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Text(l.readMore, style: TextStyle(color: c.dark ? c.hero1 : c.pd, fontWeight: FontWeight.w700, fontSize: 14)),
                  Icon(Icons.chevron_right_rounded, size: 18, color: c.dark ? c.hero1 : c.pd),
                ]),
              ),
            ]),
          ),
          const SizedBox(width: 8),
          Icon(kingdomIcon(r.kingdom), size: 72, color: Colors.white.withValues(alpha: .35)),
        ]),
      ),
    );
  }
}

/// Horizontal first-aid kit: Arnica, Calendula, Hypericum…
class FirstAidRow extends StatelessWidget {
  const FirstAidRow({super.key, required this.remedies});
  final List<Remedy> remedies;

  @override
  Widget build(BuildContext context) {
    final c = context.hm;
    final bangla = context.bn;
    // 6 dp of air above and below so the cards' soft shadow isn't clipped by the horizontal list.
    return SizedBox(
      height: 144,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: Hm.gutter, vertical: 6),
        itemCount: remedies.length,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (context, i) {
          final r = remedies[i];
          final use = r.common(bangla);
          return SizedBox(
            width: 168,
            child: HmCard(
              onTap: () => context.push(AppRoutes.remedy(r.slug)),
              padding: const EdgeInsets.all(14),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                LetterTile(r.initial, kingdom: r.kingdom, size: 36),
                const Spacer(),
                latinText(r.latin, size: 17, color: c.ink, weight: FontWeight.w600, maxLines: 1),
                Text(bangla && r.bnName() != null ? r.bnName()! : (use ?? ''), maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12.5, color: c.ink2)),
              ]),
            ),
          );
        },
      ),
    );
  }
}

class BrowseGrid extends StatelessWidget {
  const BrowseGrid({super.key, required this.canStudy});
  final bool canStudy;

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final c = context.hm;
    // Two plain rows of three equal tiles — a shrink-wrapped GridView re-measures every child on each layout.
    final tiles = [
      _Tile(Icons.eco_outlined, l.browseRemedies, (c.ptBg, c.ptInk), () => context.go(AppRoutes.explore)),
      _Tile(Icons.monitor_heart_outlined, l.browseSymptoms, (c.dg, c.dgInk), () => context.go(AppRoutes.exploreTab('symptoms'))),
      _Tile(Icons.factory_outlined, l.browseCompanies, (c.miBg, c.miInk), () => context.go(AppRoutes.exploreTab('companies'))),
      _Tile(Icons.menu_book_outlined, l.browseMateria, (c.anBg, c.anInk), () => context.push(AppRoutes.searchFor()), locked: !canStudy),
      _Tile(Icons.bookmark_border_rounded, l.browseSaved, (c.noBg, c.noInk), () => context.go(AppRoutes.saved)),
      _Tile(Icons.science_outlined, l.browseGuide, (c.bcBg, c.bcInk), () => context.push(AppRoutes.guide)),
    ];
    Widget row(List<Widget> r) => IntrinsicHeight(
          child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            for (final (i, t) in r.indexed) ...[if (i > 0) const SizedBox(width: 10), Expanded(child: t)],
          ]),
        );
    return Column(children: [row(tiles.sublist(0, 3)), const SizedBox(height: 10), row(tiles.sublist(3))]);
  }
}

class _Tile extends StatelessWidget {
  const _Tile(this.icon, this.label, this.tone, this.onTap, {this.locked = false});
  final IconData icon;
  final String label;
  final (Color, Color) tone;
  final VoidCallback onTap;
  final bool locked;

  @override
  Widget build(BuildContext context) => HmCard(
        onTap: onTap,
        semanticLabel: label,
        padding: const EdgeInsets.fromLTRB(6, 12, 6, 10),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Stack(clipBehavior: Clip.none, children: [
            IconTile(icon, tone, size: 38),
            if (locked) PositionedDirectional(end: -6, top: -6, child: Icon(Icons.lock_rounded, size: 14, color: context.hm.ink3)),
          ]),
          const SizedBox(height: 8),
          Text(label, textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, height: 1.2)),
        ]),
      );
}

class AgeRow extends StatelessWidget {
  const AgeRow({super.key, required this.groups});
  final List<AgeGroup> groups;

  @override
  Widget build(BuildContext context) {
    final c = context.hm;
    (Color, Color) tone(String code) => switch (code) { 'infant' => (c.am, c.amInk), 'child' => (c.ptBg, c.ptInk), 'senior' => (c.noBg, c.noInk), _ => (c.miBg, c.miInk) };
    IconData icon(String code) => switch (code) {
          'infant' => Icons.child_friendly_outlined, 'child' => Icons.star_border_rounded, 'senior' => Icons.elderly_rounded, _ => Icons.person_outline_rounded };
    return Row(children: [
      for (final (i, g) in groups.indexed) ...[
        if (i > 0) const SizedBox(width: 8),
        Expanded(
          child: Builder(builder: (context) {
            final label = g.label.of(context.bn) ?? g.code;
            final m = RegExp(r'^(.*?)\s*\((.*)\)$').firstMatch(label);
            return HmCard(
              onTap: () => context.push(AppRoutes.guide),
              radius: 18,
              semanticLabel: label,
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
              child: Column(children: [
                IconTile(icon(g.code), tone(g.code), size: 34),
                const SizedBox(height: 6),
                Text(m?.group(1) ?? label, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600)),
                if (m != null) Text(m.group(2)!, maxLines: 1, style: TextStyle(fontSize: 11.5, color: c.ink2)),
              ]),
            );
          }),
        ),
      ],
    ]);
  }
}

class LearnCard extends StatelessWidget {
  const LearnCard({super.key});

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final c = context.hm;
    return HmCard(
      color: c.pe, border: c.pe, radius: 28, padding: const EdgeInsets.fromLTRB(20, 22, 20, 22),
      onTap: () => context.push(AppRoutes.guide),
      child: Row(children: [
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            HmBadge(l.guideBadge, bg: Colors.white.withValues(alpha: .6), ink: c.peInk),
            const SizedBox(height: 10),
            Text(l.potencyGuideTitle, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, height: 1.25, color: c.peInk)),
            const SizedBox(height: 6),
            Text(l.potencyGuideBody, style: TextStyle(fontSize: 13, color: c.peInk)),
          ]),
        ),
        const SizedBox(width: 12),
        Icon(Icons.bubble_chart_outlined, size: 56, color: c.peInk.withValues(alpha: .5)),
      ]),
    );
  }
}

/// First-download placeholder shaped like the Home page.
class HomeSkeleton extends StatelessWidget {
  const HomeSkeleton({super.key});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(Hm.gutter, 20, Hm.gutter, 0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const HmSkeleton(height: 12, width: 90),
          const SizedBox(height: 10),
          const HmSkeleton(height: 28, width: 260),
          const SizedBox(height: 16),
          const HmSkeleton(height: 56, radius: 18),
          const SizedBox(height: 20),
          const HmSkeleton(height: 170, radius: 28),
          const SizedBox(height: 28),
          Row(children: const [Expanded(child: HmSkeleton(height: 96, radius: 20)), SizedBox(width: 12), Expanded(child: HmSkeleton(height: 96, radius: 20)), SizedBox(width: 12), Expanded(child: HmSkeleton(height: 96, radius: 20))]),
          const SizedBox(height: 18),
          Center(child: Text(context.l.loadingArchive, textAlign: TextAlign.center, style: TextStyle(color: context.hm.ink2))),
        ]),
      );
}
