/// ============================================================
/// A–Z REMEDY LIST — kingdom chips, fixed-height rows, draggable side index
/// ============================================================
///
/// Rows have fixed extents (itemExtentBuilder), so a letter's offset is
/// known without building it: tapping or dragging the index jumps straight
/// to that letter, with a selection haptic and a floating letter bubble.
/// ============================================================
library;

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import 'package:homio_essentials/core/l10n/i18n.dart';
import 'package:homio_essentials/core/router/app_routes.dart';
import 'package:homio_essentials/core/theme/tokens.dart';
import 'package:homio_essentials/core/widgets/widgets.dart';
import 'package:homio_essentials/features/explore/presentation/providers/explore_providers.dart';
import 'package:homio_essentials/shared/widgets/remedy_row.dart';

class AzRemedyList extends ConsumerStatefulWidget {
  const AzRemedyList({super.key});
  @override
  ConsumerState<AzRemedyList> createState() => _AzRemedyListState();
}

class _AzRemedyListState extends ConsumerState<AzRemedyList> {
  final _scroll = ScrollController();
  String? _dragLetter;

  static const _headerExtent = 40.0;
  double _rowExtent(BuildContext context) => (context.bn ? 92.0 : 76.0) * MediaQuery.textScalerOf(context).scale(1).clamp(1.0, 1.4);

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _jump(AzList list, String letter, double rowExtent) {
    final idx = list.letterIndex[letter];
    if (idx == null || !_scroll.hasClients) return;
    var offset = 0.0;
    for (var i = 0; i < idx; i++) {
      offset += list.items[i] is AzHeader ? _headerExtent : rowExtent;
    }
    _scroll.jumpTo(offset.clamp(0, _scroll.position.maxScrollExtent));
    if (_dragLetter != letter) HapticFeedback.selectionClick();
    setState(() => _dragLetter = letter);
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final c = context.hm;
    final s = ref.watch(exploreControllerProvider);
    final ctl = ref.read(exploreControllerProvider.notifier);
    final rowExtent = _rowExtent(context);
    return switch (ref.watch(azListProvider)) {
      AsyncValue(:final value?) => Column(children: [
          ChipRow(children: [
            HmChip(l.all, small: true, selected: s.kingdom == null, onTap: () => ctl.setKingdom(null)),
            for (final k in ['plant', 'mineral', 'animal', 'nosode', 'sarcode', 'other'])
              if ((value.kingdomCounts[k] ?? 0) > 0)
                HmChip(l.kingdom(k), small: true, count: value.kingdomCounts[k], selected: s.kingdom == k, dot: c.kingdom(k).$2, onTap: () => ctl.setKingdom(k)),
          ]),
          const SizedBox(height: 4),
          Expanded(
            child: value.items.isEmpty
                ? EmptyState(icon: Icons.filter_alt_off_outlined, title: l.noMatches)
                : Stack(children: [
                    ListView.builder(
                      controller: _scroll,
                      padding: EdgeInsetsDirectional.fromSTEB(Hm.gutter, 0, 40, context.barClearance),
                      itemCount: value.items.length,
                      itemExtentBuilder: (i, _) => i >= value.items.length ? null : (value.items[i] is AzHeader ? _headerExtent : rowExtent),
                      itemBuilder: (context, i) => switch (value.items[i]) {
                        AzHeader(:final letter) => Align(
                            alignment: AlignmentDirectional.bottomStart,
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 6),
                              child: Semantics(header: true, child: Text(letter, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: c.p))),
                            ),
                          ),
                        AzRemedy(:final remedy) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: RemedyRow(remedy, dense: true, onTap: () => context.push(AppRoutes.remedy(remedy.slug))),
                          ),
                      },
                    ),
                    HmScrollTopPill(controller: _scroll, itemExtent: rowExtent),
                    PositionedDirectional(
                      end: 2, top: 0, bottom: context.barClearance,
                      child: _AzIndex(
                        letters: value.letterIndex.keys.toList(),
                        onLetter: (x) => _jump(value, x, rowExtent),
                        onEnd: () => setState(() => _dragLetter = null),
                      ),
                    ),
                    if (_dragLetter != null)
                      Center(
                        child: Container(
                          width: 72, height: 72, alignment: Alignment.center,
                          decoration: BoxDecoration(color: c.p, borderRadius: BorderRadius.circular(22)),
                          child: Text(_dragLetter!, style: TextStyle(color: c.onp, fontSize: 28, fontWeight: FontWeight.w700)),
                        ),
                      ),
                  ]),
          ),
        ]),
      _ => const SkeletonList(),
    };
  }
}

class _AzIndex extends StatelessWidget {
  const _AzIndex({required this.letters, required this.onLetter, required this.onEnd});
  final List<String> letters;
  final ValueChanged<String> onLetter;
  final VoidCallback onEnd;

  @override
  Widget build(BuildContext context) {
    final c = context.hm;
    return LayoutBuilder(builder: (context, box) {
      final slot = box.maxHeight / letters.length.clamp(1, 99);
      void at(double dy) => onLetter(letters[(dy / slot).floor().clamp(0, letters.length - 1)]);
      return Semantics(
        label: context.l.azIndex,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: (d) => at(d.localPosition.dy),
          onTapUp: (_) => onEnd(),
          onVerticalDragUpdate: (d) => at(d.localPosition.dy),
          onVerticalDragEnd: (_) => onEnd(),
          child: SizedBox(
            width: 28,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [for (final x in letters) Text(x, style: TextStyle(fontSize: slot < 16 ? 10 : 12, fontWeight: FontWeight.w700, color: c.p))],
            ),
          ),
        ),
      );
    });
  }
}
