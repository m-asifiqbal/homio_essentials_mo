/// ============================================================
/// REMEDY SCREEN — hero + five tabs (Overview · Uses · Dosage · Brands · Study)
/// ============================================================
///
/// NestedScrollView with a pinned tab bar; each tab scrolls on its own
/// (TabList injects the overlap). `?tab=study` opens a tab directly.
/// ============================================================
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import 'package:homio_essentials/core/l10n/i18n.dart';
import 'package:homio_essentials/core/theme/app_theme.dart';
import 'package:homio_essentials/core/theme/tokens.dart';
import 'package:homio_essentials/core/widgets/widgets.dart';
import 'package:homio_essentials/features/remedy/presentation/notifiers/remedy_actions.dart';
import 'package:homio_essentials/features/remedy/presentation/providers/remedy_providers.dart';
import 'package:homio_essentials/features/remedy/presentation/widgets/brands_tab.dart';
import 'package:homio_essentials/features/remedy/presentation/widgets/dosage_tab.dart';
import 'package:homio_essentials/features/remedy/presentation/widgets/overview_tab.dart';
import 'package:homio_essentials/features/remedy/presentation/widgets/remedy_hero.dart';
import 'package:homio_essentials/features/remedy/presentation/widgets/study_tab.dart';
import 'package:homio_essentials/features/remedy/presentation/widgets/uses_tab.dart';
import 'package:homio_essentials/shared/providers/library_provider.dart';

const remedyTabs = ['overview', 'uses', 'dosage', 'brands', 'study'];

class RemedyScreen extends ConsumerStatefulWidget {
  const RemedyScreen({super.key, required this.slug, this.tab});
  final String slug;
  final String? tab;

  @override
  ConsumerState<RemedyScreen> createState() => _RemedyScreenState();
}

class _RemedyScreenState extends ConsumerState<RemedyScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabs = TabController(length: remedyTabs.length, vsync: this, initialIndex: remedyTabs.indexOf(widget.tab ?? '').clamp(0, 4));

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => RemedyActions.recordView(ref, widget.slug));
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final c = context.hm;
    final saved = ref.watch(savedProvider.select((s) => s.contains(widget.slug)));
    final detail = ref.watch(remedyDetailProvider(widget.slug));
    return Scaffold(
      body: switch (detail) {
        AsyncValue(:final value?) => NestedScrollView(
            headerSliverBuilder: (context, inner) => [
              SliverOverlapAbsorber(
                handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
                sliver: SliverMainAxisGroup(slivers: [
                  SliverAppBar(
                    pinned: true,
                    backgroundColor: c.hero1,
                    foregroundColor: Colors.white,
                    title: AnimatedOpacity(
                      duration: const Duration(milliseconds: 180),
                      opacity: inner ? 1 : 0,
                      child: Text(value.remedy.latin, style: latinStyle(size: 20, color: Colors.white)),
                    ),
                    leading: Padding(padding: const EdgeInsets.all(6), child: GlassButton(icon: Icons.arrow_back_rounded, tooltip: l.back, onTap: () => context.pop())),
                    actions: [
                      GlassButton(icon: Icons.ios_share_rounded, tooltip: l.share, onTap: () => RemedyActions.share(context, value.remedy)),
                      const SizedBox(width: 8),
                      GlassButton(icon: saved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded, tooltip: l.save,
                          onTap: () => RemedyActions.toggleSave(context, ref, widget.slug)),
                      const SizedBox(width: 12),
                    ],
                  ),
                  SliverToBoxAdapter(child: RemedyHero(r: value.remedy)),
                  SliverPersistentHeader(pinned: true, delegate: RemedyTabsHeader(_tabs, [l.tabOverview, l.tabUses, l.tabDosage, l.tabBrands, l.tabStudy], c)),
                ]),
              ),
            ],
            body: TabBarView(controller: _tabs, children: [
              OverviewTab(d: value, goTab: _tabs.animateTo),
              UsesTab(d: value, openStudy: () => _tabs.animateTo(4)),
              DosageTab(d: value),
              BrandsTab(d: value),
              StudyTab(d: value),
            ]),
          ),
        AsyncValue(hasValue: true) => SafeArea(
            child: Column(children: [
              Align(alignment: AlignmentDirectional.centerStart, child: Padding(padding: const EdgeInsets.all(12), child: IconButton(onPressed: () => context.pop(), icon: const Icon(Icons.arrow_back_rounded), tooltip: l.back))),
              Expanded(child: EmptyState(icon: Icons.search_off_rounded, title: l.notFound)),
            ]),
          ),
        AsyncError() => Center(child: EmptyState(icon: Icons.cloud_off_rounded, title: l.loadFailedTitle, body: l.loadFailedBody)),
        _ => const Center(child: CircularProgressIndicator()),
      },
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
          decoration: BoxDecoration(color: c.sf, border: Border(top: BorderSide(color: c.ln))),
          child: Row(children: [
            SizedBox(
              width: 54, height: 54,
              child: IconButton.outlined(
                onPressed: () => RemedyActions.toggleSave(context, ref, widget.slug), tooltip: l.save,
                style: IconButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)), side: BorderSide(color: c.ln)),
                icon: Icon(saved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded, color: c.p),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(child: FilledButton.icon(onPressed: () => _tabs.animateTo(2), icon: const Icon(Icons.medication_outlined), label: Text(l.doseGuide))),
          ]),
        ),
      ),
    );
  }
}
