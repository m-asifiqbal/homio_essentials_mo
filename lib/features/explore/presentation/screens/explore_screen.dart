/// ============================================================
/// EXPLORE SCREEN — A–Z remedies (kingdom filter + side index), symptoms, companies
/// ============================================================
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import 'package:homio_essentials/core/l10n/i18n.dart';
import 'package:homio_essentials/core/router/app_routes.dart';
import 'package:homio_essentials/core/theme/tokens.dart';
import 'package:homio_essentials/core/widgets/widgets.dart';
import 'package:homio_essentials/features/explore/presentation/providers/explore_providers.dart';
import 'package:homio_essentials/features/explore/presentation/widgets/az_remedy_list.dart';
import 'package:homio_essentials/features/explore/presentation/widgets/explore_lists.dart';
import 'package:homio_essentials/shared/widgets/archive_gate.dart';

class ExploreScreen extends ConsumerStatefulWidget {
  const ExploreScreen({super.key, this.initialSegment});
  final String? initialSegment;

  @override
  ConsumerState<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends ConsumerState<ExploreScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _applyDeepLink());
  }

  @override
  void didUpdateWidget(covariant ExploreScreen old) {
    super.didUpdateWidget(old);
    if (old.initialSegment != widget.initialSegment) _applyDeepLink();
  }

  void _applyDeepLink() {
    final seg = ExploreSegment.values.asNameMap()[widget.initialSegment];
    if (seg != null) ref.read(exploreControllerProvider.notifier).setSegment(seg);
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final s = ref.watch(exploreControllerProvider);
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Gutter(
            top: 20,
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(l.exploreTitle, style: Theme.of(context).textTheme.headlineMedium),
              Text(l.exploreSub, style: TextStyle(color: context.hm.ink2, fontSize: 13)),
              const SizedBox(height: 14),
              SearchLauncher(
                hint: l.searchArchive, height: 52,
                onTap: () => context.push(AppRoutes.search),
                onVoice: () => context.push(AppRoutes.searchFor(voice: true)),
              ),
              const SizedBox(height: 12),
              Segmented<ExploreSegment>(
                options: [(ExploreSegment.remedies, l.segRemedies), (ExploreSegment.symptoms, l.segSymptoms), (ExploreSegment.companies, l.segCompanies)],
                value: s.segment,
                onChanged: ref.read(exploreControllerProvider.notifier).setSegment,
              ),
            ]),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ArchiveGate(
              skeleton: const SkeletonList(),
              builder: (context, archive) => switch (s.segment) {
                ExploreSegment.symptoms => SymptomList(archive: archive),
                ExploreSegment.companies => CompanyList(archive: archive),
                ExploreSegment.remedies => const AzRemedyList(),
              },
            ),
          ),
        ]),
      ),
    );
  }
}
