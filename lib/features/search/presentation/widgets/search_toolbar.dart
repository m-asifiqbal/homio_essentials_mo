/// "N results for …" on the left; Sort and Filters pills on the right (shown once you search).
library;

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import 'package:homio_essentials/core/l10n/i18n.dart';
import 'package:homio_essentials/core/theme/tokens.dart';
import 'package:homio_essentials/core/widgets/widgets.dart';
import 'package:homio_essentials/features/search/domain/entities/search_query.dart';
import 'package:homio_essentials/features/search/presentation/providers/search_providers.dart';
import 'package:homio_essentials/features/search/presentation/widgets/search_filter_sheet.dart';

class SearchToolbar extends ConsumerWidget {
  const SearchToolbar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.hm;
    final l = context.l;
    final ctl = ref.read(searchControllerProvider.notifier);
    final sort = ref.watch(searchControllerProvider.select((s) => s.sort));
    final filters = ref.watch(searchControllerProvider.select((s) => s.filters));
    final q = ref.watch(searchControllerProvider.select((s) => s.query.trim()));
    final category = ref.watch(searchControllerProvider.select((s) => s.category));
    final total = ref.watch(searchResultsProvider.select((r) => r.total));
    final byRelevance = sort == SearchSort.relevance;
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(Hm.gutter, 0, 14, 6),
      child: Row(children: [
        Expanded(
          child: Text(
            category == SearchCategory.books ? l.inTheBooks : l.resultsFor(numL(context, total), q),
            maxLines: 1, overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 12, color: c.ink3, fontWeight: FontWeight.w600),
          ),
        ),
        const SizedBox(width: 8),
        _Pill(
          icon: byRelevance ? Icons.auto_awesome_outlined : Icons.sort_by_alpha_rounded,
          label: byRelevance ? l.sortRelevance : l.sortAZ,
          active: !byRelevance,
          onTap: () { HapticFeedback.selectionClick(); ctl.setSort(byRelevance ? SearchSort.alphabetical : SearchSort.relevance); },
        ),
        const SizedBox(width: 6),
        _Pill(
          icon: Icons.tune_rounded,
          label: filters.isEmpty ? l.filters : '${l.filters} · ${numL(context, filters.activeCount)}',
          active: !filters.isEmpty,
          onTap: () => showSearchFilterSheet(context, ref),
        ),
      ]),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.icon, required this.label, required this.active, required this.onTap});
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.hm;
    return Semantics(
      button: true, label: label, excludeSemantics: true,
      child: HmPressable(
        onTap: onTap,
        child: AnimatedContainer(
          duration: context.motion(HmMotion.fast),
          height: 32,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: active ? c.sf2 : c.sf,
            borderRadius: BorderRadius.circular(99),
            border: Border.all(color: active ? c.p : c.ln),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(icon, size: 15, color: active ? c.p : c.ink2),
            const SizedBox(width: 5),
            Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: active ? c.pd : c.ink2)),
          ]),
        ),
      ),
    );
  }
}
