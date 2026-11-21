/// ============================================================
/// HOME SCREEN — search first, remedy of the day, browse, symptoms, ages
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
import 'package:homio_essentials/features/promotions/presentation/widgets/promo_slider.dart';
import 'package:homio_essentials/shared/providers/archive_provider.dart';
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
        child: RefreshIndicator(
          color: c.p,
          onRefresh: () => ref.read(archiveProvider.notifier).refresh(),
          child: ListView(padding: const EdgeInsets.only(bottom: 32), children: [
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(20, 16, 20, 0),
              child: Row(children: [
                const HmLogo(size: 40),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(AppInfo.localizedName(context.bn), maxLines: 1, overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w800, letterSpacing: -0.3)),
                ),
                const SizedBox(width: 8),
                const LangPill(),
              ]),
            ),
            ...switch (state) {
              AsyncValue(:final value?) => _content(context, value),
              AsyncError() => [
                  EmptyState(icon: Icons.cloud_off_rounded, title: l.loadFailedTitle, body: l.loadFailedBody, action: l.retry,
                      onAction: () => ref.invalidate(archiveProvider)),
                ],
              _ => const [HomeSkeleton()],
            },
          ]),
        ),
      ),
    );
  }

  List<Widget> _content(BuildContext context, HomeUiState s) {
    final l = context.l;
    final c = context.hm;
    final greeting = switch (s.dayPart) { DayPart.morning => l.goodMorning, DayPart.afternoon => l.goodAfternoon, DayPart.evening => l.goodEvening };
    return [
      Gutter(
        top: 18,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(greeting, style: TextStyle(color: c.ink2, fontWeight: FontWeight.w700, fontSize: 13)),
          const SizedBox(height: 4),
          Text(l.homeTitle, style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 4),
          Text(l.archiveStats(numL(context, s.remedyCount), numL(context, s.conditionCount)), style: TextStyle(color: c.ink3, fontSize: 13)),
        ]),
      ),
      Gutter(
        top: 16,
        child: SearchLauncher(
          hint: l.searchHint,
          onTap: () => context.push(AppRoutes.search),
          onVoice: () => context.push(AppRoutes.searchFor(voice: true)),
        ),
      ),
      if (s.remedyOfDay != null) Gutter(top: 20, child: RemedyOfDayCard(r: s.remedyOfDay!)),
      if (s.firstAid.isNotEmpty) ...[
        SectionHeader(l.firstAidKit),
        FirstAidRow(remedies: s.firstAid),
      ],
      SectionHeader(l.browseArchive),
      Gutter(child: BrowseGrid(canStudy: s.canStudy)),
      if (!s.canStudy) Gutter(top: 8, child: Text(l.studyModesNote, style: TextStyle(fontSize: 12, color: c.ink3))),
      const SizedBox(height: 28),
      const PromoSlider(placement: 'home'),
      SectionHeader(l.findBySymptom, action: l.seeAll, onAction: () => context.go(AppRoutes.exploreTab('symptoms'))),
      ChipRow(children: [
        for (final cd in s.conditions) HmChip(cd.name(context.bn), icon: Icons.monitor_heart_outlined, onTap: () => context.push(AppRoutes.condition(cd.slug))),
      ]),
      SectionHeader(l.doseByAge),
      Gutter(child: AgeRow(groups: s.ageGroups)),
      if (s.recent.isNotEmpty) ...[
        SectionHeader(l.recentlyViewed, action: l.history, onAction: () => context.go(AppRoutes.saved)),
        for (final r in s.recent)
          Gutter(child: Padding(padding: const EdgeInsets.only(bottom: 10), child: RemedyRow(r, onTap: () => context.push(AppRoutes.remedy(r.slug))))),
      ],
      SectionHeader(l.learnBasics),
      const Gutter(child: LearnCard()),
    ];
  }
}
