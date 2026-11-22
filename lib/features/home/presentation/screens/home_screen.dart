/// ============================================================
/// HOME SCREEN — pinned top bar + search, then remedy of the day, browse, symptoms, ages
/// ============================================================
///
/// The logo / language row and the search launcher are PINNED ([HmTabPage]); only the
/// content below scrolls. The body is a lazy CustomScrollView (sliver list), the browse
/// grid is plain rows (no shrink-wrapped GridView), and section reveals play once.
/// ============================================================
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import 'package:homio_essentials/core/constants/app_info.dart';
import 'package:homio_essentials/core/l10n/i18n.dart';
import 'package:homio_essentials/core/router/app_routes.dart';
import 'package:homio_essentials/core/theme/tokens.dart';
import 'package:homio_essentials/core/widgets/widgets.dart';
import 'package:homio_essentials/features/home/presentation/providers/home_providers.dart';
import 'package:homio_essentials/features/home/presentation/widgets/home_sections.dart';
import 'package:homio_essentials/features/home/presentation/widgets/learn_slider.dart';
import 'package:homio_essentials/features/promotions/presentation/widgets/promo_slider.dart';
import 'package:homio_essentials/shared/providers/archive_provider.dart';
import 'package:homio_essentials/shared/widgets/archive_gate.dart';
import 'package:homio_essentials/shared/widgets/lang_pill.dart';
import 'package:homio_essentials/shared/widgets/remedy_row.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l;
    final c = context.hm;
    final state = ref.watch(homeStateProvider);
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: HmTabPage(
          header: Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(Hm.gutter, 12, Hm.gutter, 12),
            child: Column(children: [
              Row(children: [
                const HmLogo(size: 36),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(AppInfo.localizedName(context.bn), maxLines: 1, overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleLarge),
                ),
                const SizedBox(width: 8),
                const LangPill(),
              ]),
              const SizedBox(height: 12),
              SearchLauncher(
                hint: l.searchHint,
                height: 50,
                onTap: () => context.push(AppRoutes.search),
                onVoice: () => context.push(AppRoutes.searchFor(voice: true)),
              ),
            ]),
          ),
          body: RefreshIndicator(
            color: c.p,
            edgeOffset: 0,
            onRefresh: () => ref.read(archiveProvider.notifier).refresh(),
            child: CustomScrollView(
              slivers: [
                ...switch (state) {
                  AsyncValue(:final value?) => _content(context, value),
                  AsyncError(:final error) => [
                      SliverFillRemaining(hasScrollBody: false, child: ArchiveError(error: error)),
                    ],
                  _ => const [SliverToBoxAdapter(child: HomeSkeleton())],
                },
                SliverToBoxAdapter(child: SizedBox(height: context.barClearance + 8)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _content(BuildContext context, HomeUiState s) {
    final l = context.l;
    final c = context.hm;
    final greeting = switch (s.dayPart) { DayPart.morning => l.goodMorning, DayPart.afternoon => l.goodAfternoon, DayPart.evening => l.goodEvening };
    return [
      SliverList.list(children: [
        Gutter(
          top: 6,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(greeting, style: TextStyle(color: c.ink2, fontWeight: FontWeight.w600, fontSize: 12.5)),
            const SizedBox(height: 2),
            Text(l.homeTitle, style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 2),
            Text(l.archiveStats(numL(context, s.remedyCount), numL(context, s.conditionCount)), style: TextStyle(color: c.ink3, fontSize: 12.5)),
          ]),
        ),
        if (s.remedyOfDay != null) Gutter(top: 18, child: RemedyOfDayCard(r: s.remedyOfDay!)),
        if (s.firstAid.isNotEmpty) ...[
          SectionHeader(l.firstAidKit, top: 26),
          FirstAidRow(remedies: s.firstAid),
        ],
        SectionHeader(l.browseArchive, top: 26),
        Gutter(child: BrowseGrid(canStudy: s.canStudy)),
        if (!s.canStudy) Gutter(top: 8, child: Text(l.studyModesNote, style: TextStyle(fontSize: 11.5, color: c.ink3))),
        const SizedBox(height: 24),
        const PromoSlider(placement: 'home'),
        SectionHeader(l.findBySymptom, top: 26, action: l.seeAll, onAction: () => context.go(AppRoutes.exploreTab('symptoms'))),
        ChipRow(children: [
          for (final cd in s.conditions) HmChip(cd.name(context.bn), icon: Icons.monitor_heart_outlined, onTap: () => context.push(AppRoutes.condition(cd.slug))),
        ]),
        SectionHeader(l.doseByAge, top: 26),
        Gutter(child: AgeRow(groups: s.ageGroups)),
        if (s.recent.isNotEmpty) ...[
          SectionHeader(l.recentlyViewed, top: 26, action: l.history, onAction: () => context.go(AppRoutes.saved)),
          for (final r in s.recent)
            Gutter(child: Padding(padding: const EdgeInsets.only(bottom: 10), child: RemedyRow(r, onTap: () => context.push(AppRoutes.remedy(r.slug))))),
        ],
        SectionHeader(l.learnBasics, top: 26),
        const LearnSlider(),
      ]),
    ];
  }
}
