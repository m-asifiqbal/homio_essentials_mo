/// Filter sheet: kingdoms, reviewed-only, has-Bangla, sort.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import 'package:homio_essentials/core/l10n/i18n.dart';
import 'package:homio_essentials/core/theme/tokens.dart';
import 'package:homio_essentials/core/widgets/widgets.dart';
import 'package:homio_essentials/features/search/domain/entities/search_query.dart';
import 'package:homio_essentials/features/search/presentation/providers/search_providers.dart';

Future<void> showSearchFilterSheet(BuildContext context, WidgetRef ref) => showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => const _FilterSheet(),
    );

class _FilterSheet extends ConsumerStatefulWidget {
  const _FilterSheet();
  @override
  ConsumerState<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends ConsumerState<_FilterSheet> {
  late SearchFilters _f = ref.read(searchControllerProvider).filters;
  late SearchSort _sort = ref.read(searchControllerProvider).sort;
  static const _kingdoms = ['plant', 'mineral', 'animal', 'nosode', 'sarcode', 'other'];

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final c = context.hm;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(child: Text(l.filters, style: Theme.of(context).textTheme.titleLarge)),
            TextButton(onPressed: () => setState(() { _f = SearchFilters.none; _sort = SearchSort.relevance; }), child: Text(l.reset)),
          ]),
          const SizedBox(height: 8),
          Cap(l.kingdomLabel),
          const SizedBox(height: 10),
          Wrap(spacing: 8, runSpacing: 8, children: [
            for (final k in _kingdoms)
              HmChip(l.kingdom(k), small: true, dot: c.kingdom(k).$2, selected: _f.kingdoms.contains(k), onTap: () => setState(() {
                final next = {..._f.kingdoms};
                if (!next.remove(k)) next.add(k);
                _f = _f.copyWith(kingdoms: next);
              })),
          ]),
          const SizedBox(height: 16),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(l.reviewedOnly, style: const TextStyle(fontWeight: FontWeight.w700)),
            subtitle: Text(l.reviewedOnlySub, style: TextStyle(fontSize: 12.5, color: c.ink2)),
            value: _f.reviewedOnly,
            onChanged: (v) => setState(() => _f = _f.copyWith(reviewedOnly: v)),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(l.withBangla, style: const TextStyle(fontWeight: FontWeight.w700)),
            subtitle: Text(l.withBanglaSub, style: TextStyle(fontSize: 12.5, color: c.ink2)),
            value: _f.withBangla,
            onChanged: (v) => setState(() => _f = _f.copyWith(withBangla: v)),
          ),
          const SizedBox(height: 8),
          Cap(l.sortBy),
          const SizedBox(height: 8),
          Segmented<SearchSort>(options: [(SearchSort.relevance, l.sortRelevance), (SearchSort.alphabetical, l.sortAZ)], value: _sort, onChanged: (v) => setState(() => _sort = v)),
          const SizedBox(height: 18),
          FilledButton(
            style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(52)),
            onPressed: () {
              ref.read(searchControllerProvider.notifier)
                ..setFilters(_f)
                ..setSort(_sort);
              Navigator.pop(context);
            },
            child: Text(l.apply),
          ),
        ]),
      ),
    );
  }
}
