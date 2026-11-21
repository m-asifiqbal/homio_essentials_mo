/// ============================================================
/// SAVED SCREEN — bookmarked remedies (swipe to remove, Undo) + history
/// ============================================================
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import 'package:homio_essentials/core/l10n/i18n.dart';
import 'package:homio_essentials/core/router/app_routes.dart';
import 'package:homio_essentials/core/theme/tokens.dart';
import 'package:homio_essentials/core/widgets/widgets.dart';
import 'package:homio_essentials/features/saved/presentation/providers/saved_providers.dart';
import 'package:homio_essentials/shared/providers/library_provider.dart';
import 'package:homio_essentials/shared/widgets/remedy_row.dart';

class SavedScreen extends ConsumerWidget {
  const SavedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l;
    final c = context.hm;
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: HmTabPage(
          header: Gutter(
            top: 14,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(l.savedTitle, style: Theme.of(context).textTheme.headlineMedium),
                Text(l.savedSub, style: TextStyle(color: c.ink2, fontSize: 12.5)),
              ]),
            ),
          ),
          body: ListView(padding: EdgeInsets.only(top: 14, bottom: context.barClearance), children: [
          ...switch (ref.watch(savedListsProvider)) {
            AsyncValue(:final value?) => [
                if (value.saved.isEmpty)
                  EmptyState(icon: Icons.bookmark_border_rounded, title: l.savedEmptyTitle, body: l.savedEmptyBody,
                      action: l.browseRemedies, onAction: () => context.go(AppRoutes.explore))
                else ...[
                  Gutter(child: Padding(padding: const EdgeInsets.only(bottom: 8), child: Text(l.swipeToRemove, style: TextStyle(fontSize: 12, color: c.ink3)))),
                  for (final r in value.saved)
                    Gutter(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Dismissible(
                          key: ValueKey('saved-${r.slug}'),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            alignment: AlignmentDirectional.centerEnd,
                            padding: const EdgeInsetsDirectional.only(end: 20),
                            decoration: BoxDecoration(color: c.dg, borderRadius: BorderRadius.circular(Hm.rCard)),
                            child: Icon(Icons.bookmark_remove_outlined, color: c.dgInk),
                          ),
                          onDismissed: (_) {
                            final before = ref.read(savedProvider);
                            ref.read(savedProvider.notifier).remove(r.slug);
                            showHmSnack(context, l.removedSnack, action: l.undo, onAction: () => ref.read(savedProvider.notifier).restore(before));
                          },
                          child: RemedyRow(r, onTap: () => context.push(AppRoutes.remedy(r.slug))),
                        ),
                      ),
                    ),
                ],
                if (value.history.isNotEmpty) ...[
                  SectionHeader(l.recentlyViewed, action: l.clear, onAction: () {
                    final before = ref.read(historyProvider);
                    ref.read(historyProvider.notifier).clear();
                    showHmSnack(context, l.historyCleared, action: l.undo, onAction: () => ref.read(historyProvider.notifier).restore(before));
                  }),
                  for (final r in value.history)
                    Gutter(child: Padding(padding: const EdgeInsets.only(bottom: 8), child: RemedyRow(r, dense: true, onTap: () => context.push(AppRoutes.remedy(r.slug))))),
                ],
              ],
            AsyncError() => [EmptyState(icon: Icons.cloud_off_rounded, title: l.loadFailedTitle, body: l.loadFailedBody)],
            _ => const [SkeletonList(count: 4)],
          },
          ]),
        ),
      ),
    );
  }
}
